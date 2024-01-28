import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import '../../home.dart';



class SalesReturn extends StatefulWidget {
  const SalesReturn({Key? key}) : super(key: key);
  @override
  State<SalesReturn> createState() => _SalesReturnState();
}
class _SalesReturnState extends State<SalesReturn> {
  final _formKey = GlobalKey<FormState>();
  final  date = DateTime.now();
  List<List<TextEditingController>> controllers = [];
  List<List<FocusNode>> focusNodes = [];
  List<Map<String, dynamic>> rowData = [];
  List<bool> isRowFilled = [false];
  bool allFieldsFilled = false;
  bool dropdownValid = true;
  bool itemGroupExists = false;
  Map<String, dynamic> dataToInsert = {};
  String? errorMessage="";

  TextEditingController invoiceNo=TextEditingController();
  TextEditingController returnNo=TextEditingController();
  TextEditingController purchaseRetNo=TextEditingController();
  TextEditingController purchseDate=TextEditingController();
  TextEditingController custCode=TextEditingController();
  TextEditingController custName=TextEditingController();
  TextEditingController custMobile=TextEditingController();
  TextEditingController custAddress=TextEditingController();
  TextEditingController cpincode=TextEditingController();
  TextEditingController grandTotal=TextEditingController();
  TextEditingController payType=TextEditingController();
  ///first letter captital
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  ///already exist invoice No check and throw error
  List<Map<String, dynamic>> data3 = [];
  List<Map<String, dynamic>> filteredData3 = [];
  Future<void> fetchPono() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_sales_return_invoice'));
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
  bool isMachineNameExists(String name) {
    return data3.any((item) => item['invoiceNo'].toString().toLowerCase() == name.toLowerCase());
  }



  ///sales return_data store starts
  Map<String, dynamic> dataToInsertSalesReturn = {};
  Future<void> insertDataSalesReturn(Map<String, dynamic> dataToInsertSalesReturn) async {
    const String apiUrl = 'http://localhost:3309/sales_returns'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertSalesReturn': dataToInsertSalesReturn}),
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
  Future<void> salesReturnsToDatabase() async {

    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');
    if (salRetNum.isEmpty) {
      salRetNum = 'SR$year$month/001';
    }
    if (poNumber.isEmpty) {
      poNumber = 'SR001';
    }
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers.length; i++) {
      Map<String, dynamic> dataToInsertSalesReturn = {
        "date":date.toString(),
        "invoiceNo":invoiceNo.text,
        "salRetNo":salRetNum,
        "custCode":custCode.text,
        'itemGroup':controllers[i][0].text,
        'itemName': controllers[i][1].text,
        'gst': controllers[i][5].text,
        'qty': controllers[i][4].text,
        'rate':controllers[i][2].text,
        'amt':controllers[i][6].text,
        'amtGST': controllers[i][7].text,
        'total': controllers[i][8].text,
        "saleInvNo":poNumber,
        "salesQty":"",
        "totQty":"",
        "grandtotal":grandTotal.text,
        "pincode":cpincode.text,
      };
      insertFutures.add(insertDataSalesReturn(dataToInsertSalesReturn));
    }

    try {
      await Future.wait(insertFutures); // Await for all insertions to complete
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }
  ///sales return_data store ends

  String fetchItemGroup ="";
  String fetchItemNames ="";
  int fetchQty =0;

  ///invoice number base fetching data starts
  Future<void> fetchDataByOrderNumber(String invoiceNumber) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_sales_item?invoiceNo=$invoiceNumber');
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
              'rate': rows[i]['rate'].toString(),
              'unit': rows[i]['unit'].toString(),
              'qty': rows[i]['qty'].toString(),
              'gst': rows[i]['gst'].toString(),

            };
            print(" check ItemGroup--------${rows[i]["itemGroup"]}");
            print(" check itemName--------${rows[i]["itemName"]}");
            print(" check qty--------${rows[i]["qty"]}");

