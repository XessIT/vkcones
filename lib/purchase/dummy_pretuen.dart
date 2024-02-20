

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/purchase_entry.dart';
import '../home.dart';

class PurchaseEdit extends StatefulWidget {
  const PurchaseEdit({Key? key}) : super(key: key);
  @override
  State<PurchaseEdit> createState() => _PurchaseEditState();
}
class _PurchaseEditState extends State<PurchaseEdit> {
  final _formKey = GlobalKey<FormState>();
  final  selectedDate = DateTime.now();

  final  date = DateTime.now();
  List<List<TextEditingController>> controllers = [];
  List<List<TextEditingController>> controllers2 = [];
  List<List<FocusNode>> focusNodes = [];
  List<List<FocusNode>> focusNodes2 = [];
  List<Map<String, dynamic>> rowData = [];
  List<Map<String, dynamic>> rowData2 = [];
  List<bool> isRowFilled = [false];
  List<bool> isRowFilled2 = [false];
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

  void updateGrandTotal() {
    double tcs = double.tryParse(tcsController.text) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;

    if (selectedCheckbox == 1) {
      grandTotalValue = calculateGrandTotal2() + tcs - discount;
    } else {
      grandTotalGsm = calculateGrandTotalGsm() + tcs - discount;
    }
    setState(() {
      grandTotalValue = calculateGrandTotal2() + tcs - discount;
      grandTotalGsm = calculateGrandTotalGsm() + tcs - discount;    });
  }
  double calculateGrandTotalGsm() {
    double total = 0.0;
    for (var i = 0; i < controllers2.length; i++) {
      total += double.tryParse(controllers2[i][9].text) ?? 0.0;
    }
    print("total------------------ $total");
    return total;
  }
  double calculateGrandTotal2() {
    double total = 0.0;
    for (var i = 0; i < controllers.length; i++) {
      total += double.tryParse(controllers[i][8].text) ?? 0.0;
    }
    print("total------------------ $total");
    return total;
  }


  bool isTextFormFieldsVisible = false;

  void onArrowButtonClick() {
    setState(() {
      isTextFormFieldsVisible = !isTextFormFieldsVisible;
    });
  }




  List<Map<String, dynamic>> datapendingInsertList = [];


