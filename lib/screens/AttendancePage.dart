import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whiteboard/constant.dart';

class AttendancePage extends StatefulWidget {
  AttendancePage({this.userDetails});
  final userDetails;
  static const String id = '/attendance';
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

Firestore _firestore = Firestore.instance;

class _AttendancePageState extends State<AttendancePage> {
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
          .collection('attendance')
          .where('student_code', isEqualTo: uid)
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
          final labAttendance = attendance.data['lab_attendance'].toString();
          final totalLab = attendance.data['lab_total'].toString();
          final lectureAttendance = attendance.data['lecture_attendance'].toString();
          final totalLecture = attendance.data['lecture_total'].toString();

          final gradeCard = AttendanceCard(
            title: subjectName,
            labAttendance: labAttendance,
            lectureAttendance: lectureAttendance,
            lecturerName: lecturerName,
            totalLab: totalLab,
            totalLecture: totalLecture,
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
  AttendanceCard({this.lecturerName, this.title, this.labAttendance, this.lectureAttendance, this.totalLab, this.totalLecture});
  final String title,lecturerName, lectureAttendance, totalLecture, labAttendance, totalLab;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: kLecturerTitleTextStyle,),
            SizedBox(height: 10,),
            Text(lecturerName, style: kLecturerNameTextStyle,),
            SizedBox(height: 10,),
            Row(
              children: <Widget>[
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: <Widget>[
                          SizedBox(),
                          Text('Class'),
                          SizedBox(),
                          Text('$lectureAttendance/ $totalLecture'),
                          SizedBox(),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    ),
                    color: Color(0xFF607D8B),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: <Widget>[
                          SizedBox(),
                          Text('Lab'),
                          SizedBox(),
                          Text('$labAttendance/ $totalLab'),
                          SizedBox(),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    ),
                    color: Color(0xFF607D8B),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
