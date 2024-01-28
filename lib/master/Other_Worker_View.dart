import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/master/tabcontroller.dart';

import 'Other_Worker.dart';

class Other_Worker_view extends StatefulWidget {

  int id;
  String? fromDate;
  String? toDate;
  String? shiftType;
  String? opOneName;
  String? emp_code1;
  String? workingType;


  Other_Worker_view({Key? key,
    required this.id,
    required this.fromDate,
    required this.toDate,
    required this.shiftType,
    required this.opOneName,
    required this.emp_code1,
    required this.workingType,

  }) : super(key: key);
  @override
  State<Other_Worker_view> createState() => _Other_Worker_viewState();
}

class _Other_Worker_viewState extends State<Other_Worker_view> {

  List<Map<String, dynamic>> persondata = [];

  Future<void> filterFromtodateData(
      String fromDate, String toDate, String shiftType,) async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_combined?fromDate=$fromDate&toDate=$toDate&shiftType=$shiftType');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List<dynamic>) {
          setState(() {
            persondata = List<Map<String, dynamic>>.from(responseData.cast<Map<String, dynamic>>());
          });

          print('Person Data:');
          for (var data in persondata) {
            print('alterEmpID: ${data['alterEmpID']}, alterEmp: ${data['alterEmp']}, shiftType: ${data['shiftType']}');
          }
        } else {
          print('Error: Response data is not a List');
          print('Response Body: $responseData');
        }

      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  String shiftType="Shift Type";
  String shiftTime="Shift Timing";
  TextEditingController fromDateController=TextEditingController();
  TextEditingController toDateController=TextEditingController();
  TextEditingController op1 =TextEditingController();
  TextEditingController emp_code1=TextEditingController();
  TextEditingController wrk_type=TextEditingController();


  /// for text form field
  String? errorMessage;
  List<String> selectedNames = []; /// for suggestion fillter
  List<Map<String, dynamic>> data = [];
  String? empID="";
  String? empID2="";
  String validname1="";
  String dropdownvalue = "Shift Type";


  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    fromDate = DateTime.now();
    toDate = fromDate.add(Duration(days: 6));
    setState(() {
      dropdownvalue =widget.shiftType.toString();
      op1.text= widget.opOneName.toString();
      wrk_type.text= widget.workingType.toString();
      emp_code1.text = widget.emp_code1.toString();


    });

    controller = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(fromDate),
    );

    filterFromtodateData(fromDate.toString(),toDate.toString(),dropdownvalue);
    // filterFromtodateData(dropdownvalue);
    fromDateController = TextEditingController();
    toDateController = TextEditingController();
    // shiftTimeController = TextEditingController();
    // shiftTypeController = TextEditingController();

    DateTime localFromDate = widget.fromDate != null
        ? DateTime.parse(widget.fromDate!).toLocal()
        : DateTime.now();
    DateTime localToDate = widget.toDate != null
        ? DateTime.parse(widget.toDate!).toLocal()
        : DateTime.now();

    fromDateController.text = widget.fromDate != null
        ? DateFormat("dd-MM-yyyy").format(localFromDate)
        : '';
    toDateController.text = widget.toDate != null
        ? DateFormat("dd-MM-yyyy").format(localToDate)
        : '';

    // shiftTypeController.text = widget.shiftType.toString();
    shiftType = widget.shiftType ?? 'General';
    // shiftTypeController.text = shiftType;
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime date = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  late TextEditingController controller;
  late DateTime eod;// Declare as late since it will be initialized in the constructor
  _Other_Worker_viewState() {
    eod = DateTime.now();
    eod = DateTime(eod.year, eod.month, eod.day);
  }


  /// INSERT QUERY

  Map<String, dynamic> dataToInsertSupplier1 = {};
  Map<String, dynamic> dataToInsertSupItem1 = {};
  Map<String, dynamic> dataToInsertSup = {};

  /// Duplicate Check
  Future<List<Map<String, dynamic>>> fetchduplicate() async {
    try {

      final response = await http.get(Uri.parse('http://localhost:3309/fetch_other_working_entry'));
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


  Future<void> insertDataSup(Map<String, dynamic> dataToInsertSup) async {
    const String apiUrl = 'http://localhost:3309/other_working_entry_update'; // Replace with your server details
    try {
      List<Map<String, dynamic>> unitEntries = await fetchduplicate();
      bool isDuplicate = unitEntries.any((entry) {
        String entryFromDate = entry['fromDate'];
        String entryToDate = entry['toDate'];

        DateTime existingFromDate = DateTime.parse(entryFromDate);
        DateTime existingToDate = DateTime.parse(entryToDate);

        DateTime newFromDate = DateTime.parse(dataToInsertSup['fromDate']);
        DateTime newToDate = DateTime.parse(dataToInsertSup['toDate']);

        // Check for date range overlap
        bool overlap = !(newToDate.isBefore(existingFromDate) || newFromDate.isAfter(existingToDate));

        // Check for emp_code match
        //bool empCodeMatch = entry['alterEmpID'] == dataToInsertSup['alterEmpID'];
        //return overlap && empCodeMatch;

        bool empCodeMatch = entry['emp_code1'] == dataToInsertSup['emp_code1'];
        /// entry['emp_code2'] == dataToInsertSup['emp_code2'] &&
        ///  entry['emp_code3'] == dataToInsertSup['emp_code3'];

        return overlap && empCodeMatch;


      });

      if (isDuplicate) {
        // Display your duplicate entry dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Other Worker"),
              content: Text("This Value Already Stored "),
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
        body: jsonEncode({'dataToInsertSup': dataToInsertSup}),
      );
      if (response.statusCode == 200) {
        print('TableData inserted successfully');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Other Workers"),
                content: Text("Update successfully"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Other_worker()));
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            }
        );
      } else {
        print('Failed to insert data');
        throw Exception('Failed to  insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  Future<void> supDataToDatabase() async {
    List<Future<void>> insertFutures = [];
    Map<String, dynamic> dataToInsertSup = {
      'createdate':date.toString(),
      'shiftdate':eod.toString(),
      "opOneName":op1.text,
      "emp_code1":emp_code1.text,
      "shiftType": dropdownvalue.toString(),
      "fromDate":fromDate.toString(),
      "toDate":toDate.toString(),
      "workingType":wrk_type.text,


    };
    /*insertFutures.add(insertDataSup(dataToInsertSup));
    await Future.wait(insertFutures);*/
    await insertDataSup(dataToInsertSup);

  }

  /// for Text form Field  Datas
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentdate = DateTime.now();
    final formattedDate = DateFormat("dd-MM-yyyy").format(currentdate);
    return  MyScaffold(
        route: "Other_Worker_View",backgroundColor: Colors.white,
        body: Form(
            key: _formKey,
            child:SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 2,),
                    // Text(shiftTypeController.text),
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 25),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.shopping_cart, // Replace with the icon you want to use
                                                  // Replace with the desired icon color
                                                ),
                                                Text("Other Workers Edit", style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20
                                                ),),
                                              ],
                                            ),
                                          ),

                                          Column(
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
                                                                          child: TextFormField(
                                                                            style: TextStyle(fontSize: 13),
                                                                            readOnly: true,
                                                                            onTap: () {
                                                                              showDatePicker(
                                                                                context: context,
                                                                                initialDate: eod,
                                                                                firstDate: DateTime.now(),
                                                                                // Set the range of selectable dates
                                                                                lastDate: DateTime(2100),
                                                                              ).then((date) {
                                                                                if (date != null) {
                                                                                  setState(() {
                                                                                    eod =
                                                                                        date;
                                                                                    dropdownvalue = "Shift Type";
                                                                                    // Update the selected date
                                                                                  });
                                                                                }
                                                                              });

                                                                            },

                                                                            controller: TextEditingController(
                                                                              text: DateFormat('dd-MM-yyyy').format(eod),
                                                                            ),
                                                                          )
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
                                              child:Text("Other Workers Details ",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Text(
                                                errorMessage ?? '',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                            SizedBox(height: 15,),
                                            Wrap(
                                              children: [
                                                SizedBox(
                                                    width: 200,
                                                    height: 70,

                                                    child: TextFormField(
                                                      style: TextStyle(fontSize: 13),
                                                      readOnly: true,
                                                      onTap: () async  {
                                                        DateTime currentDate = DateTime.now();
                                                        showDatePicker(
                                                          context: context,
                                                          initialDate: fromDate,
                                                          firstDate:currentDate,
                                                          lastDate: currentDate.add(Duration(days: 6)),

                                                        ).then((date) {
                                                          if (date != null) {
                                                            setState(() {
                                                              fromDate = date;
                                                              // toDate = fromDate.add(Duration(days: 5));
                                                              controller.text = DateFormat('dd-MM-yyyy').format(fromDate);


                                                            });
                                                          }
                                                        });
                                                      },

                                                      controller: controller,
                                                      decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        labelText: "From Date",
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    )
                                                ),   /// from date
                                                SizedBox(width: 70,),
                                                SizedBox(
                                                  width: 200,
                                                  height: 70,
                                                  child: TextFormField(
                                                    style: TextStyle(fontSize: 13),
                                                    readOnly: true,
                                                    onTap: () {
                                                      DateTime currentDate = DateTime.now();
                                                      showDatePicker(
                                                        context: context,
                                                        initialDate: toDate,
                                                        firstDate: fromDate,
                                                        lastDate: fromDate.add(Duration(days: 6)),
                                                      ).then((date) {
                                                        if (date != null ) {
                                                          setState(() {
                                                            toDate = date;
                                                            filterFromtodateData(
                                                              fromDate.toString(),
                                                              toDate.toString(),
                                                              widget.shiftType.toString(), // Use shift type from the widget
                                                            );
                                                          });
                                                        }
                                                      });
                                                    },
                                                    controller: TextEditingController(text: DateFormat('dd-MM-yyyy').format(toDate)),
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "To Date",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),   ///TO Date
                                                SizedBox(width: 70,),
                                                SizedBox(
                                                  width: 220,
                                                  height: 70,
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: widget.shiftType.toString(),
                                                    style: TextStyle(fontSize: 13),
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      labelText: "Shift Type",
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),      /// shift Type
                                              ],
                                            ),  /// from date and to date and shift type
                                            SizedBox(height: 10,),
                                            Wrap(
                                              children: [
                                                SizedBox(
                                                  width: 200, height: 70,
                                                  child: TypeAheadFormField<String>(
                                                    textFieldConfiguration: TextFieldConfiguration(

                                                      controller: op1,
                                                      enabled: true,
                                                      onChanged: (query) {
                                                        setState(() {
                                                          errorMessage = null;
                                                        });

                                                        String capitalizedValue = capitalizeFirstLetter(query);
                                                        op1.value = op1.value.copyWith(
                                                          text: capitalizedValue,
                                                          selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                        );
                                                      },
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.deny(RegExp(r'\d')),
                                                      ],
                                                      style: const TextStyle(fontSize: 13),
                                                      decoration: InputDecoration(
                                                        fillColor: Colors.white,
                                                        filled: true,
                                                        labelText: "Person 1",
                                                        labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                    suggestionsCallback: (pattern) async {
                                                      if (selectedNames.isNotEmpty) {
                                                        List<String> suggestions = persondata
                                                            .where((item) => item['alterEmpID'] != null) // Filter out null alterEmpID
                                                            .map<String>((item) => '${item['alterEmp']} (${item['alterEmpID']})')
                                                            .toSet()
                                                            .toList();

                                                        suggestions = suggestions
                                                            .where((suggestion) => !selectedNames.contains(suggestion))
                                                            .toList();

                                                        return suggestions;
                                                      }
                                                      List<String> suggestions = persondata
                                                          .where((item) =>
                                                      (item['alterEmp']?.toString()?.toLowerCase() ?? '')
                                                          .startsWith(pattern.toLowerCase()) &&
                                                          item['alterEmpID']?.toString()?.toLowerCase() != empID?.toLowerCase() &&
                                                          item['alterEmpID']?.toString()?.toLowerCase() != empID2?.toLowerCase())
                                                          .map<String>((item) => '${item['alterEmp']} (${item['alterEmpID']})')
                                                          .toSet()
                                                          .toList();

                                                      return suggestions;
                                                    },
                                                    itemBuilder: (context, suggestion) {
                                                      return ListTile(
                                                        title: Text(suggestion),
                                                      );
                                                    },
                                                    onSuggestionSelected: (suggestion) {
                                                      String selectedEmpName = suggestion.split(' ')[0];
                                                      String selectedEmpID = suggestion.split('(')[1].split(')')[0];

                                                      setState(() {
                                                        emp_code1.text = selectedEmpID;
                                                        print(emp_code1.text);
                                                      });

                                                      selectedNames.add(suggestion);

                                                      //selectedOperator1 = suggestion;

                                                      bool isValidID = data.any((item) =>
                                                      '${item['alterEmp']}'.toLowerCase() == selectedEmpID.toLowerCase());
                                                      validname1 = isValidID.toString();

                                                      if (selectedEmpID == empID2) {
                                                        setState(() {
                                                          errorMessage = "Already Assigned the ID in Operator 2";
                                                        });
                                                      }
                                                      else {
                                                        setState(() {
                                                          empID = selectedEmpID;
                                                          op1.text = suggestion;
                                                        });

                                                        Future.delayed(Duration(milliseconds: 100), () {
                                                          setState(() {
                                                          });
                                                        });
                                                      }

                                                      print(' ID: $selectedEmpID');
                                                    },
                                                  ),
                                                ), /// operator 1
                                                SizedBox(width: 70,),
                                                SizedBox(
                                                  width: 200,
                                                  height: 70,
                                                  child: TextFormField(
                                                    controller: wrk_type,
                                                    //focusNode: op1FocusNode,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        errorMessage = null;
                                                      });
                                                    },
                                                    style: const TextStyle(fontSize: 13),
                                                    decoration: InputDecoration(
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      labelText: "Working Type ",
                                                      labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 70,),
                                                SizedBox( width: 200,
                                                    height: 70,child: Container(width: 275,height: 70,))

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
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (dropdownvalue == "Shift Type") {
                                  setState(() {
                                    errorMessage = '* Select a shift';
                                  });
                                } else if (op1.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Person 1';
                                  });
                                }
                                else if(wrk_type.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Working Type ';
                                  });
                                }
                                else {
                                  supDataToDatabase();
                                  print('supName cannot be empty');
                                }

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
