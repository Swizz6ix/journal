import 'package:flutter/material.dart';
import 'package:journal/blocs/home_bloc.dart';

class HomeBlocProvider extends InheritedWidget {
  final HomeBloc homeBloc;
  final String uid;

  const HomeBlocProvider({
    super.key,
    required super.child,
    required this.homeBloc,
    required this.uid
  });

  // This allows childern to get the instance of the provider
  static HomeBloc of(BuildContext context) {
    final provider = context
      .dependOnInheritedWidgetOfExactType<HomeBlocProvider>();
    assert(
      provider != null,
      'No HomeBlocProvider found in context',
    );

    return provider!.homeBloc;
  }

  // This method checks if the homeBloc does not equal to HomeBlocProvider homeBloc
  // If the expression returns true, the framework notifies widgets that hold 
  // inherited data that they need to rebuild.
  // If the expression returns a false value, the framework does not send a notification
  // since there is no need to rebuild widgets.
  @override
  bool updateShouldNotify(HomeBlocProvider old) => homeBloc != old.homeBloc;
}