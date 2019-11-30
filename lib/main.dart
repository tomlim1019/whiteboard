import 'package:flutter/material.dart';
import 'package:whiteboard/screens/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'capstone',
    options: FirebaseOptions(
      googleAppID: '1:603838278227:android:c9c47e5e02e8040d',
      apiKey: 'AIzaSyCxM6BoK7cLEQk8JeW-ZGsRMDwgZqOYBIo',
      projectID: 'capstone-fbb11',
    ),
  );
  final FirebaseStorage storage = FirebaseStorage(
      app: app, storageBucket: 'gs://capstone-fbb11.appspot.com');
  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  MyApp({this.storage});
  final FirebaseStorage storage;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          textTheme: TextTheme(
            body1: TextStyle(color: Colors.white),
          ),
          scaffoldBackgroundColor: Color(0xFFCFD8DC),
          cardColor: Color(0xFFCFD8DC),
          appBarTheme: AppBarTheme(
            color: Color(0xFF455A64),
          )),
      home: LoginPage(storage: storage,),
    );
  }
}
