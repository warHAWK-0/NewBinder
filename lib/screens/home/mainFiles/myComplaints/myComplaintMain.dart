import 'dart:async';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Binder/models/complaint.dart';
import 'package:Binder/models/user_data.dart';
import 'package:Binder/screens/home/mainFiles/myComplaints/addcomplaint.dart';
import 'package:Binder/shared/CustomAppBar.dart';
import 'package:Binder/shared/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'CustomComplaintCard.dart';

// ignore: camel_case_types
class myComplaints extends StatefulWidget {
  final UserDetails userDetails;
  const myComplaints({Key key, this.userDetails}) : super(key: key);
  @override
  _myComplaintsState createState() => _myComplaintsState();
}

// ignore: camel_case_types
class _myComplaintsState extends State<myComplaints> {
  bool hasComplaint = false;
  Future<bool> _onbackpressed() {
    return Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you Sure?",
      desc: "Do you want to exit the App?",
      buttons: [
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => exit(0),
          color: Color(0xFF1467B3),
        ),
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Color(0xFF1467B3), fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        )
      ],
    ).show();
  }

  StreamController<List<DocumentSnapshot>> _streamController =
  StreamController<List<DocumentSnapshot>>();
  List<DocumentSnapshot> myComplaints = [];
  bool _isRequesting = false;
  bool _isFinish = false;
  @override
  void initState() {
    Firestore.instance
        .collection("complaint")
        .document(widget.userDetails.department == "production"
        ? "complaintRaised"
        : "complaintAssigned")
        .collection(widget.userDetails.uid)
        .orderBy("startDate", descending: true)
        .snapshots()
        .listen((data) => onChangeData(data.documentChanges));
    requestNextPage();
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void onChangeData(List<DocumentChange> documentChanges) {
    var isChange = false;
    documentChanges.forEach((productChange) {
      if (productChange.type == DocumentChangeType.removed) {
        myComplaints.removeWhere((product) {
          return productChange.document.documentID == product.documentID;
        });
        isChange = true;
      } else {
        if (productChange.type == DocumentChangeType.modified) {
          int indexWhere = myComplaints.indexWhere((product) {
            return productChange.document.documentID == product.documentID;
          });

          if (indexWhere >= 0) {
            myComplaints[indexWhere] = productChange.document;
          }
          isChange = true;
        }
      }
    });

    if (isChange) {
      _streamController.add(myComplaints);
    }
  }

  void requestNextPage() async {
    if (!_isRequesting && !_isFinish) {
      QuerySnapshot querySnapshot;
      _isRequesting = true;
      if (myComplaints.isEmpty) {
        querySnapshot = await Firestore.instance
            .collection("complaint")
            .document(widget.userDetails.department == "production"
            ? "complaintRaised"
            : "complaintAssigned")
            .collection(widget.userDetails.uid)
            .orderBy("startDate", descending: true)
            .limit(7)
            .getDocuments();
      } else {
        querySnapshot = await Firestore.instance
            .collection("complaint")
            .document(widget.userDetails.department == "production"
            ? "complaintRaised"
            : "complaintAssigned")
            .collection(widget.userDetails.uid)
            .orderBy("startDate", descending: true)
            .limit(7)
            .getDocuments();
      }
      if (querySnapshot != null) {
        int oldSize = myComplaints.length;
        myComplaints.addAll(querySnapshot.documents);
        int newSize = myComplaints.length;
        if (oldSize != newSize) {
          _streamController.add(myComplaints);
        } else {
          _isFinish = true;
        }
      }
      _isRequesting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onbackpressed,
      child: Scaffold(
        //backgroundColor: Color(0xFFE5E5E5),
        appBar: CustomAppBar(
            backIcon: false,
            child: Text(
              'My Complaints',
              style: titleText,
            )),
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.maxScrollExtent ==
                scrollInfo.metrics.pixels) {
              requestNextPage();
            }
            return true;
          },
          child: Stack(
            children: <Widget>[
              new Container(
                  padding: EdgeInsets.only(top: 25),
                  child: StreamBuilder<List<DocumentSnapshot>>(
                      stream: _streamController.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                        return !snapshot.hasData
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height:
                              MediaQuery.of(context).size.height / 25,
                            ),
                            Container(
                              margin: EdgeInsets.all(20),
                              child: SpinKitFadingCircle(
                                size: 60,
                                color: primaryblue,
                              ),
                            ),
                            Text(
                              'Looking for complaints...',
                              style: TextStyle(
                                color: primaryblue,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        )
                            : ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (_, index) {
                            return snapshot.data[index]['status'] !=
                                "finsished"
                                ? CustomComplaintCard(
                              userDetails: widget.userDetails,
                              complaint: Complaint(
                                complaintId: snapshot.data[index]['complaintId'],
                                assignedDate: snapshot.data[index]
                                ['assignedDate'],
                                assignedTime: snapshot.data[index]
                                ['assignedTime'],
                                assignedTo: snapshot.data[index]
                                ['assignedTo'],
                                assignedToUid: snapshot.data[index]
                                ['assignedToUid'],
                                assignedBy: snapshot.data[index]
                                ['assignedBy'],
                                mobileNo: snapshot.data[index]
                                ['mobileNo'],
                                department: snapshot.data[index]
                                ['department'],
                                endDate: snapshot.data[index]
                                ['endDate'],
                                endTime: snapshot.data[index]
                                ['endDate'],
                                issue: snapshot.data[index]
                                ['issue'],
                                lineNo: snapshot.data[index]
                                ['lineNo'],
                                machineNo: snapshot.data[index]
                                ['machineNo'],
                                raisedBy: snapshot.data[index]
                                ['raisedBy'],
                                startDate: snapshot.data[index]
                                ['startDate'],
                                startTime: snapshot.data[index]
                                ['startTime'],
                                status: snapshot.data[index]
                                ['status'],
                                raisedByUid: snapshot.data[index]
                                ['raisedByUid'],
                                typeofIssue: snapshot.data[index]
                                ['typeofIssue'],
                                verifiedDate: snapshot.data[index]
                                ['verifiedDate'],
                                verifiedTime: snapshot.data[index]
                                ['verifiedTime'],
                              ),
                            )
                                : Container();
                          },
                        );
                      })),
            ],
          ),
        ),

        floatingActionButton: (widget.userDetails.department == "production")
            ? FloatingActionButton(
            backgroundColor: primaryblue,
            child: Icon(
              Icons.add,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => addComplaint(
                        userDetails: widget.userDetails,
                      )));
            })
            : null,
      ),
    );
  }
}
