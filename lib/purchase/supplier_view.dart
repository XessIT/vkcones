import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/purchase_report.dart';

import '../report/supplier_report.dart';

class supplierView extends StatefulWidget {



  int id;
  int supMobile;
  String? supName;
  String? supCode;
  String? supAddress;
  String? pincode;

  supplierView({Key? key,
    required this.id,
    required this.supCode,
    required this.supMobile,
    required this.supName,
    required this.supAddress,
    required this.pincode,

  }) : super(key: key);

  //purchaseView({Key? key,required this.poNo, required this.date}) : super(key: key);

  @override
  State<supplierView> createState() => _supplierViewState();
}

class _supplierViewState extends State<supplierView> {

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  TextEditingController supNameController=TextEditingController();
  TextEditingController supAddressController=TextEditingController();
  TextEditingController supMobileController=TextEditingController();
  TextEditingController pincodecontroller=TextEditingController();
  String? errorMessage="";
  @override
  void initState() {
    super.initState();
    // Initialize controllers
    supNameController = TextEditingController();
    supAddressController = TextEditingController();
    supMobileController = TextEditingController();



    // Set initial values from widget
    supNameController.text = widget.supName ?? '';
    supAddressController.text = widget.supAddress ?? '';
    pincodecontroller.text = widget.pincode ?? '';
    supMobileController.text = widget.supMobile.toString();

  }


  Future<List<Map<String, dynamic>>> fetchUnitEntries(String supCode) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/supplier_view?supCode=$supCode'));

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


  Future<void> updateSupplierDetails(String id, String supName, String supAddress,String pincode, String supMobile,String modifyDate) async {
    final response = await http.put(
      Uri.parse('http://localhost:3309/supplier_update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'supName': supNameController.text,
        'supAddress': supAddressController.text,
        'pincode':pincodecontroller.text,
        'supMobile': supMobileController.text,
        'modifyDate':modifyDate,
      }),
    );

    if (response.statusCode == 200) {
      print('Data updated successfully');
    } else {
      print('Error updating data: ${response.body}');
    }
  }

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
          String id = item['supCode']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['supCode']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
        }
      }});
  }





  @override
  Widget build(BuildContext context) {
    DateTime currentdate = DateTime.now();
    final formattedDate = DateFormat("dd-MM-yyyy").format(currentdate);
    return  MyScaffold(
        route: "supplier view",
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
                          height: 100,
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
                                        padding: const EdgeInsets.only(top: 25),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.shopping_cart, // Replace with the icon you want to use
                                            ),
                                            Text("Supplier Edit", style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20
                                            ),),
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 20,),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 25),
                                          child: Text(
                                            formattedDate,
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Supplier Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        errorMessage ?? '',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15,),
                                  Wrap(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 220,
                                          height: 30,
                                          child: TextFormField(
                                            readOnly: true,
                                            initialValue: widget.supCode.toString(),
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
                                      SizedBox(width:40),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 220,
                                          height: 30,
                                          child: TextFormField(
                                            readOnly: true,
                                            controller: supNameController,
                                           // initialValue: widget.supName.toString(),
                                            style: TextStyle(
                                                fontSize: 13),
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(

                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "Supplier/Company Name",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8,),
                                                )
                                            ),
                                            onChanged: (value){
                                              supNameController.text=value;
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              supNameController.value = supNameController.value.copyWith(
                                                  text: capitalizedValue,
                                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),);
                                              setState(() {
                                                errorMessage=null;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width:40),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 220,
                                          height: 30,
                                          child: TextFormField(
                                            //readOnly: true,
                                            //initialValue: widget.supAddress.toString(),
                                            controller: supAddressController,
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
                                            onChanged: (value){
                                              supAddressController.text=value;
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              supAddressController.value = supAddressController.value.copyWith(
                                                text: capitalizedValue,
                                                selection: TextSelection.collapsed(offset: capitalizedValue.length),);
                                              setState(() {
                                                errorMessage=null;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width:40),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 220,
                                          height: 30,
                                          child: TextFormField(
                                            controller: pincodecontroller,
                                            style: TextStyle(
                                                fontSize: 13),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(6)
                                            ],
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "Pincode",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8,),
                                                )
                                            ),
                                            onChanged: (value){
                                              pincodecontroller.text=value;
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              pincodecontroller.value = pincodecontroller.value.copyWith(
                                                text: capitalizedValue,
                                                selection: TextSelection.collapsed(offset: capitalizedValue.length),);
                                              setState(() {
                                                errorMessage=null;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width:40),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 220,
                                          height: 30,
                                          child: TextFormField(
                                            //readOnly: true,
                                            initialValue: widget.supMobile.toString(),
                                            style: TextStyle(
                                                fontSize: 13),
                                            decoration: InputDecoration(
                                                prefixText: "+91",
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "Supplier Mobile",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                )

                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(10)
                                            ],
                                            onChanged: (value){
                                              supMobileController.text=value;
                                              setState(() {
                                                errorMessage=null;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 450,top: 20),
                      child: Row(
                        children: [
                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () {
                              if (supNameController.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Supplier/Company Name';
                                });
                                return;
                              }
                              if (supAddressController.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Supplier Address';
                                });
                                return;
                              }
                              if (pincodecontroller.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Pincode';
                                });
                                return;
                              }else if (pincodecontroller.text.length != 6) {
                                setState(() {
                                  errorMessage = '* Enter a valid pincode';
                                });
                                return;
                              }
                              if (supMobileController.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Supplier Mobile Number ';
                                });
                                return;
                              } else if (supMobileController.text.length != 10) {
                                setState(() {
                                  errorMessage = '* Mobile Number should be\n 10 Digit';
                                });
                                return;
                              } else {
                                // If all conditions are met, proceed with saving data
                                updateSupplierDetails(
                                  widget.id.toString(),
                                  supNameController.text,
                                  supAddressController.text,
                                  pincodecontroller.text,
                                  supMobileController.text,
                                  formattedDate,
                                );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Supplier"),
                                      content: Text("Saved successfully."),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SupplierReport(),
                                              ),
                                            );
                                          },
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text("UPDATE", style: TextStyle(color: Colors.white)),
                          ),


                          SizedBox(width: 20,),
                          MaterialButton(
                            color: Colors.blue.shade600,
                            onPressed: (){
                              Navigator.pop(context);
                            //  Navigator.push(context, MaterialPageRoute(builder: (context)=>const SupplierReport()));
                            },
                            child: const Text("BACK",style: TextStyle(color: Colors.white),),),
                        ],
                      ),
                    ),
                  ],
                )
            )
        ));
  }
}
