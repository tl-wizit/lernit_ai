import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/app_localizations.dart';
import '../services/drive_service.dart';
import '../models/scenario.dart';
import '../utils/scenario_cache.dart';
import '../services/secure_storage_service.dart';
import '../services/openai_service.dart';
import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:lernit_ai/screens/scenario_view_screen.dart';
import 'package:lernit_ai/screens/scenario_edit_screen.dart';

class ScenarioListScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChanged;
  const ScenarioListScreen({Key? key, required this.onLocaleChanged})
      : super(key: key);

  @override
  State<ScenarioListScreen> createState() => _ScenarioListScreenState();
}

class _ScenarioListScreenState extends State<ScenarioListScreen> {
  List<Scenario> _scenarios = [];
  bool _isLoading = false;
  String? _error;
  bool _fromCache = false;
  bool _isTrainer = false;
  bool _isSignedIn = false;
  String? _driveFolderId;

  @override
  void initState() {
    super.initState();
    _loadTrainerMode();
    _checkDriveStatus();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  Future<void> _loadTrainerMode() async {
    final isTrainer = await SecureStorageService.getTrainerMode();
    setState(() => _isTrainer = isTrainer);
  }

  Future<void> _checkDriveStatus() async {
    final driveService = DriveService();
    final signedIn = await driveService.isSignedIn();
    String? folderId;
    if (signedIn) {
      folderId = await driveService.getFolderId();
    }
    setState(() {
      _isSignedIn = signedIn;
      _driveFolderId = folderId;
    });
    if (signedIn && folderId != null) {
      _loadFromCacheThenDrive();
    }
  }

  Future<void> _loadFromCacheThenDrive() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _fromCache = false;
    });
    // Load from cache first
    final cached = await ScenarioCache.loadScenarios();
    if (cached.isNotEmpty) {
      setState(() {
        _scenarios = cached;
        _fromCache = true;
        _isLoading = false;
      });
    }
    // Then try to refresh from Drive
    await _loadScenarios(refreshCache: true);
  }

  Future<void> _loadScenarios({bool refreshCache = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final driveService = DriveService();
      final signedIn = await driveService.isSignedIn();
      if (!signedIn) {
        setState(() {
          _error = 'Not connected to Google Drive.';
          _isLoading = false;
        });
        return;
      }
      final files = await driveService.listScenarioFiles();
      final scenarios = <Scenario>[];
      for (final file in files) {
        try {
          final data = await driveService.getFileById(file.id!);
          final jsonStr = utf8.decode(data);
          final jsonMap = json.decode(jsonStr);
          scenarios.add(Scenario.fromJson(jsonMap));
        } catch (e) {
          // Skip invalid/corrupt files
        }
      }
      setState(() {
        _scenarios = scenarios;
        _fromCache = false;
        _isLoading = false;
      });
      if (refreshCache) {
        await ScenarioCache.saveScenarios(scenarios);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load scenarios: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _duplicateAndTranslateScenario(Scenario scenario) async {
    final targetLang = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select target language'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'en'),
            child: const Text('English'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'fr'),
            child: const Text('Français'),
          ),
        ],
      ),
    );
    if (targetLang == null || targetLang == scenario.language) return;
    setState(() => _isLoading = true);
    try {
      final ai = OpenAIService();
      final prompt =
          'Translate the following scenario JSON to $targetLang, preserving structure. Only translate text fields.\n\n${jsonEncode(scenario.toJson())}';
      final result = await ai.generateScenarioWithAI(prompt: prompt);
      if (result == null) throw Exception('No AI response');
      final translatedJson = json.decode(result);
      final newScenario = Scenario.fromJson(translatedJson);
      // Open in editor for review
      final edited = await Navigator.push<Scenario>(
        context,
        MaterialPageRoute(
          builder: (context) => ScenarioEditScreen(
            onSave: (s) => Navigator.pop(context, s),
            initialScenario: newScenario,
          ),
        ),
      );
      if (edited != null) {
        await DriveService().uploadScenario(edited);
        await _loadScenarios(refreshCache: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Translated scenario saved.')),
        );
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Translation failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('scenario_list')),
        actions: [
          if (_isSignedIn && _driveFolderId != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadScenarios,
              tooltip: 'Refresh',
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              await _loadTrainerMode();
              _checkDriveStatus();
            },
            tooltip: loc.get('settings'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (!_isSignedIn || _driveFolderId == null)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Google Drive is not connected or no folder is selected.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text('Open Settings'),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                      ),
                    ],
                  ),
                )
              : _error != null
                  ? Center(child: Text(_error!))
                  : _scenarios.isEmpty
                      ? Center(child: Text(loc.get('no_scenarios')))
                      : Column(
                          children: [
                            if (_fromCache)
                              Container(
                                color: Colors.amber.shade100,
                                padding: const EdgeInsets.all(8),
                                child: const Text(
                                    'Affichage du cache local (hors ligne ou contenu non synchronisé).'),
                              ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _scenarios.length,
                                itemBuilder: (context, index) {
                                  final scenario = _scenarios[index];
                                  return ListTile(
                                    title: Text(scenario.title),
                                    subtitle:
                                        Text('Lang: ${scenario.language}'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ScenarioViewScreen(
                                                  scenario: scenario),
                                        ),
                                      );
                                    },
                                    trailing: _isTrainer
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.blue),
                                                tooltip: 'Edit',
                                                onPressed: () async {
                                                  final updatedScenario =
                                                      await Navigator.push<
                                                          Scenario>(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ScenarioEditScreen(
                                                        onSave: (scenario) {
                                                          Navigator.pop(context,
                                                              scenario);
                                                        },
                                                        initialScenario:
                                                            scenario,
                                                      ),
                                                    ),
                                                  );
                                                  if (updatedScenario != null) {
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    try {
                                                      await DriveService()
                                                          .uploadScenario(
                                                              updatedScenario);
                                                      await _loadScenarios(
                                                          refreshCache: true);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Scenario updated.')),
                                                      );
                                                    } catch (e) {
                                                      setState(() =>
                                                          _isLoading = false);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Failed to update scenario: $e')),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                tooltip: 'Delete',
                                                onPressed: () async {
                                                  final confirm =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          'Delete Scenario'),
                                                      content: Text(
                                                          'Are you sure you want to delete "${scenario.title}"? This cannot be undone.'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  false),
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  true),
                                                          child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirm == true) {
                                                    setState(() =>
                                                        _isLoading = true);
                                                    try {
                                                      // Find the Drive file by name
                                                      final driveService =
                                                          DriveService();
                                                      final files =
                                                          await driveService
                                                              .listScenarioFiles();
                                                      final file =
                                                          files.firstWhere(
                                                        (f) =>
                                                            f.name?.startsWith(
                                                                scenario.title
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            r'[^a-zA-Z0-9_-]'),
                                                                        '_')) ??
                                                            false,
                                                        orElse: () =>
                                                            throw Exception(
                                                                'File not found on Drive'),
                                                      );
                                                      await driveService
                                                          .deleteFileById(
                                                              file.id!);
                                                      await _loadScenarios(
                                                          refreshCache: true);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Scenario deleted.')),
                                                      );
                                                    } catch (e) {
                                                      setState(() =>
                                                          _isLoading = false);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Failed to delete scenario: $e')),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.green),
                                                tooltip:
                                                    'Duplicate & Translate',
                                                onPressed: () =>
                                                    _duplicateAndTranslateScenario(
                                                        scenario),
                                              ),
                                            ],
                                          )
                                        : null,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
      floatingActionButton: _isTrainer
          ? FloatingActionButton(
              onPressed: () async {
                final newScenario = await Navigator.push<Scenario>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScenarioEditScreen(),
                  ),
                );
                if (newScenario != null) {
                  final loc = AppLocalizations.of(context)!;
                  print('Showing saving dialog...');
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => AlertDialog(
                      content: Row(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 20),
                          Expanded(child: Text(loc.get('saving_scenario'))),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                  try {
                    await DriveService().uploadScenario(newScenario);
                    await _loadScenarios(refreshCache: true);
                  } catch (e) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save scenario: $e')),
                    );
                  } finally {
                    print('Attempting to dismiss dialog...');
                    if (mounted) {
                      print('Widget is mounted, dismissing dialog...');
                      Navigator.of(context, rootNavigator: true).pop();
                      print('Dialog dismissed.');
                    } else {
                      print('Widget is NOT mounted, cannot dismiss dialog.');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(loc.get('saving_scenario') + ' OK')),
                    );
                  }
                }
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Scenario',
            )
          : null,
    );
  }
}
