import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;

import 'dc_report.dart';

class dcViwe extends StatefulWidget {



  String? dcNo;
  String? grandTotal;
  int custMobile;
  String? date;
  String? custName;
  String? custCode;
  String? supplyPlace;
  String? custAddress;
  String? pincode;
  String? invNo;
  String? orderNo;String? transportNo;
  dcViwe({Key? key,
    required this.dcNo,required this.date,
    required this.custCode,
    required this.orderNo,
    required this.supplyPlace,
    required this.custMobile,
    required this.pincode,
    required this.custName,
    required this.custAddress,required this.transportNo,
    required this.invNo,
    required this.grandTotal,
    required List<Map<String,
        dynamic>> customerData}) : super(key: key);

  //dcViwe({Key? key,required this.dcNo, required this.date}) : super(key: key);

  @override
  State<dcViwe> createState() => _dcViweState();
}

class _dcViweState extends State<dcViwe> {
  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invoiceNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/dc_item_view?invoiceNo=$invoiceNo'));
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
  TextEditingController invoiceNo = TextEditingController();
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
    }
  }



  List<Map<String, dynamic>> filteredCodeData = [];
  void filterData(String searchText) {
    setState(() {
      filteredData = []; // Initialize as an empty list

      if (searchText.isNotEmpty) {
        // Filter the data based on the search text
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
          if (filteredData.isNotEmpty) {
            Map<String, dynamic> order = filteredData.first;

            grandTotal.text = order["grandTotal"]?.toString() ?? '';
            // grandtotaltxt = order["grandTotal"]?.toString() ?? '';
          } else {
            grandTotal.clear();
            //grandtotaltxt.toString().clear();
            filteredData = List.from(data);
          }
        }
      }});
  }


  @override
  Widget build(BuildContext context) {
    invoiceNo.addListener(() {
      filterData(invoiceNo.text);
    });
    return  MyScaffold(route: "dcview",
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
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey), // Add a border for the box
                            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                          ),
                          child:  Wrap(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left:10.0),
                                        child: Row(children: [
                                          Image.asset(
                                            'assets/4_db_deliverychallen.png',
                                            width: 30,
                                            height: 30,
                                          ),
                                          Text("  Delivery Challan Report", style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25
                                          ),),
                                        ],),
                                      ),

                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right:10.0),
                                          child: Container(
                                            // width: 130,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Wrap(
                                                  children: [
                                                    SizedBox(height: 20,),
                                                    SizedBox(
                                                      width: 80,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Align(
                                                            alignment: Alignment.topLeft,
                                                            child:
                                                            Text(widget.date.toString() != null ? DateFormat("dd-MM-yyyy").format(DateTime.parse("${widget.date}")):"", style: TextStyle(fontWeight: FontWeight.bold,),),
                                                          ),
                                                          Divider(
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          const Align(
                                                              alignment: Alignment.topLeft,
                                                              child:
                                                              Text("DC Number",style: TextStyle(fontWeight: FontWeight.bold),)),
                                                          Align(
                                                            alignment: Alignment.topLeft,
                                                            child:
                                                            Text(widget.dcNo.toString(),style: TextStyle(
                                                                color: Colors.black
                                                            ),),
                                                          )],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ),
                                      ),
                                    ]),
                              ]
                          ),

                        ),
                      ),
                    ),
                    SizedBox(
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
                                            padding: const EdgeInsets.only(left:5),
                                            child: Text(" Customer Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20,),
                                        Padding(
                                          padding: const EdgeInsets.only(left:5.0),
                                          child: Wrap(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: SizedBox(
                                                  width: 180,

                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: widget.custCode,
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
                                              ),
                                              SizedBox(
                                                  width:9
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: 180,

                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: widget.custName,
                                                    style: TextStyle(
                                                        fontSize: 13),
                                                    keyboardType: TextInputType.text,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        labelText: "Customer Name",
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(8,),
                                                        )
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width:9
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: 180,

                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: widget.custMobile.toString(),
                                                    style: TextStyle(
                                                        fontSize: 13),
                                                    keyboardType: TextInputType.text,
                                                    decoration: InputDecoration(
                                                        prefixText: "+91",
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        labelText: "Customer Mobile",
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(8,),
                                                        )
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width:9
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: 180,

                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: widget.custAddress,
                                                    style: TextStyle(
                                                        fontSize: 13),
                                                    keyboardType: TextInputType.text,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        labelText: "Customer Address",
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
                                                  width: 160,

                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: widget.pincode.toString(),
                                                    style: TextStyle(
                                                        fontSize: 13),
                                                    keyboardType: TextInputType.text,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        labelText: "pincode",
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

                                        Padding(
                                          padding: const EdgeInsets.only(left:0.0),
                                          child: Wrap(children: [
                                            SizedBox(
                                              width: 180,

                                              child: TextFormField(
                                                readOnly: true,
                                                initialValue: widget.supplyPlace,
                                                style: TextStyle(
                                                    fontSize: 13),
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    labelText: "Place Of Supply",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8,),
                                                    )
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                width:20
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(0.0),
                                              child: SizedBox(
                                                width: 180,

                                                child: TextFormField(
                                                  readOnly: true,
                                                  initialValue: widget.transportNo,
                                                  style: TextStyle(
                                                      fontSize: 13),
                                                  keyboardType: TextInputType.text,
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "Transport Number",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8,),
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),


                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SizedBox(width: 180,
                                                  height: 30,
                                                  child: Text("")),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SizedBox(width: 180,
                                                  height: 30,
                                                  child: Text("")),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SizedBox(width: 180,
                                                  height: 30,
                                                  child: Text("")),
                                            ),
                                          ]),
                                        ),



                                        SizedBox(height: 10,),
                                        Align(
                                          alignment:Alignment.topLeft,
                                          child:Padding(
                                            padding: const EdgeInsets.only(left:8),
                                            child: Text("Product Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10,),
                                        Center(
                                          child: SingleChildScrollView(
                                            child: FutureBuilder<List<Map<String, dynamic>>>(
                                              future: fetchUnitEntries(widget.invNo.toString()),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return Center(child: CircularProgressIndicator());
                                                } else if (snapshot.hasError) {
                                                  return Center(child: Text('Error: ${snapshot.error}'));
                                                } else if (snapshot.data != null &&
                                                    snapshot.data!.isNotEmpty) {
                                                  return SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Container(
                                                      padding: EdgeInsets.all(5.0),
                                                      child: Table(
                                                        columnWidths: {
                                                          0: FixedColumnWidth(70), // Adjust the width of the first column
                                                          1: FixedColumnWidth(180), // Adjust the width of the second column
                                                          2: FixedColumnWidth(180),
                                                          3: FixedColumnWidth(150), // Adjust the width of the second column
                                                          4: FixedColumnWidth(135),
                                                          5: FixedColumnWidth(135),
                                                          6: FixedColumnWidth(130),
                                                          // Adjust the width of the second column
                                                          // Adjust the width of the third column
                                                        },
                                                        border: TableBorder.all(color: Colors.black),
                                                        children: [
                                                          TableRow(
                                                            decoration: BoxDecoration(
                                                              color: Colors.blue.shade100,
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
                                                                    child: Center(child: Text('Item Group', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: TableCell(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Center(child: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
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
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: TableCell(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Center(child: Text('Rate per Unit', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: TableCell(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Center(child: Text('GST', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: TableCell(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Center(child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
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
                                                                    child: Center(child: Text(entry.value['itemGroup'])),
                                                                  ),
                                                                ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Center(child: Text(entry.value['itemName'])),
                                                                  ),
                                                                ),
                                                                // TableCell(
                                                                //   child: Padding(
                                                                //     padding: const EdgeInsets.all(8.0),
                                                                //     child: Center(child:Text(widget.supplyPlace.toString(), )),
                                                                //   ),
                                                                // ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Center(child: Text(entry.value['qty'].toString())),
                                                                  ),
                                                                ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Center(child: Align(
                                                                        alignment:Alignment.topRight,
                                                                        child: Text(entry.value['rate'].toString()))),
                                                                  ),
                                                                ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Center(child: Align(
                                                                        alignment:Alignment.topRight,
                                                                        child: Text(entry.value['amtGST'].toString()))),
                                                                  ),
                                                                ),
                                                                TableCell(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Center(child: Align(
                                                                        alignment:Alignment.topRight,
                                                                        child: Text(entry.value['total'].toString()))),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }else {
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
                                        SizedBox(height: 20),
                                        FutureBuilder<List<Map<String, dynamic>>>(
                                          future: fetchUnitEntries(widget.invNo!),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return Center(child: CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Center(child: Text('Error: ${snapshot.error}'));
                                            }
                                         /*   else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                              return Center(child: Text('No data available.'));
                                            } */
                                            else {
                                              final grandTotal = snapshot.data![0]["grandTotal"]; // Assuming "grandTotal" is a key in the map

                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 50.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold)),
                                                        const SizedBox(width: 20),
                                                        const Icon(Icons.currency_rupee, size: 18),
                                                        SizedBox(
                                                          width: 100,
                                                          child: TextFormField(
                                                            readOnly: true,
                                                            controller: TextEditingController(text: grandTotal),
                                                            style: const TextStyle(fontSize: 13),
                                                            validator: (value) {
                                                              if (value!.isEmpty) {
                                                                return '* Enter Main Grand Total';
                                                              }
                                                              return null;
                                                            },
                                                            keyboardType: TextInputType.number,
                                                            decoration: const InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              enabledBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(color: Colors.grey),
                                                              ),
                                                            ),
                                                            textAlign: TextAlign.right,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        color: Colors.green.shade600,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: const Text("BACK",style: TextStyle(color: Colors.white),),),
                    ),
                  ],
                )

            )
        ));
  }
}
