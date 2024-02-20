import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/master/balanacesheet_entry.dart';
import 'package:vinayaga_project/purchase/product_code_creation.dart';
import 'package:vinayaga_project/purchase/purchase_report.dart';

import '../report/supplier_report.dart';

class EditRawMaterial extends StatefulWidget {
  String? prodName;
  String? prodCode;
  String? unit;
  String? sNo;
  String? totalweight;
  int? qty;

  EditRawMaterial({Key? key,
    required this.prodCode,
    required this.prodName,
    required this.unit,
    required this.sNo,
    required this.totalweight,
    required this.qty,

  }) : super(key: key);

  //purchaseView({Key? key,required this.poNo, required this.date}) : super(key: key);

  @override
  State<EditRawMaterial> createState() => _EditRawMaterialState();
}

class _EditRawMaterialState extends State<EditRawMaterial> {



  TextEditingController prodNameController=TextEditingController();
  TextEditingController purchaseRate=TextEditingController();

  String? errorMessage="";


  @override
  void initState() {
    super.initState();
    prodNameController = TextEditingController();
    prodNameController.text = widget.prodName ?? '';
    errorMessage=null;
    // purchaseRate.text = widget.prodRate??"";
    productUnit= widget.unit;

  }
  String? productUnit;



  Future<List<Map<String, dynamic>>> fetchUnitEntries(String prodCode) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/productcode_edit?prodName=$prodCode'));

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


