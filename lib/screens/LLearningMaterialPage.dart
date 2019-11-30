import 'package:flutter/material.dart';
import 'LChapterPage.dart';
import 'package:whiteboard/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Firestore _firestore = Firestore.instance;

class LLearningMaterialPage extends StatefulWidget {
  LLearningMaterialPage({this.userDetails, this.storage});
  final userDetails;
  final FirebaseStorage storage;
  @override
  _LLearningMaterialPageState createState() => _LLearningMaterialPageState();
}

class _LLearningMaterialPageState extends State<LLearningMaterialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Learning Material',
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
        ));
  }
}

class SubjectStream extends StatelessWidget {
  SubjectStream({@required this.uid, this.storage});
  final uid;
  final FirebaseStorage storage;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('subject')
          .where('lecturer_id', isEqualTo: uid)
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
      this.storage});
  final String title, lecturerName, uid, subjectCode;
  final FirebaseStorage storage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LChapterPage(
                      userDetails: uid,
                      subjectDetails: subjectCode,
                      subjectName: title,
                      storage: storage,
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
