import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../utils/scenario_cache.dart';
import '../services/secure_storage_service.dart';
import '../services/drive_service.dart';

const String kTrainerSecretKey = 'TR!@#123'; // Change as needed

class SettingsScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChanged;
  const SettingsScreen({Key? key, required this.onLocaleChanged})
      : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool _isTrainer = false;
  bool _isDriveLoading = false;
  bool _isDriveSignedIn = false;
  String? _driveFolderId;
  String? _driveEmail;
  final _keyController = TextEditingController();
  final _apiKeyController = TextEditingController();
  String? _apiKeyMasked;

  @override
  void initState() {
    super.initState();
    _loadTrainerMode();
    _loadDriveStatus();
    _loadApiKey();
  }

  Future<void> _loadTrainerMode() async {
    final isTrainer = await SecureStorageService.getTrainerMode();
    setState(() => _isTrainer = isTrainer);
  }

  Future<void> _unlockTrainerMode() async {
    if (_keyController.text == kTrainerSecretKey) {
      await SecureStorageService.setTrainerMode(true);
      setState(() => _isTrainer = true);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trainer mode unlocked.')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid secret key.')));
    }
    _keyController.clear();
  }

  Future<void> _lockTrainerMode() async {
    await SecureStorageService.setTrainerMode(false);
    setState(() => _isTrainer = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Trainer mode locked.')));
  }

  Future<void> _loadDriveStatus() async {
    setState(() => _isDriveLoading = true);
    final driveService = DriveService();
    final signedIn = await driveService.isSignedIn();
    String? folderId;
    String? email;
    if (signedIn) {
      folderId = await driveService.getFolderId();
      email = driveService.currentUser?.email;
    }
    setState(() {
      _isDriveSignedIn = signedIn;
      _driveFolderId = folderId;
      _driveEmail = email;
      _isDriveLoading = false;
    });
  }

  Future<void> _handleDriveSignIn() async {
    setState(() => _isDriveLoading = true);
    final driveService = DriveService();
    try {
      final success = await driveService.signIn();
      if (success) {
        await _loadDriveStatus();
      } else {
        setState(() => _isDriveLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Drive sign-in failed.')),
        );
      }
    } catch (e) {
      setState(() => _isDriveLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in error: $e')),
      );
    }
  }

  Future<void> _handleDriveSignOut() async {
    setState(() => _isDriveLoading = true);
    await DriveService().signOut();
    await _loadDriveStatus();
  }

  Future<void> _handleSelectDriveFolder() async {
    final controller = TextEditingController();
    final folderId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Google Drive Folder ID'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder ID'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('OK')),
        ],
      ),
    );
    if (folderId != null && folderId.isNotEmpty) {
      await DriveService().setFolderId(folderId);
      await _loadDriveStatus();
    }
  }

  Future<void> _loadApiKey() async {
    final key = await SecureStorageService.read('openai_api_key');
    setState(() {
      if (key != null && key.isNotEmpty) {
        _apiKeyMasked = key.length > 8
            ? key.substring(0, 4) + '...' + key.substring(key.length - 4)
            : '••••';
        _apiKeyController.text = key;
      } else {
        _apiKeyMasked = null;
        _apiKeyController.text = '';
      }
    });
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      await SecureStorageService.delete('openai_api_key');
      setState(() => _apiKeyMasked = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key cleared.')),
      );
      return;
    }
    await SecureStorageService.write('openai_api_key', key);
    setState(() {
      _apiKeyMasked = key.length > 8
          ? key.substring(0, 4) + '...' + key.substring(key.length - 4)
          : '••••';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key saved securely.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('settings')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.get('change_language'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            widget.onLocaleChanged(const Locale('fr')),
                        child: const Text('Français'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () =>
                            widget.onLocaleChanged(const Locale('en')),
                        child: const Text('English'),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      await ScenarioCache.clearCache();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cache cleared.')),
                        );
                      }
                    },
                    child: const Text('Clear Cache'),
                  ),
                  const Divider(height: 32),
                  Text('Trainer Mode',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (_isTrainer) ...[
                    Row(
                      children: [
                        const Icon(Icons.lock_open, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Trainer mode is active'),
                        const Spacer(),
                        TextButton(
                          onPressed: _lockTrainerMode,
                          child: const Text('Lock'),
                        ),
                      ],
                    ),
                  ] else ...[
                    TextField(
                      controller: _keyController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Enter trainer secret key'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _unlockTrainerMode,
                      child: const Text('Unlock Trainer Mode'),
                    ),
                  ],
                  const Divider(height: 32),
                  Text('Google Drive',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (_isDriveLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(),
                    ),
                  if (_isDriveSignedIn) ...[
                    Row(
                      children: [
                        const Icon(Icons.cloud_done, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(_driveEmail ?? 'Signed in'),
                        const Spacer(),
                        TextButton(
                          onPressed: _handleDriveSignOut,
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.folder, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_driveFolderId ?? 'No folder selected'),
                        ),
                        TextButton(
                          onPressed: _handleSelectDriveFolder,
                          child: const Text('Change Folder'),
                        ),
                      ],
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google Drive'),
                      onPressed: _handleDriveSignIn,
                    ),
                  ],
                  const Divider(height: 32),
                  Text('OpenAI API Key',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_apiKeyMasked != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.vpn_key, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('Current: $_apiKeyMasked'),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            _apiKeyController.text = '';
                            setState(() {});
                          },
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ],
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Enter OpenAI API key', hintText: 'sk-...'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveApiKey,
                    child: const Text('Save API Key'),
                  ),
                ],
              ),
            ),
    );
  }
}
