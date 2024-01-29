
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinayaga_project/main.dart';
import '../home.dart';
import 'package:http/http.dart' as http;
import '../purchase/customer_order_edit.dart';
import 'dc_entry_pdf.dart';
import 'handbill_dc_entry_pdf.dart';


class RowData {
  String? itemGroup;
  String? itemName;
  TextEditingController qtyController = TextEditingController();
  TextEditingController rateperunit = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController gstamnt = TextEditingController();
  TextEditingController totalamnt = TextEditingController();
  RowData({this.itemGroup, this.itemName});
}


class SampleDC extends StatefulWidget {
  const SampleDC ({Key? key}) : super(key: key);
  @override
  State<SampleDC> createState() => _PurchaseState();
}





class _PurchaseState extends State<SampleDC> {
  final _formKey = GlobalKey<FormState>();


  TextEditingController SampleDCNo = TextEditingController();
  TextEditingController invoiceNo = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController custCode= TextEditingController();
  TextEditingController custName= TextEditingController();
  TextEditingController custAddress = TextEditingController();
  TextEditingController pincode=TextEditingController();
  TextEditingController custMobile = TextEditingController();
  TextEditingController orderNo = TextEditingController();
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

  List<Map<String, dynamic>> filtereSampleDCodeData = [];
  var totalValues = 0;
  int currentSampleDCNumber = 1;
  String? errorMessage="";
  String? deliveryType;
  String? newCode;
  bool showInitialData = true;
  bool isDataSaved = false;
  String itemGroup = '';
  String itemName = '';
  String quantity = '';
  String selectedInvoiceNo="";
  String? selectedCustomer="";
  RegExp truckNumberPattern = RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{1,2}\d{1,4}$');
  final ScrollController _scrollController = ScrollController();

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }


  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    // Use the key "SampleDCNo" to access the value of the "SampleDCNo" column.
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

  Future<void> getitem() async {
    try {
      final url = Uri.parse('http://localhost:3309/getitemGroup/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> tempItemGroup = responseData;
        final Set<String> uniqueItemGroups =
        tempItemGroup.map((item) => item['itemGroup'] as String).toSet();
        itemGroups = uniqueItemGroups.toList();
        itemGroups.sort();

        setState(() {
          print('Item Groups: $itemGroups');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getitemname() async {
    try {
      final url = Uri.parse('http://localhost:3309/getitemname/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> tempItemName = responseData;
        final Set<String> uniqueItemNames =
        tempItemName.map((item) => item['itemName'] as String).toSet();
        itemNames = uniqueItemNames.toList();
        itemNames.sort();

        setState(() {
          print('Item Groups: $itemNames');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }



//sales item
  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/SampleDC_entries?invoiceNo=$invNo'));
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
    getitemname();
    getitem();
    SampleDCnumfetch();
    fetchData();
    fetchcustData();
    fetchData3();
    filterCodeData(custName.text);
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_invoiceFocusNode);
    });
  }
  final FocusNode _invoiceFocusNode = FocusNode();

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
    });
  }



















  List<RowData> rowData = [];
  List<String> itemGroups = [];
  List<String> itemNames = [];
  String? item;
  String? itemname;

  List<String?> selectedItemNames = [];
  List<String?> selectedItemGroups = [];
  DateTime eod = DateTime.now();






  void addRow() {
    setState(() {
      rowData.add(RowData());
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


  void deleteRow(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this row?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
                setState(() {
                  if (rowData.length == 1)  {
                    // If it's the first row, clear input values instead of removing it
                    rowData[index].itemGroup = null;
                    rowData[index].itemName = null;
                    rowData[index].qtyController.text = "";
                  } else {
                    // Remove the row from the list for other rows
                    rowData.removeAt(index);
                  }
                });
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }


/*
  Map<String, dynamic> dataToInsert = {};
  Future<void> insertData(List<Map<String, dynamic>> rowsDataToInsert) async {
    const String apiUrl = 'http://localhost:3309/handbill_DC';
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
                title: Text('SampleDC'),
                content: Text('Save Successfully'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SampleDC()),
                      );
                    },
                    child: Text('OK'),
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
*/





  List<Map<String, dynamic>> dcnumdata = [];
  String? DCNO;

  Future<void> SampleDCnumfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/gethand_billdcno'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          DCNO = getNameFromJsonData(item);
          print('SampleDCNo: $DCNO');
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

  Future<void> fetchcustData() async {
    try {
      final url = Uri.parse('http://localhost:3309/custdetail/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          codedata = itemGroups.cast<Map<String, dynamic>>();
        });
        print('codeData: $codedata');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }
  void filterCodeData(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = codedata;
        // readOnlyFields = false;
        custCode.clear();
        custAddress.clear();
        custMobile.clear();
        pincode.clear();
        GSTIN.clear();
      } else {
        final existingSupplier = codedata.firstWhere(
              (item) => item['custName']?.toString() == searchText,
          orElse: () => {}, // Use an empty map literal as the default value
        );
        if (existingSupplier.isNotEmpty) {
          // Supplier found, populate fields
          //readOnlyFields = true;
          custCode.text = existingSupplier['custCode']?.toString() ?? '';
          custAddress.text = existingSupplier['custAddress']?.toString() ?? '';
          custMobile.text = existingSupplier['custMobile']?.toString() ?? '';
          pincode.text = existingSupplier['custMobile']?.toString() ?? '';
          GSTIN.text = existingSupplier['gstin']?.toString() ?? '';
        } else {
          // readOnlyFields = false;
          int maxCodeNumber = 0;
          for (var item in codedata) {
            final supCodeStr = item['custCode']?.toString() ?? '';
            if (supCodeStr.startsWith('C') && supCodeStr.length == 4) {
              final codeNumber = int.tryParse(supCodeStr.substring(1));
              if (codeNumber != null && codeNumber > maxCodeNumber) {
                maxCodeNumber = codeNumber;
              }
            }
          }
          final newCode = 'C${(maxCodeNumber + 1).toString().padLeft(3, '0')}';
          custCode.text = newCode;
          custAddress.clear();
          custMobile.clear();
          pincode.clear();
        }
      }
    });
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


  Future<void> insertDataorderitem(Map<String, dynamic> dataToInsertorditem) async {
    const String apiUrl = 'http://localhost:3309/handbill_DC'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertorditem': dataToInsertorditem}),
      );
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Hand Bill DC"),
              content: Text("Saved Succesfully"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SampleDC()));
                  },
                  child: Text("OK"),
                ),
                TextButton(
                  onPressed: () {
                    print(dcnumber);
                    Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => HandbilldcIndividualPDFView(
                          dcNo: dcnumber,
                          date: eod.toString(),
                          custCode:custCode.text,
                          invNo: invoiceNo.text,
                          custName:custName.text,
                          custMobile:custMobile.text,
                          custAddress:custAddress.text,
                          pincode:pincode.text,
                          supplyPlace:supplyPlace.text,
                          grandTotal:grandTotal.text,
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

        print('daily work status data insert successfully');

      } else {
        print('Failed to insert data');
        throw Exception('Failed to insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> submititemDataToDatabase() async {
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < rowData.length; i++) {
      Map<String, dynamic> dataToInsertorditem = {
        'dcNo': dcnumber,
        "invoiceNo": invoiceNo.text,
        'date': eod.toString(),
        'orderNo': orderNo.text,
        'custName': custName.text,
        'custMobile': custMobile.text,
        'custAddress': custAddress.text,
        'pincode': pincode.text,
        "supplyPlace": supplyPlace.text,
        "transNo": transNo.text,
        'itemGroup':rowData[i].itemGroup,
        'itemName':rowData[i].itemName,
        'qty':rowData[i].qtyController.text,
        'rateperunit':rowData[i].rateperunit.text,
        'amount':rowData[i].amount.text,
        'gstAmnt':rowData[i].gstamnt.text,
        'totalAmnt':rowData[i].totalamnt.text,
        "grandTotal": grandTotal.text,
      };
      insertFutures.add(insertDataorderitem(dataToInsertorditem));
    }
    try {

      await Future.wait(insertFutures);
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  void updateTotalAmount(int i) {
    double amount = double.tryParse(rowData[i].amount.text) ?? 0;
    double gstamnt = double.tryParse(rowData[i].gstamnt.text) ?? 0;
    double totalamnt = amount + gstamnt;

    // Update the total amount controller
    rowData[i].totalamnt.text = totalamnt.toString();
  }

  double grandTotalvalue = 0.0;

// Assuming you have a TextEditingController for grandTotal
  TextEditingController grandTotalController = TextEditingController();

// Iterate through rowData to calculate grandTotal
  void updateGrandTotal() {
    grandTotalvalue = 0.0;
    for (int i = 0; i < rowData.length; i++) {
      double totalamnt = double.tryParse(rowData[i].totalamnt.text) ?? 0;
      grandTotalvalue += totalamnt;
    }
    // Update the grandTotalController with the new value
    grandTotal.text = grandTotalvalue.toString();
  }


  Future<void> updatefinishingprodution( String qty, String itemGroup,String itemName) async {
    final Uri url = Uri.parse('http://localhost:3309/sc_to_update_Stock'); // Replace with your actual backend URL
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'qty': qty,
        'itemGroup': itemGroup,
        'itemName':itemName,
      }),
    );
    if (response.statusCode == 200) {
      print('Update finishing production successfully');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
      throw Exception('Failed to finisghing update');
    }
  }


  @override
  Widget build(BuildContext context) {
    invoiceNo.addListener(() {
      filterData(invoiceNo.text);
    });
    custName.addListener(() {
      filterCodeData(custName.text);
    });
    invoiceNo.addListener(() {
      filterData3(invoiceNo.text);
    });

    final selectedDate = DateTime.now();
    return Builder(
        builder: (context) =>
            MyScaffold(
              route: "sampledc",backgroundColor: Colors.white,
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
                                            const Text(" Hand Bill DC Entry ", style: TextStyle(
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
                                                              firstDate: DateTime(2000),
                                                              // Set the range of selectable dates
                                                              lastDate: eod,
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
                                                      SizedBox(height: 3,),
                                                      Wrap(
                                                          children:[
                                                            SizedBox(
                                                              width: 220,
                                                              child: TextFormField(
                                                                controller: invoiceNo,
                                                                focusNode: _invoiceFocusNode,
                                                                style: TextStyle(fontSize: 13),
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    errorMessage = null; // Reset error message when user types
                                                                  });
                                                                },
                                                                inputFormatters: [
                                                                  UpperCaseTextFormatter(),
                                                                  LengthLimitingTextInputFormatter(10)
                                                                ],
                                                                decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  labelText: "Invoice Number",
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                  ),
                                                                ),
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
                                              Wrap(
                                                children: [
                                                  SizedBox(
                                                    width: 220,height: 70,
                                                    child: TextFormField(
                                                      controller: orderNo,
                                                      style: TextStyle(fontSize: 13),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          errorMessage = null; // Reset error message when user types
                                                        });
                                                      },
                                                      inputFormatters: [
                                                        UpperCaseTextFormatter(),
                                                        LengthLimitingTextInputFormatter(10)
                                                      ],
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
                                                    width: 220,
                                                    height:50,
                                                    child: TypeAheadFormField<String>(
                                                      textFieldConfiguration: TextFieldConfiguration(
                                                        controller: custName,
                                                        onChanged: (value) {
                                                          String capitalizedValue = capitalizeFirstLetter(value);
                                                          custName.value = custName.value.copyWith(
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
                                                          labelText: "Customer/Company Name",
                                                          labelStyle: TextStyle(fontSize: 13,color: Colors.black),
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                      suggestionsCallback: (pattern) async {
                                                        if (pattern.isEmpty) {
                                                          return [];
                                                        }
                                                        List<String> suggestions = codedata
                                                            .where((item) =>
                                                        (item['custName']?.toString()?.toLowerCase() ?? '').contains(pattern.toLowerCase()) ||
                                                            (item['custCode']?.toString()?.toLowerCase() ?? '').contains(pattern.toLowerCase()))
                                                            .map((item) => item['custName'].toString())
                                                            .toSet()
                                                            .toList();
                                                        return suggestions;
                                                      },
                                                      itemBuilder: (context, suggestion) {
                                                        Map<String, dynamic> customerData = codedata.firstWhere(
                                                              (item) => item['custName'].toString() == suggestion,
                                                          orElse: () => Map<String, dynamic>(),
                                                        );
                                                        return ListTile(
                                                          title: Text('${customerData['custName']} (${customerData['custCode']})'),
                                                        );
                                                      },
                                                      onSuggestionSelected: (suggestion) {
                                                        Map<String, dynamic> customerData = codedata.firstWhere(
                                                              (item) => item['custName'].toString() == suggestion,
                                                          orElse: () => Map<String, dynamic>(),
                                                        );
                                                        setState(() {
                                                          selectedCustomer = suggestion;
                                                          custName.text = suggestion;
                                                        });
                                                        print('Selected Customer: $selectedCustomer, Customer Code: ${customerData['custCode']}');
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 35,),
                                                  SizedBox(
                                                    width: 220,height:70,
                                                    child: TextFormField(
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
                                                  SizedBox(width: 35,),
                                                  SizedBox(
                                                    width: 220,height: 70,
                                                    child: TextFormField(
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
                                                ],
                                              ),
                                              Wrap(
                                                children: [
                                                  SizedBox(
                                                    width: 220,height: 70,
                                                    child: TextFormField(
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
                                                  SizedBox(
                                                      width: 220,height:70,
                                                      child: Text("")),
                                                  //SizedBox(width: 35,),
                                                ],
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
                                          SingleChildScrollView(
                                            child: Scrollbar(
                                              thumbVisibility: true,
                                              controller: _scrollController,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                controller: _scrollController,
                                                child: FocusTraversalGroup(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 0),
                                                    child: Table(
                                                      border: TableBorder.all(color: Colors.black54),
                                                      defaultColumnWidth: const FixedColumnWidth(240.0),
                                                      columnWidths: const <int, TableColumnWidth>{
                                                        0: FixedColumnWidth(200),
                                                        1: FixedColumnWidth(200),
                                                        2: FixedColumnWidth(100),
                                                        3: FixedColumnWidth(100),
                                                        4: FixedColumnWidth(150),
                                                        5: FixedColumnWidth(150),
                                                        6: FixedColumnWidth(150),
                                                        7: FixedColumnWidth(150),
                                                      },
                                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                      children: [
                                                        TableRow(children: [
                                                          TableCell(
                                                            child: Container(
                                                              color: Colors.blue.shade100,
                                                              child: Center(
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(height: 10),
                                                                      Text('Item Group', style: TextStyle(fontWeight: FontWeight.bold)),
                                                                      SizedBox(height: 10),
                                                                    ],
                                                                  )),
                                                            ),
                                                          ),
                                                          TableCell(
                                                            child: Container(
                                                              color: Colors.blue.shade100,
                                                              child: Center(child: Column(
                                                                children: [
                                                                  SizedBox(height: 10),
                                                                  Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  SizedBox(height: 10),
                                                                ],
                                                              )),
                                                            ),
                                                          ),
                                                          TableCell(
                                                            child: Container(
                                                              color: Colors.blue.shade100,
                                                              child: Center(child: Column(
                                                                children: [
                                                                  SizedBox(height: 10),
                                                                  Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  SizedBox(height: 10),
                                                                ],
                                                              )),
                                                            ),
                                                          ),
                                                          TableCell(
                                                            child: Container(
                                                              color: Colors.blue.shade100,
                                                              child: Center(child: Column(
                                                                children: [
                                                                  SizedBox(height: 10),
                                                                  Text('Rate per unit', style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  SizedBox(height: 10),
                                                                ],
                                                              )),
                                                            ),
                                                          ),
                                                          TableCell(
                                                            child: Container(
                                                              color: Colors.blue.shade100,
                                                              child: Center(child: Column(
                                                                children: [
                                                                  SizedBox(height: 10),
                                                                  Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  SizedBox(height: 10),
                                                                ],
                                                              )),
                                                            ),
                                                          ),
                                                          TableCell(
                                                            child: Container(
                                                              color: Colors.blue.shade100,
                                                              child: Center(child: Column(
                                                                children: [
                                                                  SizedBox(height: 10),
                                                                  Text('GST Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  SizedBox(height: 10),
                                                                ],
                                                              )),
                                                            ),
                                                          ),
                                                          TableCell(
                                                            child: Container(
                                                              color: Colors.blue.shade100,
                                                              child: Center(child: Column(
                                                                children: [
                                                                  SizedBox(height: 10),
                                                                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  SizedBox(height: 10),
                                                                ],
                                                              )),
                                                            ),
                                                          ),
                                                          TableCell(
                                                            child: Container(
                                                              color: Colors.blue.shade100,
                                                              child: Center(
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(height: 10),
                                                                    Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                                                    SizedBox(height: 10),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),

                                                        for (var i = 0; i < rowData.length; i++)
                                                          TableRow(children: [

                                                            TableCell(
                                                              child: SizedBox(
                                                                height: 60,
                                                                child: Container(
                                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                                  color: Colors.blue.shade100,
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(5.0),
                                                                      child: TypeAheadFormField<String?>(
                                                                        textFieldConfiguration: TextFieldConfiguration(
                                                                          onChanged: (value){
                                                                          },
                                                                          controller: TextEditingController(text: rowData[i].itemGroup),
                                                                          decoration: InputDecoration(
                                                                            filled: true,
                                                                            fillColor: Colors.white,
                                                                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                                                          ),
                                                                          inputFormatters: [CapitalizeInputFormatter()],
                                                                        ),
                                                                        suggestionsCallback: (pattern) async {
                                                                          return itemGroups.where((group) => group.toLowerCase().startsWith(pattern.toLowerCase()));
                                                                        },
                                                                        itemBuilder: (context, suggestion) {
                                                                          return ListTile(
                                                                            title: Text(suggestion!),
                                                                          );
                                                                        },
                                                                        onSuggestionSelected: (String? suggestion) async {
                                                                          if (itemGroups.contains(suggestion)) {
                                                                            setState(() {
                                                                              rowData[i].itemGroup = suggestion;
                                                                              rowData[i].itemName = null;
                                                                            });
                                                                          } else {
                                                                            // Clear the itemGroup field if the suggestion is not in the itemGroups list
                                                                            setState(() {
                                                                              rowData[i].itemGroup = null;
                                                                            });
                                                                            // Show an error messag
                                                                          }
                                                                        },
                                                                      )

                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            TableCell(
                                                              child: SingleChildScrollView(
                                                                child: Container(
                                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                                  height: 60,
                                                                  color: Colors.blue.shade100,
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(5.0),
                                                                    child: TypeAheadFormField<String?>(
                                                                      textFieldConfiguration: TextFieldConfiguration(
                                                                        controller: TextEditingController(text: rowData[i].itemName),
                                                                        decoration: InputDecoration(
                                                                          filled: true,
                                                                          fillColor: Colors.white,
                                                                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                                                        ),
                                                                        inputFormatters: [CapitalizeInputFormatter()],
                                                                      ),
                                                                      suggestionsCallback: (pattern) async {
                                                                        return itemNames.where((name) => name.toLowerCase().startsWith(pattern.toLowerCase()));
                                                                      },
                                                                      itemBuilder: (context, suggestion) {
                                                                        return ListTile(
                                                                          title: Text(suggestion!),
                                                                        );
                                                                      },
                                                                      onSuggestionSelected: (String? suggestion) async {
                                                                        setState(() {
                                                                          print('Selected Item: $suggestion');
                                                                          rowData[i].itemName = suggestion;
                                                                          rowData[i].qtyController.text = "";
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            TableCell(
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                                height: 60,
                                                                color: Colors.blue.shade100,
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(5.0),
                                                                  child: TextFormField(
                                                                    controller: rowData[i].qtyController,
                                                                    keyboardType: TextInputType.number,
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                      });
                                                                    },
                                                                    inputFormatters: <TextInputFormatter>[
                                                                      FilteringTextInputFormatter.digitsOnly,
                                                                      LengthLimitingTextInputFormatter(3)
                                                                    ],
                                                                    decoration: const InputDecoration(
                                                                      filled: true,
                                                                      fillColor: Colors.white,
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(color: Colors.grey),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            TableCell(
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                                height: 60,
                                                                color: Colors.blue.shade100,
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(5.0),
                                                                  child: TextFormField(
                                                                    controller: rowData[i].rateperunit,
                                                                    keyboardType: TextInputType.number,
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                      });
                                                                    },
                                                                    inputFormatters: <TextInputFormatter>[
                                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                                                      // This regex allows digits and an optional decimal point with up to two decimal places
                                                                      LengthLimitingTextInputFormatter(5), // Adjust the limit as needed
                                                                    ],
                                                                    decoration: const InputDecoration(
                                                                      filled: true,
                                                                      fillColor: Colors.white,
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(color: Colors.grey),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            TableCell(
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                                height: 60,
                                                                color: Colors.blue.shade100,
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(5.0),
                                                                  child: TextFormField(
                                                                    controller: rowData[i].amount,
                                                                    keyboardType: TextInputType.number,
                                                                    onChanged: (value) {
                                                                      updateTotalAmount(i);
                                                                      updateGrandTotal();
                                                                      setState(() {
                                                                      });
                                                                    },
                                                                    inputFormatters: <TextInputFormatter>[
                                                                      FilteringTextInputFormatter.digitsOnly,
                                                                      LengthLimitingTextInputFormatter(5)
                                                                    ],
                                                                    decoration: const InputDecoration(
                                                                      filled: true,
                                                                      fillColor: Colors.white,
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(color: Colors.grey),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            TableCell(
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                                height: 60,
                                                                color: Colors.blue.shade100,
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(5.0),
                                                                  child: TextFormField(
                                                                    controller: rowData[i].gstamnt,
                                                                    keyboardType: TextInputType.number,
                                                                    onChanged: (value) {
                                                                      updateTotalAmount(i);
                                                                      updateGrandTotal();
                                                                      setState(() {
                                                                      });
                                                                    },
                                                                    inputFormatters: <TextInputFormatter>[
                                                                      FilteringTextInputFormatter.digitsOnly,
                                                                      LengthLimitingTextInputFormatter(5)
                                                                    ],
                                                                    decoration: const InputDecoration(
                                                                      filled: true,
                                                                      fillColor: Colors.white,
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(color: Colors.grey),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            TableCell(
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                                height: 60,
                                                                color: Colors.blue.shade100,
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(5.0),
                                                                  child: TextFormField(
                                                                    readOnly: true,
                                                                    controller: rowData[i].totalamnt,
                                                                    keyboardType: TextInputType.number,
                                                                    onChanged: (value) {
                                                                      updateGrandTotal();
                                                                      setState(() {
                                                                      });
                                                                    },
                                                                    decoration: const InputDecoration(
                                                                      filled: true,
                                                                      fillColor: Colors.white,
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(color: Colors.grey),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            TableCell(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Visibility(
                                                                      visible: true,
                                                                      child: IconButton(
                                                                        icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                                                                        onPressed:  () => deleteRow(i) ,
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                        visible: i == rowData.length - 1 &&
                                                                            rowData[i].itemGroup != null &&
                                                                            rowData[i].itemName != null &&
                                                                            rowData[i].qtyController.text.isNotEmpty,
                                                                        child: IconButton(
                                                                          icon: Icon(Icons.add_circle_outline, color: Colors.green),
                                                                          onPressed: () {
                                                                            bool isDuplicate = false;

                                                                            // Iterate through all previous rows
                                                                            for (int j = 0; j < i; j++) {
                                                                              if (rowData[i].itemGroup == rowData[j].itemGroup &&
                                                                                  rowData[i].itemName == rowData[j].itemName) {
                                                                                isDuplicate = true;
                                                                                break; // Break the loop if a duplicate is found
                                                                              }
                                                                            }

                                                                            if (isDuplicate) {
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                    title: Text('Alert'),
                                                                                    content: Text('Already Exist the Products'),
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
                                                                            } else {
                                                                              // Check if the quantity is 0
                                                                              if (rowData[i].qtyController.text == '0') {
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return AlertDialog(
                                                                                      title: Text('Alert'),
                                                                                      content: Text('Quantity cannot be 0'),
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
                                                                              } else {
                                                                                // Quantity is not 0, add the row
                                                                                addRow();
                                                                                if (i == 0) {
                                                                                  // Enable the first row removal once a second row is added
                                                                                  setState(() {
                                                                                    // isFirstRowRemovalEnabled = true;
                                                                                  });
                                                                                }
                                                                              }
                                                                            }
                                                                          },
                                                                        )


                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          ]
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 15,),
                                          Wrap(
                                            children: [
                                              Text(""),
                                              SizedBox(width:600,height: 30,),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10.0),
                                                child: Text("Grand Total     ₹ ",style: TextStyle(fontWeight: FontWeight.bold),),
                                              ),
                                              SizedBox(
                                                width: 145,height: 50,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: TextFormField(
                                                    controller: grandTotal,
                                                    style: TextStyle(fontSize: 13),
                                                    onChanged: (value) {
                                                      updateGrandTotal();
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
                                      if (invoiceNo.text.isEmpty) {
                                        setState(() {
                                          errorMessage = '* Enter a Invoice Number ';
                                        });
                                      } else if(custName.text.isEmpty){
                                        setState(() {
                                          errorMessage = '* Enter a Customer/Company Name';
                                        });
                                      }
                                      else if(custMobile.text.isEmpty){
                                        setState(() {
                                          errorMessage = '* Enter a Customer Mobile Number ';
                                        });
                                      }
                                      else if(custMobile.text.length != 10){
                                        setState(() {
                                          errorMessage = '* Enter a Valid Mobile Number ';
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
                                      else {
                                        DateTime now=DateTime.now();
                                        String year=(now.year%100).toString();
                                        String month=now.month.toString().padLeft(2,'0');
                                        if (dcnumber.isEmpty) {
                                          dcnumber = 'DC$year$month/001';
                                        }
                                        submititemDataToDatabase();
                                        try {
                                          // await insertData(rowsDataToInsert);
                                          setState(() {
                                            currentSampleDCNumber++;
                                            isDataSaved = true;
                                          });
                                        } catch (e) {
                                          print('Error inserting data: $e');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Failed to save data. Please try again."),
                                            ),
                                          );
                                        }
                                      }
                                      //   }
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
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=> SampleDC()));
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

