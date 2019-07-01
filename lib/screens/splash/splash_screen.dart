import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:outrank/main.dart';
import 'package:outrank/widgets/empty_app_bar.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  checkLoggedInState() async {
   bool loggedIn = (await FirebaseAuth.instance.currentUser()) != null;

    if (loggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  initState() {
    super.initState();
    Timer(Duration(milliseconds: 500), () {
      checkLoggedInState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: EmptyAppBar(),
        backgroundColor: AppStateContainer.of(context).theme.primaryColor,
        body: Center(
          child: CircularProgressIndicator(),
        ));
  }
}
