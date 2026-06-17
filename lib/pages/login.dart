import 'package:flutter/material.dart';
import 'package:journal/blocs/login_bloc.dart';
import 'package:journal/services/auth/authentication.dart';
import 'package:journal/widgets/build_login_and_create_buttons.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(Authentication());
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0), 
          child: Icon(
            Icons.account_circle,
            size: 88.0,
            color: Colors.white,
          )
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder(
                stream: _loginBloc.email, 
                builder: (BuildContext context, AsyncSnapshot snapshot) => TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    icon: Icon(Icons.mail_outline),
                    errorText: snapshot.hasError
                      ? snapshot.error.toString()
                      : null,
                  ),
                  onChanged: _loginBloc.emailChanged.add,
                )
              ),
              StreamBuilder(
                stream: _loginBloc.password, 
                builder: (BuildContext context, AsyncSnapshot snapshot) => TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    icon: Icon(Icons.security),
                    errorText: snapshot.hasError
                      ? snapshot.error.toString()
                      : null,
                  ),
                  onChanged: _loginBloc.passwordChanged.add,
                ),
              ),
              SizedBox(height: 48.0,),
              BuildLoginAndCreateButtons(loginBloc: _loginBloc),
            ],
          ),
        )
      ),
    );
  }
}