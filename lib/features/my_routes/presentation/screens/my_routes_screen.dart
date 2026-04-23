import 'package:flutter/material.dart';

class MyRoutesScreen extends StatelessWidget {
  const MyRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Routes')),
      body: const Center(child: Text('History of routes placeholder')),
    );
  }
}
