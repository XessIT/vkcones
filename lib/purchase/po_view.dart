import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/po_creation_report.dart';
import 'package:vinayaga_project/purchase/purchase_report.dart';

class PoView extends StatefulWidget {
  String? poNo;
  String? supMobile;
  String? date;
  String? supName;
  String? supCode;
  String? supAddress;
  String? prodCode;
  String? prodName;
  String? qty;
  String? deliveryDate;
  String? deliveryType;

  PoView({Key? key,required this.poNo,required this.date,
    required this.supCode,
    required this.supMobile,
    required this.supName,
    required this.supAddress,
    required this.prodCode,
    required this.prodName,
    required this.qty,
    required this.deliveryDate,
    required this.deliveryType,


  }) : super(key: key);


  @override
  State<PoView> createState() => _PoViewState();
}

class _PoViewState extends State<PoView> {
  Future<List<Map<String, dynamic>>> fetchUnitEntries(String poNum) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/po_view_item?poNo=$poNum'));
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
  List<Map<String, dynamic>> filteredSup = [];
  List<Map<String, dynamic>> supData = [];
  Future<List<Map<String, dynamic>>> fetchEntries(String supCode) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/fetch_sup_details?supCode=$supCode'));
      if (response.statusCode == 200) {
        final List<dynamic> supplierData = json.decode(response.body);
        return supplierData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  /* TextEditingController supController = TextEditingController();*/
  TextEditingController supCode = TextEditingController();
  TextEditingController supAddress = TextEditingController();
  TextEditingController supMobile = TextEditingController();

  void filterSupData(String searchText) {
    setState(() {
      filteredSup = [];
      if (searchText.isNotEmpty) {
        filteredSup = supData.where((item) {
          String id = item['supCode']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();
      } else {
        // Handle the case when searchText is empty
        filteredSup = supData;
      }
    });
  }
  List<Map<String, dynamic>> filteredCodeData = [];
  void filterData(String searchText) {
    setState(() {
      filteredData = [];
      if (searchText.isNotEmpty) {
        filteredData = data.where((item) {
          String id = item['poNo']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['poNo']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
        }
      }});
  }
  TextEditingController poNo = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  bool showInitialData = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (showInitialData) {
      filterData('');
      filterSupData('');
    }
  }




  @override
  Widget build(BuildContext context) {
    poNo.addListener(() {
      filterData(poNo.text);
    });
    supCode.addListener(() {
      filterSupData(supCode.text);
    });
    return  MyScaffold(route: "Po view",backgroundColor: Colors.white,
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
                                              const Text("  PO Report", style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20
                                              ),),

                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left:0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 0),
                                                      child: Align(
                                                        alignment: Alignment.topRight,
                                                        child: Container(
                                                          // width: 130,
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  SizedBox(height: 20,),
                                                                  SizedBox(
                                                                    width: 95,
                                                                    child: Container(
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Align(
                                                                            alignment: Alignment.topLeft,
                                                                            child:
                                                                            Text(widget.date.toString() != null ? DateFormat("dd-MM-yyyy").format(DateTime.parse("${widget.date}")):"", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                                                                          ),
                                                                          Divider(
                                                                            color: Colors.grey.shade600,
                                                                          ),
                                                                          const Align(
                                                                              alignment: Alignment.topLeft,
                                                                              child:
                                                                              Text("PO Number",style: TextStyle(fontWeight: FontWeight.bold),)),
                                                                          Align(
                                                                            alignment: Alignment.topLeft,
                                                                            child://Text("009"),
                                                                            Text(widget.poNo.toString(),style: TextStyle(
                                                                                color: Colors.black
                                                                            ),),
                                                                          )],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
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
                                                child:Text(" Supplier Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                ),
                                              ),

                                              SizedBox(height: 10,),

                                              Wrap(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 200,
                                                    //  height: 30,
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
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 200,
                                                                                                     //   height: 30,
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue: widget.supName.toString(),
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
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 200,
                                                    //  height: 45,
                                                      child: FutureBuilder<List<Map<String, dynamic>>>(
                                                        future: fetchEntries(widget.supCode.toString()),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return const Center(child: CircularProgressIndicator());
                                                          } else if (snapshot.hasError) {
                                                            return Center(child: Text('Error: ${snapshot.error}'));
                                                          } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                                            String supAddress = snapshot.data![0]["supAddress"].toString();
                                                            return SizedBox(

                                                              child: TextFormField(
                                                                readOnly: true,
                                                                initialValue: supAddress,
                                                                style: const TextStyle(fontSize: 13),
                                                                keyboardType: TextInputType.text,
                                                                decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  labelText: "Supplier Address",
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            return Container(); // Or any other widget you want to display
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 200,
                                                      //height: 45,
                                                      child: FutureBuilder<List<Map<String, dynamic>>>(
                                                        future: fetchEntries(widget.supCode.toString()),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return const Center(child: CircularProgressIndicator());
                                                          } else if (snapshot.hasError) {
                                                            return Center(child: Text('Error: ${snapshot.error}'));
                                                          } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                                            String supAddress = snapshot.data![0]["pincode"].toString();
                                                            return SizedBox(
                                                              child: TextFormField(
                                                                readOnly: true,
                                                                initialValue: supAddress,
                                                                style: const TextStyle(fontSize: 13),
                                                                keyboardType: TextInputType.text,
                                                                decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  labelText: "Supplier Pincode",
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            return Container(); // Or any other widget you want to display
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 200,
                                                      //   height: 45,
                                                      child: FutureBuilder<List<Map<String, dynamic>>>(
                                                        future: fetchEntries(widget.supCode.toString()),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return const Center(child: CircularProgressIndicator());
                                                          } else if (snapshot.hasError) {
                                                            return Center(child: Text('Error: ${snapshot.error}'));
                                                          } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                                            // Extract the customer address from the snapshot data
                                                            String supMobile = snapshot.data![0]["supMobile"].toString();

                                                            return SizedBox(
                                                              width: 200,
                                                            //  height: 30,
                                                              child: TextFormField(
                                                                readOnly: true,
                                                                initialValue: supMobile,
                                                                style: TextStyle(fontSize: 13),
                                                                keyboardType: TextInputType.text,
                                                                decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  labelText: "Supplier Mobile",
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            // Return a default widget when none of the conditions are met
                                                            return Container(); // Or any other widget you want to display
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 200,
                                                      // height: 30,
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue: () {
                                                          try {
                                                            if (widget.deliveryDate != null) {
                                                              DateTime parsedDate = DateTime.parse("${widget.deliveryDate}");
                                                              return DateFormat("dd-MM-yyyy").format(parsedDate);
                                                            }
                                                          } catch (e) {
                                                            print("Error parsing date: $e");
                                                          }
                                                          return ""; // Default value in case of an error
                                                        }(),
                                                        style: TextStyle(fontSize: 13),
                                                        keyboardType: TextInputType.text,
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Expected Delivery Date",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              Row(
                                                children: [


                                                /*  SizedBox(
                                                    width: 230,
                                                    height: 30,
                                                    child: TextFormField(
                                                      readOnly: true,
                                                      initialValue: widget.deliveryType.toString(),
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                      keyboardType: TextInputType.text,
                                                      decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Delivery Type",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8,),
                                                          )
                                                      ),
                                                    ),
                                                  ),*/
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Align(
                                                alignment:Alignment.topLeft,
                                                child:Text("  Product Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Center(
                                                child:
                                                SingleChildScrollView(
                                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                                    future: fetchUnitEntries(widget.poNo.toString()),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return Center(child: CircularProgressIndicator());
                                                      } else if (snapshot.hasError) {

                                                        return Center(child: Text('Error: ${snapshot.error}'));
                                                      } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                                        return SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: Container(
                                                            padding: EdgeInsets.all(16.0),
                                                            child: Table(
                                                              defaultColumnWidth: const FixedColumnWidth(230),
                                                              columnWidths: const {
                                                                0: FixedColumnWidth(150), // Adjust the width of the first column
                                                                1: FixedColumnWidth(230), // Adjust the width of the second column
                                                                2: FixedColumnWidth(230),
                                                                3: FixedColumnWidth(230), // Adjust the width of the second column
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
                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
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
                                                                          child: Center(child: Text(entry.value['prodCode'].toString())),
                                                                        ),
                                                                      ),
                                                                      TableCell(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Center(child: Text(entry.value['prodName'].toString())),
                                                                        ),
                                                                      ),
                                                                      TableCell(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Center(child: Text(entry.value['unit'].toString())),
                                                                        ),
                                                                      ),
                                                                      TableCell(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Center(child: Text(entry.value['qty'].toString())),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return Center(
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                'No Data Available',
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
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>const PoReport()));
                        },
                        child: const Text("BACK",style: TextStyle(color: Colors.white),),),
                    ),
                  ],
                )
            )
        ));
  }
}
