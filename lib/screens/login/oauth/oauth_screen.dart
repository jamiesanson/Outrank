import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:outrank/screens/login/oauth/bloc/oauth_bloc.dart';
import 'package:outrank/screens/login/oauth/bloc/oauth_event.dart';
import 'package:outrank/screens/login/oauth/bloc/oauth_state.dart';
import 'package:outrank/widgets/empty_app_bar.dart';

class OAuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OAuthBloc _bloc = BlocProvider.of<OAuthBloc>(context);

    return BlocListener(
      bloc: _bloc,
      listener: (context, state) {
        if (state is TokenRetrieved) {
          Navigator.pop(context, state.token);
        }

        if (state is TokenNotRetrieved) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder(
          bloc: _bloc,
          builder: (context, state) {
            if (state is WebviewPrompt) {
              _bloc.dispatch(BeginListening());
              
              return WebviewScaffold(
                appBar: AppBar(
                  title: Text("Sign in with Slack"),
                ),
                url: state.url,
              );
            }

            return Scaffold(
                appBar: EmptyAppBar(),
                body: Center(
                  child: CircularProgressIndicator(),
                ));
          }),
    );
  }
}
