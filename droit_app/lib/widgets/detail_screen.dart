import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// detail screen of the image, display when tap on the image bubble
class DetailScreen extends StatefulWidget {
  final String tag;
  final Widget image;

  const DetailScreen({super.key, required this.tag, required this.image});

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
      backgroundColor: Colors.black,
        body: Stack(
          children: [ 
            Center(
              child: Hero(
                tag: widget.tag,
                child: widget.image,
              ),
            ),
            Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 60, 30, 0),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(40),
                        ),
                        color: Color(0xff222222),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.clear,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ]
      ),),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}


