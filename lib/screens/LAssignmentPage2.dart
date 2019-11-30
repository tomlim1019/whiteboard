import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whiteboard/constant.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class LAssignmentPage2 extends StatefulWidget {
  LAssignmentPage2(
      {this.subjectCode, this.subjectName, this.submissionTitle, this.documentID});
  final subjectCode, subjectName, submissionTitle, documentID;
  @override
  _LAssignmentPage2State createState() => _LAssignmentPage2State();
}

Firestore _firestore = Firestore.instance;

class _LAssignmentPage2State extends State<LAssignmentPage2> {
  String submissionName;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: FittedBox(
            child: Text(
              '${widget.submissionTitle} - ${widget.subjectName}',
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
        body: SubmissionStream(
          subjectCode: widget.subjectCode,
          submission: widget.submissionTitle,
          documentID: widget.documentID,
        ));
  }
}

class SubmissionStream extends StatelessWidget {
  SubmissionStream(
      {this.subjectCode, this.submission, this.documentID});
  final subjectCode, submission, documentID;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('submission')
          .document('$subjectCode')
          .collection('$subjectCode')
          .document('$documentID')
          .collection('$submission')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final submissions = snapshot.data.documents;
        List<SubmissionCards> submissionCards = [];

        for (var submission in submissions) {
          final studentName = submission.data['student_name'];
          final link = submission.data['link'];

          final submissionCard = SubmissionCards(
            name: studentName,
            link: link,
          );
          submissionCards.add(submissionCard);
        }
        return ListView(
          children: submissionCards,
        );
      },
    );
  }
}

class SubmissionCards extends StatelessWidget {
  SubmissionCards(
      {this.name,
        this.link,});
  final String name, link;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(link)) {
          await launch(link);
        } else {
          throw 'Could not launch $link';
        }
      },
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: kLecturerTitleTextStyle,
          )
        ),
      ),
    );
  }
}
