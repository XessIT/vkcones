import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:vinayaga_project/purchase/purchase_order.dart';

import '../home.dart';



// Assuming rowData is a List of RowData objects
class RowData {
  String? itemGroup;
  String? itemName;
  int quantity;
  TextEditingController qtyController;

  RowData({this.itemGroup, this.itemName, this.quantity = 0})
      : qtyController = TextEditingController(text: quantity.toString());
}



class CustomerOrderEdit extends StatefulWidget {
  const CustomerOrderEdit({Key? key}) : super(key: key);
  @override
  State<CustomerOrderEdit> createState() => _CustomerOrderEditState();
}
class _CustomerOrderEditState extends State<CustomerOrderEdit> {
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
  TextEditingController orderNo = TextEditingController();
  TextEditingController custCode = TextEditingController();
  TextEditingController custName = TextEditingController();
  TextEditingController custMobile = TextEditingController();
  TextEditingController custAddress = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController GSTIN = TextEditingController();
  final FocusNode custCodeFocusNode = FocusNode();
  String? selectedCustomer="";
  TextEditingController deliveryDate = TextEditingController();
  String? deliveryType;
  bool dropdownValid1 = true;
  static final RegExp gstregex2 = RegExp(r"^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d{1}[Z]{1}[A-Z\d]{1}$");
  bool isFirstRowRemovalEnabled = false;
  DateTime? deliverydate;

  void validateDropdown() {
    setState(() {
      dropdownValid1 = deliveryType != "Delivery Type";
    });
  }


  String? errorMessage="";
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

