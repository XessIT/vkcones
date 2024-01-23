import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vinayaga_project/main.dart';
import '../home.dart';
import '../sale/dc.dart';
import 'package:http/http.dart' as http;

class CustomerEntry extends StatefulWidget {
  const CustomerEntry({Key? key}) : super(key: key);

  @override
  State<CustomerEntry> createState() => _CustomerEntryState();
}

class _CustomerEntryState extends State<CustomerEntry> {
  final _formKey = GlobalKey<FormState>();
  static final  RegExp gstregex = RegExp(r"^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d[Z]{1}[A-Z\d]{1}$");

  //RegExp nameRegExp = RegExp(r'^[a-zA-Z/,]+(\s[a-zA-Z]+)?$');

  void _resetForm() {
    _formKey.currentState!.reset();
  }
  void _cancelForm() {
    print('Form cancelled!');
  }

  String errorMessage='';
  String custPaytype="Payment Type";
  bool dropdownValid = true;
  TextEditingController custCode=TextEditingController();
  TextEditingController custAddress=TextEditingController();
  TextEditingController custName=TextEditingController();
  TextEditingController custMobile=TextEditingController();
  TextEditingController custGSTIN=TextEditingController();

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  List<Map<String, dynamic>> data = [];
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];

  bool showInitialData = true;


  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    // Use the key "name" to access the value of the "name" column.
    return jsonItem['custCode'];
  }

  Map<String, dynamic> dataToInsert = {};

  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    final String apiUrl = 'http://localhost:3309/Customer'; // Replace with your server details
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


String? customercode;
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getcustall'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          customercode = getNameFromJsonData(item);
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



  Future<void> loginUser1() async {
    try {
      final url = Uri.parse('http://localhost:3309/login/'); // Change this URL to your login endpoint
      final data = {
        'custCode': generateId(),
        'custName': custName.text,
        'custAddress':custAddress.text,
        'custMobile':custMobile.text,
        'custGSTIN':custGSTIN.text,
        'custPaytype':custPaytype,
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
    }
    catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
      setState(() {
        errorMessage = 'An error occurred';
      });
    }
  }
@override
  void initState() {
    // TODO: implement initState
  fetchData();
    super.initState();
  }
  void validateDropdown() {
    setState(() {
      dropdownValid = custPaytype != "Payment Type";
    });
  }

  String generateId() {
      String iddd = customercode!.substring(1); // Remove the 'S' prefix
      int idInt = int.parse(iddd) + 1; // Convert iddd to an integer, add 1
      String id = 'C${idInt.toString().padLeft(3, '0')}';
      // Convert back to string
      print(id);
      return id;
    }



  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "customer_entry",
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text("Customer Entry", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),
                    SizedBox(height: 50,),
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
                                      //controller: custCode,
                                      readOnly: true,
                                     initialValue: generateId(),
                                      style: TextStyle(fontSize: 13),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '* Enter Customer Code';
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        UpperCaseTextFormatter()
                                      ],
                                      decoration: InputDecoration(
                                        labelText: "Customer Code",
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
                                   SizedBox(
                                    width: 200,height: 70,
                                    child: TextFormField(
                                      maxLines: 2,
                                      //maxLength: 100,
                                      controller: custAddress,
                                      onChanged: (value) {
                                        String capitalizedValue = capitalizeFirstLetter(value);
                                        custAddress.value = custAddress.value.copyWith(
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
                                  ),
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
                        children:[
                          // const Text("Supplier Name/Company Name"),
                          SizedBox(
                            width: 200,height: 70,
                            child: TextFormField(
                              controller: custName,
                              style: TextStyle(fontSize: 13),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '* Enter Customer/Company Name';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                String capitalizedValue = capitalizeFirstLetter(value);
                                custName.value = custName.value.copyWith(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                );
                              },
                              decoration: InputDecoration(
                                labelText: "Customer/Company Name",
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
                              controller: custMobile,
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
                                    controller: custGSTIN,
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
                                      child: DropdownButton<String>(
                                        // Step 3.
                                        value: custPaytype,
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
                                            custPaytype = newValue!;
                                            validateDropdown();
                                          });
                                        },
                                      ),
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
                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: (){
                              generateId();
                              if(_formKey.currentState!.validate()){}
                              dataToInsert = {
                                'custCode': generateId(),
                                'custName': custName.text,
                                'custAddress': custAddress.text,
                                'custMobile': custMobile.text,
                                'custGSTIN': custGSTIN.text,
                                'custPaytype': custPaytype,
                                // Add more columns and values as needed
                              };
                              insertData(dataToInsert);
                              validateDropdown(); // Call validation before submitting
                              if (dropdownValid) {

                                //loginUser1();
                                // Form is valid, continue with your action here
                                // For example, you can print the selected value:
                                print('Selected Paymenttype: $custPaytype');
                              }
                              print("Successfull");
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
