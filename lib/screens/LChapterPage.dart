import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whiteboard/constant.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class LChapterPage extends StatefulWidget {
  LChapterPage(
      {this.userDetails, this.subjectDetails, this.subjectName, this.storage});
  final userDetails, subjectDetails, subjectName;
  final FirebaseStorage storage;
  static const String id = '/attendance';
  @override
  _LChapterPageState createState() => _LChapterPageState();
}

Firestore _firestore = Firestore.instance;

class _LChapterPageState extends State<LChapterPage> {
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
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Upload Learning Material'),
                        content: loading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
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
                              if (file != null) {
                                setState(() {
                                  loading = true;
                                });
                                StorageReference ref = widget.storage
                                    .ref()
                                    .child('learning material')
                                    .child('${widget.subjectDetails}')
                                    .child('$fileName');
                                StorageUploadTask task = ref.putFile(file);
                                var link = await (await task.onComplete)
                                    .ref
                                    .getDownloadURL();
                                await _firestore
                                    .collection('learning material')
                                    .document('${widget.subjectDetails}')
                                    .collection('${widget.subjectDetails}')
                                    .add({
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
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: MaterialStream(
          uid: widget.userDetails,
          subjectCode: widget.subjectDetails,
          storage: widget.storage,
        ));
  }
}

class MaterialStream extends StatelessWidget {
  MaterialStream({@required this.uid, this.subjectCode, this.storage});
  final uid;
  final subjectCode;
  final FirebaseStorage storage;
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
            storage: storage,
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
  ChapterCards(
      {this.name, this.subjectCode, this.storage, this.link, this.documentID});
  final String name, subjectCode, link, documentID;
  final FirebaseStorage storage;

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
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  name,
                  style: kLecturerTitleTextStyle,
                ),
              ),
              FlatButton(
                onPressed: () async {
                  StorageReference ref = storage
                      .ref()
                      .child('learning material')
                      .child('$subjectCode')
                      .child('$name');
                  ref.delete();
                  await _firestore
                      .collection('learning material')
                      .document('$subjectCode')
                      .collection('$subjectCode')
                      .document('$documentID')
                      .delete()
                      .catchError((e) {
                    print(e);
                  });
                  Toast.show('file deleted!', context);
                },
                child: Icon(Icons.delete),
              )
            ],
          ),
        ),
      ),
    );
  }
}
