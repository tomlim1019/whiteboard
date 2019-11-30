import 'package:flutter/material.dart';
import 'package:whiteboard/constant.dart';
import 'DashboardPage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:whiteboard/components/LoginFunction.dart';
import 'LDashboardPage.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.storage});
  final FirebaseStorage storage;
  static const String id = '/';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  bool checked = false;
  bool showSpinner = false;
  String _username;
  String _password;

  checkStayLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('checked')) {
      login(prefs.getString('username'), prefs.getString('password'));
    }
  }

  login(String username, String password) async {
    String alert;
    setState(() {
      showSpinner = true;
    });
    if (password == null) {
      alert = 'Password cannot be blank!';
    } else if (username == null) {
      alert = 'Username cannot be blank!';
    } else {
      alert = 'Wrong Password or User not exist!';
    }
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: '$username@email.com', password: password);
      if (user != null) {
        var userDetails = await LoginFunction().getCurrentUser();
//        print(userDetails);
        Toast.show('Logged In Succesfully!', context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => userDetails['usertype'] == 'student'
                    ? DashboardPage(
                        userDetails: userDetails,
                        storage: widget.storage,
                      )
                    : LDashboardPage(
                        userDetails: userDetails,
                        storage: widget.storage,
                      )));
      }
      setState(() {
        showSpinner = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        showSpinner = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Error'),
              content: Text(alert),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }

  @override
  void initState() {
    checkStayLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Flexible(
                child: Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: Image.asset(
                    'images/CapstoneLOGO.png',
                  ),
                ),
              ),
              Flexible(
                child: TypewriterAnimatedTextKit(
                  text: [ktitle],
                  textStyle: kTitleTextStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      labelText: 'Username',
                      labelStyle: kLecturerTitleTextStyle,
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 1))),
                  onChanged: (value) {
                    _username = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(12.0),
                      labelText: 'Password',
                      labelStyle: kLecturerTitleTextStyle,
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 1))),
                  onChanged: (value) {
                    _password = value;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Checkbox(
                      value: checked,
                      onChanged: (bool value) async {
                        setState(() {
                          checked = value;
                        });
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('checked', checked);
                      }),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    'Keep me signed in',
                    style: kLecturerTitleTextStyle,
                  ),
                ],
              ),
              Container(
                height: 50,
                width: 110,
                child: FlatButton(
                  onPressed: () async {
                    login(_username, _password);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    if (prefs.getBool('checked')) {
                      await prefs.setString('username', _username);
                      await prefs.setString('password', _password);
                    }
                  },
                  child: Text('Sign In'),
                  color: Colors.transparent,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(),
                  ),
                ),
              ),
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
