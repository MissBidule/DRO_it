import 'dart:typed_data';
import 'package:droit_app/models/profile_picture.dart';
import 'package:droit_app/models/realm_functions.dart';
import 'package:droit_app/models/firebase_functions.dart';
import 'package:droit_app/models/user.dart';
import 'package:droit_app/widgets/eye_dropper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:hsv_color_pickers/hsv_color_pickers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:droit_app/models/message.dart' as msg;
import 'package:googleapis_auth/auth_io.dart' as oauth;
import 'package:dio/dio.dart' as d;
import 'package:http/src/client.dart' as http_client;

String currentHost = "";
String currentFriend = "";
String currentFriendPushToken = "";

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key, required this.state});

  final ScreenState state;

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

enum Active { rubber, pencil, eyedrop }
enum ScreenState { profile, username, chat }

class _DrawScreenState extends State<DrawScreen> {
  final GlobalKey _keyT = GlobalKey();
  double topBoardRef = 0;
  final GlobalKey _keyB = GlobalKey();
  double bottomBoardRef = 0;

  @override
  void initState() {
    super.initState();
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp
    ]);*/
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.state == ScreenState.chat ? rightSized() : rightPositioned();
    });
  }

  @override
dispose() {
  /*SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);*/
  super.dispose();
}

  final DrawingController _drawingController = DrawingController();
  var _width = 5.0;
  // ignore: unused_field
  Color _color = Colors.red;
  var _active = Active.pencil;
  final _controller = HueController(HSVColor.fromColor(Colors.red));

  @override
  Widget build(BuildContext context) {
    if (widget.state == ScreenState.chat) {
      List <String> users = getCurrentUsers();
      currentHost = users[0];
      currentFriend = users[1];
      FirebaseFirestore.instance
              .collection('user')
              .doc(currentFriend)
              .get()
              .then(
            (DocumentSnapshot doc) {
              User user = User.fromJson(doc.data() as Map<String, dynamic>);
              currentFriendPushToken = user.pushToken;
            },
            onError: (e) => {
              debugPrint("Error getting document: $e")
            });
    }
    else {
      currentHost = getCurrentHost();
    }
    return PopScope(
      canPop:false,
          child: Scaffold(
        backgroundColor: const Color.fromRGBO(236, 234, 255, 1),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.blueAccent[700],
            onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text('Are you sure you want to leave this drawing ?'),
                          content: const Text('Nothing of what you draw will be saved.'),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context, 'Cancel'),
                                  child: Image.asset("assets/images/no.png"),
                                  
                                ),

                                GestureDetector(
                              onTap: () => { 
                                  Navigator.pop(context, 'Ok'),
                                  Navigator.of(context).pop()
                                },
                              child: Image.asset("assets/images/yes.png"),
                            ),
                              ],
                            ),
                            
                          ],
                        ),
                      ),
          ),
          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          title: Row(
            children: <Widget>[
              IconButton(
                  icon: const Icon(CupertinoIcons.trash),
                  onPressed: () =>showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(

                          backgroundColor: Colors.white,
                          title: const Text('Are you sure you want to delete this ?'),
                          content: const Text('Nothing of what you did will be saved.'),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context, 'Cancel'),
                                  child: Image.asset("assets/images/no.png"),
                                  
                                ),

                                GestureDetector(
                              onTap: () => { 
                                  _drawingController.clear(),
                                  Navigator.pop(context, 'Ok')
                                },
                              child: Image.asset("assets/images/yes.png"),
                            ),
                              ],
                            ),
                            
                          ],
                        ),
                      ),),
            ],
          ),
          actions: <Widget>[
            IconButton(
                icon: const Icon(CupertinoIcons.arrow_turn_up_left),
                onPressed: () => _drawingController.undo()),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 30, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: HuePicker(
                      controller: _controller,
                      onChanged: (HSVColor color) {
                        setState(() => _color = color
                            .withSaturation(0.7786885245901639)
                            .withValue(1.0)
                            .toColor());
                        _drawingController.setStyle(color: _color);
                      },
                      thumbShape: HueSliderThumbShape(
                          color: _color,
                          strokeWidth: 3,
                          filled: true,
                          showBorder: true),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                        icon: const Icon(CupertinoIcons.circle_fill),
                        onPressed: () => {
                            setState(() => _color = Colors.black),
                            _drawingController.setStyle(color: _color)
                          })
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                        icon: const Icon(CupertinoIcons.circle),
                        onPressed: () => {
                            setState(() => _color = Colors.white),
                            _drawingController.setStyle(color: _color)
                          }
                  )),
                ],
              ),
            ),
            SizedBox(
              key: _keyT,
              height: widget.state == ScreenState.chat ? 0 : topBoardRef,
            ),
            Expanded(
              child: Center(child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return DrawingBoard(
                    controller: _drawingController,
                    boardPanEnabled: false,
                    boardScaleEnabled: false,
                    background:
                        Container(width: MediaQuery.of(context).size.width, height: drawingBoardSize(), color: Colors.white),
                  );
                },
              )),
            ),
            SizedBox(
              key: _keyB
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 90),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 5,
                    thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 5 + _width * 0.3),
                  ),
                  child: Slider(
                    value: _width,
                    max: 50,
                    min: 1,
                    activeColor: Colors.red,
                    inactiveColor: const Color.fromARGB(255, 74, 69, 80),
                    onChanged: (double v) => {
                      setState(() => _width = v),
                      _drawingController.setStyle(strokeWidth: v)
                    },
                  ),
                ))
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FloatingActionButton(
                heroTag: 'eye-dropper',
                onPressed: () => {
                  EyeDropperWOtext.enableEyeDropper(context, (color) {
                    setState(() {
                      _color = color!;
                      _active = Active.pencil;
                    });
                    _drawingController.setStyle(color: _color);
                    _drawingController.setPaintContent(SimpleLine());
                  }),
                  setState(() {
                    _active = Active.eyedrop;
                  }),
                  _drawingController.setPaintContent(EmptyContent()),
                },
                backgroundColor: _active == Active.eyedrop
                    ? Colors.blue[200]
                    : Colors.yellow[200],
                child: const Icon(CupertinoIcons.eyedropper),
              ),
              FloatingActionButton(
                heroTag: 'select-pencil',
                onPressed: () => {
                  _drawingController.setPaintContent(SimpleLine()),
                  setState(() {
                    _active = Active.pencil;
                  })
                },
                backgroundColor: _active == Active.pencil
                    ? Colors.blue[200]
                    : Colors.yellow[200],
                child: const Icon(Icons.edit),
              ),
              FloatingActionButton(
                heroTag: 'select-eraser',
                onPressed: () => {
                  _drawingController
                      .setPaintContent(Eraser(color: Colors.white)),
                  setState(() {
                    _active = Active.rubber;
                  })
                },
                backgroundColor: _active == Active.rubber
                    ? Colors.blue[200]
                    : Colors.yellow[200],
                child: Image(
                  image: Image.asset("assets/images/rubber.png").image,
                  height: 20,
                  color: const Color.fromARGB(255, 33, 0, 93),
                ),
              ),
              FloatingActionButton(
                heroTag: 'send-image',
                onPressed: () async {
                  Int8List imageInts =
                      (await _drawingController.getImageData())!
                          .buffer
                          .asInt8List();
                  String imageString = imageInts.toString();
                  if (widget.state == ScreenState.profile) {
                    ProfilePicture newPicture = ProfilePicture(
                      image: imageString,
                      user: currentHost,
                      timestamp: Timestamp.now());
                  ppRef.add(newPicture);
                  }
                  else if (widget.state == ScreenState.username) {
                    updateUsernameDrawing(imageString, currentHost);
                  }
                  else {
                    msg.Message newMessage = msg.Message(
                          image: imageString,
                          receiver: currentFriend,
                          sender: currentHost,
                          timestamp: Timestamp.now());
                      messageRef.add(newMessage);
                      updateConversationLastMessage(currentHost, currentFriend);
                      sendPushNotification();
                  }
                  Navigator.of(context).pop(context);
                },
                backgroundColor: Colors.yellow[200],
                child: widget.state == ScreenState.chat ? const Icon( Icons.send) : const Icon( Icons.check),
              ),
            ],
          ),
        )));
  }

  void rightSized() {
    RenderBox box = _keyT.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    double top = position.dy;

    box = _keyB.currentContext!.findRenderObject() as RenderBox;
    position = box.localToGlobal(Offset.zero); //this is global position
    double bottom = position.dy;

    setState(() {
      topBoardRef = top;
      bottomBoardRef = bottom;
    });
  }

  void rightPositioned() {
    final RenderBox box = _keyT.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    double height = widget.state == ScreenState.profile ? (MediaQuery.of(context).size.height/2) - (MediaQuery.of(context).size.width/2) - position.dy : (MediaQuery.of(context).size.height/2) - ((MediaQuery.of(context).size.width*0.332)/2) - position.dy;
    setState(() {
      topBoardRef = height < 0 ? 0 : height;
    });
  }

  double drawingBoardSize() {

    if (widget.state == ScreenState.profile) {
      return MediaQuery.of(context).size.width;
    }
    else if (widget.state == ScreenState.username) {
      return MediaQuery.of(context).size.width*0.332;
    }  
    else {
      return bottomBoardRef - topBoardRef;
    }
  }
  
  void sendPushNotification() async {
    var notification = {
      "title": "DROit",
      "body": "New Message from $currentHost!",
    };
    var serviceAccount = oauth.ServiceAccountCredentials.fromJson(accessConfig);
    http_client.Client client = http_client.Client();
    var accessCredentials =
        await oauth.obtainAccessCredentialsViaServiceAccount(serviceAccount,
            ['https://www.googleapis.com/auth/firebase.messaging'], client);
    var key = accessCredentials.accessToken.data;
    var url =
        "https://fcm.googleapis.com/v1/projects/droit-7920d/messages:send";
    var headers = {
      'Authorization': 'Bearer $key',
      'Content-Type': 'application/json',
    };
    final dio = d.Dio();
    await dio.post(url,
        data: {
          "message": {
            "notification": notification,
            "token": currentFriendPushToken,
            "data": {"sender": currentHost}
          }
        },
        options: d.Options(headers: headers));
    dio.close();
  }
}

