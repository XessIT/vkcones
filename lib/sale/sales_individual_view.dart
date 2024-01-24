import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';

class SalesView extends StatefulWidget {
  final String? invoiceNo;
  final String? custName;
  final String? custCode;
  final String? custAddress;
  final String? grandtotal;
  final String? date;
  final String? itemGroup;
  final String? custpincode;
  final String? customerData;
  final String? transportNo;
  final int? custmobile;
  //final List<Map<String, dynamic>> customerData;
  const SalesView({required this.customerData ,Key? key,
    required this.invoiceNo,
    required this.custName,
    required this.custCode,
    required this.custAddress,
    required this.custmobile,
    required this.date,
    required this.grandtotal,
    required this.itemGroup, required this.custpincode, required this.transportNo
  }) : super(key: key);

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  TextEditingController grandTotalController = TextEditingController();
  double totalGST = 0.0;
  double totalSales = 0.0;
  double totalqty = 0.0;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? callValue = "";
  String checkOrderNo ="";

  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invoiceNo) async {
    try {
      final url = Uri.parse('http://localhost:3309/sales_item_view?invoiceNo=$invoiceNo');
      final response = await http.get(url);


      // final response = await http.get(Uri.parse('http://localhost:3309/sales_item_view?invoiceNo=$invoiceNo'));
      /*  if (response.statusCode == 200) {
        final List<dynamic> data1 = json.decode(response.body);
        setState(() {
          checkOrderNo =  data1[0]["checkOrderNo"].isEmpty?data1[0]["orderNo"]:data1[0]["checkOrderNo"];
        });
        return data1.cast<Map<String, dynamic>>();
      } else */
      if(response.statusCode == 200){
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

/*
  Future<void> fetchCheckOrderNo(String invoiceNo) async {
    try {
      final url = Uri.parse('http://localhost:3309/sales_item_view?invoiceNo=$invoiceNo');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          checkOrderNo =  data[0]["checkOrderNo"].isEmpty?data[0]["orderNo"]:data[0]["checkOrderNo"];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
*/

/*
  Future<List<Map<String, dynamic>>> fetchReturnItems(String invoiceNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/sales_return_item_view?invoiceNo=$invoiceNo'));
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
*/

  double grandTotal = 0.0;


  String checkOrderNumber ="";

  @override
  Widget build(BuildContext context) {
    String? orderNo;
    String? checkOrderNo;
    print("- customer data starts ${widget.customerData}- customer data ends");

    // Find the first map in customerData that contains "orderNo" and "checkOrderNo" fields
    /*  for (Map<String, dynamic> data in widget.customerData) {


      if (data.containsKey("checkOrderNo")) {
        checkOrderNumber = data["checkOrderNo"];
      }else if(checkOrderNumber != null){
        if (data.containsKey("orderNo")) {
          checkOrderNumber = data["orderNo"];
        }

      }

      // If both values are found, break out of the loop
      if (checkOrderNumber != null && checkOrderNumber != null) {
        break;
      }
    }
    //fetchCheckOrderNo(widget.invoiceNo.toString());

    List<Map<String, dynamic>> customerData = widget.customerData;
*/

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
                                          const Padding(
                                            padding: EdgeInsets.only(right:20),
                                            child: Text("Sales Report",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
                                          ),
                                        ],
                                      ),

                                      // for (var data in customerData)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0,right:15),
                                        child: Column(
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
                                                            ? DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.date!).toLocal())
                                                            : "",
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    const Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Text("Invoice No",style: TextStyle(fontWeight: FontWeight.bold),)),
                                                    Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Text(widget.invoiceNo!)),
                                                    const Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Text("Order No",style: TextStyle(fontWeight: FontWeight.bold),)),
                                                    Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Text(widget.customerData.toString())),

                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                                  padding: const EdgeInsets.only(left:10),
                                                  child: Text("Customer Details",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              //    Text(widget.itemGroup/);
                                              SizedBox(height: 20,),
                                              Wrap(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 180,
                                                     // height: 30,
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
                                                  /* SizedBox(
                                                      width:15,height: 3,
                                                  ),*/
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 180,
                                                     // height: 30,
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
                                                  /* SizedBox(
                                                    width:15,height: 3,
                                                  ),*/
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 180,
                                                    //  height: 30,
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
                                                  /*SizedBox(
                                                    width:15,height: 3,
                                                  ),*/
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 180,
                                                     // height: 30,
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue: widget.custpincode,
                                                        style: TextStyle(
                                                            fontSize: 13),
                                                        keyboardType: TextInputType.text,
                                                        decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            labelText: "Customer Pin code",
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(8,),
                                                            )
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  /* SizedBox(
                                                    width:15,height: 3,
                                                  ),*/
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 180,
                                                      //height: 30,
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue: widget.custmobile.toString(),
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
                                                  ), Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 180,
                                                      //height: 30,
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue: widget.transportNo.toString(),
                                                        style: TextStyle(
                                                            fontSize: 13),
                                                        keyboardType: TextInputType.text,
                                                        decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            labelText: "Transport No",
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
                                                  FutureBuilder<dynamic>(
                                                    future: fetchUnitEntries(widget.invoiceNo.toString()),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return Center(child: CircularProgressIndicator());
                                                      } else if (snapshot.hasError) {
                                                        return Center(child: Text('Error: ${snapshot.error}'));
                                                      } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                                        return SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: Container(
                                                            //   padding: EdgeInsets.all(16.0),
                                                            child: Table(
                                                              defaultColumnWidth: FixedColumnWidth(90), // Set your desired default width here
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
                                                                          child: Center(child: Text('Total Cone', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
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
                                                                          child: Center(child: Text('GST(%)', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
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
                                                                          child: Center(child: Text('Amount GST', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
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
                                                                          child: Center(child:Text(entry.value['totalCone'].toString())),
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
                                                                          child: Center(child: Text(entry.value['gst'].toString())),
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


                                                  SizedBox(height: 20),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,

                                                        children: [
                                                          const Padding(
                                                            padding: EdgeInsets.only(left:0),
                                                            child: Row(
                                                              children: [
                                                                Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                const SizedBox(width:2,),

                                                                const Icon(Icons.currency_rupee,size:18,),
                                                                const SizedBox(width:30,),
                                                              ],
                                                            ),
                                                          ),


                                                          SizedBox(
                                                            width: 130,
                                                            child: TextFormField(
                                                              initialValue: widget.grandtotal,
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
                                                  ),


                                                  const SizedBox(height: 20,),
                                                  //  if(fetchReturnItems(widget.invoiceNo.toString()) != null)

/*
                                                    SingleChildScrollView(
                                                    child: FutureBuilder<List<Map<String, dynamic>>>(
                                                      future: fetchReturnItems(widget.invoiceNo.toString()),
                                                      builder: (context, snapshot) {
                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                          return Center(child: CircularProgressIndicator());
                                                        } else if (snapshot.hasError) {
                                                          return Center(child: Text('Error: ${snapshot.error}'));
                                                        } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                                          return Container(
                                                            padding: EdgeInsets.all(16.0),
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left:10),
                                                                  child: const Align(
                                                                      alignment:Alignment.topLeft,
                                                                      child: Text("Return Product Details",style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),)),
                                                                ),
                                                                Table(
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
                                                                              child: Center(child: Text('GST', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
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
                                                                              child: Center(child: Text('Amount GST', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                            ),
                                                                          ),
                                                                        ), Padding(
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
                                                                         */
/* TableCell(
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Center(child:Text(entry.value['totalCone'].toString())),
                                                                            ),
                                                                          ),*//*

                                                                          TableCell(
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Center(child: Text(entry.value['rate'].toString())),
                                                                            ),
                                                                          ),
                                                                          TableCell(
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Center(child: Text(entry.value['gst'].toString())),
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

                                                                                  child: InkWell(child: Text(entry.value['total'].toString())))),
                                                                            ),
                                                                          ),
                                                                        ],
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
*/

                                                  /* SizedBox(height: 20),
                                                  Column(
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
                                                              initialValue: widget.grandtotal,
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
                                                  ),
                                                  SizedBox(height: 20,),*/

                                                ],
                                              ),





                                            ],
                                          ),
                                        ),
                                      ),
                                    ]
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
