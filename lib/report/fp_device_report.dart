import 'package:flutter/material.dart';

import '../main.dart';
class FPDeviceReport extends StatefulWidget {
  const FPDeviceReport({Key? key}) : super(key: key);

  @override
  State<FPDeviceReport> createState() => _FPDeviceReportState();
}

class _FPDeviceReportState extends State<FPDeviceReport> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "fb_device_report",backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            child: Center(
              child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text("FingerPrint Report", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),
                    SizedBox(height: 20,),
                    Wrap(
                     // mainAxisAlignment:MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Fp Device Name"),
                              SizedBox(
                                width: 200,height: 70,
                                child: TextFormField(style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),


                      ],
                    ),
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
                                              child: Text('FP Id',),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('FP Device Name',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('IP Address',
                                              ),)),

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
