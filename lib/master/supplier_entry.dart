import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vinayaga_project/main.dart';
import 'package:vinayaga_project/sale/dc.dart';
import 'package:http/http.dart' as http;


import '../home.dart';

class SupplierEntry extends StatefulWidget {
  const SupplierEntry({Key? key}) : super(key: key);

  @override
  State<SupplierEntry> createState() => _SupplierEntryState();
}

class _SupplierEntryState extends State<SupplierEntry> {
  final _formKey = GlobalKey<FormState>();
  static final  RegExp gstregex = RegExp(r"^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d[Z]{1}[A-Z\d]{1}$");

  //RegExp nameRegExp = RegExp(r'^[a-zA-Z/,]+(\s[a-zA-Z]+)?$');

  void _resetForm() {
    _formKey.currentState!.reset();
  }
  void _cancelForm() {
    print('Form cancelled!');
  }
  TextEditingController supAddress=TextEditingController();
  TextEditingController supName=TextEditingController();
  TextEditingController supMobile=TextEditingController();
  TextEditingController supGSTIN=TextEditingController();
  TextEditingController supCode=TextEditingController();


  String supPaytype = "Payment Type";
  bool dropdownValid = true;

  void validateDropdown() {
    setState(() {
      dropdownValid = supPaytype != "Payment Type";
    });
  }
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  String errorMessage ='';

