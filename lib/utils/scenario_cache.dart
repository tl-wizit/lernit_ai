import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/scenario.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ScenarioCache {
  static const _cacheFolder = 'scenarios_cache';

  static Future<Directory> _getCacheDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/$_cacheFolder');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  static Future<void> saveScenarios(List<Scenario> scenarios) async {
    if (kIsWeb) return;
    final dir = await _getCacheDir();
    for (final scenario in scenarios) {
      final file = File('${dir.path}/${_safeFileName(scenario.title)}.json');
      await file.writeAsString(json.encode(scenario.toJson()));
    }
  }

  static Future<List<Scenario>> loadScenarios() async {
    if (kIsWeb) return [];
    final dir = await _getCacheDir();
    if (!await dir.exists()) return [];
    final files =
        dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json'));
    final scenarios = <Scenario>[];
    for (final file in files) {
      try {
        final jsonStr = await file.readAsString();
        final jsonMap = json.decode(jsonStr);
        scenarios.add(Scenario.fromJson(jsonMap));
      } catch (_) {}
    }
    return scenarios;
  }

  static Future<void> clearCache() async {
    if (kIsWeb) return;
    final dir = await _getCacheDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  static String _safeFileName(String title) {
    return title.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}
