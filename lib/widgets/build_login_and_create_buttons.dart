import 'package:flutter/material.dart';
import 'package:journal/blocs/login_bloc.dart';

class BuildLoginAndCreateButtons extends StatefulWidget {
  final LoginBloc loginBloc;
  const BuildLoginAndCreateButtons({super.key, required this.loginBloc});

  @override
  State<BuildLoginAndCreateButtons> createState() => BuildLoginAndCreateButtonsState();
}

class BuildLoginAndCreateButtonsState extends State<BuildLoginAndCreateButtons> {
  
  @override
  Widget build(BuildContext context) {
    LoginBloc loginBloc = widget.loginBloc;

    Column buttonsLogin() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder(
            initialData: false,
            stream: loginBloc.enableLoginCreateButton, 
            builder: (BuildContext context, AsyncSnapshot snapshot) => ElevatedButton(
              onPressed: snapshot.data
                ? () => loginBloc.loginOrCreateChanged.add('Login')
                : null, 
              child: Text('Login'),
            )
          ),
          TextButton(
            onPressed: () {},
            child: Text('Create Account')
        )
        ],
      );
    }

    Column buttonsCreateAccount() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder(
            initialData: false,
            stream: loginBloc.enableLoginCreateButton,
            builder: (BuildContext context, AsyncSnapshot snapshot) => ElevatedButton(
              onPressed: snapshot.data
                ? () => loginBloc.loginOrCreateChanged.add('Create Account')
                : null,
              child: Text('Create Account')
            )
          ),
          TextButton(
            onPressed: () {},
            child: Text('Login'),
          )
        ],
      );
    }

    return StreamBuilder(
      initialData: 'Login',
      stream: loginBloc.loginOrCreateButton, 
      builder: ((BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == 'Login') {
          return buttonsLogin();
        } else  {
          return buttonsCreateAccount();
        }
      }),
    );
  }
}