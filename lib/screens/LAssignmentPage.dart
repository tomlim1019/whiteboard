import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whiteboard/constant.dart';
import 'LAssignmentPage2.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class LAssignmentPage extends StatefulWidget {
  LAssignmentPage(
      {this.userDetails,
      this.subjectDetails,
      this.subjectName,});
  final userDetails, subjectDetails, subjectName;
  @override
  _LAssignmentPageState createState() => _LAssignmentPageState();
}

Firestore _firestore = Firestore.instance;

class _LAssignmentPageState extends State<LAssignmentPage> {
  String submissionName;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: FittedBox(
            child: Text(
              widget.subjectName,
            ),
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
            FlatButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Add new submission'),
                        content: loading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : TextField(
                                autofocus: true,
                                onChanged: (value) {
                                  submissionName = value;
                                },
                                decoration: InputDecoration(
                                    labelText:
                                        'Please enter the name of the submission'),
                              ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text('Add'),
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              await _firestore
                                  .collection('submission')
                                  .document('${widget.subjectDetails}')
                                  .collection('${widget.subjectDetails}')
                                  .add({
                                'name': submissionName,
                              }).catchError((e) {
                                print(e);
                              });
                              Toast.show('submission added!', context);
                              setState(() {
                                loading = false;
                              });
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );
                    });
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: AssignmentStream(
          uid: widget.userDetails,
          subjectCode: widget.subjectDetails,
          subjectName: widget.subjectName,
        ));
  }
}

class AssignmentStream extends StatelessWidget {
  AssignmentStream(
      {@required this.uid, this.subjectCode, this.subjectName});
  final uid;
  final subjectCode, subjectName;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('submission')
          .document('$subjectCode')
          .collection('$subjectCode')
          .orderBy('name', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final assignments = snapshot.data.documents;
        List<AssignmentCards> assignmentCards = [];

        for (var assignment in assignments) {
          final name = assignment.data['name'];
          final documentID = assignment.documentID;

          final assignmentCard = AssignmentCards(
            name: name,
            subjectCode: subjectCode,
            subjectName: subjectName,
            documentID: documentID,
          );
          assignmentCards.add(assignmentCard);
        }
        return ListView(
          children: assignmentCards,
        );
      },
    );
  }
}

class AssignmentCards extends StatelessWidget {
  AssignmentCards(
      {this.name,
      this.subjectCode,
      this.subjectName,
      this.documentID
      });
  final String name, subjectCode, subjectName, documentID;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LAssignmentPage2(
          subjectCode: subjectCode,
          subjectName: subjectName,
          submissionTitle: name,
          documentID: documentID,
        )));
      },
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: kLecturerTitleTextStyle,
          ),
        ),
      ),
    );
  }
}
