import 'package:flutter/material.dart';
import 'ChapterPage.dart';
import 'package:whiteboard/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Firestore _firestore = Firestore.instance;

class LearningMaterialPage extends StatefulWidget {
  LearningMaterialPage({this.userDetails});
  final userDetails;
  static const String id = '/learning_material';
  @override
  _LearningMaterialPageState createState() => _LearningMaterialPageState();
}

class _LearningMaterialPageState extends State<LearningMaterialPage> {
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
        body: SubjectStream(uid: widget.userDetails['user_id']));
  }
}

class SubjectStream extends StatelessWidget {
  SubjectStream({@required this.uid});
  final uid;
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
  SubjectCard({this.lecturerName, this.title, this.subjectCode, this.uid});
  final String title, lecturerName, uid, subjectCode;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChapterPage(
                      userDetails: uid,
                      subjectDetails: subjectCode,
                      subjectName: title,
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
