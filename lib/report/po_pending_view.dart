import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/purchase_report.dart';

class POPendingView extends StatefulWidget {
  String? pendingOrderNo;
  String? customerMobile;
  String? date;
  String? customerName;
  String? customercode;
  String? customerAddress;
  String? itemGroup;
  String? itemName;
  // String? deliveryDate;
  // String? deliveryType;
  String? qty;
   String? orderNo;


  POPendingView({Key? key,
    required this.pendingOrderNo,
    required this.date,
    required this.customercode,
    required this.customerMobile,
    required this.customerName,
    required this.qty,
    required this.itemName,
    // required this.deliveryDate,
    // required this.deliveryType,
    required this.customerAddress,
    required this.itemGroup,
     required this.orderNo,
  }) : super(key: key);


  @override
  State<POPendingView> createState() => _POPendingViewState();
}

class _POPendingViewState extends State<POPendingView> {

  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invoiceNo) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/pending_po_item_view?pendingOrderNo=$invoiceNo'));

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
          String id = item['pendingOrderNo']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['pendingOrderNo']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
        }
      }});
  }
  List<Map<String, dynamic>> data2 = [];
  List<Map<String, dynamic>> filteredData2 = [];
String mobile="";
String address="";
String pincode="";
String code="";
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
/*
  void filterData2(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData2 = data2;
      } else {
        final existingSupplier = data2.firstWhere(
              (item) => widget.customercode == searchText,
          orElse: () => {},
          // Use an empty map literal as the default value
        );
        if (existingSupplier.isNotEmpty) {
         mobile = existingSupplier['supMobile']?.toString() ?? '';
          address = existingSupplier['supAddress']?.toString() ?? '';
          pincode= existingSupplier['pincode']?.toString() ?? '';
        } else {

        }
      }
    });
  }
*/
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    DateTime Date = DateTime.now();

    final formattedDate = DateFormat("dd-MM-yyyy").format(Date);
    return  MyScaffold(
        route: "pending_view",
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
                                            const Text("Pending PO Report", style: TextStyle(
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
                                                    Text("Pending PO Number",style: TextStyle(fontWeight: FontWeight.bold),)),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child://Text("009"),
                                                  Text(widget.pendingOrderNo.toString(),style: TextStyle(
                                                      color: Colors.black
                                                  ),),
                                                ),  Divider(
                                                  color: Colors.grey.shade600,
                                                ),
                                                const Align(
                                                    alignment: Alignment.topLeft,
                                                    child:
                                                    Text("Invoice No",style: TextStyle(fontWeight: FontWeight.bold),)),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child://Text("009"),
                                                  Text(widget.orderNo.toString(),style: TextStyle(
                                                      color: Colors.black
                                                  ),),
                                                ),
                                              ],
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
                                                  child: Text("Supplier Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(height: 10,),

                                              Padding(
                                                padding: const EdgeInsets.only(left:10),
                                                child: Wrap(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 200,

                                                        child: TextFormField(
                                                          readOnly: true,
                                                          initialValue: widget.customercode,
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
                                                    SizedBox(width:11),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 200,
                                                     //   width: 200,
                                                        child: TextFormField(
                                                          readOnly: true,
                                                          initialValue: widget.customerName,
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
                                                        //  height: 45,
                                                        child: FutureBuilder<List<Map<String, dynamic>>>(
                                                          future: fetchEntries(widget.customercode.toString()),
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

                                                    SizedBox(width:11),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 200,
                                                        //   height: 45,
                                                        child: FutureBuilder<List<Map<String, dynamic>>>(
                                                          future: fetchEntries(widget.customercode.toString()),
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
                                                   /* SizedBox(width:11),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 200,
                                                        child: TextFormField(
                                                          readOnly: true,
                                                        //  initialValue: widget.deliveryType,
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
                                                      ),
                                                    ),*/
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Align(
                                                alignment:Alignment.topLeft,
                                                child:Padding(
                                                  padding: const EdgeInsets.only(left:14),
                                                  child: Text("Product Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child:
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                                    future: fetchUnitEntries(widget.pendingOrderNo.toString()),
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
                                                              0: FixedColumnWidth(200), // Adjust the width of the first column
                                                              1: FixedColumnWidth(200), // Adjust the width of the second column
                                                              2: FixedColumnWidth(200),
                                                              3: FixedColumnWidth(150), // Adjust the width of the second column
                                                              4: FixedColumnWidth(140),
                                                              5: FixedColumnWidth(100),
                                                              6: FixedColumnWidth(100),
                                                              7: FixedColumnWidth(100),// Adjust the width of the second column
                                                              // Adjust the width of the third column
                                                            },
                                                            border: TableBorder.all(color: Colors.black),
                                                            children: [
                                                              TableRow(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.blue.shade300,
                                                                ),
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: TableCell(// Set the desired height
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
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text('Product Code', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                      ),
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
                                                                        child: Center(child: Text(entry.value['qty'].toString())),
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
                                                future: fetchUnitEntries(widget.pendingOrderNo!),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return Center(child: CircularProgressIndicator());
                                                  } else if (snapshot.hasError) {
                                                    return Center(child: Text('Error: ${snapshot.error}'));
                                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                                    return Center(child: Text('No data available.'));
                                                  }
                                                  else {
                                                    final grandTotal = snapshot.data![0]["grandTotal"].toString(); // Assuming "grandTotal" is a key in the map

                                                    return Column(
                                                      children: [

                                                      ],
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
