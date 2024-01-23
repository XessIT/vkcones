import 'package:flutter/material.dart';

import '../main.dart';
class ColoursEntry extends StatefulWidget {
  const ColoursEntry({Key? key}) : super(key: key);

  @override
  State<ColoursEntry> createState() => _ColoursEntryState();
}

class _ColoursEntryState extends State<ColoursEntry> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "color_entry",
        body: SingleChildScrollView(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text("Colour Creation", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Item Colour"),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height:20 ,),

                    Row(
                      children: [
                        MaterialButton(
                          color:Colors.green,onPressed: (){},child: Text("Submit",style: TextStyle(color: Colors.white),),),
                        SizedBox(width: 15,),
                        MaterialButton(
                          color:Colors.blue,onPressed: (){},child: Text("View",style: TextStyle(color: Colors.white),),),
                        SizedBox(width: 15,),


                        MaterialButton(
                          color:Colors.red,onPressed: (){},child: Text("Reset",style: TextStyle(color: Colors.white),),),


                      ],
                    ),
                  ]),
            ),
          ),
        ) );
  }
}
