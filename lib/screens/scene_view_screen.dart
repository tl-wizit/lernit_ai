import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/scene.dart';
import 'problem_view_screen.dart';
import '../widgets/tts_controls.dart';
import '../services/secure_storage_service.dart';
import '../models/problem.dart';
import '../services/drive_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SceneViewScreen extends StatefulWidget {
  final Scene scene;
  final String scenarioLanguage;
  final void Function(List<Problem>)? onProblemsChanged;
  const SceneViewScreen(
      {Key? key,
      required this.scene,
      required this.scenarioLanguage,
      this.onProblemsChanged})
      : super(key: key);

  @override
  State<SceneViewScreen> createState() => _SceneViewScreenState();
}

class _SceneViewScreenState extends State<SceneViewScreen> {
  bool _isTrainer = false;
  late List<Problem> _problems;
  File? _localSceneImage;
  Uint8List? _sceneImageBytes; // For web image preview
  final ImagePicker _picker = ImagePicker();
  final Map<int, File?> _localProblemImages = {};
  final Map<int, Uint8List?> _problemImageBytes =
      {}; // For web problem image preview

  @override
  void initState() {
    super.initState();
    _problems = List<Problem>.from(widget.scene.problems);
    _loadTrainerMode();
    _loadSceneImage();
  }

  Future<void> _loadTrainerMode() async {
    final isTrainer = await SecureStorageService.getTrainerMode();
    setState(() => _isTrainer = isTrainer);
  }

