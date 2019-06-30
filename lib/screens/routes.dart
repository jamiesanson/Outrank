import 'package:flutter/widgets.dart';

import 'home/home_screen.dart';
import 'login/login_screen.dart';

class Routes {

  static final mainRoutes = <String, WidgetBuilder>{
    '/home': (context) => HomeScreen(),
    '/login': (context) => LoginScreen(),
  };
}