import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:lernit_ai/models/scenario.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DriveService {
  static final DriveService _instance = DriveService._internal();
  factory DriveService() => _instance;
  DriveService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
      drive.DriveApi.driveMetadataScope,
    ],
  );
  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  String? _folderId;
  final _storage = const FlutterSecureStorage();

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<bool> signIn() async {
    _currentUser = await _googleSignIn.signIn();
    if (_currentUser == null) return false;
    final authHeaders = await _currentUser!.authHeaders;
    final client = GoogleAuthClient(authHeaders);
    _driveApi = drive.DriveApi(client);
    return true;
  }

  Future<bool> signInSilently() async {
    final account = await _googleSignIn.signInSilently();
    if (account == null) return false;
    _currentUser = account;
    final authHeaders = await _currentUser!.authHeaders;
    final client = GoogleAuthClient(authHeaders);
    _driveApi = drive.DriveApi(client);
    return true;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
    _folderId = null;
    await _storage.delete(key: 'drive_folder_id');
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<void> setFolderId(String folderId) async {
    _folderId = folderId;
    await _storage.write(key: 'drive_folder_id', value: folderId);
  }

  Future<String?> getFolderId() async {
    _folderId ??= await _storage.read(key: 'drive_folder_id');
    return _folderId;
  }

  Future<List<drive.File>> listScenarioFiles() async {
    if (_driveApi == null || _folderId == null) return [];
    final files = await _driveApi!.files.list(
      q: "'$_folderId' in parents and mimeType = 'application/json' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name, modifiedTime)',
    );
    return files.files ?? [];
  }

  Future<void> uploadScenario(Scenario scenario) async {
    if (_driveApi == null || _folderId == null)
      throw Exception('Drive not connected');
    final safeName =
        scenario.title.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_') + '.json';
    // Try to find existing file
    final files = await _driveApi!.files.list(
      q: "'$_folderId' in parents and name = '$safeName' and mimeType = 'application/json' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );
    final content = utf8.encode(json.encode(scenario.toJson()));
    if (files.files != null && files.files!.isNotEmpty) {
      // Overwrite existing file
      final fileId = files.files!.first.id;
      await _driveApi!.files.update(
        drive.File(),
        fileId!,
        uploadMedia: drive.Media(Stream.value(content), content.length),
      );
    } else {
      // Create new file
      final file = drive.File()
        ..name = safeName
        ..parents = [_folderId!]
        ..mimeType = 'application/json';
      await _driveApi!.files.create(
        file,
        uploadMedia: drive.Media(Stream.value(content), content.length),
      );
    }
  }

  Future<String> uploadSceneImage({
    required String scenarioTitle,
    File? imageFile,
    Uint8List? imageBytes,
    required String imageName,
  }) async {
    if (_driveApi == null || _folderId == null)
      throw Exception('Drive not connected');
    final mediaFolderName =
        scenarioTitle.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_') + '_media';
    String? mediaFolderId;
    final folderList = await _driveApi!.files.list(
      q: "'$_folderId' in parents and name = '$mediaFolderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );
    if (folderList.files != null && folderList.files!.isNotEmpty) {
      mediaFolderId = folderList.files!.first.id;
    } else {
      final folder = drive.File()
        ..name = mediaFolderName
        ..parents = [_folderId!]
        ..mimeType = 'application/vnd.google-apps.folder';
      final created = await _driveApi!.files.create(folder);
      mediaFolderId = created.id;
    }
    final imageDriveFile = drive.File()
      ..name = imageName
      ..parents = [mediaFolderId!]
      ..mimeType = 'image/jpeg';
    final bytes = imageBytes ?? await imageFile!.readAsBytes();
    final uploaded = await _driveApi!.files.create(
      imageDriveFile,
      uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
    );
    return uploaded.name ?? imageName;
  }

  /// Deletes a file from Google Drive by its file ID.
  Future<void> deleteFileById(String fileId) async {
    if (_driveApi == null) throw Exception('Drive not connected');
    await _driveApi!.files.delete(fileId);
  }

  /// Returns the metadata for a file by its Drive file ID.
  Future<drive.File?> getFileMetadata(String fileId) async {
    if (_driveApi == null) throw Exception('Drive not connected');
    return await _driveApi!.files.get(fileId) as drive.File;
  }

  /// Returns the file content as bytes for a given Drive file ID.
  Future<List<int>> getFileById(String fileId) async {
    if (_driveApi == null) throw Exception('Drive not connected');
    final media = await _driveApi!.files.get(fileId,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  // Download an image for a scene from Drive
  Future<List<int>?> downloadSceneImage({
    required String scenarioTitle,
    required String imageName,
  }) async {
    if (_driveApi == null || _folderId == null)
      throw Exception('Drive not connected');
    final mediaFolderName =
        scenarioTitle.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_') + '_media';
    // Find the media folder for this scenario
    final folderList = await _driveApi!.files.list(
      q: "'$_folderId' in parents and name = '$mediaFolderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );
    if (folderList.files == null || folderList.files!.isEmpty) return null;
    final mediaFolderId = folderList.files!.first.id;
    // Find the image file in the media folder
    final imageList = await _driveApi!.files.list(
      q: "'$mediaFolderId' in parents and name = '$imageName' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );
    if (imageList.files == null || imageList.files!.isEmpty) return null;
    final imageId = imageList.files!.first.id;
    final media = await _driveApi!.files.get(imageId!,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  // TODO: Add methods for folder picking, file download/upload, and image handling.
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