            for (int j = 0; j < 10; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }
            double quantity = double.tryParse(rowControllers[4].text) ?? 0.0;//qty-4
            double unit = double.tryParse(rowControllers[3].text) ?? 0.0;//unit-3
            double rate = double.tryParse(rowControllers[2].text) ?? 0.0;//rate-2
            double gst = double.tryParse( rowControllers[5].text) ?? 0.0;
            double temp = quantity * unit;
            double amt = temp * rate;
            double gstpersentage = amt * gst/100;
            double totals = amt+gstpersentage;
            rowControllers[6].text = amt.toStringAsFixed(2);//amt-5
            rowControllers[7].text = gstpersentage.toStringAsFixed(2);//gstamot-6
            rowControllers[8].text = totals.toStringAsFixed(2);//total-7
            //rowControllers[9].text = int.parse(quantity.toString()).toString();//total-7
            controllers.add(rowControllers);
            focusNodes.add(List.generate(10, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);
            setState(() {
              getitemgGroup = rowControllers[0].text;
              getitemgName = rowControllers[1].text;
              getQty = int.parse(rowControllers[4].text);
              fetchItemGroup = getitemgGroup.toString();
              fetchItemNames = getitemgName.toString();
              fetchQty = int.parse(getQty.toString());
              print(" check ItemGroup--------${rows[i]["itemGroup"]} $fetchItemGroup");
              print(" check itemName--------${rows[i]["itemName"]} $fetchItemNames");
              print(" check qty--------${rows[i]["qty"]}");
            });
          }
          grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
          setState(() {});
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  ///invoice number base fetching data ends

/*
  Future<void> fetchDataByInvoiceNumber(String invoiceNumber) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_sales_item?invoiceNo=$invoiceNumber');
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
              "unit":rows[i]['unit'].toString(),
              'rate': rows[i]['rate'].toString(),
              'amt': rows[i]['amt'].toString(),
              'gst': rows[i]['gst'].toString(),
              'amtGST': rows[i]['amtGST'].toString(),
              'total': rows[i]['total'].toString(),

            };

            for (int j = 0; j < 10; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }
            controllers.add(rowControllers);
            focusNodes.add(List.generate(9, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);
            */
/*  if (i >= 2) {
            break;
          }*/
  /*

          }
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
*/

  ///damage insert starts
  Map<String, dynamic> dataToInsertdamage = {};
  Future<void> insertData(Map<String, dynamic> dataToInsertdamage) async {
    const String apiUrl = 'http://localhost:3309/damage_entry';
    String itemGroup =  dataToInsertdamage['itemGroup'];
    String itemName =  dataToInsertdamage['itemName'];
    print('Checking for duplicates: itemGroup: $itemGroup, itemName: $itemName');
    List<Map<String, dynamic>> unitEntries = await fetchDamage();
    bool isDuplicate = unitEntries.any((entry) =>
    entry['itemGroup'] == itemGroup &&
        entry['itemName'] == itemName
    );

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
        body: jsonEncode({'dataToInsertdamage': dataToInsertdamage}),
      );

