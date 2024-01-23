import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home.dart';
import '../main.dart';

class SalesOrderEntry extends StatefulWidget {
  const SalesOrderEntry({Key? key}) : super(key: key);

  @override
  State<SalesOrderEntry> createState() => _SalesOrderEntryState();
}

class _SalesOrderEntryState extends State<SalesOrderEntry> {
  List<List<TextEditingController>> controllers = [];
  List<List<FocusNode>> focusNodes = [];

  @override
  void initState() {
    super.initState();
    // Add initial row
    addRow();
  }

  void addRow() {
    setState(() {
      List<TextEditingController> rowControllers = [];
      List<FocusNode> rowFocusNodes = [];

      for (int j = 0; j < 9; j++) {
        rowControllers.add(TextEditingController());
        rowFocusNodes.add(FocusNode());
      }

      controllers.add(rowControllers);
      focusNodes.add(rowFocusNodes);
      // Set focus on the first input field of the newly added row
      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(rowFocusNodes[0]);
      });
    });
  }
  void removeRow(int index) {
    setState(() {
      controllers.removeAt(index);
      focusNodes.removeAt(index);
    });
  }
String? paymentype;
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  @override
  void dispose() {
    for (var rowControllers in controllers) {
      for (var controller in rowControllers) {
        controller.dispose();
      }
    }

    super.dispose();
  }
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  // RegExp nameRegExp = RegExp(r'^[a-zA-Z]+(\s[a-zA-Z]+)?$');
  void _resetForm() {
    _formKey.currentState!.reset();
  }
  TextEditingController customername = TextEditingController();
  TextEditingController location = TextEditingController();
  void _cancelForm() {
    print('Form cancelled!');
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      route: 'sales_order_entry',
      body:  Form(
        key: _formKey,
        child:  Center(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Text("Sales Order Entry",style: TextStyle(color: Colors.black,
                  fontWeight: FontWeight.bold,fontSize: 20),),
            SizedBox(height: 20,),
              Wrap(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 90),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Invoice Number"),
                                SizedBox(
                                  width: 200,height: 75,
                                  child: TextFormField(style: TextStyle(fontSize: 13),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter Invoice Number';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),

                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 90),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Date"),
                                SizedBox(
                                  width: 200,
                                  height: 70,
                                  child: TextFormField(style: TextStyle(fontSize: 13),
                                    readOnly: true, // Set the field as read-only
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter Date';
                                      }
                                      return null;
                                    },
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: selectedDate,
                                        firstDate: DateTime(2000), // Set the range of selectable dates
                                        lastDate: DateTime(2100),
                                      ).then((date) {
                                        if (date != null) {
                                          setState(() {
                                            selectedDate = date; // Update the selected date
                                          });
                                        }
                                      });
                                    },
                                    controller: TextEditingController(text: selectedDate.toString().split(' ')[0]), // Set the initial value of the field to the selected date
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ]
              ),
              Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Customer Code"),
                        SizedBox(width: 200,height: 70,
                          child: TextFormField(style: TextStyle(fontSize: 13),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '* Enter Customer Code';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
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
                        Text("Customer Name/Company Name"),
                        SizedBox(width: 200,height: 70,
                          child: TextFormField(
                          controller: customername,
                            style: TextStyle(fontSize: 13),
                            onChanged: (value) {
                              String capitalizedValue = capitalizeFirstLetter(value);
                              customername.value = customername.value.copyWith(
                                text: capitalizedValue,
                                selection: TextSelection.collapsed(offset: capitalizedValue.length),
                              );
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '* Enter Customer Name/\nCompany Name';
                              }
                              // else if (!nameRegExp.hasMatch(value)) {
                              //   return 'Please enter alphabetic only';
                              // }
                              return null;
                            },
                            decoration: InputDecoration(
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
                        Text("Loction"),
                        SizedBox(width: 200,height: 70,
                          child: TextFormField
                            (controller: location,
                            style: TextStyle(fontSize: 13),
                            onChanged: (value) {
                              String capitalizedValue = capitalizeFirstLetter(value);
                              location.value = location.value.copyWith(
                                text: capitalizedValue,
                                selection: TextSelection.collapsed(offset: capitalizedValue.length),
                              );
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '* Enter Location';
                              }
                              // else if (!nameRegExp.hasMatch(value)) {
                              //   return 'Please enter alphabetic only';
                              // }
                              return null;
                            },
                            decoration: InputDecoration(
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
                        Text("Mobile Number"),
                        SizedBox(width: 200,height: 70,
                          child: TextFormField(style: TextStyle(fontSize: 13),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "* Enter Mobile Number";
                              } else if (value.length < 10) {
                                return "* Mobile Number should be 10 digits";
                              }  else{
                                return null;}
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 650),
                child: Wrap(
                  children: [

                    Padding(
                      padding:const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Payment Type"),
                          SizedBox(
                            width: 200,
                            height: 35,
                            child: Container(
                              // padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  // Step 3.
                                  value: paymentype,
                                  // Step 4.
                                  items: <String>['Cash','Online','Credit',]
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
                                      paymentype = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              SizedBox(height: 20,),
              Align(
                  alignment:Alignment.topLeft,child:
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text("Product Details",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20),),
              )),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      defaultColumnWidth: const FixedColumnWidth(140.0),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FixedColumnWidth(150),
                        1: FixedColumnWidth(150),
                        2: FixedColumnWidth(150),
                        7: FixedColumnWidth(150),
                        8: FixedColumnWidth(150),
                        9: FixedColumnWidth(80),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        // Table header row
                        TableRow(
                          children: [
                            TableCell(
                              child: Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    Text('Item Group',style: TextStyle(fontWeight: FontWeight.bold),),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text('Item Name',style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text('Quantity',style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text('Total Quantity',style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text('Rate per \n   Unit',style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text('Amount',style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text('GST \n (%)',style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text("Tax Amount \n     (GST)",style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text('Total',style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text('Action',style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ],
                        ),

                        // Table data rows
                        for (var i = 0; i < controllers.length; i++)
                          TableRow(
                            children: [
                              for (var j = 0; j < 9; j++)
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(style: TextStyle(fontSize: 13),
                                      controller: controllers[i][j],
                                      focusNode: focusNodes[i][j],
                                      decoration: InputDecoration(),
                                    ),
                                  ),
                                ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red.shade600,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirmation'),
                                            content: Text('Are you sure you want to remove this row?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop(); // Close the alert box
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Remove'),
                                                onPressed: () {
                                                  removeRow(i); // Remove the row
                                                  Navigator.of(context).pop(); // Close the alert box
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: MaterialButton(
                      color: Colors.green.shade600,
                      onPressed: addRow,
                      child: Text("Add Row", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Wrap(
               // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text("Total Amount"),
                        SizedBox(width: 150,height: 70,
                          child: TextFormField(style: TextStyle(fontSize: 13),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '* Enter Total Amount';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10)
                            ],
                            decoration: InputDecoration(
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
                        Text("Discount %"),
                        SizedBox(width: 150,height: 70,
                          child: TextFormField(style: TextStyle(fontSize: 13),
                            // validator: (value) {
                            //   if (value!.isEmpty) {
                            //     return '* Enter Discount';
                            //   }
                            //   // else if (!nameRegExp.hasMatch(value)) {
                            //   //   return 'Please enter numbers only';
                            //   // }
                            //   return null;
                            // },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10)
                            ],
                            decoration: InputDecoration(
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
                        Text("Discount Amount"),
                        SizedBox(width: 150,height: 70,
                          child: TextFormField(style: TextStyle(fontSize: 13),
                            // validator: (value) {
                            //   if (value!.isEmpty) {
                            //     return '* Enter Discount Amount';
                            //   }
                            //   return null;
                            // },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(7)
                            ],
                            decoration: InputDecoration(
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
                        Text("Tax Amount"),
                        SizedBox(width: 150,height: 70,
                          child: TextFormField(style: TextStyle(fontSize: 13),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '* Enter Tax Amount';
                              }
                              // else if (!nameRegExp.hasMatch(value)) {
                              //   return 'Please enter numbers only';
                              // }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10)
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ),
                      ],
                    ),
                  ),  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Grand Total"),
                        SizedBox(width: 150,height: 70,
                          child: TextFormField(style: TextStyle(fontSize: 13),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '* Enter Grant Total';
                              }
                              // else if (!nameRegExp.hasMatch(value)) {
                              //   return 'Please enter numbers only';
                              // }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10)
                            ],
                            decoration: InputDecoration(
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
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Wrap(
                  children: [
                    MaterialButton(
                      color:Colors.green,onPressed: (){
                        if(_formKey.currentState!.validate()){}
                        print("Successfull");
                    },child: Text("Submit",style: TextStyle(color: Colors.white),),),
                    SizedBox(width:10),
                    MaterialButton(color:Colors.blue,onPressed: _resetForm,child: Text("Reset",style: TextStyle(color: Colors.white),),),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
