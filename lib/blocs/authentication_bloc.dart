import 'dart:async';

import 'package:journal/services/auth/authentication_api.dart';

// This is class is responisble for identifying logging-in user
// credentials and monitoring user authentication login stauts
// When the AuthenticationBloc is instantiated, it starts a streamController
// listener that monitors the user's authentication credentials and when
// changes occur, the listener updates the credential status by calling
// sink.add() method event. If user is logged in, the sink events send the 
// user uid value, and if the user is logs out, the sink events sends a null value
// meaning no user is logged in.
class AuthenticationBloc {
  late final AuthenticationApi authenticationApi;

  final StreamController<String> _authenticationController = StreamController<String>();
  Sink<String> get addUser => _authenticationController.sink;
  Stream<String> get user => _authenticationController.stream;

  final StreamController<bool> _logoutController = StreamController<bool>();
  Sink<bool> get logoutUser => _logoutController.sink;
  Stream<bool> get listLogoutUser => _logoutController.stream;

  AuthenticationBloc(this.authenticationApi) {
    onAuthChanged();
  }

  void onAuthChanged() {
    authenticationApi
      .getFirebaseAuth()
      .onAuthStateChanged
      .listen((user) {
        final String uid = user?.uid;
        addUser.add(uid);
      });
      _logoutController.stream.listen((logout) {
        if (logout == true) _signOut();
      });
  }

  void _signOut() {
    authenticationApi.signOut();
  }

  void dispose() {
    _authenticationController.close();
    _logoutController.close();
  }
}