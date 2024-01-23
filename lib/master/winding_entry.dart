// import 'dart:convert';
// import 'dart:js_interop';
// import 'package:flutter/services.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:http/http.dart'as http;
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:vinayaga_project/main.dart';
//
// import '../home.dart';
// class WindingEntry extends StatefulWidget {
//   const WindingEntry({Key? key}) : super(key: key);
//
//   @override
//   State<WindingEntry> createState() => _WindingEntryState();
// }
//
// class _WindingEntryState extends State<WindingEntry> {
//   final _formKey = GlobalKey<FormState>();
//   DateTime selectedDate = DateTime.now();
//   // RegExp nameRegExp = RegExp(r'^[a-zA-Z\,]+(\s[a-zA-Z]+,)?$');
//   final FocusNode op1FocusNode = FocusNode();
//
//   Map<String, dynamic> dataToInsert = {};
//
//   String capitalizeFirstLetter(String text) {
//     if (text.isEmpty) return text;
//     return text.substring(0, 1).toUpperCase() + text.substring(1);
//   }
//
//   Future<void> insertData(Map<String, dynamic> dataToInsert) async {
//     const String apiUrl = 'http://localhost:3309/winding_entry/'; // Replace with your server details
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode({'dataToInsert': dataToInsert}),
//       );
//
//       if (response.statusCode == 200) {
//         showDialog(
//           barrierDismissible: false,
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("Winding Entry"),
//               content: Text("saved successfully."),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=>WindingEntry()));                  },
//                   child: Text("OK"),
//                 ),
//               ],
//             );
//           },
//         );
//       } else {
//         print('Failed to insert data');
//         throw Exception('Failed to insert data');
//       }
//     } catch (e) {
//       print('Error: $e');
//       throw Exception('Error: $e');
//     }
//   }
//   List<String> machineName = [];
//   String? selectedmachine;
//   Future<void> getmachine() async {
//     try {
//       final url = Uri.parse('http://localhost:3309/getmachname/');
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         final List<dynamic> machinename = responseData;
//
//         machineName = machinename.map((item) => item['machineName'] as String).toList();
//
//         setState(() {
//           // Print itemGroupValues to check if it's populated correctly.
//           print('Sizes: $machineName');
//         });
//       } else {
//         print('Error: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error: $error');
//     }
//   }
//   TextEditingController op1 =TextEditingController();
//   TextEditingController op2 =TextEditingController();
//   TextEditingController ass1 =TextEditingController();
//   TextEditingController ass2 =TextEditingController();
//   TextEditingController ass3 =TextEditingController();
//   String? errorMessage;
//   String dropdownvalue = "Shift Type";
//   String validname1="";
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getmachine();
//     fetchData();
//     filteredData = List<Map<String, dynamic>>.from(data);
//   }
//   Future<void> fetchData() async {
//     try {
//       final url = Uri.parse('http://localhost:3309/employee_get_report/');
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         final List<dynamic> itemGroups = responseData;
//
//         setState(() {
//           data = itemGroups.cast<Map<String, dynamic>>();
//
//           filteredData = List<Map<String, dynamic>>.from(data);
//
//           filteredData.sort((a, b) {
//             DateTime? dateA = DateTime.tryParse(a['date'] ?? '');
//             DateTime? dateB = DateTime.tryParse(b['date'] ?? '');
//             if (dateA == null || dateB == null) {
//               return 0;
//
//             }
//             return dateB.compareTo(dateA);
//           });
//         });
//
//         print('Data: $data');
//       } else {
//         print('Error: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error: $error');
//     }
//   }
//
//   List<Map<String, dynamic>> filteredData = [];
//   List<Map<String, dynamic>> data = [];
//
//   void filterData(String searchText) {
//     print("Search Text: $searchText");
//     setState(() {
//       if (searchText.isEmpty) {
//         filteredData = List<Map<String, dynamic>>.from(data);
//       } else {
//         filteredData = data.where((item) {
//           String supName = item['empName']?.toString()?.toLowerCase() ?? '';
//           String searchTextLowerCase = searchText.toLowerCase();
//
//           return supName.contains(searchTextLowerCase);
//         }).toList();
//       }
//     });
//     print("Filtered Data Length: ${filteredData.length}");
//   }
//   String? opName1="";
//   String? opName2="";
//   String? assName1="";
//   String? assName2="";
//   String? assName3="";
//
//   @override
//   Widget build(BuildContext context) {
//     return MyScaffold(
//         route: "winding_entry",
//         body: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//                 children: [
//                   SizedBox(height: 20,),
//                   SizedBox(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(16.0),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: [
//                                         const Icon(Icons.edit_note, size:30),
//                                         const Padding(
//                                           padding: EdgeInsets.only(right:0),
//                                           child: Text("Winding Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),
//                                         ),
//                                       ]),
//                                   Wrap(
//                                     children: [
//                                       Icon(
//                                         Icons.calendar_today,
//                                         size: 18,
//                                         color: Colors.black,
//                                       ),
//                                       SizedBox(width: 8),
//                                       Text(
//                                         DateFormat('dd-MM-yyyy').format(selectedDate),
//                                         style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ]
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 0.0),
//                       child: Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(16.0),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.shade50,
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     errorMessage ?? '',
//                                     style: TextStyle(color: Colors.red),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 30,),
//                               Wrap(
//                                   crossAxisAlignment: WrapCrossAlignment.start,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(10.0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               SizedBox(
//                                                 width: 200,
//                                                 height:40,
//                                                 child: Container(
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.white,
//                                                     border: Border.all(color: Colors.grey),
//                                                     borderRadius: BorderRadius.circular(5),
//                                                   ),
//                                                   child: DropdownButtonHideUnderline(
//                                                     child: DropdownButtonFormField<String>(
//                                                       hint: const Text("Machine Name"),
//                                                       value:selectedmachine, // Use selectedSize to store the selected value
//                                                       items: machineName.map((String value) {
//                                                         return DropdownMenuItem<String>(
//                                                           value: value,
//                                                           child: Text(
//                                                             value,
//                                                             style: const TextStyle(fontSize: 15),
//                                                           ),
//                                                         );
//                                                       }).toList(),
//                                                       onChanged: (String? newValue) {
//                                                         setState(() {
//                                                           selectedmachine = newValue; // Update selectedSize when a value is selected
//                                                         });
//                                                       },
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(width: 50,),
//                                     Padding(
//                                       padding:const EdgeInsets.only(left:8,right:8,top:10),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//
//                                           SizedBox(
//                                             width: 200, height:40 ,
//                                             child: Container(
//                                               // color: Colors.white,
//                                               padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
//                                               decoration: BoxDecoration(
//                                                   color: Colors.white,
//                                                   border: Border.all(color: Colors.black),
//                                                   borderRadius: BorderRadius.circular(5)
//
//                                               ),
//                                               child: DropdownButtonHideUnderline(
//                                                 child: DropdownButton<String>(
//                                                   value: dropdownvalue,
//                                                   items: <String>['Shift Type','General(9:00AM-6:00PM)','Morning(8:00AM-8:00PM)','Night(8:00PM-8:00AM)',]
//                                                       .map<DropdownMenuItem<String>>((String value) {
//                                                     return DropdownMenuItem<String>(
//                                                       value: value,
//                                                       child: Text(
//                                                         value,
//                                                         style: TextStyle(fontSize: 12),
//                                                       ),
//                                                     );
//                                                   }).toList(),
//                                                   // Step 5.
//                                                   onChanged: (String? newValue) {
//                                                     setState(() {
//                                                       dropdownvalue = newValue!;
//                                                     });
//                                                   },
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(width: 50,),
//
//                                     Padding(
//                                       padding: const EdgeInsets.all(10.0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//
//                                           SizedBox(
//                                             width: 200, height: 70,
//                                             child:  TypeAheadFormField<String>(
//
//                                               textFieldConfiguration: TextFieldConfiguration(
//                                                 controller: op1,
//                                                   focusNode: op1FocusNode, // Assign the FocusNode
//
//                                                   enabled: true,
//
//                                                 onChanged: (query) {
//                                                   setState(() {
//                                                     errorMessage = null; // Reset error message when user types
//                                                   });
//
//                                                   String capitalizedValue = capitalizeFirstLetter(query);
//                                                   op1.value = op1.value.copyWith(
//                                                     text: capitalizedValue,
//                                                     selection: TextSelection.collapsed(offset: capitalizedValue.length),
//                                                   );
//
//                                                 },
//                                                 inputFormatters: [
//                                                   FilteringTextInputFormatter.deny(RegExp(r'\d')), // Deny numeric digits
//                                                 //  FilteringTextInputFormatter.deny(RegExp(r'[\d!@#$%^&*(),.?":{}|<>]')), // Deny numeric digits and special characters
//
//                                                 ],
//                                                 style: const TextStyle(fontSize: 13),
//                                                 decoration: InputDecoration(
//                                                   fillColor: Colors.white,
//                                                   filled: true,
//                                                   labelText: "Operator Name1",
//                                                   labelStyle: TextStyle(fontSize: 13, color: Colors.black),
//                                                   border: OutlineInputBorder(
//                                                     borderRadius: BorderRadius.circular(10),
//                                                   ),
//
//                                                 ),
//                                               ),
//
//                                               suggestionsCallback: (pattern) async {
//                                                 if (pattern.isEmpty) {
//                                                   return [];
//                                                 }
//                                                 List<String> suggestions = data
//                                                     .where((item) =>
//                                                     (item['empName']?.toString()?.toLowerCase() ?? '')
//                                                         .startsWith(pattern.toLowerCase()))
//                                                     .map<String>((item) =>
//                                                 '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
//                                                     .toSet() // Remove duplicates using a Set
//                                                     .toList();
//                                                 return suggestions;
//                                               },
//                                               itemBuilder: (context, suggestion) {
//                                                 return ListTile(
//                                                   title: Text(suggestion),
//                                                 );
//                                               },
//                                               onSuggestionSelected: (suggestion) {
//                                                 // Extract the empName from the suggestion
//                                                 String selectedEmpName = suggestion.split(' ')[0];
//                                                 // Extract the empID from the suggestion
//                                                 String selectedEmpID = suggestion.split('(')[1].split(')')[0];
//                                                 bool isValidName = data.any((item) =>
//                                                 (item['empName']?.toString()?.toLowerCase() ?? '') ==
//                                                     selectedEmpName.toLowerCase());
//                                                 validname1=isValidName.toString();
//                                                 if (!isValidName) {
//                                                   setState(() {
//                                                     errorMessage = "This name is not an Employee";
//                                                   });
//                                                 }
//                                                else if (selectedEmpName == opName2) {
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Operator 2";
//                                                   });
//                                                 }
//                                                 else if (selectedEmpName == ass1.text) {
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Assistant 1";
//                                                   });
//                                                 } else if (selectedEmpName == ass2.text) {
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Assistant 2";
//                                                   });
//                                                 }else if (selectedEmpName == ass3.text) {
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Assistant 3";
//                                                   });
//                                                 }else{
//
//                                                   setState(() {
//                                                     opName1 = selectedEmpName;
//                                                     op1.text = selectedEmpName;
//                                                    });
//                                                   Future.delayed(Duration(milliseconds: 100), () {
//                                                     setState(() {
//                                                       // Disable the text field after a valid name is selected
//                                                       op1FocusNode.unfocus(); // Remove focus
//                                                       op1FocusNode.canRequestFocus = false; // Disable further focus
//                                                     });
//                                                   });
//                                                 }
//
//                                                 print('Selected Customer: $opName1, ID: $selectedEmpID');
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(width: 50,),
//
//                                     Padding(
//                                       padding: const EdgeInsets.all(10.0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//
//                                           SizedBox(
//                                             width: 200, height: 70,
//                                             child: TypeAheadFormField<String>(
//                                                 textFieldConfiguration: TextFieldConfiguration(
//                                                   controller: op2,
//                                                   onChanged: (query) {
//                                                     setState(() {
//                                                       errorMessage = null; // Reset error message when user types
//                                                     });
//                                                     String capitalizedValue = capitalizeFirstLetter(query);
//                                                     op2.value = op2.value.copyWith(
//                                                       text: capitalizedValue,
//                                                       selection: TextSelection.collapsed(offset: capitalizedValue.length),
//                                                     );
//
//
//                                                   },
//                                                   style: const TextStyle(fontSize: 13),
//                                                   decoration: InputDecoration(
//                                                     fillColor: Colors.white,
//                                                     filled: true,
//                                                     labelText: "Operator Name2",
//                                                     labelStyle: TextStyle(fontSize: 13, color: Colors.black),
//                                                     border: OutlineInputBorder(
//                                                       borderRadius: BorderRadius.circular(10),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 suggestionsCallback: (pattern) async {
//                                                   if (pattern.isEmpty) {
//                                                     return [];
//                                                   }
//                                                   List<String> suggestions = data
//                                                       .where((item) =>
//                                                       (item['empName']?.toString()?.toLowerCase() ?? '')
//                                                           .startsWith(pattern.toLowerCase()))
//                                                       .map<String>((item) =>
//                                                   '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
//                                                       .toSet() // Remove duplicates using a Set
//                                                       .toList();
//                                                   return suggestions;
//                                                 },
//                                                 itemBuilder: (context, suggestion) {
//                                                   return ListTile(
//                                                     title: Text(suggestion),
//                                                   );
//                                                 },
//                                                 onSuggestionSelected: (suggestion) {
//                                                   String selectedEmpName = suggestion.split(' ')[0];
//                                                   String selectedEmpID = suggestion.split('(')[1].split(')')[0];
//
//                                                   if (selectedEmpName == opName1) {
//                                                     setState(() {
//                                                       errorMessage = "Already Assigned the name in Operator 1";
//                                                     });
//                                                   }
//                                                   else if (selectedEmpName == ass1.text) {
//                                                     setState(() {
//                                                       errorMessage = "Already Assigned the name in Assistant 1";
//                                                     });
//                                                   } else if (selectedEmpName == ass2.text) {
//                                                     setState(() {
//                                                       errorMessage = "Already Assigned the name in Assistant 2";
//                                                     });
//                                                   }else if (selectedEmpName == ass3.text) {
//                                                     setState(() {
//                                                       errorMessage = "Already Assigned the name in Assistant 3";
//                                                     });
//                                                   }else {
//                                                     setState(() {
//                                                       errorMessage = null;
//                                                       opName2 = selectedEmpName;
//                                                       op2.text = selectedEmpName;
//                                                     });
//                                                     print('Selected Customer: $opName2, ID: $selectedEmpID');
//                                                   }}
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ]),
//                               Wrap(
//                                 //     alignment: WrapAlignment.spaceEvenly,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           width: 200, height: 70,
//                                           child: TypeAheadFormField<String>(
//                                               textFieldConfiguration: TextFieldConfiguration(
//                                                 controller: ass1,
//                                                 onChanged: (query) {
//                                                   setState(() {
//                                                     errorMessage = null; // Reset error message when user types
//                                                   });
//                                                   String capitalizedValue = capitalizeFirstLetter(query);
//                                                   ass1.value = ass1.value.copyWith(
//                                                     text: capitalizedValue,
//                                                     selection: TextSelection.collapsed(offset: capitalizedValue.length),
//                                                   );
//                                                 },
//                                                 style: const TextStyle(fontSize: 13),
//                                                 decoration: InputDecoration(
//                                                   fillColor: Colors.white,
//                                                   filled: true,
//                                                   labelText: "Assistant 1",
//                                                   labelStyle: TextStyle(fontSize: 13, color: Colors.black),
//                                                   border: OutlineInputBorder(
//                                                     borderRadius: BorderRadius.circular(10),
//                                                   ),
//                                                 ),
//                                               ),
//                                               suggestionsCallback: (pattern) async {
//                                                 if (pattern.isEmpty) {
//                                                   return [];
//                                                 }
//                                                 List<String> suggestions = data
//                                                     .where((item) =>
//                                                     (item['empName']?.toString()?.toLowerCase() ?? '')
//                                                         .startsWith(pattern.toLowerCase()))
//                                                     .map<String>((item) =>
//                                                 '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
//                                                     .toSet() // Remove duplicates using a Set
//                                                     .toList();
//                                                 return suggestions;
//                                               },
//                                               itemBuilder: (context, suggestion) {
//                                                 return ListTile(
//                                                   title: Text(suggestion),
//                                                 );
//                                               },
//                                               onSuggestionSelected: (suggestion) {
//                                                 String selectedEmpName = suggestion.split(' ')[0];
//                                                 String selectedEmpID = suggestion.split('(')[1].split(')')[0];
//                                                 if (selectedEmpName == opName1) {
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Operator 1";
//                                                   });
//                                                 }else if (selectedEmpName == opName2) {
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Operator 2";
//                                                   });}
//                                                 else if (selectedEmpName == ass2.text) {
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Assistant 1";
//                                                   });
//                                                 } else if (selectedEmpName == ass3.text) {
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Assistant 3";
//                                                   });
//                                                 } else {
//                                                   setState(() {
//                                                     errorMessage = null;
//                                                     assName1 = selectedEmpName;
//                                                     ass1.text = selectedEmpName;
//                                                   });
//                                                   print('Selected Customer: $assName1, ID: $selectedEmpID');
//                                                 }}
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(width: 50,),
//
//                                   Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           width: 200, height: 70,
//                                           child: TypeAheadFormField<String>(
//                                               textFieldConfiguration: TextFieldConfiguration(
//                                                 controller: ass2,
//                                                 onChanged: (query) {
//                                                   setState(() {
//                                                     errorMessage = null; // Reset error message when user types
//                                                   });
//                                                   String capitalizedValue = capitalizeFirstLetter(query);
//                                                   ass2.value = ass2.value.copyWith(
//                                                     text: capitalizedValue,
//                                                     selection: TextSelection.collapsed(offset: capitalizedValue.length),
//                                                   );
//                                                 },
//                                                 style: const TextStyle(fontSize: 13),
//                                                 decoration: InputDecoration(
//                                                   fillColor: Colors.white,
//                                                   filled: true,
//                                                   labelText: "Assistant 2",
//                                                   labelStyle: TextStyle(fontSize: 13, color: Colors.black),
//                                                   border: OutlineInputBorder(
//                                                     borderRadius: BorderRadius.circular(10),
//                                                   ),
//                                                 ),
//                                               ),
//                                               suggestionsCallback: (pattern) async {
//                                                 if (pattern.isEmpty) {
//                                                   return [];
//                                                 }
//                                                 List<String> suggestions = data
//                                                     .where((item) =>
//                                                     (item['empName']?.toString()?.toLowerCase() ?? '')
//                                                         .startsWith(pattern.toLowerCase()))
//                                                     .map<String>((item) =>
//                                                 '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
//                                                     .toSet() // Remove duplicates using a Set
//                                                     .toList();
//                                                 return suggestions;
//                                               },
//                                               itemBuilder: (context, suggestion) {
//                                                 return ListTile(
//                                                   title: Text(suggestion),
//                                                 );
//                                               },
//                                               onSuggestionSelected: (suggestion) {
//                                                 String selectedEmpName = suggestion.split(' ')[0];
//                                                 String selectedEmpID = suggestion.split('(')[1].split(')')[0];
//                                                 if (selectedEmpName == opName1) {
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Operator 1";
//                                                   });}
//                                                 else if(selectedEmpName == opName2){
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Operator 2";
//                                                   });}else if(selectedEmpName == ass1.text){
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Assistant 1";
//                                                   });}
//                                                 else if(selectedEmpName == ass3.text){
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Assistant 3";
//                                                   });
//
//
//                                                 } else {
//                                                   setState(() {
//                                                     errorMessage = null;
//                                                     assName2 = selectedEmpName;
//                                                     ass2.text = selectedEmpName;
//                                                   });
//                                                   print('Selected Customer: $assName2, ID: $selectedEmpID');
//                                                 }}
//                                           ),
//                                         ),
//
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(width: 50,),
//
//                                   Padding(padding: const EdgeInsets.all(10.0),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           width: 200, height: 70,
//                                           child: TypeAheadFormField<String>(
//                                               textFieldConfiguration: TextFieldConfiguration(
//                                                 controller: ass3,
//                                                 onChanged: (query) {
//                                                   setState(() {
//                                                     errorMessage = null; // Reset error message when user types
//                                                   });
//                                                   String capitalizedValue = capitalizeFirstLetter(query);
//                                                   ass3.value = ass3.value.copyWith(
//                                                     text: capitalizedValue,
//                                                     selection: TextSelection.collapsed(offset: capitalizedValue.length),
//                                                   );
//                                                 },
//                                                 style: const TextStyle(fontSize: 13),
//                                                 decoration: InputDecoration(
//                                                   fillColor: Colors.white,
//                                                   filled: true,
//                                                   labelText: "Assistant 3",
//                                                   labelStyle: TextStyle(fontSize: 13, color: Colors.black),
//                                                   border: OutlineInputBorder(
//                                                     borderRadius: BorderRadius.circular(10),
//                                                   ),
//                                                 ),
//                                               ),
//                                               suggestionsCallback: (pattern) async {
//                                                 if (pattern.isEmpty) {
//                                                   return [];
//                                                 }
//                                                 List<String> suggestions = data
//                                                     .where((item) =>
//                                                     (item['empName']?.toString()?.toLowerCase() ?? '')
//                                                         .startsWith(pattern.toLowerCase()))
//                                                     .map<String>((item) =>
//                                                 '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
//                                                     .toSet() // Remove duplicates using a Set
//                                                     .toList();
//                                                 return suggestions;
//                                               },
//                                               itemBuilder: (context, suggestion) {
//                                                 return ListTile(
//                                                   title: Text(suggestion),
//                                                 );
//                                               },
//                                               onSuggestionSelected: (suggestion) {
//                                                 String selectedEmpName = suggestion.split(' ')[0];
//                                                 String selectedEmpID = suggestion.split('(')[1].split(')')[0];
//                                                 if (selectedEmpName == opName1) {
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Operator 1";
//                                                   });}
//                                                 else if(selectedEmpName == opName1){
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Operator 2";
//                                                   });}else if(selectedEmpName == ass1.text){
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Assistant 1";
//                                                   });}
//                                                 else if(selectedEmpName == ass2.text){
//                                                   setState(() {
//                                                     errorMessage = "Already Assigned the name in Assistant 2";
//                                                   });
//
//
//                                                 } else {
//                                                   setState(() {
//                                                     errorMessage = null;
//                                                     assName3 = selectedEmpName;
//                                                     ass3.text = selectedEmpName;
//                                                   });
//                                                   print('Selected Customer: $assName3, ID: $selectedEmpID');
//                                                 }}
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(width: 50,),
//
//                                   Padding(padding: const EdgeInsets.all(10.0),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           width: 200, height: 70,
//
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               // Wrap( crossAxisAlignment: WrapCrossAlignment.start,
//                               //   children: [
//                               //
//                               //   ],
//                               // ),
//
//
//                             ]
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(40.0),
//                     child:
//                     Wrap(
//                       children: [
//                         MaterialButton(
//                           color: Colors.green.shade600,
//                           onPressed: (){
//                             if(_formKey.currentState!.validate()){
//                               if(selectedmachine==null){
//                                 setState(() {
//                                   errorMessage = '* Select a Machine Name';
//                                 });
//                               }
//                               else if(dropdownvalue=="Shift Type"){
//                                 setState(() {
//                                   errorMessage = '* Select a Shift Type';
//                                 });
//                               }
//                               else if(op1.text.isEmpty){
//                                 setState(() {
//                                   errorMessage = '* Enter the Operator Name 1';
//                                 });
//                               }
//                               else if(validname1.isEmpty){
//                                 setState(() {
//                                   errorMessage = '* ${op1.text} is not a Employee Name';
//                                 });
//                               }
//                               else if(op2.text.isEmpty){
//                                 setState(() {
//                                   errorMessage = '* Enter a Operator Name 2';
//                                 });
//                               }
//                               else if(ass1.text.isEmpty){
//                                 setState(() {
//                                   errorMessage = '* Enter a Assistant Name 1';
//                                 });
//                               }
//                               else if(ass2.text.isEmpty){
//                                 setState(() {
//                                   errorMessage = '* Enter a Assistant Name 2';
//                                 });
//                               }
//                               else if(ass3.text.isEmpty){
//                                 setState(() {
//                                   errorMessage = '* Enter a Assistant Name 3';
//                                 });
//                               }
//                               else {
//                                 dataToInsert = {
//                                   'date': DateTime.now().toString(),
//                                   "machName": selectedmachine.toString(),
//                                   "opOneName": op1.text,
//                                   "opTwoName": op2.text,
//                                   "assOne": ass1.text,
//                                   "assTwo": ass2.text,
//                                   "assThree": ass3.text,
//                                   "shiftType": dropdownvalue.toString(),
//                                 };
//                                 insertData(dataToInsert);
//
//
//                               }
//
//                             }
//                           },child: Text("SAVE",style: TextStyle(color: Colors.white),),),
//                         SizedBox(width: 10,),
//                         MaterialButton(
//                           color: Colors.blue.shade600,
//                           onPressed: (){
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: const Text('Confirmation'),
//                                   content: const Text('Do you want to Reset?'),
//                                   actions: <Widget>[
//
//                                     TextButton(
//                                       child: const Text('Yes'),
//                                       onPressed: () {
//                                         Navigator.push(context,
//                                             MaterialPageRoute(builder: (context) =>const WindingEntry()));// Close the alert box
//                                       },
//                                     ),
//                                     TextButton(
//                                       child: const Text('No'),
//                                       onPressed: () {
//                                         Navigator.of(context).pop(); // Close the alert box
//                                       },
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );                          },child:Text("RESET",style: TextStyle(color: Colors.white),),),
//                         SizedBox(width: 10,),
//                         MaterialButton(
//                           color: Colors.red.shade600,
//                           onPressed: (){
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: const Text('Confirmation'),
//                                   content: const Text('Do you want to Cancel?'),
//                                   actions: <Widget>[
//
//                                     TextButton(
//                                       child: const Text('Yes'),
//                                       onPressed: () {
//                                         Navigator.push(context,
//                                             MaterialPageRoute(builder: (context) =>const Home()));// Close the alert box
//                                       },
//                                     ),
//                                     TextButton(
//                                       child: const Text('No'),
//                                       onPressed: () {
//                                         Navigator.of(context).pop(); // Close the alert box
//                                       },
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           },child: Text("CANCEL",style: TextStyle(color: Colors.white),),)
//                       ],
//                     ),
//                   ),
//
//                 ]),
//
//           ),
//         ) );
//   }
// }
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart'as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';

