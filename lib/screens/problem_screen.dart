import 'package:flutter/material.dart';
import '../models/problem.dart';
import '../services/openai_service.dart';

class ProblemScreen extends StatefulWidget {
  final Problem problem;
  final void Function(Problem updatedProblem)? onProblemChanged;
  const ProblemScreen({Key? key, required this.problem, this.onProblemChanged})
      : super(key: key);

  @override
  State<ProblemScreen> createState() => _ProblemScreenState();
}

class _ProblemScreenState extends State<ProblemScreen> {
  late Problem _problem;
  bool _loadingAI = false;

  @override
  void initState() {
    super.initState();
    _problem = widget.problem;
  }

  // TODO: Add image editing and AI generation for resolution

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Problem')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: _problem.title,
              decoration: const InputDecoration(labelText: 'Problem Title'),
              onChanged: (v) {
                setState(() => _problem = _problem.copyWith(title: v));
                widget.onProblemChanged?.call(_problem);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _problem.description,
              decoration:
                  const InputDecoration(labelText: 'Problem Description'),
              onChanged: (v) {
                setState(() => _problem = _problem.copyWith(description: v));
                widget.onProblemChanged?.call(_problem);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _problem.resolution,
              decoration: const InputDecoration(labelText: 'Resolution'),
              onChanged: (v) {
                setState(() => _problem = _problem.copyWith(resolution: v));
                widget.onProblemChanged?.call(_problem);
              },
            ),
            // Problem image
            if (_problem.image != null && _problem.image!.isNotEmpty)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _problem.image!,
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
            // TODO: Add image editing and AI generation button
          ],
        ),
      ),
    );
  }
}
