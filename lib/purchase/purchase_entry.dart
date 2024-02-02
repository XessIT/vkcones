

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import '../home.dart';

class Purchase extends StatefulWidget {
  const Purchase({Key? key}) : super(key: key);
  @override
  State<Purchase> createState() => _PurchaseState();
}
class _PurchaseState extends State<Purchase> {
  final _formKey = GlobalKey<FormState>();
  final  selectedDate = DateTime.now();

  final  date = DateTime.now();
  List<List<TextEditingController>> controllers = [];
  List<List<TextEditingController>> controllers2 = [];
  List<List<FocusNode>> focusNodes = [];
  List<Map<String, dynamic>> rowData = [];
  List<bool> isRowFilled = [false];
  bool allFieldsFilled = false;
  bool dropdownValid = true;
  String? payType;
  bool itemGroupExists = false;
  Map<String, dynamic> dataToInsert = {};
  String? errorMessage="";
  String? status; //partial or complete
  bool invoiceEditable =false;


  bool dropdownValid1 = true;
  bool alertVisible = false;
  double grandTotalGsm = 0.0;
  double grandTotalValue = 0.0;

  TextEditingController tcsController = TextEditingController();
  TextEditingController discountController = TextEditingController();

/*
  void updateGrandTotal() {
    double tcs = double.tryParse(tcsController.text) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;

    if (selectedCheckbox != 3) {
      grandTotalValue = calculateGrandTotal() + tcs - discount;
    } else {
      grandTotalGsm = calculateGrandTotalGsm() + tcs - discount;
    }
    setState(() {
      grandTotalValue = calculateGrandTotal() + tcs - discount;
      grandTotalGsm = calculateGrandTotalGsm() + tcs - discount;    });
  }
*/
  void updateGrandTotal() {
    double tcs = double.tryParse(tcsController.text) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;

      grandTotalGsm = calculateGrandTotalGsm() + tcs - discount;

    setState(() {
      grandTotalGsm = calculateGrandTotalGsm() + tcs - discount;    });
  }

  double calculateGrandTotalGsm() {
    double total = 0.0;
    for (var i = 0; i < controllers2.length; i++) {
      total += double.tryParse(controllers2[i][9].text) ?? 0.0;
    }
    return total;
  }

  bool isTextFormFieldsVisible = false;

  void onArrowButtonClick() {
    setState(() {
      isTextFormFieldsVisible = !isTextFormFieldsVisible;
    });
  }




  List<Map<String, dynamic>> datapendingInsertList = [];

/*
  void removeRow(int rowIndex) {
    if (rowIndex >= 0 && rowIndex < controllers.length) {
      DateTime now = DateTime.now();
      String year = (now.year % 100).toString();
      String month = now.month.toString().padLeft(2, '0');
      if (poNumber.isEmpty) {
        poNumber = 'PP$year$month/001';
      }
      Map<String, dynamic> removedRowData = {
        "poNo": poNumber,
        "date": date.toString(),
        "invoiceNo": invoiceNo.text.trim(),
        "pendingOrderNo": poNumber,
        "supCode": supCode.text,
        "supName": supName.text,
        "prodCode": controllers[rowIndex][0].text,
        "prodName": controllers[rowIndex][1].text,
        'qty': controllers[rowIndex][10].text.isNotEmpty ? controllers[rowIndex][10].text : '0',
        "pincode": pincode.text,
        "deliveryDate": "",
        'unit': controllers[rowIndex][2].text,
      };

      controllers.removeAt(rowIndex);
      rowslenth = controllers.length;
      rowslenth2 = controllers.length;

      List<Map<String, dynamic>> rowDataToInsert = [removedRowData];
      datapendingInsertList.addAll(rowDataToInsert);

      focusNodes.removeAt(rowIndex);
      isRowFilled.removeAt(rowIndex);
      setState(() {
        grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
        for (int i = rowIndex; i < controllers.length; i++) {
          int fetchedIndex = i + 1;
          controllers[i][10].text = fetchedQuantities[fetchedIndex].toString();
          fetchedQuantities[i] = fetchedQuantities[fetchedIndex]!;
        }
      });
    } else {
      print("Invalid index: $rowIndex");
    }
  }
*/
    void removeRow2(int rowIndex) {
    setState(() {
      controllers2.removeAt(rowIndex); // Remove the controllers for the row
      rowData.removeAt(rowIndex); // Remove the data for the row
    });
  }
  void removeRow(int rowIndex) {
    if (rowIndex >= 0 && rowIndex < controllers.length) {
      DateTime now = DateTime.now();
      String year = (now.year % 100).toString();
      String month = now.month.toString().padLeft(2, '0');
      if (poNumber.isEmpty) {
        poNumber = 'PP$year$month/001';
      }
      Map<String, dynamic> removedRowData = {
        "poNo": poNumber,
        "date": date.toString(),
        "invoiceNo": invoiceNo.text.trim(),
        "pendingOrderNo": poNumber,
        "supCode": supCode.text,
        "supName": supName.text,
        "prodCode": controllers[rowIndex][0].text,
        "prodName": controllers[rowIndex][1].text,
        'qty': controllers[rowIndex][10].text.isNotEmpty ? controllers[rowIndex][10].text : '0',
        "pincode": pincode.text,
        "deliveryDate": "",
        'unit': controllers[rowIndex][2].text,
      };

      controllers.removeAt(rowIndex);
      rowslenth = controllers.length;
      rowslenth2 = controllers.length;

      List<Map<String, dynamic>> rowDataToInsert = [removedRowData];
      datapendingInsertList.addAll(rowDataToInsert);

      focusNodes.removeAt(rowIndex);
      isRowFilled.removeAt(rowIndex);
      setState(() {
       // grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
        for (int i = rowIndex; i < controllers.length; i++)
        {
          int fetchedIndex = i + 1;
          controllers[i][10].text = fetchedQuantities[fetchedIndex].toString();
          fetchedQuantities[i] = fetchedQuantities[fetchedIndex]!;
          rowData[i]['prodName'] = controllers[i][1].text;
        }
      });
    } else {
      print("Invalid index: $rowIndex");
    }
  }

  int? rowslenth=0;
  int? rowslenth2=0;
/*
  void removeRow(int index) {
    setState(() {
      // Remove controllers, focusNodes, and isRowFilled for the specified index
      if (index >= 0 && index < controllers.length) {
        controllers.removeAt(index);
        focusNodes.removeAt(index);
        isRowFilled.removeAt(index);
        rowData.removeAt(index);
        grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
      }
    });
  }
*/

  void clearAllRows() {
    setState(() {
      rowData.clear();
      for (var rowControllers in controllers) {
        for (var controller in rowControllers) {
          controller.clear();
        }
      }
    });
  }
  void updateFieldValidation() {
    bool allValid = true;
    for (var i = 0; i < controllers.length; i++) {
      for (var j = 0; j < 11; j++) {
        if (i < controllers.length &&
            j < controllers[i].length &&
            controllers[i][j].text.isEmpty) {
          allValid = false;
          break;
        }
      }
    }
    // Update any validation-related state here if needed.
  }
  int selectedCheckbox = 1;

  ///pending po suggestion fetch
  Future<void> fetchDataPendingPo() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/fetch__pending_po_datas'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          dataPending = jsonData.cast<Map<String, dynamic>>();
          print(" 555555555555555 $dataPending ");
        });
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to fetch dataPending'),
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
  TextEditingController PONUMBER=TextEditingController();
  void filterDatapending(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = dataPending;
        supCode.clear(); supName.clear();
      } else {
        filteredData = dataPending.where((item) {
          String id = item['pendingOrderNo']?.toString()?.toLowerCase() ?? '';
          return id == searchText.toLowerCase();
        }).toList();
        if (filteredData.isNotEmpty) {
          Map<String, dynamic> order = filteredData.first;
          supCode.text = order['supCode']?.toString() ?? '';
          supName.text = order['supName']?.toString() ?? '';
          PONUMBER.text = order['poNo']?.toString() ?? '';
          print(PONUMBER.text);
          //  invoiceNo.text = order['invoiceNo']?.toString() ?? '';
        } else {
          supCode.clear();supName.clear();
        }
      }
    });
  }



  ///pending number auto generation starts
  int currentPoNumber = 1;
  String? getNameFromJsonDatasalINv(Map<String, dynamic> jsonItem) {
    return jsonItem['pendingOrderNo'];
  }
  String poNumber = "";
  String? poNo;
  List<Map<String, dynamic>> ponumdata = [];
  String? PONO;
  List<Map<String, dynamic>> codedatas = [];
  String generateIdinvNo() {
    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');
    if (PONO != null) {
      String ID = PONO!.substring(7);
      int idInt = int.parse(ID) + 1;
      //   String id = 'PO$year$month/${idInt.toString().padLeft(3, '0')}';
      String id = 'PP$year$month/${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ponumfetchsalINv() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/pendingPO_fetch'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          PONO = getNameFromJsonDatasalINv(item);
          print('pendingOrderNo: $PONO');
        }
        setState(() {
          ponumdata = jsonData.cast<Map<String, dynamic>>();
          poNumber = generateIdinvNo(); // Call generateId here
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
  ///pending number auto generation ends



  /// pending data insert code starts here(1)
  List<Map<String, dynamic>> dataPending = [];
  String checkOrderNo = "";
  Map<String, dynamic> datapendingInsert = {};
  Future<void> insertDataPendingReport(Map<String, dynamic> datapendingInsert) async {
    const String apiUrl = 'http://localhost:3309/pending_insert_PO'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'datapendingInsert': datapendingInsert}),
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
  Future<void> pendingToDatabase() async {
    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');
    if (poNumber.isEmpty) {
      poNumber = 'PP$year$month/001';
    }
    print( "invoiceNo ${invoiceNo.text}");
    try{
      List<Future<void>> insertFutures = [];
      for (var i = 0; i < controllers.length; i++) {
        if (i >= controllers.length) {
          controllers.add(List.generate(11, (j) => TextEditingController()));
        }

        String datepass =DateTime.now().toString();
        print("Inserting data for row $i");
        Map<String, dynamic> datapendingInsert = {
          "poNo": dataPending.any((item) => item['poNo'] == PONUMBER.text) ? PONUMBER.text : poNUMber.text,
          //"poNo":poNUMber,
          "date":datepass.toString(),
          "invoiceNo":invoiceNo.text,
          "pendingOrderNo":poNumber,
          "supCode": supCode.text,
          "supName":supName.text,
          "prodCode": controllers[i][0].text,
          "prodName": controllers[i][1].text,
          'qty':controllers[i][11].text.isNotEmpty?controllers[i][11].text:'0',
          "pincode":pincode.text,
          "deliveryDate":"",
          'unit': controllers[i][2].text,
        };
        insertFutures.add(insertDataPendingReport(datapendingInsert));

        Future.microtask(() {
          setState(() {
            alertVisible=true;
          });
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: const Text("PO Number"),
                  //content:  poNUMber.text.isNotEmpty?Text("${poNUMber.text} had Partially purchased, Pending PO is ${poNumber.toString()} "):Text("$pendingPoNUMber had partially purchase, Pending PO Number is ${poNumber.toString()}    "),
                  content: const Text("Partially purchased"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Purchase()));
                      },
                      child: Text("OK"),
                    ), ]);
            },
          );
        });
        print("Data inserted for row $i");
        print('Inserting data: $datapendingInsert');
      }
      await Future.wait(insertFutures);
