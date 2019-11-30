import 'package:flutter/material.dart';
import 'AttendancePage.dart';
import 'GradePage.dart';
import 'TimetablePage.dart';
import 'LearningMaterialPage.dart';
import 'SubmissionPage.dart';
import 'ProfilePage.dart';
import 'package:whiteboard/components/DashboardButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({@required this.userDetails, this.storage});
  final userDetails, storage;
  static const String id = '/dashboard';
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Firestore _firestore = Firestore.instance;
  List<Timetable> timetables = [];
  bool done = false;

  getTimetable() {
    try {
      _firestore
          .collection('subject')
          .where('student_code', arrayContains: widget.userDetails['user_id'])
          .snapshots()
          .listen((subjects) {
        for (var subject in subjects.documents) {
          if (subject['lecture_class'] ==
              DateFormat.EEEE().format(DateTime.now())) {
            final lectureTimetable = Timetable(
                subject['lecturer_name'],
                subject['subject_name'],
                subject['lecture_time'],
                subject['lecture_venue']);
            timetables.add(lectureTimetable);
          } else if (subject['lab_class'] ==
              DateFormat.EEEE().format(DateTime.now())) {
            final labTimetable = Timetable(
                subject['lecturer_name'],
                subject['subject_name'],
                subject['lecture_time'],
                subject['lecture_venue']);
            timetables.add(labTimetable);
          }
        }
        sort(timetables);
        if (timetables.length == 0) {
          timetables.add(Timetable("", "No class today!", "", ""));
        }
        setState(() {
          done = true;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void sort(var timetable) {
    var times = [];
    timetable.forEach((time) {
      times.add(int.parse(time.time.split('-')[0]));
    });
    for (int i = 0; i < times.length + 1; i++) {
      for (int j = 0; j < times.length - 1; j++) {
        if (times[j] > times[j + 1]) {
          var temp = times[j];
          times[j] = times[j + 1];
          times[j + 1] = temp;
          var temp2 = timetables[j];
          timetables[j] = timetables[j + 1];
          timetables[j + 1] = temp2;
        }
      }
    }
  }

  @override
  void initState() {
    getTimetable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userDetails['name'],
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            color: Color(0xFF607D8B),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text('Semester'),
                      Center(
                        child: Text(widget.userDetails['semester']),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text('Subject'),
                      Center(
                        child: Text(widget.userDetails['subject_taken']),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text('Week'),
                      Center(
                        child: Text(widget.userDetails['week']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: done
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            'Today\' Timeline\n${DateFormat.yMMMMEEEEd().format(DateTime.now())}',
                            style: TextStyle(color: Colors.black),
                          ),
//                          Text(DateFormat.yMMMMEEEEd().format(DateTime.now())),
                          CarouselSlider(
                            height: 140,
                            items: timetables,
                            enableInfiniteScroll: false,
                          )
                        ],
                      )
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      DashboardButton(
                        title: 'Attendance',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AttendancePage(
                                        userDetails: widget.userDetails,
                                      )));
                        },
                      ),
                      DashboardButton(
                        title: 'Grades',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GradePage(
                                      userDetails: widget.userDetails)));
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      DashboardButton(
                        title: 'Timetable',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TimetablePage(
                                      userDetails: widget.userDetails)));
                        },
                      ),
                      DashboardButton(
                        title: 'Learning Material',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LearningMaterialPage(
                                        userDetails: widget.userDetails,
                                      )));
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      DashboardButton(
                        title: 'Submission',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SubmissionPage(
                                      userDetails: widget.userDetails,
                                      storage: widget.storage)));
                        },
                      ),
                      DashboardButton(
                        title: 'Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                    email: widget.userDetails['email'],
                                    name: widget.userDetails['name'],
                                    phone: widget.userDetails['phone'],
                                    course: widget.userDetails['course'],
                                    userType: widget.userDetails['usertype'],
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Timetable extends StatelessWidget {
  Timetable(this.lecturerName, this.subjectName, this.time, this.venue);

  final String time, venue, subjectName, lecturerName;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      color: Color(0xFF607D8B),
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(time),
                Text(venue),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(subjectName),
            SizedBox(
              height: 10,
            ),
            Text(lecturerName),
          ],
        ),
      ),
    );
  }
}
