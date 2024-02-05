
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/sale/tax_invoice_page.dart';
import '../../home.dart';


class EntrySales extends StatefulWidget {
  const EntrySales({Key? key}) : super(key: key);
  @override
  State<EntrySales> createState() => _EntrySalesState();
}
class _EntrySalesState extends State<EntrySales> {
  final _formKey = GlobalKey<FormState>();
  DateTime eod = DateTime.now();
  List<List<TextEditingController>> controllers = [];
  List<List<FocusNode>> focusNodes = [];
  List<Map<String, dynamic>> rowData = [];
  List<bool> isRowFilled = [false];
  bool allFieldsFilled = false;
  bool dropdownValid = true;
  bool itemGroupExists = false;
  Map<String, dynamic> dataToInsert = {};
  String? errorMessage="";
  String? payType;
  String? deliveryType;
  String? pdeliveryType;
  final bool showHeader = false;
  bool visibleAlert = false;
  bool allValid = true;
  static final RegExp gstregex2 = RegExp(r"^(\d{2}[A-Z]{5}\d{4}[A-Z]\d[Z][A-Z\d])$");


  // static final RegExp gstregex2 = RegExp(r"^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d{1}[Z]{1}[A-Z\d]{1}$");

  ///old
  /* double calculateTotal(int rowIndex) {
    double quantity = double.tryParse(controllers[rowIndex][2].text) ?? 0.0;
    double rate = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
    double gst = double.tryParse(controllers[rowIndex][5].text) ?? 0.0;

    double amount = quantity * rate;
    double gstAmt = (amount*gst)/100;
    double total = amount + gstAmt;

    controllers[rowIndex][4].text = amount.toStringAsFixed(2);
    controllers[rowIndex][6].text = gstAmt.toStringAsFixed(2);
    controllers[rowIndex][7].text = total.toStringAsFixed(2);

    return total;
  }
  double calculateGrandTotal() {
    double grandTotalValue = 0.0;
    for (var i = 0; i < controllers.length; i++) {
      double total = double.tryParse(controllers[i][7].text) ?? 0.0;
      grandTotalValue += total;
    }
    return grandTotalValue;
  }*/

  void addRow() {
    setState(() {
      List<TextEditingController> rowControllers = [];
      List<FocusNode> rowFocusNodes = [];

      for (int j = 0; j < 14; j++) {
        rowControllers.add(TextEditingController());
        rowFocusNodes.add(FocusNode());
      }

      controllers.add(rowControllers);
      focusNodes.add(rowFocusNodes);

      isRowFilled.add(false);

      Map<String, dynamic> row = {
        'itemGroup': '',
        'itemName': '',
        'qty':'',
        'unit': '',
        'totalCone':'',
        'rate':'',
        'gst':'',
        'amtGST':'',
        'total':'',
        'fetch_qty':'',
        'pending_qty':'',
        'orderNo':'',
        'date':'',
      };

      rowData.add(row);

      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(rowFocusNodes[0]);
      });
    });
    grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
  }
  ///new
  double calculateTotal(int rowIndex) {
    double quantity = double.tryParse(controllers[rowIndex][2].text) ?? 0.0;//qty-4
    double unit = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;//unit-3
    double rate = double.tryParse(controllers[rowIndex][5].text) ?? 0.0;//rate -2
    double amount = (quantity * unit) * rate;
    double gst = double.tryParse(controllers[rowIndex][6].text) ?? 0.0;//amtGst-6
    double total = (amount * gst)/100;
    controllers[rowIndex][9].text = total.toStringAsFixed(2);//total-7
    print('Calculated Total: $total');

    return total;
  }
  double calculateGrandTotal() {
    double grandTotalValue = 0.0;
    for (var i = 0; i < controllers.length; i++) {
      double total = double.tryParse(controllers[i][9].text) ?? 0.0;
      grandTotalValue += total;
    }
    return grandTotalValue;
  }
  /// cross check of value of goods
  double calculateValueGoods() {
    double grandTotalValue = 0.0;
    for (var i = 0; i < controllers.length; i++) {
      double total = double.tryParse(controllers[i][7].text) ?? 0.0;
      grandTotalValue += total;
    }
    return grandTotalValue;
  }
  double calculateTotalItem() {
    double grandTotalValue = 0.0;
    for (var i = 0; i < controllers.length; i++) {
      double total = double.tryParse(controllers[i][2].text) ?? 0.0;
      grandTotalValue += total;
    }
    return grandTotalValue;
  }
  double calculateTaxAmount() {
    double grandTotalValue = 0.0;
    for (var i = 0; i < controllers.length; i++) {
      double total = double.tryParse(controllers[i][8].text) ?? 0.0;
      grandTotalValue += total;
    }
    return grandTotalValue;
  }

  ///old remove (1)
  List<Map<String, dynamic>> rowsDataToInsert = [];

  void removeDataFromRowsDataToInsert(int index) {
    if (index >= 0 && index < rowsDataToInsert.length) {
      rowsDataToInsert.removeAt(index);
    }
  }
  int indexToRemove = 0; // Replace 0 with the appropriate index value
