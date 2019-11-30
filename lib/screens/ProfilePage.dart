import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'DashboardPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whiteboard/constant.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage(
      {@required this.email,
      @required this.name,
      @required this.phone,
      @required this.course,
      @required this.userType});
  final String name, phone, email, course, userType;
  static const String id = '/profile';
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Center(
              child: Text(
                'Back',
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.name, style: kLecturerTitleTextStyle,),
                            SizedBox(
                              height: 5,
                            ),
                            Text('${widget.course} - ${widget.userType}', style: kLecturerNameTextStyle,),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: Color(0xFF607D8B),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Mobile', style: kLecturerTitleTextStyle,),
                        SizedBox(
                          height: 5,
                        ),
                        Text(widget.phone, style: kLecturerNameTextStyle,),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Email', style: kLecturerTitleTextStyle,),
                        SizedBox(
                          height: 5,
                        ),
                        Text(widget.email, style: kLecturerNameTextStyle,),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                prefs.setBool('checked', false);
                _auth.signOut();
                Toast.show('Logged Out!', context,duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//                Navigator.pushReplacement(context,
//                    MaterialPageRoute(builder: (context) => LoginPage()));
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Card(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
