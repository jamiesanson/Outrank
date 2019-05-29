import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class OnboardingNicknameScreen extends StatelessWidget {

  final DocumentSnapshot officeSnapshot;

  OnboardingNicknameScreen(this.officeSnapshot);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text("Choose a nickname");
  }

}