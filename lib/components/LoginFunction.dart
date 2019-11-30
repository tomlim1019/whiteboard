import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
final _auth = FirebaseAuth.instance;
FirebaseUser loggedInUser;
var userDetails;

class LoginFunction {
//  loginUser(String username, String password) async{
//  }
  getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        final userType = await _firestore.collection('user').document(user.uid).get().then((DocumentSnapshot ds){
          return ds.data;
        });
        return userType;
      }
    } catch (e) {
      print(e);
    }
  }
}