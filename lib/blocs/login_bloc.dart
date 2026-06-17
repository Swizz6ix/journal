import 'dart:async';

import 'package:journal/classes/validators.dart';
import 'package:journal/services/auth/authentication_api.dart';

class LoginBloc with Validators {
   LoginBloc(this.authenticationApi) {
    _startListenersIfEmailPasswordAreValid();
  }

  final AuthenticationApi authenticationApi;

  late final StreamSubscription _emailSub;
  late final StreamSubscription _passwordSub;
  late final StreamSubscription _actionSub;
  
  String? _email;
  String? _password;

  final StreamController<String> _emailController = StreamController<String>.broadcast();
  Sink<String> get emailChanged => _emailController.sink;
  Stream<String> get email => _emailController.stream.transform(validateEmail);

  final StreamController<String> _passwordController = StreamController<String>.broadcast();
  Sink<String> get passwordChanged => _passwordController.sink;
  Stream<String> get password => _passwordController.stream.transform(validatePassword);

  final StreamController<bool> _enableloginCreateButtonController = StreamController<bool>.broadcast();
  Sink<bool> get enableLoginCreateButtonChanged => _enableloginCreateButtonController.sink;
  Stream<bool> get enableLoginCreateButton => _enableloginCreateButtonController.stream;

  final StreamController<String> _loginOrCreateButtonController = StreamController<String>();
  Sink<String> get loginOrCreateButtonChanged => _loginOrCreateButtonController.sink;
  Stream<String> get loginOrCreateButton => _loginOrCreateButtonController.stream;

  final StreamController<String> _loginOrCreateController = StreamController<String>();
  Sink<String> get loginOrCreateChanged => _loginOrCreateController.sink;
  Stream<String> get loginOrCreate => _loginOrCreateController.stream;

  bool get isFormValid => _email != null && _password != null;

  // This method is resposible for setting up three(3) listeners 
  // that check email, password, and login or create button streams.
  void _startListenersIfEmailPasswordAreValid() {
    _emailSub = email.listen((email) {
      _email = email;
      _updateEnableLoginCreateButtonStream();
    });

    _passwordSub = password.listen((password) {
      _password = password;
      _updateEnableLoginCreateButtonStream();
    });

    _actionSub = loginOrCreate.listen((action) {
      action == 'Login' ? _logIn() : _createAccount();
    });
  }

  // This method checks whether the  _emailValid and _passwordValid variables 
  // evaluate to true, and call the enableLogin CreateButtonChanged.add(true) 
  // to add a true value to the sink property. Otherwise, add a false value to 
  // the sink property. The results of the value being added to the sink property either 
  // enable or disable the login or create account buttons.
  void _updateEnableLoginCreateButtonStream() {
    enableLoginCreateButtonChanged.add(isFormValid);
  }

  // This method is responsible for logging in a user with email/password credentials
  Future<String> _logIn() async {
    String result = '';
    if (isFormValid) {
      try {
        await authenticationApi.signInWithEmailAndPassword(
          email: _email!, 
          password: _password!,
        );
        result = 'Success';
      } catch (error) {
        print('Login error: $error');
        return result = error.toString();
      }
      return result;
    } else {
      return 'Email and Password are not valid';
    }
  }

  // This method is responsilbe for creating a new account and if successful
  // automatically login in the new user.
  Future<String> _createAccount() async {
    String result = '';
    if (isFormValid) {
      try {
        final uid = await authenticationApi.createUserWithEmailAndPassword(
          email: _email!, 
          password: _password!,
        );
        print('Create user: $uid');
        result = 'Created user: $uid';

        try {
          await authenticationApi.signInWithEmailAndPassword(
            email: _email!, 
            password: _password!,
          );
        } catch (error) {
          print('Login error: $error');
          result = error.toString();
        }
      } catch (error) {
          print('Create user error: $error');
      }
        return result;
    } else {
      return 'Error creating user';
    }
  }

  // Close the StreamController's stream when they are not needed.
  void dispose() {
    _emailSub.cancel();
    _passwordSub.cancel();
    _actionSub.cancel();

    _passwordController.close();
    _emailController.close();
    _enableloginCreateButtonController.close();
    _loginOrCreateButtonController.close();
    _loginOrCreateController.close();
  }
}