      if (response.statusCode == 200) {
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Its Saved")));

        print('Damage table data inserted successfully');
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Its Not Saved")));

        print('Failed to dd insert data');
        throw Exception('Failed to  dd insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  ///damage insert ends

  ///damage update starts
  Future<void> updateDamage(String itemGroup, String itemName,int qtyIncrement) async {
    final String url = 'http://localhost:3309/damage/update/$itemGroup/$itemName';
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, dynamic> body = {
      'qtyIncrement': qtyIncrement.toString(), // Convert qtyIncrement to String
    };
    try {
      final http.Response response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        print('Production updated successfully');
      } else {
        print('Failed to update production. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating production: $e');
    }
  }
  ///damage update ends

  ///damage fetch starts
  Future<List<Map<String, dynamic>>> fetchDamage() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/damage_get_report'));
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
  ///check duplicate in damage
  Future<bool> checkForDuplicate(String itemGroup, String itemName) async {
    List<dynamic> Damagedata = await fetchDamage();
    for (var item in Damagedata) {
      if (item['itemGroup'] == itemGroup &&
          item['itemName'] == itemName){
        return true;
      }
    }
    return false;
  }

  double calculateTotal(int rowIndex) {
    double quantity = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;//qty-4
    double unit = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;//unit-3
    double rate = double.tryParse(controllers[rowIndex][2].text) ?? 0.0;//rate -2
    double amount = (quantity * unit) * rate;
    double gst = double.tryParse(controllers[rowIndex][5].text) ?? 0.0;//amtGst-6
    double total = (amount * gst)/100;
    controllers[rowIndex][8].text = total.toStringAsFixed(2);//total-7
    print('Calculated Total: $total');

    return total;
  }
  double calculateGrandTotal() {
    double grandTotalValue = 0.0;
    for (var i = 0; i < controllers.length; i++) {
      double total = double.tryParse(controllers[i][8].text) ?? 0.0;
      grandTotalValue += total;
    }
    return grandTotalValue;
  }
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
  @override
  void dispose() {
    for (var rowControllers in controllers) {
      for (var controller in rowControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  String reason= "Damage";

  @override
  void initState() {
    super.initState();
    //addRow();
    ponumfetch();
    fetchData();
    fetchItemGroups();
    fetchItemName();
    fetchDataByOrderNumber(invoiceNo.text);
    setState(() {
      fetchPono();
      filterPoNo(invoiceNo.text);
    });

  }


  int currentSRNumber = 1;
  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['salRetNo'];
  }
  String salRetNum = "";
  String? SRNo;
  List<Map<String, dynamic>> srnumdata = [];
  String? salRetNo;
  List<Map<String, dynamic>> srcodedata = [];
  String generateId() {
    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');

    if (salRetNo != null) {
      String ID = salRetNo!.substring(7);
      int idInt = int.parse(ID) + 1;
      String id = 'SR$year$month/${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ponumfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/salRetNo_fetch'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          salRetNo = getNameFromJsonData(item);
          print('salRetNo: $salRetNo');
        }
        setState(() {
          srnumdata = jsonData.cast<Map<String, dynamic>>();
          salRetNum = generateId(); // Call generateId here
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
  int? beforeEditQty;

//salinvFetch starts
  int currentPoNumber = 1;
  String? getNameFromJsonDatasalINv(Map<String, dynamic> jsonItem) {
    return jsonItem['saleInvNo'];
  }
  String poNumber = "";
  String? poNo;
  List<Map<String, dynamic>> ponumdata = [];
  String? PONO;
  List<Map<String, dynamic>> codedata = [];
  String generateIdinvNo() {
    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');

    if (PONO != null) {
      String ID = PONO!.substring(7);
      int idInt = int.parse(ID) + 1;
      String id = 'SR${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ponumfetchsalINv() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/saleInvNo_fetch'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          PONO = getNameFromJsonData(item);
          print('saleInvNo: $PONO');
        }
        setState(() {
          ponumdata = jsonData.cast<Map<String, dynamic>>();
          poNumber = generateId(); // Call generateId here
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


  List<String> itemGroups = [];
  List<String> itemNames = [];
  Future<void> fetchItemGroups() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_item_Group_in_sales_page'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          itemGroups = List<String>.from(data);
        });
      } else {
        throw Exception('Error loading item groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load item groups: $e');
    }
  }
  Future<void> fetchItemName() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_item_Name_in_sales_page'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          itemNames = List<String>.from(data);
        });
      } else {
        throw Exception('Error loading item groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load item groups: $e');
    }
  }


  ///sales table field update
  Future<void> updateFieldSales(String invoiceNo, String saleInvNo) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/update_sales_salInvNo_Field'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'invoiceNo': invoiceNo,
        'saleInvNo': saleInvNo,
      }),
    );

    if (response.statusCode == 200) {
      print('Field updated successfully');
      print('Response: ${response.body}');

    } else {
      print('Failed to update field');
    }
  }
  String? getitemgGroup;
  String? getitemgName;
  int? getQty = 0;
  String selectedInvoiceNo='';
  List<Map<String, dynamic>> data = [];
  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_sales/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          data = itemGroups.cast<Map<String, dynamic>>();
        });

        print('Data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }

  bool isItemAvailableInStock(String itemGroup, String itemName, int requiredQty) {
    // Find the stock data for the specified itemGroup and itemName
    var stockItem = data?.firstWhere(
          (item) => item['itemGroup'] == itemGroup && item['itemName'] == itemName,
      orElse: () => <String, dynamic>{},
    );
    if (stockItem != null) {
      int salesQTY = int.parse(stockItem['qty']);
      return requiredQty <= salesQTY;
    }

    // Item not found in stock
    return false;
  }


  List<Map<String, dynamic>> filteredData = [];
  void filterData(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = data;
        setState(() {
          purchseDate.clear();
          payType.clear();
        });
        grandTotal.clear();
        custName.clear();
        custCode.clear();
        custAddress.clear();
        cpincode.clear();
        custMobile.clear();
        payType.clear();
      } else {

        List<Map<String, dynamic>> filteredRows = data.where((item) {
          String id = item['invoiceNo']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        // controllers.clear();
        // focusNodes.clear();
        // isRowFilled.clear();
        // rowData.clear();




        filteredData = data.where((item) {
          String id = item['invoiceNo']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (filteredData.isNotEmpty) {
          Map<String, dynamic> order = filteredData.first;
          purchseDate.text = order['date']?.toString() ?? '';
          custName.text = order['custName']?.toString() ?? '';
          custCode.text = order['custCode']?.toString() ?? '';
          custAddress.text = order['custAddress']?.toString() ?? '';
          cpincode.text = order['pincode']?.toString() ?? '';
          custMobile.text = order['custMobile']?.toString() ?? '';
          grandTotal.text = order['grandTotal']?.toString() ?? '';
        } else {
          // Clear other fields if no matching order is found
          setState(() {
            custName.clear();
            custCode.clear();
            custAddress.clear();
            cpincode.clear();
            custMobile.clear();
            payType.clear();
            purchseDate.clear();
            payType.clear();
            grandTotal.clear();
          });
        }
      }
    });
  }


  Future<List<String>> getSuggestionsForReason(String query) async {
    final List<String> reasonSuggestions = ['Damage'];
    final filteredSuggestions = reasonSuggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return filteredSuggestions;
  }


  bool isDataSaved = false;
  int currentReturnNumber = 1;
  void loadReturnNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedReturnNumber = prefs.getInt('currentReturnNumber');
    if (storedReturnNumber != null && storedReturnNumber > 0) {
      setState(() {
        currentReturnNumber = storedReturnNumber;
      });
    }
  }
  String returnNumber = "";
  String? preturnNo;
  List<Map<String, dynamic>> returnNoData = [];
  String? RNO;


  ///damage table insert starts



  @override
  Widget build(BuildContext context) {
    DateTime Date = DateTime.now();
    final formattedDate = DateFormat("dd-MM-yyyy").format(Date);
    invoiceNo.addListener(() {
      filterData(invoiceNo.text);
      fetchDataByOrderNumber(invoiceNo.text);
    });
    return MyScaffold(
        route: "sales_return",backgroundColor: Colors.white,
        body:  Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 160,
                        child: Container(
                          width: double.infinity, // Set the width to full page width
                          padding: EdgeInsets.all(16.0), // Add padding for spacing
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
                                          const Icon(Icons.local_grocery_store, size:30),
                                          Text("Sales Return Entry",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 150,
                                            child: Column(
                                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(formattedDate,style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),)),
                                                SizedBox(height: 5,),
                                                const Divider(
                                                  color: Colors.grey,
                                                ),

                                                const Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    "Return Number",
                                                    style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(height: 5,),
                                                Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(salRetNum.isEmpty ? "SR${DateTime.now().year % 100}${DateTime.now().month.toString().padLeft(2, '0')}/001" : salRetNum)),
                                                const Divider(
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(
                                                  width: 150,height: 50,
                                                  child: TypeAheadFormField<String>(
                                                    textFieldConfiguration: TextFieldConfiguration(
                                                      controller: invoiceNo,
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
                                                      } else {
                                                        suggestions = [];
                                                      }
                                                      return suggestions;
                                                    },
                                                    itemBuilder: (context, suggestion) {
                                                      return ListTile(
                                                        title: Text(suggestion,style: TextStyle(fontSize: 12),),
                                                      );
                                                    },
                                                    onSuggestionSelected: (suggestion) {
                                                      setState(() {

                                                      });
                                                      if (isMachineNameExists(suggestion)) {
                                                        setState(() {
                                                          errorMessage = '* Invoice Number already exists';
                                                        });
                                                      } else {
                                                        errorMessage = null;
                                                      }
                                                      setState(() {
                                                        selectedInvoiceNo = suggestion;
                                                        invoiceNo.text = suggestion;
                                                      });
                                                      print('Selected Invoice Number: $selectedInvoiceNo');
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                    ]
                                ),

                              ]
                          ),
                        ),

                      ),
                    ),
                    SizedBox(height:5,),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        // width: 710,
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

                              const Padding(
                                padding: EdgeInsets.all(8.0),
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  children: [
                                    SizedBox(
                                      width: 200, height: 70,
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: custCode,
                                        style: TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Customer Code",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            errorMessage = null; // Reset error message when the user types
                                          });
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          custCode.value =
                                              custCode.value.copyWith(
                                                text: capitalizedValue,
                                                selection: TextSelection.collapsed(
                                                    offset: capitalizedValue
                                                        .length),
                                              );
                                        },
                                      ),
                                    ),SizedBox(width: 20,),
                                    SizedBox(
                                      width: 200,height: 70,
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: custName,
                                        style: TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Customer Name",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),

                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            errorMessage = null; // Reset error message when the user types
                                          });
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          custName.value =
                                              custName.value.copyWith(
                                                text: capitalizedValue,
                                                selection: TextSelection.collapsed(
                                                    offset: capitalizedValue
                                                        .length),
                                              );
                                        },
                                      ),
                                    ),SizedBox(width: 20,),
                                    SizedBox(
                                      width: 200,height: 70,
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: custMobile,
                                        style: TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          prefixText: "+91 ",
                                          labelText: "Customer Mobile",
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
                                    ),SizedBox(width: 20,),
                                    SizedBox(
                                      width: 200,height: 70,
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: custAddress,
                                        style: TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Customer Address",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black), // Set the border color here
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            errorMessage = null; // Reset error message when the user types
                                          });
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          custAddress.value =
                                              custAddress.value.copyWith(
                                                text: capitalizedValue,
                                                selection: TextSelection.collapsed(
                                                    offset: capitalizedValue
                                                        .length),
                                              );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    SizedBox(
                                      width: 200,height: 70,
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: cpincode,
                                        style: TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Pincode",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black), // Set the border color here
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            errorMessage = null; // Reset error message when the user types
                                          });
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          custAddress.value =
                                              custAddress.value.copyWith(
                                                text: capitalizedValue,
                                                selection: TextSelection.collapsed(
                                                    offset: capitalizedValue
                                                        .length),
                                              );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
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
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: FocusTraversalGroup(
                                        policy: OrderedTraversalPolicy(),
                                        child: Table(
                                          border: TableBorder.all(color: Colors.black),

                                          defaultColumnWidth: const FixedColumnWidth(140.0),
                                          columnWidths: const <int, TableColumnWidth>{
                                            // 0: FixedColumnWidth(120),
                                            // 1: FixedColumnWidth(120),
                                            2: FixedColumnWidth(80),
                                            3: FixedColumnWidth(0),
                                            4: FixedColumnWidth(80),
                                            5: FixedColumnWidth(80),
                                            7: FixedColumnWidth(140),
                                            8: FixedColumnWidth(140),
                                            9: FixedColumnWidth(0),
                                          },
                                          children: [
                                            TableRow(
                                              decoration: BoxDecoration(color: Colors.blue.shade200),
                                              children: [
                                                TableCell(child: Center(child: Column(
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    Text('Item Group', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 15),

                                                  ],
                                                ))),
                                                TableCell(child: Center(child: Column(
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ))),
                                                TableCell(child: Center(child: Column(
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    Text('Rate/Cone', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ))),
                                                TableCell(child: Center(child: Column(
                                                  children: [
                                                    Text(''),
                                                  ],
                                                ))),
                                                TableCell(child: Center(child: Column(
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ))),TableCell(child: Center(child: Column(
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    Text('GST(%)', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ))),
                                                TableCell(child: Center(child: Column(
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ))),
                                                TableCell(child: Center(child: Column(
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    Text('GST Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ))),
                                                TableCell(child: Center(child: Column(
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ))), TableCell(child: Center(child: Column(
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ))),
                                                TableCell(child: Center(child: Column(
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ))),
                                              ],
                                            ),
                                            for (int i = 0; i < controllers.length; i++)
                                              TableRow(
                                                children: [

                                                  for (int j = 0; j <10; j++)
                                                    j==9?
                                                    TableCell(
                                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(8.0),
                                                        child: Visibility(
                                                          visible: false,
                                                          child: TextFormField(
                                                            // style: TextStyle(fontSize: 13,color: Colors.black),
                                                            controller: controllers[i][9],





                                                          ),
                                                        ),
                                                      ),
                                                    )


                                                        :j==4
                                                        ? TableCell(
                                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(8.0),
                                                        child: TextFormField(
                                                          style: TextStyle(fontSize: 13,color: Colors.black),
                                                          controller: controllers[i][4],

                                                          decoration: const InputDecoration(
                                                            filled:true,
                                                            fillColor: Colors.white,
                                                          ),
                                                          textAlign: (j >= 0 && j <= 6) ? TextAlign.center : TextAlign.right,
                                                          enabled: j==4 || j==5,
                                                          onChanged: (value) {
                                                            double quantity = double.tryParse(controllers[i][4].text) ?? 0.0;
                                                            double enteredQuantity = double.tryParse(value) ?? 0.0;
                                                            if (enteredQuantity < quantity) {
                                                              controllers[i][j].text = quantity.toString();
                                                            }
                                                            double unit = double.tryParse(controllers[i][3].text) ?? 0.0;
                                                            double rate = double.tryParse(controllers[i][2].text) ?? 0.0;
                                                            double gst = 0.0;
                                                            try {
                                                              gst = double.parse(controllers[i][5].text);
                                                            } catch (e) {
                                                              // Handle the case where parsing fails
                                                              print('Error parsing GST: $e');
                                                            }
                                                            double amount = (quantity * (unit * rate));
                                                            double gstvalue = amount * (gst / 100);
                                                            double total = amount + gstvalue;
                                                            controllers[i][6].text = amount.toStringAsFixed(2);
                                                            controllers[i][7].text = gstvalue.toStringAsFixed(2);
                                                            controllers[i][8].text = total.toStringAsFixed(2);
                                                            final int rowIndex = i;
                                                            final int colIndex = j;
                                                            final String key = _getKeyForColumn(colIndex);
                                                            rowData[rowIndex][key] = value;
                                                            grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
                                                            int getqty = int.parse(quantity.toString());
                                                            int valuereceived = int.parse(controllers[i][9].text);
                                                            int pendingqtyget = valuereceived-getqty;
                                                            getitemgGroup= controllers[i][0].text;
                                                            getitemgName=controllers[i][1].text;
                                                            getQty=int.parse(controllers[i][4].text);
                                                            if (beforeEditQty == null) {
                                                              beforeEditQty = int.tryParse(valuereceived.toString()) ?? 0;
                                                              print("$beforeEditQty edities");
                                                            }
                                                            grandTotal.text = calculateGrandTotal().toStringAsFixed(2);

                                                            double quantities = double.tryParse(value) ?? 0.0;
                                                            if (valuereceived! < quantities) {
                                                              print("Error: Quantity can only be decreased, not increased");
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title: Text('Alert'),
                                                                    content: const Text('Return Items quantity not increase.'),
                                                                    actions: <Widget>[
                                                                      TextButton(
                                                                        child: Text('OK'),
                                                                        onPressed: () {
                                                                          setState(() {

                                                                          });


                                                                          Navigator.of(context).pop(); // Close the dialog
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                              // Reset the quantity to the previous value
                                                              controllers[i][4].text = beforeEditQty.toString();
                                                              return;
                                                            }


                                                          },
                                                        ),
                                                      ),
                                                    )

                                                        :TableCell(
                                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(8.0),
                                                        child: TextFormField(
                                                          style: TextStyle(fontSize: 13,color: Colors.black),
                                                          controller: controllers[i][j],
                                                          decoration: const InputDecoration(
                                                            filled:true,
                                                            fillColor: Colors.white,
                                                          ),
                                                          textAlign: (j >= 0 && j <= 6) ? TextAlign.center : TextAlign.right,
                                                          enabled: j==4 || j==5,
                                                          onChanged: (value) {
                                                            double quantity = double.tryParse(controllers[i][4].text) ?? 0.0;
                                                            double enteredQuantity = double.tryParse(value) ?? 0.0;
                                                            if (enteredQuantity < quantity) {
                                                              controllers[i][j].text = quantity.toString();
                                                            }
                                                            double unit = double.tryParse(controllers[i][3].text) ?? 0.0;
                                                            double rate = double.tryParse(controllers[i][2].text) ?? 0.0;
                                                            double gst = 0.0;
                                                            try {
                                                              gst = double.parse(controllers[i][5].text);
                                                            } catch (e) {
                                                              // Handle the case where parsing fails
                                                              print('Error parsing GST: $e');
                                                            }
                                                            double amount = (quantity * (unit * rate));
                                                            double gstvalue = amount * (gst / 100);
                                                            double total = amount + gstvalue;
                                                            controllers[i][6].text = amount.toStringAsFixed(2);
                                                            controllers[i][7].text = gstvalue.toStringAsFixed(2);
                                                            controllers[i][8].text = total.toStringAsFixed(2);
                                                            final int rowIndex = i;
                                                            final int colIndex = j;
                                                            final String key = _getKeyForColumn(colIndex);
                                                            rowData[rowIndex][key] = value;
                                                            grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
                                                            getitemgGroup= controllers[i][0].text;
                                                            getitemgName=controllers[i][1].text;
                                                            getQty=int.parse(controllers[i][4].text);


                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: Center(
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
                                  ),

                                  /*  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: FocusTraversalGroup(
                                      policy: OrderedTraversalPolicy(),
                                      child: Table(
                                        border: TableBorder.all(
                                            color: Colors.black54
                                        ),
                                        defaultColumnWidth: const FixedColumnWidth(140.0),
                                        columnWidths: const <int, TableColumnWidth>{
                                          // 0: FixedColumnWidth(175),
                                          // 1: FixedColumnWidth(175),
                                          2: FixedColumnWidth(100),
                                          3: FixedColumnWidth(100),
                                          4: FixedColumnWidth(100),
                                          5: FixedColumnWidth(100),
                                          6: FixedColumnWidth(100),
                                          7: FixedColumnWidth(128),8: FixedColumnWidth(115),

                                        },
                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                        children: [
                                          // Table header row
                                          TableRow(
                                            children: [
                                              TableCell(
                                                child: Container(
                                                  color:Colors.blue.shade200,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height:15 ),
                                                        Text('ItemGroup',style: TextStyle(fontWeight: FontWeight.bold),),
                                                        const SizedBox(height: 15),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Container(
                                                  color:Colors.blue.shade200,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height:15),
                                                        Text('Item Name',style: TextStyle(fontWeight: FontWeight.bold),),
                                                        const SizedBox(height:15),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Container(
                                                  color:Colors.blue.shade200,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height:15),
                                                        Text('Quantity',style: TextStyle(fontWeight: FontWeight.bold),),
                                                        const SizedBox(height:15),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Container(
                                                  color:Colors.blue.shade200,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height: 8),
                                                        Text(' Rate per\n Unit',style: TextStyle(fontWeight: FontWeight.bold),),
                                                        const SizedBox(height: 8),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Container(
                                                  color:Colors.blue.shade200,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height: 15),
                                                        Text('Amount',style: TextStyle(fontWeight: FontWeight.bold),),
                                                        const SizedBox(height: 15),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Container(
                                                  color:Colors.blue.shade200,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height: 15),
                                                        Text('GST',style: TextStyle(fontWeight: FontWeight.bold),),
                                                        const SizedBox(height: 15),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Container(
                                                  color:Colors.blue.shade200,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height: 15),
                                                        Text('GST Amount',style: TextStyle(fontWeight: FontWeight.bold),),
                                                        const SizedBox(height: 15),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Container(
                                                  color:Colors.blue.shade200,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height: 15),
                                                        Text('Total',style: TextStyle(fontWeight: FontWeight.bold),),
                                                        const SizedBox(height: 15),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Container(
                                                  color:Colors.blue.shade200,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height: 15),
                                                        Text('Reason',style: TextStyle(fontWeight: FontWeight.bold),),
                                                        const SizedBox(height: 15),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Container(
                                                  color:Colors.blue.shade200,
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height: 15),
                                                        Text('Action',style: TextStyle(fontWeight: FontWeight.bold),),
                                                        const SizedBox(height: 15),
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
                                                for (var j = 0; j < 9; j++)
                                                  j==0
                                                      ?Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: TypeAheadFormField(
                                                      textFieldConfiguration: TextFieldConfiguration(
                                                        controller: controllers[i][0],
                                                        decoration: const InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                        ),
                                                      ),

                                                      suggestionsCallback: (pattern) async {
                                                        // Fetch itemGroup values that match the input pattern
                                                        List<String> filteredItemGroups = [];
                                                        for (var item in itemGroups) {
                                                          if (item.toLowerCase().startsWith(pattern.toLowerCase())) {
                                                            filteredItemGroups.add(item);
                                                          }
                                                        }
                                                        return filteredItemGroups;
                                                      },
                                                      itemBuilder: (context, suggestion) {
                                                        return ListTile(
                                                          title: Text(suggestion),
                                                        );
                                                      },
                                                      onSuggestionSelected: (suggestion) {
                                                        controllers[i][0].text = suggestion;
                                                      },
                                                    ),
                                                  )
                                                      : j == 1
                                                      ?  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: TypeAheadFormField(
                                                      textFieldConfiguration: TextFieldConfiguration(
                                                        controller: controllers[i][1],
                                                        decoration: const InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                        ),
                                                      ),
                                                      suggestionsCallback: (pattern) async {
                                                        // Fetch itemName values that match the input pattern
                                                        List<String> filteredItemNames = [];
                                                        for (var itemName in itemNames) {
                                                          if (itemName.toLowerCase().startsWith(pattern.toLowerCase())) {
                                                            filteredItemNames.add(itemName);
                                                          }
                                                        }
                                                        return filteredItemNames;
                                                      },
                                                      itemBuilder: (context, suggestion) {
                                                        return ListTile(
                                                          title: Text(suggestion),
                                                        );
                                                      },
                                                      onSuggestionSelected: (suggestion) {

                                                        controllers[i][1].text = suggestion;
                                                      },
                                                    ),
                                                  )


                                                      : TableCell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: TextFormField(
                                                          style: TextStyle(fontSize: 13),
                                                          controller: controllers[i][j],
                                                          inputFormatters: [UpperCaseTextFormatter()],
                                                          decoration: const InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          ),
                                                          textAlign: (j >= 0 && j <= 3) ? TextAlign.center : TextAlign.right,
                                                          enabled: j == 0 || j == 1 || j == 2 || j == 3 || j == 5 || j == 2,
                                                          onChanged: (value) async {
                                                            final int rowIndex = i;
                                                            final int colIndex = j;
                                                            final String key = _getKeyForColumn(colIndex);
                                                            updateFieldValidation();
                                                            setState(() {
                                                              rowData[rowIndex][key] = value;
                                                              isRowFilled[i] = controllers[i].every((controller) => controller.text.isNotEmpty);
                                                              errorMessage = '';


                                                              if (colIndex == 2 || colIndex == 3 || colIndex == 5) {
                                                                double quantity = double.tryParse(controllers[rowIndex][2].text) ?? 0.0;
                                                                double rate = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
                                                                double gst = double.tryParse(controllers[rowIndex][5].text) ?? 0.0;

                                                                double amount = quantity * rate;
                                                                double gstAmt = (amount * gst) / 100;
                                                                double total = amount + gstAmt;

                                                                controllers[rowIndex][4].text = amount.toStringAsFixed(2);
                                                                */
                                  /*controllers[rowIndex][5].text = gst.toStringAsFixed(2);*/
                                  /*
                                                                controllers[rowIndex][6].text = gstAmt.toStringAsFixed(2);
                                                                controllers[rowIndex][7].text = total.toStringAsFixed(2);
                                                                controllers[rowIndex][8].text = reason;

                                                                grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
                                                              }
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
                                                            if (controllers.length > 1) {
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
                                                            } else {
                                                              print('Cannot remove the first row. At least one row is required.');
                                                            }
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
                                  ),*/


                                  SizedBox(height: 15,),
                                  Wrap(
                                    children: [
                                      Text(""),
                                      SizedBox(width:600),
                                      Text("Grand Total  ₹ ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                                      SizedBox(width: 20,),
                                      SizedBox(
                                        width: 124,
                                        //  height: 70,
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: grandTotal,
                                          style: const TextStyle(fontSize: 13),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            LengthLimitingTextInputFormatter(10),
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.grey)
                                              )
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:  EdgeInsets.only(top:20),
                                        child: Text(
                                          errorMessage ?? '',
                                          style: TextStyle(color: Colors.red , fontSize: 15),
                                        ),
                                      ),
                                      
                                    ],
                                  )
                                ],
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
                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () async {
                              if (invoiceNo.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Invoice Number ';
                                });
                              } else if (custCode.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Valid Invoice Number ';
                                });
                              }

                              else if (isMachineNameExists(invoiceNo.text)) {
                                setState(() {
                                  errorMessage = '* Invoice Number is already Returned';
                                });
                              }
                              else if (grandTotal.text =="0.0"||grandTotal.text =="0.00") {
                                setState(() {
                                  errorMessage = '* Enter a Sales return items ';
                                });
                              }


                              else if (!isItemAvailableInStock(getitemgGroup!, getitemgName!,getQty! )/*||getQty==0*/) {

                                setState(() {
                                  errorMessage="Return Qty is Greater than ordered Qty.";
                                });

                                print('Error: Item ${getitemgGroup!} in group ${getitemgName!} not available in stock.');
                              }
                              else {
                                for (var i = 0; i < controllers.length; i++) {
                                  //damage update starts
                                  bool isDuplicate = await checkForDuplicate(
                                    controllers[i][0].text,
                                    controllers[i][1].text,);
                                  if (isDuplicate) {
                                    updateDamage(controllers[i][0].text,
                                        controllers[i][1].text,
                                        int.parse(controllers[i][4].text));
                                  }else{
                                    //damage inserts starts
                                    dataToInsertdamage = {
                                      'itemGroup': controllers[i][0].text,
                                      'itemName': controllers[i][1].text,
                                      'qty': controllers[i][4].text
                                    };
                                    insertData(dataToInsertdamage);
                                  }}
                                //damage inserts ends
                                List<Map<String, dynamic>> rowsDataToInsert = [
                                ];
                                rowsDataToInsert.add(dataToInsert);
                                updateFieldSales(invoiceNo.text, "");
                                try {
                                  setState(() {
                                    salesReturnsToDatabase();
                                    isDataSaved = true;
                                  });
                                  clearAllRows();
                                  invoiceNo.clear();
                                  custCode.clear();
                                  custName.clear();
                                  custMobile.clear();
                                  custAddress.clear();
                                  //selectedReason==null;
                                  grandTotal.clear();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Sales return"),
                                        content: Text("saved successfully."),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SalesReturn()));
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } catch (e) {
                                  print('Error inserting data: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Failed to save data. Please try again."),
                                    ),
                                  );
                                }
                              }
                              //Navigator.push(context, MaterialPageRoute(builder: (context)=>PurchaseReturn()));
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
                                              MaterialPageRoute(builder: (context) =>const SalesReturn()));// Close the alert box
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
      return 'rate';
    case 3:
      return 'unit';
    case 4:
      return 'qty';
    case 5:
      return 'gst';
    case 6:
      return 'amt';
    case 7:
      return 'amtGst';
    case 8:
      return 'total';
    case 9:
      return 'total';
    case 10:
      return 'qty';
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

