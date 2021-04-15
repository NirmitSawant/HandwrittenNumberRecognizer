import 'package:flutter/material.dart';
import 'package:handwritten_number_recognizer/recognizer_screen.dart';

void main() => runApp(HandwrittenNumberRecognizerApp());

class HandwrittenNumberRecognizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Recognizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecognizerScreen(
        title: 'Number recognizer',
      ),
    );
  }
}
