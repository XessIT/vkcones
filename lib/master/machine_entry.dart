
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import '../home.dart';
import '../report/Machine_view.dart';
import '../report/customeredit.dart';
class MachineEntry extends StatefulWidget {
  const MachineEntry({Key? key}) : super(key: key);

  @override
  State<MachineEntry> createState() => _MachineEntryState();
}

class _MachineEntryState extends State<MachineEntry> {
  final _formKey = GlobalKey<FormState>();
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  DateTime warrantydate = DateTime.now();
  // RegExp nameRegExp = RegExp(r'^[a-zA-Z\,]+(\s[a-zA-Z])?$');
  void _resetForm() {
    _formKey.currentState!.reset();
  }
  void _cancelForm() {
    print('Form cancelled!');
  }
  TextEditingController _purchasedateController = TextEditingController();
  TextEditingController _warrantydateController = TextEditingController();

  TextEditingController machineName=TextEditingController();
  TextEditingController machineModel=TextEditingController();
  TextEditingController machineS_No=TextEditingController();
  TextEditingController machineSupName=TextEditingController();
  TextEditingController machineSupMobile=TextEditingController();
  TextEditingController purchaseRate=TextEditingController();
  String? errorMessage="";
  String dropdownvalue = "Choose...";


  bool isMachineNameExists(String name) {
    return data.any((item) => item['machineName'].toString().toLowerCase() == name.toLowerCase());
  }