Map<String, dynamic> accessConfig = {
  "type": "service_account",
  "project_id": "droit-7920d",
  "private_key_id": "7c9c340555b54cbfbd5d2a3a1f3b210c1828ac3b",
  "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCzqHZn1jj0iCV1\nRudZWmPHWqlEAREaf5xbqPYIHxrwFz9P7fxvNyDDm15ap/Fa3caZZ3Fyf7Xgf2+W\nV6A5/572CkIXc+XXFlVXXswrxvBcWOlcS04p5c3ajE5WHC1VvzJHsYqXKA0f9VqX\nahcwncUVQ9BxOAB/rnlEw/Ls7g6qh7ZUf3K/povI4MHL9830DKhoRsNZ9x2JLols\nUsmRijxdz6ir1OV0lXiMT68jPYFj4cSFWLkF6BLfCgmVqO0oI2xn641KHQIXV5lE\n6xK9skIrtCrTLbP4zVOz4bh0v6PCBUpQzAw9ngTyP4jBWhWD9cEAmOcxIqXMYBV4\noQVQmq9nAgMBAAECggEAL+XTf5aRA7zCg9Rd/KgJHw6wPwWryi1IgfV3dq3YUDda\ndVRlLz962Du1eaT5x3iGKML374dV9Z70IJiHCr94YW9VtIv9NI1rPkpzU56L2YsI\n2EbpdWkjq0cp4XJMseYyIQQYB3mxmhofR2wM97SwZR151p2QIHpjMW6udvV26oam\nn/RSTyoENa74NSrmbPZin2gFMMkSIBL/SlOzw3p/7XFZtxkXm6b8GSAWZNABOsA6\nVDze6gQHcCUXZSbr4Ix4gtyLAah9GYx8ou9Q1tKh9q0VbgCN4VcEZi3gPPV/VIKH\nUo50b6Xet0G+s+7kkvTq+OAx374ij5tkoWDMC4/hsQKBgQDgiGaBX6alDyIbmwaD\n7ne11hhsfzrqjYSUWm0NOMc+uD3i5q6BN9OXM2XV9yEria8V7IxRPfcpTNDq4MFo\nDZ7tetcH3pUWojBComMCTK2nF6Vh4F82SYcjVOYZut7bctiJztcW71Ru8W/GItNx\nBNxbtAcY2cCk2sKDvRshIR9t9wKBgQDM1hVR78Gcowg5SKtRr8UsCaIk4XTXAWuQ\nwqWkGH71HtCLhCEGqy1/+KC28LjQVB8xuMmLzbqx4L93mCVfCCdtkQBczYkYbh6g\nFaC4Bj6x9amON151kbkxce5CTIW9k64vxyb8eAwd/1bzes3QBXCWoHCus78Q8Jcv\nXXQZHc4uEQKBgE+WSa9F9k2/hXl/g9mz517e2p1qo7mMHBhxzQHIxGco61bIKcbH\nwQpxP4GOLYW/Mf51cG9DpZ5QCiWXMTbuzQykZB/396SkLLMR2EJyZ4M40HhXDaiy\ne2I8r6sjH+dtV+/RD1Cj2KvSjKoQoh4HeQxQTcuzM6O7nwMPPtSJZxiVAoGBALUM\nTE/dwJ14JF6tcm+DEp237g73D9SyNqb+xHVkCWMS13VZVe+VAWRpF3RbFJ9emyvR\njqL5Nhje85z7Z5y1klPvpAhiythDDOKl+yZsrqGQ50sCeYUlRjED6HnFNTi4/W7R\ncg4Y9WzWMb6HPr6s8DTSnoZr7WdFn/uHeIRyqbhhAoGBALLVZrov+b9MmLUlSlJg\nxtApSTI+lRphytWvsjOE+CuvwIEztavFtqXdJ8EdrRGfbJJFiHGxkneCoXDJqITw\nfZkH3CKB8xAl3uLCJPTlmono5nkrX8YH1W8ZlrwRo8nPsFn68PJX75SHBVogsgid\nJEizv1aaI+gowDv1gNQ/hAmY\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-s63wn@droit-7920d.iam.gserviceaccount.com",
  "client_id": "102564637310972403059",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-s63wn%40droit-7920d.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};