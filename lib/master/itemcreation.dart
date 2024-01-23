// import 'package:flutter/material.dart';
// import 'package:vinayaga_project/main.dart';
//
// import '../home.dart';
//
// class ItemCreation extends StatelessWidget {
//   final _formKey = GlobalKey<FormState>();
//
//   late FocusNode _itemNameFocusNode;
//   late FocusNode _hsnCodeFocusNode;
//   late FocusNode _sizeFocusNode;
//   late FocusNode _unitFocusNode;
//   late FocusNode _colorFocusNode;
//   late FocusNode _gstFocusNode;
//   late FocusNode _saleRateFocusNode;
//
//   @override
//   void initState() {
//     _itemNameFocusNode = FocusNode();
//     _hsnCodeFocusNode = FocusNode();
//     _sizeFocusNode = FocusNode();
//     _unitFocusNode = FocusNode();
//     _colorFocusNode = FocusNode();
//     _gstFocusNode = FocusNode();
//     _saleRateFocusNode = FocusNode();
//   }
//
//   @override
//   void dispose() {
//     _itemNameFocusNode.dispose();
//     _hsnCodeFocusNode.dispose();
//     _sizeFocusNode.dispose();
//     _unitFocusNode.dispose();
//     _colorFocusNode.dispose();
//     _gstFocusNode.dispose();
//     _saleRateFocusNode.dispose();
//
//   }
//   // RegExp nameRegExp = RegExp(r'^[a-zA-Z/,]+(\s[a-zA-Z]+)?$');
//   void _resetForm() {
//     _formkey.currentState!.reset();
//   }
//
//   void _cancelForm() {
//     print('Form cancelled!');
//   }
//
//   ItemCreation({Key? key}) : super(key: key);
//   GlobalKey<FormState> _formkey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return MyScaffold(
//       route: "itemcreation",
//       body:Form(
//         key: _formkey,
//         child: Center(
//           child: Column(
//             children: [
//               SizedBox(height: 50,),
//               Center(
//                 child: Text("Item Creation", style: TextStyle(
//                   fontWeight:FontWeight.bold,
//                   fontSize: 20,
//                 ),),
//               ),
//               Container(
//
//               ),
//
//               SizedBox(height: 50,),
//               Padding(
//                 padding: const EdgeInsets.only(right: 40),
//                 child: Wrap(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("ItemName"),
//                           SizedBox(height: 7,),
//                           SizedBox(
//                             width: 200, height: 70,
//                             child: TextFormField(style: TextStyle(fontSize: 13),
//                               textInputAction: TextInputAction.next,
//                               onEditingComplete: () {
//                                 FocusScope.of(context).requestFocus(_hsnCodeFocusNode);
//                               },
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return '* Enter ItemName';
//                                 }
//                                 return null;
//                               },
//                               decoration: InputDecoration(
//                                 // hintText: "Enter ItemName",
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10)
//                                   )
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("HSN/SAC Code"),
//                           SizedBox(height: 7,),
//                           SizedBox(
//                             width: 200, height: 70,
//                             child: TextFormField(style: TextStyle(fontSize: 13),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return '* Enter HSN/SAC Code';
//                                 }
//                                 return null;
//                               },
//                               decoration: InputDecoration(
//                                 // hintText: "Enter HSN/SAC Code",
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10)
//                                   )
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("Size"),
//                           SizedBox(height: 7,),
//                           SizedBox(
//                             width: 200, height: 70,
//                             child: TextFormField(style: TextStyle(fontSize: 13),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return '* Enter Size';
//                                 }
//                                 return null;
//                               },
//                               decoration: InputDecoration(
//                                 // hintText: "Enter Size",
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10)
//                                   )
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("Unit"),
//                           SizedBox(height: 7,),
//                           SizedBox(
//                             width: 200,height: 70,
//                             child: TextFormField(style: TextStyle(fontSize: 13),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return '* Enter Unit';
//                                 }
//                                 return null;
//                               },
//                               decoration: InputDecoration(
//                                 // hintText: "Enter Unit",
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10)
//                                   )
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(right:250),
//                 child: Wrap(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("Color"),
//                           SizedBox(height: 7,),
//                           SizedBox(
//                             width: 200,height: 70,
//                             child: TextFormField(style: TextStyle(fontSize: 13),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return '* Enter Color';
//                                 }
//                                 return null;
//                               },
//                               decoration: InputDecoration(
//                                 // hintText: "Enter Size",
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10)
//                                   )
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("GST%"),
//                           SizedBox(height: 7,),
//                           SizedBox(
//                             width: 200,height: 70,
//                             child: TextFormField(style: TextStyle(fontSize: 13),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return '* Enter GST%';
//                                 }
//                                 return null;
//                               },
//                               decoration: InputDecoration(
//                                 // hintText: "Enter Unit",
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10)
//                                   )
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("SaleRate"),
//                           SizedBox(height: 7,),
//                           SizedBox(
//                             width: 200,height: 70,
//                             child: TextFormField(style: TextStyle(fontSize: 13),
//                               validator: (value) {
//                                 if (value!.isEmpty) {
//                                   return '* Enter SaleRate';
//                                 }
//                                 return null;
//                               },
//                               decoration: InputDecoration(
//                                 // hintText: "Enter Unit",
//                                   border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10)
//                                   )
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10,),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Align(
//                     alignment: Alignment.center,
//                     child: MaterialButton(
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//                         color: Colors.green.shade600,
//                         onPressed: (){
//                           if(_formkey.currentState!.validate()){}
//                           print("Successfull");
//                         }, child: const Text("Submit",style: TextStyle(color: Colors.white),)),
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: MaterialButton(
//                       color: Colors.blue.shade600,
//                       onPressed:_resetForm,
//                       child: Text("Reset", style: TextStyle(color: Colors.white)),),
//                   ),
//                   SizedBox(width: 10,),
//                   MaterialButton(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//                       color: Colors.red.shade600,
//                       onPressed: (){
//                         /*  Navigator.push(context,
//                                   MaterialPageRoute(builder: (context) =>const Home()));*/// Close the alert box
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: const Text('Confirmation'),
//                               content: const Text('Do you want to cancel?'),
//                               actions: <Widget>[
//
//                                 TextButton(
//                                   child: const Text('Yes'),
//                                   onPressed: () {
//                                     Navigator.push(context,
//                                         MaterialPageRoute(builder: (context) =>const Home()));// Close the alert box
//                                   },
//                                 ),
//                                 TextButton(
//                                   child: const Text('No'),
//                                   onPressed: () {
//                                     Navigator.of(context).pop(); // Close the alert box
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       child: const Text("Cancel",style: TextStyle(color: Colors.white),)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
