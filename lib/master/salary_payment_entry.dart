import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:vinayaga_project/sale/dc.dart';

import '../home.dart';
import 'package:http/http.dart' as http;
class SalaryPaymentEntry extends StatefulWidget {
  const SalaryPaymentEntry({Key? key}) : super(key: key);

  @override
  State<SalaryPaymentEntry> createState() => _SalaryPaymentEntryState();
}

class _SalaryPaymentEntryState extends State<SalaryPaymentEntry> {



  final _formKey = GlobalKey<FormState>();

  DateTime entryDate = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now().add(Duration(days: 6));
  late TextEditingController controller;
  TextEditingController toDatecondroller=TextEditingController();
  TextEditingController fromDatecondroller=TextEditingController();
  TextEditingController entryDatecondroller=TextEditingController();

  String toDateFormatted = '';

  void _resetForm() {
    _formKey.currentState!.reset();
  }
  void _cancelForm() {
    print('Form cancelled!');
  }
  void initState() {
    super.initState();
    // fromDate = DateTime.now(); // Initialize selectedDate with a default value
    // controller = TextEditingController(
    //   text: DateFormat('yyyy-MM-dd').format(fromDate),
        toDatecondroller.text =
            DateFormat(
                'yyyy-MM-dd')
                .format(
                fromDate);
  }
  String? dropdownvalue="Position";
  String? salarytype;
  bool dropdownValid = true;

  TextEditingController employeename=TextEditingController();
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  void validateDropdown() {
    setState(() {
      dropdownValid = dropdownvalue != "Position";
    });
  }


