
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/purchase_order_report.dart';



class PurchaseView extends StatefulWidget {
  String? orderNo;
  String? customerMobile;
  String? date;
  String? customerName;
  String? customercode;
  String? customerAddress;
  String? pincode;
  String? itemGroup;
  String? itemName;
  String? deliveryDate;
  String? deliveryType;
  String? qty;
  String? totQty;
  String? GSTIN;
  PurchaseView({Key? key,
    required this.orderNo,
    required this.date,
    required this.customercode,
    required this.customerMobile,
    required this.customerName,
    required this.pincode,
    required this.GSTIN,
    required this.totQty,
    required this.qty,
    required this.itemName,
    required this.deliveryDate,
    required this.deliveryType,
    required this.customerAddress,
    required this.itemGroup,
    required List<Map<String, dynamic>> customerData}) : super(key: key);

  //dcViwe({Key? key,required this.dcNo, required this.date}) : super(key: key);

  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {




  Future<List<Map<String, dynamic>>> fetchUnitEntries(String orderNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/purchase_item_view?orderNo=$orderNo'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }
  TextEditingController orderNo = TextEditingController();
  TextEditingController custCode = TextEditingController();
  TextEditingController custAddress = TextEditingController();
  TextEditingController custMobile = TextEditingController();
  TextEditingController GSTIN = TextEditingController();
  TextEditingController grandTotal =TextEditingController();
  DateTime selectedDate = DateTime.now();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> filteredData = [];

  List<Map<String, dynamic>> data = [];

  bool showInitialData = true;



  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call filterData with an empty query when the page loads
    if (showInitialData) {
      filterData('');
      filtercustData('');
    }
  }

  void filterData(String searchText) {
    setState(() {
      filteredData = []; // Initialize as an empty list
      if (searchText.isNotEmpty) {
        // Filter the data based on the search text
        filteredData = data.where((item) {
          String id = item['orderNo']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();
        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['orderNo']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
        }
      }});
  }
  List<Map<String, dynamic>> filteredcust = [];
  List<Map<String, dynamic>> customerdata = [];


  Future<List<Map<String, dynamic>>> fetchEntries(String customercode) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/customer_view?custCode=$customercode'));
      if (response.statusCode == 200) {
        final List<dynamic> customerdata = json.decode(response.body);
        return customerdata.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  TextEditingController custCodeController = TextEditingController();
  void filtercustData(String searchText) {
    setState(() {
      filteredcust = [];
      if (searchText.isNotEmpty) {
        filteredcust = customerdata.where((item) {
          String id = item['custCode']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();
      } else {
        // Handle the case when searchText is empty
        filteredcust = customerdata;
      }
    });
  }





  @override
  Widget build(BuildContext context) {
    orderNo.addListener(() {
      filterData(orderNo.text);
    });
    custCode.addListener(() {
      filtercustData(custCode.text);
    });
    return  MyScaffold(route: "dcview",backgroundColor: Colors.white,

        body: Form(
            key: _formKey,
            child:SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 2,),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child:Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey), // Add a border for the box
                            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                          ),child: Wrap(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left:10.0),
                                      child: Image.asset(
                                        'assets/delivery.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                    Container(constraints: BoxConstraints(maxWidth: 300),
                                      child: const Text(" Sales Order Report ", style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25
                                      ),),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right:13),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:100,
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right:30.0),
                                                child: Text(widget.date.toString() != null ? DateFormat("dd-MM-yyyy").format(DateTime.parse("${widget.date}")):"", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                                              ),
                                              Divider(
                                                color: Colors.grey.shade600,
                                              ),
                                              Wrap(
                                                  children:[
                                                    Column(
                                                      children: [
                                                        SizedBox(
                                                          child:  Text("Order Number",style: TextStyle(fontWeight: FontWeight.bold),),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(children: [
                                                      Align(
                                                        alignment: Alignment.topLeft,
                                                        child://Text("009"),
                                                        Text(widget.orderNo.toString(),style: TextStyle(
                                                            color: Colors.black
                                                        ),),
                                                      ),
                                                    ],),
                                                  ]
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],)
                          ],
                        ),
                        ),
                      ),
                    ),
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
                                padding: const EdgeInsets.only(right:100),
                                child: Text(" Customer Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),


                            SizedBox(height: 20,),

                            Wrap(
                              runSpacing: 20,
                              spacing: 36,
                              children: [
                                SizedBox(
                                  width: 220,
                                  height: 30,
                                  child: TextFormField(
                                    readOnly: true,
                                    initialValue: widget.customercode,
                                    style: TextStyle(
                                        fontSize: 13),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Customer Code",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8,),
                                        )
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  width: 220,
                                  height: 30,
                                  child: TextFormField(
                                    readOnly: true,
                                    initialValue: widget.customerName,
                                    style: TextStyle(
                                        fontSize: 13),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Customer/Company Name",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8,),
                                        )
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  width: 220,
                                  height: 30,
                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                    future: fetchEntries(widget.customercode.toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error: ${snapshot.error}'));
                                      } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                        // Extract the customer address from the snapshot data
                                        String customerMobile = snapshot.data![0]["custMobile"].toString();
                                        return SizedBox(
                                          width: 200,
                                          height: 30,
                                          child: TextFormField(
                                            readOnly: true,
                                            initialValue: customerMobile,
                                            style: TextStyle(fontSize: 13),
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              labelText: "Customer Mobile",
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
                                SizedBox(
                                  width: 220,
                                  height: 30,
                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                    future: fetchEntries(widget.customercode.toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error: ${snapshot.error}'));
                                      } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                        // Extract the customer address from the snapshot data
                                        String customerAddress = snapshot.data![0]["custAddress"];
                                        return SizedBox(
                                          width: 218,
                                          height: 70,
                                          child: TextFormField(
                                            readOnly: true,
                                            initialValue: customerAddress,
                                            style: TextStyle(fontSize: 13),
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              labelText: "Customer Address",
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




                              ],
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top:30),
                              child: Wrap(
                                runSpacing: 20,
                                spacing: 36,
                                children: [
                                  SizedBox(
                                    width: 220,
                                    height: 30,
                                    child: FutureBuilder<List<Map<String, dynamic>>>(
                                      future: fetchEntries(widget.customercode.toString()),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(child: Text('Error: ${snapshot.error}'));
                                        } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                          // Extract the customer address from the snapshot data
                                          String pincode = snapshot.data![0]["pincode"];
                                          return SizedBox(
                                            width: 218,
                                            height: 70,
                                            child: TextFormField(
                                              readOnly: true,
                                              initialValue: pincode,
                                              style: TextStyle(fontSize: 13),
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "Pincode",
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

                                  SizedBox(
                                    width: 220,
                                    height: 30,
                                    child: FutureBuilder<List<Map<String, dynamic>>>(
                                      future: fetchEntries(widget.customercode.toString()),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(child: Text('Error: ${snapshot.error}'));
                                        } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                          // Extract the customer address from the snapshot data
                                          String GSTIN = snapshot.data![0]["gstin"];
                                          return SizedBox(
                                            width: 200,
                                            height: 70,
                                            child: TextFormField(
                                              readOnly: true,
                                              initialValue: GSTIN,
                                              style: TextStyle(fontSize: 13),
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "GSTIN",
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
                                  SizedBox(
                                    width: 220,
                                    height: 30,
                                    child: TextFormField(
                                      readOnly: true,
                                      initialValue: widget.deliveryType ?? '',
                                      style: TextStyle(fontSize: 13),
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Delivery Type",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    height: 30,
                                    child: TextFormField(
                                      readOnly: true,
                                      initialValue: widget.deliveryDate != null && widget.deliveryDate!.isNotEmpty
                                          ? DateFormat("dd-MM-yyyy").format(DateTime.parse(widget.deliveryDate!).toLocal())
                                          : null,
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
                                ],
                              ),
                            ),

                            SizedBox(height: 10,),

                            Align(
                              alignment:Alignment.topLeft,
                              child:Padding(
                                padding: const EdgeInsets.only(top:10),
                                child: Text("Product Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30,),
                            Container(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: FutureBuilder<List<Map<String, dynamic>>>(
                                    future: fetchUnitEntries(widget.orderNo.toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        // Your table-building logic
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return CircularProgressIndicator(); // or some loading indicator
                                      }
                                      if (snapshot.data!.isNotEmpty ||
                                          snapshot.data!.isEmpty){
                                        return Table(
                                            border: TableBorder.all(
                                                color: Colors.black54
                                            ),
                                            defaultColumnWidth: const FixedColumnWidth(605.0),
                                            columnWidths: const <int, TableColumnWidth>{
                                              0:FixedColumnWidth(52),
                                              1:FixedColumnWidth(300),
                                              2:FixedColumnWidth(300),
                                              3:FixedColumnWidth(165),
                                              4:FixedColumnWidth(165),

                                            },
                                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                            children:[
                                              //Table row starting
                                              TableRow(
                                                  children: [
                                                    TableCell(
                                                        child:Container(
                                                          color:Colors.blue.shade200,
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 8,),
                                                                Text('S.No',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                const SizedBox(height: 8,)
                                                              ],
                                                            ),),
                                                        )),
                                                    //Meeting Name
                                                    TableCell(
                                                        child:Container(
                                                          color:Colors.blue.shade200,
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 8,),
                                                                Text('Item Group',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                const SizedBox(height: 8,)
                                                              ],
                                                            ),),
                                                        )),
                                                    TableCell(
                                                        child:Container(
                                                          color:Colors.blue.shade200,
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 8,),
                                                                Text('Item Name',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                const SizedBox(height: 8,)
                                                              ],
                                                            ),),
                                                        )),

                                                    TableCell(
                                                        child:Container(
                                                          color:Colors.blue.shade200,
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 8,),
                                                                Text('Quantity',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                const SizedBox(height: 8,)
                                                              ],
                                                            ),),
                                                        )),

                                                    /* TableCell(
                                                        child:Container(
                                                          color:Colors.blue.shade200,
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 8,),
                                                                Text('Total',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                const SizedBox(height: 8,)
                                                              ],
                                                            ),),
                                                        )),*/

                                                  ]),

                                              for (var i = 0; i < snapshot.data!.length; i++) ...[
                                                TableRow(
                                                  // decoration: BoxDecoration(color: Colors.grey[200]),
                                                    children: [
                                                      // 1 s.no
                                                      TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${i+1}"),
                                                          const SizedBox(height: 10,),
                                                        ],
                                                      )
                                                      )
                                                      ),
                                                      TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${snapshot.data![i]["itemGroup"] ?? 'N/A'}"),
                                                          const SizedBox(height: 10,)
                                                        ],
                                                      ))),
                                                      TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${snapshot.data![i]["itemName"]}"),
                                                          const SizedBox(height: 10,)
                                                        ],
                                                      ))),

                                                      TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${snapshot.data![i]["qty"]}"),
                                                          const SizedBox(height: 10,)
                                                        ],
                                                      ))),
                                                      /*TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${snapshot.data![i]["totQty"]}"),
                                                          const SizedBox(height: 10,)
                                                        ],
                                                      ))),*/
                                                    ]
                                                ),
                                              ],
                                            ]
                                        );}
                                      return Container();
                                    }
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        color: Colors.green.shade600,
                        onPressed: (){
                          Navigator.pop(context);
                          //Navigator.push(context, MaterialPageRoute(builder: (context)=>const PurchaseOrderReport()));
                        },
                        child: const Text("BACK",style: TextStyle(color: Colors.white),),),
                    ),
                  ],
                )
            )
        ));
  }
}
