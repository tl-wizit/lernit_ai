import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onDriveConnect;

  const OnboardingScreen({Key? key, required this.onDriveConnect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenue'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenue dans l\'application de formation par scénarios!\n\nPour commencer, connectez votre Google Drive afin de stocker et charger vos scénarios.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud),
              label: const Text('Connecter Google Drive'),
              onPressed: onDriveConnect,
            ),
          ],
        ),
      ),
    );
  }
}