  Future<void> updateSupplierDetails(String prodCode, String prodName,String unit,/* String prodRate,*/ String modifyDate, Function(bool) callback) async {
    final response = await http.put(
      Uri.parse('http://localhost:3309/product_update/$prodCode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prodCode': prodCode,
        'prodName': prodName,
        'modifyDate': modifyDate,
        "unit":unit,
        // "prodRate":prodRate
      }),
    );
    if (response.statusCode == 200) {
      callback(true); // Update successful
    } else if (response.statusCode == 409) {
      callback(false); // ProdName already exists in the database
    } else {
      callback(false); // Other errors
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
          String id = item['prodCode']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['prodCode']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
        }
      }});
  }

  bool isDuplicate = false;


  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  @override
  Widget build(BuildContext context) {
    DateTime currentdate = DateTime.now();
    final formattedDate2 = DateFormat("yyyy-MM-dd").format(currentdate);
    final formattedDate = DateFormat("dd-MM-yyyy").format(currentdate);
    return  MyScaffold(
        route: "supplier view",backgroundColor: Colors.white,
        body: Form(
            key: _formKey,
            child:SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height:50,),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(

                          width:700, // Set the width to full page width
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
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
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.edit, // Replace with the icon you want to use
                                              ),
                                              Text("Edit Raw Material", style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20
                                              ),),

                                            ],
                                          ),
                                          Text(
                                            formattedDate,
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                          height: 175,
                          child: Column(
                            children: [
                              Wrap(
                                  children: [
                                    SizedBox(height: 20,),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        // height: 220,
                                        // width: 700, // Set the width to full page width
                                        padding: EdgeInsets.all(16.0), // Add padding for spacing
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          border: Border.all(color: Colors.grey), // Add a border for the box
                                          borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                                        ),
                                        child: Padding(
                                          padding:  EdgeInsets.only(left: 20),
                                          child: Column(
                                            children: [
                                              const Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text("Enter Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Row(mainAxisAlignment: MainAxisAlignment.end,
                                                children: [  Text(
                                                  errorMessage ?? '',
                                                  style: TextStyle(color: Colors.red),
                                                ),],),

                                              SizedBox(height: 10,),
                                              Wrap(
                                                spacing: 50,

                                                // mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 220,
                                                    height: 40,
                                                    child: TextFormField(
                                                      // readOnly: true,
                                                      initialValue: widget.prodCode.toString(),
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                      keyboardType: TextInputType.text,
                                                      inputFormatters: [
                                                        UpperCaseTextFormatter(),
                                                      ],
                                                      decoration: InputDecoration(

                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Product Code",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8,),
                                                          )
                                                      ),
                                                      onChanged: (value){
                                                        setState(() {
                                                          errorMessage = null; // Reset error message when user types
                                                        });
                                                        prodNameController.text=value;
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 220,
                                                    height: 40,
                                                    child: TextFormField(
                                                      // readOnly: true,
                                                      initialValue: widget.prodName.toString(),
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                      keyboardType: TextInputType.text,
                                                      inputFormatters: [
                                                        UpperCaseTextFormatter(),
                                                      ],
                                                      decoration: InputDecoration(

                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Product Name",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8,),
                                                          )
                                                      ),
                                                      onChanged: (value){
                                                        setState(() {
                                                          errorMessage = null; // Reset error message when user types
                                                        });
                                                        prodNameController.text=value;
                                                      },
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: !widget.prodName.toString().startsWith("GSM"),
                                                    child: SizedBox(
                                                      width: 220,
                                                      height: 40,
                                                      child: TextFormField(
                                                        initialValue: widget.qty.toString(),
                                                        style: TextStyle(fontSize: 13),
                                                        keyboardType: TextInputType.text,
                                                        inputFormatters: [UpperCaseTextFormatter()],
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Quantity",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            errorMessage = null;
                                                          });
                                                          prodNameController.text = value;
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: widget.prodName.toString().startsWith("GSM"),
                                                    child: SizedBox(
                                                      width: 220,
                                                      height: 40,
                                                      child: TextFormField(
                                                        initialValue: widget.sNo.toString(),
                                                        style: TextStyle(fontSize: 13),
                                                        keyboardType: TextInputType.text,
                                                        inputFormatters: [UpperCaseTextFormatter()],
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "S.No",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            errorMessage = null;
                                                          });
                                                          prodNameController.text = value;
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: widget.prodName.toString().startsWith("GSM"),
                                                    child: SizedBox(
                                                      width: 220,
                                                      height: 40,
                                                      child: TextFormField(
                                                        initialValue: widget.totalweight.toString(),
                                                        style: TextStyle(fontSize: 13),
                                                        keyboardType: TextInputType.text,
                                                        inputFormatters: [UpperCaseTextFormatter()],
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Weight",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            errorMessage = null;
                                                          });
                                                          prodNameController.text = value;
                                                        },
                                                      ),
                                                    ),
                                                  )

                                                ],
                                              ),


                                            ],
                                          ),
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
                    SizedBox(width: 20,height: 50,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          color: Colors.green.shade600,
                          onPressed: () async {
                            if (prodNameController.text.isNotEmpty) {
                              updateSupplierDetails(
                                  widget.prodCode.toString(),
                                  prodNameController.text,
                                  productUnit.toString(),
                                  formattedDate2.toString(),

                                      (bool isUpdateSuccessful) {
                                    if (isUpdateSuccessful) {
                                      showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Product"),
                                              content: const Text("Updated Successfully"),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCodeCreation()));
                                                  },
                                                  child: Text("OK"),
                                                ),
                                              ],
                                            );
                                          });
                                    }
                                    else {
                                      setState(() {
                                        errorMessage = '* Product Name already exist';
                                      });
                                    }
                                  }
                              );
                            }
                            else {
                              setState(() {
                                errorMessage = '* Enter a Product Name';
                              });
                            }
                          },
                          child: const Text("UPDATE", style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(width: 20,),
                        MaterialButton(
                          color: Colors.blue.shade600,
                          onPressed: (){
                            Navigator.pop(context);
                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>const ProductCodeCreation()));
                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>const ProductCodeCreation()));
                          },
                          child: const Text("BACK",style: TextStyle(color: Colors.white),),),
                      ],
                    ),

                  ],
                )
            )

        ));
  }
}
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}