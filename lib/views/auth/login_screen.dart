import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:blue_anura/views/navigation/dashboard_screen.dart';

const users = const {
  'a@b.c': '123',
};

class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String> _authUser(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'Username not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    print('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'Username not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 500.0,
      child: Container(
        child: FlutterLogin(
          title: 'Blue Anura',
          logo: 'assets/images/blue_frog.png',
          onLogin: _authUser,
          onSignup: _authUser,
          onSubmitAnimationCompleted: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => DashboardScreen(),
            ));
          },
          onRecoverPassword: _recoverPassword,
          theme: LoginTheme(
            accentColor: Colors.orange,
            errorColor: Colors.deepOrange,
            titleStyle: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontFamily: 'Grandstander',
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
            bodyStyle: TextStyle(
              fontStyle: FontStyle.italic,
              decoration: TextDecoration.underline,
            ),
            textFieldStyle: TextStyle(
              color: Colors.black,
              shadows: [Shadow(color: Colors.orange, blurRadius: 2)],
            ),
            buttonStyle: TextStyle(
            fontWeight: FontWeight.w800,
              color: Colors.orangeAccent,
            ),
            cardTheme: CardTheme(
              color: Colors.white,
              elevation: 5,
              margin: EdgeInsets.only(top: 10),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(100.0)
              ),
            ),
          ),
        ),
      )
    );
    }

}