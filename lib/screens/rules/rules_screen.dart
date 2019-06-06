import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class RulesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RulesState();
  }
}

class RulesState extends State<RulesScreen> {
  String _markdown;

  @override
  void initState() {
    super.initState();
    _downloadMarkdown();
  }

  void _downloadMarkdown() async {
    Directory appDataDir = await getApplicationDocumentsDirectory();
    File rulesFile = File("${appDataDir.path}/rules.md");

    // Check if the file exists first
    if (await rulesFile.exists()) {
      String content = await rulesFile.readAsString();
      setState(() {
        _markdown = content;
      });
    }

    // Update the file
    await FirebaseStorage.instance
        .ref()
        .child("static/rules.md")
        .writeToFile(rulesFile)
        .future;

    String content = await rulesFile.readAsString();

    if (mounted) {
      setState(() {
        _markdown = content;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_markdown == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
          backgroundColor: Colors.white,
          body: Markdown(
            data: _markdown,
          ));
    }
  }
}