  bool isMachineSno(String name) {
    return data.any((item) => item['machineS_No'].toString().toLowerCase() == name.toLowerCase());
  }
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  Map<String, dynamic> dataToInsert = {};
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filteredData = [];
  bool showDeleteButtonInFirstRow = true;
  bool showInitialData = true;
  String? machineType;
  // Add this line to initialize warrantyDate

  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    const String apiUrl = 'http://localhost:3309/machine_entry'; // Replace with your server details
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
  final TextEditingController searchController = TextEditingController();


  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getmachinedetails'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        jsonData.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['date']);
          final DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA);
        });
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


  void filterData(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredData = data.where((item) {
          final custName = item[''].toString().toLowerCase();
          return custName.contains(query.toLowerCase());
        }).toList();
        showInitialData = false;
      } else {
        filteredData = List.from(data);
        showInitialData = true;
      }
    });
  }


  Future<void> deleteItem(BuildContext context, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3309/machinedelete/$id'),
      );
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MachineEntry(),
          ),
        );
      } else {
        throw Exception('Error deleting Item Group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete Item Group: $e');
    }
  }

  void showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                onDelete(id);
                Navigator.push(context, MaterialPageRoute(builder: (context)=> MachineEntry()));
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void onDelete(int id) {
    deleteItem(context, id);
  }


  final FocusNode machineNameFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    final formattedCurrentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _purchasedateController.text = formattedCurrentDate;
    final formattedWarrantyDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _warrantydateController.text = formattedWarrantyDate;
    fetchData();
  }



  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    DateTime purchasedate = DateTime.now();
    return MyScaffold(
        route: "machine_entry",
        body:  Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                  children: [
                    SizedBox(
                      child:  Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 80,
                          width: double.infinity, // Set the width to full page width
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey), // Add a border for the box
                            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                          ),
                          child: Wrap(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top:15.0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:15.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.engineering,size: 30,),SizedBox(width: 10,),
                                          Text("Machine Entry",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top:20.0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right:23.0),
                                      child: Text(
                                          DateFormat('dd-MM-yyyy').format(currentDate),
                                          style:TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0,left:4),
                      child: Container(
                        width: double.infinity, // Set the width to full page width
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.grey), // Add a border for the box
                          borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                        ),
                        child: Wrap(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  errorMessage ?? '',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            SizedBox(height: 30,),
                            Padding(padding: const EdgeInsets.only(left:10),
                              child: Wrap(
                                spacing: 36.0, // Set the horizontal spacing between the children
                                runSpacing: 20.0,
                                children: [
                                  SizedBox(
                                    width: 220, height: 70,
                                    child: TextFormField( controller: machineS_No,
                                      style: TextStyle(fontSize: 13),
                                      onChanged: (value) {
                                        if (isMachineSno(machineS_No.text)) {
                                          setState(() {
                                            errorMessage = '* Machine Serial Number already exists';
                                          });
                                          return;
                                        }
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                      },
                                      inputFormatters: [
                                        UpperCaseTextFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Machine Serial Number",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),

                                        ),
                                      ),
                                    ),
                                  ),
                                  //const Text("Machine Name"),
                                  SizedBox(
                                    width: 220, height: 70,
                                    child: TextFormField(
                                      controller: machineName,
                                      style: TextStyle(fontSize: 13),
                                      onChanged: (value) {
                                        if (isMachineNameExists(machineName.text)) {
                                          setState(() {
                                            errorMessage = '* Machine name already exists';
                                          });
                                          return;
                                        }
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                      },
                                      inputFormatters: [
                                        UpperCaseTextFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Machine Name",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 220,height: 38,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white70,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          // Step 3
                                          value: machineType,
                                          hint: Text("Machine Type",style:TextStyle(fontSize: 13,color: Colors.black)),
                                          // Step 4.
                                          items: <String>['Winding','Finishing','Printing']
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: TextStyle(fontSize: 15,color: Colors.black),
                                              ),
                                            );
                                          }).toList(),
                                          // Step 5.
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              errorMessage = null; // Reset error message when user types
                                            });
                                            setState(() {
                                              machineType = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 220, height: 70,
                                    child: TextFormField(
                                      controller: machineModel,
                                      style: TextStyle(fontSize: 13),
                                      onChanged: (value) {
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                      },
                                      inputFormatters: [
                                        UpperCaseTextFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Machine Model",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),



                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left:10.0),
                              child: Wrap(
                                spacing: 36.0, // Set the horizontal spacing between the children
                                runSpacing: 20.0,
                                children: [
                                  SizedBox(
                                    width: 220,height: 70,
                                    child: TextFormField(
                                      controller: machineSupName,
                                      onChanged: (value) {
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                        String capitalizedValue = capitalizeFirstLetter(value);
                                        machineSupName.value = machineSupName.value.copyWith(
                                          text: capitalizedValue,
                                          selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                        );
                                      },
                                      style: TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Machine Supplier Name",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,height: 70,
                                    child: TextFormField(
                                      controller: machineSupMobile,
                                      style: TextStyle(fontSize: 13),
                                      onChanged: (value) {
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                      },
                                      keyboardType: TextInputType.text,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(10),
                                        FilteringTextInputFormatter.digitsOnly,

                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixText: "+91",
                                        labelText: "Machine Supplier Mobile",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 220, height: 70,
                                    child: TextFormField(
                                      controller: purchaseRate,
                                      style: TextStyle(fontSize: 13),
                                      onChanged: (value) {
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Purchase Rate",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number, // Use TextInputType.number for numeric keyboard
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'^[0-9!@#\$%^&*(),.?":{}|<>]*$')),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    width: 220,
                                    height: 70,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 13),
                                      readOnly: true, // Set the field as read-only
                                      onChanged: (value) {
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                      },
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(
                                              1900),
                                          lastDate: DateTime.now(),
                                        ).then((date) {
                                          if (date != null) {
                                            setState(() {
                                              selectedDate = date;
                                              // Format the date before setting it in the TextEditingController
                                              final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                                              // Set the formatted date in the controller
                                              _purchasedateController.text = formattedDate;
                                            });
                                          }
                                        });
                                      },
                                      controller: _purchasedateController,
                                      // controller: TextEditingController(text: selectedDate.toString().split(' ')[0]), // Set the initial value of the field to the selected date
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Date of Purchase",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left:10.0),
                              child: Wrap(
                                  spacing: 36.0, // Set the horizontal spacing between the children
                                  runSpacing: 20.0,
                                  children:[
                                SizedBox(
                                  width: 220,
                                  height: 70,
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 13),
                                    readOnly: true,
                                    onChanged: (value) {
                                      setState(() {
                                        errorMessage = null; // Reset error message when the user types
                                      });
                                    },
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: warrantydate,
                                        firstDate:warrantydate ,
                                        lastDate: DateTime(2100),
                                      ).then((date) {
                                        if (date != null) {
                                          setState(() {
                                            warrantydate = date;
                                            // Format the date before setting it in the TextEditingController
                                            final formattedDate = DateFormat('dd-MM-yyyy').format(warrantydate);
                                            // Set the formatted date in the controller
                                            _warrantydateController.text = formattedDate;
                                          });
                                        }
                                      });
                                    },
                                    controller: _warrantydateController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: "Warranty Date",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                            )

                          ],

                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child:
                      Wrap(
                        children: [
                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (isMachineNameExists(machineName.text)) {
                                  setState(() {
                                    errorMessage = '* Machine name already exists';
                                  });
                                  return;
                                }
                                if (isMachineSno(machineS_No.text)) {
                                  setState(() {
                                    errorMessage = '* Machine Serial Number already exists';
                                  });
                                  return;
                                }
                                final date = currentDate.toIso8601String();
                                final _purchasedateController = selectedDate.toIso8601String();
                                final _warrantydateController = warrantydate.toIso8601String();

                              if (machineS_No.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Machine SerialNo';
                                });
                              }
                              else  if (machineName.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Machine Name';
                                  });
                                }
                                else if (machineModel.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Machine Model';
                                  });
                                }
                                else if (machineType == null) {
                                  setState(() {
                                    errorMessage = '* Select a Machine';
                                  });
                                }
                                else if (machineSupName.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Machine Supplier Name';
                                  });
                                } else if (machineSupMobile.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Mobile number';
                                  });
                                } else if (machineSupMobile.text.length != 10) {
                                  setState(() {
                                    errorMessage = '* Mobile number should be 10 digits';
                                  });
                                }
                                else if (purchaseRate.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Purchase Rate';
                                  });
                                }
                                else if (_purchasedateController.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a purchase Date';
                                  });
                                }
                                else if (warrantydate.isBefore(selectedDate)) {
                                  setState(() {
                                    errorMessage = ' * Warranty Date must be after\nPurchase Date';
                                  });
                                  return; // Prevent further execution if validation fails
                                } else if (warrantydate.isAtSameMomentAs(selectedDate)) {
                                  setState(() {
                                    errorMessage = '* Warranty Date cannot be the same as\nPurchase Date';
                                  });
                                  return; // Prevent further execution if validation fails
                                }else {
                                  dataToInsert = {
                                    'date': date,
                                    'machineName': machineName.text,
                                    'machineModel': machineModel.text,
                                    'machineS_No': machineS_No.text,
                                    'machineType':machineType,
                                    'machineSupName': machineSupName.text,
                                    'machineSupMobile': machineSupMobile.text,
                                    'purchaseRate': purchaseRate.text,
                                    'purchaseDate': _purchasedateController,
                                    'warrantyDate': _warrantydateController,
                                  };
                                  insertData(dataToInsert);
                                  // Show alert after saving
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Machine'),
                                        content: Text('Saved Successfully'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) =>MachineEntry()));
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                print("Successful");
                              }
                            },
                            child: Text("SUBMIT", style: TextStyle(color: Colors.white)),
                          ),


                          SizedBox(width: 10,),
                          MaterialButton(
                            color: Colors.blue.shade600,
                            onPressed: (){
                              /*  Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>const Home()));*/// Close the alert box
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text('Do you want to Reset?'),
                                    actions: <Widget>[

                                      TextButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) =>const MachineEntry()));// Close the alert box
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('No'),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the alert box
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text("RESET",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 10,),
                          MaterialButton(
                            color: Colors.red.shade600,
                            onPressed: (){
                              /*  Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>const Home()));*/// Close the alert box
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text('Do you want to cancel?'),
                                    actions: <Widget>[

                                      TextButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) =>const Home()));// Close the alert box
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('No'),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the alert box
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text("CANCEL",style: TextStyle(color: Colors.white),),)
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding:  EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                child: Container(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 20,),
                                          PaginatedDataTable(
                                            columnSpacing:60.0,
                                            //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            rowsPerPage:10,
                                            columns:   const [
                                              DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                              DataColumn(label: Center(child: Text("   Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                              DataColumn(label: Center(child: Text("Machine S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                              DataColumn(label: Center(child: Text("Machine Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                              DataColumn(label: Center(child: Text("Machine Type",style: TextStyle(fontWeight: FontWeight.bold),))),
                                              DataColumn(label: Center(child: Text("Machine Model",style: TextStyle(fontWeight: FontWeight.bold),))),
                                              DataColumn(label: Center(child: Text("     Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                                            ],
                                            source: _YourDataTableSource(showInitialData ? data : filteredData, context,generatedButton,  onDelete, showDeleteConfirmationDialog),

                                          ),
                                        ],
                                      ),
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
            ),

          ),
        ) );
  }
}
bool generatedButton = false;
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase() ?? '', // Convert to uppercase
      selection: newValue.selection,
    );
  }
}


