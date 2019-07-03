import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outrank/model/model.dart';
import 'package:outrank/screens/match/bloc/match_bloc.dart';
import 'package:outrank/screens/match/bloc/match_event.dart';
import 'package:outrank/screens/match/bloc/match_state.dart';
import 'package:outrank/widgets/empty_app_bar.dart';

class MatchScreen extends StatelessWidget {
  final Office _currentOffice;
  
  MatchScreen(this._currentOffice);

  @override
  Widget build(BuildContext context) {
    final MatchBloc _bloc = BlocProvider.of<MatchBloc>(context);

    _bloc.dispatch(OfficeProvided(_currentOffice));

    return BlocListener(
        bloc: _bloc,
        listener: (context, state) {},
        child: BlocBuilder(
          bloc: _bloc,
          builder: (context, state) {
            if (state is WaitingOnOpponent) {
              return Scaffold(
                appBar: EmptyAppBar(),
                body: Text("Waiting on opponent"),
              );
            }

            if (state is PlayingGame) {
              return Scaffold(
                  appBar: EmptyAppBar(),
                  body: Center(
                      child: Column(children: <Widget>[
                    Text("In a match with ${state.opponentName}"),
                    FlatButton(
                      child: Text("Finished? Who won?"),
                      onPressed: () {
                        _bloc.dispatch(ReadyToReport());
                      },
                    )
                  ])));
            }

            if (state is ReportingResult) {
              return Scaffold(
                  appBar: EmptyAppBar(),
                  body: Center(
                      child: Column(children: <Widget>[
                    Text("Who won?"),
                    FlatButton(
                      child: Text("I DID!"),
                      onPressed: () {
                        _bloc.dispatch(ResultReported(true));
                      },
                    ),
                    FlatButton(
                      child: Text("${state.opponentName.toUpperCase()} DID."),
                      onPressed: () {
                        _bloc.dispatch(ResultReported(false));
                      },
                    )
                  ])));
            }

            if (state is WaitingOnOpponentResult) {
              return Scaffold(
                  appBar: EmptyAppBar(),
                  body: Center(
                      child: Text(
                          "Waiting on a result from ${state.opponentName}")));
            }

            return Scaffold(
                appBar: EmptyAppBar(),
                body: Center(child: CircularProgressIndicator()));
          },
        ));
  }
}
