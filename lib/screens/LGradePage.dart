import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LGradePage2.dart';
import 'package:whiteboard/constant.dart';

class LGradePage extends StatefulWidget {
  LGradePage({@required this.userDetails});
  final userDetails;
  static const String id = '/grade';
  @override
  _LGradePageState createState() => _LGradePageState();
}

Firestore _firestore = Firestore.instance;

class _LGradePageState extends State<LGradePage> {
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
        body: GradeStream(uid: widget.userDetails['user_id']));
  }
}

class GradeStream extends StatelessWidget {
  GradeStream({@required this.uid});
  final uid;
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
        final grades = snapshot.data.documents;
        List<GradeCards> gradeCards = [];
        for (var grade in grades) {
          final subjectName =
              '${grade.data['subject_code']} ${grade.data['subject_name']}';
          final lecturerName = grade.data['lecturer_name'];
          final subjectCode = grade.data['subject_code'];

          final gradeCard = GradeCards(
            lecturerName: lecturerName,
            title: subjectName,
            subjectCode: subjectCode,
            uid: uid,
          );
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
      @required this.uid,
      @required this.subjectCode});
  final String title, lecturerName, uid, subjectCode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LGradePage2(
                      userDetails: uid,
                      subjectDetails: subjectCode,
                    )));
      },
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(child: Text(title, style: kLecturerTitleTextStyle,)),
              SizedBox(
                height: 10,
              ),
              Center(child: Text(lecturerName, style: kLecturerNameTextStyle,)),
            ],
          ),
        ),
      ),
    );
  }
}
