import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;

class preturnView extends StatefulWidget {
  String? preturnNo;
  int? supMobile;
  String? date;
  String? supName;
  String? supCode;
  String? supAddress;
  String? prodCode;
  String? prodName;
  String? qty; String? amtGST; String? rate;String? total;String? pincode;
  preturnView({Key? key, required this.preturnNo,required this.date,
    required this.supCode,
    required this.supMobile,
    required this.supName,
    required this.supAddress,
    required this.prodCode,
    required this.prodName,
    required this.qty,
    required this.rate,
    required this.amtGST,
    required this.total, required this.pincode,

  }) : super(key: key);

  //purchaseView({Key? key,required this.poNo, required this.date}) : super(key: key);

  @override
  State<preturnView> createState() => _preturnViewState();
}

class _preturnViewState extends State<preturnView> {
  String? callinvoiceNo="";
  double totalReturnAmount = 0.0;
  double totalSalesAmount = 0.0;
  Future<List<Map<String, dynamic>>> fetchUnitEntries(String preturnNo) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/get_preturn_view?preturnNo=$preturnNo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        callinvoiceNo = data[0]["invoiceNo"];
        print("$callinvoiceNo :call invoiceNo");
        totalReturnAmount = 0.0;
        for (var entry in data) {
          totalReturnAmount += double.parse(entry['total']);
        }
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }
  Future<List<Map<String, dynamic>>> fetchPurchase(String invoiceNo) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/purchase_view?invoiceNo=$invoiceNo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        totalSalesAmount = 0.0;
        for (var entry in data) {
          totalSalesAmount += double.parse(entry['total']);
        }

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
  // List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  bool showInitialData = true;
  double grandTotal = 0.0;


  /* @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (showInitialData) {
      filterData('');
    }
  }*/
  List<Map<String, dynamic>> filteredCodeData = [];
