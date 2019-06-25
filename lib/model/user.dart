
import 'package:cloud_firestore/cloud_firestore.dart';

class User {

  final String name;

  final int gameCount;

  User(DocumentSnapshot snapshot) : 
    this.name = snapshot.data["name"],
    this.gameCount = snapshot.data["gameCount"];
}