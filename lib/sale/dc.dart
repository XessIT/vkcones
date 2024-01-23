
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinayaga_project/main.dart';
import '../home.dart';
import 'package:http/http.dart' as http;

import 'dc_entry_pdf.dart';
import 'dc_individual_pdf.dart';




class Dc extends StatefulWidget {
  const Dc ({Key? key}) : super(key: key);
  @override
  State<Dc> createState() => _PurchaseState();
}





class _PurchaseState extends State<Dc> {
  final _formKey = GlobalKey<FormState>();


  TextEditingController dcNo = TextEditingController();
  TextEditingController invoiceNo = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController custCode= TextEditingController();
  TextEditingController custName= TextEditingController();
  TextEditingController custAddress = TextEditingController();
  TextEditingController pincode=TextEditingController();
  TextEditingController custMobile = TextEditingController();
  TextEditingController orderNo = TextEditingController();
  TextEditingController ewayNo = TextEditingController();
  TextEditingController transNo = TextEditingController();
  TextEditingController supplyPlace = TextEditingController();
  TextEditingController qty = TextEditingController();
  TextEditingController total = TextEditingController();
  TextEditingController rate = TextEditingController();
  TextEditingController amt = TextEditingController();
  TextEditingController GSTIN = TextEditingController();
  TextEditingController tax = TextEditingController();
  TextEditingController totalAmount = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController discountAmt = TextEditingController();
  TextEditingController taxAmt = TextEditingController();
  TextEditingController grandTotal =TextEditingController();
  final TextEditingController searchController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<List<TextEditingController>> controllers = [];
  List<List<FocusNode>> focusNodes = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> custdata = [];
  List<Map<String, dynamic>> filterecustData = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> rowData = [];
  List<Map<String, dynamic>> filteredCodeData = [];
  var totalValues = 0;
  int currentDcNumber = 1;
  String? errorMessage="";
  String? deliveryType;
  String? newCode;
  bool showInitialData = true;
  bool isDataSaved = false;
  String itemGroup = '';
  String itemName = '';
  String quantity = '';
  String selectedInvoiceNo="";
  RegExp truckNumberPattern = RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{1,2}\d{1,4}$');

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }


  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    // Use the key "dcNo" to access the value of the "dcNo" column.
    return jsonItem['dcNo'];
  }

  String dcnumber = "";
  String? dcno;
  List<Map<String, dynamic>> codedata = [];



  String generateId() {
    DateTime now= DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');
    if (DCNO != null) {
      String ID = DCNO!.substring(7);
      int idInt = int.parse(ID) + 1;
      String id = 'DC$year$month/${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }



//sales item
  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/dc_entries?invoiceNo=$invNo'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }


  @override
  void initState() {
    super.initState(); //add Row
    addRow();
    //quotfetch();
    fetchData();
    dcnumfetch();
    fetchData2();
    fetchData3();
    // quotfetch();
  }


  //int currentInvoiceNumber = 1;




  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getSales'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
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

  void filterData(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = data;
        custCode.clear();
        orderNo.clear();
        custName.clear();
        grandTotal.clear();
        deliveryType=null;
        filteredData = data;
      } else {
        filteredData = data.where((item) {
          String id = item['invoiceNo']?.toString()?.toLowerCase() ?? '';
          return id == searchText.toLowerCase();
        }).toList();
        if (filteredData.isNotEmpty) {
          Map<String, dynamic> order = filteredData.first;
          custCode.text = order['custCode']?.toString() ?? '';
          orderNo.text = order['orderNo']?.toString() ?? '';
          custName.text = order['custName']?.toString() ?? '';
          deliveryType = order['deliveryType']?.toString() ?? '';
          grandTotal.text = order['grandTotal']?.toString() ?? '';
        } else {
          custCode.clear();orderNo.clear();
          custName.clear();
          grandTotal.clear();
        }
      }
      for (var i = 0; i < controllers.length; i++) {
        List<TextEditingController> rowControllers = controllers[i];
        List<FocusNode> rowFocusNodes = focusNodes[i];
        Map<String, dynamic> row = rowData[i];
        for (var j = 0; j < 7; j++) {
          rowControllers[j].text = row[_getKeyForColumn(j)] ?? '';
        }
        // Set the item group, item name, and quantity in the rowData map
        row['itemGroup'] = itemGroup;
        row['itemName'] = itemName;
        row['qty'] = quantity;
      }
    });
  }














  Future<void> getitem() async {
    try {
      final url = Uri.parse('http://localhost:3309/getGroup');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;

        itemGroups = units.map((item) => item['itemGroup'] as String).toList();

        setState(() {
          // Print itemGroupValues to check if it's populated correctly.
          print('Item Groups: $itemGroups');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }


  Future<void> getitemname() async {
    try {
      final url = Uri.parse('http://localhost:3309/getName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;

        itemNames = units.map((item) => item['itemName'] as String).toList();

        setState(() {
          // Print itemGroupValues to check if it's populated correctly.
          print('Item Groups: $itemNames');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }



  String? getItemFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['itemGroup'];
  }
  String? getItemNameFromJsonData(Map<String, dynamic> jsonItem) {
    // Use the key "name" to access the value of the "name" column.
    return jsonItem['itemName'];
  }


  List<String> itemGroups = [];
  String? item;
  String? itemname;
  List<String> itemNames = [];
  List<String?> selectedItemNames = [];
  List<String?> selectedItemGroups = [];
  DateTime eod = DateTime.now();







  void addRow() {
    setState(() {
      List<TextEditingController> rowControllers = [];
      List<FocusNode> rowFocusNodes = [];

      for (int j = 0; j < 4; j++) {
        rowControllers.add(TextEditingController());
        rowFocusNodes.add(FocusNode());
      }

      controllers.add(rowControllers);
      focusNodes.add(rowFocusNodes);

      Map<String, dynamic> row = {
        'itemGroup':null,
        'itemName': null,
        'qty':'',
        'total':'',
        //'grandTotal':'',
      };
      selectedItemNames.add(null);
      selectedItemGroups.add(null);
      rowData.add(row);
      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(rowFocusNodes[0]);
      });
    });
  }

  void removeRow(int index) {
    setState(() {
      controllers.removeAt(index);
    });
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

  void _resetForm() {
    _formKey.currentState!.reset();
    rowData.clear();
    custName.clear();
    custMobile.clear();
    custCode.clear();
    custAddress.clear();
    grandTotal.clear();
    invoiceNo.clear();
    transNo.clear();
    supplyPlace.clear();
    setState(() {
    });
  }
  void _cancelForm() {
    print('Form cancelled!');
  }





  Map<String, dynamic> dataToInsert = {};
  Future<void> insertData(List<Map<String, dynamic>> rowsDataToInsert) async {
    const String apiUrl = 'http://localhost:3309/DC';
    try {
      for (var dataToInsert in rowsDataToInsert) {
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
                title: Text('DC'),
                content: Text('Save Successfully'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dc()),
                      );
                    },
                    child: Text('OK'),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => dcIndividualPDFView(
                            dcNo: generateId(),
                            date: eod.toString(),
                            custCode: custCode.text,
                            invNo: invoiceNo.text,
                            custName: custName.text,
                            custMobile:custMobile.text,
                            custAddress:custAddress.text,
                            pincode: pincode.text,
                            supplyPlace: supplyPlace.text,
                            grandTotal: grandTotal.text,
                          ),
                        ),
                      );
                    },
                    child: Text('PRINT'),
                  ),
                ],
              );
            },
          );
          print('Data inserted successfully');
        } else {
          print('Failed to insert data');
          throw Exception('Failed to insert data');
        }
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }


  double calculateGrandTotal() {
    double grandTotalValue = 0.0;
    for (var i = 0; i < rowData.length; i++) {
      final double total = double.tryParse(rowData[i]['total']) ?? 0.0;
      grandTotalValue += total;
    }
    return grandTotalValue;
  }



  List<Map<String, dynamic>> dcnumdata = [];
  String? DCNO;



  Future<void> dcnumfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getDcno'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          DCNO = getNameFromJsonData(item);
          print('dcNo: $DCNO');
        }
        setState(() {
          dcnumdata = jsonData.cast<Map<String, dynamic>>();
          dcnumber = generateId(); // Call generateId here
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


  List<Map<String, dynamic>> filteredData2 = [];
  List<Map<String, dynamic>> data2 = [];

  void filterData2(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData2 = data2;
        custMobile.clear();
        pincode.clear();
        custAddress.clear();
      } else {
        final existingSupplier = data2.firstWhere(
              (item) => item['custCode']?.toString() == searchText,
          orElse: () => {},
          // Use an empty map literal as the default value
        );
        if (existingSupplier.isNotEmpty) {
          custMobile.text = existingSupplier['custMobile']?.toString() ?? '';
          custAddress.text = existingSupplier['custAddress']?.toString() ?? '';
          pincode.text = existingSupplier['pincode']?.toString() ?? '';
          GSTIN.text = existingSupplier['gstin']?.toString() ?? '';
          deliveryType = existingSupplier['deliveryType']?.toString() ?? '';
        } else {
          custMobile.clear();
          custAddress.clear();
        }
      }
    });
  }

  Future<void> fetchData2() async {
    try {
      final url = Uri.parse('http://localhost:3309/fetch_customer_details/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          data2 = itemGroups.cast<Map<String, dynamic>>();
        });

        print('Data: $data2');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }





  void didChangeDependencies() {
    super.didChangeDependencies();
    if (showInitialData) {
    }
  }

  List<Map<String, dynamic>> filteredData3 = [];
  List<Map<String, dynamic>> data3 = [];
  Future<void> fetchData3() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/checkinvoice_fordc'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        jsonData.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['date']);
          final DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA);
        });
        setState(() {
          data3 = jsonData.cast<Map<String, dynamic>>();
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


  void filterData3(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredData3 = data3.where((item) {
          final custName = item[''].toString().toLowerCase();
          return custName.contains(query.toLowerCase());
        }).toList();
        showInitialData = false;
      } else {
        filteredData3 = List.from(data3);
        showInitialData = true;
      }
    });
  }


  bool invoicenumberexiest(String name) {
    return data3.any((item) => item['invoiceNo'].toString().toLowerCase() == name.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    invoiceNo.addListener(() {
      filterData(invoiceNo.text);
    });
    custCode.addListener(() {
      filterData2(custCode.text);
    });
    invoiceNo.addListener(() {
      filterData3(invoiceNo.text);
    });

    final selectedDate = DateTime.now();
    return Builder(
        builder: (context) =>
            MyScaffold(
              route: "dc",
              body:  Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                        children: [
                          // Text("Delivery Challan Entry",style:Theme.of(context).textTheme.displayLarge),
                          // SizedBox(height: 20,),
                          SizedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: SizedBox(
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border: Border.all(color: Colors.grey), // Add a border for the box
                                    borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                                  ),child: Wrap(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left:10.0),
                                              child: Image.asset(
                                                'assets/4_db_deliverychallen.png',
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                            const Text("  Delivery Challan Entry ", style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25
                                            ),),
                                          ],
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(right: 10.0),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width:150,
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        child: TextFormField(
                                                          style: TextStyle(fontSize: 13),
                                                          readOnly: true,
                                                          onTap: () {
                                                            showDatePicker(
                                                              context: context,
                                                              initialDate: eod,
                                                              firstDate: eod,
                                                              // Set the range of selectable dates
                                                              lastDate: DateTime(2100),
                                                            ).then((date) {
                                                              if (date != null) {
                                                                setState(() {
                                                                  eod = date; // Update the selected date
                                                                  print("$eod: date");
                                                                });
                                                              }
                                                            });

                                                          },

                                                          controller: TextEditingController(
                                                            text: DateFormat('dd-MM-yyyy').format(eod),
                                                          ),

                                                          // Set the initial value of the field to the selected date

                                                          decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,

                                                            labelText: "Date",

                                                            border: OutlineInputBorder(

                                                              borderRadius: BorderRadius.circular(10),

                                                            ),

                                                          ),

                                                        ),

                                                      ),
                                                      /*   Padding(
                                                        padding: const EdgeInsets.only(right: 125.0),
                                                        child: Text(
                                                          DateFormat('dd-MM-yyyy').format(selectedDate),
                                                          style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
                                                        ),
                                                      ),*/
                                                      SizedBox(height: 3,),
                                                      Wrap(
                                                          children:[
                                                            SizedBox(
                                                              width: 150,
                                                              child: TypeAheadFormField<String>(
                                                                textFieldConfiguration: TextFieldConfiguration(
                                                                  controller: invoiceNo,
                                                                  style: const TextStyle(fontSize: 13),
                                                                  onChanged: (value) {
                                                                    if (invoicenumberexiest(invoiceNo.text)) {
                                                                      setState(() {
                                                                        errorMessage = '* This Invoice Already Saved';
                                                                      });
                                                                      //showErrorMessage(errorMessage!);
                                                                      return;
                                                                    }
                                                                    setState(() {
                                                                      errorMessage = null; // Reset error message when the user types
                                                                    });
                                                                  },
                                                                  inputFormatters: [
                                                                    UpperCaseTextFormatter()
                                                                  ],
                                                                  decoration: InputDecoration(
                                                                    fillColor: Colors.white,
                                                                    filled: true,
                                                                    labelText: "Invoice Number",
                                                                    labelStyle: TextStyle(fontSize: 13),
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                  ),
                                                                ),
                                                                suggestionsCallback: (pattern) async {
                                                                  List<String> suggestions;
                                                                  if (pattern.isNotEmpty) {
                                                                    suggestions = data
                                                                        .where((item) =>
                                                                        (item['invoiceNo']?.toString()?.toLowerCase() ?? '')
                                                                            .startsWith(pattern.toLowerCase()))
                                                                        .map((item) => item['invoiceNo'].toString())
                                                                        .toSet() // Remove duplicates using a Set
                                                                        .toList();

                                                                    // Exclude existing invoice numbers from suggestions
                                                                    suggestions.removeWhere((existingInvoiceNo) =>
                                                                    invoicenumberexiest(existingInvoiceNo) &&
                                                                        existingInvoiceNo != invoiceNo.text);
                                                                  } else {
                                                                    if (invoicenumberexiest(invoiceNo.text)) {
                                                                      setState(() {
                                                                        errorMessage = '* This Invoice Already Saved';
                                                                      });
                                                                      suggestions = [];
                                                                    } else {
                                                                      suggestions = [];
                                                                    }
                                                                  }
                                                                  return suggestions;
                                                                },
                                                                itemBuilder: (context, suggestion) {
                                                                  return ListTile(
                                                                    title: Text(suggestion,style:TextStyle(fontSize: 12)),
                                                                  );
                                                                },
                                                                onSuggestionSelected: (suggestion) {
                                                                  setState(() {
                                                                    selectedInvoiceNo = suggestion;
                                                                    invoiceNo.text = suggestion;
                                                                    if (invoicenumberexiest(suggestion)) {
                                                                      errorMessage = '* This Invoice Already Saved';
                                                                    } else {
                                                                      errorMessage = null;
                                                                    }
                                                                  });
                                                                  print('Selected Invoice Number: $selectedInvoiceNo');
                                                                },
                                                              ),
                                                            ),
                                                          ]
                                                      ),
                                                      Divider(
                                                        color: Colors.grey.shade600,
                                                      ),
                                                      const Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Text(
                                                          "DC Number",
                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                      Align(
                                                          alignment: Alignment.topLeft,
                                                          child: Text(dcnumber.isEmpty ? "DC${DateTime.now().year % 100}${DateTime.now().month.toString().padLeft(2, '0')}/001" : dcnumber)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],)
                                  ],
                                ),
                                ),
                              ),
                            ),
                          ),
                          //table
                          SizedBox(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  width: double.infinity, // Set the width to full page width
                                  padding: EdgeInsets.all(16.0), // Add padding for spacing
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    border: Border.all(color: Colors.grey), // Add a border for the box
                                    borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Column(
                                            children: [
                                              Wrap(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left:3),
                                                      child: Align(
                                                          alignment: Alignment.topLeft,
                                                          child: Text("Customer Details",style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
                                                    ),
                                                    Wrap(children: [
                                                      Align(alignment: Alignment.topRight,
                                                        child: Text(
                                                          errorMessage ?? '',
                                                          style: TextStyle(color: Colors.red),
                                                        ),
                                                      ),
                                                    ],
                                                    ),
                                                  ]
                                              ),
                                              SizedBox(height: 15,),
                                              Padding(
                                                padding: const EdgeInsets.only(left:0,right: 0),
                                                child:   Wrap(
                                                  children: [
                                                    SizedBox(
                                                      width: 220,height: 70,
                                                      child: TextFormField(
                                                        readOnly:true,
                                                        controller: orderNo,
                                                        style: TextStyle(fontSize: 13),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            errorMessage = null; // Reset error message when user types
                                                          });
                                                        },
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Order Number",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 35,),
                                                    SizedBox(
                                                      width: 220,height: 70,
                                                      child: TextFormField(
                                                        readOnly:true,
                                                        controller: custCode,
                                                        style: TextStyle(fontSize: 13),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            errorMessage = null; // Reset error message when user types
                                                          });
                                                          String capitalizedValue = capitalizeFirstLetter(value);
                                                          custCode.value = custCode.value.copyWith(
                                                            text: capitalizedValue,
                                                            selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                          );
                                                        },
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Customer Code",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 35,),
                                                    SizedBox(
                                                      width: 220,height: 70,
                                                      child: TextFormField(
                                                        readOnly:true,
                                                        controller: custName,
                                                        style: TextStyle(fontSize: 13),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            errorMessage = null; // Reset error message when user types
                                                          });
                                                        },
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Customer/Company Name",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10,),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 35,),
                                                    SizedBox(
                                                      width: 220,height:70,
                                                      child: TextFormField(
                                                        readOnly:true,
                                                        //maxLines: 2,
                                                        controller: custAddress,
                                                        style: TextStyle(fontSize: 13),
                                                        onChanged: (value) {
                                                          String capitalizedValue = capitalizeFirstLetter(value);
                                                          custAddress.value = custAddress.value.copyWith(
                                                            text: capitalizedValue,
                                                            // selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                          );
                                                          setState(() {
                                                            errorMessage = null; // Reset error message when user types
                                                          });
                                                        },
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Customer Address",
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
                                                padding: const EdgeInsets.only(left: 35,right:0),
                                                child: Wrap(
                                                  children: [
                                                    SizedBox(
                                                      width: 220,height: 70,
                                                      child: TextFormField(
                                                        readOnly:true,
                                                        controller: pincode,
                                                        style: TextStyle(fontSize: 13),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            errorMessage = null; // Reset error message when user types
                                                          });
                                                        },

                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(6),
                                                          FilteringTextInputFormatter.digitsOnly
                                                        ],
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Pincode",
                                                          hintText: "Pincode",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 35,),

                                                    SizedBox(
                                                      width: 220,height: 70,
                                                      child: TextFormField(
                                                        readOnly:true,
                                                        controller: custMobile,
                                                        style: TextStyle(fontSize: 13),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            errorMessage = null; // Reset error message when user types
                                                          });
                                                        },

                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(10),
                                                          FilteringTextInputFormatter.digitsOnly
                                                        ],
                                                        decoration: InputDecoration(
                                                          prefixText: "+91",
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Customer Mobile",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 35,),
                                                    SizedBox(
                                                      width: 220,height: 70,
                                                      child: TextFormField(
                                                        controller: transNo,
                                                        style: TextStyle(
                                                            fontSize: 13),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            errorMessage = null; // Reset error message when user types
                                                          });
                                                        },
                                                        keyboardType: TextInputType.text,
                                                        inputFormatters: [
                                                          UpperCaseTextFormatter(),
                                                          FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                                                          LengthLimitingTextInputFormatter(10),
                                                        ],
                                                        decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            labelText: "Transport Number",
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(8,),
                                                            )
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 35,),
                                                    SizedBox(
                                                      width: 220,height:70,
                                                      child: TextFormField(
                                                        //maxLines: 2,
                                                        controller: supplyPlace,
                                                        style: TextStyle(fontSize: 13),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            errorMessage = null; // Reset error message when user types
                                                          });
                                                          String capitalizedValue = capitalizeFirstLetter(value);
                                                          supplyPlace.value = supplyPlace.value.copyWith(
                                                            text: capitalizedValue,
                                                            //selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                          );
                                                        },
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                                                          LengthLimitingTextInputFormatter(30),
                                                        ],
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          labelText: "Place of Supply",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 35,),

                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment:Alignment.topLeft,
                                            child:Padding(
                                              padding: const EdgeInsets.only(left:0),
                                              child: Text(" Product Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          Container(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                                  future: fetchUnitEntries(invoiceNo.text),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      // Your table-building logic
                                                    } else if (snapshot.hasError) {
                                                      return Text('Error: ${snapshot.error}');
                                                    } else {
                                                      return CircularProgressIndicator(); // or some loading indicator
                                                    }
                                                    if (snapshot.data!.isNotEmpty ||
                                                        snapshot.data!.isEmpty){
                                                      return Table(
                                                          border: TableBorder.all(
                                                              color: Colors.black54
                                                          ),
                                                          defaultColumnWidth: const FixedColumnWidth(605.0),
                                                          columnWidths: const <int, TableColumnWidth>{
                                                            0:FixedColumnWidth(52),
                                                            1:FixedColumnWidth(190),
                                                            2:FixedColumnWidth(190),
                                                            3:FixedColumnWidth(130),
                                                            4:FixedColumnWidth(140),
                                                            5:FixedColumnWidth(140),
                                                            6:FixedColumnWidth(140),
                                                          },
                                                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                          children:[
                                                            //Table row starting
                                                            TableRow(
                                                                children: [
                                                                  TableCell(
                                                                      child:Container(
                                                                        color:Colors.blue.shade200,
                                                                        child: Center(
                                                                          child: Column(
                                                                            children: [
                                                                              const SizedBox(height: 8,),
                                                                              Text('S.no',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                              const SizedBox(height: 8,)
                                                                            ],
                                                                          ),),
                                                                      )),
                                                                  //Meeting Name
                                                                  TableCell(
                                                                      child:Container(
                                                                        color:Colors.blue.shade200,
                                                                        child: Center(
                                                                          child: Column(
                                                                            children: [
                                                                              const SizedBox(height: 8,),
                                                                              Text('Item Group',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                              const SizedBox(height: 8,)
                                                                            ],
                                                                          ),),
                                                                      )),
                                                                  TableCell(
                                                                      child:Container(
                                                                        color:Colors.blue.shade200,
                                                                        child: Center(
                                                                          child: Column(
                                                                            children: [
                                                                              const SizedBox(height: 8,),
                                                                              Text('Item Name',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                              const SizedBox(height: 8,)
                                                                            ],
                                                                          ),),
                                                                      )),
                                                                  TableCell(
                                                                      child:Container(
                                                                        color:Colors.blue.shade200,
                                                                        child: Center(
                                                                          child: Column(
                                                                            children: [
                                                                              const SizedBox(height: 8,),
                                                                              Text('Quantity',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                              const SizedBox(height: 8,)
                                                                            ],
                                                                          ),),
                                                                      )),
                                                                  TableCell(
                                                                      child:Container(
                                                                        color:Colors.blue.shade200,
                                                                        child: Center(
                                                                          child: Column(
                                                                            children: [
                                                                              const SizedBox(height: 8,),
                                                                              Text('Rate per Unit',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                              const SizedBox(height: 8,)
                                                                            ],
                                                                          ),),
                                                                      )),
                                                                  TableCell(
                                                                      child:Container(
                                                                        color:Colors.blue.shade200,
                                                                        child: Center(
                                                                          child: Column(
                                                                            children: [
                                                                              const SizedBox(height: 8,),
                                                                              Text('GST Amount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                              const SizedBox(height: 8,)
                                                                            ],
                                                                          ),),
                                                                      )),
                                                                  TableCell(
                                                                      child:Container(
                                                                        color:Colors.blue.shade200,
                                                                        child: Center(
                                                                          child: Column(
                                                                            children: [
                                                                              const SizedBox(height: 8,),
                                                                              Text('Total',style: TextStyle(fontWeight: FontWeight.bold)),
                                                                              const SizedBox(height: 8,)
                                                                            ],
                                                                          ),),
                                                                      )),

                                                                ]),

                                                            for (var i = 0; i < snapshot.data!.length; i++) ...[
                                                              TableRow(
                                                                // decoration: BoxDecoration(color: Colors.grey[200]),
                                                                  children: [
                                                                    // 1 s.no
                                                                    TableCell(child: Center(child: Column(
                                                                      children: [
                                                                        const SizedBox(height: 10,),
                                                                        Text("${i+1}"),
                                                                        const SizedBox(height: 10,),
                                                                      ],
                                                                    )
                                                                    )
                                                                    ),
                                                                    TableCell(child: Center(child: Column(
                                                                      children: [
                                                                        const SizedBox(height: 10,),
                                                                        Text("${snapshot.data![i]["itemGroup"] ?? 'N/A'}"),
                                                                        const SizedBox(height: 10,)
                                                                      ],
                                                                    ))),
                                                                    TableCell(child: Center(child: Column(
                                                                      children: [
                                                                        const SizedBox(height: 10,),
                                                                        Text("${snapshot.data![i]["itemName"]}"),
                                                                        const SizedBox(height: 10,)
                                                                      ],
                                                                    ))),
                                                                    TableCell(child: Center(child: Column(
                                                                      children: [
                                                                        const SizedBox(height: 10,),
                                                                        Text("${snapshot.data![i]["qty"]}"),
                                                                        const SizedBox(height: 10,)
                                                                      ],
                                                                    ))),
                                                                    TableCell(child: Center(child: Column(
                                                                      children: [
                                                                        const SizedBox(height: 10,),
                                                                        Align(
                                                                            alignment:Alignment.topRight,
                                                                            child: Text("${snapshot.data![i]["rate"]}  ")),
                                                                        const SizedBox(height: 10,)
                                                                      ],
                                                                    ))),
                                                                    TableCell(child: Center(child: Column(
                                                                      children: [
                                                                        const SizedBox(height: 10,),
                                                                        Align(
                                                                            alignment:Alignment.topRight,
                                                                            child: Text("${snapshot.data![i]["amtGST"]}  ")),
                                                                        const SizedBox(height: 10,)
                                                                      ],
                                                                    ))),
                                                                    TableCell(child:Padding(
                                                                      padding: const EdgeInsets.only(left: 10),
                                                                      child:Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child:Text(
                                                                                double.tryParse(snapshot.data![i]["total"].toString())?.toStringAsFixed(2)?.padLeft(10, '') ?? '',
                                                                                textAlign: TextAlign.right,
                                                                              ),
                                                                            ),

                                                                          ]),
                                                                    )
                                                                    ),
                                                                  ]
                                                              ),
                                                            ],
                                                          ]
                                                      );}
                                                    return Container();
                                                  }
                                              ),
                                            ),
                                          ),


                                          SizedBox(height: 15,),
                                          Wrap(
                                            children: [
                                              Text(""),
                                              SizedBox(width:600),
                                              Text("Grand Total     ₹ ",style: TextStyle(fontWeight: FontWeight.bold),),
                                              SizedBox(
                                                width: 145,height: 50,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    controller: grandTotal,
                                                    style: TextStyle(fontSize: 13),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        errorMessage = null; // Reset error message when user types
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(0)),
                                                      ),
                                                    ),
                                                    textAlign: TextAlign.right,
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
                              ),),
                          ),


                          Padding(
                            padding: const EdgeInsets.all(40.0),
                            child:
                            Wrap(
                              children: [
                                MaterialButton(
                                  color: Colors.green.shade600,
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final date = selectedDate.toIso8601String();
                                      List<Map<String, dynamic>> rowsDataToInsert = [];
                                      // if (invoicenumberexiest(invoiceNo.text)) {
                                      //   setState(() {
                                      //     errorMessage = '* This Invoice Number Already Saved';
                                      //   });
                                      //   return;
                                      // }
                                      if (invoiceNo.text.isEmpty) {
                                        setState(() {
                                          errorMessage = '* Enter a Invoice Number ';
                                        });
                                      } else if(orderNo.text.isEmpty){
                                        setState(() {
                                          errorMessage = '* Enter a valid Invoice Number';
                                        });

                                      }
                                      else if (transNo.text.isEmpty) {
                                        setState(() {
                                          errorMessage = '* Enter a Transport Number';
                                        });
                                      }
                                      else if (!truckNumberPattern.hasMatch(transNo.text)) {
                                        setState(() {
                                          errorMessage = '* Enter a Valid Transport number';
                                        });
                                      }
                                      else if (supplyPlace.text.isEmpty) {
                                        setState(() {
                                          errorMessage = '* Enter a Place of supply';
                                        });
                                      }

                                      /*else if (custMobile.text.isEmpty) {
                                    setState(() {
                                      errorMessage = '* Field is mandatory';
                                    });
                                  } */ else {
                                        for (var rowDataItem in rowData) {
                                          DateTime now=DateTime.now();
                                          String year=(now.year%100).toString();
                                          String month=now.month.toString().padLeft(2,'0');
                                          if (dcnumber.isEmpty) {
                                            dcnumber = 'DC$year$month/001';
                                          }
                                          Map<String, dynamic> dataToInsert = {
                                            'dcNo': dcnumber,
                                            "invoiceNo": invoiceNo.text,
                                            'date': eod.toString(),
                                            'orderNo': orderNo.text,
                                            'custCode': custCode.text,
                                            'custName': custName.text,
                                            'custMobile': custMobile.text,
                                            'custAddress': custAddress.text,
                                            'pincode': pincode.text,
                                            "supplyPlace": supplyPlace.text,
                                            "transNo": transNo.text,
                                            "grandTotal": grandTotal.text,
                                          };
                                          rowsDataToInsert.add(dataToInsert);
                                        }
                                        try {
                                          await insertData(rowsDataToInsert);
                                          setState(() {
                                            currentDcNumber++;
                                            isDataSaved = true;
                                          });

                                          // Show success message in an alert dialog
                                          // showDialog(
                                          //   barrierDismissible: false,
                                          //   context: context,
                                          //   builder: (BuildContext context) {
                                          //     return AlertDialog(
                                          //       title: Text("Delivery Challan"),
                                          //       content: Padding(
                                          //         padding: const EdgeInsets.only(top:20.0),
                                          //         child: Text('Saved Successfully'),
                                          //       ),
                                          //       actions: <Widget>[
                                          //         TextButton(
                                          //           child: const Text('OK'),
                                          //           onPressed: () {
                                          //             Navigator.push(context,
                                          //                 MaterialPageRoute(builder: (context) =>Dc()));// Close the alert box
                                          //           },
                                          //         ),
                                          //       ],
                                          //     );
                                          //   },
                                          // );
                                        } catch (e) {
                                          print('Error inserting data: $e');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Failed to save data. Please try again."),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: Text("SAVE", style: TextStyle(color: Colors.white)),
                                ),

                                SizedBox(width: 20,),
                                MaterialButton(
                                  color: Colors.blue.shade600,
                                  onPressed: () {
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
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=> Dc()));
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('No'),
                                              onPressed: () {
                                                Navigator.pop(context); // Close the alert box
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text("RESET",style: TextStyle(color: Colors.white),),),
                                SizedBox(width: 20,),
                                MaterialButton(
                                  color: Colors.red.shade600,
                                  onPressed: (){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirmation'),
                                          content: const Text('Do you want to cancel?'),
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
                                  },
                                  child: Text("CANCEL",style: TextStyle(color: Colors.white),),)
                              ],
                            ),
                          ),
                        ]),

                  ),
                ),
              ),
            )

    ) ;
  }

}


String _getKeyForColumn(int columnIndex) {
  switch (columnIndex) {
    case 0:
      return 'itemGroup';
    case 1:
      return 'itemName';
    case 2:
      return 'qty';
    case 3:
      return 'total';
    default:
      return '';
  }
}
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

