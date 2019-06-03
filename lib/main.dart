import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outrank/screens/intro/onboarding_master_screen.dart';
import 'package:outrank/widgets/empty_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'screens/ranking/ranking_screen.dart';
import 'screens/games/games_screen.dart';
import 'screens/rules/rules_screen.dart';

void main() => runApp(Outrank());

final ThemeData outrankTheme = new ThemeData(
  brightness:     Brightness.light,
  primaryColor:   Color(0xFF3B71DC),
  accentColor:    Color(0xFF3B71DC),
);

class Outrank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outrank',
      theme: outrankTheme,
      home: OutrankHomePage(),
    );
  }
}

class OutrankHomePage extends StatefulWidget {

  @override
  OutrankHomeState createState() => OutrankHomeState();
}

class OutrankHomeState extends State<OutrankHomePage> {

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0: {
        return RankingScreen();
      }
      case 1: {
        return RulesScreen();
      }
      case 2: {
        return GamesScreen();
      }
      default: {
        throw Exception("Unexcected selected index: $_selectedIndex");
      }
    }
  }

  Widget _getOnboardedScreen() {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getOnboardedScreen();
  }
}
