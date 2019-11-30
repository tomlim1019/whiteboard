import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whiteboard/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class ChapterPage extends StatefulWidget {
  ChapterPage(
      {this.userDetails, this.subjectDetails, this.subjectName});
  final userDetails, subjectDetails, subjectName;
  static const String id = '/attendance';
  @override
  _ChapterPageState createState() => _ChapterPageState();
}

Firestore _firestore = Firestore.instance;

class _ChapterPageState extends State<ChapterPage> {
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
        body: MaterialStream(
          uid: widget.userDetails,
          subjectCode: widget.subjectDetails,
        ));
  }
}

class MaterialStream extends StatelessWidget {
  MaterialStream({@required this.uid, this.subjectCode});
  final uid;
  final subjectCode;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('learning material')
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
        final chapters = snapshot.data.documents;
        List<ChapterCards> chapterCards = [];

        for (var chapter in chapters) {
          final chapterName = chapter.data['name'];
          final link = chapter.data['link'];
          final documentID = chapter.documentID;

          final chapterCard = ChapterCards(
            name: chapterName,
            subjectCode: subjectCode,
            link: link,
            documentID: documentID,
          );
          chapterCards.add(chapterCard);
        }
        return ListView(
          children: chapterCards,
        );
      },
    );
  }
}

class ChapterCards extends StatelessWidget {
  ChapterCards({this.name, this.subjectCode, this.link, this.documentID});
  final String name, subjectCode, link, documentID;

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
          ),
        ),
      ),
    );
  }
}
