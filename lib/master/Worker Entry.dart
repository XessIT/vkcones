import 'package:flutter/material.dart';
import 'package:vinayaga_project/home.dart';
import 'package:vinayaga_project/main.dart';
import 'package:vinayaga_project/master/tabcontroller.dart';
import 'package:vinayaga_project/master/with_printing.dart';

import 'Other_Worker.dart';


class WorkerEntry extends StatefulWidget {
  const WorkerEntry({Key? key}) : super(key: key);

  @override
  State<WorkerEntry> createState() => _WorkerEntryState();
}

class _WorkerEntryState extends State<WorkerEntry> {
  // Function to show the alert dialog
  Color? hoverColor;

  Future<void> _showAlertDialog() async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select an option'),
          content: Container(
            width: 200.0, // Adjust the width as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton(
                  onPressed: () {},
                  child: ListTile(
                    title: GestureDetector(
                      onTap: () {
                        // Handle text click, you can navigate or perform any action here
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WithPrinting()));
                      },
                      child: Text(
                        'With Printing',
                        style: TextStyle(
                          color: hoverColor,
                        ),
                      ),
                    ),
                  ),
                ),
                /// WITH PRINTING
                TextButton
                  (
                  onPressed: () {  },
                  child: ListTile(
                    title: GestureDetector(

                      onTap: () {
                        // Handle text click, you can navigate or perform any action here
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerTab()));
                      },
                      child: Text('Without Printing'),
                    ),
                  ),
                ), /// WITHOUT PRINTING
                TextButton
                  (
                  onPressed: () {  },
                  child: ListTile(
                    title: GestureDetector(
                      onTap: () {
                        // Handle text click, you can navigate or perform any action here
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Other_worker()));
                      },
                      child: Text('Others'),
                    ),
                  ),
                ), /// OTHERS

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Home())); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _showAlertDialog(); // Show the alert dialog after the frame is drawn
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      route: "worker_entry",
      body: Container(), // Adjust this as needed
    );
  }
}