import '../home.dart';
class WindingEntry extends StatefulWidget {
  const WindingEntry({Key? key}) : super(key: key);

  @override
  State<WindingEntry> createState() => _WindingEntryState();
}
List<String> selectedOptions = [];

class _WindingEntryState extends State<WindingEntry> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();

  // RegExp nameRegExp = RegExp(r'^[a-zA-Z\,]+(\s[a-zA-Z]+,)?$');
  final FocusNode op1FocusNode = FocusNode();

  Map<String, dynamic> dataToInsert = {};

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/winding_entry_get_report'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(":$data");
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    const String apiUrl = 'http://localhost:3309/winding_entry/'; // Replace with your server details

    try {
      String machineName = dataToInsert['machName'];
      String ShiftType = dataToInsert['shiftType'];
      String OperatorName1 = dataToInsert['opOneName'];
      String optwoName =dataToInsert['optwoName'];
      String assOne =dataToInsert['assOne'];
      String asstwo =dataToInsert['asstwo'];
      String assthree =dataToInsert['assthree'];

      List<Map<String, dynamic>> unitEntries = await fetchUnitEntries();
      bool isDuplicate = unitEntries.any((entry) =>
      entry['machName'] == machineName &&
          entry['shiftType'] == ShiftType &&
          entry['opOneName'] == OperatorName1 &&
          entry['optwoName'] == optwoName &&
          entry['assOne'] ==assOne &&
          entry['asstwo'] ==asstwo &&
          entry['assthree'] ==assthree



      );

      if (isDuplicate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Production"),
              content: Text("This item already exists on this date. do you want continue...??"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                    //  updateqtyinProduction(machineName, ShiftType, OperatorName1,optwoName,assOne,asstwo,assthree ,int.parse(qty.text),formattedDate);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>WindingEntry()));
                  },
                  child: Text("yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the alert dialog
                  },
                  child: Text("No"),
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
        body: jsonEncode({'dataToInsert': dataToInsert}),
      );

      if (response.statusCode == 200) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Winding Entry"),
              content: Text("saved successfully."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>WindingEntry()));                  },
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
  TextEditingController op1 =TextEditingController();
  TextEditingController op2 =TextEditingController();
  TextEditingController ass1 =TextEditingController();
  TextEditingController ass2 =TextEditingController();
  TextEditingController ass3 =TextEditingController();
  String? errorMessage;
  String dropdownvalue = "Shift Type";
  String validname1="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getmachine();
    fetchData();
    filteredData = List<Map<String, dynamic>>.from(data);
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

  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  String? opName1="";
  String? empID="";
  String? opName2="";
  String? empID2="";
  String? assName1="";
  String? empID3="";
  String? assName2="";
  String? empID4="";
  String? assName3="";
  String? empID5="";
  String? selectedOperator2 = "";
  String? selectedOperator1 = "";
  String? selectedOperator3 = "";
  String? selectedOperator4 = "";
  String? selectedOperator5 = "";




  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "winding_entry",
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
                                          child: Text("Winding Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),
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
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 200,
                                                height:35,
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
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 50,),
                                    Padding(
                                      padding:const EdgeInsets.only(left:8,right:8,top:10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          SizedBox(
                                            width: 200, height:34 ,
                                            child: Container(
                                              // color: Colors.white,

                                              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(color: Colors.black),
                                                  borderRadius: BorderRadius.circular(5)

                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: dropdownvalue,
                                                  items: <String>['Shift Type','General','Morning','Night',]
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
                                            width: 200, height: 120,
                                            child: TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: op1,
                                                focusNode: op1FocusNode,
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
                                                    .startsWith(pattern.toLowerCase()) &&
                                                    item['empID']?.toString()?.toLowerCase() != empID?.toLowerCase() &&
                                                    item['empID']?.toString()?.toLowerCase() != empID2?.toLowerCase())
                                                    .map<String>((item) => '${item['empName']} (${item['empID']})')
                                                    .toSet()
                                                    .toList();

                                                suggestions = suggestions.where((suggestion) =>
                                                suggestion != op2.text &&
                                                    suggestion != ass1.text &&
                                                    suggestion != ass2.text &&
                                                    suggestion != ass3.text).toList();

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

                                                selectedOperator1 = suggestion;

                                                bool isValidID = data.any((item) =>
                                                '${item['empID']}'.toLowerCase() == selectedEmpID.toLowerCase());
                                                validname1 = isValidID.toString();

                                                if (selectedOperator2 != null && suggestion == selectedOperator2 && suggestion == selectedOperator3 && suggestion == selectedOperator4 && suggestion == selectedOperator5) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the ID in Operator ";
                                                  });
                                                } else if (selectedEmpID == empID2) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the ID in Operator 2";
                                                  });
                                                } else if (selectedEmpName == ass1.text) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the ID in Assistant 1";
                                                  });
                                                } else if (selectedEmpName == ass2.text) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the ID in Assistant 2";
                                                  });
                                                } else if (selectedEmpName == ass3.text) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the ID in Assistant 3";
                                                  });
                                                } else {
                                                  setState(() {
                                                    opName1 = selectedEmpName;
                                                    empID = selectedEmpID;
                                                    op1.text = suggestion;
                                                  });

                                                  Future.delayed(Duration(milliseconds: 100), () {
                                                    setState(() {
                                                      op1FocusNode.unfocus();
                                                      op1FocusNode.canRequestFocus = false;
                                                    });
                                                  });
                                                }

                                                print('Selected Operator Name 1: $opName1, ID: $selectedEmpID');
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
                                            child:TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: op2,
                                                onChanged: (query) {
                                                  setState(() {
                                                    errorMessage = null;
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
                                                    .startsWith(pattern.toLowerCase()) &&
                                                    item['empID']?.toString()?.toLowerCase() != empID?.toLowerCase()&&
                                                    item['empID']?.toString()?.toLowerCase() != empID2?.toLowerCase() &&
                                                    item['empID']?.toString()?.toLowerCase() != empID3?.toLowerCase() &&
                                                    item['empID']?.toString()?.toLowerCase() != empID4?.toLowerCase() &&
                                                    item['empID']?.toString()?.toLowerCase() != empID5?.toLowerCase()
                                                )
                                                    .map<String>((item) => '${item['empName']} (${item['empID']})')
                                                    .toSet()
                                                    .toList();
                                                suggestions = suggestions.where((suggestion) =>
                                                suggestion != op1.text &&
                                                    suggestion != ass1.text &&
                                                    suggestion != ass2.text &&
                                                    suggestion != ass3.text).toList();

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

                                                selectedOperator2 = suggestion;

                                                if (selectedEmpID == empID) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Operator 1";
                                                  });
                                                } else {
                                                  setState(() {
                                                    errorMessage = null;
                                                    opName2 = selectedEmpName;
                                                    op2.text = suggestion;
                                                  });
                                                  print('Selected Operator Name 2: $opName2, ID: $selectedEmpID');
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                              Wrap(
                                //     alignment: WrapAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 200, height: 70,
                                          child:  TypeAheadFormField<String>(
                                            textFieldConfiguration: TextFieldConfiguration(
                                              controller: ass1,
                                              onChanged: (query) {
                                                setState(() {
                                                  errorMessage = null; // Reset error message when the user types
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
                                                  .startsWith(pattern.toLowerCase()) &&
                                                  item['empID']?.toString()?.toLowerCase() != empID?.toLowerCase() &&
                                                  item['empID']?.toString()?.toLowerCase() != empID2?.toLowerCase() &&
                                                  item['empID']?.toString()?.toLowerCase() != empID3?.toLowerCase() &&
                                                  item['empID']?.toString()?.toLowerCase() != empID4?.toLowerCase() &&
                                                  item['empID']?.toString()?.toLowerCase() != empID5?.toLowerCase())
                                                  .map<String>((item) => '${item['empName']} (${item['empID']})')
                                                  .toSet()
                                                  .toList();

                                              suggestions = suggestions.where((suggestion) =>
                                              suggestion != op1.text &&
                                                  suggestion != op2.text &&
                                                  suggestion != ass2.text &&
                                                  suggestion != ass3.text).toList();
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
                                              selectedOperator3 = suggestion;


                                              if (selectedEmpID == empID) {
                                                setState(() {
                                                  errorMessage = "Already Assigned the ID in Operator 1";
                                                });
                                              } else if (selectedEmpID == empID2) {
                                                setState(() {
                                                  errorMessage = "Already Assigned the ID in Operator 2";
                                                });
                                              } else if (selectedEmpID == empID3) {
                                                setState(() {
                                                  errorMessage = "Already Assigned the ID in Assistant 1";
                                                });
                                              } else if (selectedEmpID == empID4) {
                                                setState(() {
                                                  errorMessage = "Already Assigned the ID in Assistant 2";
                                                });
                                              } else if (selectedEmpID == empID5) {
                                                setState(() {
                                                  errorMessage = "Already Assigned the ID in Assistant 3";
                                                });
                                              } else {
                                                setState(() {
                                                  errorMessage = null;
                                                  assName1 = selectedEmpName;
                                                  ass1.text = suggestion;
                                                });
                                                print('Selected Assistant 1: $assName1, ID: $selectedEmpID');
                                              }
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
                                          child:  TypeAheadFormField<String>(
                                            textFieldConfiguration: TextFieldConfiguration(
                                              controller: ass2,
                                              onChanged: (query) {
                                                setState(() {
                                                  errorMessage = null; // Reset error message when the user types
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
                                                  .startsWith(pattern.toLowerCase()) &&
                                                  item['empID']?.toString()?.toLowerCase() != empID?.toLowerCase() &&
                                                  item['empID']?.toString()?.toLowerCase() != empID2?.toLowerCase() &&
                                                  item['empID']?.toString()?.toLowerCase() != empID3?.toLowerCase() &&
                                                  item['empID']?.toString()?.toLowerCase() != empID4?.toLowerCase() &&
                                                  item['empID']?.toString()?.toLowerCase() != empID5?.toLowerCase())
                                                  .map<String>((item) => '${item['empName']} (${item['empID']})')
                                                  .toSet()
                                                  .toList();

                                              suggestions = suggestions.where((suggestion) =>
                                              suggestion != op1.text &&
                                                  suggestion != op2.text &&
                                                  suggestion != ass1.text &&
                                                  suggestion != ass3.text).toList();
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
                                              selectedOperator4 = suggestion;


                                              if (selectedEmpID == empID || selectedEmpID == empID2 || selectedEmpID == empID3 || selectedEmpID == empID4 || selectedEmpID == empID5) {
                                                setState(() {
                                                  errorMessage = "Already Assigned the ID in Operator or Assistant";
                                                });
                                              } else {
                                                setState(() {
                                                  errorMessage = null;
                                                  assName2 = selectedEmpName;
                                                  ass2.text = suggestion;
                                                });
                                                print('Selected Assistant 2: $assName2, ID: $selectedEmpID');
                                              }
                                            },
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
                                                    .startsWith(pattern.toLowerCase()) &&
                                                    item['empID']?.toString()?.toLowerCase() != empID?.toLowerCase() &&
                                                    item['empID']?.toString()?.toLowerCase() != empID2?.toLowerCase() &&
                                                    item['empID']?.toString()?.toLowerCase() != empID3?.toLowerCase() &&
                                                    item['empID']?.toString()?.toLowerCase() != empID4?.toLowerCase() &&
                                                    item['empID']?.toString()?.toLowerCase() != empID5?.toLowerCase())

                                                    .map<String>((item) =>
                                                '${item['empName']} (${item['empID']})') // Modify this line to match your data structure
                                                    .toSet() // Remove duplicates using a Set
                                                    .toList();
                                                suggestions = suggestions.where((suggestion) =>
                                                suggestion != selectedOperator2 &&
                                                    suggestion != selectedOperator1 &&
                                                    suggestion != selectedOperator3 &&
                                                    suggestion != op1.text &&
                                                    suggestion != op2.text &&
                                                    suggestion != ass1.text &&
                                                    suggestion != ass2.text).toList();
                                                suggestions =
                                                    suggestions.where((suggestion) => suggestion.toLowerCase().startsWith(pattern.toLowerCase())).toList();


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
                                                if (selectedEmpID == empID) {
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Operator 1";
                                                  });}
                                                else if(selectedEmpID == empID3){
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Operator 2";
                                                  });}else if(selectedEmpID == empID4){
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 1";
                                                  });}
                                                else if(selectedEmpID == empID5){
                                                  setState(() {
                                                    errorMessage = "Already Assigned the name in Assistant 2";
                                                  });


                                                } else {
                                                  setState(() {
                                                    errorMessage = null;
                                                    assName3 = selectedEmpName;
                                                    ass3.text = suggestion;
                                                  });
                                                  print('Selected Customer: $assName3, ID: $selectedEmpID');
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
                                          child:  TextFormField(
                                              style: const TextStyle(fontSize: 13),
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                labelText: "Quantity",
                                                labelStyle: TextStyle(fontSize: 13, color: Colors.black),
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
                              // Wrap( crossAxisAlignment: WrapCrossAlignment.start,
                              //   children: [
                              //
                              //   ],
                              // ),


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
                          onPressed: (){
                            print("op1-${op1.text}");
                            print("op2-${op2.text}");
                            print("as1-${ass1.text}");
                            print("as2-${ass2.text}");
                            print("as3-${ass3.text}");
                            print("machname-${selectedmachine.toString()}");
                            print("shift -${dropdownvalue.toString()}");
                            if(_formKey.currentState!.validate()){
                              if(selectedmachine==null){
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
                                  errorMessage = '* Enter the Operator Name 1';
                                });
                              }
                              else if(validname1.isEmpty){
                                setState(() {
                                  errorMessage = '* ${op1.text} is not a Employee Name';
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
                                  'date':DateTime.now().toString(),
                                  "machName":selectedmachine.toString(),
                                  "opOneName": op1.text,
                                  "optwoName": op2.text,
                                  "assOne": ass1.text,
                                  "asstwo": ass2.text,
                                  "assthree": ass3.text,
                                  "shiftType": dropdownvalue.toString(),
                                };
                                insertData(dataToInsert);


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
                                            MaterialPageRoute(builder: (context) =>const WindingEntry()));// Close the alert box
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
                            );                          },child:Text("RESET",style: TextStyle(color: Colors.white),),),
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
                          },child: Text("CANCEL",style: TextStyle(color: Colors.white),),),
                        SizedBox(width: 10,),
                        MaterialButton(
                          color: Colors.blue.shade600,
                          onPressed: (){

                          },child: Text("UPDATE",style: TextStyle(color: Colors.white),),)
                      ],
                    ),
                  ),

                ]),

          ),
        ) );
  }
}

