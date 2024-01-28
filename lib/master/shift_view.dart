/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/master/shift_entry.dart';
import '../new_sales_entries.dart';


class ShiftView extends StatefulWidget {



  int id;
  String? empID;
  String? empName;
  String? fromDate;
  String? toDate;
  String? shiftType;
  String? shiftTime;

  ShiftView({Key? key,
    required this.id,
    required this.empID,
    required this.empName,
    required this.fromDate,
    required this.toDate,
    required this.shiftType,
    required this.shiftTime,

  }) : super(key: key);
  @override
  State<ShiftView> createState() => _ShiftViewState();
}

class _ShiftViewState extends State<ShiftView> {


  Map<String, String> shiftTimingsMap = {
    'General': '9:00AM - 6:00PM',
    'Morning': '8:00AM - 8:00PM',
    'Night': '8:00PM - 8:00AM',
  };


  String shiftType="Shift Type";
  String shiftTime="Shift Timing";

  late DateTime fromDate;
  late DateTime toDate;


  TextEditingController empID=TextEditingController();
  TextEditingController empName=TextEditingController();
  TextEditingController fromDateController=TextEditingController();
  TextEditingController toDateController=TextEditingController();
  TextEditingController shiftTimeController=TextEditingController();
  TextEditingController shiftTypeController=TextEditingController();
  TextEditingController shiftDateController=TextEditingController();
  TextEditingController shifttoDateController=TextEditingController();

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
    shiftDateController = TextEditingController();
    shifttoDateController = TextEditingController();
    fromDateController = TextEditingController();
    toDateController = TextEditingController();
    shiftTimeController = TextEditingController();
    shiftTypeController = TextEditingController();

    DateTime localFromDate = widget.fromDate != null
        ? DateTime.parse(widget.fromDate!).toLocal()
        : DateTime.now();
    DateTime localtoDate = widget.toDate != null
        ? DateTime.parse(widget.toDate!).toLocal()
        : DateTime.now();
    // DateTime localToDate = widget.toDate != null
    //     ? DateTime.parse(widget.toDate!).toLocal()
    //     : DateTime.now();

    shiftDateController.text = widget.fromDate != null
        ? DateFormat("yyyy-MM-dd").format(localFromDate)
        : '';
    shifttoDateController.text = widget.toDate != null
        ? DateFormat("yyyy-MM-dd").format(localtoDate)
        : '';
    // fromDateController.text = widget.toDate != null
    //     ? DateFormat("yyyy-MM-dd").format(localToDate)
    //     : '';


