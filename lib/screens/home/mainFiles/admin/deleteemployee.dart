import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_binder/models/user_Info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../shared/CustomAppBar.dart';
import '../../../../shared/themes.dart';
import 'invalidPersonalNo.dart';

class DeleteEmployee extends StatefulWidget {
  @override
  _DeleteEmployeeState createState() => _DeleteEmployeeState();
}

class _DeleteEmployeeState extends State<DeleteEmployee> {
  String userID="";
  List<user_Info> allData = [];
  void fetchDepartmentComplaints() async {

    final QuerySnapshot usersList =
    await Firestore.instance.collection('binder').getDocuments();
    final List<DocumentSnapshot> docUsers = usersList.documents;
    allData.clear();
    for (DocumentSnapshot docUser in docUsers) {
      String uidUser = docUser.documentID;
      print(uidUser);
      final QuerySnapshot userComplaints = await Firestore.instance
          .collection('binder')
          .document(uidUser)
          .collection('user_details')
          .getDocuments();
      final List<DocumentSnapshot> docComplaints = userComplaints.documents;
      for (DocumentSnapshot docComplaint in docComplaints) {
        print(docComplaint.documentID + " => " );
        if (PID == docComplaint.data['personalId']) {
          print(PID); print(docComplaint.data['personalId']);
          userID= uidUser;
          user_Info d = new user_Info(
              docComplaint.data['name'],
              docComplaint.data['department'],
              docComplaint.data['designation'],
              docComplaint.data['mobileNo'],
              docComplaint.data['email'],
              docComplaint.data['personalId'],
              docComplaint.data['blockNo'],
              docComplaint.documentID);
          allData.add(d);
        }
      }
    }
    setState(() {
      print(allData.length);
    });
  }


  String PID = "";
  bool showDetailsContainer = false;
  bool detailsFound = false;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'EditEmployeeAdmin',
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: CustomAppBar(
          child: Text(
            'Delete an employee',
            style: titleText,
          ),
          backIcon: true,
          elevation: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter Personal No.",
                      hintStyle: TextStyle(color: Color(0xFF1467B3)),
                      filled: true,
                      fillColor: Color.fromRGBO(20, 103, 179, 0.05),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(93, 153, 252, 100)),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:
                              Color.fromRGBO(223, 232, 247, 100)) //dfe8f7
                      ),
                    ),
                    onChanged: (String text){
                      PID = text;
                    },
                    onSubmitted: (String text){
                      PID = text;
                      // getter method to get details of the PID
                      // and turn details found FLAG to true
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: FlatButton(
                      color: Color(0xFF1467B3),
                      textColor: Colors.white,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Colors.blueAccent,
                      onPressed: () {
                        fetchDepartmentComplaints();
                        if(allData.length==1) {
                          setState(() {
                            showDetailsContainer=true;
                            detailsFound=true;
                          });
                        }
//                        setState(() {
//                          showDetailsContainer = true;
//                          if(PID == "pid1"){
//                            detailsFound = true;
//                          }
//                          else{
//                            detailsFound = false;
//                          }
//                        });
                      },
                      child: Text(
                        "Get Details",
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                  ),
                  showDetailsContainer == true ? Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    child: detailsFound == false ? Container(
                      height: 100,
                      child: Stack(
                        children: <Widget>[
                          Align(
                            child: Container(
                              child: Image.asset(
                                  'assets/images/InvalidPersonalNo.png',
                                  height: 50,
                                  fit: BoxFit.cover),
                            ),
                            alignment: Alignment.center,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              child: Text(
                                "Invalid Personal No",
                                style: TextStyle(
                                    fontSize: 15.0, color: primaryblue),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ) : Container(
                      child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          /**/
                        },
                        child: Container(
                          height: 250,
                          margin:
                          EdgeInsets.only(top: 10, left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            //padding: EdgeInsets.only(left: 5, top: 10),
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("Name:                 "+ allData[0].name,
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Color(0xFF1467B3),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("Personal No:      "+allData[0].personal_no,
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Color(0xFF1467B3),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("Block No:            "+allData[0].block_no,
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Color(0xFF1467B3),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("Department:       "+allData[0].department,
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Color(0xFF1467B3),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("Designation:       "+(allData[0].designation.toString()=="0"? "Operator":
                                allData[0].designation.toString()=="0"? "Production":
                                allData[0].designation.toString()=="0"? " Admin": "Null"),
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Color(0xFF1467B3),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("Phone Number: "+allData[0].phone_no,
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Color(0xFF1467B3),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Text("Email ID:              "+allData[0].email,
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Color(0xFF1467B3),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: FlatButton(
                                  color: Color(0xFF1467B3),
                                  textColor: Colors.white,
                                  disabledColor: Colors.grey,
                                  disabledTextColor: Colors.black,
                                  padding: EdgeInsets.all(8.0),
                                  splashColor: Colors.blueAccent,
                                  onPressed: () {
//                                    Navigator.push(
//                                      context,
//                                      MaterialPageRoute(
//                                          builder: (context) => EditEmpProfile(userID:userID,allData: allData,)),
//                                    );
                                  },
                                  child: Text(
                                    "Delete Employee",
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ) : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
