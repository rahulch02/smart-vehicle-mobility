import 'package:fcm_app/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = false;
  String? errorMessage = '';
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPass = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();

  String getCurrentUserId() {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    return uid;
  }

  void signUpWithEmailPass() async {
    if (_controllerEmail.text.isEmpty || _controllerPass.text.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Please enter a value for each field'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    try {
      Auth()
          .signIn(email: _controllerEmail.text, password: _controllerPass.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserwithEmailPass() async {
    if (_controllerName.text.isEmpty ||
        _controllerEmail.text.isEmpty ||
        _controllerPass.text.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Please enter a value for each field'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    WidgetTree.of(context)!.string = _controllerName.text;
    try {
      Auth().createUser(
          email: _controllerEmail.text, password: _controllerPass.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('Firebase Authentication');
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: title),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
        onPressed: isLogin ? signUpWithEmailPass : createUserwithEmailPass,
        child: Text(isLogin ? 'Login' : 'Register'));
  }

  Widget _loginRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Register Instead' : 'Login Instead'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _title()),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !isLogin
                ? _entryField('Full Name', _controllerName)
                : const SizedBox(),
            _entryField('E-mail', _controllerEmail),
            _entryField('Password', _controllerPass),
            _errorMessage(),
            _submitButton(),
            _loginRegisterButton()
          ],
        ),
      ),
    );
  }
}
