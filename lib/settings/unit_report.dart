import 'package:flutter/material.dart';

import '../main.dart';
class Unit_Report extends StatefulWidget {
  const Unit_Report({Key? key}) : super(key: key);

  @override
  State<Unit_Report> createState() => _SizeReportState();
}

class _SizeReportState extends State<Unit_Report> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "unit_entry",backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            child: Center(
              child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text("Unit Report", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),

                    SizedBox(height: 50,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                                border: TableBorder.all(),
                                defaultColumnWidth: const FixedColumnWidth(140.0),
                                columnWidths: const <int, TableColumnWidth>{
                                  0: FixedColumnWidth(300),

                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children:[
                                  //Table row starting
                                  TableRow(
                                      children: [
                                        TableCell(
                                          child: Center(
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 8),
                                                Text('Item Unit'),
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          ),
                                        ),

                                        //Meeting Name

                                        TableCell(
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



                                        TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(""),
                                        )
                                        ),
                                        TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child:Column(
                                            children: [
                                              SizedBox(height: 5,),
                                              Row(
                                                children: [
                                                  SizedBox(width: 45,height: 28,
                                                    child: MaterialButton(

                                                      color: Colors.green.shade600,
                                                      onPressed: (){},child:Icon(Icons.edit_note,color: Colors.white,),),
                                                  ),
                                                  const SizedBox(width: 5,),
                                                  SizedBox(width: 45,height: 28,
                                                    child: MaterialButton(
                                                      color: Colors.red.shade600,
                                                      onPressed: (){},child:Icon(Icons.delete,color: Colors.white,),),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5,),

                                            ],
                                          ),
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
          ),
        ) );
  }
}
