import 'package:flutter/material.dart';
import 'package:journal/blocs/authentication_bloc.dart';


class AuthenticationBlocProvider extends InheritedWidget {
  final AuthenticationBloc authenticationBloc;

  const AuthenticationBlocProvider({
    super.key, 
    required super.child,
    required this.authenticationBloc,
  });

  static AuthenticationBloc of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AuthenticationBlocProvider>();

    assert(
      provider != null,
      'No AuthenticationBlocProvider found in context',
    );

    return provider!.authenticationBloc;
  }

  @override
  bool updateShouldNotify(AuthenticationBlocProvider old) => 
    authenticationBloc != old.authenticationBloc;
}