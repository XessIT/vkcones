import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
class QuotationItem extends StatefulWidget {
  String? quotNo;
  int customerMobile;
  String? date;
  String? customerName;
  String? custCode;
  String? customerAddress;
  String? pincode;
  QuotationItem({Key? key,
    required this.quotNo,
    required this.date,
    required this.customerMobile,
    required this.customerName,
    required this.pincode,
    required this.customerAddress, required this.custCode
  }) : super(key: key);
  @override
  State<QuotationItem> createState() => _QuotationItemState();
}


class _QuotationItemState extends State<QuotationItem> {


  Future<List<Map<String, dynamic>>> fetchUnitEntries(String dateLimit) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getQuotItem'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Filter data based on the date limit
        final DateTime limitDate = DateTime.parse(dateLimit);
        final filteredData = data.where((entry) {
          final entryDate = DateTime.parse(entry['date']); // Replace 'dateField' with the actual date field in your data
          return entryDate.isBefore(limitDate);
        }).toList();

        return filteredData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }
  TextEditingController date = TextEditingController();
  List<Map<String, dynamic>> filteredCodeData = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  void filterData(String searchText) {
    setState(() {
      filteredData = []; // Initialize as an empty list
      if (searchText.isNotEmpty) {
        // Filter the data based on the search text
        filteredData = data.where((item) {
          String id = item['date']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['date']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
        }
      }});
  }


  bool showInitialData = true;

  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call filterData with an empty query when the page loads
    if (showInitialData) {
      filterData('');
    }
  }




  @override
  Widget build(BuildContext context) {
    date.addListener(() {
      filterData(date.text);
    });

    return MyScaffold(
      route: "/quotation_item",
      body: Center(
        child: Column(
          children: [

            SizedBox(

              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Wrap(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [const Icon(Icons.edit_note, size:30),
                                  Text("Quotation Item Report",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),],),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: SizedBox(
                                  width: 120,
                                  child: Container(
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child:
                                              Text(widget.date.toString() != null ? DateFormat("dd-MM-yyyy").format(DateTime.parse("${widget.date}")):"", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),),
                                            Divider(
                                              color: Colors.grey.shade600,
                                            ),
                                            const Align(
                                                alignment: Alignment.topLeft,
                                                child: Text("Quotation Number",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),)),

                                            Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(widget.quotNo.toString())),
                                          ]
                                      )

                                  ),
                                ),
                              ),
                            ]),
                      ]
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
                child: Wrap(
                  children: [
                    Align(
                      alignment:Alignment.topLeft,
                      child:Padding(
                        padding: const EdgeInsets.only(left:5),
                        child: Text(" Customer Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 40,),
                    Wrap(
                      runSpacing: 10,
                      spacing: 100,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:8.0),
                          child: SizedBox(
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
                                  labelText: "Customer Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8,),
                                  )
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 220,
                          height: 30,
                          child: TextFormField(
                            readOnly: true,
                            initialValue: widget.customerAddress,
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
                        SizedBox(
                          width: 220,
                          height: 30,
                          child: TextFormField(
                            readOnly: true,
                            initialValue: widget.pincode,
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

                        SizedBox(
                          width: 220,
                          height: 30,
                          child: TextFormField(
                            readOnly: true,
                            initialValue: widget.customerMobile.toString(),
                            style: TextStyle(
                                fontSize: 13),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Customer Mobile",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8,),
                                )
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3,),
                    Align(
                      alignment:Alignment.topLeft,
                      child:Padding(
                        padding: const EdgeInsets.only(left:10,bottom: 10,top: 10),
                        child: Text("Product Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchUnitEntries(widget.date.toString()),
                        //  future: fetchUnitEntries(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                            return Container(
                              padding: EdgeInsets.all(10.0),
                              child: Table(
                                columnWidths: {
                                  0: FixedColumnWidth(70), // Adjust the width of the first column
                                  1: FixedColumnWidth(310), // Adjust the width of the second column
                                  2: FixedColumnWidth(310), // Adjust the width of the third column
                                  3: FixedColumnWidth(145),
                                  4: FixedColumnWidth(145),// Adjust the width of the third column
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
                                            child: Center(child: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
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
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(child: Text(entry.value['unit'])),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Align(
                                                alignment:Alignment.center,
                                                child: Text(entry.value['rate'])),
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
                },
                child: const Text("BACK",style: TextStyle(color: Colors.white),),),
            ),
          ],
        ),
      ),
    );
  }
}
