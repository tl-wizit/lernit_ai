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
    // Example version, replace with your actual version logic if needed
    const appVersion = '7.0.0 (1)';
    final accentColor = Colors.red.shade700;
    return Scaffold(
      backgroundColor: Colors.white, // Set main page body to white
      appBar: AppBar(
        backgroundColor: accentColor,
        elevation: 0,
        title: const Text('Lernit – scénarios',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadScenarios,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              await _loadTrainerMode();
              await _checkDriveStatus(); // Ensure folderId and scenarios are refreshed after settings
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
                        style: TextStyle(color: Colors.black54),
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
                  ? Center(
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.white)))
                  : _scenarios.isEmpty
                      ? Center(
                          child: Text(loc.get('no_scenarios'),
                              style: const TextStyle(color: Colors.white)))
                      : Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 64),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _scenarios.length,
                                itemBuilder: (context, index) {
                                  final scenario = _scenarios[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    elevation: 4,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (scenario.image != null &&
                                              scenario.image!.isNotEmpty)
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      top: Radius.circular(16)),
                                              child: Image.network(
                                                scenario.image!,
                                                height: 140,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) =>
                                                    Container(
                                                  height: 140,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                      Icons.broken_image,
                                                      size: 48),
                                                ),
                                              ),
                                            )
                                          else
                                            Container(
                                              height: 140,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: const BorderRadius
                                                    .vertical(
                                                    top: Radius.circular(16)),
                                              ),
                                              child: const Icon(Icons.image,
                                                  size: 48, color: Colors.grey),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Text(
                                              scenario.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Version label
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('v$appVersion',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87)),
                              ),
                            ),
                          ],
                        ),
      floatingActionButton: _isTrainer
          ? FloatingActionButton(
              backgroundColor: accentColor,
              onPressed: () async {
                final newScenario = await Navigator.push<Scenario>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScenarioEditScreen(),
                  ),
                );
                if (newScenario != null) {
                  final loc = AppLocalizations.of(context)!;
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
                    if (mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
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
