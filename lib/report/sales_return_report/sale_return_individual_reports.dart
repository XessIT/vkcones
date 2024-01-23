import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';

class SalesReturnIndividualReport extends StatefulWidget {
  final String? salRetNo;
  final String? custCode;
  final String? custpincode;
  final String? grandtotal;
  final String? custName;
  final String? date;
  const SalesReturnIndividualReport({
    Key? key,
    required this.date,
    required this.grandtotal,
    required this.custCode,
    required this.salRetNo, required this.custName, required this.custpincode
  }) : super(key: key);

  @override
  State<SalesReturnIndividualReport> createState() => _SalesReturnIndividualReportState();
}

class _SalesReturnIndividualReportState extends State<SalesReturnIndividualReport> {
  TextEditingController grandTotalController = TextEditingController();


  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? callValue = "";
  String? invoiceNo = "";
  double? totalsum = 0.0;
  double totalReturnAmount = 0.0;
  double totalSalesAmount = 0.0;
  Future<List<Map<String, dynamic>>> fetchUnitSales(String invoiceNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/sales_item_view?invoiceNo=$invoiceNo'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        totalSalesAmount = 0.0;

        for (var entry in data) {
          totalSalesAmount += double.parse(entry['total']);
        }
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

//table item fetch
  Future<List<Map<String, dynamic>>> fetchUnitEntries(String salRetNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_sales_returns_individual_report?salRetNo=$salRetNo'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        invoiceNo = data[0]["invoiceNo"];
        totalReturnAmount = 0.0;
        for (var entry in data) {
          totalReturnAmount += double.parse(entry['total']);
        }
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }



  //customer details fetch
  // Future<List<Map<String, dynamic>>> fetchCustomerDetailsGet(String custCode) async {
  //   try {
  //     final response = await http.get(Uri.parse('http://localhost:3309/get_sales_return_report?custCode=$custCode'));
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data.cast<Map<String, dynamic>>();
  //     } else {
  //       throw Exception('Error loading customer details get: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to customer details get: $e');
  //   }
  // }
  double grandTotal = 0.0;

  @override
  Widget build(BuildContext context) {
    return  MyScaffold(route: "dcview",
        body: Form(
            key: _formKey,
            child:SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 5,),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
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
                                      Row(
                                        children: [
                                          const Icon(Icons.sell, size:30),
                                          Text("Sales Return Report",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      // for (var data in customerData)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: Container(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(
                                                      (widget.date != null)
                                                          ? DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.date!))
                                                          : "",
                                                    ),
                                                  ),
                                                  Divider(
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const Align(
                                                      alignment: Alignment.topLeft,
                                                      child: Text("Sales Return No",style: TextStyle(fontWeight: FontWeight.bold),)),
                                                  Align(
                                                      alignment: Alignment.topLeft,
                                                      child: Text(widget.salRetNo!))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ]
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          child: Container(
                            child: Column(
                              children: [
                                FutureBuilder(
                                    future: fetchUnitEntries(widget.salRetNo.toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error: ${snapshot.error}'));
                                      } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                        return FutureBuilder<List<Map<String, dynamic>>>(
                                            future: fetchUnitSales(invoiceNo.toString()),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Center(child: CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Center(child: Text('Error: ${snapshot.error}'));
                                              } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                                return Wrap(
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
                                                                  padding: const EdgeInsets.only(left:10),
                                                                  child: Text("Customer Details",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(height: 20,),
                                                              //customer date
                                                              Wrap(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: SizedBox(
                                                                      width: 180,
                                                                      //height: 30,
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

                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: SizedBox(
                                                                      width: 180,
                                                                      //height: 30,
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

                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: SizedBox(
                                                                      width: 180,
                                                                     // height: 30,
                                                                      child: TextFormField(
                                                                        readOnly: true,
                                                                        initialValue: snapshot.data![0]["custAddress"],
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
                                                                      width: 180,
                                                                      //height: 30,
                                                                      child: TextFormField(
                                                                        readOnly: true,
                                                                        initialValue: snapshot.data![0]["pincode"],
                                                                        style: TextStyle(
                                                                            fontSize: 13),
                                                                        keyboardType: TextInputType.text,
                                                                        decoration: InputDecoration(
                                                                            filled: true,
                                                                            fillColor: Colors.white,
                                                                            labelText: "Customer Pincode",
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
                                                                      width: 180,
                                                                      //height: 30,
                                                                      child: TextFormField(
                                                                        readOnly: true,

                                                                        initialValue: snapshot.data![0]["custMobile"].toString(),
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
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(height: 20,),
                                                              Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left:10),
                                                                    child: const Align(
                                                                        alignment:Alignment.topLeft,
                                                                        child: Text("Product Details",style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),)),
                                                                  ),
                                                                  const SizedBox(height: 20,),
                                                                  SingleChildScrollView(
                                                                    child: FutureBuilder<List<Map<String, dynamic>>>(
                                                                      future: fetchUnitSales(invoiceNo.toString()),
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
                                                                                defaultColumnWidth: FixedColumnWidth(120),
                                                                                columnWidths: {
                                                                                  0: FixedColumnWidth(70), // Adjust the width of the first column
                                                                                  1: FixedColumnWidth(200), // Adjust the width of the second column
                                                                                  2: FixedColumnWidth(200), // Adjust the width of the third column
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
                                                                                            child: Center(child: Text('Rate/Cone', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                        child: TableCell(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Center(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
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
                                                                                        TableCell(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Center(child:Text(entry.value['qty'].toString())),
                                                                                          ),
                                                                                        ),
                                                                                        TableCell(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Center(child: Text(entry.value['rate'].toString())),
                                                                                          ),
                                                                                        ),
                                                                                        TableCell(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Center(child: Align(
                                                                                                alignment:Alignment.topRight,

                                                                                                child: Text(entry.value['amt'].toString()))),
                                                                                          ),
                                                                                        ),
                                                                                        TableCell(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Center(child:
                                                                                            Align(
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
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [

                                                                      Padding(
                                                                        padding: const EdgeInsets.only(right: 20),
                                                                        child: Text("Total    $totalSalesAmount"),
                                                                      ),
                                                                    ],
                                                                  ),

                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left:10),
                                                                    child: const Align(
                                                                        alignment:Alignment.topLeft,
                                                                        child: Text("Return Product Details",style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),)),
                                                                  ),

                                                                  SingleChildScrollView(
                                                                    child: FutureBuilder<List<Map<String, dynamic>>>(
                                                                      future: fetchUnitEntries(widget.salRetNo.toString()),
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
                                                                                defaultColumnWidth: FixedColumnWidth(120),
                                                                                columnWidths: {
                                                                                  0: FixedColumnWidth(70),
                                                                                  1: FixedColumnWidth(200),
                                                                                  2: FixedColumnWidth(200),
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
                                                                                            child: Center(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
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
                                                                                        TableCell(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Center(child:Text(entry.value['qty'].toString())),
                                                                                          ),
                                                                                        ),
                                                                                        TableCell(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Center(child: Text(entry.value['rate'].toString())),
                                                                                          ),
                                                                                        ),
                                                                                        TableCell(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Center(child: Align(
                                                                                                alignment:Alignment.topRight,

                                                                                                child: Text(entry.value['amt'].toString()))),
                                                                                          ),
                                                                                        ),
                                                                                        TableCell(
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Center(child:
                                                                                            Align(
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
                                                                  /* Row(
                                                                children: [

                                                                  Text("$totalReturnAmount"),
                                                                ],
                                                              ),*/
                                                                  Row(mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(right: 20),
                                                                        child: Text("Total  $totalReturnAmount"),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(right: 20),
                                                                        child: Text("Grand Total: ${(totalSalesAmount - totalReturnAmount).toStringAsFixed(2)}"),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: 20),
                                                                  /*  Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(left:720),
                                                                        child: Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                      ),
                                                                      const SizedBox(width:2,),

                                                                      const Icon(Icons.currency_rupee,size:18,),
                                                                      const SizedBox(width:30,),
                                                                      SizedBox(
                                                                        width: 130,
                                                                        child: TextFormField(
                                                                          initialValue: widget.grandtotal.toString(),
                                                                          style: const TextStyle(fontSize: 13),
                                                                          validator: (value) {
                                                                            if (value!.isEmpty) {
                                                                              return '* Enter Grand Total';
                                                                            }
                                                                            return null;
                                                                          },
                                                                          keyboardType: TextInputType.number,
                                                                          textAlign: TextAlign.right,
                                                                          decoration: const InputDecoration(
                                                                              filled: true,
                                                                              fillColor: Colors.white,
                                                                              enabledBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(color: Colors.grey)
                                                                              )
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),*/


                                                                  // for (var data in customerData!)
                                                                  //
                                                                  //   Row(
                                                                  //   children: [
                                                                  //     const Padding(
                                                                  //       padding: EdgeInsets.only(left:670),
                                                                  //       child: Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  //     ),
                                                                  //     const SizedBox(width:20,),
                                                                  //     const Icon(Icons.currency_rupee,size:18,),
                                                                  //     SizedBox(
                                                                  //       width: 130,
                                                                  //       child: TextFormField(
                                                                  //         controller: TextEditingController(text:data["grandTotal"]),
                                                                  //         style: const TextStyle(fontSize: 13),
                                                                  //         validator: (value) {
                                                                  //           if (value!.isEmpty) {
                                                                  //             return '* Enter Main Grand Total';
                                                                  //           }
                                                                  //           return null;
                                                                  //         },
                                                                  //         keyboardType: TextInputType.number,
                                                                  //         decoration: const InputDecoration(
                                                                  //             filled: true,
                                                                  //             fillColor: Colors.white,
                                                                  //             enabledBorder: OutlineInputBorder(
                                                                  //                 borderSide: BorderSide(color: Colors.grey)
                                                                  //             )
                                                                  //         ),
                                                                  //       ),
                                                                  //     ),
                                                                  //   ],
                                                                  // ),
                                                                ],
                                                              ),





                                                            ],
                                                          ),

                                                        ),
                                                      ),
                                                      Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: MaterialButton(
                                                            color: Colors.green.shade600,
                                                            onPressed: (){
                                                              Navigator.pop(context);
                                                            },
                                                            child: const Text("BACK",style: TextStyle(color: Colors.white),),),
                                                        ),
                                                      ),
                                                    ]
                                                );
                                              }
                                              return Container();
                                            } );
                                      }
                                      return Container();
                                    }
                                )


                              ],
                            ),
                          ),
                        ),

                      ),
                    ),

                  ],
                )
            )
        ));
  }
}
