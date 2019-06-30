import 'package:bloc/bloc.dart';

class LoggingBlocDelegate extends BlocDelegate {

  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    // TODO - Crash reporting
  }
}