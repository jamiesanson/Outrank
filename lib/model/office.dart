import 'package:cloud_firestore/cloud_firestore.dart';

class Office {

  final String name;

  Office(DocumentSnapshot snapshot) : 
    this.name = snapshot.data["name"];
}