  Future<void> _loadSceneImage() async {
    if (widget.scene.image == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final scenarioMediaFolder =
        widget.scene.title.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_') +
            '_media';
    final localPath = '${dir.path}/$scenarioMediaFolder/${widget.scene.image}';
    final localFile = File(localPath);
    if (await localFile.exists()) {
      setState(() {
        _localSceneImage = localFile;
      });
    } else {
      // Download from Drive
      try {
        final bytes = await DriveService().downloadSceneImage(
          scenarioTitle: widget.scene.title,
          imageName: widget.scene.image!,
        );
        await localFile.parent.create(recursive: true);
        if (bytes != null) {
          await localFile.writeAsBytes(bytes);
          setState(() {
            _localSceneImage = localFile;
          });
        } else {
          // Optionally handle null bytes (e.g., show error)
        }
      } catch (e) {
        // Optionally show error or fallback
      }
    }
  }

  Future<void> _addProblem() async {
    final newProblem = await showDialog<Problem>(
      context: context,
      builder: (context) => ProblemEditDialog(),
    );
    if (newProblem != null) {
      setState(() {
        _problems.add(newProblem);
      });
      widget.onProblemsChanged?.call(_problems);
    }
  }

  void _deleteProblem(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Problem'),
        content: const Text('Are you sure you want to delete this problem?'),
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
        _problems.removeAt(index);
      });
      widget.onProblemsChanged?.call(_problems);
    }
  }

  void _reorderProblem(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final problem = _problems.removeAt(oldIndex);
      _problems.insert(newIndex, problem);
    });
    widget.onProblemsChanged?.call(_problems);
  }

  Future<void> _pickSceneImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _sceneImageBytes = bytes;
        });
        try {
          final imageName = DateTime.now().millisecondsSinceEpoch.toString() +
              '_' +
              picked.name;
          final uploadedName = await DriveService().uploadSceneImage(
            scenarioTitle: widget.scene.title,
            imageBytes: bytes,
            imageName: imageName,
          );
          setState(() {
            widget.scene.image = uploadedName;
          });
          widget.onProblemsChanged?.call(_problems);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded and saved.')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
          }
        }
      } else {
        setState(() {
          _localSceneImage = File(picked.path);
        });
        try {
          final imageName = DateTime.now().millisecondsSinceEpoch.toString() +
              '_' +
              picked.name;
          final uploadedName = await DriveService().uploadSceneImage(
            scenarioTitle: widget.scene.title,
            imageFile: _localSceneImage!,
            imageName: imageName,
          );
          setState(() {
            widget.scene.image = uploadedName;
          });
          widget.onProblemsChanged?.call(_problems);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded and saved.')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
          }
        }
      }
    }
  }

  Future<void> _pickProblemImage(int problemIndex) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _problemImageBytes[problemIndex] = bytes;
        });
        try {
          final imageName = DateTime.now().millisecondsSinceEpoch.toString() +
              '_' +
              picked.name;
          final uploadedName = await DriveService().uploadSceneImage(
            scenarioTitle: widget.scene.title,
            imageBytes: bytes,
            imageName: imageName,
          );
          setState(() {
            _problems[problemIndex] =
                _problems[problemIndex].copyWith(image: uploadedName);
          });
          widget.onProblemsChanged?.call(_problems);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Problem image uploaded and saved.')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
          }
        }
      } else {
        setState(() {
          _localProblemImages[problemIndex] = File(picked.path);
        });
        try {
          final imageName = DateTime.now().millisecondsSinceEpoch.toString() +
              '_' +
              picked.name;
          final uploadedName = await DriveService().uploadSceneImage(
            scenarioTitle: widget.scene.title,
            imageFile: _localProblemImages[problemIndex]!,
            imageName: imageName,
          );
          setState(() {
            _problems[problemIndex] =
                _problems[problemIndex].copyWith(image: uploadedName);
          });
          widget.onProblemsChanged?.call(_problems);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Problem image uploaded and saved.')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isTrainer
              ? TextField(
                  controller: TextEditingController(text: widget.scene.title),
                  decoration: InputDecoration(
                    labelText: 'Scene Title',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.yellow.shade50,
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty &&
                        value != widget.scene.title) {
                      widget.onProblemsChanged?.call(_problems);
                      setState(() {
                        widget.scene.title = value;
                      });
                    }
                  },
                )
              : TTSControls(
                  text: widget.scene.title,
                  language: widget.scenarioLanguage,
                  highlightStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(backgroundColor: Colors.yellow),
                  normalStyle: Theme.of(context).textTheme.titleLarge,
                ),
          if (_isTrainer)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                controller:
                    TextEditingController(text: widget.scene.description),
                decoration: InputDecoration(
                  labelText: 'Scene Description',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.yellow.shade50,
                ),
                maxLines: null,
                onSubmitted: (value) {
                  if (value.trim() != widget.scene.description) {
                    widget.onProblemsChanged?.call(_problems);
                    setState(() {
                      widget.scene.description = value;
                    });
                  }
                },
              ),
            )
          else if (widget.scene.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            TTSControls(
              text: widget.scene.description,
              language: widget.scenarioLanguage,
            ),
          ],
          if (widget.scene.image != null ||
              _localSceneImage != null ||
              _sceneImageBytes != null) ...[
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                if (kIsWeb && _sceneImageBytes != null) {
                  return Image.memory(_sceneImageBytes!, height: 180);
                } else if (_localSceneImage != null) {
                  if (identical(0, 0.0)) {
                    return Image.network(widget.scene.image ?? '',
                        height: 180,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.broken_image));
                  } else {
                    return Image.file(_localSceneImage!, height: 180);
                  }
                } else if (widget.scene.image != null) {
                  return Image.network(widget.scene.image!,
                      height: 180,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.broken_image));
                } else {
                  return const SizedBox();
                }
              },
            ),
            if (_isTrainer)
              TextButton.icon(
                onPressed: _pickSceneImage,
                icon: const Icon(Icons.image),
                label: const Text('Change Image'),
              ),
          ] else if (_isTrainer) ...[
            TextButton.icon(
              onPressed: _pickSceneImage,
              icon: const Icon(Icons.image),
              label: const Text('Add Image'),
            ),
          ],
          const SizedBox(height: 20),
          Text('Problèmes:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_isTrainer)
            Column(
              children: [
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: _reorderProblem,
                  children: [
                    for (int i = 0; i < _problems.length; i++)
                      Card(
                        key: ValueKey('problem_$i'),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: TextEditingController(
                                    text: _problems[i].title),
                                decoration: InputDecoration(
                                  labelText: 'Problem Title',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.yellow.shade50,
                                ),
                                style: Theme.of(context).textTheme.titleMedium,
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty &&
                                      value != _problems[i].title) {
                                    setState(() {
                                      _problems[i] =
                                          _problems[i].copyWith(title: value);
                                    });
                                    widget.onProblemsChanged?.call(_problems);
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: TextEditingController(
                                    text: _problems[i].description),
                                decoration: InputDecoration(
                                  labelText: 'Problem Description',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.yellow.shade50,
                                ),
                                maxLines: null,
                                onSubmitted: (value) {
                                  if (value != _problems[i].description) {
                                    setState(() {
                                      _problems[i] = _problems[i]
                                          .copyWith(description: value);
                                    });
                                    widget.onProblemsChanged?.call(_problems);
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: TextEditingController(
                                    text: _problems[i].resolution),
                                decoration: InputDecoration(
                                  labelText: 'Resolution',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.yellow.shade50,
                                ),
                                maxLines: null,
                                onSubmitted: (value) {
                                  if (value != _problems[i].resolution) {
                                    setState(() {
                                      _problems[i] = _problems[i]
                                          .copyWith(resolution: value);
                                    });
                                    widget.onProblemsChanged?.call(_problems);
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              if (_problems[i].image != null ||
                                  _localProblemImages[i] != null ||
                                  _problemImageBytes[i] != null) ...[
                                Builder(
                                  builder: (context) {
                                    if (kIsWeb &&
                                        _problemImageBytes[i] != null) {
                                      return Image.memory(
                                          _problemImageBytes[i]!,
                                          height: 120);
                                    } else if (_localProblemImages[i] != null) {
                                      if (identical(0, 0.0)) {
                                        return Image.network(
                                            _problems[i].image ?? '',
                                            height: 120,
                                            errorBuilder: (c, e, s) =>
                                                const Icon(Icons.broken_image));
                                      } else {
                                        return Image.file(
                                            _localProblemImages[i]!,
                                            height: 120);
                                      }
                                    } else if (_problems[i].image != null) {
                                      return Image.network(_problems[i].image!,
                                          height: 120,
                                          errorBuilder: (c, e, s) =>
                                              const Icon(Icons.broken_image));
                                    } else {
                                      return const SizedBox();
                                    }
                                  },
                                ),
                                TextButton.icon(
                                  onPressed: () => _pickProblemImage(i),
                                  icon: const Icon(Icons.image),
                                  label: const Text('Change Image'),
                                ),
                              ] else ...[
                                TextButton.icon(
                                  onPressed: () => _pickProblemImage(i),
                                  icon: const Icon(Icons.image),
                                  label: const Text('Add Image'),
                                ),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteProblem(i),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _addProblem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Problem'),
                ),
              ],
            )
          else
            ..._problems.map((problem) {
              return Card(
                child: ListTile(
                  title: TTSControls(
                    text: problem.title,
                    language: widget.scenarioLanguage,
                    highlightStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(backgroundColor: Colors.yellow),
                    normalStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: TTSControls(
                    text: problem.description,
                    language: widget.scenarioLanguage,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProblemViewScreen(
                          problem: problem,
                          scenarioLanguage: widget.scenarioLanguage,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

class ProblemEditDialog extends StatefulWidget {
  final Problem? initialProblem;
  const ProblemEditDialog({Key? key, this.initialProblem}) : super(key: key);

  @override
  State<ProblemEditDialog> createState() => _ProblemEditDialogState();
}

class _ProblemEditDialogState extends State<ProblemEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _resolutionController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialProblem?.title ?? '');
    _descController =
        TextEditingController(text: widget.initialProblem?.description ?? '');
    _resolutionController =
        TextEditingController(text: widget.initialProblem?.resolution ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.initialProblem == null ? 'Add Problem' : 'Edit Problem'),
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
            TextFormField(
              controller: _resolutionController,
              decoration: const InputDecoration(labelText: 'Resolution'),
            ),
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
              final problem = Problem(
                title: _titleController.text,
                description: _descController.text,
                resolution: _resolutionController.text,
                image: widget.initialProblem?.image,
              );
              Navigator.pop(context, problem);
            }
          },
          child: Text(widget.initialProblem == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
