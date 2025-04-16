import 'package:flutter/material.dart';
import '../models/problem.dart';
import '../utils/app_localizations.dart';
import '../widgets/tts_controls.dart';

class ProblemViewScreen extends StatelessWidget {
  final Problem problem;
  final String scenarioLanguage;
  const ProblemViewScreen(
      {Key? key, required this.problem, required this.scenarioLanguage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(problem.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TTSControls(
              text: problem.title,
              language: scenarioLanguage,
              highlightStyle: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(backgroundColor: Colors.yellow),
              normalStyle: Theme.of(context).textTheme.titleMedium,
            ),
            if (problem.description.isNotEmpty) ...[
              TTSControls(
                text: problem.description,
                language: scenarioLanguage,
              ),
              const SizedBox(height: 16),
            ],
            if (problem.image != null) ...[
              Image.network(
                  problem.image!), // TODO: handle local/cache/Drive images
              const SizedBox(height: 16),
            ],
            Text('Résolution:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TTSControls(
              text: problem.resolution,
              language: scenarioLanguage,
            ),
            Text(problem.resolution),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.get('return_to_scene')),
        ),
      ),
    );
  }
}