/*
      Future.microtask(() {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text("Order Number"),

                content:  poNUMber.text!.isNotEmpty?Text("$poNo had partially ordered, Pending orderNUmber is ${poNumber.toString()}    "):Text("$checkOrderNo had partially ordered, Pending orderNumber is ${poNumber.toString()}    "),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Purchase()));
                    },
                    child: Text("OK"),
                  ), ]);

          },
        );
      });
*/
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }
  /// pending data insert code ends here(1)
  /// pendingpo based fetch a data in page starts
  Future<void> fetchDataByPONumber(String pendingOrderNo) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_pending_po_item?pendingOrderNo=$pendingOrderNo');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;

        setState(() {
          controllers.clear();
          focusNodes.clear();
          isRowFilled.clear();
          rowData.clear();
          for (var i = 0; i < rows.length; i++) {
            List<TextEditingController> rowControllers = [];
            Map<String, dynamic> row = {
              'prodCode': rows[i]['prodCode'],
              'prodName': rows[i]['prodName'],
              'unit':rows[i]['unit'],
              'unit':rows[i]['unit'],
              'qty': rows[i]['qty'],
              'totalWeight': rows[i]['totalWeight'],
              'rate': rows[i]['rate'],
              'amt': rows[i]['amt'],
              'gst': rows[i]['gst'],
              'amtGST': rows[i]['amtGST'],
              'total': rows[i]['total'],
              'rQty': rows[i]['qty'],
              //'aQty': rows[i]['qty'],
            };

            for (int j = 0; j < 12; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }

            controllers.add(rowControllers);
            focusNodes.add(List.generate(12, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);
            fetchedQuantities[i] = double.tryParse(rows[i]['qty']) ?? 0.0;

          }
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  /// pendingpo based fetch a data in page ends




  @override
  void dispose() {
    for (var rowControllers in controllers) {
      for (var controller in rowControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }



  int fetchingQTY=0;
  int editingQTY =0;
  int calculateQTY =0;

  TextEditingController invoiceNo=TextEditingController();
  TextEditingController purchaseDate=TextEditingController();
  TextEditingController supCode=TextEditingController();
  TextEditingController supName=TextEditingController();
  TextEditingController supMobile=TextEditingController();
  TextEditingController supAddress=TextEditingController();
  TextEditingController pincode =TextEditingController();
  TextEditingController poNUMber=TextEditingController();
  TextEditingController pendingPoNUMber=TextEditingController();
  TextEditingController grandTotal=TextEditingController();

  int qty =0;
  int recieved =0;
  int pending=0;

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  Map<String, dynamic> dataToInsertRaw = {};
  Map<String, dynamic> dataToInsertRawGsm = {};
  Map<String, dynamic> dataToInsertSupItem2 = {};
  Map<String, dynamic> dataToInsertSupItemGsm = {};

  Future<void> insertDataPoItem2(Map<String, dynamic> dataToInsertSupItem2) async {
    const String apiUrl = 'http://localhost:3309/purchase_entry_item'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertSupItem2': dataToInsertSupItem2}),
      );
      if (response.statusCode == 200) {
        print('TableData inserted successfully');
        if(alertVisible==false) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Purchase"),
                content: const Text(
                    "Saved Successfully"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Purchase()));
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Failed to insert data into the table');
        throw Exception('Failed to insert data into the table');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  Future<void> insertDataPoItemGsm(Map<String, dynamic> dataToInsertSupItemGsm) async {
    const String apiUrl = 'http://localhost:3309/purchase_entry_item_gsm'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertSupItemGsm': dataToInsertSupItemGsm}),
      );
      if (response.statusCode == 200) {
        print('TableData inserted successfully');
        if(alertVisible==false) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Purchase"),
                content: const Text(
                    "Saved Successfully"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Purchase()));
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Failed to insert data into the table');
        throw Exception('Failed to insert data into the table');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> submitItemDataToDatabaseGsm() async {
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers2.length; i++) {
      String purchaseDateString = purchaseDate.text;
      DateTime purchaseDateTime = DateFormat('dd-MM-yyyy').parse(purchaseDateString);
      String formattedPurchaseDate = DateFormat('yyyy-MM-dd').format(purchaseDateTime);

      Map<String, dynamic> dataToInsertSupItemGsm = {
        'invoiceNo':invoiceNo.text,
        "date":date.toString(),
        "poNo": dataPending.any((item) => item['poNo'] == PONUMBER.text) ? PONUMBER.text : poNUMber.text,
        'purchaseDate': formattedPurchaseDate,
        "supName": supName.text,
        "supCode":supCode.text,
        "supAddress": supAddress.text,
        "pincode": pincode.text,
        "supMobile": supMobile.text,
        'prodCode':controllers2[i][0].text,
        'prodName': controllers2[i][1].text,
        'unit': controllers2[i][2].text,
        'sNo': controllers2[i][3].text,
        'totalWeight': controllers2[i][4].text,
        'rate':controllers2[i][5].text,
        'amt':controllers2[i][6].text,
        'gst': controllers2[i][7].text,
        'amtGST': controllers2[i][8].text,
        'total': controllers2[i][9].text,
        'grandTotal':grandTotalGsm,
        'extraCharge':tcsController.text,
        'discount':discountController.text,
        "payType":payType,
      };
      insertFutures.add(insertDataPoItemGsm(dataToInsertSupItemGsm));
    }

    try {
      await Future.wait(insertFutures);

      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }
  Future<void> submitItemDataToDatabase() async {
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers.length; i++) {
      String purchaseDateString = purchaseDate.text;
      DateTime purchaseDateTime = DateFormat('dd-MM-yyyy').parse(purchaseDateString);
      String formattedPurchaseDate = DateFormat('yyyy-MM-dd').format(purchaseDateTime);

      Map<String, dynamic> dataToInsertSupItem2 = {
        'invoiceNo':invoiceNo.text,
        "date":date.toString(),
        // "poNo":poNUMber.text,
        //        "poNo":poNUMber.text.isEmpty? pendingPoNUMber.text:poNUMber.text,
        "poNo": dataPending.any((item) => item['poNo'] == PONUMBER.text) ? PONUMBER.text : poNUMber.text,
        'purchaseDate': formattedPurchaseDate,
        /*"supName": supplierInfo["supName"].toString(),
        "supCode": supplierInfo["supCode"].toString(),
        "supAddress": supplierInfo["supAddress"].toString(),
        "supMobile": supplierInfo["supMobile"].toString(),*/
        "supName": supName.text,
        "supCode":supCode.text,
        "supAddress": supAddress.text,
        "pincode": pincode.text,
        "supMobile": supMobile.text,
        'prodCode':controllers[i][0].text,
        'prodName': controllers[i][1].text,
        'unit': controllers[i][2].text,
        'qty': controllers[i][3].text,
        'totalWeight': controllers[i][4].text,
        'rate':controllers[i][5].text,
        'amt':controllers[i][6].text,
        'gst': controllers[i][7].text,
        'amtGST': controllers[i][8].text,
        'total': controllers[i][9].text,
        'grandTotal':grandTotal.text,
        "payType":payType,
        'returnTotal':"0.00"
      };
      insertFutures.add(insertDataPoItem2(dataToInsertSupItem2));
    }

    try {
      await Future.wait(insertFutures);

      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }


  bool isDuplicateProductCode(String productCode, int currentRowIndex) {
    for (int i = 0; i < controllers.length; i++) {
      if (i != currentRowIndex &&
          controllers[i][0].text == productCode) {
        return true;
      }
    }
    return false;
  }
  bool isDuplicateProductName(String productName, int currentRowIndex) {
    for (int i = 0; i < controllers.length; i++) {
      if (i != currentRowIndex &&
          controllers[i][1].text == productName) {
        return true;
      }
    }
    return false;
  }

  double calculateContainerWidth(String value) {
    // You can define your own logic to calculate the width based on the value
    // For example, you can set a threshold value and increase the width if the value exceeds that threshold.
    double threshold = 10000;

    if (value.isEmpty) {
      return 110; // Default width when the field is empty
    } else {
      double numericValue = double.parse(value);
      return numericValue > threshold ? 200 : 110; // Adjust the threshold and widths based on your requirement
    }
  }







  Future<bool> checkForDuplicate(String prodCode) async {
    const String apiUrl = 'http://localhost:3309/fetch_productcode_duplicate'; // Replace with your server endpoint

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> sizeData = jsonDecode(response.body);
        return sizeData.any((item) => item['prodCode'] == prodCode);
      } else {
        print('Failed to fetch data');
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  Future<void> insertDataRaw(Map<String, dynamic> dataToInsertRaw) async {
    const String apiUrl = 'http://localhost:3309/Raw_material_entry'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertRaw': dataToInsertRaw}),
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
  Future<void> submitItemDataToRaw() async {
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers.length; i++) {
      String purchaseDateString = purchaseDate.text;
      DateTime purchaseDateTime = DateFormat('dd-MM-yyyy').parse(purchaseDateString);
      String formattedPurchaseDate = DateFormat('yyyy-MM-dd').format(purchaseDateTime);

      Map<String, dynamic> dataToInsertRaw = {
        "date":date.toString(),
        'prodCode':controllers[i][0].text,
        'prodName': controllers[i][1].text,
        'unit':controllers[i][2].text,
        'qty': controllers[i][3].text,

      };
      insertFutures.add(insertDataRaw(dataToInsertRaw));
    }

    try {
      await Future.wait(insertFutures);
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  Future<bool> checkForDuplicateGsm(String prodCode, String sNo) async {
    const String apiUrl = 'http://localhost:3309/fetch_productcode_duplicate_gsm'; // Replace with your server endpoint

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> sizeData = jsonDecode(response.body);
        return sizeData.any((item) => item['prodCode'] == prodCode && item['sNo'] == sNo);
      } else {
        print('Failed to fetch data');
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  Future<void> insertDataRawGsm(Map<String, dynamic> dataToInsertRawGsm) async {
    const String apiUrl = 'http://localhost:3309/Raw_material_entry_gsm'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertRawGsm': dataToInsertRawGsm}),
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
  Future<void> submitItemDataToRawGsm() async {
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers2.length; i++) {
      String purchaseDateString = purchaseDate.text;
      DateTime purchaseDateTime = DateFormat('dd-MM-yyyy').parse(purchaseDateString);
      String formattedPurchaseDate = DateFormat('yyyy-MM-dd').format(purchaseDateTime);

      Map<String, dynamic> dataToInsertRawGsm = {
        "date":date.toString(),
        'prodCode':controllers2[i][0].text,
        'prodName': controllers2[i][1].text,
        'unit':controllers2[i][2].text,
        'sNo': controllers2[i][3].text,
        'totalweight': controllers2[i][4].text,
      };
      insertFutures.add(insertDataRawGsm(dataToInsertRawGsm));
    }

    try {
      await Future.wait(insertFutures);
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  Future<void> addRawMaterialGsm(String prodCode, String prodName, String unit,int sNo,String modifyDate,String totalweight) async {
    final Uri url = Uri.parse('http://localhost:3309/addRawMaterialGsm'); // Replace with your actual backend URL

    final response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'prodCode': prodCode,
        'prodName': prodName,
        'unit':unit.toString(),
        'sNo': sNo,
        "modifyDate":date.toString(),
        'totalweight':totalweight,
      }),
    );

    if (response.statusCode == 200) {
      print('Update  raw material successful');
    } else {
      print('Failed to update. raw material  Status code: ${response.statusCode}');
      throw Exception('Failed to update raw material');
    }
  }
  Future<void> addRawMaterial(String prodCode, String prodName, String unit,int qty,String modifyDate) async {
    final Uri url = Uri.parse('http://localhost:3309/addRawMaterial'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'prodCode': prodCode,
        'prodName': prodName,
        'unit':unit.toString(),
        'qty': qty,
        "modifyDate":date.toString(),
      }),
    );

    if (response.statusCode == 200) {
      print('Update  raw material successful');
    } else {
      print('Failed to update. raw material  Status code: ${response.statusCode}');
      throw Exception('Failed to update raw material');
    }
  }

  Future<String> fetchProductName(String prodCode) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/fetchProductName'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prodCode': prodCode}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['prodName'];
    } else {
      throw Exception('Failed to fetch product name');
    }
  }
  Future<String> fetchProductCode(String prodName) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/fetchProductCode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prodName': prodName}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['prodCode'];
    } else {
      throw Exception('Failed to fetch product code');
    }
  }


  String selectedInvoiceNo = '';
  String selectedPoInvoiceNo = '';
  final FocusNode _suppliernameFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_suppliernameFocusNode);
    });
    fetchDataPendingPo();
    fetchData();//add Row
    fetchData2();
     addRow2();
    ponumfetchsalINv();
    fetchDataSup();
    calculateGrandTotalGsm();

    fetchPono();
  }

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> dataSup = [];
  List<Map<String, dynamic>> data2 = [];
  List<Map<String, dynamic>> data3 = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> filteredData2 = [];
  List<Map<String, dynamic>> filteredData3 = [];
  void filterData2(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData2 = data2;
        supMobile.clear();
        supAddress.clear();
        pincode.clear();
        grandTotal.clear();
      } else {
        final existingSupplier = data2.firstWhere(
              (item) => item['supCode']?.toString() == searchText,
          orElse: () => {},
          // Use an empty map literal as the default value
        );
        if (existingSupplier.isNotEmpty) {
          supMobile.text = existingSupplier['supMobile']?.toString() ?? '';
          supAddress.text = existingSupplier['supAddress']?.toString() ?? '';
          pincode.text = existingSupplier['pincode']?.toString() ?? '';
        } else {
          supMobile.clear();
          supAddress.clear();
          pincode.clear();
          grandTotal.clear();
        }
      }
    });
  }
  Future<void> fetchData2() async {
    try {
      final url = Uri.parse('http://localhost:3309/fetch_supplier_data/');
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


  bool isMachineNameExists(String name) {
    return data3.any((item) => item['poNo'].toString().toLowerCase() == name.toLowerCase());
  }


  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/fetch_po_datas'));
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
        supCode.clear(); supName.clear();
      } else {
        filteredData = data.where((item) {
          String id = item['poNo']?.toString()?.toLowerCase() ?? '';
          return id == searchText.toLowerCase();
        }).toList();
        if (filteredData.isNotEmpty) {
          Map<String, dynamic> order = filteredData.first;
          supCode.text = order['supCode']?.toString() ?? '';
          supName.text = order['supName']?.toString() ?? '';
        } else {
          supCode.clear();supName.clear();
        }
      }
    });
  }
  bool isDataSaved = false;
  int? aQty =0;
  int? eqty =0;
  // String itemCode = '';
  // String itemName = '';
  // String quantity = '';


  Future<void> fetchPono() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_purchase'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          data3 = jsonData.cast<Map<String, dynamic>>();
        });
      } else {
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
  void filterPoNo(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredData3 = data3.where((item) {
          final custName = item[''].toString().toLowerCase();
          return custName.contains(query.toLowerCase());
        }).toList();
      } else {
        filteredData3 = List.from(data3);
      }
    });
  }
  Map<int, double> fetchedQuantities = {};
  Map<int, double> fetchedtotalWeight = {};
  Set<String> selectedProducts = Set();

  Future<List<String>> fetchSuggestions(String pattern) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/fetchSuggestions'), // Replace with your actual endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'pattern': pattern}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['suggestions']);
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }
  void showWarningMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert box
              },
            ),
          ],
        );
      },
    );
  }
  Future<String> fetchUnitInPO(String prodCode, String prodName) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/fetchUnitInPO'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prodCode': prodCode, 'prodName': prodName}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['unit'];
    } else {
      throw Exception('Failed to fetch unit from PO table');
    }
  }
  void addRow2() {
    setState(() {
      List<TextEditingController> rowControllers = [];
      List<FocusNode> rowFocusNodes = [];

      for (int j = 0; j < 10; j++) {
        rowControllers.add(TextEditingController());
        rowFocusNodes.add(FocusNode());
      }

      controllers2.add(rowControllers);
      isRowFilled.add(false);

      Map<String, dynamic> row = {
        'prodCode': '',
        'prodName': '',
        'unit':'',
        'qty': '',
      };

      rowData.add(row);

      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(rowFocusNodes[0]);
      });
    });
  }

  Future<void> fetchDataByInvoiceNumber(String poNumber) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_po_item?poNo=$poNumber');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;

        setState(() {
          controllers.clear();
          focusNodes.clear();
          isRowFilled.clear();
          rowData.clear();
          for (var i = 0; i < rows.length; i++) {
            List<TextEditingController> rowControllers = [];
            Map<String, dynamic> row = {
              'prodCode': rows[i]['prodCode'],
              'prodName': rows[i]['prodName'],
              'unit':rows[i]['unit'],
              'qty': rows[i]['qty'],
              'totalWeight': rows[i]['totalWeight'],
              'rate': rows[i]['rate'],
              'amt': rows[i]['amt'],
              'gst': rows[i]['gst'],
              'amtGST': rows[i]['amtGST'],
              'total': rows[i]['total'],
              'rQty': rows[i]['qty'],
              //'aQty': rows[i]['qty'],
            };

            for (int j = 0; j < 12; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }

            controllers.add(rowControllers);
            focusNodes.add(List.generate(12, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);
            fetchedQuantities[i] = double.tryParse(rows[i]['qty']) ?? 0.0;
            //    fetchedtotalWeight[i] = double.tryParse(rows[i]['totalWeight']) ?? 0.0;

          }
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  /// fetch supplier
  bool readOnlyFields = false;
  String selectedCustomer=" ";

  Future<void> insertDataSup(Map<String, dynamic> dataToInsertSup) async {
    const String apiUrl = 'http://localhost:3309/supplier_data'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertSup': dataToInsertSup}),
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
  Future<void> supDataToDatabase() async {
    List<Future<void>> insertFutures = [];
    Map<String, dynamic> dataToInsertSup = {
      'date': date.toString(),
      'supName': supName.text,
      'supCode': supCode.text,
      'supAddress': supAddress.text,
      'pincode':pincode.text,
      'supMobile': supMobile.text,
    };
    insertFutures.add(insertDataSup(dataToInsertSup));
    await Future.wait(insertFutures);
  }
  Future<List<dynamic>> fetchSizeData() async {
    const String apiUrl = 'http://localhost:3309/fetch_supCode/'; // Replace with your server details

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
  Future<bool> checkForDuplicateSup(String size) async {
    List<dynamic> sizeData = await fetchSizeData();
    for (var item in sizeData) {
      if (item['supCode'] == size) {
        return true; // Size already exists, return true
      }
    }
    return false; // Size is unique, return false
  }
  void filterDataSup(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = dataSup;
        readOnlyFields = false;
        supCode.clear();
        supAddress.clear();
        pincode.clear();
        supMobile.clear();
      } else {
        final existingSupplier = dataSup.firstWhere(
              (item) => item['supName']?.toString() == searchText,
          orElse: () => {}, // Use an empty map literal as the default value
        );

        if (existingSupplier.isNotEmpty) {
          // Supplier found, populate fields
          readOnlyFields = true;
          supCode.text = existingSupplier['supCode']?.toString() ?? '';
          supAddress.text = existingSupplier['supAddress']?.toString() ?? '';
          supMobile.text = existingSupplier['supMobile']?.toString() ?? '';
          pincode.text = existingSupplier['pincode']?.toString() ?? '';
        } else {
          readOnlyFields = false;
          int maxCodeNumber = 0;
          for (var item in dataSup) {
            final supCodeStr = item['supCode']?.toString() ?? '';
            if (supCodeStr.startsWith('S') && supCodeStr.length == 4) {
              final codeNumber = int.tryParse(supCodeStr.substring(1));
              if (codeNumber != null && codeNumber > maxCodeNumber) {
                maxCodeNumber = codeNumber;
              }
            }
          }
          final newCode = 'S${(maxCodeNumber + 1).toString().padLeft(3, '0')}';
          supCode.text = newCode;
          supAddress.clear();
          supMobile.clear();
          pincode.clear();
        }
      }
    });
  }
  Future<void> fetchDataSup() async {
    try {
      final url = Uri.parse('http://localhost:3309/fetch_supplier/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          dataSup = itemGroups.cast<Map<String, dynamic>>();
        });

        print('Data: $dataSup');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    poNUMber.addListener(() {
      filterData(poNUMber.text);
      fetchDataByInvoiceNumber(poNUMber.text);
    });
    pendingPoNUMber.addListener(() {
      filterDatapending(pendingPoNUMber.text);
      fetchDataByPONumber(pendingPoNUMber.text);
    });
    supCode.addListener(() {
      filterData2(supCode.text);
    });
    supName.addListener(() {
      filterDataSup(supName.text);
    });
    double screenWidth = MediaQuery.of(context).size.width;
    return MyScaffold(
        route: "purchase_entry",backgroundColor: Colors.white,
        body:  Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                  children: [
                    SizedBox(height: 15,),
                    SizedBox(
                      //width: 720,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity, // Set the width to full page width
                          padding: EdgeInsets.all(14.0), // Add padding for spacing
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey), // Add a border for the box
                            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                          ),
                          child: Wrap(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                            children:[    const Icon(Icons.local_grocery_store, size:30),
                                              Text("Purchase Entry",style: TextStyle(fontSize:screenWidth * 0.019,fontWeight: FontWeight.bold),),
                                            ]),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: selectedCheckbox == 1,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  pendingPoNUMber.clear();
                                                  errorMessage ="";

                                                  if (value != null && value) {
                                                    selectedCheckbox = 1;
                                                  } else {
                                                    // Toggle between 1 and 2
                                                    selectedCheckbox = selectedCheckbox == 1 ? 2 : 1;
                                                  }
                                                });
                                              },
                                            ),
                                            Text("PO"),
                                            Checkbox(
                                              value: selectedCheckbox == 3,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  poNUMber.clear();
                                                  errorMessage ="";
                                                  //  checkOrderNo ="";
                                                  if (value != null && value) {
                                                    selectedCheckbox = 3;
                                                  } else {
                                                    selectedCheckbox = selectedCheckbox == 3 ? 1 : 3;
                                                  }
                                                });
                                              },
                                            ),
                                            const Text("GSM"),
                                            Checkbox(
                                              value: selectedCheckbox == 2,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  poNUMber.clear();
                                                  errorMessage ="";
                                                  //  checkOrderNo ="";
                                                  if (value != null && value) {
                                                    selectedCheckbox = 2;
                                                  } else {
                                                    // Toggle between 2 and 1
                                                    selectedCheckbox = selectedCheckbox == 2 ? 1 : 2;
                                                  }
                                                });
                                              },
                                            ),
                                            Text("Pending"),
                                          ],
                                        ),


                                      ],
                                    ),
                                    //poNumber textformfield
                                    Column(
                                      children: [
                                        Visibility(
                                          visible: selectedCheckbox == 1 || selectedCheckbox == 3 ,
                                          child: SizedBox(
                                            width: 140,
                                            height: 36,
                                            child: TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: poNUMber,focusNode: _suppliernameFocusNode,
                                                style: const TextStyle(fontSize: 13),
                                                onChanged: (value) {
                                                  setState(() {
                                                    errorMessage = null;

                                                  });
                                                },
                                                inputFormatters: [
                                                  UpperCaseTextFormatter(),
                                                ],
                                                decoration: InputDecoration(
                                                  // suffixIcon: Icon(Icons.search),
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  labelText: "PO Number",
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
                                                  (item['poNo']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()) &&
                                                      (selectedCheckbox != 1 || !item['prodName'].toString().startsWith('GSM')))
                                                      .map((item) => item['poNo'].toString())
                                                      .toSet() // Remove duplicates using a Set
                                                      .toList();

                                                  suggestions.removeWhere((existingInvoiceNo) =>
                                                  isMachineNameExists(existingInvoiceNo) &&
                                                      existingInvoiceNo != poNUMber.text);

                                                  suggestions = suggestions.take(5).toList();
                                                } else {
                                                  suggestions = [];
                                                }
                                                return suggestions;
                                              },

                                              itemBuilder: (context, suggestion) {
                                                return ListTile(
                                                  title: Text(suggestion),
                                                );
                                              },
                                              onSuggestionSelected: (suggestion) {
                                                setState(() {
                                                  selectedInvoiceNo = suggestion;
                                                  poNUMber.text = suggestion;
                                                  if (isMachineNameExists(poNUMber.text)) {
                                                    setState(() {
                                                      errorMessage = '* This PO Number is Already invoiced';
                                                    });
                                                  }
                                                });
                                                print('Selected Invoice Number: $selectedInvoiceNo');
                                              },
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: selectedCheckbox ==2,

                                          child: SizedBox(
                                            width: 140,
                                            height: 36,
                                            child: TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: pendingPoNUMber,
                                                style: const TextStyle(fontSize: 13),
                                                onChanged: (value) {
                                                  setState(() {
                                                    errorMessage = null; // Reset error message when the user types
                                                  });
                                                },
                                                inputFormatters: [
                                                  UpperCaseTextFormatter(),
                                                ],
                                                decoration: InputDecoration(
                                                  // suffixIcon: Icon(Icons.search),
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  labelText: "Pending PO Number",
                                                  labelStyle: TextStyle(fontSize: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              suggestionsCallback: (pattern) async {
                                                List<String> suggestions;
                                                if (pattern.isNotEmpty) {
                                                  suggestions = dataPending
                                                      .where((item) =>
                                                      (item['pendingOrderNo']?.toString()?.toLowerCase() ?? '')
                                                          .startsWith(pattern.toLowerCase()))
                                                      .map((item) => item['pendingOrderNo'].toString())
                                                      .toSet() // Remove duplicates using a Set
                                                      .toList();
                                                  suggestions.removeWhere((existingInvoiceNo) =>
                                                  isMachineNameExists(existingInvoiceNo) &&
                                                      existingInvoiceNo != pendingPoNUMber.text);
                                                  suggestions = suggestions.take(5).toList();
                                                } else {
                                                  suggestions = [];
                                                }
                                                return suggestions;
                                              },
                                              itemBuilder: (context, suggestion) {
                                                return ListTile(
                                                  title: Text(suggestion),
                                                );
                                              },
                                              onSuggestionSelected: (suggestion) {
                                                if (isMachineNameExists(suggestion)) {
                                                  setState(() {
                                                    errorMessage = '* This Order already exists';
                                                  });
                                                } else {
                                                  errorMessage = null;
                                                }

                                                setState(() {
                                                  selectedPoInvoiceNo = suggestion;
                                                  pendingPoNUMber.text = suggestion;
                                                });
                                                print('Selected Invoice Number: $selectedPoInvoiceNo');
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //pending po textformfield


                                  ],),

                                Padding(
                                  padding: const EdgeInsets.only(top:8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
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
                                                purchaseDate.text =
                                                    DateFormat(
                                                        'dd-MM-yyyy')
                                                        .format(
                                                        pickDate);
                                                errorMessage=null;

                                              });
                                            }
                                          },
                                          controller: purchaseDate, // Set the initial value of the field to the selected date
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelText: "Purchase Date",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      SizedBox(
                                        width: 140,
                                        child: TextFormField(
                                          // readOnly: invoiceEditable,
                                          controller: invoiceNo,
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
                                            fillColor: Colors.white,
                                            labelText: "Invoice Number",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),

                                      ),
                                    ],),
                                ),
                              ]
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      // width: 720,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity, // Set the width to full page width
                          padding: EdgeInsets.all(16.0), // Add padding for spacing
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.grey), // Add a border for the box
                            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                          ),
                          child: Wrap(
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Supplier Details",style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:16,
                                        ),),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                            errorMessage ?? '',
                                            style: TextStyle(color: Colors.red,fontSize: 13),
                                          ),
                                        ),


                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Wrap(
                                      children: [
                                        SizedBox(
                                          width: 240,height: 70,
                                          child: TextFormField(
                                            readOnly: true,
                                            controller:supCode,
                                            style: TextStyle(fontSize: 13),
                                            onChanged: (value) {
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              supCode.value = supCode.value.copyWith(
                                                text: capitalizedValue,
                                                selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                              );

                                            },

                                            decoration: InputDecoration(
                                                labelText: "Supplier Code",
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10,),
                                                )
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 60,),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 36),
                                          child:SizedBox(
                                            width: 240,
                                            height:50,
                                            child: TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: supName,
                                               // focusNode: _suppliernameFocusNode,
                                                onChanged: (value) {
                                                  String capitalizedValue = capitalizeFirstLetter(value);
                                                  supName.value = supName.value.copyWith(
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
                                                  labelText: "Supplier/Company Name",
                                                  labelStyle: TextStyle(fontSize: 16,color: Colors.black),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              suggestionsCallback: (pattern) async {
                                                if (pattern.isEmpty) {
                                                  return [];
                                                }
                                                List<String> suggestions = dataSup
                                                    .where((item) =>
                                                (item['supName']?.toString()?.toLowerCase() ?? '').contains(pattern.toLowerCase()) ||
                                                    (item['supCode']?.toString()?.toLowerCase() ?? '').contains(pattern.toLowerCase()))
                                                    .map((item) => item['supName'].toString())
                                                    .toSet()
                                                    .toList();
                                                return suggestions;
                                              },
                                              itemBuilder: (context, suggestion) {
                                                Map<String, dynamic> customerData = dataSup.firstWhere(
                                                      (item) => item['supName'].toString() == suggestion,
                                                  orElse: () => Map<String, dynamic>(),
                                                );
                                                return ListTile(
                                                  title: Text('${customerData['supName']} (${customerData['supCode']})'),
                                                );
                                              },
                                              onSuggestionSelected: (suggestion) {
                                                Map<String, dynamic> customerData = dataSup.firstWhere(
                                                      (item) => item['supName'].toString() == suggestion,
                                                  orElse: () => Map<String, dynamic>(),
                                                );
                                                setState(() {
                                                  selectedCustomer = suggestion;
                                                  supName.text = suggestion;
                                                });
                                                print('Selected Customer: $selectedCustomer, Customer Code: ${customerData['supCode']}');
                                              },
                                            ),
                                          ),

                                          /* SizedBox(
                                            width: 220,
                                            height: 34,
                                            child:
                                            TypeAheadFormField<String>(
                                              hideKeyboard: checkName,
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: supName,
                                                onChanged: (value) {
                                                  // fetchData5();
                                                  String capitalizedValue = capitalizeFirstLetter(value);
                                                  supName.value = supName.value.copyWith(
                                                    text: capitalizedValue,
                                                    selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                  );
                                                },
                                                style: const TextStyle(fontSize: 13),
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  labelText: "Supplier Name", // Update label
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
                                                    .where((item) {
                                                  String empName = item['supName']?.toString()?.toLowerCase() ?? '';
                                                  String empId = item['supCode']?.toString()?.toLowerCase() ?? '';
                                                  return empName.contains(pattern.toLowerCase()) || empId.contains(pattern.toLowerCase());
                                                })
                                                    .map<String>((item) =>
                                                '${item['supName']} (${item['supCode']})') // Modify this line to match your data structure
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
                                                setState(() {
                                                  selectedCustomer = selectedEmpName;
                                                  supName.text = selectedEmpName;
                                                  checkName = true;
                                                });
                                                print('Selected Customer: $selectedCustomer, ID: $selectedEmpID');
                                              },
                                            ),
                                          ),*/
                                        ),
                                        SizedBox(width: 60,),
                                        SizedBox(
                                          width: 240,height: 70,
                                          child: TextFormField(
                                            readOnly: selectedCheckbox != 3,
                                            controller: supAddress,
                                            style: TextStyle(fontSize: 13),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              labelText: "Supplier Address",
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
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Wrap(
                                      children: [
                                        SizedBox(
                                          width: 240,height: 70,
                                          child: TextFormField(
                                            readOnly: selectedCheckbox != 3,
                                            controller: pincode,
                                            //initialValue: supplierInfo['supAddress'].toString()??'',
                                            onChanged: (value) {
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              pincode.value = pincode.value.copyWith(
                                                text: capitalizedValue,
                                                //selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                              );
                                              setState(() {
                                                errorMessage = null; // Reset error message when user types
                                              });
                                            },
                                            style: TextStyle(fontSize: 13),

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
                                        SizedBox(width: 60,),
                                        SizedBox(
                                          width: 240,height: 70,
                                          child: TextFormField(
                                            readOnly: selectedCheckbox != 3,
                                            controller: supMobile,
                                            //initialValue: supplierInfo['supMobile'].toString()??'',
                                            style: TextStyle(fontSize: 13),
                                            onChanged: (value){
                                            },
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              prefixText: "+91 ",
                                              labelText: "Supplier Mobile",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10,),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 60,),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 38),
                                          child: SizedBox(
                                            width: 240,height:38,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButtonFormField<String>(
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                value: payType,
                                                hint:Text("Payment Type",style:TextStyle(fontSize: 13),),
                                                items: <String>['Cash','Cheque','NEFT','RTGS']
                                                    .map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: TextStyle(fontSize: 13),
                                                    ),
                                                  );
                                                }).toList(),
                                                // Step 5.
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    payType = newValue!;
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("Product Details",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:16,
                                    ),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  children: [
                                    if ( selectedCheckbox == 3)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: FocusTraversalGroup(
                                        policy: OrderedTraversalPolicy(),
                                        child: Table(
                                          border: TableBorder.all(color: Colors.black54),
                                          columnWidths: const <int, TableColumnWidth>{
                                            0: FixedColumnWidth(110),
                                            1: FixedColumnWidth(150),
                                            2: FixedColumnWidth(80),
                                            3: FixedColumnWidth(60),
                                            4: FixedColumnWidth(100),
                                            5: FixedColumnWidth(80),
                                            6: FixedColumnWidth(100),
                                            7: FixedColumnWidth(60),
                                            8: FixedColumnWidth(100),
                                            9: FixedColumnWidth(120),
                                            10: FixedColumnWidth(110),
                                          },
                                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                          children: [
                                            // Table header row
                                            TableRow(
                                              children: [
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height: 8),
                                                          Text('Product Code', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          SizedBox(height: 8),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Column(
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Column(
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text('Unit', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Column(
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text('S.No', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Column(
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text('Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Column(
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text('Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Column(
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Column(
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text('Gst %', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Column(
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text('Gst Amt', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Column(
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade100,
                                                    child: const Column(
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Table data rows
                                            for (var i = 0; i < controllers2.length; i++)
                                              TableRow(
                                                children: [
                                                  for (var j = 0; j < 10; j++)
                                                    TableCell(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: j == 3
                                                            ? TextFormField(
                                                          style: TextStyle(fontSize: 13),
                                                          controller: controllers2[i][j],
                                                          inputFormatters: [
                                                          ],
                                                          decoration: const InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          ),
                                                          onChanged: (value) {
                                                            final int rowIndex = i;
                                                            final int colIndex = j;
                                                            final String key = _getKeyForColumn(colIndex);
                                                            updateFieldValidation();
                                                            setState(() {
                                                              rowData[rowIndex][key] = value;
                                                              errorMessage = ''; // Clear the error message when the user types in the table
                                                            });
                                                          },
                                                        )
                                                            : j == 2
                                                            ? TextFormField(
                                                          enabled: false, // Set this to false to make it read-only

                                                          style: TextStyle(fontSize: 13),
                                                          controller: controllers2[i][j],
                                                          decoration: const InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          ),
                                                          onChanged: (value) {
                                                            final int rowIndex = i;
                                                            final int colIndex = j;
                                                            final String key = _getKeyForColumn(colIndex);

                                                            updateFieldValidation();
                                                            setState(() {
                                                              rowData[rowIndex][key] = value;
                                                            });
                                                          },
                                                        )
                                                            : (j == 0 || j == 1)  ? TypeAheadFormField<String>(
                                                            textFieldConfiguration: TextFieldConfiguration(
                                                              controller: controllers2[i][j],
                                                              style: TextStyle(fontSize: 13),
                                                              inputFormatters: [
                                                                UpperCaseTextFormatter(),
                                                              ],
                                                              decoration: const InputDecoration(
                                                                filled: true,
                                                                fillColor: Colors.white,
                                                              ),

                                                              onChanged: (value) async {
                                                                final int rowIndex = i;
                                                                final int colIndex = j;
                                                                final String key = _getKeyForColumn(colIndex);

                                                                updateFieldValidation();
                                                                setState(() {
                                                                  rowData[rowIndex][key] = value;
                                                                });

                                                                // Fetch unit based on prodCode and prodName
                                                                final prodCode = controllers2[rowIndex][0].text;
                                                                final prodName = controllers2[rowIndex][1].text;
                                                                final unit = await fetchUnitInPO(prodCode, prodName);

                                                                // Update the unit controller
                                                                controllers2[rowIndex][2].text = unit;
                                                                setState(() {
                                                                  rowData[rowIndex][key] = value;
                                                                  errorMessage = ''; // Clear the error message when the user types in the table
                                                                });
                                                              },
                                                            ),
                                                            suggestionsCallback: (pattern) async {
                                                              return await fetchSuggestions(pattern);
                                                            },
                                                            itemBuilder: (context, suggestion) {
                                                              return ListTile(
                                                                title: Text(suggestion),
                                                              );
                                                            },
                                                            // ...

                                                            onSuggestionSelected: (suggestion) async {
                                                              final int rowIndex = i;
                                                              final int colIndex = j;
                                                              final String key = _getKeyForColumn(colIndex);

                                                              final match = RegExp(r'^(.+?) - (.+)$').firstMatch(suggestion);
                                                              if (match != null) {
                                                                final productCode = match.group(1)?.trim();
                                                                final productName = match.group(2)?.trim();
                                                                final selectedProductKey = '$productCode-$productName';

                                                                if (controllers2.any((row) => row[0].text == productCode && row != controllers2[rowIndex])) {
                                                                  showWarningMessage('Product with code $productCode already selected in another row!');
                                                                  setState(() {
                                                                    controllers2[rowIndex][0].text = ''; // Clear the product code
                                                                    controllers2[rowIndex][1].text = ''; // Clear the product code
                                                                  });
                                                                } else {
                                                                  if (selectedProducts.isNotEmpty) {
                                                                    final previousProductName = selectedProducts.last.split('-').last;

                                                                    if ((previousProductName.startsWith('GSM') && !productName!.startsWith('GSM')) ||
                                                                        (!previousProductName.startsWith('GSM') && productName!.startsWith('GSM'))) {
                                                                      showWarningMessage('Product name mismatched Please check!');
                                                                      setState(() {
                                                                        controllers2[rowIndex][0].text = '';
                                                                        controllers2[rowIndex][1].text = '';
                                                                        // Clear the product code
                                                                      });
                                                                      return;
                                                                    }
                                                                  }

                                                                  selectedProducts.add(selectedProductKey);
                                                                  setState(() {
                                                                    controllers2[rowIndex][0].text = productCode!;
                                                                    controllers2[rowIndex][1].text = productName!;
                                                                  });

                                                                  // Fetch unit based on prodCode and prodName
                                                                  final unit = await fetchUnitInPO(productCode!, productName!);

                                                                  controllers2[rowIndex][2].text = unit;
                                                                }
                                                              }
                                                            }
                                                        ):
                                                        TextFormField(
                                                          style: TextStyle(fontSize: 13,
                                                            color: (j == 4 || j == 5 || j == 6 || j == 7 || j == 8 || j == 9 ) ? Colors.black : Colors.grey, // Set the text color
                                                          ),
                                                          controller: controllers2[i][j],
                                                          inputFormatters: [
                                                            UpperCaseTextFormatter(),
                                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                            if (j == 7)
                                                              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,1})?$')),
                                                          ],
                                                          decoration: const InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          ),
                                                          onChanged: (value) async {
                                                            final int rowIndex2 = i;
                                                            final int colIndex2 = j;
                                                            final String key = _getKeyForColumn(colIndex2);

                                                            setState(() {
                                                              double weight= double.tryParse(controllers2[rowIndex2][4].text) ?? 0.0;
                                                              double rate = double.tryParse(controllers2[rowIndex2][5].text) ?? 0.0;
                                                              double gst = double.tryParse(controllers2[rowIndex2][7].text) ?? 0.0;


                                                              double amount = weight * rate;
                                                              double gstAmt = (amount * gst) / 100;
                                                              double total = amount + gstAmt;

                                                              controllers2[rowIndex2][6].text = amount.toStringAsFixed(2);
                                                              controllers2[rowIndex2][8].text = gstAmt.toStringAsFixed(2);
                                                              controllers2[rowIndex2][9].text = total.toStringAsFixed(2);
                                                              grandTotalGsm = calculateGrandTotalGsm();
                                                              print("grandTotalGsm $grandTotalGsm");
                                                            });

                                                          }
                                                        ),
                                                      ),
                                                    ),
                                                  TableCell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(Icons.remove_circle_outline),
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
                                                                          if (controllers2.length == 1) {
                                                                            // If there is only one row, clear the data instead of removing the row
                                                                            clearAllRows();
                                                                            Navigator.of(context).pop();
                                                                          } else {
                                                                            // If there are multiple rows, remove the entire row
                                                                            removeRow2(i);
                                                                            Navigator.of(context).pop();
                                                                          }
                                                                          //Navigator.of(context).pop(); // Close the alert box// Close the alert box
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                          Visibility(
                                                            visible: i == controllers2.length - 1,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [

                                                                IconButton(
                                                                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                                                  onPressed: () {

                                                                    if (controllers2[i][0].text.isNotEmpty && controllers2[i][1].text.isNotEmpty && controllers2[i][2].text.isNotEmpty && controllers2[i][3].text.isNotEmpty) {
                                                                      addRow2();
                                                                    } else {
                                                                      showWarningMessage(' Fields cannot be empty!');
                                                                    }


                                                                  },
                                                                )

                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],

                                        ),
                                      ),
                                    ),
                                    if ( selectedCheckbox == 1 || selectedCheckbox == 2 )
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: FocusTraversalGroup(
                                        policy: OrderedTraversalPolicy(),
                                        child: Table(
                                          border: TableBorder.all(
                                              color: Colors.black54
                                          ),
                                          defaultColumnWidth: const FixedColumnWidth(140.0),
                                          columnWidths:  const <int, TableColumnWidth>{
                                            // 0: FixedColumnWidth(175),
                                            // 1: FixedColumnWidth(175),
                                            2: FixedColumnWidth(100),
                                            3: FixedColumnWidth(100),
                                            4: FixedColumnWidth(100),
                                            5: FixedColumnWidth(100),
                                            6: FixedColumnWidth(100),
                                            7: FixedColumnWidth(100),
                                            8: FixedColumnWidth(115),
                                            9: FixedColumnWidth(0),
                                            10: FixedColumnWidth(0),
                                            11: FixedColumnWidth(60),


                                          },
                                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                          children: [
                                            // Table header row
                                            TableRow(
                                              children: [
                                                TableCell(
                                                  child: Container(
                                                    color:Colors.blue.shade200,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height:15 ),
                                                          Text('Product Code',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          SizedBox(height: 15),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color:Colors.blue.shade200,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height:15),
                                                          Text('Product Name',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          SizedBox(height:15),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),TableCell(
                                                  child: Container(
                                                    color:Colors.blue.shade200,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height:15),
                                                          Text('Unit',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          SizedBox(height:15),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color:Colors.blue.shade200,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height:15),
                                                          Text('Quantity',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          SizedBox(height:15),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color:Colors.blue.shade200,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height: 15),
                                                          Text(' Rate ',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          SizedBox(height: 15),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color:Colors.blue.shade200,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height: 15),
                                                          Text('Amount',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          SizedBox(height: 15),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color:Colors.blue.shade200,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height: 15),
                                                          Text('GST (%)',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          SizedBox(height: 15),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color:Colors.blue.shade200,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height: 15),
                                                          Text('GST Amount',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          SizedBox(height: 15),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color:Colors.blue.shade200,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height: 15),
                                                          Text('Total',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          SizedBox(height: 15),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible:false,
                                                  child: TableCell(
                                                    child: Container(
                                                      color:Colors.blue.shade200,
                                                      child: const Center(
                                                        child: Column(
                                                          children: [
                                                            SizedBox(height: 15),
                                                            Text('R qty',style: TextStyle(fontWeight: FontWeight.bold),),
                                                            SizedBox(height: 15),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(

                                                  visible:false,
                                                  child: TableCell(
                                                    child: Container(
                                                      color:Colors.blue.shade200,
                                                      child: Center(
                                                        child: Column(
                                                          children: [
                                                            const SizedBox(height: 15),
                                                            Text('A qty',style: TextStyle(fontWeight: FontWeight.bold),),
                                                            const SizedBox(height: 15),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Container(
                                                    color:Colors.blue.shade200,
                                                    child: const Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height: 15),
                                                          Text('Action',style: TextStyle(fontWeight: FontWeight.bold),),
                                                          SizedBox(height: 15),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Table data rows
                                            for (var i = 0; i < controllers.length; i++)
                                              TableRow(
                                                children: [
                                                  for (var j = 0; j < 11; j++)
                                                    j==4? TableCell(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: TextFormField(
                                                            style: TextStyle(fontSize: 13,
                                                              color: (j == 0 || j == 1 || j == 2 || j == 5 || rowData[i]['prodName'].startsWith('GSM') || j == 7 || j == 2||j==3) ? Colors.black : Colors.grey, // Set the text color
                                                            ),
                                                            controller: controllers[i][j],
                                                            inputFormatters: [
                                                              UpperCaseTextFormatter(),
                                                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                              if (j == 7)
                                                                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,1})?$')),
                                                            ],
                                                            decoration: const InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                            ),

                                                            textAlign: (j >= 0 && j <= 3) ? TextAlign.center : TextAlign.right,
                                                            enabled: (j == 3 || j == 6 || j == 4),
                                                            onChanged: (value) async {
                                                              final int rowIndex = i;
                                                              final int colIndex = j;
                                                              final String key = _getKeyForColumn(colIndex);
                                                              final productName= await fetchProductName(value);
                                                              final productCode= await fetchProductCode(value);
                                                              updateFieldValidation();
                                                              setState(() {
                                                                rowData[rowIndex][key] = value;
                                                                if (colIndex == 0) {
                                                                  controllers[i][1].clear();
                                                                } else if (colIndex == 1) {
                                                                  controllers[i][0].clear();
                                                                }

                                                                if (productName.isNotEmpty) {
                                                                  controllers[i][1].text = productName;
                                                                }
                                                                if (productCode.isNotEmpty) {
                                                                  controllers[i][0].text = productCode;
                                                                }
                                                                isRowFilled[i] = controllers[i].every((controller) => controller.text.isNotEmpty);
                                                                if (value.isNotEmpty && isDuplicateProductCode(value, rowIndex)) {
                                                                  controllers[rowIndex][1].clear();
                                                                  errorMessage = 'You already entered the\n product code $value.';
                                                                  return;
                                                                }
                                                                if (value.isNotEmpty && isDuplicateProductName(value, rowIndex)) {
                                                                  errorMessage = 'You already entered the\n product Name $value.';
                                                                  controllers[rowIndex][0].clear();
                                                                  return;
                                                                }
                                                                errorMessage = '';




                                                                if( !rowData[i]['prodName'].startsWith('GSM')){
                                                                  if (colIndex == 3 || colIndex == 4 || colIndex == 6) {
                                                                    double quantity = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
                                                                    double rate = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;
                                                                    double gst = double.tryParse(controllers[rowIndex][6].text) ?? 0.0;


                                                                    double amount = quantity * rate;
                                                                    double gstAmt = (amount * gst) / 100;
                                                                    double total = amount + gstAmt;
                                                                    if (quantity > fetchedQuantities[rowIndex]!) {
                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        content: Text('Quantity should be less than or equal to ${fetchedQuantities[rowIndex]}'),
                                                                        duration: const Duration(seconds: 2),
                                                                      ));

                                                                      setState(() {
                                                                        controllers[i][3].text = fetchedQuantities[rowIndex].toString();
                                                                      });
                                                                      return;
                                                                    }


                                                                    controllers[rowIndex][5].text = amount.toStringAsFixed(2);
                                                                    controllers[rowIndex][7].text = gstAmt.toStringAsFixed(2);
                                                                    controllers[rowIndex][8].text = total.toStringAsFixed(2);
                                                                    int? editedqty=  int.parse(controllers[rowIndex][3].text);//10
                                                                    int? receiveqty = int.parse(controllers[rowIndex][9].text);//10
                                                                    int? pendingqty = receiveqty-editedqty;
                                                                    setState(() {

                                                                      qty = receiveqty!;
                                                                      recieved= editedqty;
                                                                      pending= pendingqty;


                                                                      print("  Qty $qty");
                                                                      print(" received Qty $recieved");
                                                                      print(" pending Qty  $pending");
                                                                      // editqty = editedqty;
                                                                    });
                                                                    controllers[rowIndex][10].text = pendingqty.toString();
                                                                    //grandTotalValue = calculateGrandTotal();
                                                                    print("grandTotalValue0 $grandTotalValue");

                                                                  }}
                                                              });
                                                              setState(() {
                                                                fetchingQTY = int.parse(controllers[rowIndex][10].text);
                                                                editingQTY =int.parse(controllers[rowIndex][3].text);
                                                                calculateQTY = fetchingQTY-editingQTY;
                                                                print("calculateQty $calculateQTY");

                                                              });
                                                            }
                                                        ),
                                                      ),
                                                    ) :
                                                    j==4? TableCell(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: TextFormField(
                                                            style: TextStyle(fontSize: 13,
                                                              color: (j == 0 || j == 1 || j == 2 || j == 5 || rowData[i]['prodName'].startsWith('GSM') || j == 7 || j == 2||j==3) ? Colors.black : Colors.grey, // Set the text color
                                                            ),
                                                            controller: controllers[i][j],
                                                            inputFormatters: [UpperCaseTextFormatter(),
                                                              if (j == 7)
                                                                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,1})?$')),FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                            ],
                                                            decoration: const InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                            ),

                                                            textAlign: (j >= 0 && j <= 3) ? TextAlign.center : TextAlign.right,
                                                            enabled: (j == 3 || j == 6 || j == 4),                                                            onChanged: (value) async {
                                                              final int rowIndex = i;
                                                              final int colIndex = j;
                                                              final String key = _getKeyForColumn(colIndex);
                                                              final productName= await fetchProductName(value);
                                                              final productCode= await fetchProductCode(value);


                                                              updateFieldValidation();
                                                              setState(() {
                                                                rowData[rowIndex][key] = value;
                                                                if (colIndex == 0) {
                                                                  controllers[i][1].clear();
                                                                } else if (colIndex == 1) {
                                                                  controllers[i][0].clear();
                                                                }

                                                                if (productName.isNotEmpty) {
                                                                  controllers[i][1].text = productName;
                                                                }
                                                                if (productCode.isNotEmpty) {
                                                                  controllers[i][0].text = productCode;
                                                                }
                                                                isRowFilled[i] = controllers[i].every((controller) => controller.text.isNotEmpty);
                                                                if (value.isNotEmpty && isDuplicateProductCode(value, rowIndex)) {
                                                                  controllers[rowIndex][1].clear();
                                                                  errorMessage = 'You already entered the\n product code $value.';
                                                                  return;
                                                                }
                                                                if (value.isNotEmpty && isDuplicateProductName(value, rowIndex)) {
                                                                  errorMessage = 'You already entered the\n product Name $value.';
                                                                  controllers[rowIndex][0].clear();
                                                                  return;
                                                                }
                                                                errorMessage = '';


                                                                if(!rowData[i]['prodName'].startsWith('GSM')){
                                                                  if (colIndex == 3 || colIndex == 4 || colIndex == 6) {
                                                                    double quantity = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
                                                                    double rate = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;
                                                                    double gst = double.tryParse(controllers[rowIndex][6].text) ?? 0.0;

                                                                    double amount = quantity * rate;
                                                                    double gstAmt = (amount * gst) / 100;
                                                                    double total = amount + gstAmt;
                                                                    if (quantity > fetchedQuantities[rowIndex]!) {
                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        content: Text('Quantity should be less than or equal to ${fetchedQuantities[rowIndex]}'),
                                                                        duration: Duration(seconds: 2),
                                                                      ));

                                                                      setState(() {
                                                                        controllers[i][3].text = fetchedQuantities[rowIndex].toString();
                                                                      });
                                                                      return;
                                                                    }

                                                                    controllers[rowIndex][5].text = amount.toStringAsFixed(2);
                                                                    controllers[rowIndex][7].text = gstAmt.toStringAsFixed(2);
                                                                    controllers[rowIndex][8].text = total.toStringAsFixed(2);
                                                                    int? editedqty=  int.parse(controllers[rowIndex][3].text);//10
                                                                    int? receiveqty = int.parse(controllers[rowIndex][9].text);//10
                                                                    int? pendingqty = receiveqty-editedqty;
                                                                    setState(() {

                                                                      qty = receiveqty!;
                                                                      recieved= editedqty;
                                                                      pending= pendingqty;


                                                                      print("  Qty $qty");
                                                                      print(" received Qty $recieved");
                                                                      print(" pending Qty  $pending");
                                                                      // editqty = editedqty;
                                                                    });
                                                                    controllers[rowIndex][10].text = pendingqty.toString();
                                                                   // grandTotalValue = calculateGrandTotal();
                                                                    print("grandTotalValue1 $grandTotalValue");

                                                                  }}
                                                              });
                                                              setState(() {
                                                                fetchingQTY = int.parse(controllers[rowIndex][9].text);
                                                                editingQTY =int.parse(controllers[rowIndex][3].text);
                                                                calculateQTY = fetchingQTY-editingQTY;
                                                                print("calculateQty $calculateQTY");

                                                              });

                                                            }
                                                        ),
                                                      ),
                                                    )
                                                        :  TableCell(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: TextFormField(
                                                            style: TextStyle(fontSize: 13,
                                                              color: (j == 0 || j == 1 || j == 2 || j == 5 || rowData[i]['prodName'].startsWith('GSM') || j == 7 || j == 2||j==3) ? Colors.black : Colors.grey, // Set the text color
                                                            ),
                                                            controller: controllers[i][j],
                                                            // enabled: !(j == 6 || j == 8 || j == 9) || (rowData[i]['unit'] != 'Kg' && rowData[i]['unit'] != 'Nos'), // Set enabled based on conditions for controllers[i][6], [8], and [9]

                                                            inputFormatters: [UpperCaseTextFormatter(),
                                                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')
                                                              ),
                                                              if (j == 7)
                                                                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,1})?$')),
                                                            ],

                                                            decoration: const InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                            ),

                                                            textAlign: (j >= 0 && j <= 3) ? TextAlign.center : TextAlign.right,
                                                            enabled: (j == 3 || j == 6 || j == 4),                                                            onChanged: (value) async {
                                                              final int rowIndex = i;
                                                              final int colIndex = j;
                                                              final String key = _getKeyForColumn(colIndex);
                                                              final productName= await fetchProductName(value);
                                                              final productCode= await fetchProductCode(value);


                                                              updateFieldValidation();
                                                              setState(() {
                                                                rowData[rowIndex][key] = value;
                                                                if (colIndex == 0) {
                                                                  controllers[i][1].clear();
                                                                } else if (colIndex == 1) {
                                                                  controllers[i][0].clear();
                                                                }

                                                                if (productName.isNotEmpty) {
                                                                  controllers[i][1].text = productName;
                                                                }
                                                                if (productCode.isNotEmpty) {
                                                                  controllers[i][0].text = productCode;
                                                                }
                                                                isRowFilled[i] = controllers[i].every((controller) => controller.text.isNotEmpty);
                                                                if (value.isNotEmpty && isDuplicateProductCode(value, rowIndex)) {
                                                                  controllers[rowIndex][1].clear();
                                                                  errorMessage = 'You already entered the\n product code $value.';
                                                                  return;
                                                                }
                                                                if (value.isNotEmpty && isDuplicateProductName(value, rowIndex)) {
                                                                  errorMessage = 'You already entered the\n product Name $value.';
                                                                  controllers[rowIndex][0].clear();
                                                                  return;
                                                                }
                                                                errorMessage = '';


                                                                if( !rowData[i]['prodName'].startsWith('GSM')){
                                                                  if (colIndex == 3 || colIndex == 4 || colIndex == 6) {
                                                                    double quantity = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
                                                                    double rate = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;
                                                                    double gst = double.tryParse(controllers[rowIndex][6].text) ?? 0.0;

                                                                    double amount = quantity * rate;
                                                                    double gstAmt = (amount * gst) / 100;
                                                                    double total = amount + gstAmt;
                                                                    if (quantity > fetchedQuantities[rowIndex]!) {
                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        content: Text('Quantity should be less than or equal to ${fetchedQuantities[rowIndex]}'),
                                                                        duration: Duration(seconds: 2),
                                                                      ));

                                                                      setState(() {
                                                                        controllers[i][3].text = fetchedQuantities[rowIndex].toString();
                                                                      });
                                                                      return;
                                                                    }

                                                                    controllers[rowIndex][5].text = amount.toStringAsFixed(2);
                                                                    controllers[rowIndex][7].text = gstAmt.toStringAsFixed(2);
                                                                    controllers[rowIndex][8].text = total.toStringAsFixed(2);
                                                                    int? editedqty=  int.parse(controllers[rowIndex][3].text);//10
                                                                    int? receiveqty = int.parse(controllers[rowIndex][9].text);//10
                                                                    int? pendingqty = receiveqty-editedqty;
                                                                    setState(() {

                                                                      qty = receiveqty!;
                                                                      recieved= editedqty;
                                                                      pending= pendingqty;


                                                                      print("  Qty $qty");
                                                                      print(" received Qty $recieved");
                                                                      print(" pending Qty  $pending");
                                                                      // editqty = editedqty;
                                                                    });
                                                                    controllers[rowIndex][11].text = pending.toString();
                                                                    //grandTotalValue = calculateGrandTotal();
                                                                    print("grandTotalValue2 $grandTotalValue");

                                                                  }}
                                                                                                                     });
                                                              setState(() {
                                                                fetchingQTY = int.parse(controllers[rowIndex][9].text);
                                                                editingQTY =int.parse(controllers[rowIndex][3].text);
                                                                calculateQTY = fetchingQTY-editingQTY;
                                                                print("calculateQty $calculateQTY");

                                                              });
                                                            }
                                                        ),
                                                      ),
                                                    ),
                                                  TableCell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [

                                                          //  if (controllers.length ==controllers.length && i != controllers.length - 1) // Render "Add" button only in the last row
                                                          IconButton(
                                                              icon: const Icon(Icons.remove_circle_outline),
                                                              color: Colors.red.shade600,
                                                              onPressed: () {
                                                                if (_formKey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  if (invoiceNo
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(() {
                                                                      errorMessage =
                                                                      "* Enter a invoiceNo";
                                                                    });
                                                                  }
                                                                  else {

                                                                    if (controllers.length > 1) {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (
                                                                            BuildContext context) {
                                                                          return AlertDialog(
                                                                            title: Text('Confirmation'),
                                                                            content: Text('Are you sure you want to remove this row?'),
                                                                            actions: <Widget>[TextButton(child: Text('Cancel'),
                                                                              onPressed: () {Navigator.of(context).pop();},),
                                                                              TextButton(child: Text('Remove'),
                                                                                onPressed: () {removeRow(i);Navigator.of(context).pop(); },),],);
                                                                        },
                                                                      );
                                                                    } else {
                                                                      print(
                                                                          'Cannot remove the first row. At least one row is required.');
                                                                    }
                                                                  }
                                                                }
                                                              }),
                                                          ///addrow                                                      // if (i == controllers.length - 1&&allFieldsFilled) // Render "Add" button only in the last row
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 10,),
                                    Wrap(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.arrow_left_sharp ),
                                              onPressed: () {
                                                onArrowButtonClick();
                                              },
                                            ),
                                            Visibility(
                                              visible: isTextFormFieldsVisible,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 70,
                                                    height: 30,
                                                    child: TextFormField(
                                                      controller: tcsController,
                                                      keyboardType: TextInputType.number,
                                                      decoration: const InputDecoration(labelText: 'Tcs'),
                                                      onChanged: (_) {
                                                        updateGrandTotal();
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  SizedBox(
                                                    width: 70,
                                                    height: 30,
                                                    child: TextFormField(
                                                      controller: discountController,
                                                      keyboardType: TextInputType.number,
                                                      decoration: const InputDecoration(labelText: 'Dis'),
                                                      onChanged: (_) {
                                                        updateGrandTotal();
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                ],
                                              ),
                                            ),
                                            selectedCheckbox != 3
                                                ? Text("Grand Total ₹ $grandTotalValue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
                                                : Text("Grand Total ₹ $grandTotalGsm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        /* Padding(
                                          padding: const EdgeInsets.only(top:20),
                                          child: Text(
                                            errorMessage ?? '',
                                            style: TextStyle(color: Colors.red,fontSize: 15),
                                          ),
                                        ),*/
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child:
                      Wrap(
                        children: [
                          Visibility(
                            visible: selectedCheckbox != 3,
                            child:MaterialButton(
                              color: Colors.green.shade600,
                              onPressed: () async {
                                bool hasDuplicateProdCode = false;
                                bool hasNewProdCode = false;
                                if (isMachineNameExists(poNUMber.text)) {
                                  setState(() {
                                    errorMessage = '* This PO Number is Already invoiced';
                                  });
                                }
                                else if (isMachineNameExists(pendingPoNUMber.text)) {
                                  setState(() {
                                    errorMessage = '* This PendingPo Number is Already invoiced';
                                  });
                                }
                                else if (purchaseDate.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Purchase Date';
                                  });
                                }
                                else if (invoiceNo.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Invoice Number';
                                  });
                                }
                                else {
                                  if (_formKey.currentState!.validate())
                                  {
                                    for (var i = 0; i < controllers.length; i++) {
                                      String enteredProdCode = controllers[i][0].text;
                                      bool isDuplicate = await checkForDuplicate(enteredProdCode);
                                      if (isDuplicate) {
                                        hasDuplicateProdCode = true;
                                      } else {
                                        hasNewProdCode = true;
                                      }
                                    }
                                    if (hasDuplicateProdCode && hasNewProdCode) {
                                      for (int i = 0; i < controllers.length; i++) {
                                        String enteredProdCode = controllers[i][0].text;
                                        bool isDuplicate = await checkForDuplicate(enteredProdCode);
                                        if (isDuplicate) {
                                          await addRawMaterial(
                                            controllers[i][0].text,
                                            controllers[i][1].text,
                                            controllers[i][2].text,
                                            int.parse(controllers[i][3].text),
                                            date.toIso8601String(),
                                          );
                                        }
                                        else {
                                          Map<String, dynamic> dataToInsertRaw = {
                                            'date': date.toString(),
                                            'prodCode': controllers[i][0].text,
                                            'prodName': controllers[i][1].text,
                                            'unit': controllers[i][2].text,
                                            'qty': controllers[i][3].text,
                                          };
                                          await insertDataRaw(dataToInsertRaw);
                                        }
                                      }
                                    }
                                    else if (hasDuplicateProdCode) {
                                      for (int i = 0; i < controllers.length; i++) {
                                        await addRawMaterial(
                                            controllers[i][0].text,
                                            controllers[i][1].text,
                                            controllers[i][2].text,
                                            int.parse(controllers[i][3].text),
                                            date.toIso8601String()
                                        );

                                      }
                                    }
                                    else if (hasNewProdCode) {
                                      submitItemDataToRaw();
                                    }

                                    setState(() {
                                      isDataSaved = true;
                                    });
                                    submitItemDataToDatabase();

                                    List<Map<String, dynamic>> rowsDataToInsert = [];

                                    if(fetchingQTY != editingQTY){
                                      rowsDataToInsert.add(datapendingInsert);
                                      await pendingToDatabase();
                                    }
                                    List<Future<void>> insertFutures = [];
                                    for (var i = 0; i < datapendingInsertList.length; i++) {
                                      insertFutures.add(insertDataPendingReport(datapendingInsertList[i]));
                                      await Future.wait(insertFutures);
                                    }

                                    setState(() {
                                      isDataSaved = true;
                                    });

                                  }
                                  else {
                                    setState(() {
                                      errorMessage =
                                      '* Fill all fields in the table';
                                    });
                                  }
                                }
                              },
                              child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                            ),
                          ),

                          Visibility(
                            visible: selectedCheckbox == 3,
                            child: MaterialButton(
                              color: Colors.green.shade600,
                              onPressed: () async {
                                bool hasDuplicateProdCode2 = false;
                                bool hasNewProdCode2 = false;
                                if (_formKey.currentState!.validate())
                                  {
                                    for (var i = 0; i < controllers2.length; i++) {
                                      String enteredProdCode = controllers2[i][0].text;
                                      String enteredSNo = controllers2[i][3].text;
                                      bool isDuplicate2 = await checkForDuplicateGsm(enteredProdCode,enteredSNo);
                                      if (isDuplicate2) {
                                        hasDuplicateProdCode2 = true;
                                      } else {
                                        hasNewProdCode2 = true;
                                      }
                                    }
                                    if (hasDuplicateProdCode2 && hasNewProdCode2) {
                                      for (int i = 0; i < controllers2.length; i++) {
                                        String enteredProdCode = controllers2[i][0].text;
                                        String enteredSNo = controllers2[i][3].text;
                                        bool isDuplicate = await checkForDuplicateGsm(enteredProdCode,enteredSNo);                                        if (isDuplicate) {
                                          await addRawMaterialGsm(
                                            controllers2[i][0].text,
                                            controllers2[i][1].text,
                                            controllers2[i][2].text,
                                            int.parse(controllers2[i][3].text),
                                            date.toIso8601String(),
                                            controllers2[i][4].text,
                                          );
                                        }
                                        else {
                                          Map<String, dynamic> dataToInsertRawGsm = {
                                            'date': date.toString(),
                                            'prodCode': controllers2[i][0].text,
                                            'prodName': controllers2[i][1].text,
                                            'unit': controllers2[i][2].text,
                                            'sNo': controllers2[i][3].text,
                                            "totalweight":controllers2[i][4].text,
                                          };
                                          await insertDataRawGsm(dataToInsertRawGsm);
                                        }
                                      }
                                    }
                                    else if (hasDuplicateProdCode2) {
                                      for (int i = 0; i < controllers2.length; i++) {
                                        await addRawMaterialGsm(
                                            controllers2[i][0].text,
                                            controllers2[i][1].text,
                                            controllers2[i][2].text,
                                            int.parse(controllers2[i][3].text),
                                            date.toIso8601String(),
                                            controllers2[i][4].text
                                        );
                                      }
                                    }
                                    else if (hasNewProdCode2) {
                                      submitItemDataToRawGsm();
                                    }
                                    setState(() {
                                      isDataSaved = true;
                                    });
                                    await submitItemDataToDatabaseGsm();
                                  }
                              },
                              child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          SizedBox(width: 20,),
                          MaterialButton(
                            color: Colors.blue.shade600,
                            onPressed: (){
                              /*  Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>const Home()));*/// Close the alert box
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
                                              MaterialPageRoute(builder: (context) =>const Purchase()));// Close the alert box
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
                            child: const Text("RESET",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 20,),
                          MaterialButton(
                            color: Colors.red.shade600,
                            onPressed: (){
                              /* Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>Home()));*/
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
                                              MaterialPageRoute(builder: (context) =>Home()));// Close the alert box
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
        ) );
  }
}
/*
String _getKeyForColumn(int columnIndex) {
  switch (columnIndex) {
    case 0:
      return 'prodCode';
    case 1:
      return 'prodName';
    case 2:
      return 'unit';
    case 3:
      return 'qty';
    case 4:
      return 'rate';
    case 5:
      return 'amt';
    case 6:
      return 'gst';
    case 7:
      return 'amtGST';
    case 8:
      return 'total';
    case 9:
      return 'rQty';
    case 10:
      return 'aQty';
    default:
      return '';
  }
}
*/
String _getKeyForColumn(int columnIndex) {
  switch (columnIndex) {
    case 0:
      return 'prodCode';
    case 1:
      return 'prodName';
    case 2:
      return 'unit';
    case 3:
      return 'qty';
    case 4:
      return 'totalWeight';
    case 5:
      return 'rate';
    case 6:
      return 'amt';
    case 7:
      return 'gst';
    case 8:
      return 'amtGST';
    case 9:
      return 'total';
    case 10:
      return 'rQty';
    case 11:
      return 'aQty';
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

