import 'package:flutter/material.dart';
import '../models/scene.dart';
import '../models/problem.dart';
import 'problem_screen.dart';
import '../services/openai_service.dart';

class SceneScreen extends StatefulWidget {
  final Scene scene;
  final void Function(Scene updatedScene)? onSceneChanged;
  const SceneScreen({Key? key, required this.scene, this.onSceneChanged})
      : super(key: key);

  @override
  State<SceneScreen> createState() => _SceneScreenState();
}

class _SceneScreenState extends State<SceneScreen> {
  late Scene _scene;
  bool _loadingAI = false;

  @override
  void initState() {
    super.initState();
    _scene = widget.scene;
  }

  void _editProblem(int idx) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProblemScreen(
          problem: _scene.problems[idx],
          onProblemChanged: (p) {
            setState(() {
              _scene.problems[idx] = p;
            });
            widget.onSceneChanged?.call(_scene);
          },
        ),
      ),
    );
    if (updated != null) {
      setState(() {
        _scene.problems[idx] = updated;
      });
      widget.onSceneChanged?.call(_scene);
    }
  }

  void _addProblem() {
    setState(() {
      _scene.problems.add(Problem(title: '', description: '', resolution: ''));
    });
    widget.onSceneChanged?.call(_scene);
  }

  void _deleteProblem(int idx) {
    setState(() {
      _scene.problems.removeAt(idx);
    });
    widget.onSceneChanged?.call(_scene);
  }

  void _reorderProblem(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final p = _scene.problems.removeAt(oldIndex);
      _scene.problems.insert(newIndex, p);
    });
    widget.onSceneChanged?.call(_scene);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scene')), // You can add edit controls here
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scene image
            if (_scene.image != null && _scene.image!.isNotEmpty)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _scene.image!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {/* TODO: implement image picker */},
                    icon: const Icon(Icons.image),
                    label: const Text('Change Image'),
                  ),
                ],
              )
            else
              TextButton.icon(
                onPressed: () {/* TODO: implement image picker */},
                icon: const Icon(Icons.image),
                label: const Text('Add Image'),
              ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _scene.title,
              decoration: const InputDecoration(labelText: 'Scene Title'),
              onChanged: (v) {
                setState(() => _scene = _scene.copyWith(title: v));
                widget.onSceneChanged?.call(_scene);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _scene.description,
              decoration: const InputDecoration(labelText: 'Scene Description'),
              onChanged: (v) {
                setState(() => _scene = _scene.copyWith(description: v));
                widget.onSceneChanged?.call(_scene);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addProblem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Problem'),
                ),
                // TODO: Add AI generation buttons
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableListView(
                onReorder: _reorderProblem,
                children: [
                  for (int i = 0; i < _scene.problems.length; i++)
                    ListTile(
                      key: ValueKey('problem_$i'),
                      title: Text(_scene.problems[i].title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editProblem(i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProblem(i),
                          ),
                        ],
                      ),
                      onTap: () => _editProblem(i),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, 'previous');
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, 'next');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
