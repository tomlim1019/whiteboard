import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whiteboard/constant.dart';

class LGradePage2 extends StatefulWidget {
  LGradePage2({this.userDetails, this.subjectDetails});
  final userDetails, subjectDetails;
  static const String id = '/attendance';
  @override
  _LGradePage2State createState() => _LGradePage2State();
}

Firestore _firestore = Firestore.instance;

class _LGradePage2State extends State<LGradePage2> {
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
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('grade')
          .where('subject_code', isEqualTo: subjectCode)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final students = snapshot.data.documents;
        List<StudentCards> studentCards = [];

        for (var student in students) {
          final studentName = student.data['student_name'];
          final studentCode = student.data['student_code'];
          final marks = student.data['marks'];
          final totalMarks = student.data['total_marks'];

          final studentCard = StudentCards(
            name: studentName,
            studentCode: studentCode,
            subjectCode: subjectCode,
            marks : marks,
            totalMarks : totalMarks,
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
        this.marks,
        this.totalMarks
      });
  final String name, studentCode, subjectCode;
  final int marks, totalMarks;
  int givenMarks, newTotal;

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
            Center(child: Text(name, style: kLecturerTitleTextStyle,)),
            SizedBox(
              height: 10,
            ),
            Center(child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Marks: ${marks.toString()}/${totalMarks.toString()}', style: kLecturerTitleTextStyle,),
              ),
            )),
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
                              title: Text('Grade'),
                              content: Column(
                                children: <Widget>[
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                        labelText: 'Marks Given'
                                    ),
                                    onChanged: (value){
                                      try{
                                        givenMarks = int.parse(value);
                                      } catch (e) {print(e);}
                                    },
                                  ),
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                        labelText: 'Total Marks'
                                    ),
                                    onChanged: (value){
                                      try{
                                        newTotal = int.parse(value);
                                      } catch (e) {print(e);}
                                    },
                                  )
                                ],
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Ok'),
                                  onPressed: () {
                                    _firestore
                                        .collection('grade')
                                        .document('$studentCode$subjectCode')
                                        .updateData({
                                      'marks': marks+givenMarks,
                                      'total_marks': totalMarks+newTotal
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
                    child: Text('Update Grades', style: TextStyle(color: Colors.white),),
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
