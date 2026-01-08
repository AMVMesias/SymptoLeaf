import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// SymptoLeaf - Plant Disease Detection App
/// Initial version with basic UI structure
/// Created: January 8, 2026
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SymptoLeaf',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('SymptoLeaf - Coming Soon'),
        ),
      ),
    );
  }
}
