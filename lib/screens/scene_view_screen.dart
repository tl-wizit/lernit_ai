import 'package:flutter/material.dart';
import '../models/scene.dart';
import 'problem_view_screen.dart';
import '../models/problem.dart';

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
  late List<Problem> _problems;

  @override
  void initState() {
    super.initState();
    _problems = List<Problem>.from(widget.scene.problems);
  }

  @override
  Widget build(BuildContext context) {
    // Only show read-only view: title, description, image, and problems as cards
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scene title
          Text(
            widget.scene.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (widget.scene.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.scene.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (widget.scene.image != null && widget.scene.image!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Image.network(
              widget.scene.image!,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
            ),
          ],
          const SizedBox(height: 20),
          Text('Problèmes:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._problems.map((problem) => Card(
                child: ListTile(
                  title: Text(problem.title),
                  subtitle: problem.description.isNotEmpty
                      ? Text(problem.description)
                      : null,
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
              )),
        ],
      ),
    );
  }
}