/*
  void filterData(String searchText) {
    setState(() {
      filteredData = [];
      if (searchText.isNotEmpty) {
        filteredData = data.where((item) {
          String id = item['preturnNo']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['preturnNo']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
          callinvoiceNo =data[0]["invoiceNo"];
        }
      }});
  }
*/





  @override
  Widget build(BuildContext context) {
    DateTime Date = DateTime.now();
    final formattedDate = DateFormat("dd-MM-yyyy").format(Date);
    return  MyScaffold(
        route: "purchase view",
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
                          height: 130,
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
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.shopping_cart, // Replace with the icon you want to use
                                                  // Replace with the desired icon color
                                                ),
                                                const Text("Purchase Return Report", style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20
                                                ),),
                                              ],
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.only(left: 730,top: 10),
                                            child: Container(
                                              // width: 130,
                                                child: SizedBox(
                                                  width:90,
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
                                                            Text("Return Number",style: TextStyle(fontWeight: FontWeight.bold),)),
                                                        Align(
                                                          alignment: Alignment.topLeft,
                                                          child://Text("009"),
                                                          Text(widget.preturnNo.toString(),style: TextStyle(
                                                              color: Colors.black
                                                          ),),
                                                        )],
                                                    ),
                                                  ),
                                                )),
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
                                                child:Padding(
                                                  padding: const EdgeInsets.only(left:10,top: 10,bottom: 10),
                                                  child: Text(" Supplier Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(height: 10,),

                                              Padding(
                                                padding: const EdgeInsets.only(left:14),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
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
                                                    ), SizedBox(width:11),
                                                    SizedBox(
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
                                                    ), SizedBox(width:11),
                                                    SizedBox(
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
                                                    ), SizedBox(width:11),
                                                    SizedBox(
                                                      width: 200,
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
                                                            labelText: "Supplier Pincode",
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(8,),
                                                            )
                                                        ),
                                                      ),
                                                    ), SizedBox(width:11),
                                                    SizedBox(
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
                                                    ), SizedBox(width:11),
                                                    /* SizedBox(
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
                                                    ),*/
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10,),

                                              /*   Center(
                                                child:
                                                SingleChildScrollView(
                                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                                    future: fetchPurchase(callinvoiceNo!),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return Center(child: CircularProgressIndicator());
                                                      } else if (snapshot.hasError) {

                                                        return Center(child: Text('Error: ${snapshot.error}'));
                                                      } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                                        return Container(
                                                          padding: EdgeInsets.all(16.0),
                                                          child: Table(
                                                            columnWidths: {
                                                              0: FixedColumnWidth(60), // Adjust the width of the first column
                                                              1: FixedColumnWidth(180), // Adjust the width of the second column
                                                              2: FixedColumnWidth(180),
                                                              3: FixedColumnWidth(150), // Adjust the width of the second column
                                                              4: FixedColumnWidth(140),
                                                              5: FixedColumnWidth(100),
                                                              6: FixedColumnWidth(100),// Adjust the width of the second column
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
                                                                    TableCell(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Center(child: Text(entry.value['rate'].toString())),
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
                                              SizedBox(height: 20),*/

                                              ///Return table view starts
                                              Center(
                                                child:
                                                SingleChildScrollView(
                                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                                    future: fetchUnitEntries(widget.preturnNo.toString()),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return Center(child: CircularProgressIndicator());
                                                      } else if (snapshot.hasError) {
                                                        return Center(child: Text('Error: ${snapshot.error}'));
                                                      } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                                                        return FutureBuilder<List<Map<String, dynamic>>>(
                                                            future: fetchPurchase(callinvoiceNo.toString()),
                                                            builder: (context, snapshotsales) {
                                                              if (snapshotsales.connectionState == ConnectionState.waiting) {
                                                                return Center(child: CircularProgressIndicator());
                                                              } else if (snapshotsales.hasError) {
                                                                return Center(child: Text('Error: ${snapshotsales.error}'));
                                                              } else if (snapshotsales.data != null && snapshotsales.data!.isNotEmpty) {

                                                                return Column(
                                                                  children: [
                                                                    Align(
                                                                      alignment:Alignment.topLeft,
                                                                      child:Padding(
                                                                        padding: const EdgeInsets.only(left:14),
                                                                        child: Text("Product Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      padding: EdgeInsets.all(16.0),
                                                                      child: Table(
                                                                        columnWidths: const{
                                                                          0: FixedColumnWidth(60), // Adjust the width of the first column
                                                                          1: FixedColumnWidth(180), // Adjust the width of the second column
                                                                          2: FixedColumnWidth(180),
                                                                          3: FixedColumnWidth(150), // Adjust the width of the second column
                                                                          4: FixedColumnWidth(140),
                                                                          5: FixedColumnWidth(100),
                                                                          6: FixedColumnWidth(100),// Adjust the width of the second column
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
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: TableCell(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Center(child: Text('Rate per Unit', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                                  ),
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
                                                                          for (var entry in snapshotsales.data!.asMap().entries)
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
                                                                                TableCell(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Center(child: Text(entry.value['rate'].toString())),
                                                                                  ),
                                                                                ),
                                                                                // TableCell(
                                                                                //   child: Padding(
                                                                                //     padding: const EdgeInsets.all(8.0),
                                                                                //     child: Center(child: Text(entry.value['totalWeight'].toString())),
                                                                                //   ),
                                                                                // ),
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
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(right: 20),
                                                                          child: Text("Total:   $totalSalesAmount"),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    SizedBox(height: 10,),
                                                                    ///return Product details  starts

                                                                    Align(
                                                                      alignment:Alignment.topLeft,
                                                                      child:Padding(
                                                                        padding: const EdgeInsets.only(left:14),
                                                                        child: Text("Return Product Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    ///return Product details  ends


                                                                    ///return Product details table starts
                                                                    Container(

                                                                      padding: EdgeInsets.all(16.0),
                                                                      child: Table(
                                                                        columnWidths:const {
                                                                          0: FixedColumnWidth(60), // Adjust the width of the first column
                                                                          1: FixedColumnWidth(180), // Adjust the width of the second column
                                                                          2: FixedColumnWidth(180),
                                                                          3: FixedColumnWidth(150), // Adjust the width of the second column
                                                                          4: FixedColumnWidth(140),
                                                                          5: FixedColumnWidth(100),
                                                                          6: FixedColumnWidth(100),// Adjust the width of the second column
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
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: TableCell(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Center(child: Text('Rate per Unit', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            /*  Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: TableCell(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Center(child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                                                                                  ),
                                                                                ),
                                                                              ),*/
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
                                                                                TableCell(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Center(child: Text(entry.value['rate'].toString())),
                                                                                  ),
                                                                                ),
                                                                               /* TableCell(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Center(child: Text(entry.value['totalWeight'].toString())),
                                                                                  ),
                                                                                ),*/
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
                                                                    ),
                                                                    SizedBox(height: 20,),
                                                                    Row(mainAxisAlignment: MainAxisAlignment.end,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(right: 20),
                                                                          child: Text("Total:  $totalReturnAmount"),
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
                                                                    ///return Product details table ends

                                                                  ],
                                                                );
                                                              }return Container();}
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
                                              ///Return table view ends

                                              ///Return grandtotall view starts
/*
                                              FutureBuilder<List<Map<String, dynamic>>>(
                                                future: fetchUnitEntries(widget.preturnNo!),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return Center(child: CircularProgressIndicator());
                                                  } else if (snapshot.hasError) {
                                                    return Center(child: Text('Error: ${snapshot.error}'));
                                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                                    return Center(child: Text('No data available.'));
                                                  } else {
                                                    final grandTotal = snapshot.data![0]["grandTotal"]; // Assuming "grandTotal" is a key in the map

                                                    return Column(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 861,bottom:30),
                                                          child: Row(
                                                            children: [
                                                              Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold)),
                                                              const SizedBox(width: 20),
                                                              const Icon(Icons.currency_rupee, size: 18),
                                                              SizedBox(
                                                                width: 93,
                                                                child: TextFormField(
                                                                  readOnly: true,
                                                                  controller: TextEditingController(text: grandTotal),
                                                                  style: const TextStyle(fontSize: 13),
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
*/

                                              ///Return grandtotall view ends
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
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>const PurchaseReturnReport()));
                        },
                        child: const Text("BACK",style: TextStyle(color: Colors.white),),),
                    ),
                  ],
                )
            )
        ));
  }
}
