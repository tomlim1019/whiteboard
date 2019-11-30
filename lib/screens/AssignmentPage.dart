import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whiteboard/constant.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentPage extends StatefulWidget {
  AssignmentPage(
      {this.userDetails, this.subjectDetails, this.subjectName, this.storage, this.username});
  final userDetails, subjectDetails, subjectName, username;
  final FirebaseStorage storage;
  static const String id = '/attendance';
  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

Firestore _firestore = Firestore.instance;

class _AssignmentPageState extends State<AssignmentPage> {
  String fileName;
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
        ),
        body: AssignmentStream(
          uid: widget.userDetails,
          subjectCode: widget.subjectDetails,
          storage: widget.storage,
          username: widget.username,
        ));
  }
}

class AssignmentStream extends StatelessWidget {
  AssignmentStream({@required this.uid, this.subjectCode, this.storage, this.username});
  final uid;
  final subjectCode, username;
  final FirebaseStorage storage;
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
          final chapterName = assignment.data['name'];
          final link = assignment.data['link'];
          final documentID = assignment.documentID;

          final assignmentCard = AssignmentCards(
            name: chapterName,
            subjectCode: subjectCode,
            storage: storage,
            link: link,
            documentID: documentID,
            username: username,
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

class AssignmentCards extends StatefulWidget {
  AssignmentCards({this.name, this.subjectCode, this.storage, this.link, this.documentID, this.username});
  final String name, subjectCode, link, documentID, username;
  final FirebaseStorage storage;

  @override
  _AssignmentCardsState createState() => _AssignmentCardsState();
}

class _AssignmentCardsState extends State<AssignmentCards> {
  String fileName;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Upload File'),
                content: loading ? Center(child: CircularProgressIndicator(),)
                : TextField(
                  autofocus: true,
                  onChanged: (value) {
                    fileName = value;
                  },
                  decoration: InputDecoration(
                      labelText:
                      'Please enter the name of the file'),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text('Select File'),
                    onPressed: () async {
                      var file =
                      await FilePicker.getFile(type: FileType.ANY);
                      setState(() {
                        loading = true;
                      });
                      if (file != null) {
                        StorageReference ref = widget.storage
                            .ref()
                            .child('assignment')
                            .child('${widget.subjectCode}')
                            .child('$fileName');
                        StorageUploadTask task = ref.putFile(file);
                        var link = await (await task.onComplete)
                            .ref
                            .getDownloadURL();
                        _firestore
                            .collection('submission')
                            .document('${widget.subjectCode}')
                            .collection('${widget.subjectCode}')
                            .document('${widget.documentID}')
                            .collection('${widget.name}')
                            .add({
                          'student_name': widget.username,
                          'name': fileName,
                          'link': link
                        }).catchError((e) {
                          print(e);
                        });
                        Toast.show('file uploaded!', context);
                      } else {
                        Toast.show('Upload failed!', context);
                      }
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
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            widget.name,
            textAlign: TextAlign.center,
            style: kLecturerTitleTextStyle,
          ),
        ),
      ),
    );
  }
}
