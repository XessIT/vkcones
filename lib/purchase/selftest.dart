import 'package:flutter/material.dart';

import '../Attendance/Attendance.dart';
class Self extends StatefulWidget {
  const Self({Key? key}) : super(key: key);
  @override
  State<Self> createState() => _SelfState();
}
class _SelfState extends State<Self> {
  @override
  Widget build(BuildContext context) {
   return MyScaffold(
      route: 'Self',
     body: Container(
       color: Colors.white,
       child: Form(
         child: Table(
           
         ),

       ),

     ),

    );
  }

}