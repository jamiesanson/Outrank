
import 'package:cloud_firestore/cloud_firestore.dart';

class Game {

  final DocumentReference officeRef;

  final DocumentReference op1Ref;

  final DocumentReference op2Ref;

  final DocumentReference op1ResultRef;

  final DocumentReference op2ResultRef;

  Game(DocumentSnapshot snapshot) : 
    this.officeRef = snapshot.data["office"],
    this.op1Ref = snapshot.data["op_1"],
    this.op2Ref = snapshot.data["op_2"],
    this.op1ResultRef = snapshot.data["op_1_result"],
    this.op2ResultRef = snapshot.data["op_1_result"];
}