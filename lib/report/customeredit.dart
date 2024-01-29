import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'customer_report.dart';


class custedit extends StatefulWidget {
  int id;
  int custMobile;
  String? date;
  String? custName;
  String? custCode;
  String? pincode;
  String? custAddress;
  String? gstin;
  String? orderNo;
  custedit({Key? key,
    required this.id,
    required this.date,
    required this.custCode,
    required this.custMobile,
    required this.custName,
    required this.pincode,
    required this.custAddress,
    required this.gstin,
    required List<Map<String, dynamic>> customerData}) : super(key: key);

  //dcViwe({Key? key,required this.dcNo, required this.date}) : super(key: key);

  @override
  State<custedit> createState() => _custeditState();
}

class _custeditState extends State<custedit> {
  TextEditingController custNameController= TextEditingController();
  TextEditingController custAddressController= TextEditingController();
  TextEditingController custMobileController= TextEditingController();
  TextEditingController gstinController= TextEditingController();
  TextEditingController pincodeController= TextEditingController();
  TextEditingController formattedDate=TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  bool showInitialData = true;
  String? errorMessage="";
  static final RegExp gstregex2 = RegExp(r"^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d{1}[Z]{1}[A-Z\d]{1}$");
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    custNameController = TextEditingController();
    custAddressController = TextEditingController();
    custMobileController = TextEditingController();
    gstinController = TextEditingController();
    pincodeController = TextEditingController();
    formattedDate=TextEditingController();

