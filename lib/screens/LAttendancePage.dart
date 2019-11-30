import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LAttendancePage2.dart';
import 'package:whiteboard/constant.dart';

class LAttendancePage extends StatefulWidget {
  LAttendancePage({this.userDetails});
  final userDetails;
  static const String id = '/attendance';
  @override
  _LAttendancePageState createState() => _LAttendancePageState();
}

Firestore _firestore = Firestore.instance;

class _LAttendancePageState extends State<LAttendancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Attendance',
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Center(
              child: Text(
                'Back',
              ),
            ),
          ),
        ),
        body: AttendanceStream(uid: widget.userDetails['user_id'])
    );
  }
}

class AttendanceStream extends StatelessWidget {
  AttendanceStream({@required this.uid});
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
        final attendances = snapshot.data.documents;
        List<AttendanceCard> attendanceCard = [];

        for (var attendance in attendances) {
          final subjectName =
              '${attendance.data['subject_code']} ${attendance.data['subject_name']}';
          final lecturerName = attendance.data['lecturer_name'];
          final subjectCode = attendance.data['subject_code'];

          final gradeCard = AttendanceCard(
            title: subjectName,
            subjectCode: subjectCode,
            uid: uid,
            lecturerName: lecturerName,
          );
          attendanceCard.add(gradeCard);
        }
        return ListView(
          children: attendanceCard,
        );
      },
    );
  }
}

class AttendanceCard extends StatelessWidget {
  AttendanceCard({this.lecturerName, this.title, this.subjectCode, this.uid});
  final String title,lecturerName, uid, subjectCode;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>LAttendancePage2(userDetails: uid, subjectDetails: subjectCode,)));
    },
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(child: Text(title, style: kLecturerTitleTextStyle,)),
              SizedBox(height: 10,),
              Center(child: Text(lecturerName, style: kLecturerNameTextStyle,)),
              SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
}
