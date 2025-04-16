import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../models/scene.dart';
import '../utils/app_localizations.dart';
import 'scene_view_screen.dart';
import '../services/secure_storage_service.dart';
import '../services/drive_service.dart';
import '../utils/scenario_cache.dart';
import 'scene_screen.dart';

class ScenarioViewScreen extends StatefulWidget {
  final Scenario scenario;
  const ScenarioViewScreen({Key? key, required this.scenario})
      : super(key: key);

  @override
  State<ScenarioViewScreen> createState() => _ScenarioViewScreenState();
}

class _ScenarioViewScreenState extends State<ScenarioViewScreen> {
  int _currentSceneIndex = 0;
  bool _isTrainer = false;
  List<Scene> _scenes = [];

  @override
  void initState() {
    super.initState();
    _scenes = List<Scene>.from(widget.scenario.scenes);
    _loadTrainerMode();
  }

  Future<void> _loadTrainerMode() async {
    final isTrainer = await SecureStorageService.getTrainerMode();
    setState(() => _isTrainer = isTrainer);
  }

  bool _hasUnsavedChanges() {
    final initial = widget.scenario;
    if (_scenes.length != initial.scenes.length) return true;
    for (int i = 0; i < _scenes.length; i++) {
      if (_scenes[i].title != initial.scenes[i].title ||
          _scenes[i].description != initial.scenes[i].description ||
          _scenes[i].image != initial.scenes[i].image ||
          _scenes[i].problems.length != initial.scenes[i].problems.length) {
        return true;
      }
      for (int j = 0; j < _scenes[i].problems.length; j++) {
        final p1 = _scenes[i].problems[j];
        final p2 = initial.scenes[i].problems[j];
        if (p1.title != p2.title ||
            p1.description != p2.description ||
            p1.resolution != p2.resolution ||
            p1.image != p2.image) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges()) return true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text('You have unsaved changes. Save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    return shouldLeave == true;
  }

  void _saveScenario() async {
    try {
      await DriveService().uploadScenario(
        widget.scenario.copyWith(
          scenes: List<Scene>.from(_scenes),
          lastUpdated: DateTime.now(),
        ),
      );
      setState(() {
        widget.scenario.scenes.clear();
        widget.scenario.scenes.addAll(_scenes);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scenario saved to Drive.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save scenario: $e')),
      );
    }
  }

  void _goToNextScene() {
    setState(() {
      if (_currentSceneIndex < _scenes.length - 1) {
        _currentSceneIndex++;
      }
    });
  }

  Future<void> _addScene() async {
    final newScene = await showDialog<Scene>(
      context: context,
      builder: (context) => SceneEditDialog(),
    );
    if (newScene != null) {
      setState(() {
        _scenes.add(newScene);
        _currentSceneIndex = _scenes.length - 1;
      });
    }
  }

  void _deleteScene(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scene'),
        content: Text('Are you sure you want to delete this scene?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _scenes.removeAt(index);
        if (_currentSceneIndex >= _scenes.length) {
          _currentSceneIndex = _scenes.isEmpty ? 0 : _scenes.length - 1;
        }
      });
    }
  }

  void _reorderScene(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final scene = _scenes.removeAt(oldIndex);
      _scenes.insert(newIndex, scene);
      if (_currentSceneIndex == oldIndex) {
        _currentSceneIndex = newIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isLastScene = _currentSceneIndex == _scenes.length - 1;
    final scenario = widget.scenario;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(scenario.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save',
              onPressed: _saveScenario,
            ),
          ],
        ),
        body: Column(
          children: [
            // Scenario header with image, title, description (view only)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: scenario.image != null && scenario.image!.isNotEmpty
                        ? Image.network(
                            scenario.image!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          )
                        : Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image,
                                size: 40, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (scenario.description != null &&
                            scenario.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              scenario.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Scenes list
            Expanded(
              child: ReorderableListView(
                onReorder: _reorderScene,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  for (int i = 0; i < _scenes.length; i++)
                    Column(
                      key: ValueKey('scene_$i'),
                      children: [
                        InkWell(
                          onTap: () async {
                            int currentIdx = i;
                            while (true) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SceneScreen(
                                    scene: _scenes[currentIdx],
                                    onSceneChanged: (scene) {
                                      setState(() {
                                        _scenes[currentIdx] = scene;
                                      });
                                    },
                                  ),
                                ),
                              );
                              if (result == 'next') {
                                if (currentIdx < _scenes.length - 1) {
                                  currentIdx++;
                                } else {
                                  // No next scene, go back to scene list
                                  break;
                                }
                              } else if (result == 'previous') {
                                if (currentIdx > 0) {
                                  currentIdx--;
                                } else {
                                  // No previous scene, go back to scene list
                                  break;
                                }
                              } else {
                                // User closed or saved, go back to scene list
                                break;
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: i == _currentSceneIndex
                                  ? Colors.blue.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: i == _currentSceneIndex
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                                width: i == _currentSceneIndex ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ReorderableDragStartListener(
                                  index: i,
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.drag_handle,
                                        color: Colors.grey),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _scenes[i].image != null &&
                                          _scenes[i].image!.isNotEmpty
                                      ? Image.network(
                                          _scenes[i].image!,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            width: 64,
                                            height: 64,
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                                Icons.broken_image,
                                                size: 28),
                                          ),
                                        )
                                      : Container(
                                          width: 64,
                                          height: 64,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.image,
                                              size: 28, color: Colors.grey),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _scenes[i].title,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                if (_isTrainer) ...[
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteScene(i),
                                    tooltip: 'Delete Scene',
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (i < _scenes.length - 1) const SizedBox(height: 12),
                      ],
                    ),
                ],
              ),
            ),
            // Navigation buttons and scene content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  if (_isTrainer)
                    ElevatedButton.icon(
                      onPressed: _addScene,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Scene'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: isLastScene
                        ? () => Navigator.pop(context)
                        : _goToNextScene,
                    child: Text(isLastScene
                        ? loc.get('finish_scenario')
                        : loc.get('next_scene')),
                  ),
                ],
              ),
            ),
            if (_scenes.isNotEmpty)
              SizedBox(
                height: 320,
                child: SceneViewScreen(
                  scene: _scenes[_currentSceneIndex],
                  scenarioLanguage: widget.scenario.language,
                  onProblemsChanged: (problems) async {
                    setState(() {
                      _scenes[_currentSceneIndex] = _scenes[_currentSceneIndex]
                          .copyWith(problems: problems);
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// SceneEditDialog widget (inline for now)
class SceneEditDialog extends StatefulWidget {
  final Scene? initialScene;
  const SceneEditDialog({Key? key, this.initialScene}) : super(key: key);

  @override
  State<SceneEditDialog> createState() => _SceneEditDialogState();
}

class _SceneEditDialogState extends State<SceneEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialScene?.title ?? '');
    _descController =
        TextEditingController(text: widget.initialScene?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialScene == null ? 'Add Scene' : 'Edit Scene'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            // TODO: Add image picker if needed
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final scene = Scene(
                title: _titleController.text,
                description: _descController.text,
                image: widget.initialScene?.image,
                problems: widget.initialScene?.problems ?? [],
              );
              Navigator.pop(context, scene);
            }
          },
          child: Text(widget.initialScene == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
