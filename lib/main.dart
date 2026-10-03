import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Bank',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Digital Bank'),
        ),
        body: const Center(
          child: Text('Digital Bank'),
        ),
      ),
    );
  }
}