  //TextEditingController date=TextEditingController();
  TextEditingController empID=TextEditingController();
  TextEditingController empName=TextEditingController();
  // TextEditingController fromDate=TextEditingController();
  // TextEditingController toDate=TextEditingController();
  TextEditingController workHours=TextEditingController();
  TextEditingController paidSalary=TextEditingController();
  Map<String, dynamic> dataToInsert = {};


  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    final String apiUrl = 'http://localhost:3309/Payment'; // Replace with your server details

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


  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    selectedDate = DateTime.now(); // Initialize selectedDate with a default value
    controller = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(selectedDate),
    );
    return MyScaffold(
        route: "salary_payment_entry",backgroundColor: Colors.white,
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
                                    Icon(Icons.payment),
                                    const Text("Salary Payment Entry", style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25
                                    ),),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 508),
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
                                                                        DateFormat('dd-MM-yyyy').format(selectedDate), // Change the date format here
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
                     width: double.infinity, // Set the width to full page width
                     padding: EdgeInsets.all(8.0),
                     decoration: BoxDecoration(
                       color: Colors.blue.shade50,
                       border: Border.all(color: Colors.grey), // Add a border for the box
                       borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                     ),
                     child:Padding(
                       padding: const EdgeInsets.only(left: 10),
                       child: Wrap(
                           children: [
                             SizedBox(height: 10,),
                             Row(
                               children: [
                                 Text("  Salary Payemnt",style: TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
                               ],
                             ),
                             SizedBox(height: 15,),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       //const Text("Employee ID"),
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
                                             labelText: "Employee ID",
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
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       //const Text("Employee Name"),
                                       SizedBox(
                                         width: 200,height: 70,
                                         child: TextFormField(
                                           controller: empName,
                                           style: TextStyle(fontSize: 13),
                                           validator: (value) {
                                             if (value!.isEmpty) {
                                               return '* Enter Employee Name';
                                             }
                                             return null;
                                           },
                                           onChanged: (value) {
                                             String capitalizedValue = capitalizeFirstLetter(value);
                                             employeename.value = employeename.value.copyWith(
                                               text: capitalizedValue,
                                               selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                             );
                                           },
                                           decoration: InputDecoration(
                                             labelText: "Employee Name",
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
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       // const Text("From Date"),
                                       SizedBox(
                                         width: 200,
                                         height: 70,
                                         child: TextFormField(style: TextStyle(fontSize: 13),
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
                                                   fromDatecondroller.text =
                                                       DateFormat(
                                                           'yyyy-MM-dd')
                                                           .format(
                                                           date);
                                                   //fromDate = date; // Update the selected date
                                                   toDate=fromDate.add(Duration(days: 6));
                                                   //controller.text = DateFormat('yyyy-MM-dd').format(fromDate);
                                                 });
                                               }
                                             });
                                           },
                                           //controller: controller,
                                           controller: TextEditingController(text: fromDate.toString().split(' ')[0]), // Set the initial value of the field to the selected date
                                           decoration: InputDecoration(
                                             labelText: "From Date",
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
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       //const Text("To Date"),
                                       SizedBox(
                                         width: 200,
                                         height: 70,
                                         child: TextFormField(
                                           style: TextStyle(fontSize: 13),
                                           readOnly: true, // Set the field as read-only
                                           validator: (value) {
                                             if (value!.isEmpty) {
                                               return '* Enter To Date';
                                             }
                                             return null;
                                           },
                                           onTap: () {
                                             showDatePicker(
                                               context: context,
                                               initialDate: toDate,
                                               firstDate: DateTime(2000),
                                               lastDate: DateTime(2100),
                                             ).then((date) {
                                               if (date != null) {
                                                 setState(() {
                                                   // toDate = DTimeate(date.year, date.month, date.day);
                                                   //toDate = date;
                                                   toDatecondroller.text =
                                                       DateFormat(
                                                           'yyyy-MM-dd')
                                                           .format(
                                                           date);
                                                   // toDateFormatted = DateFormat('yyyy-MM-dd').format(date).toString();
                                                 });
                                               }
                                             });
                                           },
                                           // controller: TextEditingController(text: toDateFormatted),
                                           controller: TextEditingController(text: toDate.toString().split(' ')[0]), // Set the initial value of the field to the selected date
                                           decoration: InputDecoration(
                                             labelText: "Enter To date",
                                             border: OutlineInputBorder(
                                               borderRadius: BorderRadius.circular(10),
                                             ),
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Wrap(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // const Text("Position"),
                                  SizedBox(
                                    width: 200,
                                    height: 35,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: dropdownvalue,
                                          items: <String>["Position",'Operator', 'Assistant']
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              dropdownvalue = newValue;
                                              validateDropdown(); // Call validation when the dropdown changes
                                            });
                                          },
                                        ),
                                      ),
                                    ),),
                                  if (!dropdownValid)
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        '* select a position',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 50,),
                            Padding(
                              padding:const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //  const Text("Working Hours"),
                                  SizedBox(
                                    width: 200,height: 70,
                                    child: TextFormField(
                                      controller: workHours,
                                      style: TextStyle(fontSize: 13),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '* Enter Working Hours';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters:<TextInputFormatter> [
                                        LengthLimitingTextInputFormatter(10),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                          labelText: "Working Hours",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10,),
                                          )
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 43,),
                            // Wrap(
                            //   children: [],
                            // ),
                            Padding(
                              padding:const EdgeInsets.only(right: 0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //const Text("Paid Salary"),
                                    SizedBox(
                                      width: 200,height: 70,
                                      child: TextFormField(
                                          controller: paidSalary,
                                          style: TextStyle(fontSize: 13),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return '* Enter Paid Salary';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            labelText: "Paid Salary",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                           ]),
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
                            onPressed: (){
                              if(_formKey.currentState!.validate()){}
                              validateDropdown(); // Call validation before submitting
                              if (dropdownValid) {
                                final date1 = fromDate.toIso8601String();
                                final date2 = toDate.toIso8601String();
                                final entry = entryDate.toIso8601String();
                                dataToInsert = {
                                  'entryDate':entryDatecondroller,
                                  'empID': empID.text,
                                  'empName': empName.text,
                                  'position': dropdownvalue,
                                  'fromDate': fromDatecondroller,
                                  'toDate': toDatecondroller.text,
                                  'workHours': workHours.text,
                                  'paidSalary': paidSalary.text,
                                  // Add more columns and values as needed
                                };
                                insertData(dataToInsert);
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>SalaryPaymentEntry()));
                                // Form is valid, continue with your action here
                                // For example, you can print the selected value:
                                print('Selected position: $dropdownvalue');
                              }
                            },child: Text("Submit",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 10,),
                          MaterialButton(
                            color: Colors.blue.shade600,
                            onPressed: _resetForm,child:Text("Reset",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 10,),
                          MaterialButton(
                            color: Colors.red.shade600,
                            onPressed: (){
                              _cancelForm();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>Home()));
                            },child: Text("Cancel",style: TextStyle(color: Colors.white),),)
                        ],
                      ),
                    ),
                  ]),
            ),

          ),
        ) );
  }
}