// Declare a list to store data for pending insertions
  List<Map<String, dynamic>> datapendingInsertList = [];
  void removeRow(int rowIndex) {
    if (rowIndex >= 0 && rowIndex < controllers.length) {
      DateTime now=DateTime.now();
      String year=(now.year%100).toString();
      String month=now.month.toString().padLeft(2,'0');
      if (poNumber.isEmpty) {
        poNumber = 'PO$year$month/001';
      }

      String dateString = controllers[rowIndex][13].text.trim();
      DateTime dateTime = DateFormat('dd-MM-yy').parse(dateString);
      String formattedDate = DateFormat('dd-MM-yy').format(dateTime);

      // Retrieve the data from the row being removed
      Map<String, dynamic> removedRowData = {
        "pendingOrderNo": poNumber.toString(),
        "date": eod.toString(),
        // "date": eod.toString(),
        "orderNo": orderNo.text.isNotEmpty?controllers[rowIndex][12].text: pendingorderNo.text,
        "custCode": custCode.text,
        "custName": custName.text,
        "custAddress": custAddress.text,
        "custMobile": custMobile.text,
        "pincode": cpincode.text,
        "deliveryType": deliveryType,
        'itemGroup': controllers[rowIndex][0].text,
        'itemName': controllers[rowIndex][1].text,
        'qty': controllers[rowIndex][10].text.isNotEmpty ? controllers[rowIndex][10].text : '0',
        "checkOrderNo":orderNo.text.isNotEmpty?controllers[rowIndex][12].text:checkOrderNo.toString(),
        "individualOrderNo":controllers[rowIndex][12].text,
        //  'orderDate':controllers[rowIndex][13].text,
        'orderDate':formattedDate,
      };

      // Remove the row from your local data structure (controllers)
      controllers.removeAt(rowIndex);
      rowslenth= controllers.length;
      pendingrowslenth= controllers.length;

      // Add the removed data to the pending data list
      datapendingInsertList.add(removedRowData);

      // Trigger a rebuild of the UI to reflect the changes
      setState(() {
        grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
      });
    } else {
      print("Invalid index: $rowIndex");
    }
  }
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
    for (var i = 0; i < controllers.length; i++) {
      for (var j = 0; j <12; j++) {
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
  @override
  void dispose() {
    for (var rowControllers in controllers) {
      for (var controller in rowControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  TextEditingController orderNo=TextEditingController();
  TextEditingController pendingorderNo=TextEditingController();
  TextEditingController invoiceNo=TextEditingController();
  TextEditingController custCode=TextEditingController();
  TextEditingController custName=TextEditingController();
  TextEditingController custMobile=TextEditingController();
  TextEditingController custAddress=TextEditingController();
  TextEditingController cpincode=TextEditingController();
  TextEditingController pcustCode=TextEditingController();
  TextEditingController pcustName=TextEditingController();
  TextEditingController pcustMobile=TextEditingController();
  TextEditingController pcustAddress=TextEditingController();
  TextEditingController pcpincode=TextEditingController();
  TextEditingController grandTotal=TextEditingController();
  TextEditingController id=TextEditingController();
  TextEditingController transNo = TextEditingController();

  bool isDataSaved = false;
  TextEditingController gstin=TextEditingController();
  TextEditingController pgstin=TextEditingController();
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  int? fetchgetQty = 0;



  Map<String, dynamic> dataToInsertPurchaseReturn = {};

  /// pending data insert code starts here(1)
  String checkOrderNo = "";
  Map<String, dynamic> datapendingInsert = {};
  Future<void> insertDataPendingReport(Map<String, dynamic> datapendingInsert) async {
    const String apiUrl = 'http://localhost:3309/pending_insert'; // Replace with your server details
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
      poNumber = 'PO$year$month/001';
    }


    try{
      List<Future<void>> insertFutures = [];
      for (var i = 0; i < controllers.length; i++) {
        if (i >= controllers.length) {
          controllers.add(List.generate(8, (j) => TextEditingController()));
        }
        String dateString = controllers[i][13].text.trim();
        DateTime dateTime = DateFormat('dd-MM-yy').parse(dateString);
        String formattedDate = DateFormat('dd-MM-yy').format(dateTime);


        print("Inserting data for row $i");
        Map<String, dynamic> datapendingInsert = {
          "pendingOrderNo":poNumber.toString(),
          "date": eod.toString(),
          "orderNo":orderNo.text.isNotEmpty?controllers[i][12].text:pendingorderNo.text,
          "custCode": custCode.text,
          "custName": custName.text,
          "custAddress": custAddress.text,
          "custMobile": custMobile.text,
          "pincode":cpincode.text,
          "deliveryType":deliveryType,
          'itemGroup': controllers[i][0].text,
          'itemName': controllers[i][1].text,
          'qty':controllers[i][11].text.isNotEmpty?controllers[i][11].text:'0',
          "checkOrderNo":orderNo.text.isNotEmpty?controllers[i][12].text :checkOrderNo.toString(),
          "individualOrderNo":controllers[i][12].text,
          // 'orderDate':DateFormat('dd-MM-yy').format(controllers[i][13].text.trim())
          'orderDate': formattedDate

        };
        insertFutures.add(insertDataPendingReport(datapendingInsert));
        print("Data inserted for row $i");
        print('Inserting data: $datapendingInsert');
      }
      await Future.wait(insertFutures);
      Future.microtask(() {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text("Order Number"),
                content:  orderNo.text.isNotEmpty?Text("${orderNo.text} had partially ordered, Pending orderNumber is ${poNumber.toString()}    "):Text("${checkOrderNo.toString()} had partially ordered, Pending orderNumber is ${poNumber.toString()}    "),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EntrySales()));
                    },
                    child: const Text("OK"),
                  ), ]);

          },
        );
      });
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }
  /// pending data insert code ends here(1)

  ///unavailable data store to pending report code starts here(2)
  Map<String, dynamic> datapendingInsertunavailablestock = {};
  Future<void> insertDataUnavailablePendingReport(Map<String, dynamic> datapendingInsertunavailablestock) async {
    const String apiUrl = 'http://localhost:3309/pending_insert_unavailable'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'datapendingInsertunavailablestock': datapendingInsertunavailablestock}),
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
  Future<void> pendingUnavailabeToDatabase() async {
    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');
    if (poNumber.isEmpty) {
      poNumber = 'PO$year$month/001';
    }
    try{
      List<Future<void>> insertFutures = [];
      for (var i = 0; i < dcontrollers.length; i++) {
        if (i >= dcontrollers.length) {
          dcontrollers.add(List.generate(8, (j) => TextEditingController()));
        }
        String dateString = dcontrollers[i][13].text.trim();
        DateTime dateTime = DateFormat('dd-MM-yy').parse(dateString);
        String formattedDate = DateFormat('dd-MM-yy').format(dateTime);

        print("Inserting data for row $i");
        Map<String, dynamic> datapendingInsertunavailablestock = {
          "pendingOrderNo":poNumber.toString(),
          "date": eod.toString(),
          "orderNo":orderNo.text.isNotEmpty?dcontrollers[i][12].text:pendingorderNo.text,
          "custCode": custCode.text,
          "custName": custName.text,
          "custAddress": custAddress.text,
          "custMobile": custMobile.text,
          "pincode":cpincode.text,
          "deliveryType":deliveryType,
          'itemGroup': dcontrollers[i][0].text,
          'itemName': dcontrollers[i][1].text,
          'qty':dcontrollers[i][2].text.isNotEmpty?dcontrollers[i][2].text:'0',
          "checkOrderNo":orderNo.text.isNotEmpty? dcontrollers[i][12].text:checkOrderNo.toString(),
          "individualOrderNo": dcontrollers[i][12].text,
          'orderDate':formattedDate,
        };
        insertFutures.add(insertDataUnavailablePendingReport(datapendingInsertunavailablestock));
        Future.microtask(() {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: const Text("Order Number"),
                  content:  orderNo.text.isNotEmpty?Text("${orderNo.text} had partially soldOut, Pending orderNumber is ${poNumber.toString()} "):Text("$checkOrderNo had partially soldOut, Pending orderNumber is ${poNumber.toString()}    "),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EntrySales()));
                      },
                      child: const Text("OK"),
                    ), ]);
            },
          );
        });
        print("Data inserted for row $i");
        print('Inserting data: $datapendingInsertunavailablestock');
      }
      await Future.wait(insertFutures); // Await for all insertions to complete
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }
  ///unavailable data store to pending report code ends here(2)

  /// insert data to sales starts here
  Map<String, dynamic> dataToInsertPurchaseReturnItem = {};
  Future<void> insertDataSalesItem(Map<String, dynamic> dataToInsertPurchaseReturnItem) async {
    const String apiUrl = 'http://localhost:3309/sales_insert'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },

        body: jsonEncode({'dataToInsertPurchaseReturnItem': dataToInsertPurchaseReturnItem}),
      );
      if (response.statusCode == 200) {
        print('sales successfully');
        DateTime now=DateTime.now();
        String year=(now.year%100).toString();
        String month=now.month.toString().padLeft(2,'0');
        if (invoiceNumber.isEmpty) {
          invoiceNumber = 'IN$year$month/001';
        }
        //  createInvoicePDF(invoiceNo:invoiceNumber.toString(),orderNo:orderNo.text.trim(),custCode:custCode.text,custName:custName.text,custAddress:custAddress.text,custMobile:custMobile.text,date:eod.toString(), grandtotal:grandTotal.text,pincode:pcpincode.text,gstin:gstin.text,noNdate:controllers[i][12].text + "/"+ controllers[i][13].text);

        // Navigator.push(context, MaterialPageRoute(builder: (context)=>TaxInvoiceBill(invoiceNo: generateId(),orderNo:orderNo.text.trim(),custCode:custCode.text,custName:custName.text,custAddress:custAddress.text,custMobile:custMobile.text,date:eod.toString(), grandtotal:grandTotal.text,pincode:pcpincode.text,gstin:gstin.text)));
        //      Navigator.push(context, MaterialPageRoute(builder: (context)=>));
        // SalesGeneratePDF(invoiceNo: generateId(),orderNo:orderNo.text.trim(),custCode:custCode.text,custName:custName.text,custAddress:custAddress.text,custMobile:custMobile.text,date:date.toString(), grandtotal:grandTotal.text), // Pass dataToInsert to the PDF screen
        //    ),
        // // );
        Navigator.push(context, MaterialPageRoute(builder: (context)=> const EntrySales()));

      } else {
        print('Failed to insert data into the table');
        throw Exception('Failed to insert data into the table');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  Future<void> insertdataTosales() async {
    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');
    if (invoiceNumber.isEmpty) {
      invoiceNumber = 'IN$year$month/001';
    }
    try{


      List<Future<void>> insertFutures = [];
      for (var i = 0; i < controllers.length; i++) {
        if (i >= controllers.length) {
          controllers.add(List.generate(6+
              8, (j) => TextEditingController()));
        }
        print("Inserting data for row $i");
        Map<String, dynamic> dataToInsertPurchaseReturnItem = {
          "invoiceNo":invoiceNumber,
          "date": eod.toString(),
          "orderNo":orderNo.text.isNotEmpty?orderNo.text:pendingorderNo.text,
          "custCode": custCode.text,
          "custName": custName.text,
          "custAddress": custAddress.text,
          "custMobile": custMobile.text,
          "gstin":gstin.text,
          "deliveryType":deliveryType,
          "payType":payType,
          'unit':controllers[i][3].text,
          'itemGroup': controllers[i][0].text,
          'itemName': controllers[i][1].text,
          'totalCone': controllers[i][4].text,
          'rate': controllers[i][5].text,
          'gst':controllers[i][6].text ,
          'qty': controllers[i][2].text,
          'amt': controllers[i][7].text,
          'amtGST': controllers[i][8].text,
          'total': controllers[i][9].text,
          'grandTotal': grandTotal.text,
          "salesQty":controllers[i][10].text,
          "pincode":cpincode.text,
          "pendingQty":controllers[i][11].text.isNotEmpty?controllers[i][11].text:'0',
          "checkOrderNo":checkOrderNo.toString(),
          "individualOrderNo":controllers[i][12].text,
          'orderDate':controllers[i][13].text,
          "noNdate":"${controllers[i][12].text}/${controllers[i][13].text}",
          "transportNo":transNo.text,
        };
        insertFutures.add(insertDataSalesItem(dataToInsertPurchaseReturnItem));
        print("Data inserted for row $i");
        print('Inserting data: $dataToInsertPurchaseReturnItem');
        updateStock(controllers[i][0].text, controllers[i][1].text, int.parse(controllers[i][2].text));

        //
        createInvoicePDF(invoiceNo:invoiceNumber.toString(),orderNo:orderNo.text.trim(),custCode:custCode.text,custName:custName.text,custAddress:custAddress.text,custMobile:custMobile.text,date:eod.toString(), grandtotal:grandTotal.text,pincode:pcpincode.text,gstin:gstin.text,transportNo:transNo.text);

        /*     for(int i= 0; i<controllers.length;i++) {
            print("check store value of stock :${int.parse(
                controllers[i][2].text)}");
          }*/
        currentInvoiceNumber++;
        isDataSaved = true;
      }
      await Future.wait(insertFutures); // Await for all insertions to complete
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }
  /// insert data to sales ends here

  /// fetch data pending
  Future<Map<String, dynamic>> fetchPendingReportDetails(String orderNo) async {
    final response = await http.get(Uri.parse('http://localhost:3309/get_pending_report?orderNo=$orderNo'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      if (jsonData.isNotEmpty) {
        return jsonData[0]; // Assuming you expect a single result
      } else {
        throw Exception('Pending report details not found');
      }
    } else {
      throw Exception('Failed to fetch pending report details');
    }
  }
  double stockQuantity = 0.0;
  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const EntrySales()));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  List<Map<String, dynamic>> pendingQty = [];
  List<TextEditingController> qtycheckcontroller = [];
  List<int> quantities = [];
  List<int> getQuantities = [];
  List<int> pendingQties = [];
  /// unavailable stock details shows code startes here
  int? rowslenth=0;
  int? pendingrowslenth=0;
  List<List<TextEditingController>> dcontrollers = [];
  List<Map<String, dynamic>> rowDatadisable = [];
  //orderNo base
  Future<void> fetchStockDataDisableorderNO(List<String> orderNumbers) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_stock_items_for_sale?orderNumbers=${orderNumbers.join(',')}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;
        setState(()  {
          dcontrollers.clear();
          rowDatadisable.clear();
          for (var i = 0; i < rows.length; i++) {
            List<TextEditingController> rowControllers = [];
            Map<String, dynamic> row = {
              'itemGroup': rows[i]['itemGroup'],
              'itemName': rows[i]['itemName'],
              'qty': rows[i]['qty'].toString(),
              'unit': rows[i]['unit'].toString(),
              'rate': rows[i]['rate'].toString(),
              'gst': rows[i]['gst'].toString(),
              'orderNo': rows[i]['orderNo'].toString(),
              'date': rows[i]['date'].toString(),
            };
            for (int j = 0; j < 14; j++) {
              TextEditingController dcontroller = TextEditingController(text: row[_getKeyForColumnDisable(j)]);
              rowControllers.add(dcontroller);
            }
            double quantity = double.tryParse(rowControllers[2].text) ?? 0.0;//qty-4
            //    quantities.add(int.parse(quantity.toString())); // Add the quantity to the list
            double unit = double.tryParse(rowControllers[3].text) ?? 0.0;//unit-3
            double rate = double.tryParse(rowControllers[5].text) ?? 0.0;//rate-2
            double gst = double.tryParse( rowControllers[6].text) ?? 0.0;
            double temp = quantity * unit;
            double amt = temp * rate;
            double gstpersentage = amt * gst/100;
            double totals = amt+gstpersentage;
            rowControllers[4].text = temp.toStringAsFixed(0);//amt-5
            rowControllers[7].text = amt.toStringAsFixed(2);//amt-5
            rowControllers[8].text = gstpersentage.toStringAsFixed(2);//gstamot-6
            rowControllers[9].text = totals.toStringAsFixed(2);//total-7
            //     rowControllers[10].text =int.parse(quantity.toString()).toString();//total-7
            dcontrollers.add(rowControllers);
            rowDatadisable.add(row);
          }
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  //pending orderNo base
  Future<void> fetchStockDataDisablependingorderNO(List<String> pendingOrderNos) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_stock_items_for_sale_pending?pendingOrderNos=${pendingOrderNos.join(',')}');
      //  final url = Uri.parse('http://localhost:3309/get_stock_items_for_sale_pending?pendingOrderNo=$pendingOrderNo');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;
        await getAStock();
        setState(()  {
          dcontrollers.clear();
          focusNodes.clear();
          isRowFilled.clear();
          rowDatadisable.clear();
          for (var i = 0; i < rows.length; i++) {
            List<TextEditingController> rowControllers = [];
            Map<String, dynamic> row = {
              'itemGroup': rows[i]['itemGroup'],
              'itemName': rows[i]['itemName'],
              'qty': rows[i]['qty'].toString(),
              'unit': rows[i]['unit'].toString(),
              'rate': rows[i]['rate'].toString(),
              'gst': rows[i]['gst'].toString(),
              'orderNo': rows[i]['orderNo'].toString(),
              'date': rows[i]['date'].toString(),
            };

            fetchgetitemgGroup=row['itemGroup'].toString();
            fetchgetitemgName=row['itemName'].toString();
            fetchgetQty=int.parse(row['qty'].toString());
            for (int j = 0; j < 14; j++) {
              TextEditingController dcontroller = TextEditingController(text: row[_getKeyForColumnDisable(j)]);
              rowControllers.add(dcontroller);
            }
            double quantity = double.tryParse(rowControllers[2].text) ?? 0.0;//qty-4
            //  quantities.add(int.parse(quantity.toString())); // Add the quantity to the list
            double unit = double.tryParse(rowControllers[3].text) ?? 0.0;//unit-3
            double rate = double.tryParse(rowControllers[5].text) ?? 0.0;//rate-2
            double gst = double.tryParse( rowControllers[6].text) ?? 0.0;
            double temp = quantity * unit;
            double amt = temp * rate;
            double gstpersentage = amt * gst/100;
            double totals = amt+gstpersentage;
            rowControllers[4].text = temp.toStringAsFixed(0); //amt-5

            rowControllers[7].text = amt.toStringAsFixed(2);//amt-5
            rowControllers[8].text = gstpersentage.toStringAsFixed(2);//gstamot-6
            rowControllers[9].text = totals.toStringAsFixed(2);//total-7
            //   rowControllers[10].text =int.parse(quantity.toString()).toString();//total-7
            dcontrollers.add(rowControllers);
            focusNodes.add(List.generate(9, (i) => FocusNode()));
            rowDatadisable.add(row);
          }
          grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  /// unavailable stock details shows code ends here


  ///fetch checkOrderNo for find orginal orderno in pending reports starts
/*
  Future<void> fetchCheckOrderNo(String pendingOrderNo) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3309/fetch_checkOrderNo?pendingOrderNo=$pendingOrderNo'),
      );   //   final response = await http.get(url);

      print('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List && responseData.isNotEmpty) {
          final result = responseData[0]["result"];
          checkOrderNo =responseData[0]["result"];

          print('Selected Invoice Number: $pendingOrderNo');
          print('CheckOrderNo: $result');

          // You can use the value in "result" as needed in your application
        } else {
          print('Error: Invalid response data format');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
*/

  List<Map<String,dynamic>> checkingOrderNo=[];
  Future<void> fetchCheckOrderNos(List<String> pendingOrderNos) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3309/fetch_checkOrderNo?pendingOrderNos=${pendingOrderNos.join(',')}'),
      );
      print('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        //  final result = response.body;
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          checkingOrderNo = List<Map<String, dynamic>>.from(responseData.map((dynamic item) => item as Map<String, dynamic>));
        });

        if (checkingOrderNo.isNotEmpty) {
          final String checkOrderNoValue = checkingOrderNo.first['result'];
          setState(() {
            checkOrderNo = checkOrderNoValue;
          });
          print('Selected Invoice Numbers: $checkOrderNoValue');
        } else {
          print('Error: Result is an empty list');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  ///ends checkOrderNofor find orginal orderno in pending reports ends
  Map<String, int> aggregatedQuantities = {};
  List<List<TextEditingController>> originalControllers = [];
  // After fetching data, update controllers with modifiedData
  void updateControllersWithModifiedData(List<Map<String, dynamic>> modifiedData) {
    for (var i = 0; i < controllers.length; i++) {
      for (var j = 0; j < controllers[i].length; j++) {
        // Assuming 'itemGroup', 'itemName', and 'qty' are keys in modifiedData
        String itemGroup = modifiedData[i]['itemGroup'];
        String itemName = modifiedData[i]['itemName'];
        String qty = modifiedData[i]['qty'].toString();
        controllers[i][0].text = itemGroup;
        controllers[i][1].text = itemName;
        controllers[i][2].text = qty;

        // Update other controllers if needed...
      }
    }
  }

// Convert controllers to originalControllers
  void convertControllersToOriginalControllers() {
    for (var i = 0; i < controllers.length; i++) {
      List<TextEditingController> originalRowControllers = [];
      for (var j = 0; j < controllers[i].length; j++) {
        TextEditingController originalController = TextEditingController(text: controllers[i][j].text);
        originalRowControllers.add(originalController);
      }
      originalControllers.add(originalRowControllers);
    }
  }
  List<Map<String, dynamic>> originalDataList = []; // Store original data
  bool isPendingOrder = false;

  ///order no base fetch data for table starts
  Future<void> fetchDataByOrderNumber(List<String> orderNumbers) async {
    try {
      if (orderNumbers.isEmpty) {
        setState(() {
          controllers.clear();
          focusNodes.clear();
          isRowFilled.clear();
          rowData.clear();
        });
        return;
      }

      final url = Uri.parse('http://localhost:3309/get_sales_product_items?orderNumbers=${orderNumbers.join(',')}');
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
              'itemGroup': rows[i]['itemGroup'],
              'itemName': rows[i]['itemName'],
              'qty': rows[i]['qty'].toString(),
              'unit': rows[i]['unit'].toString(),
              'rate': rows[i]['rate'].toString(),
              'gst': rows[i]['gst'].toString(),
              'orderNo': rows[i]['orderNo'].toString(),
              'date': rows[i]['date'].toString(),
            };
            print('Response Fetch Data: $responseData');
            print('Rows: $rows');
            fetchgetitemgGroup=row['itemGroup'].toString();
            fetchgetitemgName=row['itemName'].toString();
            fetchgetQty=int.parse(row['qty'].toString());
            for (int j = 0; j < 14; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }
            setState(() {
              double quantity = double.tryParse(rowControllers[2].text) ?? 0.0;
              double unit = double.tryParse(rowControllers[3].text) ?? 0.0;
              double rate = double.tryParse(rowControllers[5].text) ?? 0.0;
              double gst = double.tryParse( rowControllers[6].text) ?? 0.0;
              double temp = quantity * unit;
              double amt = temp * rate;
              double gstpersentage = amt * gst/100;
              double totals = amt+gstpersentage;
              setState(() {
                rowControllers[4].text = temp.toStringAsFixed(0);//amt-5
                rowControllers[7].text = amt.toStringAsFixed(2);//amt-5
                rowControllers[8].text = gstpersentage.toStringAsFixed(2);//gstamot-6
                rowControllers[9].text = totals.toStringAsFixed(2);//total-7
              });

            });
            controllers.add(rowControllers);
            focusNodes.add(List.generate(14, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);
            validQuantity = rowControllers[2].text;
            validRate = rowControllers[5].text;
            validGST = rowControllers[6].text;

            setState(() {
              originalDataList = List.from(rowData);

            });
            if (validQuantity=='0'){
              setState(() {
                errorMessage="* Enter a Valid Qty";
              });
            }
            else if(validQuantity.isEmpty){
              setState(() {
                errorMessage="* Enter a Qty";
              });
            }
            ///rate validation
            else if(validRate== '0') {
              setState(() {
                errorMessage ="* Enter a valid Rate";
              });}
            else if(validRate.isEmpty) {
              setState(() {
                errorMessage ="* Enter a Rate";
              });
            }
            ///gst validations
            else if(validGST=='0') {
              setState(() {
                errorMessage ="* Enter a valid GST";
              });}
            else if(validGST.isEmpty) {
              setState(() {
                errorMessage ="* Enter a GST(%)";
              });
            }}
          grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
          setState(() {
            suggesstiondata.removeWhere(
                  (item) => orderNumbers.contains(item['orderNo'].toString()),
            );
            rowslenth= rows.length;
          });//}
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
/*
  Future<void> fetchavailableStockByOrderNumber(List<String> orderNumbers) async {
    try {
      if (orderNumbers.isEmpty) {
        setState(() {
          controllers.clear();
          focusNodes.clear();
          isRowFilled.clear();
          rowData.clear();
        });
        return;
      }

      final url = Uri.parse('http://localhost:3309/get_stock_available_qty?orderNumbers=${orderNumbers.join(',')}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;

        setState(() {
          // Clear data structures before populating them with new data
          controllers.clear();
          focusNodes.clear();
          isRowFilled.clear();
          rowData.clear();
          for (var i = 0; i < rows.length; i++) {
            */
/* String itemGroup = rows[i]['itemGroup'];
            String itemName = rows[i]['itemName'];
            int existingIndex = -1;
            for (int j = 0; j < controllers.length; j++) {
              if (controllers[j][0].text == itemGroup && controllers[j][1].text == itemName) {
                existingIndex = j;
                break;
              }
            }
            if (existingIndex != -1) {
              // If item already exists, update the quantity
              int currentQty = int.parse(controllers[existingIndex][2].text);
              int newQty = currentQty + int.parse(rows[i]['qty'].toString());
              controllers[existingIndex][2].text = newQty.toString();
            }else{
*/
/*


            List<TextEditingController> rowControllers = [];
            Map<String, dynamic> row = {
              'itemGroup': rows[i]['itemGroup'],
              'itemName': rows[i]['itemName'],
              'qty': rows[i]['qty'].toString(),
              'unit': rows[i]['unit'].toString(),
              'rate': rows[i]['rate'].toString(),
              'gst': rows[i]['gst'].toString(),
              'orderNo': rows[i]['orderNo'].toString(),
              'date': rows[i]['date'].toString(),
            };
            print('Response Fetch Data: $responseData');
            print('Rows: $rows');
            fetchgetitemgGroup=row['itemGroup'].toString();
            fetchgetitemgName=row['itemName'].toString();
            fetchgetQty=int.parse(row['qty'].toString());
            for (int j = 0; j < 14; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }
            double quantity = double.tryParse(rowControllers[2].text) ?? 0.0;//qty-4
            quantities.add(int.parse(quantity.toString())); // Add the quantity to the list
            double unit = double.tryParse(rowControllers[3].text) ?? 0.0;//unit-3
            double rate = double.tryParse(rowControllers[5].text ) ?? 0.0;//rate-2
            double gst = double.tryParse( rowControllers[6].text) ?? 0.0;
            double temp = quantity * unit;
            double amt = temp * rate;
            double gstpersentage = amt * gst/100;
            double totals = amt+gstpersentage;
            rowControllers[4].text = temp.toString();//amt-5
            rowControllers[7].text = amt.toStringAsFixed(2);//amt-5
            rowControllers[8].text = gstpersentage.toStringAsFixed(2);//gstamot-6
            rowControllers[9].text = totals.toStringAsFixed(2);//total-7
            rowControllers[10].text =int.parse(quantity.toString()).toString();//total-7
            rowControllers[11].text =rowControllers[11].text;//total-7
            controllers.add(rowControllers);
            focusNodes.add(List.generate(9, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);
            validQuantity = rowControllers[2].text;
            validRate = rowControllers[5].text;
            validGST = rowControllers[6].text;
            setState(() {
              originalDataList = List.from(rowData);

            });
            if (validQuantity=='0'){
              setState(() {
                errorMessage="* Enter a Valid Qty";
              });
            }
            else if(validQuantity.isEmpty){
              setState(() {
                errorMessage="* Enter a Qty";
              });
            }
            ///rate validation
            else if(validRate== '0') {
              setState(() {
                errorMessage ="* Enter a valid Rate";
              });}
            else if(validRate.isEmpty) {
              setState(() {
                errorMessage ="* Enter a Rate";
              });
            }
            ///gst validations
            if(validGST=='0') {
              setState(() {
                errorMessage ="* Enter a valid GST";
              });}
            else if(validGST.isEmpty) {
              setState(() {
                errorMessage ="* Enter a GST(%)";
              });
            }}
          grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
          setState(() {
            suggesstiondata.removeWhere(
                  (item) => orderNumbers.contains(item['orderNo'].toString()),
            );
            rowslenth= rows.length;
          });//}
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
*/

  ///table for pending report ends

  ///PendingOrder Numberbase fetch table data  starts
  Future<void> fetchDataByPendingOrderNumber(List<String> pendingOrderNos) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_pending_items?pendingOrderNos=${pendingOrderNos.join(',')}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;
        setState(()  {
          controllers.clear();
          focusNodes.clear();
          isRowFilled.clear();
          rowData.clear();
          for (var i = 0; i < rows.length; i++) {

            List<TextEditingController> rowControllers = [];
            Map<String, dynamic> row = {
              'itemGroup': rows[i]['itemGroup'],
              'itemName': rows[i]['itemName'],
              'qty': rows[i]['qty'],
              'unit': rows[i]['unit'].toString(),
              'rate': rows[i]['rate'].toString(),
              'gst': rows[i]['gst'].toString(),
              'orderNo': rows[i]['orderNo'].toString(),
              'date': rows[i]['date'].toString(),

            };
            fetchgetitemgGroup=row['itemGroup'].toString();
            fetchgetitemgName=row['itemName'].toString();
            fetchgetQty=int.parse(row['qty'].toString());
            for (int j = 0; j < 14; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }
            setState(() {
              double quantity = double.tryParse(rowControllers[2].text) ?? 0.0;//qty-4
              // quantities.add(int.parse(quantity.toString())); // Add the quantity to the list
              double unit = double.tryParse(rowControllers[3].text) ?? 0.0;//unit-3
              double rate = double.tryParse(rowControllers[5].text) ?? 0.0;//rate-2
              double gst = double.tryParse( rowControllers[6].text) ?? 0.0;
              double temp = quantity * unit;
              double amt = temp * rate;
              double gstpersentage = amt * gst/100;
              double totals = amt+gstpersentage;
              rowControllers[4].text = temp.toStringAsFixed(0);//amt-5
              rowControllers[7].text = amt.toStringAsFixed(2);//amt-5
              rowControllers[8].text = gstpersentage.toStringAsFixed(2);//gstamot-6
              rowControllers[9].text = totals.toStringAsFixed(2);//total-7

            });

            //  rowControllers[10].text =int.parse(quantity.toString()).toString();//total-7
            controllers.add(rowControllers);
            focusNodes.add(List.generate(9, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);
            validQuantity = rowControllers[2].text;
            validRate = rowControllers[5].text;
            validGST = rowControllers[6].text;
            if (validQuantity=='0'){
              setState(() {
                errorMessage="* Enter a Valid Qty";
              });
            }
            else if(validQuantity.isEmpty){
              setState(() {
                errorMessage="* Enter a Qty";
              });
            }
            ///rate validation
            else if(validRate== '0') {
              setState(() {
                errorMessage ="* Enter a valid Rate";
              });}
            else if(validRate.isEmpty) {
              setState(() {
                errorMessage ="* Enter a Rate";
              });
            }else if(validRate.isNotEmpty) {
              setState(() {
                errorMessage ="";
              });
            }
            ///gst validations
            if(validGST=='0') {
              setState(() {
                errorMessage ="* Enter a valid GST";
              });}
            else if(validGST.isEmpty) {
              setState(() {
                errorMessage ="* Enter a GST(%)";
              });
            }
          }
          grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
          setState(() {
            pendingrowslenth= rows.length;
          });

        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  ///PendingOrder Numberbase fetch table data  ends

  bool isStockValueIsZERO(String itemGroup, String itemName, int requiredQty) {
    // Find the stock data for the specified itemGroup and itemName
    var stockItem = stockdata.firstWhere(
          (item) => item['itemGroup'] == itemGroup && item['itemName'] == itemName,
      orElse: () => <String, dynamic>{},
    );

    //  if (stockItem != null) {
    int stockQty = int.parse(stockItem['qty']);
    return stockQty ==0;
    //  }

    // Item not found in stock
    // return false;
  }

  double pendingqty =0.0;
  double editPendingQty =0.0;
  double dpendingQty =0.0;
  List<Map<String, dynamic>> stockdata = [];
  List totalvaluezerocheck = [];
  List<Map<String, dynamic>> pendingdata = [];
  List<Map<String, dynamic>> suggesstiondata = [];
  List<Map<String, dynamic>> suggesstiondataForduplicate = [];
  List<Map<String, dynamic>> pendingsuggesstiondata = [];
  String? getitemgGroup;
  String? getitemgName;
  double? getQty = 0.0; String? fetchgetitemgGroup="";
  String? fetchgetitemgName;
  String validQuantity ="";
  String validRate ="";
  String validGST ="";

  ///fetch stock items for duplicate values check starts here
  Future<void> getAStock() async {
    try {
      final url = Uri.parse('http://localhost:3309/stock_get_report/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          stockdata = itemGroups.cast<Map<String, dynamic>>();
        });

        //print('Data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  ///fetch stock items for duplicate values check ends here
  void clearTableDetails() {
    setState(() {
      controllers.clear();
      focusNodes.clear();
      isRowFilled.clear();
      rowData.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    //addRow();
    fetchData();
    fetchDataDuplicateCheck();
    fetchPendingData();
    fetchPendingDataD();
    fetchDataSuggestion(selectedOrderNumbers);
    fetchPendingSuggession(selectedPendingOrderNumbers);
    loadInvoiceNumber();
    reNoFetch();
    ponumfetchsalINv();
    fetchData2();
    getAStock();
    // fetchStockDataDisableorderNO(selectedOrderNumbers);
    //  fetchCheckOrderNos(selectedPendingOrderNumbers);
    // fetchDataByPendingOrderNumber(pendingorderNo.text);
    //  fetchStockDataDisablependingorderNO(pendingorderNo.text);
    setState(() {
      fetchDataPending2();
      fetchPono();
      filterPoNo(invoiceNo.text);
    });
    setState(() {

    });

  }
//for customer details fetch
  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_sales_name/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          data = itemGroups.cast<Map<String, dynamic>>();
        });

        print('get  purchase order Data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }
  Future<void> fetchDataDuplicateCheck() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_sales_name_data/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          suggesstiondataForduplicate = itemGroups.cast<Map<String, dynamic>>();
        });

        print('get  purchase order Data: $suggesstiondataForduplicate');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }
  //for customer details fetch for pending orderNo

  Future<void> fetchPendingData() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_pending_name/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          pendingdata = itemGroups.cast<Map<String, dynamic>>();
        });

        print('Data: $pendingdata');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }
  List<Map<String, dynamic>> pendingdataDuplicate = [];

  Future<void> fetchPendingDataD() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_pending_name_data/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          pendingdataDuplicate = itemGroups.cast<Map<String, dynamic>>();
        });

        print('Data: $pendingdataDuplicate');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }


  ///for suggesstionlist details fetch
  /* Future<void> fetchDataSuggestion(
      ) async {
    try {
      final Uri url = Uri.parse('http://localhost:3309/get_sales_name_for_suggestion/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          suggesstiondata = itemGroups.cast<Map<String, dynamic>>();
        });

        print('Data suggestion: $suggesstiondata');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }*/
  Future<void> fetchDataSuggestion(List<String>? orderNoList,) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_sales_name_for_suggestion/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          suggesstiondata = itemGroups.cast<Map<String, dynamic>>();
        });
        setState(() {

        });
        print('Pending Data: $suggesstiondata');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }


  ///for suggesstion pendingorderNo
  Future<void> fetchPendingSuggession(List<String>? orderNoList,) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_pending_name_for_suggestion/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          pendingsuggesstiondata = itemGroups.cast<Map<String, dynamic>>();
        });
        setState(() {

        });
        print('Pending Data: $pendingsuggesstiondata');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }

  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filteredDataPending = [];
  List<Map<String, dynamic>> datapending = [];
  ///orderNo base fetch a customer details
  void filterData(String searchText) {
    setState(() {
      List<String> searchList = searchText.split(' ');

      if (searchText.isEmpty) {
        filteredData = data;
        custCode.clear();
        custName.clear();
      } else {
        filteredData = data.where((item) {
          String id = item['orderNo']?.toString().toLowerCase() ?? '';
          return searchList.any((searchItem) => id.contains(searchItem.toLowerCase()));
        }).toList();

        if (filteredData.isNotEmpty) {
          Map<String, dynamic> order = filteredData.first;
          custCode.text = order['custCode']?.toString() ?? '';
          custName.text = order['custName']?.toString() ?? '';
          //  deliveryType = order['deliveryType']?.toString() ?? '';
        } else {
          custCode.clear();
          custName.clear();
        }
      }
    });
  }

  ///pendingorderNo base fetch a customer details
  void filterDatapending(String searchText) {
    setState(() {
      List<String> searchList = searchText.split(' ');

      if (searchText.isEmpty) {
        filteredDataPending = pendingdata;
        custCode.clear(); custName.clear();
      } else {
        filteredDataPending = pendingdata.where((item) {
          String id = item['pendingOrderNo']?.toString().toLowerCase() ?? '';
          return searchList.any((searchItem) => id.contains(searchItem.toLowerCase()));
        }).toList();
        if (filteredDataPending.isNotEmpty) {
          Map<String, dynamic> order = filteredDataPending.first;
          custCode.text = order['custCode']?.toString() ?? '';
          custName.text = order['custName']?.toString() ?? '';
          //   deliveryType = order['deliveryType']?.toString() ?? '';
        } else {
          custCode.clear();custName.clear();
        }
      }
    });
  }
  String selectedInvoiceNo='';
  String selectedPendingNo='';
  List<Map<String, dynamic>> filteredData2 = [];
  List<Map<String, dynamic>> data2 = [];
  List<Map<String, dynamic>> filteredDataPending2 = [];
  List<Map<String, dynamic>> datapending2 = [];
  void filterData2(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData2 = data2;
        custMobile.clear();
        custAddress.clear();
        cpincode.clear();
        gstin.clear();
        deliveryType =null;
        transNo.clear();
      } else {
        final existingSupplier = data2.firstWhere(
              (item) => item['custCode']?.toString() == searchText,
          orElse: () => {}, // Use an empty map literal as the default value
        );
        if (existingSupplier.isNotEmpty) {
          custMobile.text = existingSupplier['custMobile']?.toString() ?? '';
          custAddress.text = existingSupplier['custAddress'];
          cpincode.text = existingSupplier['pincode'];
          gstin.text = existingSupplier['gstin'];
          //  deliveryType = existingSupplier['deliveryType'];
        } else {
          custMobile.clear();
          custAddress.clear();
          cpincode.clear();
          gstin.clear();
          deliveryType=null;
          transNo.clear();
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
        print('Data sales customer: $data2');
      } else {
        print('Error sales customer: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }
  ///fetch pending_customer details in textformfield  starts

  void filterDataPendingData2(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredDataPending2 = datapending2;
        custMobile.clear();
        custAddress.clear();
        cpincode.clear();
        gstin.clear();
        pcustMobile.clear();
        pcustAddress.clear();
        pcpincode.clear();
      } else {
        final existingSupplier = datapending2.firstWhere(
              (item) => item['custCode']?.toString() == searchText,
          orElse: () => {}, // Use an empty map literal as the default value
        );
        if (existingSupplier.isNotEmpty) {
          pcustMobile.text = existingSupplier['custMobile']?.toString() ?? '';
          pcustAddress.text = existingSupplier['custAddress'];
          pcpincode.text = existingSupplier['pincode'];
          pgstin.text = existingSupplier['gstin'];
          pdeliveryType = existingSupplier['deliveryType'];
        } else {
          pcustMobile.clear();
          pcustAddress.clear();
          pcpincode.clear();
          pgstin.clear();
        }
      }
    });
  }
  Future<void> fetchDataPending2() async {
    try {
      final url = Uri.parse('http://localhost:3309/fetch_pending_customer_details/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;
        setState(() {
          datapending2 = itemGroups.cast<Map<String, dynamic>>();
        });
        print('Data  Pending sales customer: $datapending2');
      } else {
        print('Error sales customer: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }
  ///fetch pending_customer details in textformfield  ends

  int currentInvoiceNumber = 1;
  void loadInvoiceNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedInvoiceNumber = prefs.getInt('currentInvoiceNumber');
    if (storedInvoiceNumber != null && storedInvoiceNumber > 0) {
      setState(() {
        currentInvoiceNumber = storedInvoiceNumber;
      });
    }
  }
  List<Map<String, dynamic>> data3 = [];
  List<Map<String, dynamic>> pendingdata3 = [];
  List<Map<String, dynamic>> filteredData3 = [];
  List<Map<String, dynamic>> pendingfilteredData3 = [];
  /// check for condition already exist or not starts
  Future<void> fetchPono() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_sales_invoice'));
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
            title: const Text('Error'),
            content: Text('An error occurred: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
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
  bool isMachineNameExists(String name) {
    return data3.any((item) => item['orderNo'].toString().toLowerCase() == name.toLowerCase());
  }
  bool isOrderComplete(String orderNo) {
    // Find the order in your data
    var order = data3.firstWhere(
          (item) => item['orderNo'] == orderNo,
      orElse: () => <String, dynamic>{}, // Return an empty map if not found
    );

    // Check if the order exists and has a delivery type of 'Complete'
    return /*order != null &&*/ order['deliveryType'] == 'Complete';
  }
  bool isOrderPartial(String orderNo) {
    var order = data3.firstWhere(
          (item) => item['orderNo'] == orderNo,
      orElse: () => <String, dynamic>{},
    );

    return /*order !=  null &&*/ order['deliveryType'] == 'Partial';
  }
  /// check for condition already exist or not ends
  double amtgstc= 0.0;

  ///
  String generateReturnId() {
    String formattedDateYear = DateFormat('yy').format(DateTime.now());
    String formattedDateMonth = DateFormat('MM').format(DateTime.now());
    String formattedNumber = currentInvoiceNumber.toString().padLeft(3, '0');
    String invoiceNumber = 'IN/$formattedDateYear$formattedDateMonth/$formattedNumber';
    return invoiceNumber;
  }
  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['invoiceNo'];
  }
  String invoiceNumber = "";
  List<Map<String, dynamic>> codedata = [];
  String generateId() {
    DateTime now= DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');
    if (rNO != null) {
      String iD = rNO!.substring(7);
      int idInt = int.parse(iD) + 1;
      String id = 'IN$year$month/${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  List<Map<String, dynamic>> returnNoData = [];
  String? rNO;
  Future<void> reNoFetch() async {
    try {
      BuildContext storedContext = context;

      final response = await http.get(Uri.parse('http://localhost:3309/get_invoice_no'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for (var item in jsonData) {
          rNO = getNameFromJsonData(item);
          print('poNo: $rNO');
        }
        setState(() {
          returnNoData = jsonData.cast<Map<String, dynamic>>();
          invoiceNumber = generateId(); // Call generateId here
        });
      } else {
        showDialog(
          context: storedContext,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to fetch data'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
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
            title: const Text('Error'),
            content: Text('An error occurred: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

/*
  Future<void> reNoFetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_invoice_no'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          rNO = getNameFromJsonData(item);
          print('poNo: $rNO');
        }
        setState(() {
          returnNoData = jsonData.cast<Map<String, dynamic>>();
          invoiceNumber = generateId(); // Call generateId here

        });
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to fetch data'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
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
            title:const Text('Error'),
            content: Text('An error occurred: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
*/
  RegExp truckNumberPattern = RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{1,2}\d{1,4}$');

  Map<String, int> originalAvailableQuantities = {};

/*
  void updateUnavailableQuantity(int rowIndex, int newAvailableQuantity) {
    if (rowIndex >= 0 && rowIndex < controllers.length) {
      // Calculate the change in quantity
      int oldAvailableQuantity = int.parse(controllers[rowIndex][2].text);
      int quantityChange = oldAvailableQuantity - newAvailableQuantity;

      // Update the corresponding dcontrollers entry
      dcontrollers[rowIndex][2].text = (int.parse(dcontrollers[rowIndex][2].text) + quantityChange).toString();
    }
  }
*/
  String? getNameFromJsonDatasalINv(Map<String, dynamic> jsonItem) {
    return jsonItem['pendingOrderNo'];
  }
  String poNumber = "";
  String? poNo;
  List<Map<String, dynamic>> ponumdata = [];
  String? pONO;
  List<Map<String, dynamic>> codedatas = [];
  String generateIdinvNo() {
    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');
    if (pONO != null) {
      String iD = pONO!.substring(7);
      int idInt = int.parse(iD) + 1;
      String id = 'PO$year$month/${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ponumfetchsalINv() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/pendingInvNo_fetch'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          pONO = getNameFromJsonDatasalINv(item);
          print('pendingOrderNo: $pONO');
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
              title: const Text('Error'),
              content:const Text('Failed to fetch data'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
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
            title:const Text('Error'),
            content: Text('An error occurred: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }


  List<String> itemGroups = [];
  List<String> itemNames = [];
  Future<void> updateStock(String itemGroup, String itemName, int qty) async {
    final Uri url = Uri.parse('http://localhost:3309/sales_to_update_Stock'); // Replace with your actual backend URL
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'itemGroup': itemGroup,
        'itemName': itemName,
        /*  'size': size,
        'color': color,*/
        'qty': qty.toString(),
      }),
    );

    if (response.statusCode == 200) {
      print('Update successful');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
      throw Exception('Failed to update');
    }
  }
  Map<String, double> totalQuantities = {};

  void handleAvailableQtyChange(int rowIndex, double newAvailableQty) {
    // Parse the current available and unavailable quantities
    double currentAvailableQty = double.parse(controllers[rowIndex][2].text);
    double currentUnavailableQty = double.parse(dcontrollers[rowIndex][2].text);
    double currentaAvailableQty = double.parse(controllers[rowIndex][10].text);
    double totalLimit = currentUnavailableQty+currentaAvailableQty;
    // Calculate the increase in available quantity
    double increase = newAvailableQty - currentAvailableQty;

    // Get the itemGroup and itemName
    String itemGroup = controllers[rowIndex][0].text;
    String itemName = controllers[rowIndex][1].text;
    String key = '$itemGroup-$itemName';

    // Calculate the total quantity for the itemGroup and itemName
    double totalQuantity = currentAvailableQty + currentUnavailableQty;

    // Check against the total limit
    //
    if (totalQuantity + increase > totalLimit) {
      increase = totalLimit - totalQuantity;
      newAvailableQty = currentAvailableQty + increase;
    }

    // Update the available and unavailable quantities
    controllers[rowIndex][2].text = newAvailableQty.toString();
    dcontrollers[rowIndex][2].text = (currentUnavailableQty + increase).toString();

    // Update the total quantity in the map
    totalQuantities[key] = currentUnavailableQty + increase;
  }
  ///Addrow fetch code old
//total lenth of row
  int? totalRows =0;
  bool checkEnable= false;
  double? beforeEditQty;
  int? afterEditQty;
  int selectedCheckbox = 1;

  List<String> selectedOrderNumbers = [];
  List<String> selectedPendingOrderNumbers = [];
  List<Map<String, dynamic>> productDetails = [];

  bool removeVisible = false;
  void handleButtonPress() {
    filterData(orderNo.text);
    fetchDataByOrderNumber(selectedOrderNumbers);
    fetchStockDataDisableorderNO(selectedOrderNumbers);

  }
  void pendinghandleButtonPress(){
    filterDatapending(pendingorderNo.text);
    fetchCheckOrderNos(selectedPendingOrderNumbers);
    fetchDataByPendingOrderNumber(selectedPendingOrderNumbers);
    fetchStockDataDisablependingorderNO(selectedPendingOrderNumbers);
  }

  @override
  Widget build(BuildContext context) {
    // DateTime Date = DateTime.now();
    // final formattedDate = DateFormat("dd/MM/yyyy").format(Date);
    custCode.addListener(() {
      filterData2(custCode.text);
      filterDataPendingData2(custCode.text);
    });
    return MyScaffold(
        route: "entry_sales",backgroundColor: Colors.white,
        body:  Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    // ElevatedButton(onPressed: (){
                    //   createInvoicePDF(invoiceNo:"IN2401/001",orderNo:"ORD002",custCode:"C025",custName:"Bhuvana",custAddress:"Amman nagar ,KPM",custMobile:"1234567890",date:"2024-01-27", grandtotal:"8053.50",pincode:"123456",gstin:"33BBBp", transportNo: 'ka01Ak0001');
                    //
                    // }, child: Text("test")),
                    Padding(
                      padding: const EdgeInsets.only(left:5,right:5,top:5),
                      child: SizedBox(
                        height: 200,
                        child: Container(
                          width: double.infinity, // Set the width to full page width
                          padding: const EdgeInsets.all(16.0), // Add padding for spacing
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
                                       Row(
                                        children: [
                                          SizedBox(height: 15,),
                                          Icon(Icons.local_grocery_store, size:30),
                                          Text("Sales Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),
                                          IconButton(
                                            icon: Icon(Icons.refresh),
                                            onPressed: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=> EntrySales()));
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.arrow_back),
                                            onPressed: () {
                                              // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalaryCalculation()));
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: selectedCheckbox == 1,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                pendingorderNo.clear();
                                                controllers.clear();
                                                dcontrollers.clear();
                                                custCode.clear();
                                                custName.clear();
                                                custMobile.clear();
                                                custAddress.clear();
                                                deliveryType==null;
                                                payType ==null;
                                                errorMessage ="";
                                                selectedOrderNumbers.clear();
                                                selectedPendingOrderNumbers.clear();
                                                checkOrderNo ="";

                                                //
                                                // fetchData();
                                                // fetchDataSuggestion(selectedOrderNumbers);
                                                // fetchPendingData();
                                                // fetchPendingDataD();
                                                // fetchDataDuplicateCheck();

                                                // fetchDataByPendingOrderNumber(selectedPendingOrderNumbers);



                                                if (value != null && value) {

                                                  selectedCheckbox = 1;

                                                } else {
                                                  // Toggle between 1 and 2
                                                  selectedCheckbox = selectedCheckbox == 1 ? 2 : 1;

                                                }
                                              });
                                            },
                                          ),
                                          const Text("Sales Order Number"),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: selectedCheckbox == 2,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                orderNo.clear();
                                                controllers.clear();
                                                dcontrollers.clear();
                                                custCode.clear();
                                                custName.clear();
                                                custMobile.clear();
                                                custAddress.clear();
                                                deliveryType==null;
                                                payType ==null;
                                                errorMessage ="";
                                                checkOrderNo ="";
                                                selectedPendingOrderNumbers.clear();
                                                selectedOrderNumbers.clear();
                                                checkOrderNo="";


                                                if (value != null && value) {

                                                  selectedCheckbox = 2;
                                                } else {
                                                  // Toggle between 2 and 1
                                                  selectedCheckbox = selectedCheckbox == 2 ? 1 : 2;

                                                }
                                              });
                                            },
                                          ),
                                          const Text("Pending Order Number"),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: Column(
                                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                SizedBox(
                                                  child: TextFormField(
                                                    style: const TextStyle(fontSize: 13),
                                                    readOnly: true,
                                                    onTap: () {
                                                      showDatePicker(
                                                        context: context,
                                                        initialDate: eod,

                                                        firstDate: DateTime(2000),
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

                                                // Align(
                                                //     alignment: Alignment.topLeft,
                                                //     child: Text(formattedDate,style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),)),

                                                const Divider(
                                                  color: Colors.grey,
                                                ),
                                                const Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    "Invoice Number",
                                                    style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                //   SizedBox(height: 5,),
                                                Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(invoiceNumber.isEmpty ? "IN${DateTime.now().year % 100}${DateTime.now().month.toString().padLeft(2, '0')}/001" : invoiceNumber)),
                                                const Divider(
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20,),
                                        ],
                                      ),
                                    ]
                                ),
                                //  Text("heloooooooooooss"),
                                ///old typeaheadformfield code
/*
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Visibility(
                                      visible: selectedCheckbox == 1,
                                      child: SizedBox(width: 300,
                                        child: TypeAheadFormField<String>(
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: orderNo,
                                            style: const TextStyle(fontSize: 13),
                                            inputFormatters:
                                            [UpperCaseTextFormatter()],
                                            decoration: InputDecoration(
                                              fillColor: Colors.white, filled: true,
                                              labelText: "Order Number",
                                              labelStyle: TextStyle(fontSize: 13),
                                              suffixIcon: orderNo.text.isNotEmpty
                                                  ? Visibility(
                                                visible: removeVisible,
                                                child: IconButton(
                                                  icon: Icon(Icons.clear),
                                                  onPressed: () {
                                                    selectedOrderNumbers.clear();
                                                  },
                                                ),
                                              )
                                                  : null, // Don't show the icon if there is no text
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),),
                                            ),),
                                          suggestionsCallback: (pattern) async {
                                            List<String> inputParts = pattern.split(',').map((part) => part.trim()).toList();
                                            String currentInput = inputParts.isNotEmpty ? inputParts.last : '';
                                            List<String> suggestions;
                                            if (currentInput.isNotEmpty) {
                                              suggestions = suggesstiondata
                                                  .where((item) =>
                                              (item['orderNo']?.toString().toLowerCase() ?? '')
                                                  .startsWith(currentInput.toLowerCase()) &&
                                                  !selectedOrderNumbers.contains(item['orderNo'].toString()))
                                                  .map((item) => item['orderNo'].toString())
                                                  .toSet()
                                                  .toList();
                                            } else {
                                              suggestions = suggesstiondata
                                                  .where((item) => !selectedOrderNumbers.contains(item['orderNo'].toString()))
                                                  .map((item) => item['orderNo'].toString())
                                                  .toSet()
                                                  .toList();}
                                            suggestions.sort((a, b) => b.compareTo(a));
                                            return suggestions;
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) async {
                                            if (!selectedOrderNumbers.contains(suggestion)) {
                                              setState(() {
                                                removeVisible=true;
                                                selectedOrderNumbers.add(suggestion);
                                                orderNo.text = selectedOrderNumbers.join(', ');
                                                suggesstiondata.removeWhere((item) => item['orderNo'].toString() == suggestion,

                                                );
                                              });
                                            }
                                            print('Selected Order Numbers: $selectedOrderNumbers');
                                          },
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: selectedCheckbox==1,
                                      child: Container(height:38,decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(5),),
                                        child: IconButton(onPressed: (){
                                          handleButtonPress();
                                        }, icon:Icon(Icons.check,color: Colors.green,size: 25,)),
                                      ),
                                    ),
                                    Visibility(
                                      visible: selectedCheckbox ==2,
                                      child: SizedBox(width: 300,
                                        child: TypeAheadFormField<String>(
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: pendingorderNo,
                                            style: const TextStyle(fontSize: 13),
                                            inputFormatters:
                                            [UpperCaseTextFormatter()],
                                            decoration: InputDecoration(
                                              fillColor: Colors.white, filled: true,
                                              labelText: "Pending Order Number",
                                              labelStyle: TextStyle(fontSize: 13),
                                              suffixIcon: pendingorderNo.text.isNotEmpty
                                                  ? Visibility(
                                                visible: removeVisible,
                                                child: IconButton(
                                                  icon: Icon(Icons.clear),
                                                  onPressed: () {
                                                    setState(() {
                                                      pendingorderNo.clear();
                                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>EntrySales()));// Clear the text in the controller
                                                    });
                                                  },
                                                ),
                                              )
                                                  : null, // Don't show the icon if there is no text


                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),),
                                            ),),
                                          suggestionsCallback: (pattern) async {
                                            List<String> inputParts = pattern.split(',').map((part) => part.trim()).toList();
                                            String currentInput = inputParts.isNotEmpty ? inputParts.last : '';
                                            List<String> suggestions;
                                            if (currentInput.isNotEmpty) {
                                              suggestions = pendingsuggesstiondata
                                                  .where((item) =>
                                              (item['pendingOrderNo']?.toString().toLowerCase() ?? '')
                                                  .startsWith(currentInput.toLowerCase()) &&
                                                  !selectedPendingOrderNumbers.contains(item['pendingOrderNo'].toString()))
                                                  .map((item) => item['pendingOrderNo'].toString())
                                                  .toSet()
                                                  .toList();
                                            } else {
                                              suggestions = pendingsuggesstiondata
                                                  .where((item) => !selectedPendingOrderNumbers.contains(item['orderNo'].toString()))
                                                  .map((item) => item['pendingOrderNo'].toString())
                                                  .toSet()
                                                  .toList();}
                                            suggestions.sort((a, b) => b.compareTo(a));
                                            return suggestions;
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) async {
                                            if (!selectedPendingOrderNumbers.contains(suggestion)) {
                                              setState(() {
                                                selectedPendingOrderNumbers.add(suggestion);
                                                pendingorderNo.text = selectedPendingOrderNumbers.join(', ');
                                                pendingsuggesstiondata.removeWhere((item) => item['pendingOrderNo'].toString() == suggestion,
                                                );
                                              });
                                            }
                                            print('Selected Order Numbers: $selectedPendingOrderNumbers');
                                          },
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: selectedCheckbox==2,
                                      child:Container(height:38,decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(5),),
                                        child: IconButton(onPressed: (){
                                          pendinghandleButtonPress();
                                        }, icon:Icon(Icons.check)),
                                      ),),

                                    SizedBox(width: 20,),
                                  ],
                                )
*/
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Visibility(
                                      visible: selectedCheckbox == 1,
                                      child:  SizedBox(

                                        width: 300,
                                        child: TypeAheadFormField<String>(
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: orderNo,
                                            style: const TextStyle(fontSize: 13),
                                            inputFormatters: [UpperCaseTextFormatter()],
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              labelText: "Order Number",
                                              labelStyle: const TextStyle(fontSize: 13),
                                              suffixIcon: orderNo.text.isNotEmpty
                                                  ? IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  setState(() {
                                                    removeVisible = false;
                                                    selectedOrderNumbers.clear();
                                                    orderNo.text = '';
                                                    rowData.clear();
                                                    focusNodes.clear();
                                                    controllers.clear();
                                                    dcontrollers.clear();
                                                    checkOrderNo="";
                                                    custAddress.clear();
                                                    custMobile.clear();
                                                    cpincode.clear();
                                                    custName.clear();
                                                    transNo.clear();
                                                    custCode.clear();
                                                    errorMessage ="";
                                                    deliveryType=null;
                                                    payType=null;
                                                  });
                                                },
                                              )
                                                  : null,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          suggestionsCallback: (pattern) async {

                                            List<String> inputParts = pattern.split(',').map((part) => part.trim()).toList();
                                            String currentInput = inputParts.isNotEmpty ? inputParts.last : '';
                                            List<String> suggestions = suggesstiondataForduplicate
                                                .where((item) =>
                                            (item['orderNo']?.toString().toLowerCase() ?? '')
                                                .startsWith(currentInput.toLowerCase()) &&
                                                !selectedOrderNumbers.contains(item['orderNo'].toString()))
                                                .map((item) => item['orderNo'].toString())
                                                .toSet()
                                                .toList();
                                            suggestions.sort((a, b) => b.compareTo(a));
                                            return suggestions;
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) async {

                                            if (!selectedOrderNumbers.contains(suggestion)) {
                                              setState(() {
                                                removeVisible=true;
                                                selectedOrderNumbers.add(suggestion);
                                                orderNo.text = selectedOrderNumbers.join(', ');
                                                suggesstiondata.removeWhere((item) => item['orderNo'].toString() == suggestion,
                                                );
                                              });
                                            }
                                            print('Selected Order Numbers: $selectedOrderNumbers');
                                          },
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: selectedCheckbox==1,
                                      child: Container(height:38,decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(5),),
                                        child: IconButton(onPressed: (){
                                          handleButtonPress();
                                        }, icon:const Icon(Icons.check,color: Colors.green,size: 25,)),
                                      ),
                                    ),
                                    Visibility(
                                      visible: selectedCheckbox ==2,
                                      child: SizedBox(width: 300,
                                        child: TypeAheadFormField<String>(
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: pendingorderNo,
                                            style: const TextStyle(fontSize: 13),
                                            inputFormatters:
                                            [UpperCaseTextFormatter()],
                                            decoration: InputDecoration(
                                              fillColor: Colors.white, filled: true,
                                              labelText: "Pending Order Number",
                                              labelStyle: const TextStyle(fontSize: 13),
                                              suffixIcon: pendingorderNo.text.isNotEmpty
                                                  ? IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  setState(() {
                                                    removeVisible = false;
                                                    selectedPendingOrderNumbers.clear();
                                                    pendingorderNo.text = '';
                                                    orderNo.text = '';
                                                    rowData.clear();
                                                    focusNodes.clear();
                                                    controllers.clear();
                                                    dcontrollers.clear();
                                                    checkOrderNo="";
                                                    custAddress.clear();
                                                    custMobile.clear();
                                                    cpincode.clear();
                                                    custName.clear();
                                                    transNo.clear();
                                                    custCode.clear();
                                                    deliveryType=null;
                                                    errorMessage ="";
                                                    payType=null;
                                                    // Clear the text in the controller
                                                  });
                                                },
                                              )
                                                  : null, // Don't show the icon if there is no text


                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),),
                                            ),),
                                          suggestionsCallback: (pattern) async {

                                            List<String> inputParts = pattern.split(',').map((part) => part.trim()).toList();
                                            String currentInput = inputParts.isNotEmpty ? inputParts.last : '';
                                            List<String> suggestions =pendingdataDuplicate
                                                .where((item) =>
                                            (item['pendingOrderNo']?.toString().toLowerCase() ?? '')
                                                .startsWith(currentInput.toLowerCase()) &&
                                                !selectedPendingOrderNumbers.contains(item['pendingOrderNo'].toString()))
                                                .map((item) => item['pendingOrderNo'].toString())
                                                .toSet()
                                                .toList();
                                            suggestions.sort((a, b) => b.compareTo(a));

                                            return suggestions;
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) async {
                                            if (!selectedPendingOrderNumbers.contains(suggestion)) {
                                              setState(() {
                                                removeVisible=true;
                                                selectedPendingOrderNumbers.add(suggestion);
                                                pendingorderNo.text = selectedPendingOrderNumbers.join(', ');
                                                pendingsuggesstiondata.removeWhere((item) => item['pendingOrderNo'].toString() == suggestion,

                                                );
                                              });
                                            }
                                            print('Selected  Pending Order Numbers: $selectedPendingOrderNumbers');
                                          },
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: selectedCheckbox==2,
                                      child:Container(height:38,decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(5),),
                                        child: IconButton(onPressed: (){
                                          pendinghandleButtonPress();
                                        }, icon:const Icon(Icons.check)),
                                      ),),

                                    const SizedBox(width: 20,),
                                  ],
                                )

                              ]
                          ),
                        ),

                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        child: Container(
                          width: double.infinity, // Set the width to full page width
                          padding: const EdgeInsets.all(16.0), // Add padding for spacing
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            border: Border.all(color: Colors.grey), // Add a border for the box
                            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                          ),
                          child: Wrap(
                            children: [
                              Padding(
                                padding:  const EdgeInsets.only(left:0),
                                child: Column(
                                  children: [
                                    if(checkOrderNo !="")
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Text("OrderNumber   "),
                                          Text(checkOrderNo),
                                        ],
                                      ),
                                    const SizedBox(height: 3,),

                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("Customer Details",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:16,
                                    ),),

                                  ],
                                ),
                              ),
                              Wrap(
                                children: [
                                  const SizedBox(width: 20,),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Wrap(
                                      children: [
                                        SizedBox(
                                          width: 220, height: 70,
                                          child: TextFormField(
                                            readOnly: true, controller: custCode,
                                            style: const TextStyle(fontSize: 13),
                                            decoration: InputDecoration(
                                              filled: true, fillColor: Colors.white, labelText: "Customer Code",
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                                            onChanged: (value){
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              custCode.value = custCode.value.copyWith(
                                                text: capitalizedValue, selection: TextSelection.collapsed(
                                                  offset: capitalizedValue.length),);
                                            },),
                                        ),const SizedBox(width: 55,),

                                        SizedBox(
                                          width: 220,height: 70,
                                          child: TextFormField(
                                            readOnly: true, controller: custName, style: const TextStyle(fontSize: 13),
                                            decoration: InputDecoration(
                                              filled: true, fillColor: Colors.white, labelText: "Customer Name",
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),),
                                            onChanged: (value){
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              custName.value = custName.value.copyWith(
                                                text: capitalizedValue, selection: TextSelection.collapsed(
                                                  offset: capitalizedValue.length),);},),),

                                        const SizedBox(width: 55,),

                                        SizedBox(
                                          width: 220,height: 70,
                                          child: TextFormField(readOnly: true,
                                            controller: custMobile, style: const TextStyle(fontSize: 13),
                                            decoration: InputDecoration(filled: true,
                                              fillColor: Colors.white, prefixText: "+91 ",
                                              labelText: "Customer Mobile", border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10,),),),
                                            keyboardType: TextInputType.number, inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],),),
                                        const SizedBox(width: 55,),
                                        SizedBox(
                                          width: 220,height: 70,
                                          child: TextFormField(
                                            readOnly: true, controller: custAddress,
                                            style: const TextStyle(fontSize: 13),
                                            decoration: const InputDecoration(filled: true,
                                              fillColor: Colors.white, labelText: "Customer Address",
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black),),),
                                            onChanged: (value){String capitalizedValue = capitalizeFirstLetter(value);
                                            custAddress.value = custAddress.value.copyWith(
                                              text: capitalizedValue, selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                            );},),),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              Wrap(
                                children: [
                                  const SizedBox(width: 20,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      children: [
                                        SizedBox(
                                          width: 220,height: 70,
                                          child: TextFormField(readOnly: true,
                                            controller: cpincode,
                                            style: const TextStyle(fontSize: 13),
                                            decoration: InputDecoration(filled: true,
                                              fillColor: Colors.white, labelText: "Pincode",
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10,),),),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(6)],),),
                                        const SizedBox(width: 53,),
                                        SizedBox(
                                          width: 221,height: 70,
                                          child: TextFormField(
                                            controller:gstin,
                                            style: const TextStyle(fontSize: 13),
                                            inputFormatters: [
                                              UpperCaseTextFormatter(),
                                              LengthLimitingTextInputFormatter(16)],
                                            decoration: InputDecoration(
                                              labelText:"GSTIN",
                                              filled: true, // Set to true to enable filling
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10,),),),),),
                                        const SizedBox(width: 53,),
                                        SizedBox(
                                          width: 220,
                                          height:38,
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButtonFormField<String>(
                                              decoration: const InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                contentPadding: EdgeInsets.symmetric(
                                                  vertical: 12.0,
                                                  horizontal: 16.0,
                                                ),
                                                disabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 1, color: Colors.white)),
                                              ),
                                              hint: const Text("Delivery Type",style: TextStyle(fontSize:13,color: Colors.black),),
                                              isExpanded: true,
                                              value: deliveryType,
                                              items: <String>['Partial','Complete',]
                                                  .map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: const TextStyle(fontSize: 13,color: Colors.black),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  deliveryType = newValue!;
                                                  errorMessage ="";
                                                });},),),),
                                        const SizedBox(width: 1,),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 36,left: 54),
                                          child: SizedBox(
                                            width: 220,
                                            height:38,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButtonFormField<String>(
                                                decoration: const InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding: EdgeInsets.symmetric(
                                                    vertical: 12.0,
                                                    horizontal: 16.0,
                                                  ),
                                                  disabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 0.5, color: Colors.white)),
                                                ),
                                                hint: const Text("Payment Type",style: TextStyle(fontSize:13,color: Colors.black),),
                                                isExpanded: true,
                                                value: payType,
                                                items: <String>['Cash','Cheque','NEFT','RTGS',]
                                                    .map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: const TextStyle(fontSize: 13),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    payType = newValue!;
                                                    errorMessage ="";
                                                  });},),),),),
                                        //SizedBox(width: 55,height: 50,),
                                        //     SizedBox(width: 221,height: 70,),
                                      ],
                                    ),
                                  ),

                                ],
                              ),

                              Wrap(
                                children: [
                                  const SizedBox(width: 20,),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SizedBox(
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
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: FocusTraversalGroup(
                                        policy: OrderedTraversalPolicy(),
                                        child: Table(border: TableBorder.all(color: Colors.black),
                                            defaultColumnWidth: const FixedColumnWidth(140.0),
                                            columnWidths: const <int, TableColumnWidth>{2: FixedColumnWidth(80), 3: FixedColumnWidth(0),
                                              4: FixedColumnWidth(80), 5: FixedColumnWidth(80),
                                              7: FixedColumnWidth(140), 8: FixedColumnWidth(140),
                                              9: FixedColumnWidth(120), 10: FixedColumnWidth(0),
                                              11: FixedColumnWidth(0), 12: FixedColumnWidth(0), 13: FixedColumnWidth(0),/*12: FixedColumnWidth(0),*/},
                                            children: [
                                              TableRow(
                                                decoration: BoxDecoration(color: Colors.blue.shade200),
                                                children:  const [
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Item Group', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),
                                                    ],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 3),
                                                      Text('No.of\npack', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 3),],))),
                                                  TableCell(child: Center(child: Column(children: [Text(''),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Total Cone', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Rate/cone', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('GST(%)', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('GST Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [Text('',),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [Text('',),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [Text('',),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [Text('',),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),],),
                                              for (int i = 0; i < controllers.length; i++)
                                                TableRow(children: [
                                                  for (int j = 0; j < 14; j++)
                                                    j==2?
                                                    TableCell(verticalAlignment: TableCellVerticalAlignment.middle,
                                                      child: Padding(padding: const EdgeInsets.all(8.0),
                                                        child: TextFormField(
                                                          style: const TextStyle(fontSize: 13,color: Colors.black),
                                                          textAlign: TextAlign.center, keyboardType: TextInputType.number,
                                                          onChanged: (value) {


                                                            setState(() {


                                                              double quantity =double.tryParse(controllers[i][2].text)??0.0;
                                                              editPendingQty =quantity;
                                                              double getqty = quantity;
                                                              double valuereceived = double.tryParse(controllers[i][10].text)??0.0;
                                                              pendingqty = valuereceived ;
                                                              double pendingqtyget = valuereceived-getqty;
                                                              // Update the corresponding qty in the unavailable table
                                                              double unit = double.tryParse(controllers[i][3].text) ?? 0.0;
                                                              double rate = double.tryParse(controllers[i][5].text) ?? 0.0;
                                                              double gst = double.tryParse(controllers[i][6].text)??0.0;
                                                              double? temp = (quantity*unit);
                                                              double amount = (temp * rate);
                                                              double gstvalue = amount * (gst / 100);
                                                              double total = amount + gstvalue;
                                                              controllers[i][4].text = temp.toStringAsFixed(0);
                                                              controllers[i][7].text = amount.toStringAsFixed(2);
                                                              controllers[i][8].text = gstvalue.toStringAsFixed(2);
                                                              controllers[i][9].text = total.toStringAsFixed(2);
                                                              controllers[i][11].text = pendingqtyget.toStringAsFixed(0);
                                                              final int rowIndex = i;final int colIndex = j;
                                                              final String key = _getKeyForColumn(colIndex);
                                                              rowData[rowIndex][key] = value;
                                                              if (beforeEditQty == null) {beforeEditQty = double.tryParse(valuereceived.toString()) ?? 0.0;
                                                              print("$beforeEditQty edities");}
                                                              double quantities = double.tryParse(value) ?? 0.0;
                                                              if (valuereceived < quantities) {
                                                                print("Error: Quantity can only be decreased, not increased");
                                                                showDialog(context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(title: const Text('Alert'),
                                                                      content: const Text('Quantity can only be decreased, not increased.'),
                                                                      actions: <Widget>[TextButton(
                                                                        child: const Text('OK'), onPressed: () {
                                                                        controllers[i][2].text = valuereceived.toStringAsFixed(0);
                                                                        double? temp =valuereceived*unit;double amount = (temp * rate);
                                                                        double gstvalue = amount * (gst / 100);double total = amount + gstvalue;
                                                                        controllers[i][4].text = temp.toStringAsFixed(0);controllers[i][7].text = amount.toStringAsFixed(2);
                                                                        controllers[i][8].text = gstvalue.toStringAsFixed(2);controllers[i][9].text = total.toStringAsFixed(2);
                                                                        double receivedValue = double.tryParse(controllers[i][10].text)??0.0;
                                                                        double editedValue = double.tryParse(controllers[i][2].text)??0.0;
                                                                        double pendingqtygets = receivedValue-editedValue;
                                                                        controllers[i][11].text = pendingqtygets.toStringAsFixed(0);
                                                                        Navigator.of(context).pop();
                                                                      },),],);},);
                                                                controllers[i][2].text = valuereceived.toStringAsFixed(0);
                                                                //    handleAvailableQtyChange(i, quantity);
                                                                //     updateUnavailableQuantity(i, getqty);
                                                                return;}
                                                              validQuantity = controllers[i][2].text;
                                                              if(controllers[i][2].text == '0' ) {
                                                                setState(() {errorMessage ="* Enter a valid Quantity";
                                                                });}else if(validQuantity.isEmpty){
                                                                setState(() {errorMessage ="* Enter a Quantity";});
                                                              }else if(validQuantity.isNotEmpty) {
                                                                setState(() {errorMessage = "";});}grandTotal.text = calculateGrandTotal().toStringAsFixed(2);});
                                                            getitemgGroup= controllers[i][0].text;getitemgName=controllers[i][1].text;
                                                            setState(() {
                                                              getQty=double.tryParse(controllers[i][2].text);
                                                              print("$getQty - editqty");
                                                              setState(() {
                                                                //   totalvaluezerocheck.add(double.tryParse(controllers[i][9].text.toString()).toString());
                                                                print("$totalvaluezerocheck -- total value check");
                                                              });});},
                                                          enabled:  (j == 5 || j == 6 || j == 2),
                                                          decoration: const InputDecoration(
                                                            filled:true, fillColor: Colors.white,), controller: controllers[i][2],
                                                          inputFormatters: <TextInputFormatter>[
                                                            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')), LengthLimitingTextInputFormatter(5)
                                                          ],),),)
                                                        : j==10?
                                                    TableCell(verticalAlignment: TableCellVerticalAlignment.middle,
                                                      child: Visibility(visible: false, child: TextFormField(controller: controllers[i][10],),),)
                                                        :j==11?
                                                    Visibility(visible: false, child: TableCell(
                                                      verticalAlignment: TableCellVerticalAlignment.middle, child: Visibility(visible: false,
                                                      child: TextFormField(controller: controllers[i][11],
                                                      ),),),)
                                                        :j==12?
                                                    Visibility(visible: false, child: TableCell(
                                                      verticalAlignment: TableCellVerticalAlignment.middle, child: Visibility(visible: false,
                                                      child: TextFormField(controller: controllers[i][12],),),),)
                                                        :j==13?
                                                    Visibility(visible: false, child: TableCell(
                                                      verticalAlignment: TableCellVerticalAlignment.middle, child: Visibility(visible: false,
                                                      child: TextFormField(controller: controllers[i][13],),),),)
                                                        : TableCell(verticalAlignment: TableCellVerticalAlignment.middle,
                                                      child: Padding(padding: const EdgeInsets.all(8.0),
                                                        child: TextFormField(style: const TextStyle(fontSize: 13,color: Colors.black),
                                                          controller: controllers[i][j],
                                                          decoration: const InputDecoration(filled:true, fillColor: Colors.white,),
                                                          inputFormatters: <TextInputFormatter>[
                                                            FilteringTextInputFormatter.allow(RegExp(r'^[\d.]*')), LengthLimitingTextInputFormatter(5)],
                                                          textAlign: (j >= 0 && j <= 6) ? TextAlign.center : TextAlign.right,
                                                          enabled: (j == 5 || j == 6 || j == 2),
                                                          onChanged: (value) {setState(() {
                                                            double quantity =double.tryParse(controllers[i][2].text)??0.0;
                                                            double unit = double.tryParse(controllers[i][3].text) ?? 0.0;
                                                            double rate = double.tryParse(controllers[i][5].text) ?? 0.0;
                                                            double gst = double.tryParse(controllers[i][6].text)??0.0;
                                                            double temp = quantity*unit;
                                                            double amount = (temp * rate);
                                                            double gstvalue = amount * (gst / 100);
                                                            double total = amount + gstvalue;
                                                            //   double getqty = int.parse(quantity.toString());
                                                            double valuereceived = double.tryParse(controllers[i][10].text)?? 0.0;
                                                            double pendingqtyget = valuereceived-quantity;
                                                            setState(() {
                                                              controllers[i][4].text = temp.toStringAsFixed(0);
                                                              controllers[i][7].text = amount.toStringAsFixed(2);
                                                              controllers[i][8].text = gstvalue.toStringAsFixed(2);controllers[i][9].text = total.toStringAsFixed(2);
                                                            });

                                                            controllers[i][11].text = pendingqtyget.toStringAsFixed(0);
                                                            final int rowIndex = i;final int colIndex = j;
                                                            final String key = _getKeyForColumn(colIndex);
                                                            rowData[rowIndex][key] = value;
                                                            /* if (beforeEditQty == null) {
                                                            beforeEditQty = int.tryParse(value) ?? 0;
                                                          print("$beforeEditQty edities");
                                                          }*/
                                                            grandTotal.text = calculateGrandTotal().toStringAsFixed(2);});
                                                          getitemgGroup= controllers[i][0].text;
                                                          getitemgName=controllers[i][1].text;
                                                          setState(() {
                                                            // getQty=int.parse(controllers[i][2].text);
                                                            print("$getQty - editqty");});
                                                          validRate = controllers[i][5].text;
                                                          validGST = controllers[i][6].text;
                                                          ///rate validation
                                                          if(controllers[i][3].text== '0') {setState(() {
                                                            errorMessage ="* Enter a valid Rate";
                                                          });}
                                                          else if(controllers[i][3].text.isEmpty) {setState(() {errorMessage ="* Enter a Rate";});}
                                                          else if(controllers[i][3].text== '0'){
                                                            setState(() {
                                                              errorMessage ="* Enter a valid Rate";
                                                            });
                                                          }
                                                          else if(controllers[i][3].text.isNotEmpty) {setState(() {errorMessage ="";});}
                                                          ///gst validations
                                                          if(validGST=='0') {setState(() {errorMessage ="* Enter a valid GST";});}
                                                          else if(validGST.isEmpty) {setState(() {errorMessage ="* Enter a GST(%)";});
                                                          }},
                                                        ),
                                                      ),),
                                                  TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: Center(child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [IconButton(
                                                        icon: const Icon(Icons.remove_circle_outline),
                                                        color: Colors.red.shade600,
                                                        onPressed: () {showDialog(context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              title: const Text('Confirmation'),
                                                              content: const Text('Are you sure you want to remove this row?'),
                                                              actions: <Widget>[TextButton(child: const Text('Cancel'),
                                                                onPressed: () {Navigator.of(context).pop();},),
                                                                TextButton(child: const Text('Remove'),
                                                                  onPressed: () {removeRow(i);Navigator.of(context).pop(); },),],);},);},),],),),),],),]),),),


                                    const Padding(
                                      padding: EdgeInsets.only(right:1015,top: 5,bottom: 5),
                                      child: Wrap(
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text("Unavailable Product Details",style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:16,
                                          ),),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: FocusTraversalGroup(
                                        policy: OrderedTraversalPolicy(),
                                        child: Container(
                                          color: Colors.blue.shade100,
                                          child: Table(
                                            border: TableBorder.all(color: Colors.black),
                                            defaultColumnWidth: const FixedColumnWidth(140.0),
                                            columnWidths: const <int, TableColumnWidth>{2: FixedColumnWidth(80),
                                              3: FixedColumnWidth(0), 4: FixedColumnWidth(80),
                                              5: FixedColumnWidth(80), 7: FixedColumnWidth(140),
                                              8: FixedColumnWidth(140), 9: FixedColumnWidth(120),
                                              10: FixedColumnWidth(0), 11: FixedColumnWidth(0),
                                              12: FixedColumnWidth(0), 13: FixedColumnWidth(0),
                                            },
                                            children: [
                                              TableRow(
                                                decoration: BoxDecoration(color: Colors.blue.shade200),
                                                children:  const [
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Item Group', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),
                                                    ],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 3),
                                                      Text('No.of\npack', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 3),],))),
                                                  TableCell(child: Center(child: Column(children: [Text(''),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Total Cone', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Rate/cone', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('GST(%)', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('GST Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [Text('',),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [Text('',),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [Text('',),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [Text('',),],))),
                                                  TableCell(child: Center(child: Column(
                                                    children: [SizedBox(height: 15),
                                                      Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 15),],))),],),
                                              for (int i = 0; i < dcontrollers.length; i++)
                                                TableRow(
                                                  children: [
                                                    for (int j = 0; j < 14; j++)
                                                      j==10?
                                                      TableCell(
                                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                                        child: Visibility(
                                                          visible: false,
                                                          child: TextFormField(
                                                            readOnly: true,
                                                            controller: dcontrollers[i][10],
                                                          ),
                                                        ),
                                                      )
                                                          :j==11?
                                                      Visibility(
                                                        visible: false,
                                                        child: TableCell(
                                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                                          child: Visibility(
                                                            visible: false,
                                                            child: TextFormField(
                                                              readOnly: true,
                                                              controller: dcontrollers[i][11],
                                                            ),
                                                          ),
                                                        ),
                                                      ) :j==12?
                                                      Visibility(
                                                        visible: false,
                                                        child: TableCell(
                                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                                          child: Visibility(
                                                            visible: false,
                                                            child: TextFormField(
                                                              readOnly: true,
                                                              controller: dcontrollers[i][12],
                                                            ),
                                                          ),
                                                        ),
                                                      ) :j==13?
                                                      Visibility(
                                                        visible: false,
                                                        child: TableCell(
                                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                                          child: Visibility(
                                                            visible: false,
                                                            child: TextFormField(
                                                              readOnly: true,
                                                              controller: dcontrollers[i][13],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                          : TableCell(
                                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: TextFormField(
                                                            readOnly: true,
                                                            textAlign: (j >= 0 && j <= 6) ? TextAlign.center : TextAlign.right,
                                                            style: const TextStyle(fontSize: 13,color: Colors.grey),
                                                            controller: dcontrollers[i][j],
                                                            decoration: const InputDecoration(
                                                              filled:true,
                                                              fillColor: Colors.white,
                                                            ),
                                                            // keyboardType: TextInputType.number,
                                                            inputFormatters: <TextInputFormatter>[

                                                              // FilteringTextInputFormatter.digitsOnly,
                                                              LengthLimitingTextInputFormatter(5)
                                                            ],
                                                            onChanged: (value){
                                                              setState(() {
                                                                double quantity =double.tryParse(dcontrollers[i][2].text)??0.0;
                                                                //    dpendingQty =int.parse(quantity.toString());
                                                                pendingrowslenth =dcontrollers.length;
                                                                // Calculate the changed quantity

                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),

                                                    TableCell(
                                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                                      child:Text(""),
                                                      /*  child: Center(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [

                                                           IconButton(
                                                          icon: Icon(Icons.edit),
                                                       //   color: Colors.blue.shade600,
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  title: Text('Confirmation'),
                                                                  content: Text('Are you sure you want to Edit this?'),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      child: Text('Cancel'),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop(); // Close the alert box
                                                                      },
                                                                    ),
                                                                    TextButton(
                                                                      child: Text('Edit'),
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          editingRowIndex = i; // Set the editing row index
                                                                          checkEnable = true;
                                                                        });
                                                                        Navigator.pop(context);
                                                                      },
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),

                                                         *//*   IconButton(
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
                                                            ),*//*

                                                         *//*  Visibility(
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
                                                        ),*//*

                                                          ],
                                                        ),
                                                      ),*/
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )

                                  ],
                                ),
                              ),


                              const SizedBox(height: 10,),
                              const SizedBox(height: 10,),
                              /* if(orderNo.text.isNotEmpty&&fetchgetitemgGroup! =="")
                                Center(child: const Text("There is no stock for this order",style: TextStyle(color: Colors.black
                                ),)),
*/
                              // ScaffoldMessenger(child:Text("This Order No Data is not available in Stock")),

                              const SizedBox(height: 20,),

                              Padding(
                                padding: const EdgeInsets.only(left: 30.0,top: 20),
                                child: Column(
                                  children: [
                                    Wrap(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          children: [
                                            const Text("Total Item : ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                                            selectedCheckbox==1? Text(rowslenth.toString())
                                                : Text(pendingrowslenth.toString()),
                                            const Text(""),
                                          ],
                                        ),
                                        const SizedBox(width: 35,),
                                        Wrap(
                                          //  mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            const Text("Total Qty : ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                                            Text(calculateTotalItem().toStringAsFixed(0)),
                                          ],
                                        ),
                                        const SizedBox(width: 35,),
                                        Wrap(
                                          // / mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            const Text("Values Of Goods: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                                            Text(calculateValueGoods().toStringAsFixed(2)),
                                          ],
                                        ),
                                        const SizedBox(width: 35,),
                                        Wrap(
                                          //mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            const Text("Tax Value: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                                            Text(calculateTaxAmount().toStringAsFixed(2)),
                                          ],
                                        ),
                                        const SizedBox(width: 35,),
                                        Wrap(
                                          // mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            const Text("Total: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                                            Text(grandTotal.text),
                                          ],
                                        ),
                                      ],
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,

                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top:20),
                                          child: Text(
                                            errorMessage ?? '',
                                            style: const TextStyle(color: Colors.red,fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),


/*
                              Padding(
                                padding: const EdgeInsets.only(right: 88,top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [


                                    Text("Grand Total  ₹ ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                                    SizedBox(
                                      width: 124,
                                      //  height: 70,
                                      child: TextFormField(
                                        controller: grandTotal,
                                        style: const TextStyle(fontSize: 13),
                                        textAlign: TextAlign.right,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          LengthLimitingTextInputFormatter(10),
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            //prefixIcon: const Icon(Icons.currency_rupee),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey)
                                            )
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width: 16,
                                        child: Text(" ")),
                                  ],
                                ),
                              ),
*/

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
/*
                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Success"),
                                      content: Text("Data saved successfully."),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close the alert box
                                          },
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                          ),
*/

                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () async {
                              if(_formKey.currentState!.validate()){
                                if (isMachineNameExists(orderNo.text)) {
                                  setState(() {
                                    errorMessage = '* This Order Number is Already invoiced';
                                  });
                                }
                                else if (isMachineNameExists(pendingorderNo.text)) {
                                  setState(() {
                                    errorMessage = '* This Pending Order Number is Already invoiced';
                                  });
                                }
                                else if(custName.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* All fields are mandatory';
                                  });
                                } else if(custMobile.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* All fields are mandatory';
                                  });

                                }else if(custAddress.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* All fields are mandatory';
                                  });

                                }else if(cpincode.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* All fields are mandatory';
                                  });
                                }
                                else if(payType ==null){
                                  setState(() {
                                    errorMessage = '* Select a Payment Type';
                                  });
                                }
                                else if (gstin.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* GSTIN is mandatory';
                                  });
                                } else if (!gstregex2.hasMatch(gstin.text)) {
                                  setState(() {
                                    errorMessage = '* Invalid GSTIN';
                                  });
                                }
                                else if (deliveryType==null) {
                                  setState(() {
                                    errorMessage = '* Select the deliveryType';
                                  });}
                                /* else if (totalvaluezerocheck == "0.0"||totalvaluezerocheck =="0") {
                                  setState(() {
                                    errorMessage = '* Enter a Sales items ';
                                  });
                                }*/
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

                                else if (validQuantity=='0'){
                                  setState(() {
                                    errorMessage="* Enter a Valid Qty";
                                  });
                                }
                                else if(validQuantity.isEmpty){
                                  setState(() {
                                    errorMessage="* Enter a Qty";
                                  });
                                }
                                ///rate validation
                                else if(validRate== '0') {
                                  setState(() {
                                    errorMessage ="* Enter a valid Rate";
                                  });}
                                else if(validRate.isEmpty) {
                                  setState(() {
                                    errorMessage ="* Enter a Rate";
                                  });
                                }

                                ///gst validations
                                else if(validGST=='0') {
                                  setState(() {
                                    errorMessage ="* Enter a valid GST";
                                  });}
                                else if(validGST.isEmpty) {
                                  setState(() {
                                    errorMessage ="* Enter a GST(%)";
                                  });
                                }
                                else {
                                  /// insert to sales
                                  List<Map<String, dynamic>> rowsDataToInsert = [];
                                  rowsDataToInsert.add(dataToInsert);
                                  await insertdataTosales();

                                  /// edit qty store to pending database
                                  if(pendingqty != editPendingQty) {
                                    rowsDataToInsert.add(datapendingInsert);
                                    await pendingToDatabase();
                                  }
                                  /// unavailable in stock products store to pending database
                                  rowsDataToInsert.add(datapendingInsertunavailablestock);
                                  await pendingUnavailabeToDatabase();
                                  // ///delete row pending store to pending database
                                  List<Future<void>> insertFutures = [];
                                  for (var i = 0; i < datapendingInsertList.length; i++) {
                                    insertFutures.add(insertDataPendingReport(datapendingInsertList[i]));
                                  }
                                  await Future.wait(insertFutures);
                                  datapendingInsertList.clear();
                                  try {
                                    setState(() {
                                      isDataSaved = true;
                                    });
                                  } catch (e) {
                                    print('Error inserting data: $e');
                                  }
                                }}
                            },
                            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 20,),
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
                                              MaterialPageRoute(builder: (context) =>const EntrySales()));// Close the alert box
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
                          const SizedBox(width: 20,),
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
                            child:const Text("CANCEL",style: TextStyle(color: Colors.white),),)
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
        ) );
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
      return 'unit';
    case 4:
      return 'totalCone';
    case 5:
      return 'rate';
    case 6:
      return 'gst';
    case 7:
      return 'amt';
    case 8:
      return 'amtGST';
    case 9:
      return 'total';
    case 10:
      return 'qty';
    case 11:
      return 'pending_qty';
    case 12:
      return 'orderNo';
    case 13:
      return 'date';
    default:
      return '';
  }
}
String _getKeyForColumnDisable(int columnIndex) {
  switch (columnIndex) {
    case 0:
      return 'itemGroup';
    case 1:
      return 'itemName';
    case 2:
      return 'qty';
    case 3:
      return 'unit';
    case 4:
      return 'totalCone';
    case 5:
      return 'rate';
    case 6:
      return 'gst';
    case 7:
      return 'amt';
    case 8:
      return 'amtGST';
    case 9:
      return 'total';
    case 10:
      return 'qty';
    case 11:
      return 'pending_qty';
    case 12:
      return 'orderNo';
    case 13:
      return 'date';
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