  int? rowslenth=0;
  int? rowslenth2=0;


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
  void clearAllRows2() {
    setState(() {
      rowData2.clear();
      for (var rowControllers in controllers2) {
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
  void updateFieldValidation2() {
    bool allValid = true;
    for (var i = 0; i < controllers2.length; i++) {
      for (var j = 0; j < 10; j++) {
        if (i < controllers2.length &&
            j < controllers2[i].length &&
            controllers2[i][j].text.isEmpty) {
          allValid = false;
          break;
        }
      }
    }
    // Update any validation-related state here if needed.
  }
  int selectedCheckbox = 1;



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
  TextEditingController podate=TextEditingController();
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
  Map<String, dynamic> dataToInsertRaw2 = {};
  Map<String, dynamic> dataToInsertRawGsm = {};
  Map<String, dynamic> dataToInsertSupItem2 = {};

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
                                  PurchaseEdit()));
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
  Future<void> submitItemDataToDatabase() async {
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers.length; i++) {
      String purchaseDateString = purchaseDate.text;
      DateTime purchaseDateTime = DateFormat('dd-MM-yyyy').parse(purchaseDateString);
      String formattedPurchaseDate = DateFormat('yyyy-MM-dd').format(purchaseDateTime);

      Map<String, dynamic> dataToInsertSupItem2 = {
        'invoiceNo':invoiceNo.text,
        "date":date.toString(),
        'purchaseDate': formattedPurchaseDate,
        "supName": supName.text,
        "supCode":supCode.text,
        "supAddress": supAddress.text,
        "pincode": pincode.text,
        "supMobile": supMobile.text,
        'prodCode':controllers[i][0].text,
        'prodName': controllers[i][1].text,
        'unit': controllers[i][2].text,
        'qty': controllers[i][3].text,
        'rate':controllers[i][4].text,
        'amt':controllers[i][5].text,
        'gst': controllers[i][6].text,
        'amtGST': controllers[i][7].text,
        'total': controllers[i][8].text,
        'grandTotal':grandTotalValue,
        'extraCharge':tcsController.text,
        'discount':discountController.text,
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

  Future<bool> checkForDuplicate(String prodCode, String poNo) async {
    const String apiUrl = 'http://localhost:3309/fetch_productcode_poNo_duplicate'; // Replace with your server endpoint

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        bool isProdCodeDuplicate = data.any((item) => item['prodCode'] == prodCode);
        bool isPoNoDuplicate = data.any((item) => item['poNo'] == poNo);

        return isProdCodeDuplicate && isPoNoDuplicate;
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
    const String apiUrl = 'http://localhost:3309/purchase_edit_new_update'; // Replace with your server details
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
        'purchaseDate': formattedPurchaseDate,
        'invoiceNo':invoiceNo.text,
        "supCode":supCode.text,
        "supName": supName.text,
        "supMobile": supMobile.text,
        "supAddress": supAddress.text,
        "pincode": pincode.text,
        "payType":payType,
        'prodCode':controllers[i][0].text,
        'prodName': controllers[i][1].text,
        'unit': controllers[i][2].text,
        'qty': controllers[i][3].text,
        'rate':controllers[i][4].text,
        'amt':controllers[i][5].text,
        'gst': controllers[i][6].text,
        'amtGST': controllers[i][7].text,
        'total': controllers[i][8].text,
        'grandTotal':grandTotalValue,
        'extraCharge':tcsController.text,
        'discount':discountController.text,
        "poNo":poNUMber.text,
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
  Future<void> updatePurchase(String purchaseDate, String invoiceNo,String supCode,String supName,String supMobile,String supAddress,String pincode,String payType,String prodCode,String prodName,String unit,String qty,String rate,String amt,String gst,String amtGST,String total,String grandTotal,String extraCharge,String discount,String poNo) async {
    final Uri url = Uri.parse('http://localhost:3309/purchase_edit_update'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "date":date.toString(),
        'purchaseDate': purchaseDate,
        'invoiceNo':invoiceNo,
        "supCode":supCode,
        "supName": supName,
        "supMobile": supMobile,
        "supAddress": supAddress,
        "pincode": pincode,
        "payType":payType,
        'prodCode':prodCode,
        'prodName': prodName,
        'unit': unit,
        'qty': qty,
        'rate':rate,
        'amt':amt,
        'gst': gst,
        'amtGST': amtGST,
        'total': total,
        'grandTotal':grandTotal,
        'extraCharge':extraCharge,
        'discount':discount,
        'poNo':poNo
      }),
    );

    if (response.statusCode == 200) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Purchase"),
            content: const Text(
                "Update Successfully"),
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
    } else {
      print('Failed to update. raw material  Status code: ${response.statusCode}');
      throw Exception('Failed to update raw material');
    }
  }


  Future<void> updatePurchaseGsm(String purchaseDate, String invoiceNo,String supCode,String supName,String supMobile,String supAddress,String pincode,String payType,String prodCode,String prodName,String unit,String sNo,String totalWeight,String rate,String amt,String gst,String amtGST,String total,String grandTotal,String extraCharge,String discount,String poNo) async {
    final Uri url = Uri.parse('http://localhost:3309/purchase_gsm_edit_update'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "date":date.toString(),
        'purchaseDate': purchaseDate,
        'invoiceNo':invoiceNo,
        "supCode":supCode,
        "supName": supName,
        "supMobile": supMobile,
        "supAddress": supAddress,
        "pincode": pincode,
        "payType":payType,
        'prodCode':prodCode,
        'prodName': prodName,
        'unit': unit,
        'sNo': sNo,
        'totalWeight': totalWeight,
        'rate':rate,
        'amt':amt,
        'gst': gst,
        'amtGST': amtGST,
        'total': total,
        'grandTotal':grandTotal,
        'extraCharge':extraCharge,
        'discount':discount,
        'poNo':poNo
      }),
    );

    if (response.statusCode == 200) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Purchase"),
            content: const Text(
                "Update Successfully"),
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
    } else {
      print('Failed to update. raw material  Status code: ${response.statusCode}');
      throw Exception('Failed to update raw material');
    }
  }
  Future<void> insertDataRawGsm(Map<String, dynamic> dataToInsertRawGsm) async {
    const String apiUrl = 'http://localhost:3309/purchase_edit_new_update_gsm'; // Replace with your server details
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
        'purchaseDate': formattedPurchaseDate,
        'invoiceNo':invoiceNo.text,
        "supCode":supCode.text,
        "supName": supName.text,
        "supMobile": supMobile.text,
        "supAddress": supAddress.text,
        "pincode": pincode.text,
        "payType":payType,
        'prodCode':controllers2[i][0].text,
        'prodName': controllers2[i][1].text,
        'unit': controllers2[i][2].text,
        'sNo': controllers2[i][3].text,
        'totalWeight':controllers2[i][4].text,
        'rate':controllers2[i][5].text,
        'amt': controllers2[i][6].text,
        'gst': controllers2[i][7].text,
        'amtGST': controllers2[i][8].text,
        'total': controllers2[i][9].text,
        'grandTotal':grandTotalGsm,
        'extraCharge':tcsController.text,
        'discount':discountController.text,
        "poNo":poNUMber.text,

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

  Future<bool> checkForDuplicate2(String prodCode) async {
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
  Future<void> insertDataRaw2(Map<String, dynamic> dataToInsertRaw2) async {
    const String apiUrl = 'http://localhost:3309/Raw_material_entry_edit'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertRaw2': dataToInsertRaw2}),
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
/*
  Future<void> submitItemDataToRaw2() async {
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers.length; i++) {
      Map<String, dynamic> dataToInsertRaw2 = {
        "date":date.toString(),
        'prodCode':controllers[i][0].text,
        'prodName': controllers[i][1].text,
        'unit':controllers[i][2].text,
        'qty': controllers[i][3].text,
      };
      insertFutures.add(insertDataRaw2(dataToInsertRaw2));
    }

    try {
      await Future.wait(insertFutures);
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }
*/
  Future<void> addRawMaterial(String prodCode, String prodName, String unit, int qty, String modifyDate) async {
    final Uri url = Uri.parse('http://localhost:3309/add_MinusRawMaterial'); // Replace with your actual backend URL

    List<Future<void>> insertFutures = [];

    for (var i = 0; i < controllers.length; i++) {
      double initialQuantity = double.parse(controllers[i][9].text);
      double editedQuantity = double.parse(controllers[i][3].text);

      if (initialQuantity == editedQuantity) {
        print('Quantities are equal. Skipping update for item $i');
        continue;
      }

      insertFutures.add(
            () async {
          final response = await http.post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              'prodCode': prodCode,
              'prodName': prodName,
              'unit': unit,
              'qty': int.parse(controllers[i][10].text),
              'modifyDate': date.toString(),
              'isIncrease': initialQuantity < editedQuantity,
            }),
          );

          if (response.statusCode == 200) {
            print('Update raw material successful for item $i');
          } else {
            print('Failed to update raw material for item $i. Status code: ${response.statusCode}');
            throw Exception('Failed to update raw material');
          }
        }(),
      );
    }

    try {
      await Future.wait(insertFutures);
      print('All raw material data inserted successfully');
    } catch (e) {
      print('Error inserting raw material data: $e');
    }
  }

  Future<void> submitItemDataToRaw2() async {
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers.length; i++) {
      String purchaseDateString = purchaseDate.text;
      DateTime purchaseDateTime = DateFormat('dd-MM-yyyy').parse(purchaseDateString);
      String formattedPurchaseDate = DateFormat('yyyy-MM-dd').format(purchaseDateTime);

      Map<String, dynamic> dataToInsertRaw2 = {
        "date": date.toString(),
        'prodCode': controllers[i][0].text,
        'prodName': controllers[i][1].text,
        'unit': controllers[i][2].text,
        'qty': controllers[i][3].text,
      };
      insertFutures.add(
            () async {
          try {
            await insertDataRaw2(dataToInsertRaw2);
            print('Data inserted successfully for item $i');
          } catch (e) {
            print('Error inserting data for item $i: $e');
          }
        }(),
      );
    }

    try {
      await Future.wait(insertFutures);
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  /*
  Future<void> addRawMaterial(String prodCode, String prodName, String unit,int qty, String modifyDate) async {
    final Uri url = Uri.parse('http://localhost:3309/add_MinusRawMaterial'); // Replace with your actual backend URL

    for (var i = 0; i < controllers.length; i++) {
      double initialQuantity = double.parse(controllers[i][9].text);
      double editedQuantity = double.parse(controllers[i][3].text);

      if (initialQuantity == editedQuantity) {
        print('Quantities are equal. Skipping update for item $i');
        continue;
      }

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'prodCode': prodCode,
          'prodName': prodName,
          'unit': unit,
          'qty': int.parse(controllers[i][10].text),
          'modifyDate': date.toString(),
          'isIncrease': initialQuantity < editedQuantity,
        }),
      );

      if (response.statusCode == 200) {
        print('Update raw material successful for item $i');
      } else {
        print('Failed to update raw material for item $i. Status code: ${response.statusCode}');
        throw Exception('Failed to update raw material');
      }
    }
  }
*/


  String selectedInvoiceNo = '';
  String selectedPoInvoiceNo = '';
  final FocusNode _suppliernameFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_suppliernameFocusNode);
    });
    fetchData();//add Row
     addRow2();
     addRow();
    fetchDataSup();
    calculateGrandTotal2();
    calculateGrandTotalGsm();
  }

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> dataSup = [];
  List<Map<String, dynamic>> data2 = [];
  List<Map<String, dynamic>> data3 = [];
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> filteredData2 = [];
  List<Map<String, dynamic>> filteredData3 = [];


  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/fetch_purchase_datas'));
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
  Future<void> fetchData2() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/fetch_purchase_datas_invoice'));
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
        supCode.clear();
        supName.clear();
        supMobile.clear();
        supAddress.clear();
        invoiceNo.clear();
        tcsController.clear();
        discountController.clear();
        setState(() {
          purchaseDate.clear();
          payType == null;
        });

      } else {
        filteredData = data.where((item) {
          String poNo = item['poNo']?.toString()?.toLowerCase() ?? '';
         // String invoiceNo = item['invoiceNo']?.toString()?.toLowerCase() ?? '';

          return poNo == searchText.toLowerCase() || invoiceNo == searchText.toLowerCase();
        }).toList();
        if (filteredData.isNotEmpty) {
          Map<String, dynamic> order = filteredData.first;

          //poNUMber.text = order['poNo']?.toString() ?? '';
          supCode.text = order['supCode']?.toString() ?? '';
          supCode.text = order['supCode']?.toString() ?? '';
          supName.text = order['supName']?.toString() ?? '';
          supAddress.text = order['supAddress']?.toString() ?? '';
          supMobile.text = order['supMobile']?.toString() ?? '';
          pincode.text = order['pincode']?.toString() ?? '';
          invoiceNo.text = order['invoiceNo']?.toString() ?? '';
          if (order['purchaseDate'] != null) {
            DateTime parsedDate = DateTime.parse(order['purchaseDate'].toString()).toLocal();
            String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
            purchaseDate.text = formattedDate;
          } else { purchaseDate.clear();
          }          tcsController.text = order['extraCharge']?.toString() ?? '';
          discountController.text = order['discount']?.toString() ?? '';
        }
        else {
          supCode.clear();supName.clear();
        }
      }
    });
  }
  void filterData2(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = data;
        supCode.clear();
        supName.clear();
        supMobile.clear();
        supAddress.clear();
        poNUMber.clear();
        setState(() {
          purchaseDate.clear();
          payType == null;
        });
        tcsController.clear();
        discountController.clear();



      } else {
        filteredData = data.where((item) {
          //String poNo = item['poNo']?.toString()?.toLowerCase() ?? '';
          String invoiceNo = item['invoiceNo']?.toString()?.toLowerCase() ?? '';

          return invoiceNo == searchText.toLowerCase();
        }).toList();
        if (filteredData.isNotEmpty) {
          Map<String, dynamic> order = filteredData.first;

          poNUMber.text = order['poNo']?.toString() ?? '';
          supCode.text = order['supCode']?.toString() ?? '';
          supCode.text = order['supCode']?.toString() ?? '';
          supName.text = order['supName']?.toString() ?? '';
          supAddress.text = order['supAddress']?.toString() ?? '';
          supMobile.text = order['supMobile']?.toString() ?? '';
          pincode.text = order['pincode']?.toString() ?? '';
          invoiceNo.text = order['invoiceNo']?.toString() ?? '';
          if (order['purchaseDate'] != null) {
            DateTime parsedDate = DateTime.parse(order['purchaseDate'].toString()).toLocal();
            String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
            purchaseDate.text = formattedDate;
          } else { purchaseDate.clear();
          }          tcsController.text = order['extraCharge']?.toString() ?? '';
          discountController.text = order['discount']?.toString() ?? '';
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


  Map<int, double> fetchedQuantities = {};
  Map<int, double> fetchedQuantities2 = {};
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
  void addRow() {
    setState(() {
      List<TextEditingController> rowControllers = [];
      List<FocusNode> rowFocusNodes = [];

      for (int j = 0; j < 11; j++) {
        rowControllers.add(TextEditingController());
        rowFocusNodes.add(FocusNode());
      }

      controllers.add(rowControllers);
      focusNodes.add(rowFocusNodes);

      isRowFilled.add(false);

      Map<String, dynamic> row = {
        'prodCode': '',
        'prodName': '',
        'unit': '',
        'qty': '',
        'rate':'',
        'amt':'',
        'gst':'',
        'amtGST':'',
        'total':'',
      };

      rowData.add(row);
      grandTotalValue = calculateGrandTotal2();

      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(rowFocusNodes[0]);
      });
    });
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
      focusNodes.add(rowFocusNodes);

      isRowFilled.add(false);

      Map<String, dynamic> row = {
        'prodCode': '',
        'prodName': '',
        'unit': '',
        'sNo': '',
        'totalWeight': '',
        'rate':'',
        'amt':'',
        'gst':'',
        'amtGST':'',
        'total':'',
      };

      rowData.add(row);
      grandTotalGsm = calculateGrandTotalGsm();

      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(rowFocusNodes[0]);
      });
    });
  }
  void removeRow(int index) {
    setState(() {
      if (index >= 0 && index < controllers.length) {
        controllers.removeAt(index);
        focusNodes.removeAt(index);
        isRowFilled.removeAt(index);
        rowData.removeAt(index);
        grandTotalValue = calculateGrandTotal2();
      }
    });
  }
  void removeRow2(int index) {
    setState(() {
      if (index >= 0 && index < controllers2.length) {
        controllers2.removeAt(index);
        focusNodes.removeAt(index);
        isRowFilled.removeAt(index);
        rowData.removeAt(index);
        grandTotalGsm = calculateGrandTotalGsm();
      }
    });
  }

  Future<void> fetchDataByInvoiceNumber(String invoiceNumber) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_purchase_item?invoiceNo=$invoiceNumber');
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
              'rate': rows[i]['rate'],
              'amt': rows[i]['amt'],
              'gst': rows[i]['gst'],
              'amtGST': rows[i]['amtGST'],
              'total': rows[i]['total'],
              'qty2': rows[i]['qty'],
            };

            for (int j = 0; j < 11; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }

            controllers.add(rowControllers);
            focusNodes.add(List.generate(11, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);

          }
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> fetchDataByPoNumber(String poNumber) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_purchase_items?poNo=$poNumber');
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
              'rate': rows[i]['rate'],
              'amt': rows[i]['amt'],
              'gst': rows[i]['gst'],
              'amtGST': rows[i]['amtGST'],
              'total': rows[i]['total'],
              'qty2': rows[i]['qty'],
            };

            for (int j = 0; j < 11; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }

            controllers.add(rowControllers);
            focusNodes.add(List.generate(11, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);

          }
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> fetchDataByPoNumber2(String poNumber) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_purchase_items?poNo=$poNumber');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;

        setState(() {
          controllers2.clear();
          focusNodes2.clear();
          isRowFilled2.clear();
          rowData2.clear();
          for (var i = 0; i < rows.length; i++) {
            List<TextEditingController> rowControllers = [];
            Map<String, dynamic> row = {
              'prodCode': rows[i]['prodCode'],
              'prodName': rows[i]['prodName'],
              'unit':rows[i]['unit'],
              'sNo': rows[i]['sNo'],
              'totalWeight': rows[i]['totalWeight'],
              'rate': rows[i]['rate'],
              'amt': rows[i]['amt'],
              'gst': rows[i]['gst'],
              'amtGST': rows[i]['amtGST'],
              'total': rows[i]['total'],
            };

            for (int j = 0; j < 10; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn2(j)]);
              rowControllers.add(controller);
            }

            controllers2.add(rowControllers);
            focusNodes2.add(List.generate(10, (i) => FocusNode()));
            rowData2.add(row);
            isRowFilled2.add(true);

          }
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> fetchDataByInvoiceNumber2(String invoiceNumber) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_purchase_item?invoiceNo=$invoiceNumber');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;

        setState(() {
          controllers2.clear();
          focusNodes2.clear();
          isRowFilled2.clear();
          rowData2.clear();
          for (var i = 0; i < rows.length; i++) {
            List<TextEditingController> rowControllers = [];
            Map<String, dynamic> row = {
              'prodCode': rows[i]['prodCode'],
              'prodName': rows[i]['prodName'],
              'unit':rows[i]['unit'],
              'sNo': rows[i]['sNo'],
              'totalWeight': rows[i]['totalWeight'],
              'rate': rows[i]['rate'],
              'amt': rows[i]['amt'],
              'gst': rows[i]['gst'],
              'amtGST': rows[i]['amtGST'],
              'total': rows[i]['total'],
            };

            for (int j = 0; j < 10; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn2(j)]);
              rowControllers.add(controller);
            }

            controllers2.add(rowControllers);
            focusNodes2.add(List.generate(10, (i) => FocusNode()));
            rowData2.add(row);
            isRowFilled2.add(true);
            fetchedQuantities2[i] = double.tryParse(rows[i]['qty']) ?? 0.0;
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
      print('Error: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    poNUMber.addListener(() {
      filterData(poNUMber.text);
      fetchDataByPoNumber2(poNUMber.text);
    });
    poNUMber.addListener(() {
      filterData(poNUMber.text);
      fetchDataByPoNumber(poNUMber.text);
    });
    invoiceNo.addListener(() {
      filterData2(invoiceNo.text);
      fetchDataByInvoiceNumber(invoiceNo.text);
    });
    invoiceNo.addListener(() {
      fetchDataByInvoiceNumber2(invoiceNo.text);
    });
    supName.addListener(() {
      filterDataSup(supName.text);
    });
    double screenWidth = MediaQuery.of(context).size.width;
    return MyScaffold(
        route: "purchase_entry",backgroundColor: Colors.white,
        body:  Container(
          //color: Colors.black,
          child: Form(
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
                                                Text("Purchase Edit",style: TextStyle(fontSize:screenWidth * 0.019,fontWeight: FontWeight.bold),),
                                                IconButton(
                                                  icon: Icon(Icons.refresh),
                                                  onPressed: () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>PurchaseEdit()));
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.arrow_back),
                                                  onPressed: () {
                                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalaryCalculation()));
                                                    Navigator.pop(context);
                                                  },
                                                )
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
                                                    }
                                                    else {
                                                      selectedCheckbox = selectedCheckbox == 1 ? 2 : 1;
                                                    }
                                                  });
                                                },
                                              ),
                                              Text("PO"),
                                              Checkbox(
                                                value: selectedCheckbox == 2,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    poNUMber.clear();
                                                    errorMessage ="";
                                                    //  checkOrderNo ="";
                                                    if (value != null && value) {
                                                      selectedCheckbox = 2;
                                                    }
                                                    else {
                                                      selectedCheckbox = selectedCheckbox == 2 ? 1 : 2;
                                                    }
                                                  });
                                                },
                                              ),
                                              const Text("GSM"),
                                            ],
                                          ),
                                        ],
                                      ),
                                      //poNumber textformfield
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            height: 36,
                                            child: TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: poNUMber,
                                                focusNode: _suppliernameFocusNode,
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
                                                      .startsWith(pattern.toLowerCase())
                                                      &&
                                                      (selectedCheckbox == 1 && !item['prodName'].toString().startsWith('GSM')) ||
                                                      (selectedCheckbox == 2 && item['prodName'].toString().startsWith('GSM'))
                                                  )
                                                      .map((item) => item['poNo'].toString())
                                                      .toSet()
                                                      .toList();

                                                  suggestions = suggestions.take(5).toList();
                                                }
                                                else {
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
                                                });
                                                print('Selected Invoice Number: $selectedInvoiceNo');
                                              },
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
                                      child: TextFormField(
                                        style: TextStyle(fontSize: 13),
                                        readOnly: true,
                                        onTap: () async {
                                          DateTime? pickDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now(),
                                          );
                                          if (pickDate == null) return;
                                          {
                                            setState(() {
                                              // Format the picked date before setting it to the controller
                                              purchaseDate.text = DateFormat('dd-MM-yyyy').format(pickDate);
                                              errorMessage = null;
                                            });
                                          }
                                        },
                                        controller: purchaseDate,
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
                                          child:
                                          TypeAheadFormField<String>(
                                            textFieldConfiguration: TextFieldConfiguration(
                                              controller: invoiceNo, // Use the controller for invoiceNo
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
                                                (item['poNo']?.toString()?.toLowerCase() ?? '').startsWith(pattern.toLowerCase()) ||
                                                    (item['invoiceNo']?.toString()?.toLowerCase() ?? '').startsWith(pattern.toLowerCase()) &&
                                                        (selectedCheckbox == 1 && !item['prodName'].toString().startsWith('GSM') ||
                                                            (selectedCheckbox == 2 && item['prodName'].toString().startsWith('GSM'))))
                                                    .map((item) => item['invoiceNo'].toString())
                                                    .toSet()
                                                    .toList();

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
                                                invoiceNo.text = suggestion;
                                              });
                                              print('Selected Invoice Number: $selectedInvoiceNo');
                                            },
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
                                              // readOnly: selectedCheckbox != 3,
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
                                              //  readOnly: selectedCheckbox != 3,
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
                                              // readOnly: selectedCheckbox != 3,
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
                                            child:
                                            SizedBox(
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
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
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
                                      selectedCheckbox == 1 ?
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
                                              9: FixedColumnWidth(110),



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
                                                  TableCell(
                                                    child: Container(
                                                      color:Colors.blue.shade200,
                                                      child: const Center(
                                                        child: Column(
                                                          children: [
                                                            SizedBox(height: 15),
                                                            Text('qty',style: TextStyle(fontWeight: FontWeight.bold),),
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
                                                            Text('dif',style: TextStyle(fontWeight: FontWeight.bold),),
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
                                                      TableCell(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: TextFormField(
                                                              style: TextStyle(fontSize: 13,
                                                                color: (j == 0 || j == 1 || j == 2 || j == 5 || rowData[i]['prodName'].startsWith('GSM') || j == 7 || j == 2||j==3) ? Colors.black : Colors.grey, // Set the text color
                                                              ),
                                                              controller: controllers[i][j],
                                                              inputFormatters: [
                                                                // UpperCaseTextFormatter(),
                                                                // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                                // if (j == 7)
                                                                //   FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,1})?$')),
                                                              ],
                                                              decoration: const InputDecoration(
                                                                filled: true,
                                                                fillColor: Colors.white,
                                                              ),

                                                              textAlign: (j >= 0 && j <= 3) ? TextAlign.center : TextAlign.right,
                                                              // enabled: (j == 3 || j == 6 || j == 4),
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

                                                                  double quantity = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
                                                                  double rate = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;
                                                                  double gst = double.tryParse(controllers[rowIndex][6].text) ?? 0.0;


                                                                  double amount = quantity * rate;
                                                                  double gstAmt = (amount * gst) / 100;
                                                                  double total = amount + gstAmt;


                                                                  controllers[rowIndex][5].text = amount.toStringAsFixed(2);
                                                                  controllers[rowIndex][7].text = gstAmt.toStringAsFixed(2);
                                                                  controllers[rowIndex][8].text = total.toStringAsFixed(2);
                                                                  double initialQuantity = double.parse(controllers[i][9].text);
                                                                  double editedQuantity = double.parse(controllers[i][3].text);
                                                                  int dif;

                                                                  if (initialQuantity > editedQuantity) {
                                                                    dif = (initialQuantity - editedQuantity).toInt();
                                                                  } else if (initialQuantity < editedQuantity) {
                                                                    dif = (editedQuantity - initialQuantity).toInt();
                                                                  } else {
                                                                    dif = 0; // or any other default value
                                                                  }
                                                                  controllers[rowIndex][10].text = dif.toStringAsFixed(0);

                                                                  print('Difference: $dif');

                                                                  setState(() {
                                                                    grandTotalValue = calculateGrandTotal2();
                                                                    print("grandTotalGsm $grandTotalValue");
                                                                  });

                                                                  print("grandTotalValue0 $grandTotalValue");

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
                                                            // if (i == controllers.length - 1&&allFieldsFilled) // Render "Add" button only in the last row
                                                              Visibility(
                                                                visible: i == controllers.length-1 && isRowFilled[i],
                                                                child: Align(
                                                                  alignment: Alignment.center,
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      IconButton(
                                                                        icon: Icon(Icons.add_circle_outline,color: Colors.green,),
                                                                        onPressed: () {
                                                                          addRow();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
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
                                      ):
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
                                              9: FixedColumnWidth(110),
                                              10: FixedColumnWidth(100),



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
                                                  ),
                                                  TableCell(
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
                                                            Text('S.No',style: TextStyle(fontWeight: FontWeight.bold),),
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
                                                            Text('Weight',style: TextStyle(fontWeight: FontWeight.bold),),
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
                                              for (var i = 0; i < controllers2.length; i++)
                                                TableRow(
                                                  children: [
                                                    for (var j = 0; j < 10; j++)
                                                      TableCell(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: TextFormField(
                                                              style: TextStyle(fontSize: 13,
                                                                color: (j == 0 || j == 1 || j == 2 || j == 5 || rowData2[i]['prodName'].startsWith('GSM') || j == 7 || j == 2||j==3) ? Colors.black : Colors.grey, // Set the text color
                                                              ),
                                                              controller: controllers2[i][j],
                                                              inputFormatters: [
                                                                UpperCaseTextFormatter(),
                                                                // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                                // if (j == 7)
                                                                //   FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,1})?$')),
                                                              ],
                                                              decoration: const InputDecoration(
                                                                filled: true,
                                                                fillColor: Colors.white,
                                                              ),

                                                              textAlign: (j >= 0 && j <= 3) ? TextAlign.center : TextAlign.right,
                                                              // enabled: (j == 3 || j == 6 || j == 4),
                                                              onChanged: (value) async {
                                                                final int rowIndex = i;
                                                                final int colIndex = j;
                                                                final String key = _getKeyForColumn2(colIndex);
                                                                final productName= await fetchProductName(value);
                                                                final productCode= await fetchProductCode(value);
                                                                updateFieldValidation2();
                                                                setState(() {
                                                                  rowData2[rowIndex][key] = value;
                                                                  if (colIndex == 0) {
                                                                    controllers2[i][1].clear();
                                                                  } else if (colIndex == 1) {
                                                                    controllers2[i][0].clear();
                                                                  }

                                                                  if (productName.isNotEmpty) {
                                                                    controllers2[i][1].text = productName;
                                                                  }
                                                                  if (productCode.isNotEmpty) {
                                                                    controllers2[i][0].text = productCode;
                                                                  }
                                                                  isRowFilled2[i] = controllers2[i].every((controller) => controller.text.isNotEmpty);
                                                                  if (value.isNotEmpty && isDuplicateProductCode(value, rowIndex)) {
                                                                    controllers2[rowIndex][1].clear();
                                                                    errorMessage = 'You already entered the\n product code $value.';
                                                                    return;
                                                                  }
                                                                  if (value.isNotEmpty && isDuplicateProductName(value, rowIndex)) {
                                                                    errorMessage = 'You already entered the\n product Name $value.';
                                                                    controllers2[rowIndex][0].clear();
                                                                    return;
                                                                  }
                                                                  errorMessage = '';
                                                                  double quantity = double.tryParse(controllers2[rowIndex][4].text) ?? 0.0;
                                                                  double rate = double.tryParse(controllers2[rowIndex][5].text) ?? 0.0;
                                                                  double gst = double.tryParse(controllers2[rowIndex][7].text) ?? 0.0;


                                                                  double amount = quantity * rate;
                                                                  double gstAmt = (amount * gst) / 100;
                                                                  double total = amount + gstAmt;


                                                                  controllers2[rowIndex][6].text = amount.toStringAsFixed(2);
                                                                  controllers2[rowIndex][8].text = gstAmt.toStringAsFixed(2);
                                                                  controllers2[rowIndex][9].text = total.toStringAsFixed(2);

                                                                  setState(() {
                                                                    grandTotalGsm = calculateGrandTotalGsm();
                                                                    print("grandTotalGsm $grandTotalGsm");
                                                                  });

                                                                  print("grandTotalValue0 $grandTotalValue");
                                                                }
                                                                );
                                                              }
                                                          ),
                                                        ),
                                                      ) ,
                                                    TableCell(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [

                                                            //  if (controllers.length ==controllers.length && i != controllers.length - 1) // Render "Add" button only in the last row
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
                                                                            removeRow2(i); // Remove the row
                                                                            Navigator.of(context).pop(); // Close the alert box
                                                                          },
                                                                        ),

                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                            // if (i == controllers.length - 1&&allFieldsFilled) // Render "Add" button only in the last row
                                                            Visibility(
                                                              visible: i == controllers2.length-1 && isRowFilled2[i],
                                                              child: Align(
                                                                alignment: Alignment.center,
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    IconButton(
                                                                      icon: const Icon(Icons.add_circle_outline,color: Colors.green,),
                                                                      onPressed: () {
                                                                        addRow2();
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
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
                                      const SizedBox(height: 10,),
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
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 70,
                                                    height: 30,
                                                    child: TextFormField(
                                                      controller: tcsController,
                                                      keyboardType: TextInputType.number,
                                                      decoration: const InputDecoration(
                                                        labelText: 'charge',
                                                        labelStyle: TextStyle(fontSize: 10), // Set the font size for the label
                                                      ),
                                                      style: TextStyle(fontSize: 10), // Set the font size for the input text
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
                                                      decoration: const InputDecoration(
                                                        labelText: 'Dis',
                                                        labelStyle: TextStyle(fontSize: 10), // Set the font size for the label
                                                      ),
                                                      style: TextStyle(fontSize: 10),                                                      onChanged: (_) {
                                                      updateGrandTotal();
                                                    },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                ],
                                              ),
                                              selectedCheckbox == 1
                                                  ?
                                              Text("Grand Total ₹ ${grandTotalValue.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
                                                  :
                                              Text("Grand Total ₹ ${grandTotalGsm.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),

                                            ],
                                          ),
                                        ],
                                      ),
                                      const Row(
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
                              visible: selectedCheckbox == 1,
                              child:MaterialButton(
                                color: Colors.green.shade600,
                                onPressed: () async {
                                  String purchaseDateString = purchaseDate.text;
                                  DateTime purchaseDateTime = DateFormat('dd-MM-yyyy').parse(purchaseDateString);
                                  String formattedPurchaseDate = DateFormat('yyyy-MM-dd').format(purchaseDateTime);
                                  bool hasDuplicateProdCode = false;
                                  bool hasDuplicateProdCode2 = false;
                                  bool hasNewProdCode = false;
                                  bool hasNewProdCode2 = false;

                                  if (purchaseDate.text.isEmpty) {
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
                                        String enteredPoNo = poNUMber.text;
                                        bool isDuplicate = await checkForDuplicate(enteredProdCode,enteredPoNo);
                                        if (isDuplicate) {
                                          hasDuplicateProdCode = true;
                                        } else {
                                          hasNewProdCode = true;
                                        }
                                      }
                                      if (hasDuplicateProdCode && hasNewProdCode) {
                                        for (int i = 0; i < controllers.length; i++) {
                                          String enteredProdCode = controllers[i][0].text;
                                          String enteredPoNo = poNUMber.text;
                                          bool isDuplicate = await checkForDuplicate(enteredProdCode,enteredPoNo);
                                          if (isDuplicate) {
                                            await updatePurchase(
                                              formattedPurchaseDate,
                                              invoiceNo.text,
                                              supCode.text,
                                              supName.text,
                                              supMobile.text,
                                              supAddress.text,
                                              pincode.text,
                                              payType.toString(),
                                              controllers[i][0].text,
                                                controllers[i][1].text,
                                                controllers[i][2].text,
                                                controllers[i][3].text,
                                                controllers[i][4].text,
                                                controllers[i][5].text,
                                                controllers[i][6].text,
                                                controllers[i][7].text,
                                                controllers[i][8].text,
                                              grandTotalValue.toStringAsFixed(2),
                                              tcsController.text,
                                              discountController.text,
                                              poNUMber.text
                                            );
                                          }
                                          else {
                                            Map<String, dynamic> dataToInsertRaw = {
                                              "date":date.toString(),
                                              'purchaseDate': formattedPurchaseDate,
                                              'invoiceNo':invoiceNo.text,
                                              "supCode":supCode.text,
                                              "supName": supName.text,
                                              "supMobile": supMobile.text,
                                              "supAddress": supAddress.text,
                                              "pincode": pincode.text,
                                              "payType":payType,
                                              'prodCode':controllers[i][0].text,
                                              'prodName': controllers[i][1].text,
                                              'unit': controllers[i][2].text,
                                              'qty': controllers[i][3].text,
                                              'rate':controllers[i][4].text,
                                              'amt':controllers[i][5].text,
                                              'gst': controllers[i][6].text,
                                              'amtGST': controllers[i][7].text,
                                              'total': controllers[i][8].text,
                                              'grandTotal':grandTotalGsm,
                                              'extraCharge':tcsController.text,
                                              'discount':discountController.text,
                                              "poNo":poNUMber.text,
                                            };
                                            await insertDataRaw(dataToInsertRaw);
                                          }
                                        }
                                      }
                                      else if (hasDuplicateProdCode) {
                                        for (int i = 0; i < controllers.length; i++) {
                                          await updatePurchase(
                                              formattedPurchaseDate,
                                              invoiceNo.text,
                                              supCode.text,
                                              supName.text,
                                              supMobile.text,
                                              supAddress.text,
                                              pincode.text,
                                              payType.toString(),
                                              controllers[i][0].text,
                                              controllers[i][1].text,
                                              controllers[i][2].text,
                                              controllers[i][3].text,
                                              controllers[i][4].text,
                                              controllers[i][5].text,
                                              controllers[i][6].text,
                                              controllers[i][7].text,
                                              controllers[i][8].text,
                                              grandTotalGsm.toStringAsFixed(2),
                                              tcsController.text,
                                              discountController.text,
                                              poNUMber.text
                                          );

                                        }
                                      }
                                      else if (hasNewProdCode) {
                                        submitItemDataToRaw();
                                      }
                                      for (int i = 0; i < controllers.length; i++) {
                                        await updatePurchase(
                                            formattedPurchaseDate,
                                            invoiceNo.text,
                                            supCode.text,
                                            supName.text,
                                            supMobile.text,
                                            supAddress.text,
                                            pincode.text,
                                            payType.toString(),
                                            controllers[i][0].text,
                                            controllers[i][1].text,
                                            controllers[i][2].text,
                                            controllers[i][3].text,
                                            controllers[i][4].text,
                                            controllers[i][5].text,
                                            controllers[i][6].text,
                                            controllers[i][7].text,
                                            controllers[i][8].text,
                                            grandTotalGsm.toStringAsFixed(2),
                                            tcsController.text,
                                            discountController.text,
                                            poNUMber.text
                                        );

                                      }
                                      setState(() {
                                        isDataSaved = true;
                                      });
                                      for (var i = 0; i < controllers.length; i++) {
                                        String enteredProdCode = controllers[i][0].text;
                                        bool isDuplicate = await checkForDuplicate2(enteredProdCode);
                                        if (isDuplicate) {
                                          hasDuplicateProdCode2 = true;
                                        } else {
                                          hasNewProdCode2 = true;
                                        }
                                      }
                                      if (hasDuplicateProdCode2 && hasNewProdCode2) {
                                        for (int i = 0; i < controllers.length; i++) {
                                          String enteredProdCode = controllers[i][0].text;
                                          bool isDuplicate = await checkForDuplicate2(enteredProdCode);
                                          if (isDuplicate) {
                                            await addRawMaterial(
                                              controllers[i][0].text,
                                              controllers[i][1].text,
                                              controllers[i][2].text,
                                              int.parse(controllers[i][10].text),
                                              date.toIso8601String(),
                                            );
                                          }
                                          else {
                                            // submitItemDataToRaw2();
                                            Map<String, dynamic> dataToInsertRaw2 = {
                                              'date': date.toString(),
                                              'prodCode': controllers[i][0].text,
                                              'prodName': controllers[i][1].text,
                                              'unit': controllers[i][2].text,
                                              'qty': controllers[i][3].text,
                                            };
                                            await insertDataRaw2(dataToInsertRaw2);
                                          }
                                        }
                                      }
                                      else if (hasDuplicateProdCode2) {
                                        for (int i = 0; i < controllers.length; i++) {
                                          await addRawMaterial(
                                              controllers[i][0].text,
                                              controllers[i][1].text,
                                              controllers[i][2].text,
                                              int.parse(controllers[i][10].text),
                                              date.toIso8601String()
                                          );

                                        }
                                      }
                                      else if (hasNewProdCode2) {
                                        submitItemDataToRaw2();
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
                              visible: selectedCheckbox == 2,
                              child:MaterialButton(
                                color: Colors.green.shade600,
                                onPressed: () async {
                                  String purchaseDateString = purchaseDate.text;
                                  DateTime purchaseDateTime = DateFormat('dd-MM-yyyy').parse(purchaseDateString);
                                  String formattedPurchaseDate = DateFormat('yyyy-MM-dd').format(purchaseDateTime);
                                  bool hasDuplicateProdCode = false;
                                  bool hasNewProdCode = false;

                                  if (purchaseDate.text.isEmpty) {
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

                                      for (var i = 0; i < controllers2.length; i++) {
                                        String enteredProdCode = controllers2[i][0].text;
                                        String enteredPoNo = poNUMber.text;
                                        bool isDuplicate = await checkForDuplicate(enteredProdCode,enteredPoNo);
                                        if (isDuplicate) {
                                          hasDuplicateProdCode = true;
                                        } else {
                                          hasNewProdCode = true;
                                        }
                                      }
                                      if (hasDuplicateProdCode && hasNewProdCode) {
                                        for (int i = 0; i < controllers2.length; i++) {
                                          String enteredProdCode = controllers2[i][0].text;
                                          String enteredPoNo = poNUMber.text;
                                          bool isDuplicate = await checkForDuplicate(enteredProdCode,enteredPoNo);
                                          if (isDuplicate) {
                                            await updatePurchaseGsm(
                                                formattedPurchaseDate,
                                                invoiceNo.text,
                                                supCode.text,
                                                supName.text,
                                                supMobile.text,
                                                supAddress.text,
                                                pincode.text,
                                                payType.toString(),
                                                controllers2[i][0].text,
                                                controllers2[i][1].text,
                                                controllers2[i][2].text,
                                                controllers2[i][3].text,
                                                controllers2[i][4].text,
                                                controllers2[i][5].text,
                                                controllers2[i][6].text,
                                                controllers2[i][7].text,
                                                controllers2[i][8].text,
                                                controllers2[i][9].text,
                                                grandTotalGsm.toStringAsFixed(2),
                                                tcsController.text,
                                                discountController.text,
                                                poNUMber.text
                                            );
                                          }
                                          else {
                                            Map<String, dynamic> dataToInsertRawGsm = {
                                              "date":date.toString(),
                                              'purchaseDate': formattedPurchaseDate,
                                              'invoiceNo':invoiceNo.text,
                                              "supCode":supCode.text,
                                              "supName": supName.text,
                                              "supMobile": supMobile.text,
                                              "supAddress": supAddress.text,
                                              "pincode": pincode.text,
                                              "payType":payType,
                                              'prodCode':controllers2[i][0].text,
                                              'prodName': controllers2[i][1].text,
                                              'unit': controllers2[i][2].text,
                                              'sNo': controllers2[i][3].text,
                                              'totalWeight':controllers2[i][4].text,
                                              'rate':controllers2[i][5].text,
                                              'amt': controllers2[i][6].text,
                                              'gst': controllers2[i][7].text,
                                              'amtGST': controllers2[i][8].text,
                                              'total': controllers2[i][9].text,
                                              'grandTotal':grandTotalGsm,
                                              'extraCharge':tcsController.text,
                                              'discount':discountController.text,
                                              "poNo":poNUMber.text,

                                            };
                                            await insertDataRawGsm(dataToInsertRawGsm);
                                          }
                                        }
                                      }
                                      else if (hasDuplicateProdCode) {
                                        for (int i = 0; i < controllers2.length; i++) {
                                          await updatePurchaseGsm(
                                              formattedPurchaseDate,
                                              invoiceNo.text,
                                              supCode.text,
                                              supName.text,
                                              supMobile.text,
                                              supAddress.text,
                                              pincode.text,
                                              payType.toString(),
                                              controllers2[i][0].text,
                                              controllers2[i][1].text,
                                              controllers2[i][2].text,
                                              controllers2[i][3].text,
                                              controllers2[i][4].text,
                                              controllers2[i][5].text,
                                              controllers2[i][6].text,
                                              controllers2[i][7].text,
                                              controllers2[i][8].text,
                                              controllers2[i][9].text,
                                              grandTotalGsm.toStringAsFixed(2),
                                              tcsController.text,
                                              discountController.text,
                                              poNUMber.text
                                          );

                                        }
                                      }
                                      else if (hasNewProdCode) {
                                        submitItemDataToRaw();
                                      }
                                      for (int i = 0; i < controllers2.length; i++) {
                                        await updatePurchaseGsm(
                                            formattedPurchaseDate,
                                            invoiceNo.text,
                                            supCode.text,
                                            supName.text,
                                            supMobile.text,
                                            supAddress.text,
                                            pincode.text,
                                            payType.toString(),
                                            controllers2[i][0].text,
                                            controllers2[i][1].text,
                                            controllers2[i][2].text,
                                            controllers2[i][3].text,
                                            controllers2[i][4].text,
                                            controllers2[i][5].text,
                                            controllers2[i][6].text,
                                            controllers2[i][7].text,
                                            controllers2[i][8].text,
                                            controllers2[i][9].text,
                                            grandTotalGsm.toStringAsFixed(2),
                                            tcsController.text,
                                            discountController.text,
                                            poNUMber.text,

                                        );

                                      }

                                      //submitItemDataToDatabase();

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
                                                MaterialPageRoute(builder: (context) =>const PurchaseEdit()));// Close the alert box
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
          ),
        ) );
  }
}
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
      return 'qty';
    case 10:
      return 'dif';
    default:
      return '';
  }
}
String _getKeyForColumn2(int columnIndex) {
  switch (columnIndex) {
    case 0:
      return 'prodCode';
    case 1:
      return 'prodName';
    case 2:
      return 'unit';
    case 3:
      return 'sNo';
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

