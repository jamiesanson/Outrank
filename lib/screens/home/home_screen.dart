import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outrank/screens/games/games_screen.dart';
import 'package:outrank/screens/ranking/bloc/ranking_bloc.dart';
import 'package:outrank/screens/ranking/ranking_screen.dart';
import 'package:outrank/screens/rules/rules_screen.dart';
import 'package:outrank/widgets/empty_app_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _rankingScreen = BlocProvider(
      builder: (BuildContext context) =>
          RankingBloc(ImmutableProvider.of(context)),
      child: RankingScreen());

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        {
          return _rankingScreen;
        }
      case 1:
        {
          return RulesScreen();
        }
      case 2:
        {
          return GamesScreen();
        }
      default:
        {
          throw Exception("Unexcected selected index: $_selectedIndex");
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      appBar: EmptyAppBar(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.score),
            title: Text('Rankings'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            title: Text('Trade Me Rules'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            title: Text('My games'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).accentColor,
      ),
    );
  }
}