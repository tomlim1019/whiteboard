import 'package:flutter/material.dart';
import 'LAttendancePage.dart';
import 'LGradePage.dart';
import 'LTimetablePage.dart';
import 'LLearningMaterialPage.dart';
import 'LSubmissionPage.dart';
import 'ProfilePage.dart';
import 'package:whiteboard/components/DashboardButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:whiteboard/constant.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LDashboardPage extends StatefulWidget {
  LDashboardPage({@required this.userDetails, this.storage});
  final userDetails;
  final FirebaseStorage storage;
//  static const String id = '/dashboard';
  @override
  _LDashboardPageState createState() => _LDashboardPageState();
}

class _LDashboardPageState extends State<LDashboardPage> {
  Firestore _firestore = Firestore.instance;
  List<Timetable> timetables = [];
  bool done = false;

  getTimetable() {
    try {
      _firestore
          .collection('subject')
          .where('lecturer_id', isEqualTo: widget.userDetails['user_id'])
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
                            style: kLecturerTitleTextStyle,
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
                                  builder: (context) => LAttendancePage(
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
                                  builder: (context) => LGradePage(
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
                                  builder: (context) => LTimetablePage(
                                      userDetails: widget.userDetails)));
                        },
                      ),
                      DashboardButton(
                        title: 'Learning Material',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LLearningMaterialPage(
                                        userDetails: widget.userDetails,
                                        storage: widget.storage,
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
                                  builder: (context) => LSubmissionPage(
                                        userDetails: widget.userDetails,
                                      )));
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
