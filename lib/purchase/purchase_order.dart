import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinayaga_project/main.dart';
import '../home.dart';
import 'customer_order_edit.dart';

class RowData {
  String? itemGroup;
  String? itemName;
  String? size;
  String? color;
  List<String> itemNames = [];
  List<String> itemSizes = [];
  List<String> itemColors = [];
  int? quantity;
  int? totalQty;
  int? callUnit;
  TextEditingController qtyController = TextEditingController();
  TextEditingController totalQtyController = TextEditingController();
  RowData({this.itemGroup, this.itemName, this.size, this.color,this.quantity,this.totalQty,this.callUnit});
}

class Purchaseorder extends StatefulWidget {
  const Purchaseorder({Key? key}) : super(key: key);
  @override
  State<Purchaseorder> createState() => _PurchaseorderState();
}
class _PurchaseorderState extends State<Purchaseorder> {
  final _formKey = GlobalKey<FormState>();
  final  selectedDate = DateTime.now();
  DateTime warrantydate = DateTime.now();
  DateTime date = DateTime.now();
  DateTime pickDate = DateTime.now();
  TextEditingController customerCode = TextEditingController();
  TextEditingController customerName = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController paymentType = TextEditingController();
  TextEditingController orderNumber  = TextEditingController();
  TextEditingController grandTotal = TextEditingController();
  TextEditingController  gst= TextEditingController();
  TextEditingController orderNo = TextEditingController();
  TextEditingController custCode = TextEditingController();
  TextEditingController custName = TextEditingController();
  TextEditingController custMobile = TextEditingController();
  TextEditingController custAddress = TextEditingController();
  TextEditingController pincode=TextEditingController();
  TextEditingController GSTIN = TextEditingController();
  TextEditingController saleorderdate = TextEditingController();
  RegExp pincodeRegex = RegExp(r'^[0-9]{6}$');
  bool checkName = false;
  String selectedInvoiceNo="";
  final FocusNode custCodeFocusNode = FocusNode();
  String? selectedCustomer="";
  TextEditingController deliveryDate = TextEditingController();
  String? deliveryType;
  bool dropdownValid1 = true;
  static final RegExp gstregex2 = RegExp(r"^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d{1}[Z]{1}[A-Z\d]{1}$");
  bool isFirstRowRemovalEnabled = false;
  DateTime? deliverydate;
  int selectedCheckbox = 1;

  void validateDropdown() {
    setState(() {
      dropdownValid1 = deliveryType != "Delivery Type";
    });
  }

  String? errorMessage="";

