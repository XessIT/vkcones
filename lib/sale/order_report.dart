import 'package:flutter/material.dart';
import 'package:vinayaga_project/main.dart';
class OrderReport extends StatefulWidget {
  const OrderReport({Key? key}) : super(key: key);
  @override
  State<OrderReport> createState() => _OrderReportState();
}
class _OrderReportState extends State<OrderReport> {
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "order_report",backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            child: Center(
              child: Column(
                  children: [
                    SizedBox(height: 50,),
                    Text("Order Report", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),
                    SizedBox(height: 50,),
                    Align(
                      alignment: Alignment.topLeft,
                     // padding: const EdgeInsets.only(right: 100),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(

                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            SizedBox(height: 20,),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Search.."),
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
                            SizedBox(width: 20,),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "From Date",
                                    style: TextStyle(backgroundColor: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 70,
                                    child: TextFormField(style: TextStyle(fontSize: 13),
                                      readOnly: true, // Set the field as read-only
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '* Enter Date';
                                        }
                                        return null;
                                      },
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime(2000), // Set the range of selectable dates
                                          lastDate: DateTime(2100),
                                        ).then((date) {
                                          if (date != null) {
                                            setState(() {
                                              selectedDate = date; // Update the selected date
                                            });
                                          }
                                        });
                                      },
                                      controller: TextEditingController(text: selectedDate.toString().split(' ')[0]), // Set the initial value of the field to the selected date
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: 30,),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "To Date",
                                    style: TextStyle(backgroundColor: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 70,
                                    child: TextFormField(style: TextStyle(fontSize: 13),
                                      readOnly: true, // Set the field as read-only
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '* Enter Date';
                                        }
                                        return null;
                                      },
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime(2000), // Set the range of selectable dates
                                          lastDate: DateTime(2100),
                                        ).then((date) {
                                          if (date != null) {
                                            setState(() {
                                              selectedDate = date; // Update the selected date
                                            });
                                          }
                                        });
                                      },
                                      controller: TextEditingController(text: selectedDate.toString().split(' ')[0]), // Set the initial value of the field to the selected date
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: 40,),
                            //SizedBox(width: 300,),
                            Padding(
                              padding: const EdgeInsets.only(top: 29),
                              child: MaterialButton(
                                color: Colors.green.shade600,
                                height: 40,
                                onPressed: (){},child: Text("Genarate",style: TextStyle(color: Colors.white),),),
                            ),
                          ],
                        ),
                      ),
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
                                  0:FixedColumnWidth(90),
                                  1:FixedColumnWidth(130),
                                  2:FixedColumnWidth(100),
                                  7:FixedColumnWidth(100),
                                  8:FixedColumnWidth(90),
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
                                                  Text('S.no',),
                                                  const SizedBox(height: 8,)
                                                ],
                                              ),)),
                                        //Meeting Name
                                        TableCell(
                                            child:Center(
                                              child: Text('Date',),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Order Number',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Customer Name',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Mobile Number',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Total Quantity',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Sub Total',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Tax Value',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Discount%',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Grant Total',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Action',
                                              ),)),
                                        // TableCell(child: Column(
                                        //   children:  [
                                        //     TableCell(child: Column(
                                        //       children: [
                                        //         Text("Tax Amt"),
                                        //         Divider(color: Colors.black,)
                                        //       ],
                                        //     ),),
                                        //     Row(
                                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //       children: [
                                        //         TableCell(child: Text("Sgst"),),
                                        //         SizedBox(height: 80,
                                        //           child: VerticalDivider(
                                        //             color: Colors.black,
                                        //             thickness: 1,
                                        //           ),
                                        //         ),
                                        //         TableCell(child: Text("Cgst"),),
                                        //         SizedBox(height: 80,
                                        //           child: VerticalDivider(
                                        //             color: Colors.black,
                                        //             thickness: 1,
                                        //           ),
                                        //         ),
                                        //         TableCell(child: Text("Gst"),),
                                        //
                                        //       ],
                                        //     ),
                                        //
                                        //
                                        //   ]
                                        // ))

                                        // Edit
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
                                          child: Text(""),
                                        )
                                        ),


                                        // TableCell(child:Padding(
                                        //   padding: const EdgeInsets.only(left: 0),
                                        //   child: Row(
                                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //     children:  [
                                        //       Text("2"),
                                        //       SizedBox(height: 80,
                                        //         child: VerticalDivider(
                                        //           color: Colors.black,
                                        //           thickness: 1,
                                        //         ),
                                        //       ),
                                        //
                                        //
                                        //
                                        //       Text("2"),
                                        //       SizedBox(height: 80,
                                        //         child: VerticalDivider(
                                        //           color: Colors.black,
                                        //           thickness: 1,
                                        //         ),
                                        //       ),
                                        //       Text("5")
                                        //
                                        //     ],
                                        //   ),
                                        // )
                                        //  ),
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
