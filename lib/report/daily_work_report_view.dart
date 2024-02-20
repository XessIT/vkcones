
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/purchase_order_report.dart';

class DailyWorkView extends StatefulWidget {
  String? machineType;
  String? machineName;
  String? shiftType;
  String? assistentone;
  String? assistenttwo;
  String? operator;
  String? totalproduction;
  String? extraproduction;
  String? deliveryDate;
  String? deliveryType;
  String? qty;
  String? date;
  String? totQty;
  String? GSTIN;
  List<Map<String, dynamic>> customerData; // Add this line
  DailyWorkView({
    Key? key,
    required this.assistentone,
    required this.operator,
    required this.assistenttwo,
    required this.shiftType,
    required this.machineName,
    required this.machineType,
    required this.qty,
    required this.date,
    required this.extraproduction,
    required this.deliveryDate,
    required this.deliveryType,
    required this.totalproduction,
    required this.customerData, // Add this line
  }) : super(key: key);

  @override
  State<DailyWorkView> createState() => _DailyWorkViewState();
}


class _DailyWorkViewState extends State<DailyWorkView> {

  late List<Map<String, dynamic>> customerData;
  @override
  void initState() {
    super.initState();
    customerData = widget.customerData;
  }

  Future<List<Map<String, dynamic>>> fetchUnitEntries(String createDate,String shiftType,String machineName,String machineType) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/daily_work_status_view?createDate=$createDate&shiftType=$shiftType&machineName=$machineName&machineType=$machineType'));
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
    return  MyScaffold(
        route: "dailywork",backgroundColor: Colors.white,
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
                                    Container(constraints: BoxConstraints(maxWidth: 400),
                                      child: const Text(" Daily Work Status Report ", style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
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
                                                padding: const EdgeInsets.only(right:0.0),
                                                child: Text(widget.date.toString() != null ? DateFormat("dd-MM-yyyy").format(DateTime.parse("${widget.date}").toLocal()):"", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
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
                                child: Text("Employee Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
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
                                    initialValue: widget.shiftType.toString(),
                                    style: TextStyle(
                                        fontSize: 13),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Shift",
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
                                    initialValue: widget.machineType.toString(),
                                    style: TextStyle(
                                        fontSize: 13),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Machine",
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
                                    initialValue: widget.machineName.toString(),
                                    style: TextStyle(
                                        fontSize: 13),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Machine Name",
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
                                    initialValue: widget.totalproduction.toString(),
                                    style: TextStyle(
                                        fontSize: 13),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Production",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8,),
                                        )
                                    ),
                                  ),
                                ),
                              ],
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
                                    initialValue: widget.operator.toString(),
                                    style: TextStyle(
                                        fontSize: 13),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Person 1",
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
                                    initialValue: widget.assistentone.toString(),
                                    style: TextStyle(
                                        fontSize: 13),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Person 2",
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
                                    initialValue: widget.assistenttwo.toString(),
                                    style: TextStyle(
                                        fontSize: 13),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Person 3",
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
                                    initialValue: widget.extraproduction.toString(),
                                    style: TextStyle(
                                        fontSize: 13),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Extra Production",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8,),
                                        )
                                    ),
                                  ),
                                ),
                              ],
                            ),


                            Align(
                              alignment:Alignment.topLeft,
                              child:Padding(
                                padding: const EdgeInsets.only(top:10),
                                child: Text("Production Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30,),
                            Container(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: FutureBuilder<List<Map<String, dynamic>>>
                                  (
                                    future: fetchUnitEntries(
                                      widget.date.toString(),
                                      widget.shiftType.toString(),
                                      widget.machineName.toString(), // Assuming you have machineName property in your widget
                                      widget.machineType.toString(), // Assuming you have machineType property in your widget
                                    ),
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
                                            defaultColumnWidth: const FixedColumnWidth(100.0),
                                            columnWidths: const <int, TableColumnWidth>{
                                              0:FixedColumnWidth(52),
                                              1:FixedColumnWidth(100),
                                              2:FixedColumnWidth(100),
                                              3:FixedColumnWidth(100),
                                              4:FixedColumnWidth(100),
                                              5:FixedColumnWidth(150),
                                              6:FixedColumnWidth(150),
                                            },
                                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                            children:[
                                              //Table row starting
                                              TableRow(
                                                  children: [
                                                    //sno
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
                                                    //Finished GSM
                                                    TableCell(
                                                        child:Container(
                                                          color:Colors.blue.shade200,
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 8,),
                                                                Text('GSM',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                const SizedBox(height: 8,)
                                                              ],
                                                            ),),
                                                        )),
                                                    //Finished reel
                                                    TableCell(
                                                        child:Container(
                                                          color:Colors.blue.shade200,
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 8,),
                                                                Text('Reel',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                const SizedBox(height: 8,)
                                                              ],
                                                            ),),
                                                        )),
                                                    //Finished weight
                                                     TableCell(
                                                        child:Container(
                                                          color:Colors.blue.shade200,
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 8,),
                                                                Text('Weight',style: TextStyle(fontWeight: FontWeight.bold)),
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
                                                                Text('Prodused Cone',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                const SizedBox(height: 8,)
                                                              ],
                                                            ),),
                                                        )),
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
                                                        ))),
                                                      //gsm
                                                      TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${snapshot.data![i]["gsm"]}"),
                                                          const SizedBox(height: 10,)
                                                        ],
                                                      ))),
                                                      //reel
                                                      TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${snapshot.data![i]["finish_reel"]}"),
                                                          const SizedBox(height: 10,)
                                                        ],
                                                      ))),
                                                      //weight
                                                      TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${snapshot.data![i]["finish_weight"]}"),
                                                          const SizedBox(height: 10,)
                                                        ],
                                                      ))),
                                                      //itemGroup
                                                      TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${snapshot.data![i]["itemGroup"] ?? 'N/A'}"),
                                                          const SizedBox(height: 10,)
                                                        ],
                                                      ))),
                                                      //itemame
                                                      TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${snapshot.data![i]["itemName"]}"),
                                                          const SizedBox(height: 10,)
                                                        ],
                                                      ))),
                                                      //production
                                                      TableCell(child: Center(child: Column(
                                                        children: [
                                                          const SizedBox(height: 10,),
                                                          Text("${snapshot.data![i]["num_of_production"]}"),
                                                          const SizedBox(height: 10,)
                                                        ],
                                                      ))),

                                                    ]
                                                ),
                                              ],
                                            ]
                                        );
                                      }
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
