import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outrank/model/game.dart';
import 'package:outrank/model/office.dart';
import 'package:outrank/model/user.dart';
import 'package:outrank/screens/ranking/bloc/bloc.dart';
import 'package:outrank/widgets/backdrop.dart';
import 'package:outrank/widgets/empty_app_bar.dart';

class RankingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RankingBloc _rankingBloc = BlocProvider.of<RankingBloc>(context);
    if (!(_rankingBloc.currentState is RanksLoaded)) {
      _rankingBloc.dispatch(FetchAll());
    }

    return BlocBuilder(
      bloc: _rankingBloc,
      builder: (context, state) {
        if (state is RanksLoading) {
          return Loading();
        }

        if (state is RanksNotLoaded) {
          return NotLoaded();
        }

        return Loaded();
      },
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
      appBar: EmptyAppBar(),
    );
  }
}

class NotLoaded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RankingBloc _rankingBloc = BlocProvider.of<RankingBloc>(context);

    return Scaffold(
      body: Center(
          child: Column(children: <Widget>[
        Text("BANANA ERROR, YIKES"),
        MaterialButton(
          minWidth: 300,
          height: 48,
          child: Text(
            "START PLAYING",
            style: TextStyle(fontSize: 16),
          ),
          onPressed: () {
            _rankingBloc.dispatch(FetchAll());
          },
        )
      ])),
      appBar: EmptyAppBar(),
    );
  }
}

class Loaded extends StatelessWidget {
  Widget _userList(List<User> users) {
    return Column(children: <Widget>[
      Text("This month's top players"),
      ...users.map((User user) {
        String subtitleText = user.gameCount != null
            ? "${user.gameCount} games played this month"
            : "No games this month";
        return ListTile(
          title: Text(user.name),
          subtitle: Text(subtitleText),
        );
      }).toList(),
    ]);
  }

  String _tableTextForGame(Game game) {
    switch (game.state) {
      case GameState.empty: return "The table is free!";
      case GameState.waiting_for_opponent: return "A game is about to start";
      case GameState.in_progress: return "A game is in progress";
      case GameState.waiting_on_result: return "A game is about to end";
      default: return "Something weird happened. A game might be in progess";
    }
  }

  String _buttonTextForGame(Game game) {
    switch (game.state) {
      case GameState.waiting_for_opponent: return game.op1Name != null ? "PLAY ${game.op1Name.toUpperCase()}" : "JOIN GAME";
      default: return "START PLAYING";
    }
  }

  // Builds the page header widget, with illustration, start game action and
  // whether or not the table's in use
  Widget _pageHeader(Office office, Game game, VoidCallback onStartPressed) {

    String tableText = _tableTextForGame(game);
    String buttonText = _buttonTextForGame(game);
    bool isButtonDisabled = game.state == GameState.in_progress || game.state == GameState.waiting_on_result;

    return Column(
      children: <Widget>[
        Image.network(
          "https://www.trademe.co.nz/trust-safety/media/285465/kevin-nest-trademe.png",
          width: 200,
          height: 200,
        ),
        Text(tableText),
        Padding(
          padding: EdgeInsets.all(16),
          child: Center(
              child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  color: Color(0xFF3B71DC),
                  clipBehavior: Clip.antiAlias,
                  child: MaterialButton(
                    minWidth: 300,
                    height: 48,
                    child: Text(
                      buttonText,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: isButtonDisabled ? null : () {
                      onStartPressed();
                    },
                  ))),
        )
      ],
    );
  }

  Widget _getBackgroundView(Office currentOffice, List<Office> allOffices,
      void Function(Office) onOfficeChosen) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
            children: allOffices.map((Office office) {
          return RadioListTile(
              title: Text(
                office.name,
                style: TextStyle(color: Colors.white),
              ),
              value: office.id,
              groupValue: currentOffice.id,
              activeColor: Colors.white,
              onChanged: (value) {
                onOfficeChosen(office);
              });
        }).toList()));
  }

  @override
  Widget build(BuildContext context) {
    final RankingBloc _rankingBloc = BlocProvider.of<RankingBloc>(context);

    return BlocBuilder(
      bloc: _rankingBloc,
      builder: (context, state) {
        if (state is RanksLoaded) {
          return Backdrop(
            currentOffice: state.office,
            frontLayer: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _pageHeader(state.office, state.currentGame, () {
                    _rankingBloc.dispatch(StartPlaying());
                  }),
                  _userList(state.users)
                ],
              ),
            ),
            backLayer:
                _getBackgroundView(state.office, state.allOffices, (office) {
              _rankingBloc.dispatch(OfficeChanged(office));
            }),
            frontTitle: Text(
              "Current: ${state.office.name}",
              style: TextStyle(fontSize: 16),
            ),
            backTitle: Text(
              'Choose your office',
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          throw Exception("Illegal loaded state $state");
        }
      },
    );
  }
}
