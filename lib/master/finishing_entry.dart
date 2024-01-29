import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart'as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';

import '../home.dart';
class FinishingEntry extends StatefulWidget {
  const FinishingEntry({Key? key}) : super(key: key);

  @override
  State<FinishingEntry> createState() => _FinishingEntryState();
}

class _FinishingEntryState extends State<FinishingEntry> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();

  // RegExp nameRegExp = RegExp(r'^[a-zA-Z\,]+(\s[a-zA-Z]+,)?$');
  void _resetForm() {
    _formKey.currentState!.reset();
  }
  void _cancelForm() {
    print('Form cancelled!');
  }
  Map<String, dynamic> dataToInsert = {};


  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    const String apiUrl = 'http://localhost:3309/finishing_entry/'; // Replace with your server details

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsert': dataToInsert}),
      );

      if (response.statusCode == 200) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Finishing Entry"),
              content: Text("saved successfully."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FinishingEntry()));
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to insert data');
        throw Exception('Failed to insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  List<String> machineName = [];
  String? selectedmachine;
  Future<void> getmachine() async {
    try {
      final url = Uri.parse('http://localhost:3309/getmachname/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> machinename = responseData;

        machineName = machinename.map((item) => item['machineName'] as String).toList();

        setState(() {
          // Print itemGroupValues to check if it's populated correctly.
          print('Sizes: $machineName');
        });


      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  //TextEditingController machineName =TextEditingController();
  TextEditingController op1 =TextEditingController();
  TextEditingController op2 =TextEditingController();
  TextEditingController ass1 =TextEditingController();
  TextEditingController ass2 =TextEditingController();
  TextEditingController ass3 =TextEditingController();
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  String? errorMessage;
  @override
  void initState() {
    // TODO: implement initState
    getmachine();
    fetchData();
    filteredData = List<Map<String, dynamic>>.from(data);
    super.initState();
  }
  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/employee_get_report/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          data = itemGroups.cast<Map<String, dynamic>>();

          filteredData = List<Map<String, dynamic>>.from(data);

          filteredData.sort((a, b) {
            DateTime? dateA = DateTime.tryParse(a['date'] ?? '');
            DateTime? dateB = DateTime.tryParse(b['date'] ?? '');
            if (dateA == null || dateB == null) {
              return 0;

            }
            return dateB.compareTo(dateA);
          });
        });

        print('Data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];

  void filterData(String searchText) {
    print("Search Text: $searchText");
    setState(() {
      if (searchText.isEmpty) {
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        filteredData = data.where((item) {
          String supName = item['empName']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();

          return supName.contains(searchTextLowerCase);
        }).toList();
      }
    });
    print("Filtered Data Length: ${filteredData.length}");
  }
  String? opName1="";
  String? opName2="";
  String? assName1="";
  String? assName2="";
  String? assName3="";




  String dropdownvalue = "Shift Type";
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "finishing_entry",backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
                children: [
                  SizedBox(height: 20,),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.edit_note, size:30),
                                        const Padding(
                                          padding: EdgeInsets.only(right:0),
                                          child: Text("Finishing Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),
                                        ),
                                      ]),
                                  Wrap(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        DateFormat('dd-MM-yyyy').format(selectedDate),
                                        style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     showDatePicker(
                                  //       context: context,
                                  //       initialDate: selectedDate,
                                  //       firstDate: DateTime(2000), // Set the range of selectable dates
                                  //       lastDate: DateTime(2100),
                                  //     ).then((date) {
                                  //       if (date != null) {
                                  //         setState(() {
                                  //           selectedDate = date; // Update the selected date
                                  //         });
                                  //       }
                                  //     });
                                  //   },
                                  //   child: Wrap(
                                  //     children: [
                                  //       Icon(
                                  //         Icons.calendar_today,
                                  //         size: 18,
                                  //         color: Colors.black,
                                  //       ),
                                  //       SizedBox(width: 8),
                                  //       Text(
                                  //         DateFormat('dd-MM-yyyy').format(selectedDate), // Format the date here
                                  //         style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.bold),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),


                            ]
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 0.0),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
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
                              Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 200,
                                            height:40,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,

                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButtonFormField<String>(
                                                  hint: const Text("Machine Name"),
                                                  value:selectedmachine, // Use selectedSize to store the selected value
                                                  items: machineName.map((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: const TextStyle(fontSize: 15),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      selectedmachine = newValue; // Update selectedSize when a value is selected
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 50,),
                                    Padding(
                                      padding:const EdgeInsets.only(left: 8,right: 8.0,top: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          SizedBox(
                                            width: 200, height: 38,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(color: Colors.black),
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: dropdownvalue,
                                                  items: <String>['Shift Type','General(9:00AM-6:00PM)','Morning(8:00AM-8:00PM)','Night(8:00PM-8:00AM)',]
                                                      .map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: TextStyle(fontSize: 12),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  // Step 5.
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      dropdownvalue = newValue!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 50,),

                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 200, height: 70,
                                            child:  TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: op1,
                                                onChanged: (query) {
                                                  setState(() {
                                                    errorMessage = null; // Reset error message when user types
                                                  });
                                                  String capitalizedValue = capitalizeFirstLetter(query);
                                                  op1.value = op1.value.copyWith(
                                                    text: capitalizedValue,
                                                    selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                  );

                                                },
                                                style: const TextStyle(fontSize: 13),
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  labelText: "Operator Name1",
                                                  labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              suggestionsCallback: (pattern) async {
                                                if (pattern.isEmpty) {
                                                  return [];
                                                }
                                                List<String> suggestions = data
                                                    .where((item) =>
                                                    (item['empName']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map<String>((item) =>
                                                '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
                                                    .toSet() // Remove duplicates using a Set
                                                    .toList();
                                                return suggestions;
                                              },
                                              itemBuilder: (context, suggestion) {
                                                return ListTile(
                                                  title: Text(suggestion),
                                                );
                                              },
                                              onSuggestionSelected: (suggestion) {
                                                // Extract the empName from the suggestion
                                                String selectedEmpName = suggestion.split(' ')[0];
                                                // Extract the empID from the suggestion
                                                String selectedEmpID = suggestion.split('(')[1].split(')')[0];
                                                if (selectedEmpName == opName2) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Operator 2";
                                                  });
                                                }
                                                else if (selectedEmpName == ass1.text) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 1";
                                                  });
                                                } else if (selectedEmpName == ass2.text) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 2";
                                                  });
                                                }else if (selectedEmpName == ass3.text) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 3";
                                                  });
                                                }else{

                                                  setState(() {
                                                    opName1 = selectedEmpName;
                                                    op1.text = selectedEmpName;
                                                  });}
                                                print('Selected Customer: $opName1, ID: $selectedEmpID');
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 50,),

                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          SizedBox(
                                            width: 200, height: 70,
                                            child: TypeAheadFormField<String>(
                                                textFieldConfiguration: TextFieldConfiguration(
                                                  controller: op2,
                                                  onChanged: (query) {
                                                    setState(() {
                                                      errorMessage = null; // Reset error message when user types
                                                    });
                                                    String capitalizedValue = capitalizeFirstLetter(query);
                                                    op2.value = op2.value.copyWith(
                                                      text: capitalizedValue,
                                                      selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                    );


                                                  },
                                                  style: const TextStyle(fontSize: 13),
                                                  decoration: InputDecoration(
                                                    fillColor: Colors.white,
                                                    filled: true,
                                                    labelText: "Operator Name2",
                                                    labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                                suggestionsCallback: (pattern) async {
                                                  if (pattern.isEmpty) {
                                                    return [];
                                                  }
                                                  List<String> suggestions = data
                                                      .where((item) =>
                                                      (item['empName']?.toString()?.toLowerCase() ?? '')
                                                          .startsWith(pattern.toLowerCase()))
                                                      .map<String>((item) =>
                                                  '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
                                                      .toSet() // Remove duplicates using a Set
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

                                                  if (selectedEmpName == opName1) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the name in Operator 1";
                                                    });
                                                  }
                                                  else if (selectedEmpName == ass1.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the name in Assistant 1";
                                                    });
                                                  } else if (selectedEmpName == ass2.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the name in Assistant 2";
                                                    });
                                                  }else if (selectedEmpName == ass3.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the name in Assistant 3";
                                                    });
                                                  }else {
                                                    setState(() {
                                                      errorMessage = null;
                                                      opName2 = selectedEmpName;
                                                      op2.text = selectedEmpName;
                                                    });
                                                    print('Selected Customer: $opName2, ID: $selectedEmpID');
                                                  }}
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                              Wrap( crossAxisAlignment: WrapCrossAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 200, height: 70,
                                          child: TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: ass1,
                                                onChanged: (query) {
                                                  setState(() {
                                                    errorMessage = null; // Reset error message when user types
                                                  });
                                                  String capitalizedValue = capitalizeFirstLetter(query);
                                                  ass1.value = ass1.value.copyWith(
                                                    text: capitalizedValue,
                                                    selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                  );
                                                },
                                                style: const TextStyle(fontSize: 13),
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  labelText: "Assistant 1",
                                                  labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              suggestionsCallback: (pattern) async {
                                                if (pattern.isEmpty) {
                                                  return [];
                                                }
                                                List<String> suggestions = data
                                                    .where((item) =>
                                                    (item['empName']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map<String>((item) =>
                                                '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
                                                    .toSet() // Remove duplicates using a Set
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
                                                if (selectedEmpName == opName1) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Operator 1";
                                                  });
                                                }else if (selectedEmpName == opName2) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Operator 2";
                                                  });}
                                                else if (selectedEmpName == ass2.text) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 1";
                                                  });
                                                } else if (selectedEmpName == ass3.text) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 3";
                                                  });
                                                } else {
                                                  setState(() {
                                                    errorMessage = null;
                                                    assName1 = selectedEmpName;
                                                    ass1.text = selectedEmpName;
                                                  });
                                                  print('Selected Customer: $assName1, ID: $selectedEmpID');
                                                }}
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 50,),

                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 200, height: 70,
                                          child: TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: ass2,
                                                onChanged: (query) {
                                                  setState(() {
                                                    errorMessage = null; // Reset error message when user types
                                                  });
                                                  String capitalizedValue = capitalizeFirstLetter(query);
                                                  ass2.value = ass2.value.copyWith(
                                                    text: capitalizedValue,
                                                    selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                  );
                                                },
                                                style: const TextStyle(fontSize: 13),
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  labelText: "Assistant 2",
                                                  labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              suggestionsCallback: (pattern) async {
                                                if (pattern.isEmpty) {
                                                  return [];
                                                }
                                                List<String> suggestions = data
                                                    .where((item) =>
                                                    (item['empName']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map<String>((item) =>
                                                '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
                                                    .toSet() // Remove duplicates using a Set
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
                                                if (selectedEmpName == opName1) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Operator 1";
                                                  });}
                                                else if(selectedEmpName == opName2){
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Operator 2";
                                                  });}else if(selectedEmpName == ass1.text){
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 1";
                                                  });}
                                                else if(selectedEmpName == ass3.text){
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 3";
                                                  });


                                                } else {
                                                  setState(() {
                                                    errorMessage = null;
                                                    assName2 = selectedEmpName;
                                                    ass2.text = selectedEmpName;
                                                  });
                                                  print('Selected Customer: $assName2, ID: $selectedEmpID');
                                                }}
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 50,),

                                  Padding(padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 200, height: 70,
                                          child: TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: ass3,
                                                onChanged: (query) {
                                                  setState(() {
                                                    errorMessage = null; // Reset error message when user types
                                                  });
                                                  String capitalizedValue = capitalizeFirstLetter(query);
                                                  ass3.value = ass3.value.copyWith(
                                                    text: capitalizedValue,
                                                    selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                  );
                                                },
                                                style: const TextStyle(fontSize: 13),
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  labelText: "Assistant 3",
                                                  labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              suggestionsCallback: (pattern) async {
                                                if (pattern.isEmpty) {
                                                  return [];
                                                }
                                                List<String> suggestions = data
                                                    .where((item) =>
                                                    (item['empName']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map<String>((item) =>
                                                '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
                                                    .toSet() // Remove duplicates using a Set
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
                                                if (selectedEmpName == opName1) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Operator 1";
                                                  });}
                                                else if(selectedEmpName == opName1){
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Operator 2";
                                                  });}else if(selectedEmpName == ass1.text){
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 1";
                                                  });}
                                                else if(selectedEmpName == ass2.text){
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 2";
                                                  });


                                                } else {
                                                  setState(() {
                                                    errorMessage = null;
                                                    assName3 = selectedEmpName;
                                                    ass3.text = selectedEmpName;
                                                  });
                                                  print('Selected Customer: $assName3, ID: $selectedEmpID');
                                                }}
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 50,),

                                  Padding(padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 200, height: 70,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ]
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child:
                    Wrap(
                      children: [
                        MaterialButton(
                          color: Colors.green.shade600,
                          onPressed: () async {
                            if(_formKey.currentState!.validate()){
                              if(selectedmachine == null){
                                setState(() {
                                  errorMessage = '* Select a Machine Name';
                                });

                              }
                              else if(dropdownvalue=="Shift Type"){
                                setState(() {
                                  errorMessage = '* Select a Shift Type';
                                });
                              }
                              else if(op1.text.isEmpty){
                                setState(() {
                                  errorMessage = '* Enter a Operator Name 1';
                                });
                              }
                              else if(op2.text.isEmpty){
                                setState(() {
                                  errorMessage = '* Enter a Operator Name 2';
                                });
                              }
                              else if(ass1.text.isEmpty){
                                setState(() {
                                  errorMessage = '* Enter a Assistant Name 1';
                                });
                              }
                              else if(ass2.text.isEmpty){
                                setState(() {
                                  errorMessage = '* Enter a Assistant Name 2';
                                });
                              }
                              else if(ass3.text.isEmpty){
                                setState(() {
                                  errorMessage = '* Enter a Assistant Name 3';
                                });
                              }

                              else {
                                dataToInsert = {
                                  'date': DateTime.now().toString(),
                                  "machName": selectedmachine.toString(),
                                  "opOneName": op1.text,
                                  "opTwoName": op2.text,
                                  "assOne": ass1.text,
                                  "assTwo": ass2.text,
                                  "assThree": ass3.text,
                                  "shiftType": dropdownvalue.toString(),
                                };
                                await insertData(dataToInsert);

                              }
                            }
                          },child: Text("SAVE",style: TextStyle(color: Colors.white),),),
                        SizedBox(width: 10,),
                        MaterialButton(
                          color: Colors.blue.shade600,
                          onPressed: (){
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
                                            MaterialPageRoute(builder: (context) =>const FinishingEntry()));// Close the alert box
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
                          },child:Text("RESET",style: TextStyle(color: Colors.white),),),
                        SizedBox(width: 10,),
                        MaterialButton(
                          color: Colors.red.shade600,
                          onPressed: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmation'),
                                  content: const Text('Do you want to Cancel?'),
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
                          },child: Text("CANCEL",style: TextStyle(color: Colors.white),),)
                      ],
                    ),
                  ),
                ]),
          ),
        ) );
  }
}