class _YourDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  final Function(int) onDelete;
  final Function(BuildContext, int) showDeleteConfirmationDialog;
  final bool generatedButton;

  _YourDataTableSource(
      this.data, this.context, this.generatedButton, this.onDelete, this.showDeleteConfirmationDialog);
  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final row = data[index];
    final id = row["id"];
    return DataRow(
      cells: [
        DataCell(Center(child: Text("${index + 1}"))),
        DataCell(Center(
          child:   Text(
            row["date"] != null
                ? DateFormat('dd-MM-yyyy').format(
              DateTime.parse("${row["date"]}"),
            ) : "",
          ),
        )),
        DataCell(Center(child: Text("${row["machineS_No"]}"))),
        DataCell(Center(child: Text("${row["machineName"]}"))),
        DataCell(Center(child: Container(
            constraints: BoxConstraints(maxWidth:150),child: Text("${row["machineType"]}")))),
        DataCell(Center(child: Text("${row["machineModel"]}"))),
        DataCell(Center(child:Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*IconButton(icon: Icon(Icons.edit ,color:Colors. blue,),onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>MachineView(
                  customerData:data,
                  id: row["id"],
                  date:row["date"],
                  machineName:row["machineName"],
                  machineModel:row["machineModel"],
                  machineS_No:row["machineS_No"],
                  machineSupName:row["machineSupName"],
                  machineSupMobile:row["machineSupMobile"],
                  purchaseRate:row["purchaseRate"],
                  purchaseDate:row["purchaseDate"],
                  warrantyDate:row["warrantyDate"],
                )));
              },),*/

              Center(
                child: IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    showDeleteConfirmationDialog(context, id);
                  },
                ),
              ),
            ],
          ),
        ),)),
      ],
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