    custNameController.text = widget.custName ?? '';
    custAddressController.text = widget.custAddress ?? '';
    custMobileController.text = widget.custMobile.toString();
    gstinController.text = widget.gstin ?? '';
    pincodeController.text = widget.pincode ?? '';
  }



  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> updateCustomerDetails(String id, String custName, String custAddress,String pincode, String custMobile, String gstin, String modifyDate) async {
    final response = await http.put(
      Uri.parse('http://localhost:3309/custupdate_update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'custName': custNameController.text,
        'custAddress': custAddress,
         'pincode':pincode,
        'custMobile': custMobile,
        'gstin': gstin,
        'modifyDate':modifyDate,
      }),
    );

    if (response.statusCode == 200) {
      print('Data updated successfully');
    } else {
      print('Error updating data: ${response.body}');
    }
  }




  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(currentDate);
    return  MyScaffold(route: "cust_edit",backgroundColor: Colors.white,
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
                          child:  Column(
                            children: [
                              Wrap(
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [   Icon(Icons.edit),SizedBox(width: 1,),
                                            const Text("  Customer Edit", style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25
                                            ),),],),
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat('dd-MM-yyyy').format(currentDate), // Change the date format here
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
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
                      child: Wrap(
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
                                        child: Text(" Customer Details",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          errorMessage ?? '',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20,),

                                    Wrap(
                                      spacing: 20.0, // Set the horizontal spacing between the children
                                      runSpacing: 20.0,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            width: 180,
                                            height: 30,
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
                                            height: 30,
                                            child: TextFormField(
                                              readOnly: true,
                                              initialValue: widget.custName.toString(),
                                              style: TextStyle(
                                                  fontSize: 13),
                                              onChanged: (value) {
                                                setState(() {
                                                  errorMessage = null; // Reset error message when user types
                                                });
                                                String capitalizedValue = capitalizeFirstLetter(value);
                                                custNameController.value = custNameController.value.copyWith(
                                                  text: capitalizedValue,
                                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                );
                                                setState(() {
                                                  errorMessage = null; // Reset error message when user types
                                                });

                                              },
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
                                            height: 30,
                                            child: TextFormField(
                                              //controller: custAddressController,
                                              initialValue: widget.custAddress,
                                              onChanged: (value) {
                                                setState(() {
                                                  errorMessage = null; // Reset error message when user types
                                                });
                                                String capitalizedValue = capitalizeFirstLetter(value);
                                                custAddressController.value = custAddressController.value.copyWith(
                                                  text: capitalizedValue,
                                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                );
                                                setState(() {
                                                  errorMessage = null; // Reset error message when user types
                                                });

                                              },
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
                                            height: 30,
                                            child: TextFormField(
                                              //controller: custMobileController,
                                              initialValue: widget.pincode.toString(),
                                              onChanged: (value){
                                                pincodeController.text =value;
                                              },
                                              style: TextStyle(
                                                  fontSize: 13),
                                              decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  labelText: " Pincode ",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8,),
                                                  )
                                              ),
                                              keyboardType: TextInputType.text,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(6),
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                    SizedBox(width: 10,),
                                    Wrap(
                                      spacing: 20.0, // Set the horizontal spacing between the children
                                      runSpacing: 20.0,
                                      children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 180,
                                          height: 30,
                                          child: TextFormField(
                                            //controller: custMobileController,
                                            initialValue: widget.custMobile.toString(),
                                            onChanged: (value){
                                              custMobileController.text =value;
                                            },
                                            style: TextStyle(
                                                fontSize: 13),
                                            decoration: InputDecoration(
                                                prefixText: "+91",
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "Customer Mobile",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8,),
                                                )
                                            ),
                                            keyboardType: TextInputType.text,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(10),
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 180,
                                          height: 30,
                                          child: TextFormField(
                                            //controller: gstinController,
                                            initialValue: widget.gstin.toString(),
                                            onChanged: (value) {
                                              setState(() {
                                                errorMessage = null; // Reset error message when user types
                                              });
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              gstinController.value = gstinController.value.copyWith(
                                                text: capitalizedValue,
                                                selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                              );
                                              setState(() {
                                                errorMessage = null; // Reset error message when user types
                                              });

                                            },
                                            style: TextStyle(
                                                fontSize: 13),

                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "GSTIN",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8,),
                                                )
                                            ),
                                          ),
                                        ),
                                      ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(  width: 180,
                                            height: 30,
                                          child:Text("")),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(  width: 180,
                                              height: 30,
                                              child:Text("")),
                                        ),

                                    ],),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
                              ),

                            ),
                          ]
                      ),
                    ),
                    Wrap( children:[ Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Padding(

                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () {
                              if (custNameController.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Customer Name';
                                });
                              } else if (custMobileController.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Customer Mobile';
                                });
                              } else if (custMobileController.text.length != 10) {
                                setState(() {
                                  errorMessage = '* Mobile number should be 10 digits';
                                });
                              } else if (custAddressController.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Customer Address';
                                });
                              }
                              else if (pincodeController.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a pincode';
                                });
                              }else if (pincodeController.text.length != 6) {
                                setState(() {
                                  errorMessage = '* Enter a valid pincode';
                                });
                              }

                              else if (gstinController.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a GSTIN';
                                });
                              } else if (!gstregex2.hasMatch(gstinController.text)) {
                                setState(() {
                                  errorMessage = '* Invalid GSTIN';
                                });
                              } else {
                                // If all fields are filled, proceed with updating details
                                updateCustomerDetails(
                                  widget.id.toString(),
                                  custNameController.text,
                                  custAddressController.text,
                                  pincodeController.text,
                                  custMobileController.text,
                                  gstinController.text,
                                  formattedDate,
                                );

                                showDialog(
                                  context: context,
                                  barrierDismissible: false, // Prevent dialog from closing on outside tap
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Customer'),
                                      content: Text('Update successfully.'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> CustomerReport())) ;// Close the dialog
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text("UPDATE", style: TextStyle(color: Colors.white)),
                          ),
                        ),



                        Padding(

                          padding: const EdgeInsets.only(left: 15.0,right: 15.0),

                          child: MaterialButton(

                            color: Colors.red.shade600,

                            onPressed: (){

                              Navigator.pop(context);

                            },child: const Text("BACK",style: TextStyle(color: Colors.white),),),

                        ),

                      ],

                    ),]

                    ),

                  ],
                )

            )
        ));
  }
}
