
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/purchase_report.dart';

class
purchaseView extends StatefulWidget {
  String? invoiceNo;
  String? date;
  int supMobile;
  String? supName;
  String? supCode;
  String? supAddress;
  String? pincode;
  String? payType;


  purchaseView({Key? key, required this.invoiceNo,
    required this.date,
    required this.supCode,
    required this.supMobile,
    required this.supName,
    required this.supAddress,
    required this.pincode,
    required this.payType, required amtGST, required total, required qty, required prodName, required rate, required prodCode,
  }) : super(key: key);

  //purchaseView({Key? key,required this.poNo, required this.date}) : super(key: key);

  @override
  State<purchaseView> createState() => _purchaseViewState();
}

class _purchaseViewState extends State<purchaseView> {

  String? callinvoiceNo="";
  double totalReturnAmount = 0.0;
  double totalSalesAmount = 0.0;

  Future<List<Map<String, dynamic>>> fetchreturnreport(String invoiceNo) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/purchase_returnview?invoiceNo=$invoiceNo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }




  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invoiceNo) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/purchase_view?invoiceNo=$invoiceNo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }
  DateTime selectedDate = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController poNo = TextEditingController();
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  bool showInitialData = true;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (showInitialData) {
      filterData('');
    }
  }
  List<Map<String, dynamic>> filteredCodeData = [];
  void filterData(String searchText) {
    setState(() {
      filteredData = [];
      if (searchText.isNotEmpty) {
        filteredData = data.where((item) {
          String id = item['invoiceNo']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['invoiceNo']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
        }
      }});
  }





  @override
  Widget build(BuildContext context) {
    DateTime Date = DateTime.now();
    final formattedDate = DateFormat("dd-MM-yyyy").format(Date);
    return  MyScaffold(
        route: "purchase view",backgroundColor: Colors.white,
        body: Form(
            key: _formKey,
            child:SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 2,),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          width: double.infinity, // Set the width to full page width
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            // gradient: LinearGradient(
                            //   colors: [Colors.blue.shade50, Colors.blue.shade200], // Gradient colors
                            //   begin: Alignment.topLeft, // Gradient start point
                            //   end: Alignment.bottomRight, // Gradient end point
                            // ),
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey), // Add a border for the box
                            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                          ),
                          child:  Column(
                            children: [
                              Wrap(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.shopping_cart, // Replace with the icon you want to use
                                              // Replace with the desired icon color
                                            ),
                                            const Text("  Purchase Report ", style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20
                                            ),)
                                          ],
                                        ),
                                        SizedBox(
                                          width: 95,
                                          child: Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child://Text("2023/09/09")
                                                  Text(widget.date.toString() != null ? DateFormat("dd-MM-yyyy").format(DateTime.parse("${widget.date}")):"", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                                                ),
                                                Divider(
                                                  color: Colors.grey.shade600,
                                                ),
                                                const Align(
                                                    alignment: Alignment.topLeft,
                                                    child:
                                                    Text("Invoice Number",style: TextStyle(fontWeight: FontWeight.bold),)),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child://Text("009"),
                                                  Text(widget.invoiceNo.toString(),style: TextStyle(
                                                      color: Colors.black
                                                  ),),
                                                )],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                              ),
                            ],
                          ),

                        ),
                      ),
                    ),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          child: Container(
                            child: Column(
                              children: [
                                Wrap(
                                    children: [
                                      SizedBox(height: 20,),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          width: double.infinity, // Set the width to full page width
                                          padding: EdgeInsets.all(16.0), // Add padding for spacing
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            border: Border.all(color: Colors.grey), // Add a border for the box
                                            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                                          ),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment:Alignment.topLeft,
                                                child:Padding(
                                                  padding: const EdgeInsets.only(left:10,top: 10,bottom: 10),
                                                  child: Text(" Supplier Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(height: 10,),

                                              Padding(
                                                padding: const EdgeInsets.only(left:10),
                                                child: Wrap(
                                                  spacing: 36.0, // Set the horizontal spacing between the children
                                                  runSpacing: 20.0,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 200,
                                                        height: 30,
                                                        child: TextFormField(
                                                          readOnly: true,
                                                          initialValue: widget.supCode,
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                          keyboardType: TextInputType.text,
                                                          decoration: InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              labelText: "Supplier Code",
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(8,),
                                                              )
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width:11,height:20),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 200,
                                                        height: 30,
                                                        child: TextFormField(
                                                          readOnly: true,
                                                          initialValue: widget.supName,
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                          keyboardType: TextInputType.text,
                                                          decoration: InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              labelText: "Supplier Name",
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(8,),
                                                              )
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width:11),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 200,
                                                        height: 30,
                                                        child: TextFormField(
                                                          readOnly: true,
                                                          initialValue: widget.supAddress,
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                          keyboardType: TextInputType.text,
                                                          decoration: InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              labelText: "Supplier Address",
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(8,),
                                                              )
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width:11),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 200,
                                                        height: 30,
                                                        child: TextFormField(
                                                          initialValue: widget.pincode,
                                                          readOnly: true,
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                          keyboardType: TextInputType.text,
                                                          decoration: InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              labelText: "Pincode",
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(8,),
                                                              )
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width:11),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 200,
                                                        height: 30,
                                                        child: TextFormField(
                                                          readOnly: true,
                                                          initialValue: widget.supMobile.toString(),
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                          keyboardType: TextInputType.text,
                                                          decoration: InputDecoration(
                                                              prefixText: "+91",
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              labelText: "Supplier Mobile",
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(8,),
                                                              )
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width:11),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 200,
                                                        height: 30,
                                                        child: TextFormField(
                                                          readOnly: true,
                                                          initialValue: widget.payType,
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                          keyboardType: TextInputType.text,
                                                          decoration: InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              labelText: "Payment Type",
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(8,),
                                                              )
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Align(
                                                  alignment:Alignment.topLeft,
                                                  child:Padding(
                                                    padding: const EdgeInsets.only(left:14),
                                                    child: Text("Purchase Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                                    future: fetchUnitEntries(widget.invoiceNo.toString()),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return Center(child: CircularProgressIndicator());
                                                      } else if (snapshot.hasError) {

                                                        return Center(child: Text('Error: ${snapshot.error}'));
                                                      } else {
                                                        return Table(
                                                          defaultColumnWidth: const FixedColumnWidth(
                                                              600),
                                                          columnWidths: const <
                                                              int,
                                                              TableColumnWidth>{
                                                            0: FixedColumnWidth(60),
                                                            1: FixedColumnWidth(
                                                                80),
                                                            2: FixedColumnWidth(
                                                                200),
                                                            3: FixedColumnWidth(
                                                                80),
                                                            // Adjust the width of the second column
                                                            4: FixedColumnWidth(
                                                                80),
                                                            5: FixedColumnWidth(
                                                                80),
                                                            6: FixedColumnWidth(
                                                                100),
                                                            7: FixedColumnWidth(
                                                                70),
                                                            8: FixedColumnWidth(
                                                                100),
                                                            // Adjust the width of the second column
                                                          },
                                                          border: TableBorder
                                                              .all(color: Colors
                                                              .black),
                                                          children: [
                                                            TableRow(
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .blue
                                                                    .shade300,
                                                              ),
                                                              children: const [
                                                                Center(
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                      'S.No',
                                                                      style: TextStyle(
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                        'Product Code',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black)),
                                                                  ),
                                                                ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                        'Product Name',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black)),
                                                                  ),
                                                                ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                        'Unit',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black)),
                                                                  ),
                                                                ),
                                                                /* Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                ),*/

                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                        'Rate',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black)),
                                                                  ),
                                                                ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                        'Quantity',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black)),
                                                                  ),
                                                                ),

                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                        'Amount',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black)),
                                                                  ),
                                                                ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                        'GST',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black)),
                                                                  ),
                                                                ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(8.0),
                                                                    child: Text(
                                                                        'Total',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            for (var entry in snapshot
                                                                .data!
                                                                .asMap()
                                                                .entries)
                                                              TableRow(
                                                                children: [
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center
                                                                        (child: Text((entry.key + 1).toString())),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Center(
                                                                          child: Text(
                                                                              entry
                                                                                  .value['prodCode'])),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Center(
                                                                          child: Text(
                                                                              entry
                                                                                  .value['prodName'])),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Center(
                                                                          child: Text(
                                                                              entry
                                                                                  .value['unit'])),
                                                                    ),
                                                                  ),
                                                                  /* TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(child: Text(entry.value['totalWeight'])),
                                                                    ),
                                                                  ),*/
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Center(
                                                                          child: Text(
                                                                              entry
                                                                                  .value['rate']
                                                                                  .toString())),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Center(
                                                                          child: Text(
                                                                              entry
                                                                                  .value['qty']
                                                                                  .toString())),
                                                                    ),
                                                                  ),

                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Center(
                                                                          child: Align(
                                                                              alignment: Alignment
                                                                                  .topRight,
                                                                              child: Text(
                                                                                  entry
                                                                                      .value['amt']
                                                                                      .toString())
                                                                          )
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Center(
                                                                          child: Align(
                                                                              alignment: Alignment
                                                                                  .topRight,
                                                                              child: Text(
                                                                                  entry
                                                                                      .value['amtGST']
                                                                                      .toString()))),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Center(
                                                                          child: Align(
                                                                              alignment: Alignment
                                                                                  .topRight,
                                                                              child: Text(
                                                                                  entry
                                                                                      .value['total']
                                                                                      .toString()))),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                          ],
                                                        );
                                                        /*else {
                                                        return Center(
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                '',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }*/
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              FutureBuilder<List<Map<String, dynamic>>>(
                                                future: fetchUnitEntries(widget.invoiceNo!),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return Center(child: CircularProgressIndicator());
                                                  } else if (snapshot.hasError) {
                                                    return Center(child: Text('Error: ${snapshot.error}'));
                                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                                    return Center(child: Text('No data available.'));
                                                  } else {
                                                    final purchaseTotal = snapshot.data![0]["grandTotal"].toString(); // Assuming "grandTotal" is a key in the map

                                                    return Column(
                                                      children: [
                                                       /* Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Text("Purchase Total: ${purchaseTotal}", style: TextStyle(fontWeight: FontWeight.bold)),
                                                            SizedBox(
                                                                width:20,
                                                                child: Text("   ")),

                                                          ],
                                                        ),*/
                                                      ],
                                                    );
                                                  }
                                                },
                                              ),


                                              SizedBox(height: 10,),
                                              Align(
                                                alignment:Alignment.topLeft,
                                                child:Padding(
                                                  padding: const EdgeInsets.only(left:14),
                                                  child: Text("Return Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child:
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                                    future: fetchreturnreport(widget.invoiceNo.toString()),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return Center(child: CircularProgressIndicator());
                                                      } else if (snapshot.hasError) {

                                                        return Center(child: Text('Error: ${snapshot.error}'));
                                                      } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                                        return Container(
                                                          padding: EdgeInsets.all(16.0),
                                                          child: Table(
                                                            defaultColumnWidth: const FixedColumnWidth(600),
                                                            columnWidths: const <int, TableColumnWidth>{
                                                              0: FixedColumnWidth(60),
                                                              1: FixedColumnWidth(
                                                                  80),
                                                              2: FixedColumnWidth(
                                                                  200),
                                                              3: FixedColumnWidth(
                                                                  80),
                                                              // Adjust the width of the second column
                                                              4: FixedColumnWidth(
                                                                  80),
                                                              5: FixedColumnWidth(
                                                                  80),
                                                              6: FixedColumnWidth(
                                                                  100),
                                                              7: FixedColumnWidth(
                                                                  70),
                                                              8: FixedColumnWidth(
                                                                  100),// Adjust the width of the second column
                                                              // Adjust the width of the third column
                                                            },
                                                            border: TableBorder.all(color: Colors.black),
                                                            children: [
                                                              TableRow(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.blue.shade300,
                                                                ),
                                                                children: [
                                                                  TableCell(// Set the desired height
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(
                                                                        child: Text(
                                                                          'S.No',
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(child: Text('Product Code', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(child: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(child: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                 /* Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                      ),
                                                                    ),
                                                                  ),*/
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(child: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(child: Text('GST', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                  TableCell(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Center(child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              for (var entry in snapshot.data!.asMap().entries)
                                                                TableRow(
                                                                  children: [
                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text((entry.key + 1).toString())),
                                                                      ),
                                                                    ),
                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text(entry.value['prodCode'])),
                                                                      ),
                                                                    ),
                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text(entry.value['prodName'])),
                                                                      ),
                                                                    ),
                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text(entry.value['unit'])),
                                                                      ),
                                                                    ),
                                                                   /* TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text(entry.value['totalWeight'])),
                                                                      ),
                                                                    ),*/
                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text(entry.value['rate'].toString())),
                                                                      ),
                                                                    ),
                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text(entry.value['qty'].toString())),
                                                                      ),
                                                                    ),

                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(
                                                                            child:Align(
                                                                                alignment: Alignment.topRight,
                                                                                child: Text(entry.value['amt'].toString())
                                                                            )
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child:Align(
                                                                            alignment: Alignment.topRight,
                                                                            child: Text(entry.value['amtGST'].toString()))),
                                                                      ),
                                                                    ),
                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child:Align(
                                                                            alignment: Alignment.topRight,
                                                                            child: Text(entry.value['total'].toString()))),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        return Center(
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                '',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              FutureBuilder<List<Map<String, dynamic>>>(
                                                future: fetchUnitEntries(widget.invoiceNo!),
                                                builder: (context, purchaseSnapshot) {
                                                  if (purchaseSnapshot.connectionState == ConnectionState.waiting) {
                                                    return Center(child: CircularProgressIndicator());
                                                  } else if (purchaseSnapshot.hasError) {
                                                    return Center(child: Text('Error: ${purchaseSnapshot.error}'));
                                                  } else if (!purchaseSnapshot.hasData || purchaseSnapshot.data!.isEmpty) {
                                                    return Center(child: Text('No purchase data available.'));
                                                  } else {
                                                    final purchaseTotal = double.parse(purchaseSnapshot.data![0]["grandTotal"].toString());

                                                    return FutureBuilder<List<Map<String, dynamic>>>(
                                                      future: fetchreturnreport(widget.invoiceNo!),
                                                      builder: (context, returnSnapshot) {
                                                        if (returnSnapshot.connectionState == ConnectionState.waiting) {
                                                          return Center(child: CircularProgressIndicator());
                                                        } else if (returnSnapshot.hasError) {
                                                          return Center(child: Text('Error: ${returnSnapshot.error}'));
                                                        } else if (!returnSnapshot.hasData || returnSnapshot.data!.isEmpty) {
                                                          return Center(child: Text('No return data available.'));
                                                        } else {
                                                          final returnTotal = double.parse(returnSnapshot.data![0]["grandTotal"].toString());
                                                          final grandTotal = purchaseTotal - returnTotal;

                                                          return Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Text("Purchase Total : ${purchaseTotal.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  SizedBox(
                                                                    width: 20,
                                                                    child: Text("   "),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Text("Return Total : ${returnTotal.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  SizedBox(
                                                                    width: 20,
                                                                    child: Text("   "),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Text("Grand Total : ${grandTotal.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  SizedBox(
                                                                    width: 20,
                                                                    child: Text("   "),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                          ),
                        ),

                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        color: Colors.green.shade600,
                        onPressed: (){
                          Navigator.pop(context);
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>const PurchaseReport()));
                        },
                        child: const Text("BACK",style: TextStyle(color: Colors.white),),),
                    ),
                  ],
                )
            )
        ));
  }
}