  Map<String, dynamic> dataToInsert = {};

  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    final String apiUrl = 'http://localhost:3309/Suplier'; // Replace with your server details

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsert': dataToInsert}),
      );

      if (response.statusCode == 200) {
        print('Data inserted successfully');
      } else {
        print('Failed to insert data');
        throw Exception('Failed to insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

//update
  Map<String, dynamic> dataToUpdate = {};
  String id='1';

  Future<void> updateData(Map<String, dynamic> dataToUpdate, String id) async {
    final String apiUrl = 'http://localhost:3309/update/$id'; // Replace with your server details and endpoint

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToUpdate': dataToUpdate}),
      );

      if (response.statusCode == 200) {
        print('Data updated successfully');
      } else {
        print('Failed to update data');
        throw Exception('Failed to update data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
//old insert cost
  Future<void> loginUser1() async {
    try {
      final url = Uri.parse('http://localhost:3309/login/'); // Change this URL to your login endpoint
      final data = {
        'supCode': generateId(),
        'supName': supName.text,
        'supAddress':supAddress.text,
        'supMobile':supMobile.text,
        'supGSTIN':supGSTIN.text,
        'supPaytype':supPaytype,
      };

      final response = await http.post(
        url,
        body: json.encode(data), // Send data as JSON in the request body
        headers: {
          'Content-Type': 'application/json', // Set the content type to JSON
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        // Now you can work with the userData
        print('User Data: $userData');
      } else {
        // Error handling for HTTP request
        print('Error: ${response.statusCode}');
        setState(() {
          errorMessage = 'Failed to login';
        });
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
      setState(() {
        errorMessage = 'An error occurred';
      });
    }
  }

  List<Map<String, dynamic>> data = [];
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];

  bool showInitialData = true;




  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDatas();

  }

  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    // Use the key "name" to access the value of the "name" column.
    return jsonItem['supCode'];
  }

  String? customercode;
  String? selectedValue;
  List<String> supplier=[];

  //String? selectedValue; // This will hold the selected value from the dropdown.
  List<String> supCodes = []; // This list will store the supCode values.

  Future<void> fetchDatas() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getsupplier'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        // Clear the previous values in supCodes list.
        supCodes.clear();

        for (var item in jsonData) {
          String? supCode = getNameFromJsonData(item); // Assuming getNameFromJsonData extracts the supCode.
          supCodes.add(supCode!); // Add supCode to the list.
        }

        setState(() {
          // Set the data in your state, if needed.
          data = jsonData.cast<Map<String, dynamic>>();
        });
      } else {
        // Handle the error case.
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to fetch data'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      // Handle exceptions.
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getall'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          customercode = getNameFromJsonData(item);
          print('Name: $customercode');
        }
        setState(() {
          data = jsonData.cast<Map<String, dynamic>>();
        });
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to fetch data'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call filterData with an empty query when the page loads
    if (showInitialData) {
      //filterData('');
    }
  }

  String generateId() {
    // var customerCode = "S001"; // Replace with your actual customer code
    String iddd = customercode!.substring(1); // Remove the 'S' prefix
    String code = 'S$iddd';
    int idInt = int.parse(iddd) + 1; // Convert iddd to an integer, add 1
    String id = 'S${idInt.toString().padLeft(3, '0')}';
    // Convert back to string
    print(id);
    return id;
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "supplier_entry",
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text("Supplier Entry", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),
                    SizedBox(height: 50,),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: Wrap(
                          children: [
                            Padding(padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 200,height: 70,
                                    child: TextFormField(
                                      readOnly: true,
                                      initialValue: generateId(),
                                      //controller: subCodeController,
                                      style: TextStyle(fontSize: 13),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '* Enter Supplier Code';
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        UpperCaseTextFormatter()
                                      ],
                                      decoration: InputDecoration(
                                        labelText: "Supplier Code",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),

                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 200,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // const Text("Location"),
                                  DropdownButton<String>(
                                    value: selectedValue,
                                    items: supCodes.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue = newValue;
                                      });
                                    },
                                  ),
                                 /* SizedBox(
                                    width: 200,height: 70,
                                    child: TextFormField(
                                      maxLines: 2,
                                      controller: supAddress,
                                      onChanged: (value) {
                                        String capitalizedValue = capitalizeFirstLetter(value);
                                        supAddress.value = supAddress.value.copyWith(
                                          text: capitalizedValue,
                                          selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                        );
                                      },
                                      style: TextStyle(fontSize: 13),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '* Enter Address';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: "Address",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),*/
                                ],
                              ),
                            ),

                          ]),
                    ),
                    SizedBox(height: 5,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 415, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const Text("Supplier Name/Company Name"),
                          SizedBox(
                            width: 200,height: 70,
                            child: TextFormField(
                              controller: supName,
                              style: TextStyle(fontSize: 13),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '* Enter Supplier/Company Name';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                String capitalizedValue = capitalizeFirstLetter(value);
                                supName.value = supName.value.copyWith(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                );
                              },
                              decoration: InputDecoration(
                                labelText: "Supplier/Company Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),

                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 415, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const Text("Mobile Number"),
                          SizedBox(
                            width: 200,height: 70,
                            child: TextFormField(
                              controller: supMobile,
                              style: TextStyle(fontSize: 13),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "* Enter Mobile Number";
                                } else if (value.length < 10) {
                                  return "* Mobile Number should be 10 digits";
                                }  else{
                                  return null;}
                              },
                              decoration: InputDecoration(
                                labelText: "Mobile Number",
                                prefixText: "+91",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: Wrap(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          Padding(
                            padding:const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // const Text("GST IN"),
                                SizedBox(
                                  width: 200,height: 70,
                                  child: TextFormField(
                                    controller: supGSTIN,
                                    style: TextStyle(fontSize: 13),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "* Enter GSTIN";
                                      }

                                      if (!gstregex.hasMatch(value)) {
                                        return '* Enter a valid GSTIN';
                                      }
                                      else {
                                        return null;
                                      }
                                    },
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                        labelText: "GSTIN",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10,),
                                        )
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 200,),
                          Padding(
                            padding: const EdgeInsets.only(top:5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // const Text("Payment Type"),
                                SizedBox(
                                  width: 200,height: 36,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child:  DropdownButton<String>(
                                        value: selectedValue,
                                        items: supCodes.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedValue = newValue;
                                          });
                                        },
                                      ),
                                      /*child: DropdownButton<String>(
                                        // Step 3.
                                        value: supPaytype,
                                        // Step 4.
                                        items: <String>['Payment Type','Cash','Online','Credit',]
                                            .map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          );
                                        }).toList(),
                                        // Step 5.
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            supPaytype = newValue!;
                                            validateDropdown();
                                          });
                                        },
                                      ),*/
                                    ),
                                  ),
                                ),
                                if (!dropdownValid)
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text(
                                      '* select a payment Type',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10,),

                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child:
                      Wrap(
                        children: [
                          MaterialButton(onPressed: (){
                            //loginUser1();

                            dataToUpdate = {
                              'supCode': 'S001',
                              'supName': supName.text,
                              'supAddress': supAddress.text,
                              'supMobile': supMobile.text,
                              'supGSTIN': supGSTIN.text,
                              'supPaytype': supPaytype,
                              // Add more columns and values as needed
                            };
                            updateData(dataToUpdate, id);
                          },
                            child: Text('update'),
                          ),
                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: (){
                              if(_formKey.currentState!.validate()){}
                              validateDropdown(); // Call validation before submitting
                              if (dropdownValid) {
                                dataToInsert = {
                                  'supCode': generateId(),
                                  'supName': supName.text,
                                  'supAddress': supAddress.text,
                                  'supMobile': supMobile.text,
                                  'supGSTIN': supGSTIN.text,
                                  'supPaytype': supPaytype,
                                  // Add more columns and values as needed
                                };
                                insertData(dataToInsert);
                                // Form is valid, continue with your action here
                                // For example, you can print the selected value:
                                print('Selected Paymenttype: $supPaytype');
                              }
                              print("Success");

                            },child: Text("SUBMIT",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 10,),
                          MaterialButton(
                            color: Colors.blue.shade600,
                            onPressed: _resetForm,child:Text("RESET",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 10,),
                          MaterialButton(
                            color: Colors.red.shade600,
                            onPressed: (){
                              _cancelForm();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>Home()));
                            },child: Text("CANCEL",style: TextStyle(color: Colors.white),),)
                        ],
                      ),
                    ),
                  ]),
            ),

          ),
        ) );
  }
}
