
import 'package:cloud_firestore/cloud_firestore.dart';

class Game {

  final String id;

  final DocumentReference officeRef;

  final DocumentReference op1Ref;
  final String op1Name;

  final DocumentReference op2Ref;
  final String op2Name;

  final String op1Result;

  final String op2Result;

  GameState get state => _processState();

  GameState _processState() {
    // If there's no office or no opponents, let the game be joinable
    if (officeRef == null || (op1Ref == null && op2Ref == null)) {
      return GameState.empty;
    }

    if (op1Ref != null && op2Ref == null) {
      return GameState.waiting_for_opponent;
    }

    if (op1Ref != null && op2Ref != null && op1Result == null && op2Result == null) {
      return GameState.in_progress;
    }

    if (op1Result != null || op2Result != null) {
      return GameState.waiting_on_result;
    }

    return GameState.unknown;
  }

  static Game empty() {
    return Game._();
  }

  Game._(): 
    this.id = null,
    this.officeRef = null,
    this.op1Ref = null,
    this.op1Name = null,
    this.op2Ref = null,
    this.op2Name = null,
    this.op1Result = null,
    this.op2Result = null;

  Game(DocumentSnapshot snapshot) : 
    this.id = snapshot.documentID,
    this.officeRef = snapshot.data["office"],
    this.op1Ref = snapshot.data["op_1"],
    this.op1Name = snapshot.data["op_1_name"],
    this.op2Ref = snapshot.data["op_2"],
    this.op2Name = snapshot.data["op_2_name"],
    this.op1Result = snapshot.data["op_1_result"],
    this.op2Result = snapshot.data["op_1_result"];
}

enum GameState {
   unknown, 
   empty,
   waiting_for_opponent, 
   in_progress, 
   waiting_on_result 
}