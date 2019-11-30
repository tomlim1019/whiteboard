import 'package:flutter/material.dart';
import 'AssignmentPage.dart';
import 'package:whiteboard/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Firestore _firestore = Firestore.instance;

class SubmissionPage extends StatefulWidget {
  SubmissionPage({this.userDetails, this.storage});
  final userDetails;
  final FirebaseStorage storage;
  static const String id = '/learning_material';
  @override
  _SubmissionPageState createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Submission',
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
        body: SubjectStream(
          uid: widget.userDetails['user_id'],
          storage: widget.storage,
          username: widget.userDetails['name'],
        ));
  }
}

class SubjectStream extends StatelessWidget {
  SubjectStream({@required this.uid, this.storage, this.username});
  final uid, username;
  final FirebaseStorage storage;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('subject')
          .where('student_code', arrayContains: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final subjects = snapshot.data.documents;
        List<SubjectCard> subjectCards = [];

        for (var subject in subjects) {
          final subjectName =
              '${subject.data['subject_code']} ${subject.data['subject_name']}';
          final lecturerName = subject.data['lecturer_name'];
          final subjectCode = subject.data['subject_code'];

          final subjectCard = SubjectCard(
            title: subjectName,
            subjectCode: subjectCode,
            uid: uid,
            lecturerName: lecturerName,
            storage: storage,
            username: username,
          );
          subjectCards.add(subjectCard);
        }
        return ListView(
          children: subjectCards,
        );
      },
    );
  }
}

class SubjectCard extends StatelessWidget {
  SubjectCard(
      {this.lecturerName,
      this.title,
      this.subjectCode,
      this.uid,
      this.storage,
      this.username});
  final String title, lecturerName, uid, subjectCode, username;
  final FirebaseStorage storage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AssignmentPage(
                      subjectName: title,
                      subjectDetails: subjectCode,
                      userDetails: uid,
                      storage: storage,
                      username: username,
                    )));
      },
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: kLecturerTitleTextStyle,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                lecturerName,
                textAlign: TextAlign.center,
                style: kLecturerNameTextStyle,
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
