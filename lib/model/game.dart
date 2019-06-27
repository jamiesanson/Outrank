
import 'package:cloud_firestore/cloud_firestore.dart';

class Game {

  final DocumentReference officeRef;

  final DocumentReference op1Ref;

  final String op1Name;

  final DocumentReference op2Ref;

  final DocumentReference op1ResultRef;

  final DocumentReference op2ResultRef;

  GameState get state => _processState();

  GameState _processState() {
    // If there's no office or no opponents, let the game be joinable
    if (officeRef == null || (op1Ref == null && op2Ref == null)) {
      return GameState.empty;
    }

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

  static Game empty() {
    return Game._();
  }

  Game._(): 
    this.officeRef = null,
    this.op1Ref = null,
    this.op1Name = null,
    this.op2Ref = null,
    this.op1ResultRef = null,
    this.op2ResultRef = null;

  Game(DocumentSnapshot snapshot) : 
    this.officeRef = snapshot.data["office"],
    this.op1Ref = snapshot.data["op_1"],
    this.op1Name = snapshot.data["op_1_name"],
    this.op2Ref = snapshot.data["op_2"],
    this.op1ResultRef = snapshot.data["op_1_result"],
    this.op2ResultRef = snapshot.data["op_1_result"];
}

enum GameState {
   unknown, 
   empty,
   waiting_for_opponent, 
   in_progress, 
   waiting_on_result 
}