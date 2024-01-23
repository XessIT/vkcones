// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart'as http;
//
// import '../main.dart';
//
//
// class SettingsEntry extends StatefulWidget {
//   const SettingsEntry({Key? key}) : super(key: key);
//
//   @override
//   State<SettingsEntry> createState() => _SettingsEntryState();
// }
//
// class _SettingsEntryState extends State<SettingsEntry> {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 4,
//       child: MyScaffold(
//         route: "/settings_entry",
//         body: Container(
//           color: Colors.white,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children:  [
//                 const TabBar(
//                   //  controller: _tabController,
//                   // isScrollable: true,
//                     labelColor: Colors.blue,
//                     unselectedLabelColor: Colors.black,
//                     tabs:[
//                       Tab(text: ('Unit Entry'),),
//                       Tab(text: ('Size Entry'),),
//                       Tab(text: ('Color Entry'),),
//                       Tab(text:("GST Entry"),),
//
//
//
//                     ]),
//                 const SizedBox(height: 30,),
//                 Container(
//                     height:1100,
//                     child: TabBarView(children: [
//                       UnItEntry(),
//                       SizeEntry(),
//                       ColorsEntry(),
//                       GstEntry(),
//                     ])
//                 )
//               ],
//             ),
//           ),
//         ),
//
//       ),
//     );
//   }
// }
// ///Gst Entry Class
//
// class GstEntry extends StatefulWidget {
//   GstEntry({Key? key}) : super(key: key);
//   @override
//   State<GstEntry> createState() => _GstEntryState();
// }
// class _GstEntryState extends State<GstEntry> {
//   final _formKey = GlobalKey<FormState>();
//
//   void _resetForm() {
//     _formKey.currentState!.reset();
//   }
//   static final  RegExp gstregex = RegExp(r"^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d[Z]{1}[A-Z\d]{1}$");
//
//   TextEditingController gst = TextEditingController();
//   Map<String, dynamic> dataToInsert = {};
//
//
//   Future<void> insertData(Map<String, dynamic> dataToInsert) async {
//     const String apiUrl = 'http://localhost:3309/gst_entry/'; // Replace with your server details
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
//         print('Data inserted successfully');
//       } else {
//         print('Failed to insert data');
//         throw Exception('Failed to insert data');
//       }
//     } catch (e) {
//       print('Error: $e');
//       throw Exception('Error: $e');
//     }
//   }
//   Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
//     try {
//       final response = await http.get(Uri.parse('http://localhost:3309/gst_entry'));
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.cast<Map<String, dynamic>>();
//       } else {
//         throw Exception('Error loading gst entries: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load gst entries: $e');
//     }
//   }
//   Future<void> updateunit(BuildContext context, Map<String, dynamic> unitEntry) async {
//     TextEditingController unitController = TextEditingController(text: unitEntry['gst']);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Edit GST'),
//           content: TextField(
//             controller: unitController,
//             decoration: InputDecoration(labelText: 'GST'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String updatedunit = unitController.text;
//
//                 try {
//                   final response = await http.put(
//                     Uri.parse('http://localhost:3309/gst_update/${unitEntry['id']}'),
//                     headers: {
//                       'Content-Type': 'application/json',
//                     },
//                     body: jsonEncode({'gst': updatedunit}),
//                   );
//
//                   if (response.statusCode == 200) {
//                     // Navigator.pushReplacement
//                   } else {
//                     throw Exception('Error updating gst: ${response.statusCode}');
//                   }
//                 } catch (e) {
//                   throw Exception('Failed to update gst: $e');
//                 }
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   Future<void> deleteItem(BuildContext context, int id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('http://localhost:3309/gst_delete/$id'),
//       );
//
//       if (response.statusCode == 200) {
//       } else {
//         throw Exception('Error deleting gst: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to delete gst: $e');
//     }
//   }
//   Future<void> confirmDelete(BuildContext context, int id) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete this GST?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteItem(context, id);
//                 Navigator.of(context).pop(); // Close the dialog after deletion
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           const Icon(Icons.save_alt, size:30),
//                           const Padding(
//                             padding: EdgeInsets.only(right:0),
//                             child: Text(" GST Entry",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
//                           ),
//                         ]),
//                     const SizedBox(
//                       height: 30,
//                     ),
//                     Wrap(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(
//                                 width: 300,
//                                 child: TextFormField(
//                                   controller: gst,
//                                   validator: (value){
//                                     if(value!.isEmpty){
//                                       return "* Enter GST";
//                                     }
//                                     else{
//                                       return null;
//                                     }
//                                   },
//                                   keyboardType: TextInputType.number,
//                                   inputFormatters: <TextInputFormatter>[
//                                     FilteringTextInputFormatter.digitsOnly,
//                                     LengthLimitingTextInputFormatter(2)
//                                   ],
//                                   decoration: InputDecoration(
//                                       labelText: "GST(%)",
//                                       border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(10)
//                                       )
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: 30,),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Align(
//                           alignment: Alignment.center,
//                           child: MaterialButton(
//                               shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//                               color: Colors.green.shade600,
//                               onPressed: (){
//                                 if(_formKey.currentState!.validate()){
//                                   dataToInsert = {
//                                     'gst': gst.text,
//                                   };
//                                   insertData(dataToInsert);
//
//                                 }
//                               }, child: const Text("SAVE",style: TextStyle(color: Colors.white),)),
//                         ),
//                         const SizedBox(
//                           width: 20,
//                         ),
//                         // MaterialButton(
//                         //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//                         //     color: Colors.blue.shade600,
//                         //     onPressed: (){
//                         //      Navigator.push(context, MaterialPageRoute(builder: (context)=> GSTReport()));
//                         //     }, child: const Text("View",style: TextStyle(color: Colors.white),)),
//                         const SizedBox(
//                           width: 20,
//                         ),
//                         MaterialButton(
//                             shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//                             color: Colors.red.shade600,
//                             onPressed: _resetForm, child: const Text("RESET",style: TextStyle(color: Colors.white),)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Center(
//                       child: SingleChildScrollView(
//                         child: FutureBuilder<List<Map<String, dynamic>>>(
//                           future: fetchUnitEntries(),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return Center(child: CircularProgressIndicator());
//                             } else if (snapshot.hasError) {
//                               return Center(child: Text('Error: ${snapshot.error}'));
//                             } else {
//                               return Table(
//
//                                 columnWidths: {
//                                   0: FixedColumnWidth(100), // Adjust the width of the first column
//                                   1: FixedColumnWidth(300), // Adjust the width of the second column
//                                   2: FixedColumnWidth(300), // Adjust the width of the third column
//                                 },
//
//                                 border: TableBorder.all(),
//                                 defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//                                 children: [
//                                   TableRow(
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue.shade100,
//                                     ),
//                                     children: [
//                                       Center(child: Column(
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Text('S.No', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                           ),
//                                         ],
//                                       )),
//                                       Center(child: Column(
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Text('GST', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                           ),
//
//                                         ],
//                                       )),
//                                       Center(child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Text('Action', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                       )),
//                                     ],
//                                   ),
//                                   for (var unitEntry in snapshot.data!)
//                                     TableRow(
//                                       children: [
//                                         Center(child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Text((snapshot.data!.indexOf(unitEntry) + 1).toString()),
//                                         )),
//                                         Center(child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Text(unitEntry['gst']),
//                                         )),
//                                         Row(
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: [
//                                             IconButton(
//                                               icon: Icon(Icons.edit, color: Colors.blue),
//                                               onPressed: () {
//                                                 updateunit(context, unitEntry);
//                                               },
//                                             ),
//                                             IconButton(
//                                               icon: Icon(Icons.delete, color: Colors.red),
//                                               onPressed: () {
//                                                 showDialog(
//                                                   context: context,
//                                                   builder: (BuildContext context) {
//                                                     return AlertDialog(
//                                                       title: Text('Delete'),
//                                                       content: Text('Are you sure? you want to delete the GST'),
//                                                       actions: <Widget>[
//                                                         TextButton(
//                                                           child: Text('Cancel'),
//                                                           onPressed: () {
//                                                             Navigator.of(context).pop();
//                                                           },
//                                                         ),
//                                                         TextButton(
//                                                           child: Text('Delete'),
//                                                           onPressed: () {
//                                                             deleteItem(context, unitEntry['id']);
//                                                             Navigator.of(context).pop();
//                                                           },
//                                                         ),
//                                                       ],
//                                                     );
//                                                   },
//                                                 );
//                                               },
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                 ],
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 50,),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// ///
// /// Size Entry Class
//
// class SizeEntry extends StatefulWidget {
//   const SizeEntry({Key? key}) : super(key: key);
//
//   @override
//   State<SizeEntry> createState() => _SizeEntryState();
// }
//
// class _SizeEntryState extends State<SizeEntry> {
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController size = TextEditingController();
//   String capitalizeFirstLetter(String text) {
//     if (text.isEmpty) return text;
//     return text.substring(0, 1).toUpperCase() + text.substring(1);
//   }
//   Map<String, dynamic> dataToInsert = {};
//   String errorMessage ="";
//   Future<void> insertData(Map<String, dynamic> dataToInsert) async {
//     const String apiUrl = 'http://localhost:3309/size_entry/'; // Replace with your server details
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
//         print('Data inserted successfully');
//       } else {
//         print('Failed to insert data');
//         throw Exception('Failed to insert data');
//       }
//     } catch (e) {
//       print('Error: $e');
//       throw Exception('Error: $e');
//     }
//   }
//
//
//   void _resetForm() {
//     _formKey.currentState!.reset();
//   }
//   Future<List<dynamic>> fetchSizeData() async {
//     const String apiUrl = 'http://localhost:3309/size_entry/'; // Replace with your server details
//
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//
//       if (response.statusCode == 200) {
//         List<dynamic> sizeData = jsonDecode(response.body);
//         return sizeData;
//       } else {
//         print('Failed to fetch data');
//         throw Exception('Failed to fetch data');
//       }
//     } catch (e) {
//       print('Error: $e');
//       throw Exception('Error: $e');
//     }
//   }
//
//   Future<bool> checkForDuplicate(String size) async {
//     List<dynamic> sizeData = await fetchSizeData();
//     for (var item in sizeData) {
//       if (item['size'] == size) {
//         return true; // Size already exists, return true
//       }
//     }
//     return false; // Size is unique, return false
//   }
//   Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
//     try {
//       final response = await http.get(Uri.parse('http://localhost:3309/size_entry'));
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.cast<Map<String, dynamic>>();
//       } else {
//         throw Exception('Error loading unit entries: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load unit entries: $e');
//     }
//   }
//   Future<void> updateunit(BuildContext context, Map<String, dynamic> unitEntry) async {
//     TextEditingController unitController = TextEditingController(text: unitEntry['size']);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Edit Size'),
//           content: TextField(
//             controller: unitController,
//             decoration: InputDecoration(labelText: 'Size'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String updatedunit = unitController.text;
//
//                 try {
//                   final response = await http.put(
//                     Uri.parse('http://localhost:3309/size_update/${unitEntry['id']}'),
//                     headers: {
//                       'Content-Type': 'application/json',
//                     },
//                     body: jsonEncode({'size': updatedunit}),
//                   );
//
//                   if (response.statusCode == 200) {
//                    Navigator.pop(context);
//                   } else {
//                     throw Exception('Error updating Size: ${response.statusCode}');
//                   }
//                 } catch (e) {
//                   throw Exception('Failed to update Size: $e');
//                 }
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   Future<void> deleteItem(BuildContext context, int id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('http://localhost:3309/size_delete/$id'),
//       );
//
//       if (response.statusCode == 200) {
//       } else {
//         throw Exception('Error deleting Size: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to delete Size: $e');
//     }
//   }
//   Future<void> confirmDelete(BuildContext context, int id) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete this Size?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteItem(context, id);
//                 Navigator.of(context).pop(); // Close the dialog after deletion
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Padding(
//               padding: const EdgeInsets.all(0.0),
//               child: Center(
//                 child: Column(
//                     children: [
//
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(16.0),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   const Icon(Icons.save_alt, size:30),
//                                   const Padding(
//                                     padding: EdgeInsets.only(right:0),
//                                     child: Text(" Size Entry",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
//                                   ),
//                                 ]),
//                             SizedBox(height: 20,),
//                             SizedBox(height: 30,),
//                             Wrap(
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       width: 300,
//                                       child: TextFormField(
//                                         controller: size,
//                                         validator: (value){
//                                           if(value!.isEmpty){
//                                             return "* Enter Size";
//                                           }else{
//                                             return null;
//                                           }
//                                         },
//                                         onChanged: (value) {
//                                           String capitalizedValue = capitalizeFirstLetter(value);
//                                           size.value = size.value.copyWith(
//                                             text: capitalizedValue,
//                                             selection: TextSelection.collapsed(offset: capitalizedValue.length),
//                                           );
//                                         },
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter.deny(RegExp(r'[0-9]')) // Deny numeric characters
//                                         ],
//                                         decoration: InputDecoration(
//                                           labelText: "Size",
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(10),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height:30 ,),
//
//                             Wrap(
//                               children: [
//
//                                 MaterialButton(
//                                   color:Colors.green,onPressed: () async {
//                                   if(_formKey.currentState!.validate()){
//                                     String enteredSize = size.text;
//                                     bool isDuplicate = await checkForDuplicate(enteredSize);
//                                     if (isDuplicate) {
//                                       setState(() {
//                                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Size already exists")));
//                                         errorMessage = "Size already exists"; // Set an error message
//                                       });
//                                     } else {
//                                       dataToInsert = {
//                                         'size': enteredSize,
//                                       };
//                                       await insertData(dataToInsert);
//                                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Size Saved Successful")));
//
//                                     }
//
//                                   }
//                                 },child: const Text("SAVE",style: TextStyle(color: Colors.white),),),
//                                 const SizedBox(width: 15,),
//                                 // MaterialButton(
//                                 //   color:Colors.blue,onPressed: (){
//                                 //   Navigator.push(context, MaterialPageRoute(builder: (context)=> SizeReport()));
//                                 // },child: const Text("VIEW",style: TextStyle(color: Colors.white),),),
//                                 // const SizedBox(width: 15,),
//                                 MaterialButton(
//                                   color:Colors.red,onPressed: _resetForm,
//                                   child: const Text("RESET",style: TextStyle(color: Colors.white),),),
//                               ],
//                             ),
//                                                     ],
//                         ),
//                       ),
//
//
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(16.0),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             border: Border.all(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                               child: SingleChildScrollView(
//                                 child: FutureBuilder<List<Map<String, dynamic>>>(
//                                   future: fetchUnitEntries(),
//                                   builder: (context, snapshot) {
//                                     if (snapshot.connectionState == ConnectionState.waiting) {
//                                       return Center(child: CircularProgressIndicator());
//                                     } else if (snapshot.hasError) {
//                                       return Center(child: Text('Error: ${snapshot.error}'));
//                                     } else {
//                                       return Table(
//
//                                         columnWidths: {
//                                           0: FixedColumnWidth(100), // Adjust the width of the first column
//                                           1: FixedColumnWidth(300), // Adjust the width of the second column
//                                           2: FixedColumnWidth(300), // Adjust the width of the third column
//                                         },
//
//                                         border: TableBorder.all(),
//                                         defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//                                         children: [
//                                           TableRow(
//                                             decoration: BoxDecoration(
//                                               color: Colors.blue.shade100,
//                                             ),
//                                             children: [
//                                               Center(child: Column(
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(8.0),
//                                                     child: Text('S.No', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                                   ),
//                                                 ],
//                                               )),
//                                               Center(child: Column(
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(8.0),
//                                                     child: Text('Size', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                                   ),
//
//                                                 ],
//                                               )),
//                                               Center(child: Padding(
//                                                 padding: const EdgeInsets.all(8.0),
//                                                 child: Text('Action', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                               )),
//                                             ],
//                                           ),
//                                           for (var unitEntry in snapshot.data!)
//                                             TableRow(
//                                               children: [
//                                                 Center(child: Padding(
//                                                   padding: const EdgeInsets.all(8.0),
//                                                   child: Text((snapshot.data!.indexOf(unitEntry) + 1).toString()),
//                                                 )),
//                                                 Center(child: Padding(
//                                                   padding: const EdgeInsets.all(8.0),
//                                                   child: Text(unitEntry['size']),
//                                                 )),
//                                                 Row(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: [
//                                                     IconButton(
//                                                       icon: Icon(Icons.edit, color: Colors.blue),
//                                                       onPressed: () {
//                                                         updateunit(context, unitEntry);
//                                                       },
//                                                     ),
//                                                     IconButton(
//                                                       icon: Icon(Icons.delete, color: Colors.red),
//                                                       onPressed: () {
//                                                         showDialog(
//                                                           context: context,
//                                                           builder: (BuildContext context) {
//                                                             return AlertDialog(
//                                                               title: Text('Delete'),
//                                                               content: Text('Are you sure? you want to delete the Size'),
//                                                               actions: <Widget>[
//                                                                 TextButton(
//                                                                   child: Text('Cancel'),
//                                                                   onPressed: () {
//                                                                     Navigator.of(context).pop();
//                                                                   },
//                                                                 ),
//                                                                 TextButton(
//                                                                   child: Text('Delete'),
//                                                                   onPressed: () {
//                                                                     deleteItem(context, unitEntry['id']);
//                                                                     Navigator.of(context).pop();
//                                                                   },
//                                                                 ),
//                                                               ],
//                                                             );
//                                                           },
//                                                         );
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                         ],
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ]),
//               ),
//             ),
//           ),
//         ) );
//   }
// }
//
// ///
// /// Unit Entry Class
// class UnItEntry extends StatefulWidget {
//   const UnItEntry({Key? key}) : super(key: key);
//
//   @override
//   State<UnItEntry> createState() => _UnItEntryState();
// }
//
// class _UnItEntryState extends State<UnItEntry> {
//   final _formKey = GlobalKey<FormState>();
//
//   void _resetForm() {
//     _formKey.currentState!.reset();
//   }
//
//   String errorMessage = '';
//
//   String capitalizeFirstLetter(String text) {
//     if (text.isEmpty) return text;
//     return text.substring(0, 1).toUpperCase() + text.substring(1);
//   }
//   TextEditingController unit  = TextEditingController();
//   Map<String, dynamic> dataToInsert = {};
//
//
//   Future<void> insertData(Map<String, dynamic> dataToInsert) async {
//     const String apiUrl = 'http://localhost:3309/unit_entry/'; // Replace with your server details
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
//         print('Data inserted successfully');
//       } else {
//         print('Failed to insert data');
//         throw Exception('Failed to insert data');
//       }
//     } catch (e) {
//       print('Error: $e');
//       throw Exception('Error: $e');
//     }
//   }
//
//
// ///Report
//   Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
//     try {
//       final response = await http.get(Uri.parse('http://localhost:3309/unit_entry'));
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.cast<Map<String, dynamic>>();
//       } else {
//         throw Exception('Error loading unit entries: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load unit entries: $e');
//     }
//   }
//   Future<void> updateunit(BuildContext context, Map<String, dynamic> unitEntry) async {
//     TextEditingController unitController = TextEditingController(text: unitEntry['unit']);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Edit Unit'),
//           content: TextField(
//             controller: unitController,
//             decoration: InputDecoration(labelText: 'Unit'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String updatedunit = unitController.text;
//
//                 try {
//                   final response = await http.put(
//                     Uri.parse('http://localhost:3309/unit_update/${unitEntry['id']}'),
//                     headers: {
//                       'Content-Type': 'application/json',
//                     },
//                     body: jsonEncode({'unit': updatedunit}),
//                   );
//
//                   if (response.statusCode == 200) {
//                     // Navigator.pushReplacement(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (context) => UnitReport(),
//                     //   ),
//                     // );
//                   } else {
//                     throw Exception('Error updating Unit: ${response.statusCode}');
//                   }
//                 } catch (e) {
//                   throw Exception('Failed to update Unit: $e');
//                 }
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   Future<void> deleteItem(BuildContext context, int id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('http://localhost:3309/unit_delete/$id'),
//       );
//
//       if (response.statusCode == 200) {
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(
//         //     builder: (context) => UnitReport(),
//         //   ),
//         // );
//       } else {
//         throw Exception('Error deleting UNIT: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to delete UNIT: $e');
//     }
//   }
//   Future<void> confirmDelete(BuildContext context, int id) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete this Unit?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteItem(context, id);
//                 Navigator.of(context).pop(); // Close the dialog after deletion
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Padding(
//               padding: const EdgeInsets.all(0.0),
//               child: Center(
//                 child: Column(
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(16.0),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   const Icon(Icons.save_alt, size:30),
//                                   const Padding(
//                                     padding: EdgeInsets.only(right:0),
//                                     child: Text(" Unit Entry",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
//                                   ),
//                                 ]),
//                             SizedBox(height: 20,),
//                             Wrap(
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       width: 300,
//                                       child: TextFormField(
//                                         controller: unit,
//                                         validator: (value){
//                                           if(value!.isEmpty){
//                                             return "* Enter Unit";
//                                           }else{
//                                             return null;
//                                           }
//                                         },
//                                         keyboardType: TextInputType.number,
//                                         inputFormatters: <TextInputFormatter>[
//                                           FilteringTextInputFormatter.digitsOnly,
//                                           LengthLimitingTextInputFormatter(11)
//                                         ],
//                                         decoration: InputDecoration(
//                                           labelText: "Unit",
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(10),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height:30 ,),
//                             Wrap(
//                               children: [
//                                 MaterialButton(
//                                   color:Colors.green,onPressed: (){
//                                   if(_formKey.currentState!.validate()){
//                                     dataToInsert = {
//                                       'unit': unit.text,
//                                     };
//                                     insertData(dataToInsert);
//
//                                   }
//                                 },child: const Text("SAVE",style: TextStyle(color: Colors.white),),),
//                                 const SizedBox(width: 15,),
//                                 // MaterialButton(
//                                 //   color:Colors.blue,onPressed: (){
//                                 //   Navigator.push(context, MaterialPageRoute(builder: (context)=>UnitReport()));
//                                 // },child: const Text("VIEW",style: TextStyle(color: Colors.white),),),
//                                 // const SizedBox(width: 15,),
//                                 MaterialButton(
//                                   color:Colors.red,onPressed: _resetForm,child: const Text("RESET",style: TextStyle(color: Colors.white),),),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//
//
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(16.0),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             border: Border.all(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                               child: SingleChildScrollView(
//                                 child: FutureBuilder<List<Map<String, dynamic>>>(
//                                   future: fetchUnitEntries(),
//                                   builder: (context, snapshot) {
//                                     if (snapshot.connectionState == ConnectionState.waiting) {
//                                       return Center(child: CircularProgressIndicator());
//                                     } else if (snapshot.hasError) {
//                                       return Center(child: Text('Error: ${snapshot.error}'));
//                                     } else {
//                                       return Table(
//
//                                             columnWidths: {
//                                               0: FixedColumnWidth(100), // Adjust the width of the first column
//                                               1: FixedColumnWidth(300), // Adjust the width of the second column
//                                               2: FixedColumnWidth(300), // Adjust the width of the third column
//                                             },
//
//                                         border: TableBorder.all(),
//                                         defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//                                         children: [
//                                           TableRow(
//                                             decoration: BoxDecoration(
//                                               color: Colors.blue.shade100,
//                                             ),
//                                             children: [
//                                               Center(child: Column(
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(8.0),
//                                                     child: Text('S.No', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                                   ),
//                                                 ],
//                                               )),
//                                               Center(child: Column(
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(8.0),
//                                                     child: Text('Unit', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                                   ),
//
//                                                 ],
//                                               )),
//                                               Center(child: Padding(
//                                                 padding: const EdgeInsets.all(8.0),
//                                                 child: Text('Action', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                               )),
//                                             ],
//                                           ),
//                                           for (var unitEntry in snapshot.data!)
//                                             TableRow(
//                                               children: [
//                                                 Center(child: Padding(
//                                                   padding: const EdgeInsets.all(8.0),
//                                                   child: Text((snapshot.data!.indexOf(unitEntry) + 1).toString()),
//                                                 )),
//                                                 Center(child: Padding(
//                                                   padding: const EdgeInsets.all(8.0),
//                                                   child: Text(unitEntry['unit']),
//                                                 )),
//                                                 Row(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: [
//                                                     IconButton(
//                                                       icon: Icon(Icons.edit, color: Colors.blue),
//                                                       onPressed: () {
//                                                         updateunit(context, unitEntry);
//                                                       },
//                                                     ),
//                                                     IconButton(
//                                                       icon: Icon(Icons.delete, color: Colors.red),
//                                                       onPressed: () {
//                                                         showDialog(
//                                                           context: context,
//                                                           builder: (BuildContext context) {
//                                                             return AlertDialog(
//                                                               title: Text('Delete'),
//                                                               content: Text('Are you sure? you want to delete the Unit'),
//                                                               actions: <Widget>[
//                                                                 TextButton(
//                                                                   child: Text('Cancel'),
//                                                                   onPressed: () {
//                                                                     Navigator.of(context).pop();
//                                                                   },
//                                                                 ),
//                                                                 TextButton(
//                                                                   child: Text('Delete'),
//                                                                   onPressed: () {
//                                                                     deleteItem(context, unitEntry['id']);
//                                                                     Navigator.of(context).pop();
//                                                                   },
//                                                                 ),
//                                                               ],
//                                                             );
//                                                           },
//                                                         );
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                         ],
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                     ]),
//               ),
//             ),
//           ),
//         ) );
//   }
// }
//
// ///
// ///Color Entry Class
// class ColorsEntry extends StatefulWidget {
//   const ColorsEntry({Key? key}) : super(key: key);
//
//   @override
//   State<ColorsEntry> createState() => _ColorsEntryState();
// }
//
// class _ColorsEntryState extends State<ColorsEntry> {
//   final _formKey = GlobalKey<FormState>();
//
//   void _resetForm() {
//     _formKey.currentState!.reset();
//   }
//
//   TextEditingController color = TextEditingController();
//   String errorMessage = '';
//
//   String capitalizeFirstLetter(String text) {
//     if (text.isEmpty) return text;
//     return text.substring(0, 1).toUpperCase() + text.substring(1);
//   }
//   Map<String, dynamic> dataToInsert = {};
//
//
//   Future<void> insertData(Map<String, dynamic> dataToInsert) async {
//     const String apiUrl = 'http://localhost:3309/color_entry/'; // Replace with your server details
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
//         print('Data inserted successfully');
//       } else {
//         print('Failed to insert data');
//         throw Exception('Failed to insert data');
//       }
//     } catch (e) {
//       print('Error: $e');
//       throw Exception('Error: $e');
//     }
//   }
//   ///Report
//   Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
//     try {
//       final response = await http.get(Uri.parse('http://localhost:3309/color_entry'));
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.cast<Map<String, dynamic>>();
//       } else {
//         throw Exception('Error loading color entries: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load color entries: $e');
//     }
//   }
//   Future<void> updateunit(BuildContext context, Map<String, dynamic> unitEntry) async {
//     TextEditingController unitController = TextEditingController(text: unitEntry['color']);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Edit Color'),
//           content: TextField(
//             controller: unitController,
//             decoration: InputDecoration(labelText: 'Color'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String updatedunit = unitController.text;
//
//                 try {
//                   final response = await http.put(
//                     Uri.parse('http://localhost:3309/color_update/${unitEntry['id']}'),
//                     headers: {
//                       'Content-Type': 'application/json',
//                     },
//                     body: jsonEncode({'color': updatedunit}),
//                   );
//
//                   if (response.statusCode == 200) {
//                     // Navigator.pushReplacement(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (context) => UnitReport(),
//                     //   ),
//                     // );
//                   } else {
//                     throw Exception('Error updating color: ${response.statusCode}');
//                   }
//                 } catch (e) {
//                   throw Exception('Failed to update color: $e');
//                 }
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   Future<void> deleteItem(BuildContext context, int id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('http://localhost:3309/color_delete/$id'),
//       );
//
//       if (response.statusCode == 200) {
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(
//         //     builder: (context) => UnitReport(),
//         //   ),
//         // );
//       } else {
//         throw Exception('Error deleting color: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to delete color: $e');
//     }
//   }
//   Future<void> confirmDelete(BuildContext context, int id) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete this Color?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteItem(context, id);
//                 Navigator.of(context).pop(); // Close the dialog after deletion
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Padding(
//               padding: const EdgeInsets.all(0.0),
//               child: Center(
//                 child: Column(
//                     children: [
//
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(16.0),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   const Icon(Icons.save_alt, size:30),
//                                   const Padding(
//                                     padding: EdgeInsets.only(right:0),
//                                     child: Text(" Color Entry",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
//                                   ),
//                                 ]),
//                             SizedBox(height: 20,),
//                             Wrap(
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       width: 300,
//                                       child: TextFormField(
//                                         controller: color,
//                                         validator: (value){
//                                           if(value!.isEmpty){
//                                             return "* Enter Color";
//                                           }else{
//                                             return null;
//                                           }
//                                         },
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter.deny(RegExp(r'[0-9]')) // Deny numeric characters
//                                         ],
//                                         onChanged: (value) {
//                                           String capitalizedValue = capitalizeFirstLetter(value);
//                                           color.value = color.value.copyWith(
//                                             text: capitalizedValue,
//                                             selection: TextSelection.collapsed(offset: capitalizedValue.length),
//                                           );
//                                         },
//                                         decoration: InputDecoration(
//                                           labelText: "Color",
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(10),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height:30 ,),
//                             Wrap(
//                               children: [
//                                 MaterialButton(
//                                   color:Colors.green,onPressed: (){
//                                   if(_formKey.currentState!.validate()){
//                                     dataToInsert = {
//                                       'color': color.text,
//                                     };
//
//                                     insertData(dataToInsert);
//
//                                   }
//                                 },child: const Text("SAVE",style: TextStyle(color: Colors.white),),),
//                                 SizedBox(width: 15,),
//                                 // MaterialButton(
//                                 //   color:Colors.blue,onPressed: (){
//                                 //   Navigator.push(context, MaterialPageRoute(builder: (context)=>ColorsReport()));
//                                 // },child: Text("View",style: TextStyle(color: Colors.white),),),
//                                 SizedBox(width: 15,),
//                                 MaterialButton(
//                                   color:Colors.red,onPressed: _resetForm,child: Text("RESET",style: TextStyle(color: Colors.white),),),
//                               ],
//                             ),
//
//                           ],
//                         ),
//                       ),
//
//
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(16.0),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             border: Border.all(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                               child: SingleChildScrollView(
//                                 child: FutureBuilder<List<Map<String, dynamic>>>(
//                                   future: fetchUnitEntries(),
//                                   builder: (context, snapshot) {
//                                     if (snapshot.connectionState == ConnectionState.waiting) {
//                                       return Center(child: CircularProgressIndicator());
//                                     } else if (snapshot.hasError) {
//                                       return Center(child: Text('Error: ${snapshot.error}'));
//                                     } else {
//                                       return Table(
//
//                                         columnWidths: {
//                                           0: FixedColumnWidth(100), // Adjust the width of the first column
//                                           1: FixedColumnWidth(300), // Adjust the width of the second column
//                                           2: FixedColumnWidth(300), // Adjust the width of the third column
//                                         },
//
//                                         border: TableBorder.all(),
//                                         defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//                                         children: [
//                                           TableRow(
//                                             decoration: BoxDecoration(
//                                               color: Colors.blue.shade100,
//                                             ),
//                                             children: [
//                                               Center(child: Column(
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(8.0),
//                                                     child: Text('S.No', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                                   ),
//                                                 ],
//                                               )),
//                                               Center(child: Column(
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets.all(8.0),
//                                                     child: Text('Color', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                                   ),
//
//                                                 ],
//                                               )),
//                                               Center(child: Padding(
//                                                 padding: const EdgeInsets.all(8.0),
//                                                 child: Text('Action', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                               )),
//                                             ],
//                                           ),
//                                           for (var unitEntry in snapshot.data!)
//                                             TableRow(
//                                               children: [
//                                                 Center(child: Padding(
//                                                   padding: const EdgeInsets.all(8.0),
//                                                   child: Text((snapshot.data!.indexOf(unitEntry) + 1).toString()),
//                                                 )),
//                                                 Center(child: Padding(
//                                                   padding: const EdgeInsets.all(8.0),
//                                                   child: Text(unitEntry['color']),
//                                                 )),
//                                                 Row(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: [
//                                                     IconButton(
//                                                       icon: Icon(Icons.edit, color: Colors.blue),
//                                                       onPressed: () {
//                                                         updateunit(context, unitEntry);
//                                                       },
//                                                     ),
//                                                     IconButton(
//                                                       icon: Icon(Icons.delete, color: Colors.red),
//                                                       onPressed: () {
//                                                         showDialog(
//                                                           context: context,
//                                                           builder: (BuildContext context) {
//                                                             return AlertDialog(
//                                                               title: Text('Delete'),
//                                                               content: Text('Are you sure? you want to delete the Color'),
//                                                               actions: <Widget>[
//                                                                 TextButton(
//                                                                   child: Text('Cancel'),
//                                                                   onPressed: () {
//                                                                     Navigator.of(context).pop();
//                                                                   },
//                                                                 ),
//                                                                 TextButton(
//                                                                   child: Text('Delete'),
//                                                                   onPressed: () {
//                                                                     deleteItem(context, unitEntry['id']);
//                                                                     Navigator.of(context).pop();
//                                                                   },
//                                                                 ),
//                                                               ],
//                                                             );
//                                                           },
//                                                         );
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                         ],
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//
//                     ]),
//               ),
//             ),
//           ),
//         ) );
//   }
// }
//
// ///
//
// class UpperCaseTextFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     return TextEditingValue(
//       text: newValue.text?.toUpperCase() ?? '', // Convert to uppercase
//       selection: newValue.selection,
//     );
//   }
// }
