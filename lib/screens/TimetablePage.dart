import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whiteboard/constant.dart';

class TimetablePage extends StatefulWidget {
  TimetablePage({@required this.userDetails});
  final userDetails;
  static const String id = '/timetable';
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  Firestore _firestore = Firestore.instance;
  Map<String, List<TimetableCard>> timetables = {
    "Monday": [],
    "Tuesday": [],
    "Wednesday": [],
    "Thursday": [],
    "Friday": []
  };
  bool done = false;

  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  getTimetable() {
    try {
      _firestore
          .collection('subject')
          .where('student_code', arrayContains: widget.userDetails['user_id'])
          .snapshots()
          .listen((subjects) {
        for (var subject in subjects.documents) {
          var i = 0;
          while (i < 5) {
            if (subject['lab_class'] != null &&
                subject['lab_class'] == days[i]) {
              final labTimetable = TimetableCard(
                  subject['lecturer_name'],
                  subject['subject_name'],
                  subject['lab_time'],
                  subject['lab_venue'],
                  subject['subject_code']);
              timetables[days[i]].add(labTimetable);
            }
            if (subject['lecture_class'] != null &&
                subject['lecture_class'] == days[i]) {
              final lectureTimetable = TimetableCard(
                  subject['lecturer_name'],
                  subject['subject_name'],
                  subject['lecture_time'],
                  subject['lecture_venue'],
                  subject['subject_code']);
              timetables[days[i]].add(lectureTimetable);
            }
            i++;
          }
        }
        for (int i = 0; i < 5; i++) {
          if (timetables[days[i]].length == 0) {
            timetables[days[i]]
                .add(TimetableCard("", "No class today!", "", "", ""));
          }
          else sort(timetables[days[i]],i);
        }
//        sort(timetables);
        setState(() {
          done = true;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void sort(var timetable, int k) {
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
          var temp2 = timetables[days[k]][j];
          timetables[days[k]][j] = timetables[days[k]][j + 1];
          timetables[days[k]][j + 1] = temp2;
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
      backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Timetable',
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
        body: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, i) {
              return Card(
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: done
                        ? Column(
                            children: <Widget>[
                              Text(days[i], style: TextStyle(color: Colors.black),),
                              Column(
                                children: timetables[days[i]],
                              )
                            ],
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          )),
              );
            }));
  }
}

class TimetableCard extends StatelessWidget {
  TimetableCard(this.lecturerName, this.subjectName, this.time, this.venue,
      this.subjectCode);

  final String subjectCode, subjectName, lecturerName, time, venue;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('$subjectCode $subjectName', style: kLecturerTitleTextStyle,),
            SizedBox(
              height: 10,
            ),
            Text(lecturerName, style: kLecturerNameTextStyle,),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Card(
                    color: Color(0xFF607D8B),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: <Widget>[
                          Text('Time'),
                          Text(time),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Color(0xFF607D8B),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: <Widget>[
                          Text('Venue'),
                          Text(venue),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    ),
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
