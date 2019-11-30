import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whiteboard/constant.dart';

class LAttendancePage2 extends StatefulWidget {
  LAttendancePage2({this.userDetails, this.subjectDetails});
  final userDetails, subjectDetails;
  static const String id = '/attendance';
  @override
  _LAttendancePage2State createState() => _LAttendancePage2State();
}

Firestore _firestore = Firestore.instance;

class _LAttendancePage2State extends State<LAttendancePage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Attendance',
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
          actions: <Widget>[
            FlatButton(onPressed: (){
              _firestore
                  .collection('attendance')
                  .where('subject_code', isEqualTo: widget.subjectDetails)
                  .getDocuments().then((doc){
              });
            }, child: Icon(Icons.calendar_today, color: Colors.white,))
          ],
        ),
        body: StudentStream(
          uid: widget.userDetails,
          subjectCode: widget.subjectDetails,
        ));
  }
}

class StudentStream extends StatelessWidget {
  StudentStream({@required this.uid, this.subjectCode});
  final uid;
  final subjectCode;
  @override
  Widget build(BuildContext context) {
    print(subjectCode);
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('attendance')
          .where('subject_code', isEqualTo: subjectCode)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          print('done');
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final students = snapshot.data.documents;
        List<StudentCards> studentCards = [];

        for (var student in students) {
          final studentName = student.data['student_name'];
          final lab = student.data['lab_attendance'];
          final labTotal = student.data['lab_total'];
          final lecture = student.data['lecture_attendance'];
          final lectureTotal = student.data['lecture_total'];
          final studentCode = student.data['student_code'];

          final studentCard = StudentCards(
            name: studentName,
            lab: lab,
            labTotal: labTotal,
            lecture: lecture,
            lectureTotal: lectureTotal,
            studentCode: studentCode,
            subjectCode: subjectCode,
          );
          studentCards.add(studentCard);
        }
        return ListView(
          children: studentCards,
        );
      },
    );
  }
}

class StudentCards extends StatelessWidget {
  StudentCards(
      {this.name,
      this.subjectCode,
      this.studentCode,
      this.lab,
      this.labTotal,
      this.lecture,
      this.lectureTotal});
  final String name, studentCode, subjectCode;
  final int lab, labTotal, lecture, lectureTotal;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Text(
              name,
              style: kLecturerTitleTextStyle,
            )),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Lab Attendance: ${lab.toString()}/${labTotal.toString()}',
                    style: kLecturerTitleTextStyle,
                  ),
                ),
              ),
            ),
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Lecture Attendance: ${lecture.toString()}/${lectureTotal.toString()}',
                    style: kLecturerTitleTextStyle,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    color: Color(0xFF607D8B),
                    padding: EdgeInsets.all(0.0),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Attendance'),
                              content: Text('Lecture Attendance for $name'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Absent'),
                                  onPressed: () {
                                    _firestore
                                        .collection('attendance')
                                        .document('$studentCode$subjectCode')
                                        .updateData({
                                      'lecture_attendance': lecture,
                                      'lecture_total': lectureTotal + 1
                                    }).catchError((e) {
                                      print(e);
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Present'),
                                  onPressed: () {
                                    _firestore
                                        .collection('attendance')
                                        .document('$studentCode$subjectCode')
                                        .updateData({
                                      'lecture_attendance': lecture + 1,
                                      'lecture_total': lectureTotal + 1
                                    }).catchError((e) {
                                      print(e);
                                    });
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    },
                    child: Text(
                      'Sign Lecture Attendance',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: RaisedButton(
                    color: Color(0xFF607D8B),
                    padding: EdgeInsets.all(0.0),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Attendance'),
                              content: Text(
                                'Mark attendance for $name ?',
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Absent'),
                                  onPressed: () {
                                    _firestore
                                        .collection('attendance')
                                        .document('$studentCode$subjectCode')
                                        .updateData({
                                      'lab_attendance': lab,
                                      'lab_total': labTotal + 1
                                    }).catchError((e) {
                                      print(e);
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Present'),
                                  onPressed: () {
                                    _firestore
                                        .collection('attendance')
                                        .document('$studentCode$subjectCode')
                                        .updateData({
                                      'lab_attendance': lab + 1,
                                      'lab_total': labTotal + 1
                                    }).catchError((e) {
                                      print(e);
                                    });
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    },
                    child: Text(
                      'Sign Lab Attendance',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
