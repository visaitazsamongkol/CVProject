import 'package:flutter/material.dart';

import "dart:async";
import "dart:io";
import "package:flutter/cupertino.dart";
import 'package:image_picker/image_picker.dart';
import './home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Flutter Demo",
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: Home());
  }
}
