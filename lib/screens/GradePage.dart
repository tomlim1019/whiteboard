import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whiteboard/constant.dart';

class GradePage extends StatefulWidget {
  GradePage({@required this.userDetails});
  final userDetails;
  static const String id = '/grade';
  @override
  _GradePageState createState() => _GradePageState();
}

Firestore _firestore = Firestore.instance;


class _GradePageState extends State<GradePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Grade',
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
        body: GradeStream(uid: widget.userDetails['user_id'])
        );
  }
}

class GradeStream extends StatelessWidget {
  GradeStream({@required this.uid});
  final uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('grade')
          .where('student_code', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final grades = snapshot.data.documents;
        List<GradeCards> gradeCards = [];
        for (var grade in grades) {
          final marks = grade.data['marks'].toString();
          final totalMarks = grade.data['total_marks'].toString();
          final subjectName =
              '${grade.data['subject_code']} ${grade.data['subject_name']}';
          final lecturerName = grade.data['lecturer_name'];

          final gradeCard = GradeCards(
              lecturerName: lecturerName,
              title: subjectName,
              marks: marks,
              totalMarks: totalMarks);
          gradeCards.add(gradeCard);
        }
        return ListView(
          children: gradeCards,
        );
      },
    );
  }
}

class GradeCards extends StatelessWidget {
  GradeCards(
      {@required this.lecturerName,
      @required this.title,
      @required this.marks,
      @required this.totalMarks});
  final String title, lecturerName, marks, totalMarks;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: kLecturerTitleTextStyle,),
            Text(lecturerName, style: kLecturerNameTextStyle,),
            Center(
              child: Card(
                color: Color(0xFF607D8B),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 10.0),
                  child: Text('$marks/$totalMarks'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
