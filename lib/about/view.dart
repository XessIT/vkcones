import 'package:flutter/material.dart';

import '../main.dart';
class View extends StatefulWidget {
  const View({Key? key}) : super(key: key);

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "view",backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            child: Column(
                children: [
                  SizedBox(height: 20,),
                  Text("Company Info", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                              border: TableBorder.all(),
                              defaultColumnWidth: const FixedColumnWidth(140.0),
                              columnWidths: const <int, TableColumnWidth>{
                                0:FixedColumnWidth(90),
                                1:FixedColumnWidth(100),
                                2:FixedColumnWidth(100),
                                7:FixedColumnWidth(140),
                              },
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children:[
                                //Table row starting
                                TableRow(
                                    children: [
                                      TableCell(
                                          child:Center(
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 8,),
                                                Text('S. No',),
                                                const SizedBox(height: 8,)
                                              ],
                                            ),)),
                                      //Meeting Name
                                      TableCell(
                                          child:Center(
                                            child: Text('Company Name',),)),
                                      TableCell(
                                          child:Center(
                                            child: Text('Address',
                                            ),)),
                                      TableCell(
                                          child:Center(
                                            child: Text('Contact',
                                            ),)),
                                      TableCell(
                                          child:Center(
                                            child: Text('Mail Id',
                                            ),)),
                                      TableCell(
                                          child:Center(
                                            child: Text('Gst',
                                            ),)),
                                      TableCell(
                                          child:Center(
                                            child: Text('TIN',
                                            ),)),
                                      TableCell(
                                          child:Center(
                                            child: Text('CST',
                                            ),)), TableCell(
                                          child:Center(
                                            child: Text('Action',
                                            ),)),

                                    ]),
                                // Table row end

                                //Table row start
                                TableRow(
                                  // decoration: BoxDecoration(color: Colors.grey[200]),
                                    children: [
                                      // 1 s.no
                                      TableCell(child: Center(child: Column(
                                        children: [
                                          const SizedBox(height: 10,),
                                          Text(""),
                                          const SizedBox(height: 10,)
                                        ],
                                      ))),
                                      TableCell(child: Center(child: Column(
                                        children: [
                                          const SizedBox(height: 10,),
                                          Text(""),
                                          const SizedBox(height: 10,)
                                        ],
                                      ))),

                                      TableCell(child:Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(""),
                                      )
                                      ), TableCell(child:Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(""),
                                      )
                                      ),
                                      TableCell(child:Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(""),
                                      )
                                      ),
                                      TableCell(child:Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(""),
                                      )
                                      ),
                                      TableCell(child:Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(""),
                                      )
                                      ),
                                      TableCell(child:Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(""),
                                      )
                                      ), TableCell(child:Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child:Text(""),
                                      )
                                      ),
                                    ]
                                )
                              ]
                          )
                      ),
                    ),
                  ),
                ]),
          ),
        ) );
  }
}
