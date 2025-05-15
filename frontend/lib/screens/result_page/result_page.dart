// lib/pages/flower_result_page.dart
import 'package:flutter/material.dart';
import 'dart:io';

class ResultPage extends StatelessWidget {
  final String imagePath;
  final String name;
  final List<String> commonNames;

  const ResultPage({
    required this.imagePath,
    required this.name,
    required this.commonNames,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.file(File(imagePath), height: 200, fit: BoxFit.cover),
              const SizedBox(height: 16),
              Text("名前", style: Theme.of(context).textTheme.titleMedium),
              Text(
                name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(" 名前", style: Theme.of(context).textTheme.titleMedium),
              Text(
                commonNames.join(', '),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("トップにもどる"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
