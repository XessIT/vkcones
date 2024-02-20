import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;

import '../master/machine_entry.dart';

class MachineView extends StatefulWidget {
  int id;
  String? date;
  String? machineName;
  String? machineModel;
  String? machineS_No;
  String? machineSupName;
  int machineSupMobile;
  String? purchaseRate;
  String? purchaseDate;
  String? warrantyDate;
  MachineView({Key? key,
    required this.id,
    required this.date,
    required this.machineName,
    required this.machineModel,
    required this.machineSupMobile,
    required this.machineSupName,
    required this.machineS_No,
    required this.purchaseRate,
    required this.purchaseDate,
    required this.warrantyDate,
    required List<Map<String, dynamic>> customerData}) : super(key: key);

  @override
  State<MachineView> createState() => _MachineViewState();
}
DateTime selectedDate = DateTime.now();
DateTime warrantyDate = DateTime.now();
String? errorMessage="";
class _MachineViewState extends State<MachineView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController machineNamecontroller = TextEditingController();
  TextEditingController machineModelcontroller = TextEditingController();
  TextEditingController machineSNOcontroller = TextEditingController();
  TextEditingController machinesupNamecontroller = TextEditingController();
  TextEditingController machinesupMobilecontroller = TextEditingController();
  TextEditingController purchaseratecontroller = TextEditingController();
  TextEditingController warrantydatecontroller = TextEditingController();
  TextEditingController purchasedatecontroller = TextEditingController();
  TextEditingController currentdatecontroller = TextEditingController();
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != controller.text) {
      setState(() {
        controller.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }


  @override
  void initState() {
    super.initState();
    machineNamecontroller = TextEditingController();
    machineModelcontroller = TextEditingController();
    machineSNOcontroller = TextEditingController();
    machinesupNamecontroller = TextEditingController();
    machinesupMobilecontroller=TextEditingController();
    purchaseratecontroller=TextEditingController();
    warrantydatecontroller=TextEditingController();
    purchasedatecontroller=TextEditingController();
    currentdatecontroller=TextEditingController();


    DateTime localFromDate = widget.warrantyDate != null
        ? DateTime.parse(widget.warrantyDate!).toLocal()
        : DateTime.now();
    DateTime localToDate = widget.purchaseDate != null
        ? DateTime.parse(widget.purchaseDate!).toLocal()
        : DateTime.now();

    warrantydatecontroller.text = widget.warrantyDate != null
        ? DateFormat("dd-MM-yyyy").format(localFromDate)
        : '';
    purchasedatecontroller.text = widget.purchaseDate != null
        ? DateFormat("dd-MM-yyyy").format(localToDate)
        : '';
    machineNamecontroller.text = widget.machineName ?? '';
    machineModelcontroller.text = widget.machineModel ?? '';
    machineSNOcontroller.text = widget.machineS_No ?? '';
    machinesupNamecontroller.text = widget.machineSupName ?? '';
    purchaseratecontroller.text = widget.purchaseRate ?? '';
    currentdatecontroller.text = widget.date ?? '';
    machinesupMobilecontroller.text = widget.machineSupMobile.toString();
  }

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filteredData = [];
  bool showInitialData = true;


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


  void didChangeDependencies() {
    super.didChangeDependencies();
  }



  Future<void> updateCustomerDetails(
      String id,
      String machineName,
      String machineModel,
      String machineS_No,
      String machineSupName,
      String machineSupMobile,
      String purchaseRate,
      String purchaseDate,
      String warrantyDate,
      String modifyDate,
      ) async
  {
    DateTime warrantyDateFormatted = DateFormat('dd-MM-yyyy').parse(warrantyDate);
    String formattedWarrantyDate = DateFormat('yyyy-MM-dd').format(warrantyDateFormatted);
    DateTime purchaseDateFormatted = DateFormat('dd-MM-yyyy').parse(purchaseDate);
    String formattedPurchaseDate = DateFormat('yyyy-MM-dd').format(purchaseDateFormatted);

    try {
      // Fetch the latest data
      //  await fetchData();

      // Exclude the current item being edited from the check
      bool nameExists = data
          .where((item) => item['machineName'].toString().toLowerCase() == machineName.toLowerCase() && item['id'] != id)
          .isNotEmpty;

      if (nameExists) {
        // Show an error message if the machine name already exists for a different item
        setState(() {
          errorMessage = 'The machine name "$machineName" already exists for another entry. Please choose a different name.';
        });
      } else {
        // Continue with the update if the name doesn't exist
        final response = await http.put(
          Uri.parse('http://localhost:3309/machine_update/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'machineName': machineName,
            'machineModel': machineModel,
            'machineS_No': machineS_No,
            'machineSupName': machineSupName,
            'machineSupMobile': machineSupMobile,
            'purchaseRate': purchaseRate,
            'purchaseDate': formattedPurchaseDate,
            'warrantyDate': formattedWarrantyDate,
            'modifyDate': modifyDate,
          }),
        );

        if (response.statusCode == 200) {
          // Check if the update was successful
          print('Data updated successfully');

          // Reset the error message
          setState(() {
            errorMessage = null;
          });

          // Show an alert box only if the data was successfully updated
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Machine'),
                content: Text('Update Successfully'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MachineEntry()));
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Error updating data: ${response.body}');
        }
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }




  /* Future<void> updateCustomerDetails(
      String id,
      String machineName,
      String machineModel,
      String machineS_No,
      String machineSupName,
      String machineSupMobile,
      String purchaseRate,
      String purchaseDate,
      String warrantyDate,
      String modifyDate,
      ) async {
    final response = await http.put(
      Uri.parse('http://localhost:3309/machine_update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'machineName': machineName,
        'machineModel':machineModel,
        'machineS_No': machineS_No,
        'machineSupName': machineSupName,
        'machineSupMobile': machineSupMobile,
        'purchaseRate': purchaseRate,
        'purchaseDate': purchaseDate,
        'warrantyDate': warrantyDate,
        'modifyDate':modifyDate,
      }),
    );

    if (response.statusCode == 200) {
      print('Data updated successfully');
    } else {
      print('Error updating data: ${response.body}');
    }
  }*/

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    String currentdatecontroller = DateFormat("yyyy-MM-dd HH:mm:ss").format(currentDate);
    // DateTime purchaseDate = DateTime.now();
    // String purchasedatecontroller = DateFormat("yyyy-MM-dd").format(purchaseDate);
    // DateTime warrantyDate = DateTime.now();
    // String warrantydatecontroller = DateFormat("yyyy-MM-dd").format(warrantyDate);

    return  MyScaffold(
      route: '',backgroundColor: Colors.white,
      body: Form(key: _formKey,child:
      Column(
        children: [
          SizedBox(height: 2,),
          SizedBox(
            child: Padding(
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
                          padding: const EdgeInsets.only(top:15.0,left: 8),
                          child: Row(
                            children: [
                              Icon(Icons.engineering,size: 30,),SizedBox(width: 10,),
                              Text("Machine Report",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:20.0,right: 8),
                          child: Text(
                              DateFormat('dd-MM-yyyy').format(currentDate),
                              style:TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            child:  Padding(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text("Machine Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                        ],
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 36.0, // Set the horizontal spacing between the children
                        runSpacing: 20.0,
                        children: [
                          SizedBox(
                            width: 220, height: 70,
                            child: TextFormField(
                              readOnly: true,
                              onChanged: (value) {
                                String capitalizedValue = capitalizeFirstLetter(value);
                                machineNamecontroller.value = machineNamecontroller.value.copyWith(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                );
                                setState(() {
                                  errorMessage = null; // Reset error message when user types
                                });
                              },
                              initialValue: widget.machineName,
                              style: TextStyle(fontSize: 13),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '* Enter Machine Name';
                                }
                                return null;
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
                            width: 220, height: 70,
                            child: TextFormField(
                              readOnly: true,
                              onChanged: (value) {
                                String capitalizedValue = capitalizeFirstLetter(value);
                                machineModelcontroller.value = machineModelcontroller.value.copyWith(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                );
                                setState(() {
                                  errorMessage = null; // Reset error message when user types
                                });
                              },
                              initialValue: widget.machineModel,
                              //controller: machineModel,
                              style: TextStyle(fontSize: 13),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '* Enter Machine Model';
                                }
                                return null;
                              },
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                              ],
                              decoration: InputDecoration(
                                labelText: "Machine Model",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(width: 8,),
                          SizedBox(
                            width: 220, height: 70,
                            child: TextFormField(
                              readOnly: true,
                              onChanged: (value) {

                                String capitalizedValue = capitalizeFirstLetter(value);
                                machineSNOcontroller.value = machineSNOcontroller.value.copyWith(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                );
                                setState(() {
                                  errorMessage = null; // Reset error message when user types
                                });

                              },
                              initialValue: widget.machineS_No,
                              //controller: machineS_No,
                              style: TextStyle(fontSize: 13),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '* Enter Machine Serial Number';
                                }
                                return null;
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
                          // SizedBox(width: 8,),
                          SizedBox(
                            width: 220,height: 70,
                            child: TextFormField(
                              readOnly: true,
                              onChanged: (value) {

                                String capitalizedValue = capitalizeFirstLetter(value);
                                machinesupNamecontroller.value = machinesupNamecontroller.value.copyWith(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                );
                                setState(() {
                                  errorMessage = null; // Reset error message when user types
                                });

                              },
                              initialValue: widget.machineSupName,
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
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 36.0, // Set the horizontal spacing between the children
                        runSpacing: 20.0,
                        children: [
                          SizedBox(
                            width: 220,height: 70,
                            child: TextFormField(
                              readOnly: true,
                              onChanged: (value) {

                                String capitalizedValue = capitalizeFirstLetter(value);
                                machinesupMobilecontroller.value = machinesupMobilecontroller.value.copyWith(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                );
                                setState(() {
                                  errorMessage = null; // Reset error message when user types
                                });

                              },
                              initialValue: widget.machineSupMobile.toString(),
                              style: TextStyle(fontSize: 13),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '* Enter Machine Supplier Mobile';
                                }
                                return null;
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
                              readOnly: true,
                              onChanged: (value) {

                                String capitalizedValue = capitalizeFirstLetter(value);
                                purchaseratecontroller.value = purchaseratecontroller.value.copyWith(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                );
                                setState(() {
                                  errorMessage = null; // Reset error message when user types
                                });

                              },
                              initialValue: widget.purchaseRate,
                              style: TextStyle(fontSize: 13),

                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                FilteringTextInputFormatter.allow(RegExp(r'^[0-9!@#\$%^&*(),.?":{}|<>]*$')),
                              ],
                              keyboardType: TextInputType.number, // Use TextInputType.number for numeric keyboard
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Purchase Rate",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 220, height: 70,
                            child: TextFormField(
                              readOnly: true,
                              style: TextStyle(fontSize: 13),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),

                                );
                                if (pickedDate != null) {
                                  // Explicitly set the timezone to UTC before formatting
                                  DateTime utcDate = pickedDate.toUtc();
                                  setState(() {
                                    purchasedatecontroller.text = DateFormat('yyyy-MM-dd').format(utcDate);
                                  });
                                }
                              },
                              controller: purchasedatecontroller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Date of purchase",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 220, height: 70,
                            child: TextFormField(
                              readOnly: true,
                              style: TextStyle(fontSize: 13),

                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    warrantydatecontroller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                                    errorMessage = null; // Reset error message
                                  });
                                }
                              },
                              controller: warrantydatecontroller,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Wrap(
            children: [
            /*  Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  color: Colors.green.shade600,
                  onPressed: () {
                    if (machineNamecontroller.text.isEmpty) {
                      setState(() {
                        errorMessage = '* Enter a Machine Name';
                      });
                    }
                    else if (machineModelcontroller.text.isEmpty) {
                      setState(() {
                        errorMessage = '* Enter a Machine Model';
                      });
                    }
                    else if (machineSNOcontroller.text.isEmpty) {
                      setState(() {
                        errorMessage = '* Enter a Machine Serial No';
                      });
                    }
                    else if (machinesupNamecontroller.text.isEmpty) {
                      setState(() {
                        errorMessage = '* Enter a Machine Supplier Name';
                      });
                    }
                    else if (machinesupMobilecontroller.text.isEmpty) {
                      setState(() {
                        errorMessage = '* Enter a Supplier Mobile';
                      });
                    }
                    else if (machinesupMobilecontroller.text.length != 10) {
                      setState(() {
                        errorMessage = '* Mobile number should be 10 digits';
                      });
                    }
                    else if (purchaseratecontroller.text.isEmpty) {
                      setState(() {
                        errorMessage = '* Enter a Purchase rate';
                      });
                    }
                    else if (purchasedatecontroller.text.isEmpty) {
                      setState(() {
                        errorMessage = '* Enter a Purchase date';
                      });
                    }
                    else if (warrantydatecontroller.text.isEmpty) {
                      setState(() {
                        errorMessage = '* Enter a Warranty Date';
                      });
                    }
                    else{
                      updateCustomerDetails(
                        widget.id.toString(),
                        machineNamecontroller.text,
                        machineModelcontroller.text,
                        machineSNOcontroller.text,
                        machinesupNamecontroller.text,
                        machinesupMobilecontroller.text,
                        purchaseratecontroller.text,
                        purchasedatecontroller.text,
                        warrantydatecontroller.text,
                        currentdatecontroller,
                      );

                      // Show an alert box
                      *//* showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Machine'),
                            content: Text('Update Successfully'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> MachineEntry())) ;// Close the alert box
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );*//*
                    }
                  },
                  child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                ),
              ),*/

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  color: Colors.red.shade600,
                  onPressed: (){
                    Navigator.pop(context);
                  },child: const Text("BACK",style: TextStyle(color: Colors.white),),),
              ),
            ],
          ),
        ],

      ),

      ),

    );
  }
}
