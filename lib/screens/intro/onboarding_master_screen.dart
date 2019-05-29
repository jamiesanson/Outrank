import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:outrank/screens/intro/onboarding_nickname_screen.dart';
import 'package:outrank/screens/intro/onboarding_office_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OnboardingState();
  }
}

class _OnboardingState extends State {
  DocumentSnapshot _selectedOffice;

  PageController _controller;

  @override
  void initState() {
    super.initState();
    this._controller = PageController();
  }

  Future<bool> _onWillPop() async {
    if (_controller.page == 0.0) return true;

    _controller.previousPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.ease
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: PageView.builder(
            controller: _controller,
            itemBuilder: (context, position) {
              switch (position) {
                case 0:
                  {
                    return OnboardingOfficeScreen((DocumentSnapshot doc) {
                      setState(() {
                        _selectedOffice = doc;
                        _controller.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      });
                    });
                  }
                case 1:
                  {
                    return OnboardingNicknameScreen(_selectedOffice);
                  }
              }
            },
            itemCount: 2,
            physics: NeverScrollableScrollPhysics(),
          ),
        ));
  }
}
