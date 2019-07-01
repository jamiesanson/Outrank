import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outrank/screens/login/bloc/login_bloc.dart';

import 'home/home_screen.dart';
import 'login/login_screen.dart';

class Routes {

  static final mainRoutes = <String, WidgetBuilder>{
    '/home': (context) => HomeScreen(),
    '/login': (context) => BlocProvider(builder: (context) => LoginBloc(), child: LoginScreen()),
  };
}