    print(shiftDateController.text);
    print(shifttoDateController.text);
    //fetchData4(shiftDateController.text,shifttoDateController.text,widget.shiftType.toString(),);
    print(selectedShiftType);
    shiftTimeController.text = widget.shiftTime.toString();
    shiftTypeController.text = widget.shiftType.toString();
    shiftType = widget.shiftType ?? 'General';
    shiftTypeController.text = shiftType;
    shiftTimeController.text = shiftTimingsMap[shiftType] ?? '9:00AM - 6:00PM';
    //filterFromToDateData(fromDate,toDate,empIDValue);
  }



  Future<List<Map<String, dynamic>>> fetchUnitEntries(String empID) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/shift_view?empID=$empID'));

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






  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController poNo = TextEditingController();
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  bool showInitialData = true;
  String? errorMessage;
  String selectedShiftType = '';

  String selectedCustomer = '';

  //fetchemploye details



  List<Map<String, dynamic>> data4 = [];
  List<Map<String, dynamic>> employeename = [];

  Future<void> fetchData4(String fromDate,String toDate,String shiftType) async {
    try {
      final formattedFromDate = DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(fromDate));
      final formattedToDate = DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(toDate));

      final response = await http.get(Uri.parse('http://localhost:3309/getemployeein_shiftdate?fromDate=$formattedFromDate&toDate=$formattedToDate&shiftType=$shiftType'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          print(" employeee  $data");
          data4 = data.cast<Map<String, dynamic>>();
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
            title: Text('Alert'),
            content: Text('Choose the Fromdate'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftView(
                    id: widget.id,
                    empID: widget.empID,
                    empName:widget.empName,
                    fromDate: widget.fromDate,
                    toDate: widget.toDate,
                    shiftType:widget.shiftType,
                    shiftTime: widget.shiftTime,)));
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }


  List<Map<String, dynamic>> filteredData4 = [];
  void filterData4(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData4 = data4;
        empID.clear();
        filteredData4 = data4;
      } else {
        filteredData4 = data4.where((item) {
          String id = item['first_name']?.toString()?.toLowerCase() ?? '';
          return id == searchText.toLowerCase();
        }).toList();
        if (filteredData4.isNotEmpty) {
          Map<String, dynamic> order = filteredData4.first;
          empID.text = order['emp_code']?.toString() ?? '';
        } else {
          empID.clear();
        }
      }
    });
  }












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
          String id = item['emp_code']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['emp_code']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
        }
      }});
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }


  Future<List<Map<String, dynamic>>> fetchduplicate() async {
    try {

      final response = await http.get(Uri.parse('http://localhost:3309/fetch_shift'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("6666666666666666666666666666666666666666666:$data");
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

//insert shift
  Future<void> insertDataShift(Map<String, dynamic> dataToInsertShift) async {
    const apiUrl = 'http://localhost:3309/shift_data'; // Replace with your server address
    try {
      List<Map<String, dynamic>> unitEntries = await fetchduplicate();
      bool isDuplicate = unitEntries.any((entry) {
        String entryFromDate = entry['fromDate'];
        String entryToDate = entry['toDate'];

        DateTime existingFromDate = DateTime.parse(entryFromDate);
        DateTime existingToDate = DateTime.parse(entryToDate);

        DateTime newFromDate = DateTime.parse(dataToInsertShift['fromDate']);
        DateTime newToDate = DateTime.parse(dataToInsertShift['toDate']);

        // Check for date range overlap
        bool overlap = !(newToDate.isBefore(existingFromDate) || newFromDate.isAfter(existingToDate));

        // Check for emp_code match
        bool empCodeMatch = entry['alterEmpID'] == dataToInsertShift['alterEmpID'];

        return overlap && empCodeMatch;
      });

      if (isDuplicate) {
        // Display your duplicate entry dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Shift"),
              content: Text("This Empolyee already exists within the specified date"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftView(
                      id: widget.id,
                      empID: widget.empID,
                      empName:widget.empName,
                      fromDate: widget.fromDate,
                      toDate: widget.toDate,
                      shiftType:widget.shiftType,
                      shiftTime: widget.shiftTime,)));
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        print('Duplicate entry, not inserted');
        return;
      }
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertSup': dataToInsertShift}),
      );

      if (response.statusCode == 200) {
        print('Data inserted successfully');
      } else {
        print('Failed to insert data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  String empIDValue = '';
  String?callUnit;

  Future<void> filterFromToDateData(DateTime fromDate, DateTime toDate, String empIDValue) async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/check_empid_updateexists?fromDate=${DateFormat('yyyy-MM-dd').format(fromDate)}&toDate=${DateFormat('yyyy-MM-dd').format(toDate)}&alterEmpID=${empIDValue}');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final unit = responseData['alterEmpID'];

        if (unit != null) {
          final empIDExists = await checkEmpIDExists(fromDate, toDate, empIDValue);

          setState(() {
            if (empIDExists) {
              errorMessage = 'Employee ID already exists for the selected date range';
            } else {
              errorMessage = null;
            }

            callUnit = unit;
          });
        } else {
          setState(() {
            // Handle the case where emp_code is null
          });
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  Future<void> checkDuplicateEmpID() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_fromtodate?fromDate=${DateFormat('yyyy-MM-dd').format(fromDate)}&toDate=${DateFormat('yyyy-MM-dd').format(toDate)}');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final unit = responseData['alterEmpID'];

        if (unit != null) {
          final empIDExists = await checkEmpIDExists(fromDate, toDate, empID.text);

          setState(() {
            if (empIDExists) {
              errorMessage = 'Employee already exists for the selected date';
            } else {
              errorMessage = null;
            }

            callUnit = unit;
          });
        } else {
          setState(() {
            // Handle the case where emp_code is null
          });
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<bool> checkEmpIDExists(DateTime fromDate, DateTime toDate, String empIDValue) async {
    try {
      final url = Uri.parse('http://localhost:3309/check_empid_updateexists?fromDate=${DateFormat('yyyy-MM-dd').format(fromDate)}&toDate=${DateFormat('yyyy-MM-dd').format(toDate)}&emp_code=$empIDValue');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['exists'];
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    empName.addListener(() {
      filterData4(empName.text);
    });
    DateTime fromDate = DateTime.now();
    DateTime toDate = DateTime.now();
    DateTime currentdate = DateTime.now();
    final formattedDate = DateFormat("yyyy-MM-dd").format(currentdate);
    return  MyScaffold(
        route: "shift view",
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
                          child:  Column(
                            children: [
                              Wrap(
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 25),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.shopping_cart, // Replace with the icon you want to use
                                                  // Replace with the desired icon color
                                                ),
                                                Text("Shift Edit", style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20
                                                ),),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left:780),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 0),
                                                  child: Align(
                                                    alignment: Alignment.topRight,
                                                    child: Container(
                                                      // width: 130,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              SizedBox(height: 20,),
                                                              SizedBox(
                                                                width: 95,
                                                                child: Container(
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
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
                                                                      */
/*Divider(
                                                                        color: Colors.grey.shade600,
                                                                      ),*//*

                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                                            Row(
                                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                              children: [
                                              Align(
                                                alignment:Alignment.topLeft,
                                                child:Text("Shift Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    errorMessage ?? '',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            ],),

                                            SizedBox(height: 15,),
                                            Wrap(
                                              spacing:35,
                                              children: [
                                                SizedBox(
                                                  width: 220,
                                                  height: 70,
                                                  child: TextFormField(
                                                    style: TextStyle(fontSize: 13),
                                                    readOnly: true,
                                                    onTap: () async {
                                                      DateTime currentDate = DateTime.now();
                                                      DateTime initialDate = widget.fromDate != null
                                                          ? DateTime.parse(widget.fromDate!).toLocal()
                                                          : currentDate;

                                                      DateTime? pickedDate = await showDatePicker(
                                                        context: context,
                                                        initialDate: initialDate,
                                                        firstDate: initialDate,  // Set firstDate to initialDate
                                                        lastDate: initialDate.add(Duration(days: 6)),
                                                      );

                                                      if (pickedDate != null) {
                                                        setState(() {
                                                          fromDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                                                        });
                                                        // fetchData4(DateFormat('yyyy-MM-dd').format(pickedDate));
                                                      }
                                                    },
                                                    controller: fromDateController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "From Date",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 220,height: 70,
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        errorMessage=null;
                                                      });
                                                    },
                                                    initialValue: widget.shiftType,
                                                    style: TextStyle(fontSize: 13),
                                                    inputFormatters: [
                                                      UpperCaseTextFormatter(),
                                                    ],
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "Shift Type",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(
                                                  width: 220,
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    controller: shiftTimeController,
                                                    style: TextStyle(
                                                        fontSize: 13),
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return '* Enter Timing';
                                                      }
                                                      return null;
                                                    },
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[
                                                      LengthLimitingTextInputFormatter(2),
                                                      FilteringTextInputFormatter.digitsOnly,
                                                    ],
                                                    decoration: InputDecoration(
                                                      labelText: "Shift Timing",
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 220,
                                                  height:50,
                                                  child: TypeAheadFormField<String>(
                                                    textFieldConfiguration: TextFieldConfiguration(
                                                      controller: empName,
                                                      onChanged: (value) async {
                                                        // await checkDuplicateEmpID();
                                                        String capitalizedValue = capitalizeFirstLetter(value);
                                                        empName.value = empName.value.copyWith(
                                                          text: capitalizedValue,
                                                          selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                        );
                                                        setState(() {
                                                          errorMessage = null; // Reset error message when user types
                                                        });
                                                      },
                                                      style: const TextStyle(fontSize: 13),
                                                      decoration: InputDecoration(
                                                        fillColor: Colors.white,
                                                        filled: true,
                                                        labelText: "Employee Name",
                                                        labelStyle: TextStyle(fontSize: 13,color: Colors.black),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                    suggestionsCallback: (pattern) async {
                                                      List<String> suggestions = data4
                                                      // suggestionsCallback: (pattern) async {
                                                      // return itemGroups.where((group) => group.toLowerCase().startsWith(pattern.toLowerCase()));
                                                      //                                                     },
                                                          .where((item) =>
                                                      (item['first_name']?.toString()?.toLowerCase() ?? '').startsWith(pattern.toLowerCase()) ||
                                                          (item['emp_code']?.toString()?.toLowerCase() ?? '').startsWith(pattern.toLowerCase()))
                                                          .map((item) => item['first_name'].toString())
                                                          .toSet()
                                                          .toList();
                                                      // If the pattern is empty, return all suggestions
                                                      if (pattern.isEmpty) {
                                                        suggestions = data4
                                                            .map((item) => item['first_name'].toString())
                                                            .toSet()
                                                            .toList();
                                                      }

                                                      return suggestions;
                                                    },
                                                    itemBuilder: (context, suggestion) {
                                                      Map<String, dynamic> customerData = data4.firstWhere(
                                                            (item) => item['first_name'].toString() == suggestion,
                                                        orElse: () => Map<String, dynamic>(),
                                                      );
                                                      return ListTile(
                                                        title: Text('${customerData['first_name']} (${customerData['emp_code']})'),
                                                      );
                                                    },
                                                    onSuggestionSelected: (suggestion) {
                                                      Map<String, dynamic> customerData = data4.firstWhere(
                                                            (item) => item['first_name'].toString() == suggestion,
                                                        orElse: () => Map<String, dynamic>(),
                                                      );
                                                      setState(() {
                                                        selectedCustomer = suggestion;
                                                        empName.text = suggestion;
                                                      });
                                                      print('Selected Customer: $selectedCustomer, Customer Code: ${customerData['emp_code']}');
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 220,height: 70,
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        errorMessage=null;
                                                      });
                                                    }, controller: empID,
                                                    style: TextStyle(fontSize: 13),
                                                    inputFormatters: [
                                                      UpperCaseTextFormatter(),
                                                    ],
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "Employee ID",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Wrap(
                                              children: [
                                                */
/* SizedBox(
                                                  width: 220,
                                                  height: 70,
                                                  child: TextFormField(
                                                    style: TextStyle(fontSize: 13),
                                                    readOnly: true,
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return '* Enter To Date';
                                                      }
                                                      return null;
                                                    },
                                                    onTap: () async {
                                                      DateTime? pickedDate = await showDatePicker(
                                                        context: context,
                                                        initialDate: DateTime.now(),
                                                        firstDate: DateTime(2000),
                                                        lastDate: DateTime(2100),
                                                      );
                                                      if (pickedDate != null) {
                                                        setState(() {
                                                          toDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                                        });
                                                      }
                                                    },
                                                    controller: toDateController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "To Date",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                )*//*




                                                */
/*  SizedBox(
                                                  width: 220,
                                                  height: 30,
                                                  child: TextFormField(
                                                    initialValue: widget.shiftType.toString(),
                                                    style: TextStyle(
                                                        fontSize: 13),
                                                    keyboardType: TextInputType.text,
                                                    decoration: InputDecoration(

                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        labelText: "Shift Type",
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(8,),
                                                        )
                                                    ),
                                                    onChanged: (value){
                                                      shiftTypeController.text=value;
                                                      shiftTimeController.text = shiftTypeToTime[selectedShiftType] ?? '9AM - 6PM';
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 70,),
                                                SizedBox(
                                                  width: 220,
                                                  height: 30,
                                                  child: TextFormField(
                                                    // readOnly: true,

                                                    initialValue: widget.shiftTime.toString(),
                                                    style: TextStyle(
                                                        fontSize: 13),
                                                    keyboardType: TextInputType.text,
                                                    decoration: InputDecoration(

                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        labelText: "Shift Time",
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(8,),
                                                        )
                                                    ),
                                                    onChanged: (value){
                                                      shiftTimeController.text=value;
                                                    },
                                                  ),
                                                ),*//*

                                              ],
                                            ),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 450,top: 20),
                      child: Row(
                        children: [

                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () async {
                              await checkDuplicateEmpID();
                              // await checkDuplicateEmpID();
                              if(_formKey.currentState!.validate()){
                                 if (empName.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter Employee Name';
                                  });
                                }
                                 else  if (empID.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter Employee ID';
                                });
                              }
                                else if (errorMessage == null){
                                  Map<String, dynamic> dataToInsertShift = {
                                    'date': formattedDate,
                                    'first_name':widget.empName,
                                    'emp_code':widget.empID,
                                    'alterEmp': empName.text,
                                    'alterEmpID': empID.text,
                                    'shiftType': shiftType.toString(),
                                    'shiftTime': shiftTimeController.text,
                                    'modifyDate':currentdate.toString(),
                                    'fromDate': DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(fromDateController.text)),
                                    'toDate': DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(toDateController.text)),
                                  };
                                  insertDataShift(dataToInsertShift);
                                  try{
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Shift"),
                                          content: Text(" Update Successfully"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftCreation()));
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                  catch (e) {
                                    print('Error inserting data: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Failed to save data. Please try again."),
                                      ),
                                    );
                                  }
                                }
                              }
                              print("Successfull");
                            },
                            child: Text("UPDATE",style: TextStyle(color: Colors.white),),),

                          SizedBox(width: 20,),
                          MaterialButton(
                            color: Colors.blue.shade600,
                            onPressed: (){
                              // Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>const ShiftCreation()));
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
*/
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/master/shift_entry.dart';
import '../new_sales_entries.dart';


class ShiftView extends StatefulWidget {



  int id;
  String? empID;
  String? empName;
  String? fromDate;
  String? toDate;
  String? shiftType;
  String? shiftTime;

  ShiftView({Key? key,
    required this.id,
    required this.empID,
    required this.empName,
    required this.fromDate,
    required this.toDate,
    required this.shiftType,
    required this.shiftTime,

  }) : super(key: key);
  @override
  State<ShiftView> createState() => _ShiftViewState();
}

class _ShiftViewState extends State<ShiftView> {

  Map<String, String> shiftTimingsMap = {
    'General': '9:00AM - 6:00PM',
    'Morning': '8:00AM - 8:00PM',
    'Night': '8:00PM - 8:00AM',
  };


  String shiftType="Shift Type";
  String shiftTime="Shift Timing";

  late DateTime fromDate;
  late DateTime toDate;


  TextEditingController empID=TextEditingController();
  TextEditingController empName=TextEditingController();
  TextEditingController fromDateController=TextEditingController();
  TextEditingController toDateController=TextEditingController();
  TextEditingController shiftTimeController=TextEditingController();
  TextEditingController shiftTypeController=TextEditingController();
  TextEditingController shiftDateController=TextEditingController();
  TextEditingController shifttoDateController=TextEditingController();

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
    shiftDateController = TextEditingController();
    shifttoDateController = TextEditingController();
    fromDateController = TextEditingController();
    toDateController = TextEditingController();
    shiftTimeController = TextEditingController();
    shiftTypeController = TextEditingController();

    DateTime localFromDate = widget.fromDate != null
        ? DateTime.parse(widget.fromDate!).toLocal()
        : DateTime.now();
    DateTime localtoDate = widget.toDate != null
        ? DateTime.parse(widget.toDate!).toLocal()
        : DateTime.now();
    // DateTime localToDate = widget.toDate != null
    //     ? DateTime.parse(widget.toDate!).toLocal()
    //     : DateTime.now();

    shiftDateController.text = widget.fromDate != null
        ? DateFormat("yyyy-MM-dd").format(localFromDate)
        : '';
    shifttoDateController.text = widget.toDate != null
        ? DateFormat("yyyy-MM-dd").format(localtoDate)
        : '';
    // toDateController.text = widget.toDate != null
    //     ? DateFormat("yyyy-MM-dd").format(localToDate)
    //     : '';


    print(shiftDateController.text);
    print(shifttoDateController.text);
    //fetchData4(shiftDateController.text,shifttoDateController.text,widget.shiftType.toString(),);
    print(selectedShiftType);
    shiftTimeController.text = widget.shiftTime.toString();
    shiftTypeController.text = widget.shiftType.toString();
    shiftType = widget.shiftType ?? 'General';
    shiftTypeController.text = shiftType;
    shiftTimeController.text = shiftTimingsMap[shiftType] ?? '9:00AM - 6:00PM';
    //filterFromToDateData(fromDate,toDate,empIDValue);
  }



  Future<List<Map<String, dynamic>>> fetchUnitEntries(String empID) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/shift_view?empID=$empID'));

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

  // Future<void> updateSupplierDetails(String id, String empID, String empName, String fromDate,String toDate,String shiftType,String shiftTime,String modifyDate) async {
  //   final response = await http.put(
  //     Uri.parse('http://localhost:3309/shift_update/$id'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'id': id,
  //       'fromDate': fromDateController.text,
  //       'toDate': toDateController.text,
  //       'shiftTime': shiftTimeController.text,
  //       'shiftType':shiftTypeController.text,
  //       'modifyDate':modifyDate,
  //     }),
  //   );
  //   if (response.statusCode == 200) {
  //     print('Data updated successfully');
  //   } else {
  //     print('Error updating data: ${response.body}');
  //   }
  // }




  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController poNo = TextEditingController();
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  bool showInitialData = true;
  String? errorMessage;
  String selectedShiftType = '';

  String selectedCustomer = '';

  //fetchemploye details



  List<Map<String, dynamic>> data4 = [];
  List<Map<String, dynamic>> employeename = [];

  Future<void> fetchData4(String fromDate,String toDate,String shiftType) async {
    try {
      final formattedFromDate = DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(fromDate));
      final formattedToDate = DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(toDate));

      final response = await http.get(Uri.parse('http://localhost:3309/getemployeein_shiftdate?fromDate=$formattedFromDate&toDate=$formattedToDate&shiftType=$shiftType'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          print(" employeee  $data");
          data4 = data.cast<Map<String, dynamic>>();
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


  List<Map<String, dynamic>> filteredData4 = [];
  void filterData4(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData4 = data4;
        empID.clear();
        filteredData4 = data4;
      } else {
        filteredData4 = data4.where((item) {
          String id = item['first_name']?.toString()?.toLowerCase() ?? '';
          return id == searchText.toLowerCase();
        }).toList();
        if (filteredData4.isNotEmpty) {
          Map<String, dynamic> order = filteredData4.first;
          empID.text = order['emp_code']?.toString() ?? '';
        } else {
          empID.clear();
        }
      }
    });
  }












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
          String id = item['emp_code']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (searchText.isEmpty) {
          filteredData = data;
        } else {
          filteredData = data.where((item) {
            String id = item['emp_code']?.toString() ?? '';
            return id.contains(searchText);
          }).toList();
          showInitialData = false;
        }
      }});
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }


  Future<List<Map<String, dynamic>>> fetchduplicate() async {
    try {

      final response = await http.get(Uri.parse('http://localhost:3309/fetch_shift'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("6666666666666666666666666666666666666666666:$data");
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

//insert shift
  Future<void> insertDataShift(Map<String, dynamic> dataToInsertShift) async {
    const apiUrl = 'http://localhost:3309/shift_data'; // Replace with your server address
    try {
      List<Map<String, dynamic>> unitEntries = await fetchduplicate();
      bool isDuplicate = unitEntries.any((entry) {
        String entryFromDate = entry['fromDate'];
        String entryToDate = entry['toDate'];

        DateTime existingFromDate = DateTime.parse(entryFromDate);
        DateTime existingToDate = DateTime.parse(entryToDate);

        DateTime newFromDate = DateTime.parse(dataToInsertShift['fromDate']);
        DateTime newToDate = DateTime.parse(dataToInsertShift['toDate']);

        // Check for date range overlap
        bool overlap = !(newToDate.isBefore(existingFromDate) || newFromDate.isAfter(existingToDate));

        // Check for emp_code match
        bool empCodeMatch = entry['alterEmpID'] == dataToInsertShift['alterEmpID'];

        return overlap && empCodeMatch;
      });

      if (isDuplicate) {
        // Display your duplicate entry dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Shift"),
              content: Text("This Empolyee already exists within the specified date"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftView(
                      id: widget.id,
                      empID: widget.empID,
                      empName:widget.empName,
                      fromDate: widget.fromDate,
                      toDate: widget.toDate,
                      shiftType:widget.shiftType,
                      shiftTime: widget.shiftTime,)));
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        print('Duplicate entry, not inserted');
        return;
      }
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertSup': dataToInsertShift}),
      );

      if (response.statusCode == 200) {
        print('Data inserted successfully');
      } else {
        print('Failed to insert data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  String empIDValue = '';
  String?callUnit;

  Future<void> filterFromToDateData(DateTime fromDate, DateTime toDate, String empIDValue) async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/check_empid_updateexists?fromDate=${DateFormat('yyyy-MM-dd').format(fromDate)}&toDate=${DateFormat('yyyy-MM-dd').format(toDate)}&alterEmpID=${empIDValue}');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final unit = responseData['alterEmpID'];

        if (unit != null) {
          final empIDExists = await checkEmpIDExists(fromDate, toDate, empIDValue);

          setState(() {
            if (empIDExists) {
              errorMessage = 'Employee ID already exists for the selected date range';
            } else {
              errorMessage = null;
            }

            callUnit = unit;
          });
        } else {
          setState(() {
            // Handle the case where emp_code is null
          });
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  Future<void> checkDuplicateEmpID() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_fromtodate?fromDate=${DateFormat('yyyy-MM-dd').format(fromDate)}&toDate=${DateFormat('yyyy-MM-dd').format(toDate)}');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final unit = responseData['alterEmpID'];

        if (unit != null) {
          final empIDExists = await checkEmpIDExists(fromDate, toDate, empID.text);

          setState(() {
            if (empIDExists) {
              errorMessage = 'Employee already exists for the selected date';
            } else {
              errorMessage = null;
            }

            callUnit = unit;
          });
        } else {
          setState(() {
            // Handle the case where emp_code is null
          });
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<bool> checkEmpIDExists(DateTime fromDate, DateTime toDate, String empIDValue) async {
    try {
      final url = Uri.parse('http://localhost:3309/check_empid_updateexists?fromDate=${DateFormat('yyyy-MM-dd').format(fromDate)}&toDate=${DateFormat('yyyy-MM-dd').format(toDate)}&emp_code=$empIDValue');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['exists'];
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    empName.addListener(() {
      filterData4(empName.text);
    });
    DateTime fromDate = DateTime.now();
    DateTime toDate = DateTime.now();
    DateTime currentdate = DateTime.now();
    final formattedDate = DateFormat("yyyy-MM-dd").format(currentdate);
    return  MyScaffold(
        route: "shift view",backgroundColor: Colors.white,
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
                          child:  Column(
                            children: [
                              Wrap(
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 25),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.shopping_cart, // Replace with the icon you want to use
                                                  // Replace with the desired icon color
                                                ),
                                                Text("Shift Edit", style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20
                                                ),),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left:780),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 0),
                                                  child: Align(
                                                    alignment: Alignment.topRight,
                                                    child: Container(
                                                      // width: 130,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              SizedBox(height: 20,),
                                                              SizedBox(
                                                                width: 95,
                                                                child: Container(
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
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
                                                                      /*Divider(
                                                                        color: Colors.grey.shade600,
                                                                      ),*/
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                                              child:Text("Shift Details",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(height: 15,),
                                            Wrap(
                                              spacing:35,
                                              children: [
                                                SizedBox(
                                                  width: 220,
                                                  height: 70,
                                                  child: TextFormField(
                                                    style: TextStyle(fontSize: 13),
                                                    readOnly: true,
                                                    onTap: () async {
                                                      // DateTime currentDate = DateTime.now();
                                                      DateTime? pickedDate = await showDatePicker(
                                                        context: context,
                                                        initialDate: widget.fromDate != null
                                                            ? DateTime.parse(widget.fromDate!).toLocal()
                                                            : DateTime.now(),
                                                        firstDate: widget.fromDate != null
                                                            ? DateTime.parse(widget.fromDate!).toLocal()
                                                            : DateTime.now(),
                                                        lastDate: widget.toDate != null
                                                            ? DateTime.parse(widget.fromDate!).toLocal().add(Duration(days: 6))
                                                            : DateTime.now().add(Duration(days: 6)),
                                                      );
                                                      if (pickedDate != null) {
                                                        setState(() {
                                                          fromDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                                                        });
                                                        // fetchData4(DateFormat('yyyy-MM-dd').format(pickedDate));
                                                      }
                                                    },
                                                    controller: fromDateController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "From Date",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 220,
                                                  height: 70,
                                                  child: TextFormField(
                                                    style: TextStyle(fontSize: 13),
                                                    readOnly: true,
                                                    onTap: () async {
                                                      DateTime? pickedDate = await showDatePicker(
                                                        context: context,
                                                        initialDate: widget.fromDate != null
                                                            ? DateTime.parse(widget.fromDate!).toLocal()
                                                            : DateTime.now(),
                                                        firstDate: widget.fromDate != null
                                                            ? DateTime.parse(widget.fromDate!).toLocal()
                                                            : DateTime.now(),
                                                        lastDate: widget.toDate != null
                                                            ? DateTime.parse(widget.fromDate!).toLocal().add(Duration(days: 6))
                                                            : DateTime.now().add(Duration(days: 6)),
                                                      );
                                                      if (pickedDate != null) {
                                                        setState(() {
                                                          toDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                                                        });
                                                        fetchData4(
                                                          fromDateController.text,
                                                          toDateController.text,
                                                          widget.shiftType.toString(),
                                                        );
                                                      }
                                                    },
                                                    controller: toDateController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "To Date",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),


                                                SizedBox(
                                                  width: 220,height: 70,
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        errorMessage=null;
                                                      });
                                                    },
                                                    initialValue: widget.shiftType,
                                                    style: TextStyle(fontSize: 13),
                                                    inputFormatters: [
                                                      UpperCaseTextFormatter(),
                                                    ],
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "Shift Type",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),



                                                SizedBox(
                                                  width: 220,
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    controller: shiftTimeController,
                                                    style: TextStyle(
                                                        fontSize: 13),
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return '* Enter Timing';
                                                      }
                                                      return null;
                                                    },
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[
                                                      LengthLimitingTextInputFormatter(2),
                                                      FilteringTextInputFormatter.digitsOnly,
                                                    ],
                                                    decoration: InputDecoration(
                                                      labelText: "Shift Timing",
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 220,
                                                  height:50,
                                                  child: TypeAheadFormField<String>(
                                                    textFieldConfiguration: TextFieldConfiguration(
                                                      controller: empName,
                                                      onChanged: (value) async {
                                                        // await checkDuplicateEmpID();
                                                        String capitalizedValue = capitalizeFirstLetter(value);
                                                        empName.value = empName.value.copyWith(
                                                          text: capitalizedValue,
                                                          selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                        );
                                                        setState(() {
                                                          errorMessage = null; // Reset error message when user types
                                                        });
                                                      },
                                                      style: const TextStyle(fontSize: 13),
                                                      decoration: InputDecoration(
                                                        fillColor: Colors.white,
                                                        filled: true,
                                                        labelText: "Employee Name",
                                                        labelStyle: TextStyle(fontSize: 13,color: Colors.black),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                    suggestionsCallback: (pattern) async {
                                                      List<String> suggestions = data4
                                                      // suggestionsCallback: (pattern) async {
                                                      // return itemGroups.where((group) => group.toLowerCase().startsWith(pattern.toLowerCase()));
                                                      //                                                     },
                                                          .where((item) =>
                                                      (item['first_name']?.toString()?.toLowerCase() ?? '').startsWith(pattern.toLowerCase()) ||
                                                          (item['emp_code']?.toString()?.toLowerCase() ?? '').startsWith(pattern.toLowerCase()))
                                                          .map((item) => item['first_name'].toString())
                                                          .toSet()
                                                          .toList();
                                                      // If the pattern is empty, return all suggestions
                                                      if (pattern.isEmpty) {
                                                        suggestions = data4
                                                            .map((item) => item['first_name'].toString())
                                                            .toSet()
                                                            .toList();
                                                      }

                                                      return suggestions;
                                                    },
                                                    itemBuilder: (context, suggestion) {
                                                      Map<String, dynamic> customerData = data4.firstWhere(
                                                            (item) => item['first_name'].toString() == suggestion,
                                                        orElse: () => Map<String, dynamic>(),
                                                      );
                                                      return ListTile(
                                                        title: Text('${customerData['first_name']} (${customerData['emp_code']})'),
                                                      );
                                                    },
                                                    onSuggestionSelected: (suggestion) {
                                                      Map<String, dynamic> customerData = data4.firstWhere(
                                                            (item) => item['first_name'].toString() == suggestion,
                                                        orElse: () => Map<String, dynamic>(),
                                                      );
                                                      setState(() {
                                                        selectedCustomer = suggestion;
                                                        empName.text = suggestion;
                                                      });
                                                      print('Selected Customer: $selectedCustomer, Customer Code: ${customerData['emp_code']}');
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 220,height: 70,
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        errorMessage=null;
                                                      });
                                                    },
                                                    controller: empID,
                                                    style: TextStyle(fontSize: 13),
                                                    inputFormatters: [
                                                      UpperCaseTextFormatter(),
                                                    ],
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "Employee ID",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Wrap(
                                              children: [
                                              ],
                                            ),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 450,top: 20),
                      child: Row(
                        children: [
                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () async {
                              await checkDuplicateEmpID();
                              // await checkDuplicateEmpID();
                              if(_formKey.currentState!.validate()){
                                if (empID.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter Employee ID';
                                  });
                                }
                                else if (empName.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter Employee Name';
                                  });
                                }
                                else if (shiftType==null) {
                                  setState(() {
                                    errorMessage = '* Select a Shift Type';
                                  });
                                  return;
                                }
                                else if (errorMessage == null){
                                  Map<String, dynamic> dataToInsertShift = {
                                    'date': formattedDate,
                                    'first_name':widget.empName,
                                    'emp_code':widget.empID,
                                    'alterEmp': empName.text,
                                    'alterEmpID': empID.text,
                                    'shiftType': shiftType.toString(),
                                    'shiftTime': shiftTimeController.text,
                                    'modifyDate':currentdate.toString(),
                                    'fromDate': DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(fromDateController.text)),
                                    'toDate': DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(toDateController.text)),
                                  };
                                  insertDataShift(dataToInsertShift);
                                  try{
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Shift"),
                                          content: Text(" Update Successfully"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftCreation()));
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                  catch (e) {
                                    print('Error inserting data: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Failed to save data. Please try again."),
                                      ),
                                    );
                                  }
                                }
                              }
                              print("Successfull");
                            },
                            child: Text("UPDATE",style: TextStyle(color: Colors.white),),),
                          /* MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: (){
                              if (fromDateController.text.isNotEmpty) {
                                updateSupplierDetails(
                                  widget.id.toString(),
                                  empID.text,
                                  empName.text,
                                  fromDateController.text,
                                  toDateController.text,
                                  shiftTimeController.text,
                                  shiftTypeController.text,
                                  formattedDate,
                                );
                              } else {
                                print('supName cannot be empty');
                              }
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Shift"),
                                    content: Text("Update successfully"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftCreation()));
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text("SAVE",style: TextStyle(color: Colors.white),),),*/
                          SizedBox(width: 20,),
                          MaterialButton(
                            color: Colors.blue.shade600,
                            onPressed: (){
                              // Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>const ShiftCreation()));
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