  bool checkbox1Value = false;
  bool checkbox2Value = false;
  bool isDataSaved = false;
  String? errorMsgDateandOredeNO;
  RegExp truckNumberPattern = RegExp(r'^([A-Z0-9]{2}\s?[A-Z0-9]{2}\s?[A-Z]{1,2}\s?\d{1,4})\s?$');
  String? payType;
  bool orderNumberExists = false;
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }



  Future<List<dynamic>> fetchSizeData() async {
    const String apiUrl = 'http://localhost:3309/customerdetails/'; // Replace with your server details
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> sizeData = jsonDecode(response.body);
        return sizeData;
      } else {
        print('Failed to fetch data');
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }



  Future<bool> checkForDuplicate(String size) async {
    List<dynamic> sizeData = await fetchSizeData();
    for (var item in sizeData) {
      if (item['custCode'] == size) {
        return true; // Size already exists, return true
      }
    }
    return false; // Size is unique, return false
  }


  Map<String, dynamic> dataToInsert = {};
  Future<void> insertData(Map<String, dynamic> rowsDataToInsert) async  {
    const String apiUrl = 'http://localhost:3309/purchaseorder_entry';
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
  Map<String, dynamic> dataToInsertcustomer = {};



  Future<void> insertDatacustomer(Map<String, dynamic> dataToInsertcustomer) async {
    const String apiUrl = 'http://localhost:3309/customer_entry'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertcustomer': dataToInsertcustomer}),
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

  Future<void> customerDataToDatabase() async {
    List<Future<void>> insertFutures = [];
    Map<String, dynamic> dataToInsertcustomer = {
      "custCode":custCode.text,
      "custName":custName.text,
      "custAddress":custAddress.text,
      "pincode":pincode.text,
      "custMobile":custMobile.text,
      "gstin":GSTIN.text,
      "date":date.toString(),
    };
    insertFutures.add(insertDatacustomer(dataToInsertcustomer));
    await Future.wait(insertFutures);
  }
  Map<String, dynamic> dataToInsertorditem = {};


  Future<void> insertDataorderitem(Map<String, dynamic> dataToInsertorditem) async {
    const String apiUrl = 'http://localhost:3309/purchaseitem_entry'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertorditem': dataToInsertorditem}),
      );
      if (response.statusCode == 200) {
        print('TableData inserted successfully');
      } else {
        print('Failed to insert data into the table');
        throw Exception('Failed to insert data into the table');
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
        'orderNo': orderNo.text,
        'itemGroup':rowData[i].itemGroup,
        'itemName':rowData[i].itemName,
        'color':rowData[i].color,
        'size':rowData[i].size,
        'qty': rowData[i].qtyController.text,
        'date': date.toString(),
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

  FocusNode _searchFocus = FocusNode();
  List<Map<String, dynamic>> codedata = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> filteredorderData = [];
  List<Map<String, dynamic>> orderdata = [];
  bool readOnlyFields = false;


  Future<void> fetchData() async {
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
        readOnlyFields = false;
        custCode.clear();
        custAddress.clear();
        custMobile.clear();
        GSTIN.clear();
      } else {
        final existingSupplier = codedata.firstWhere(
              (item) => item['custName']?.toString() == searchText,
          orElse: () => {}, // Use an empty map literal as the default value
        );
        if (existingSupplier.isNotEmpty) {
          // Supplier found, populate fields
          readOnlyFields = true;
          custCode.text = existingSupplier['custCode']?.toString() ?? '';
          custAddress.text = existingSupplier['custAddress']?.toString() ?? '';
          custMobile.text = existingSupplier['custMobile']?.toString() ?? '';
          GSTIN.text = existingSupplier['gstin']?.toString() ?? '';
        } else {
          readOnlyFields = false;
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
          GSTIN.clear();
        }
      }
    });
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





  List<RowData> rowData = [];
  List<String> itemGroups = [];
  List<String> itemNames = [];
  Future<void> fetchitemnameData() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_unit_by_iG_iN/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          rowData = List.generate(responseData.length, (index) => RowData());
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }



  Future<void> getitemsizes(String itemGroup, String itemName, int index) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_size_by_iG_iN?itemGroup=$itemGroup&&itemName=$itemName');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;
        final Set<String> uniqueItemSizes =
        units.map((item) => item['size'] as String).toSet();
        setState(() {
          rowData[index].itemSizes = uniqueItemSizes.toList();
          rowData[index].size = null;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getitemcolor(String itemGroup, String itemName, String size, int index) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_color_by_iG_iN?itemGroup=$itemGroup&&itemName=$itemName&&size=$size');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;
        final Set<String> uniqueItemColor =
        units.map((item) => item['color'] as String).toSet();
        setState(() {
          rowData[index].itemColors = uniqueItemColor.toList();
          rowData[index].color = null;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }



  int callUnit =0;
  Future<void> filterUnitData(String itemGroup, String itemName,) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_unit_by_iG_iN?itemGroup=$itemGroup&itemName=$itemName');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final unit = responseData['unit'];
        print('Unit in filterUnitData: $unit');
        setState(() {
          callUnit=unit;
          print('Unit: $unit');
          print('Unit---------------------------------------------------------------------------------------------: $unit');
          print('CallUnit:$callUnit');
        });
        callUnit=unit;
        print('Unit: $unit');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }




  void addRow() {
    setState(() {
      rowData.add(RowData());
    });
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



  void calculateTotalQty(int index) {
    if (callUnit != null && rowData[index].quantity != null) {
      int totalQty = callUnit! * rowData[index].quantity!;
      // Update the total quantity in the rowData
      setState(() {
        rowData[index].totalQty = totalQty;
        // Update the totalQtyController text
        rowData[index].totalQtyController.text = totalQty.toString();
      });
    }
  }


  List<Map<String, dynamic>> data = [];
  bool showInitialData = true;
  List<Map<String, dynamic>> filtered = [];


  Future<void> fetchorderNo() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/checkorderNo'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        jsonData.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['date']);
          final DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA);
        });
        setState(() {
          data = jsonData.cast<Map<String, dynamic>>();
        });
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Alert"),
              content: Text("Invoice Generated"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Purchaseorder()));
                  },
                  child: Text("OK"),
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

  bool isOrderNumExists(String name) {
    return data.any((item) => item['orderNo'].toString().toLowerCase() == name.toLowerCase());
  }

  void filterData(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filtered = data.where((item) {
          final custName = item[''].toString().toLowerCase();
          return custName.contains(query.toLowerCase());
        }).toList();
      } else {
        filteredData = List.from(data);
      }
    });
  }


  int currentPoNumber = 1;
  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['nonordNo'];
  }

  String orderNomber = "";
  String? poNo;
  List<Map<String, dynamic>> ponumdata = [];
  String? PONO;
  String generateId() {
    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');

    if (PONO != null) {
      String ID = PONO!.substring(7);
      int idInt = int.parse(ID) + 1;
      String id = 'WO$year$month-${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ordernumfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getorderno'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          PONO = getNameFromJsonData(item);
          print('orderNo: $PONO');
        }
        setState(() {
          ponumdata = jsonData.cast<Map<String, dynamic>>();
          orderNomber = generateId(); // Call generateId here
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


  @override
  void initState() {
    super.initState();
    fetchData();
    fetchData2();
    fetchData3();
    addRow();
    fetchitemnameData();
    fetchorderNo();
    getitem();
    getitemname();
    ordernumfetch();
    filterCodeData(custName.text);
    saleorderdate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_custNameFocusNode);
    });
  }

  void showOrderNumberExistsDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert"),
          content: Text("Invoice generated For this order"),
          actions: [
            TextButton(
              onPressed: () {
                orderNo.clear();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> data5 = [];



  Future<void> fetchorderNo2() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/checkorderNo'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        jsonData.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['date']);
          final DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA);
        });
        setState(() {
          data5 = jsonData.cast<Map<String, dynamic>>();
        });
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Alert"),
              content: Text("Invoice Generated"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Purchaseorder()));
                  },
                  child: Text("OK"),
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

  bool isOrderNumExists2(String name) {
    return data.any((item) => item['orderNo'].toString().toLowerCase() == name.toLowerCase());
  }

  void filterData2(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filtered = data.where((item) {
          final custName = item[''].toString().toLowerCase();
          return custName.contains(query.toLowerCase());
        }).toList();
      } else {
        filteredData = List.from(data);
      }
    });
  }


  List<Map<String, dynamic>> filteredData3 = [];
  List<Map<String, dynamic>> data3 = [];
  Future<void> fetchData3() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/checkorderNo_forcustomerorder'));
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

  bool ordernumberexiest(String name) {
    return data3.any((item) => item['orderNo'].toString().toLowerCase() == name.toLowerCase());
  }



  TextEditingController qtycontrolls = TextEditingController();
  TextEditingController totqtycontrolls = TextEditingController();
  List<Map<String, dynamic>> filteredData2 = [];
  List<Map<String, dynamic>> data2 = [];
  final ScrollController _scrollController = ScrollController();






  void filterData5(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData2 = data2;
        custMobile.clear();
        pincode.clear();
        custAddress.clear();
        GSTIN.clear();
      } else {
        final existingSupplier = data2.firstWhere(
              (item) => item['custCode']?.toString() == searchText,
          orElse: () => {},
        );
        if (existingSupplier.isNotEmpty) {
          custMobile.text = existingSupplier['custMobile']?.toString() ?? '';
          custAddress.text = existingSupplier['custAddress']?.toString() ?? '';
          pincode.text = existingSupplier['pincode']?.toString() ?? '';
          GSTIN.text = existingSupplier['gstin']?.toString() ?? '';
        } else {
          custMobile.clear();
          custAddress.clear();
          pincode.clear();
          GSTIN.clear();
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
  String itemNamefetch = '';
  String itemGroupfetch = '';


  Map<String, dynamic> dataToUpdate = {};
  Future<void> insertData2(List<Map<String, dynamic>> dataListToUpdate) async {
    const String apiUrl = 'http://localhost:3309/purchaseorder_update';
    try {
      final List<Map<String, dynamic>> requestDataList = [];

      for (var dataToUpdate in dataListToUpdate) {
        requestDataList.add({'dataToInsert': dataToUpdate});
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestDataList),
      );

      if (response.statusCode != 200) {
        print('Failed to insert data');
        throw Exception('Failed to insert data');
      }

      // Rest of your code...

    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }


  //stock insert

  Future<List<Map<String, dynamic>>> fetchStock() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/stock_get_report'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading fetchstock entries: ${response.statusCode}');

      }
    } catch (e) {
      throw Exception('Failed to load fetchstock entries: $e');
    }
  }

