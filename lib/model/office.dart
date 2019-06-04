import 'package:cloud_firestore/cloud_firestore.dart';

class Office {

  final String name;

  final String id;

  Office(DocumentSnapshot snapshot) : 
    this.name = snapshot.data["name"],
    this.id = snapshot.documentID;
}