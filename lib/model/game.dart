
import 'package:cloud_firestore/cloud_firestore.dart';

class Game {

  final DocumentReference officeRef;

  final DocumentReference op1Ref;

  final DocumentReference op2Ref;

  final DocumentReference op1ResultRef;

  final DocumentReference op2ResultRef;

  GameState get state => _processState();

  GameState _processState() {
    if (op1Ref != null && op2Ref == null) {
      return GameState.waiting_for_opponent;
    }

    if (op1Ref != null && op2Ref != null && op1ResultRef == null && op2ResultRef == null) {
      return GameState.in_progress;
    }

    if ((op1ResultRef != null) != (op2ResultRef != null)) {
      return GameState.waiting_on_result;
    }

    return GameState.unknown;
  }

  Game(DocumentSnapshot snapshot) : 
    this.officeRef = snapshot.data["office"],
    this.op1Ref = snapshot.data["op_1"],
    this.op2Ref = snapshot.data["op_2"],
    this.op1ResultRef = snapshot.data["op_1_result"],
    this.op2ResultRef = snapshot.data["op_1_result"];
}

enum GameState {
   unknown, 
   waiting_for_opponent, 
   in_progress, 
   waiting_on_result 
}