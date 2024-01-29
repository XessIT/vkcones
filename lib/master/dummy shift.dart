import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vinayaga_project/main.dart';
import 'package:vinayaga_project/sale/dc.dart';
import 'package:http/http.dart' as http;
import '../home.dart';
import 'package:intl/intl.dart';

class ShiftEntry extends StatefulWidget {
  const ShiftEntry({Key? key}) : super(key: key);

  @override
  State<ShiftEntry> createState() => _ShiftEntryState();
}

class _ShiftEntryState extends State<ShiftEntry> {
  final _formKey = GlobalKey<FormState>();

  DateTime date = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  Map<String, String> shiftTimingsMap = {
    'General': '9:00AM - 6:00PM',
    'Morning': '8:00AM - 8:00PM',
    'Night': '8:00PM - 8:00AM',
  };


  void _resetForm() {
    _formKey.currentState!.reset();
  }
  void _cancelForm() {
    print('Form cancelled!');
  }
  Map<String, dynamic> dataToInsert = {};







  TextEditingController empName=TextEditingController();
  TextEditingController empID=TextEditingController();
  TextEditingController shiftTiming=TextEditingController();
  late TextEditingController controller;

  Map<String, dynamic> dataToInsertShift = {};
  Future<void> insertDataShift(Map<String, dynamic> dataToInsertShift) async {
    const String apiUrl = 'http://localhost:3309/shift_data'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertSup': dataToInsertShift}),
      );
      if (response.statusCode == 200) {
        print('TableData inserted successfully');
      } else {
        print('Failed to Table insert data');
        throw Exception('Failed to Table insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  Future<void> shiftDataToDatabase() async {
    List<Future<void>> insertFutures = [];
    Map<String, dynamic> dataToInsertShift = {
      'date': date.toString(),
      'empName':empName.text,
      'empID':empID.text,
      'fromDate':fromDate,
      'toDate':toDate,
      'shiftType':shiftType,
      'shiftTime':shiftTime
    };
    insertFutures.add(insertDataShift(dataToInsertShift));
    await Future.wait(insertFutures);
  }


  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    fromDate = DateTime.now(); // Initialize selectedDate with a default value
    controller = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(fromDate),
    );
  }

  void validateDropdown() {
    setState(() {
      dropdownValid1 = shiftType != "Shift Type";
      dropdownValid2 = shiftTime != "Shift Timing";
    });
  }

  bool dropdownValid1 = true;
  bool dropdownValid2 = true;
  String shiftType="Shift Type";
  String shiftTime="Shift Timing";
  String? errorMessage;

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  final TextEditingController dob = TextEditingController();

  DateTime firstSelectableYear = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    return MyScaffold(
        route: "shift_entry",backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity, // Set the width to full page width
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey), // Add a border for the box
                          borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                        ),
                        child:Wrap(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.edit),
                                    const Text("  Shift Creation", style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                    ),),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 580),
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
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left:130.0,top:15),
                                                            child: Container(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Align(
                                                                    alignment: Alignment.topLeft,
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(left: 15,bottom: 10.0),
                                                                      child: Text(
                                                                        DateFormat('dd-MM-yyyy').format(date), // Change the date format here
                                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 218,
                        width: double.infinity, // Set the width to full page width
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.grey), // Add a border for the box
                          borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(top: 10),
                              child: Text("Shift Details",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                            ),
                            SizedBox(height: 8,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      height: 70,
                                      child: TextFormField(
                                        style: TextStyle(fontSize: 13),
                                        readOnly: true, // Set the field as read-only
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '* Enter From Date';
                                          }
                                          return null;
                                        },
                                        onTap: () {
                                          showDatePicker(
                                            context: context,
                                            initialDate: fromDate,
                                            firstDate: DateTime(2000), // Set the range of selectable dates
                                            lastDate: DateTime(2100),
                                          ).then((date) {
                                            if (date != null) {
                                              setState(() {
                                                fromDate = date; // Update the selected date
                                                toDate = fromDate.add(Duration(days: 6));
                                                controller.text = DateFormat('yyyy-MM-dd').format(fromDate);
                                              });
                                            }
                                          });
                                        },
                                        controller: controller,
                                        // controller: TextEditingController(
                                        //   text: DateFormat('yyyy-MM-dd').format(selectedDate)),
                                        // controller: TextEditingController(text: selectedDate.toString().split(' ')[0]), // Set the initial value of the field to the selected date
                                        decoration: InputDecoration(
                                          // filled: true,
                                          // fillColor: Colors.white,
                                          labelText: "From Date",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      height: 70,
                                      child: TextFormField(
                                        style: TextStyle(fontSize: 13),
                                        readOnly: true,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '* Enter To Date';
                                          }
                                          DateTime ToDate = DateTime.parse(value); // Convert the input value to DateTime
                                          if (ToDate.isBefore(fromDate)) {
                                            return 'To Date must be after\nFrom Date';
                                          }
                                          return null;
                                        },
                                        onTap: () {
                                          showDatePicker(
                                            context: context,
                                            initialDate: toDate ?? fromDate.add(Duration(days: 6)),
                                            firstDate: fromDate.add(Duration(days: 1)), // Ensure the "To Date" is after "From Date"
                                            lastDate: DateTime(2100),
                                          ).then((date) {
                                            if (date != null) {
                                              setState(() {
                                                toDate = date;
                                              });
                                            }
                                          });
                                        },
                                        controller: TextEditingController(text: toDate.toString().split(' ')[0]),
                                        decoration: InputDecoration(
                                          // filled: true,
                                          // fillColor: Colors.white,
                                          labelText: "To Date",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 200,height: 70,
                                      child: TextFormField(
                                        controller: empName,
                                        onChanged: (value) {
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          empName.value = empName.value.copyWith(
                                            text: capitalizedValue,
                                            selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                          );
                                        },
                                        style: TextStyle(fontSize: 13),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '* Enter Employee Name';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          // filled: true,
                                          // fillColor: Colors.white,
                                          labelText: "Employee Name",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 200,height: 70,
                                      child: TextFormField(
                                        controller: empID,
                                        style: TextStyle(fontSize: 13),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '* Enter Employee ID';
                                          }
                                          return null;
                                        },
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                        ],
                                        decoration: InputDecoration(
                                          // filled: true,
                                          // fillColor: Colors.white,
                                          labelText: "Employee ID",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 200,
                                    height: 35,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black),
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          // Step 3.
                                          value: shiftType,
                                          // Step 4.
                                          items: <String>['Shift Type','General','Morning','Night',]
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
                                              shiftType = newValue!;
                                              shiftTiming.text = shiftTimingsMap[shiftType] ?? '';
                                              dropdownValid1;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 87),
                                    child: SizedBox(
                                      width: 200,
                                      child: TextFormField(
                                        controller: shiftTiming,
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
                                          // filled: true,
                                          // fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!dropdownValid1)
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        '* select Shift Type',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      Wrap(
                        children: [
                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: (){
                              if(_formKey.currentState!.validate()){
                                validateDropdown();
                                if (dropdownValid1) {
                                  print('Selected Shift Type: $shiftType');
                                }// Call validation before submitting
                                if (dropdownValid2) {
                                  print('Selected Shift Timing: $shiftTime');
                                }
                                try{
                                  shiftDataToDatabase();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Success"),
                                        content: Text("Data saved successfully."),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftEntry()));
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
