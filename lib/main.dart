import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outrank/screens/ranking/bloc/ranking_repository.dart';
import 'package:outrank/screens/routes.dart';
import 'package:outrank/themes.dart';
import 'package:outrank/util/logging_bloc_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloc/bloc.dart';

// Screens
import 'constants.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  BlocSupervisor.delegate = LoggingBlocDelegate();
  runApp(AppStateContainer(child: Outrank()));
}

class Outrank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ImmutableProviderTree(
        immutableProviders: [
          ImmutableProvider<RankingRepository>(
            value: RankingRepository(),
          ),
        ],
        child: MaterialApp(
          title: 'Outrank',
          theme: AppStateContainer.of(context).theme,
          home: SplashScreen(),
          routes: Routes.mainRoutes,
        ));
  }
}

/// top level widget to hold application state
/// state is passed down with an inherited widget
class AppStateContainer extends StatefulWidget {
  final Widget child;

  AppStateContainer({@required this.child});

  @override
  _AppStateContainerState createState() => _AppStateContainerState();

  static _AppStateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }
}

class _AppStateContainerState extends State<AppStateContainer> {
  
  String currentUserId;

  ThemeData _theme = Themes.getTheme();
  int themeCode;

  ThemeData get theme => _theme;

  @override
  initState() {
    super.initState();
    SharedPreferences.getInstance().then((sharedPrefs) {
      setState(() {
        themeCode = sharedPrefs.getInt(Constants.THEME_INDEX_KEY);
        currentUserId = sharedPrefs.getString(Constants.USER_ID_KEY);

        this._theme = Themes.getTheme(code: themeCode);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }

  updateUserId(String userId) {
    setState(() {
      this.currentUserId = userId;
    });
    SharedPreferences.getInstance().then((sharedPref) {
      sharedPref.setString(Constants.USER_ID_KEY, userId);
    });
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final _AppStateContainerState data;

  const _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer oldWidget) => true;
}