import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/scenario.dart';
import '../models/scene.dart';
import '../models/problem.dart';
import '../services/openai_service.dart';

class ScenarioEditScreen extends StatefulWidget {
  final Scenario? initialScenario;
  final void Function(Scenario)? onSave;
  const ScenarioEditScreen({Key? key, this.initialScenario, this.onSave})
      : super(key: key);

  @override
  State<ScenarioEditScreen> createState() => _ScenarioEditScreenState();
}

class _ScenarioEditScreenState extends State<ScenarioEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _language = 'fr';
  List<Scene> _scenes = [];
  bool _loadingAI = false;
  bool _previewMode = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialScenario?.title ?? '');
    _descController =
        TextEditingController(text: widget.initialScenario?.description ?? '');
    _language = widget.initialScenario?.language ?? 'fr';
    _scenes = widget.initialScenario?.scenes ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    if (widget.initialScenario == null) {
      // New scenario, any non-empty field or scenes is unsaved
      return _titleController.text.isNotEmpty ||
          _descController.text.isNotEmpty ||
          _scenes.isNotEmpty;
    }
    final initial = widget.initialScenario!;
    if (_titleController.text != initial.title) return true;
    if (_descController.text != (initial.description ?? '')) return true;
    if (_language != initial.language) return true;
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
    if (!_hasUnsavedChanges) return true;
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text('You have unsaved changes. Save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (shouldSave == null) return false; // Cancel
    if (shouldSave) {
      _save();
      return false; // _save will pop
    }
    return true; // Discard
  }

  Future<void> _generateWithAI() async {
    final prompt = await showDialog<String>(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Générer un scénario avec l’IA'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
                hintText: 'Décrivez le sujet ou donnez des instructions...'),
            autofocus: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, ctrl.text),
                child: const Text('Générer')),
          ],
        );
      },
    );
    if (prompt == null || prompt.trim().isEmpty) return;
    setState(() => _loadingAI = true);
    try {
      final ai = OpenAIService();
      final aiPrompt =
          'Génère un scénario de formation au format JSON avec titre, description, scenes (avec titre, description, problèmes avec titre, description, résolution). Langue: $_language. Sujet: $prompt.';
      final result = await ai.generateScenarioWithAI(prompt: aiPrompt);
      if (result != null) {
        final json = Scenario.fromJson(jsonDecode(result));
        setState(() {
          _titleController.text = json.title;
          _descController.text = json.description ?? '';
          _language = json.language;
          _scenes = json.scenes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur IA: $e')));
    } finally {
      setState(() => _loadingAI = false);
    }
  }

  Future<void> _generateSceneWithAI() async {
    final prompt = await showDialog<String>(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Générer une scène avec l’IA'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
                hintText: 'Décrivez la scène ou donnez des instructions...'),
            autofocus: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, ctrl.text),
                child: const Text('Générer')),
          ],
        );
      },
    );
    if (prompt == null || prompt.trim().isEmpty) return;
    setState(() => _loadingAI = true);
    try {
      final ai = OpenAIService();
      final aiPrompt =
          'Génère une scène de formation au format JSON avec titre et description. Langue: $_language. Sujet: $prompt.';
      final result = await ai.generateScenarioWithAI(prompt: aiPrompt);
      if (result != null) {
        final Map<String, dynamic> json = result.contains('{')
            ? jsonDecode(result.substring(result.indexOf('{')))
            : jsonDecode(result);
        final scene = Scene.fromJson(json);
        setState(() {
          _scenes.add(scene);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur IA: $e')));
    } finally {
      setState(() => _loadingAI = false);
    }
  }

  Future<void> _generateProblemsWithAI(int sceneIndex) async {
    final scene = _scenes[sceneIndex];
    setState(() => _loadingAI = true);
    try {
      final ai = OpenAIService();
      final aiPrompt =
          'Pour la scène suivante (titre: "${scene.title}", description: "${scene.description}"), génère une liste de problèmes au format JSON (tableau d’objets avec titre, description, résolution). Langue: $_language.';
      final result = await ai.generateScenarioWithAI(prompt: aiPrompt);
      if (result != null) {
        final List<dynamic> problemsJson = result.contains('[')
            ? jsonDecode(result.substring(result.indexOf('[')))
            : jsonDecode(result);
        setState(() {
          _scenes[sceneIndex] = Scene(
            title: scene.title,
            description: scene.description,
            image: scene.image,
            problems: problemsJson.map((e) => Problem.fromJson(e)).toList(),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur IA: $e')));
    } finally {
      setState(() => _loadingAI = false);
    }
  }

  Future<void> _generateResolutionWithAI(int sceneIdx, int problemIdx) async {
    final problem = _scenes[sceneIdx].problems[problemIdx];
    setState(() => _loadingAI = true);
    try {
      final ai = OpenAIService();
      final aiPrompt =
          'Pour le problème suivant (titre: "${problem.title}", description: "${problem.description}"), génère une résolution détaillée au format texte, adaptée à un contexte de formation. Langue: $_language.';
      final result = await ai.generateScenarioWithAI(prompt: aiPrompt);
      if (result != null) {
        setState(() {
          _scenes[sceneIdx].problems[problemIdx] = Problem(
            title: problem.title,
            description: problem.description,
            resolution: result.trim(),
            image: problem.image,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur IA: $e')));
    } finally {
      setState(() => _loadingAI = false);
    }
  }

  void _addScene() {
    setState(() {
      _scenes.add(Scene(title: '', description: '', problems: []));
    });
  }

  void _deleteScene(int index) {
    setState(() {
      _scenes.removeAt(index);
    });
  }

  void _reorderScene(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final scene = _scenes.removeAt(oldIndex);
      _scenes.insert(newIndex, scene);
    });
  }

  void _addProblem(int sceneIdx) {
    setState(() {
      _scenes[sceneIdx]
          .problems
          .add(Problem(title: '', description: '', resolution: ''));
    });
  }

  void _deleteProblem(int sceneIdx, int problemIdx) {
    setState(() {
      _scenes[sceneIdx].problems.removeAt(problemIdx);
    });
  }

  void _reorderProblem(int sceneIdx, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final problem = _scenes[sceneIdx].problems.removeAt(oldIndex);
      _scenes[sceneIdx].problems.insert(newIndex, problem);
    });
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final scenario = Scenario(
        title: _titleController.text,
        description: _descController.text,
        language: _language,
        scenes: _scenes,
        lastUpdated: DateTime.now(),
      );
      if (widget.onSave != null) {
        widget.onSave!(scenario);
      }
      Navigator.pop(context, scenario);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.initialScenario == null
              ? 'Nouveau Scénario'
              : 'Éditer le Scénario'),
          actions: [
            Row(
              children: [
                Text(_previewMode ? 'Prévisualiser' : 'Édition',
                    style: const TextStyle(fontSize: 14)),
                Switch(
                  value: _previewMode,
                  onChanged: (v) => setState(() => _previewMode = v),
                  activeColor: Colors.blue,
                ),
              ],
            ),
            if (!_previewMode)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _save,
                tooltip: 'Enregistrer',
              ),
          ],
        ),
        body: _loadingAI
            ? const Center(child: CircularProgressIndicator())
            : _previewMode
                ? _buildPreviewMode(context)
                : _buildEditMode(context),
      ),
    );
  }

  Widget _buildPreviewMode(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_titleController.text,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        if (_descController.text.isNotEmpty)
          Text(_descController.text,
              style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        for (int s = 0; s < _scenes.length; s++) ...[
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_scenes[s].title,
                      style: Theme.of(context).textTheme.titleMedium),
                  if (_scenes[s].description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(_scenes[s].description),
                    ),
                  if (_scenes[s].problems.isNotEmpty)
                    ..._scenes[s].problems.map((p) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.title,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                if (p.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 2, bottom: 4),
                                    child: Text(p.description),
                                  ),
                                if (p.resolution.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child:
                                        Text('Résolution :\n${p.resolution}'),
                                  ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEditMode(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Titre du scénario'),
            validator: (v) => v == null || v.isEmpty ? 'Obligatoire' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _language,
            items: const [
              DropdownMenuItem(value: 'fr', child: Text('Français')),
              DropdownMenuItem(value: 'en', child: Text('Anglais')),
            ],
            onChanged: (v) => setState(() => _language = v ?? 'fr'),
            decoration: const InputDecoration(labelText: 'Langue du scénario'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _generateWithAI,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Générer avec l’IA'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _generateSceneWithAI,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une scène avec l’IA'),
          ),
          const SizedBox(height: 24),
          if (_scenes.isNotEmpty)
            Text('Scènes:', style: Theme.of(context).textTheme.titleMedium),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: _reorderScene,
            children: [
              for (int s = 0; s < _scenes.length; s++)
                Card(
                  key: ValueKey('scene_$s'),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _scenes[s].title,
                                decoration: const InputDecoration(
                                    labelText: 'Titre de la scène'),
                                onChanged: (v) =>
                                    setState(() => _scenes[s] = Scene(
                                          title: v,
                                          description: _scenes[s].description,
                                          image: _scenes[s].image,
                                          problems: _scenes[s].problems,
                                        )),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteScene(s),
                            ),
                          ],
                        ),
                        TextFormField(
                          initialValue: _scenes[s].description,
                          decoration: const InputDecoration(
                              labelText: 'Description de la scène'),
                          onChanged: (v) => setState(() => _scenes[s] = Scene(
                                title: _scenes[s].title,
                                description: v,
                                image: _scenes[s].image,
                                problems: _scenes[s].problems,
                              )),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _generateProblemsWithAI(s),
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Générer problèmes IA'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _addProblem(s),
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter un problème'),
                            ),
                          ],
                        ),
                        if (_scenes[s].problems.isNotEmpty)
                          ReorderableListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            onReorder: (oldIdx, newIdx) =>
                                _reorderProblem(s, oldIdx, newIdx),
                            children: [
                              for (int p = 0;
                                  p < _scenes[s].problems.length;
                                  p++)
                                Card(
                                  key: ValueKey('problem_${s}_$p'),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                initialValue: _scenes[s]
                                                    .problems[p]
                                                    .title,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            'Titre du problème'),
                                                onChanged: (v) => setState(() =>
                                                    _scenes[s].problems[p] =
                                                        Problem(
                                                      title: v,
                                                      description: _scenes[s]
                                                          .problems[p]
                                                          .description,
                                                      resolution: _scenes[s]
                                                          .problems[p]
                                                          .resolution,
                                                      image: _scenes[s]
                                                          .problems[p]
                                                          .image,
                                                    )),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _deleteProblem(s, p),
                                            ),
                                          ],
                                        ),
                                        TextFormField(
                                          initialValue: _scenes[s]
                                              .problems[p]
                                              .description,
                                          decoration: const InputDecoration(
                                              labelText:
                                                  'Description du problème'),
                                          onChanged: (v) => setState(() =>
                                              _scenes[s].problems[p] = Problem(
                                                title: _scenes[s]
                                                    .problems[p]
                                                    .title,
                                                description: v,
                                                resolution: _scenes[s]
                                                    .problems[p]
                                                    .resolution,
                                                image: _scenes[s]
                                                    .problems[p]
                                                    .image,
                                              )),
                                        ),
                                        TextFormField(
                                          initialValue:
                                              _scenes[s].problems[p].resolution,
                                          decoration: const InputDecoration(
                                              labelText: 'Résolution'),
                                          onChanged: (v) => setState(() =>
                                              _scenes[s].problems[p] = Problem(
                                                title: _scenes[s]
                                                    .problems[p]
                                                    .title,
                                                description: _scenes[s]
                                                    .problems[p]
                                                    .description,
                                                resolution: v,
                                                image: _scenes[s]
                                                    .problems[p]
                                                    .image,
                                              )),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () =>
                                                _generateResolutionWithAI(s, p),
                                            icon:
                                                const Icon(Icons.auto_awesome),
                                            label: const Text(
                                                'Générer résolution IA'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _addScene,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une scène'),
          ),
        ],
      ),
    );
  }
}
