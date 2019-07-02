import 'package:flutter/material.dart';
import 'package:outrank/model/game.dart';
import 'package:outrank/widgets/empty_app_bar.dart';

class MatchScreen extends StatelessWidget {

  final Game _game;
  
  MatchScreen(this._game);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmptyAppBar(),
      body: Center(
        child: Text("Waiting on a player"),),
    );
  }

}