//check stock duplicate
  Future<bool> checkForDuplicatestock(String itemGroup, String itemName) async {
    List<dynamic> sizeData = await fetchStock();
    for (var item in sizeData) {
      if (item['itemGroup'] == itemGroup &&
          item['itemName'] == itemName){
        return true;
      }
    }
    return false;
  }

  //stock store value '

  Map<String, dynamic> dataToInsert2 = {};

  Future<void> insertDataStock(Map<String, dynamic> dataToInsert2) async {
    final String apiUrl = 'http://localhost:3309/stock_insert';
    String itemGroup = dataToInsert2['itemGroup'];
    String itemName = dataToInsert2['itemName'];
    int unit = callUnit;
    dataToInsert2['unit'] = unit;
    print('Checking for duplicates: itemGroup: $itemGroup, itemName: $itemName');
    List<Map<String, dynamic>> unitEntries = await fetchStock();
    bool isDuplicate = unitEntries.any((entry) =>
    entry['itemGroup'] == itemGroup &&
        entry['itemName'] == itemName);
    if (isDuplicate) {
      print('Duplicate entry, not inserted');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsert2': dataToInsert2}),
      );
      if (response.statusCode == 200) {
        print('stock inserted successfully');
      } else {
        print('Failed to stock insert data');
        throw Exception('Failed to stock insert data');
      }
    }


    catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  void clearTableValues() {
    for (var i = 0; i < rowData.length; i++) {
      setState(() {
        // Clear values in each row
        rowData[i].itemGroup = null;
        rowData[i].itemName = null;
        rowData[i].quantity = 0;
        rowData[i].qtyController.text = "";
      });
    }
  }

  final FocusNode _custNameFocusNode = FocusNode();
  bool isNewOrderEntered = false;
  @override
  Widget build(BuildContext context) {

    var selectedDate = DateTime.now();
    custName.addListener(() {
      filterCodeData(custName.text);
    });
    custCode.addListener(() {
      filterData5(custCode.text);
    });
    return MyScaffold(
      route: "purchase_order",
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 5,),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    children: [
                                      Image.asset(
                                        'assets/delivery.png',
                                        width: 25,
                                        height: 25,
                                      ),
                                      const Text(" Sales Order Entry", style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25
                                      ),), // Add a Spacer to push the IconButton to the right
                                      IconButton(
                                        icon: Icon(Icons.edit,color: Colors.black), // You can change the icon as needed
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerOrderEdit()));
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height:10),
                                  Padding(
                                    padding: const EdgeInsets.only(left:20.0),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: selectedCheckbox == 1,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              orderNo.clear();
                                              custName.clear();
                                              custCode.clear();
                                              custAddress.clear();
                                              custMobile.clear();
                                              GSTIN.clear();
                                              clearTableValues();
                                              if (value != null && value) {
                                                selectedCheckbox = 1;
                                              } else {
                                                // Toggle between 1 and 2
                                                selectedCheckbox = selectedCheckbox == 1 ? 2 : 1;
                                              }
                                            });
                                          },
                                        ),
                                        Text("Without Order Number"),
                                      ],
                                    ),),

                                  Padding(
                                    padding: const EdgeInsets.only(left:20),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: selectedCheckbox == 2,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              orderNo.clear();
                                              custName.clear();
                                              custCode.clear();
                                              custAddress.clear();
                                              custMobile.clear();
                                              GSTIN.clear();
                                              clearTableValues();
                                              if (value != null && value) {
                                                selectedCheckbox = 2;
                                              } else {
                                                // Toggle between 2 and 1
                                                selectedCheckbox = selectedCheckbox == 2 ? 1 : 2;
                                              }
                                            });
                                          },
                                        ),
                                        Text("With Order Number"),
                                      ],
                                    ),
                                  ),
                                ],),


                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Wrap(
                                  children: [
                                    SizedBox(
                                      width:150,
                                      child: Container(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: 140,
                                              child: TextFormField(style: TextStyle(fontSize: 13),
                                                readOnly: true, // Set the field as read-only
                                                onTap: () async {
                                                  DateTime? pickDate = await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(
                                                        1900),
                                                    lastDate: DateTime.now(),
                                                  );
                                                  if (pickDate == null)
                                                    return;
                                                  {
                                                    setState(() {
                                                      saleorderdate.text =
                                                          DateFormat(
                                                              'dd-MM-yyyy')
                                                              .format(
                                                              pickDate);
                                                      errorMessage=null;
                                                    });
                                                  }
                                                },
                                                controller: saleorderdate, // Set the initial value of the field to the selected date
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  labelText: "Date",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 3,),
                                            Divider(
                                              color: Colors.grey.shade600,
                                            ),
                                            Wrap(
                                                children:[
                                                  Visibility(
                                                    visible: selectedCheckbox == 1,
                                                    child: Column(children: [
                                                      Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Text(
                                                          "Order Number",
                                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Text(
                                                          orderNomber.isEmpty
                                                              ? "WO${DateTime.now().year % 100}${DateTime.now().month.toString().padLeft(2, '0')}-001"
                                                              : orderNomber,
                                                        ),
                                                      ),
                                                    ],),
                                                  ),

                                                  SizedBox(
                                                    width:200,
                                                    child: Visibility(
                                                      visible: selectedCheckbox == 2,
                                                      child: TextFormField(
                                                        controller: orderNo,
                                                        style: const TextStyle(fontSize: 13),
                                                        onChanged: (value) {
                                                          if (ordernumberexiest(orderNo.text)) {
                                                            setState(() {
                                                              errorMessage = '* This Order Number Already Saved';
                                                            });
                                                            return;
                                                          }
                                                          fetchData();
                                                          if (isOrderNumExists(orderNo.text)) {
                                                            showOrderNumberExistsDialog(); // Show dialog if order number already exists
                                                            return;
                                                          }
                                                          custName.addListener(() {
                                                            filterCodeData(custName.text);
                                                          });
                                                          setState(() {
                                                            errorMessage = null; // Reset error message when the user types
                                                          });
                                                        },
                                                        inputFormatters: [
                                                          UpperCaseTextFormatter(),
                                                        ],
                                                        decoration: InputDecoration(
                                                          fillColor: Colors.white,
                                                          filled: true,
                                                          labelText: "Order Number",
                                                          labelStyle: TextStyle(fontSize: 13),
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),

                                                    ),
                                                  ),
                                                ]
                                            ),
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
                SizedBox(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        width: double.infinity, // Set the width to full page width
                        padding: EdgeInsets.all(16.0), // Add padding for spacing
                        decoration: BoxDecoration(
                          color:Colors.blue[50],
                          border: Border.all(color: Colors.grey), // Add a border for the box
                          borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                        ),
                        child: Column(
                          children: [
                            Wrap(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Customer Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 15,),
                            Wrap(
                              spacing: 36.0, // Set the horizontal spacing between the children
                              runSpacing: 20.0,
                              children: [
                                SizedBox(
                                  width: 220,height: 70,
                                  child:  TextFormField(
                                    readOnly:true,
                                    controller: custCode,
                                    focusNode: custCodeFocusNode,
                                    style: TextStyle(fontSize: 13),
                                    inputFormatters: [
                                      UpperCaseTextFormatter(), // Apply the formatter
                                    ],
                                    onChanged: (value){
                                      setState(() {
                                        errorMessage = null; // Reset error message when user types
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white70,
                                      labelText:"Customer Code" ,
                                      //hintStyle: TextStyle(fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 220,
                                  height:50,
                                  child: TypeAheadFormField<String>(
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: custName,
                                      focusNode: _custNameFocusNode,
                                      onChanged: (value) {
                                        String capitalizedValue = capitalizeFirstLetter(value);
                                        custName.value = custName.value.copyWith(
                                          text: capitalizedValue,
                                          selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                        );
                                        setState(() {
                                           if (custName.text.isEmpty) {
                                          setState(() {
                                          errorMessage = '* Enter a Customer/Company Name';
                                          });
                                          }
                                          else if (custName.text.length < 3) {
                                          setState(() {
                                          errorMessage = '* Customer/Company Name should have at least 3 letters';
                                          });
                                          }
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

                                SizedBox(
                                  width: 220, height: 70,
                                  child: TextFormField(
                                    readOnly: readOnlyFields,
                                    controller: custMobile,
                                    style: TextStyle(fontSize: 13),
                                    onChanged: (value){
                                      setState(() {
                                        if (custMobile.text.isEmpty) {
                                           setState(() {
                                          errorMessage = '* Enter a Customer Mobile';
                                        });
                                        }
                                        else if (custMobile.text.length != 10) {
                                          setState(() {
                                           errorMessage = '* Mobile number should be 10 digits';
                                          });
                                        }
                                        errorMessage = null; // Reset error message when user types
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white70,
                                      labelText: "Customer Mobile",
                                      prefixText: "+91 ",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10,),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10)
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 220, height: 70,
                                  child: TextFormField(
                                    readOnly: readOnlyFields,
                                    //maxLines: 2,
                                    controller: custAddress,
                                    onChanged: (value) {
                                      String capitalizedValue = capitalizeFirstLetter(value);
                                      custAddress.value = custAddress.value.copyWith(
                                        text: capitalizedValue,
                                        //  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                      );
                                      setState(() {
                                        errorMessage = null; // Reset error message when user types
                                      });
                                    },
                                    style: TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white70,
                                      labelText: "Customer Address",
                                      //hintStyle: TextStyle(fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),

                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 36.0, // Set the horizontal spacing between the children
                              runSpacing: 20.0,
                              children: [
                                SizedBox(
                                  width: 220, height: 70,
                                  child: TextFormField(
                                    readOnly: readOnlyFields,
                                    controller: pincode,
                                    style: TextStyle(fontSize: 13),
                                    onChanged: (value) {
                                      setState(() {
                                        errorMessage = null;
                                        if (value.isEmpty) {
                                          errorMessage = null;
                                        }
                                        if (pincode.text.length == 6) {
                                        } else {
                                          errorMessage = '* Enter a valid Pincode';
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white70,
                                      labelText: "Pincode",
                                      hintText: "Pincode",
                                      //hintStyle: TextStyle(fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10,),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(6)
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 220,height: 70,
                                  child: TextFormField(
                                    readOnly: readOnlyFields,
                                    controller: GSTIN,
                                    style: TextStyle(fontSize: 13),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(15),
                                      UpperCaseTextFormatter(), // Apply the formatter
                                    ],
                                    onChanged: (value){
                                        setState(() {
                                          errorMessage = null;
                                           if (value.isEmpty) {
                                             setState(() {
                                            errorMessage = '* Enter a GSTIN';
                                           });
                                           }
                                          if (!gstregex2.hasMatch(GSTIN.text)) {
                                          setState(() {
                                          errorMessage = '* Invalid GSTIN';
                                            });
                                          }
                                        });

                                      // setState(() {
                                      //   / Reset error message when user types
                                      // });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white70,
                                      labelText: "GSTIN",
                                      //hintStyle: TextStyle(fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 220,height: 38,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white70,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        // Step 3.
                                        value: deliveryType,
                                        hint: Text("Delivery Type",style:TextStyle(fontSize: 13,color: Colors.black)),
                                        // Step 4.
                                        items: <String>['Complete','Partial']
                                            .map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(fontSize: 15,color: Colors.black),
                                            ),
                                          );
                                        }).toList(),
                                        // Step 5.
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            errorMessage = null; // Reset error message when user types
                                          });
                                          setState(() {
                                            deliveryType = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),


                                SizedBox(
                                  width: 220,
                                  height: 70,
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 13),
                                    readOnly: true,
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: deliverydate ?? DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      ).then((date) {
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                        if (date != null) {
                                          setState(() {
                                            deliverydate = date;
                                            final formattedDate = DateFormat('dd-MM-yyyy').format(deliverydate!);
                                            deliveryDate.text = formattedDate;
                                          });
                                        }
                                      });
                                    },
                                    controller: deliveryDate, // Use the deliveryDate controller here
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: "Expected Delivery Date",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),

                            const Align(
                                alignment:Alignment.topLeft,
                                child: Text("Product Details",
                                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
                            const SizedBox(height: 20,),
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
                                          0: FixedColumnWidth(325),
                                          1: FixedColumnWidth(325),
                                          2: FixedColumnWidth(170),
                                          3: FixedColumnWidth(170),
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
                                                                rowData[i].qtyController.text = "";
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
                                                          rowData[i].quantity = int.tryParse(value) ?? 0;
                                                          calculateTotalQty(i);
                                                        });
                                                      },
                                                      inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter.digitsOnly,
                                                        LengthLimitingTextInputFormatter(10)
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top:20),
                                  child: Text(
                                    errorMessage ?? '',
                                    style: TextStyle(color: Colors.red,fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child:
                  Wrap(
                    children: [
                      MaterialButton(
                        color: Colors.green.shade600,
                        onPressed: () async {
                          setState(() {
                            errorMessage = null; // Reset error message before processing
                          });
                          if (selectedCheckbox == 1) {
                            DateTime now=DateTime.now();
                            String year=(now.year%100).toString();
                            String month=now.month.toString().padLeft(2,'0');
                            if (orderNomber.isEmpty) {
                              orderNomber = 'WO$year$month-001';
                            }
                            for (var i = 0; i < rowData.length; i++) {
                              if (i > 0 &&
                                  rowData[i].itemGroup == rowData[i - 1].itemGroup &&
                                  rowData[i].itemName == rowData[i - 1].itemName) {
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
                              }
                              else if (rowData[i].qtyController.text == '0')  {
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
                              }
                              else if (rowData[i].qtyController.text == '00')  {
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
                              }
                              else  if (_formKey.currentState!.validate()) {
                                final deliveryDate = deliverydate?.toIso8601String();
                                String enteredcustCode = custCode.text;
                                bool isDuplicate = await checkForDuplicate(enteredcustCode);
                                validateDropdown();
                                if (ordernumberexiest(orderNo.text)) {
                                  setState(() {
                                    errorMessage = '* This Order Number Already Saved';
                                  });
                                  return;
                                }
                                else if (saleorderdate.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Selecte a Date';
                                  });
                                }
                                else if (custName.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Customer/Company Name';
                                  });
                                }
                                else if (custName.text.length < 3) {
                                  setState(() {
                                    errorMessage = '* Customer/Company Name should have at least 3 letters';
                                  });
                                }
                                else if (custMobile.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Customer Mobile';
                                  });
                                }
                                else if (custMobile.text.length != 10) {
                                  setState(() {
                                    errorMessage = '* Mobile number should be 10 digits';
                                  });
                                }
                                else if (custAddress.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Customer Address';
                                  });
                                }
                                else if(pincode.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a pincode';
                                  });
                                }
                                else if (!pincodeRegex.hasMatch(pincode.text)) {
                                  setState(() {
                                    errorMessage = '* Enter a valid pincode with exactly 6 digits';
                                  });
                                }
                                else if (GSTIN.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a GSTIN';
                                  });
                                }
                                else if (!gstregex2.hasMatch(GSTIN.text)) {
                                  setState(() {
                                    errorMessage = '* Invalid GSTIN';
                                  });
                                }
                                else if (rowData[i].itemGroup == null || rowData[i].itemName == null || rowData[i].qtyController.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Fill all fields in the table';
                                  });
                                  return;
                                }
                                else if (rowData[i].qtyController.text == null || rowData[i].qtyController.text == '0') {
                                  setState(() {
                                    errorMessage = '* Enter a quantity greater than 0';
                                  });
                                }
                                else if (errorMessage == null) {
                                  bool isDuplicatestock = await checkForDuplicatestock(
                                    rowData[i].itemGroup!, rowData[i].itemName!,);
                                  if (isDuplicatestock) {
                                    print("its duplicates ${rowData[i].itemGroup!}, ${rowData[i]
                                        .itemName!},");
                                  } else {
                                    final dataToInsert2 = {
                                      'date': date.toString(),
                                      'itemGroup': rowData[i].itemGroup!,
                                      'itemName': rowData[i].itemName,
                                      'unit': callUnit,
                                      'qty': '0',
                                    };
                                    await insertDataStock(dataToInsert2); //s
                                  }
                                  dataToInsert = {
                                    'nonordNo':orderNomber,
                                    'orderNo': orderNomber,
                                    'date': date.toString(),
                                    'custCode': custCode.text,
                                    'custName': custName.text,
                                    'deliveryType': deliveryType,
                                    'deliveryDate': deliverydate.toString(),
                                    'itemGroup': rowData[i].itemGroup,
                                    'itemName': rowData[i].itemName,
                                    'qty':rowData[i].qtyController.text,
                                    'date': date.toString(),
                                  };
                                  try {
                                    await insertData(dataToInsert);
                                    if (isDuplicate) {
                                    } else {
                                      customerDataToDatabase();
                                    }
                                    setState(() {
                                      deliveryType==null;
                                      isDataSaved = true;
                                    });
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString('orderNo', orderNo.text);
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Sales Order"),
                                          content: Text("Saved Successfully"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) => Purchaseorder()));
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    print('Error inserting data: $e');
                                  }
                                }
                              }
                            }
                            print('Checkbox 1 is selected');
                          } else if (selectedCheckbox == 2) {
                            for (var i = 0; i < rowData.length; i++) {
                              if (i > 0 &&
                                  rowData[i].itemGroup == rowData[i - 1].itemGroup &&
                                  rowData[i].itemName == rowData[i - 1].itemName) {
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
                              }
                              else if (rowData[i].qtyController.text == '0')  {
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
                              }
                              else if (rowData[i].qtyController.text == '00')  {
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
                              }

                              else if (_formKey.currentState!.validate()) {
                                final deliveryDate = deliverydate?.toIso8601String();
                                String enteredcustCode = custCode.text;
                                bool isDuplicate = await checkForDuplicate(enteredcustCode);
                                validateDropdown();
                                if (ordernumberexiest(orderNo.text)) {
                                  setState(() {
                                    errorMessage = '* This Order Number Already Saved';
                                  });
                                  return;
                                }
                                else if (orderNo.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Order Number';
                                  });
                                }
                                else if (custName.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Customer/Company Name';
                                  });
                                }
                                else if (custMobile.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Customer Mobile';
                                  });
                                }
                                else if (custMobile.text.length != 10) {
                                  setState(() {
                                    errorMessage = '* Mobile number should be 10 digits';
                                  });
                                }
                                else if (custAddress.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Customer Address';
                                  });
                                }  else if (GSTIN.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a GSTIN';
                                  });
                                }
                                else if (!gstregex2.hasMatch(GSTIN.text)) {
                                  setState(() {
                                    errorMessage = '* Invalid GSTIN';
                                  });
                                }
                               /* else if (deliveryType == null) {
                                  setState(() {
                                    errorMessage = '* Select a DeliveryType';
                                  });
                                }
                                else if (deliveryDate == null) {
                                  setState(() {
                                    errorMessage = '* Select a Expected Delivery Date';
                                  });
                                }*/
                                else if (rowData[i].itemGroup == null || rowData[i].itemName == null || rowData[i].qtyController.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Fill all fields in the table';
                                  });
                                  return;
                                }
                                else {
                                  final dataToInsert2 = {
                                    'date': date.toString(),
                                    'itemGroup': rowData[i].itemGroup!,
                                    'itemName': rowData[i].itemName,
                                    'unit': callUnit,
                                    'qty': '0',
                                    //   'modifyDate': "",
                                  };
                                  await insertDataStock(dataToInsert2);
                                  dataToInsert = {
                                    'orderNo': orderNo.text,
                                    'date': saleorderdate.text,
                                    'custCode': custCode.text,
                                    'custName': custName.text,
                                    'deliveryType': deliveryType,
                                    'deliveryDate': deliverydate.toString(),
                                    'itemGroup': rowData[i].itemGroup,
                                    'itemName': rowData[i].itemName,
                                    'qty':rowData[i].qtyController.text,
                                    //'totQty': rowData[i].totalQtyController.text,
                                    'date': date.toString(),
                                  };
                                  try {
                                    await insertData(dataToInsert);
                                    if (isDuplicate) {
                                    } else {
                                      customerDataToDatabase();
                                    }
                                    setState(() {
                                      deliveryType==null;
                                      isDataSaved = true;
                                    });
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString('orderNo', orderNo.text);
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Sales Order"),
                                          content: Text("Saved Successfully"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.push(context, MaterialPageRoute(
                                                    builder: (context) => Purchaseorder()));
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    print('Error inserting data: $e');
                                  }
                                }
                              }
                            }
                            print('Checkbox 2 is selected');
                          }
                        },
                        child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 20,),
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Purchaseorder()));
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
                                title: Text('Confirmation'),
                                content: Text('Do you want to cancel?'),
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
              ],
            ),
          ),
        ),
      ),
    );
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
class MyRowData {
  String? itemName;
  TextEditingController qtyController = TextEditingController();
}

class CapitalizeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: _capitalizeWords(newValue.text),
      selection: newValue.selection,
    );
  }

  String _capitalizeWords(String text) {
    List<String> words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }
    return words.join(' ');
  }
}