  Future<void> insertData(List<Map<String, dynamic>> dataListToInsert) async {
    const String apiUrl = 'http://localhost:3309/purchaseorder_entry';
    try {
      // Make the API call for each set of data
      for (var dataToInsert in dataListToInsert) {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'dataToInsert': dataToInsert}),
        );
        // Handle the response as needed
        if (response.statusCode != 200) {
          print('Failed to insert data');
          throw Exception('Failed to insert data');
        }
      }

      // If all API calls are successful, show success dialog or perform other actions
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Customer Order"),
            content: Text("Updated Successfully"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Purchaseorder()));
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      print('All data inserted successfully');
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

        'qty': rowData[i].qtyController.text,
        //'totQty': rowData[i].totalQtyController.text,
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
  List<Map<String, dynamic>> data4 = [];
  List<Map<String, dynamic>> filteredData4 = [];
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




  Future<void> fetchcustdetails() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getcustomer_purchase_order'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          data4 = jsonData.cast<Map<String, dynamic>>();
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

  void filterData4(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = data4;
        custCode.clear();
        custName.clear();
        deliveryDate.clear();
        deliveryType=null;
        filteredData4 = data4;
      } else {
        filteredData4 = data4.where((item) {
          String id = item['orderNo']?.toString()?.toLowerCase() ?? '';
          return id == searchText.toLowerCase();
        }).toList();
        if (filteredData4.isNotEmpty) {
          Map<String, dynamic> order = filteredData4.first;
          custCode.text = order['custCode']?.toString() ?? '';
          custName.text = order['custName']?.toString() ?? '';
          deliveryType=order['deliveryType']?.toString() ?? '';
          if (order['deliveryDate'] != null) {
            DateTime parsedDate = DateTime.parse(order['deliveryDate'].toString()).toLocal();
            String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
            deliveryDate.text = formattedDate;
          } else { deliveryDate.clear();
          }
        } else {
          custCode.clear();
          custName.clear();
          custName.clear();
          deliveryDate.clear();
          deliveryType=null;
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
                setState(() {
                  rowData.removeAt(index); // Remove the row from the list
                });
                Navigator.of(context).pop(); // Close the alert dialog
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
  ///for unit
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

  List<String> itemNames = [];
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

  void calculateTotalQty(int index) {
    print('Debug: callUnit=$callUnit, quantity=${rowData[index].quantity}');

    if (callUnit != null && rowData[index].quantity != null) {
      int totalQty = callUnit! * rowData[index].quantity!;
      // Update the total quantity in the rowData
      setState(() {

        // Update the totalQtyController text
      });
    }
  }

  List<Map<String, dynamic>> data = [];
  bool showInitialData = true;
  List<Map<String, dynamic>> filtered = [];
  String selectedInvoiceNo="";


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
              content: Text("iInvoice Generated"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => CustomerOrderEdit()));
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


  List<Map<String, dynamic>> data6 = [];

  List<Map<String, dynamic>> filtered6 = [];

  Future<void> fetchnoorderNo() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/checknonorderNo_Customer_order'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        jsonData.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['date']);
          final DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA);
        });
        setState(() {
          data6 = jsonData.cast<Map<String, dynamic>>();
        });
      } else {
      }
    } catch (error) {
    }
  }

  bool isnonOrderNum(String name) {
    return data6.any((item) => item['nonordNo'].toString().toLowerCase() == name.toLowerCase());
  }

  void filterDatanon(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filtered6 = data6.where((item) {
          final orderNo = item['nonordNo'].toString().toLowerCase();
          return orderNo.contains(query.toLowerCase());
        }).toList();
      } else {
        filtered6 = List.from(data6);
      }
    });
  }


  @override
  void initState() {
    super.initState();
    fetchData();
    addRow();
    fetchcustdetails();
    fetchData();
    fetchData2();
    fetchitemnameData();
    fetchorderNo();
    getitem();
    getitemname();
    fetchDataByOrderumber(orderNo.text);
    filterCodeData(custName.text);
    fetchnoorderNo();
    deliveryDate=TextEditingController();
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


  TextEditingController qtycontrolls = TextEditingController();
  TextEditingController totqtycontrolls = TextEditingController();

  Future<void> fetchDataByOrderumber(String orderNo) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_purchase_orderitem?orderNo=$orderNo');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;

        setState(() {
          rowData.clear();
          for (var i = 0; i < rows.length; i++) {
            Map<String, dynamic> row = {
              'itemGroup': rows[i]['itemGroup'],
              'itemName': rows[i]['itemName'],
              'qty': rows[i]['qty'],
            };
            // Add the created row to rowData
            rowData.add(RowData(
              itemGroup: row['itemGroup'],
              itemName: row['itemName'],
              quantity: row['qty'],
            ));

            print('Debug: qty=${row['qty']}, totQty=${row['totQty']}');
            // Update controllers
            rowData[i].qtyController.text = row['qty'].toString();
            //  rowData[i].totalQtyController.text = row['totQty'].toString();
          }
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }



  List<Map<String, dynamic>> filteredData2 = [];
  List<Map<String, dynamic>> data2 = [];

  void filterData2(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData2 = data2;
        custMobile.clear();
        custAddress.clear();
        GSTIN.clear();
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
        } else {
          custMobile.clear();
          custAddress.clear();
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



  Future<void> updateCustomerorderDetails(String orderNo,String custCode,
      String custName, String deliveryType, String deliveryDate,
      String itemGroup, String itemName, String qty, String totQty, String modifyDate) async {
    final response = await http.put(
      Uri.parse('http://localhost:3309/purchase_order_update/$orderNo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'orderNo': orderNo,
        'custName': custName,
        'custCode': custCode, // Add this if needed
        'deliveryDate': deliveryDate,
        'deliveryType': deliveryType,
        'modifyDate': modifyDate,
        'itemGroup': itemGroup,
        'itemName': itemName,
        'qty': qty,
        // 'totQty': totQty,
      }),
    );
    if (response.statusCode == 200) {
      print('Data updated successfully');
    } else {
      print('Error updating data: ${response.body}');
    }
  }

  String id = '';

  Future<void> deleteItem(String orderNo) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3309/purchase_orderdelete/$orderNo'),
      );
      if (response.statusCode == 200) {
        print('Data deleted successfully');
      } else if (response.statusCode == 404) {
        print('No matching data found for deletion');
      } else {
        throw Exception('Error deleting item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }
  Future<void> onDelete(String orderNo) async {
    await deleteItem(orderNo);
  }


  void updateTable() {
    bool allFieldsFilled = rowData.every((row) =>
    row.itemGroup != null &&
        row.itemName != null &&
        row.qtyController.text.isNotEmpty);

    if (allFieldsFilled) {
      setState(() {});
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


  @override
  Widget build(BuildContext context) {
    var selectedDate = DateTime.now();

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
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/delivery.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                  const Text(" Sales Order Edit", style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25
                                  ),),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width:200,
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 125.0),
                                              child: Text(
                                                DateFormat('dd-MM-yyyy').format(selectedDate),
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(height: 3,),
                                            Divider(
                                              color: Colors.grey.shade600,
                                            ),
                                            Wrap(
                                                children:[
                                                  SizedBox(
                                                    width: 200,
                                                    child: TypeAheadFormField<String>(
                                                      textFieldConfiguration: TextFieldConfiguration(
                                                        controller: orderNo,
                                                        style: const TextStyle(fontSize: 13),
                                                        onChanged: (value) {
                                                          if (isOrderNumExists(orderNo.text)) {
                                                            showOrderNumberExistsDialog(); // Show dialog if order number already exists
                                                            return;
                                                          }
                                                          else{
                                                            orderNo.addListener(() {
                                                              fetchDataByOrderumber(orderNo.text);
                                                              filterDatanon(orderNo.text);
                                                            });
                                                            orderNo.addListener(() {
                                                              filterData4(orderNo.text);
                                                            });
                                                            custCode.addListener(() {
                                                              filterData2(custCode.text);
                                                            });
                                                            custName.addListener(() {
                                                              filterCodeData(custName.text);
                                                            });
                                                            fetchData();
                                                            fetchnoorderNo();
                                                            orderNo.addListener(() {
                                                              fetchDataByOrderumber(orderNo.text);
                                                            });
                                                            print("Checking if orderNo is in nonordNo");
                                                            if (isnonOrderNum(orderNo.text)) {
                                                              print("OrderNo is already in nonordNo");
                                                            }
                                                            if (isnonOrderNum(orderNo.text)) {
                                                              return;
                                                            }
                                                          }
                                                          setState(() {
                                                            errorMessage = null; // Reset error message when user types
                                                          });
                                                        },
                                                        inputFormatters:[
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
                                                      suggestionsCallback: (pattern) async {
                                                        List<String> suggestions;
                                                        if (pattern.isNotEmpty) {
                                                          suggestions = data4
                                                              .where((item) =>
                                                              (item['orderNo']?.toString()?.toLowerCase() ?? '')
                                                                  .startsWith(pattern.toLowerCase()))
                                                              .map((item) => item['orderNo'].toString())
                                                              .toSet() // Remove duplicates using a Set
                                                              .toList();

                                                          suggestions.removeWhere((existingInvoiceNo) =>
                                                          isOrderNumExists(existingInvoiceNo) &&
                                                              existingInvoiceNo != orderNo.text);
                                                        } else {
                                                          if (isOrderNumExists(orderNo.text)) {
                                                            setState(() {
                                                              errorMessage = '* This Order Already Saved';
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
                                                          title: Text(suggestion),
                                                        );
                                                      },
                                                      onSuggestionSelected: (suggestion) {
                                                        // if (isOrderNumExists(orderNo.text)) {
                                                        //   showOrderNumberExistsDialog(); // Show dialog if order number already exists
                                                        //   return;
                                                        // }
                                                        setState(() {
                                                          selectedInvoiceNo = suggestion;
                                                          orderNo.text = suggestion;
                                                        });
                                                        print('Selected Invoice Number: $selectedInvoiceNo');
                                                      },
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          errorMessage ?? '',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
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
                                          (item['custName']?.toString()?.toLowerCase() ?? '')
                                              .startsWith(pattern.toLowerCase()))
                                          .map((item) => item['custName'].toString())
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
                                      setState(() {
                                        selectedCustomer = suggestion;
                                        custName.text = suggestion;
                                      });
                                      print('Selected Customer: $selectedCustomer');
                                    },
                                  ),
                                ),

                                SizedBox(
                                  width: 220, height: 70,
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: custMobile,
                                    style: TextStyle(fontSize: 13),
                                    onChanged: (value){
                                      setState(() {
                                        errorMessage = null; // Reset error message when user types
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white70,
                                      labelText: "Customer Mobile",
                                      //hintStyle: TextStyle(fontWeight: FontWeight.bold),
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
                                    readOnly: true,
                                    //maxLines: 2,
                                    controller: custAddress,
                                    onChanged: (value) {
                                      String capitalizedValue = capitalizeFirstLetter(value);
                                      custAddress.value = custAddress.value.copyWith(
                                        text: capitalizedValue,
                                        selection: TextSelection.collapsed(offset: capitalizedValue.length),
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
                              crossAxisAlignment: WrapCrossAlignment.start,
                              spacing: 36.0, // Set the horizontal spacing between the children
                              runSpacing: 20.0,
                              children: [
                                SizedBox(
                                  width: 220, height: 70,
                                  child: TextFormField(
                                    readOnly: readOnlyFields,
                                    controller: pincode,
                                    style: TextStyle(fontSize: 13),
                                    onChanged: (value){
                                      setState(() {
                                        errorMessage = null; // Reset error message when user types
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
                                    readOnly: true,
                                    controller: GSTIN,
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
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
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
                              scrollDirection: Axis.horizontal,
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
                                        /* TableCell(
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
                                        ),*/
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
                                                      controller: TextEditingController(text: rowData[i].itemGroup),
                                                      decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                                      ),
                                                      inputFormatters: [CapitalizeInputFormatter()],
                                                    ),
                                                    suggestionsCallback: (pattern) async {
                                                      return itemGroups.where((group) => group.toLowerCase().contains(pattern.toLowerCase()));
                                                    },
                                                    itemBuilder: (context, suggestion) {
                                                      return ListTile(
                                                        title: Text(suggestion!),
                                                      );
                                                    },
                                                    onSuggestionSelected: (String? suggestion) async {
                                                      setState(() {
                                                        rowData[i].itemGroup = suggestion;
                                                        rowData[i].itemName = null;
                                                        rowData[i].qtyController.text = "";
                                                      });
                                                      updateTable();
                                                    },
                                                  ),
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
                                                      return itemNames.where((name) => name.toLowerCase().contains(pattern.toLowerCase()));
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
                                                      updateTable();
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
                                                    });
                                                    updateTable();
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

                                          /* TableCell(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                              height: 60,
                                              color: Colors.blue.shade100,
                                              child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: TextFormField(
                                                  controller: rowData[i].totalQtyController,
                                                  keyboardType: TextInputType.number,
                                                  enabled: false,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      rowData[i].totalQty = int.tryParse(value) ?? 0;
                                                      calculateTotalQty(i);
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
                                          ),*/

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
                                                      onPressed: i > 0 ? () => deleteRow(i) : null,
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
                                                            }
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ]),
                                    ],
                                  ),
                                ),
                              ),
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
                          List<Map<String, dynamic>> dataListToInsert = [];
                          for (var i = 0; i < rowData.length; i++) {
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
                            }
                            if (rowData[i].qtyController.text == '00') {
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
                              print("Delivery Date Inside Button Pressed: ${deliveryDate.text}");
                              if (orderNo.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Order Number';
                                });
                              }
                              else if (custName.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Customer/Company Name';
                                });
                              }
                              else if (deliveryType == null) {
                                setState(() {
                                  errorMessage = '* Select a DeliveryType';
                                });
                              }
                              else if (deliveryDate == null) {
                                setState(() {
                                  errorMessage = '* Select a Expected Delivery Date';
                                });
                              }
                              else  if (rowData[i].itemGroup == null || rowData[i].itemName == null || rowData[i].qtyController.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Fill all fields in the table';
                                });
                                return;
                              }
                              DateTime parsedDeliveryDate = DateFormat('dd-MM-yyyy').parse(deliveryDate.text);
                              await onDelete(orderNo.text);
                              print("${orderNo.text}");
                              if(isnonOrderNum(orderNo.text)){
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
                                    //   'modifyDate': "",
                                  };
                                  await insertDataStock(dataToInsert2); //s
                                }
                                dataListToInsert.add({
                                  'orderNo': orderNo.text,
                                  'nonordNo': orderNo.text,
                                  'date': date.toString(),
                                  'custCode': custCode.text,
                                  'custName': custName.text,
                                  'deliveryType': deliveryType,
                                  'deliveryDate': parsedDeliveryDate.toLocal().toString(),
                                  'itemGroup': rowData[i].itemGroup,
                                  'itemName': rowData[i].itemName,
                                  'qty': rowData[i].qtyController.text,
                                  'modifyDate':date.toString(),
                                  'date': date.toString(),
                                }
                                );}else{
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
                                    //   'modifyDate': "",
                                  };
                                  await insertDataStock(dataToInsert2); //s
                                }
                                dataListToInsert.add({
                                  'orderNo': orderNo.text,
                                  'date': date.toString(),
                                  'custCode': custCode.text,
                                  'custName': custName.text,
                                  'deliveryType': deliveryType,
                                  'deliveryDate': parsedDeliveryDate.toLocal().toString(),
                                  'itemGroup': rowData[i].itemGroup,
                                  'itemName': rowData[i].itemName,
                                  'qty': rowData[i].qtyController.text,
                                  'modifyDate':date.toString(),
                                  'date': date.toString(),
                                }
                                );
                              };
                            }
                          }

                          // Check if there is any data to insert
                          if (dataListToInsert.isNotEmpty) {
                            // Call the insertData function with the list of data
                            await insertData(dataListToInsert);

                            // Additional code after successful insertion
                            setState(() {
                              deliveryType = null;
                              isDataSaved = true;
                            });
                          }
                        },
                        child: const Text("UPDATE", style: TextStyle(color: Colors.white)),
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> CustomerOrderEdit()));
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



