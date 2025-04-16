import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../models/scene.dart';
import '../utils/app_localizations.dart';
import 'scene_view_screen.dart';
import '../services/secure_storage_service.dart';
import '../services/drive_service.dart';
import '../utils/scenario_cache.dart';

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

  Future<void> _editScene(int index) async {
    final updatedScene = await showDialog<Scene>(
      context: context,
      builder: (context) => SceneEditDialog(initialScene: _scenes[index]),
    );
    if (updatedScene != null) {
      setState(() {
        _scenes[index] = updatedScene;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenario.title),
      ),
      body: _isTrainer
          ? Column(
              children: [
                Expanded(
                  child: ReorderableListView(
                    onReorder: _reorderScene,
                    children: [
                      for (int i = 0; i < _scenes.length; i++)
                        ListTile(
                          key: ValueKey('scene_$i'),
                          title: Text(_scenes[i].title),
                          subtitle: Text(_scenes[i].description),
                          leading: Text('Scene ${i + 1}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editScene(i),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteScene(i),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() => _currentSceneIndex = i);
                          },
                          selected: i == _currentSceneIndex,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
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
                  Expanded(
                    child: SceneViewScreen(
                      scene: _scenes[_currentSceneIndex],
                      scenarioLanguage: widget.scenario.language,
                      onProblemsChanged: (problems) async {
                        setState(() {
                          _scenes[_currentSceneIndex] =
                              _scenes[_currentSceneIndex]
                                  .copyWith(problems: problems);
                        });
                      },
                    ),
                  ),
              ],
            )
          : SceneViewScreen(
              scene: _scenes[_currentSceneIndex],
              scenarioLanguage: widget.scenario.language,
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
