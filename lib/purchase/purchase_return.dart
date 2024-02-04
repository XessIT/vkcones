
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import '../home.dart';

class PurchaseReturn extends StatefulWidget {
  const PurchaseReturn({Key? key}) : super(key: key);
  @override
  State<PurchaseReturn> createState() => _PurchaseReturnState();
}
class _PurchaseReturnState extends State<PurchaseReturn> {
  final _formKey = GlobalKey<FormState>();
  final  date = DateTime.now();
  List<List<TextEditingController>> controllers = [];
  List<List<FocusNode>> focusNodes = [];
  List<Map<String, dynamic>> rowData = [];
  List<bool> isRowFilled = [false];
  bool allFieldsFilled = false;
  bool dropdownValid = true;
  //String payType="Payment Type";
  bool itemGroupExists = false;
  Map<String, dynamic> dataToInsert = {};
  /* final List<String> reasonOptions = ['Reason','Mismatch', 'Damage', 'Others'];
  List<String> selectedReason = List.generate(3, (i) => 'Reason');*/

  String? errorMessage="";
  bool isTableFieldsEmpty(int rowIndex) {
    return controllers[rowIndex].any((controller) => controller.text.isEmpty);
  }
/*  YourWidgetState() {
    selectedReason = List.generate(controllers.length, (i) => 'Reason');
  }*/

  double calculateTotal(int rowIndex) {
    double quantity = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
    double rate = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;
    double gst = double.tryParse(controllers[rowIndex][6].text) ?? 0.0;

    double amount = quantity * rate;
    double gstAmt = (amount * gst) / 100;
    double total = amount + gstAmt;

    controllers[rowIndex][5].text = amount.toStringAsFixed(2);
    controllers[rowIndex][7].text = gstAmt.toStringAsFixed(2);
    controllers[rowIndex][8].text = total.toStringAsFixed(2);


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
  void addRow() {
    setState(() {
      List<TextEditingController> rowControllers = [];
      List<FocusNode> rowFocusNodes = [];

      for (int j = 0; j < 10; j++) {
        rowControllers.add(TextEditingController());
        rowFocusNodes.add(FocusNode());
      }

      controllers.add(rowControllers);
      focusNodes.add(rowFocusNodes);
      isRowFilled.add(false);

      // selectedReason.add('Reason');

      Map<String, dynamic> row = {
        'prodCode': '',
        'prodName': '',
        'unit':'',
        'qty': '',
        'rate':'',
        'amt':'',
        'gst':'',
        'amtGST':'',
        'total':'',
        'reason':'',
      };

      rowData.add(row);

      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(rowFocusNodes[0]);
      });
    });
    grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
  }
  void removeRow(int rowIndex) {
    setState(() {
      controllers.removeAt(rowIndex);
      focusNodes.removeAt(rowIndex);
      isRowFilled.removeAt(rowIndex);
      rowData.removeAt(rowIndex);

      // fetchedQuantities.remove(rowIndex);
      // for (int i = 0; i < fetchedQuantities.length; i++) {
      //   if (i >= rowIndex) {
      //     fetchedQuantities[i] = fetchedQuantities[i + 1]!;
      //   }
      // }

    });
    setState(() {
      grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
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
      for (var j = 0; j < 10; j++) {
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
  void validateDropdown() {
    setState(() {
      dropdownValid = payType != null;
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


  TextEditingController invoiceNo=TextEditingController();
  TextEditingController returnNo=TextEditingController();
  TextEditingController purchaseRetNo=TextEditingController();
  TextEditingController purchseDate=TextEditingController();
  TextEditingController supCode=TextEditingController();
  TextEditingController supName=TextEditingController();
  TextEditingController supMobile=TextEditingController();
  TextEditingController supAddress=TextEditingController();
  TextEditingController grandTotal=TextEditingController();
  TextEditingController payType=TextEditingController();
  TextEditingController pincode=TextEditingController();
  TextEditingController id=TextEditingController();

  List<Map<String, dynamic>> data3 = [];
  List<Map<String, dynamic>> filteredData3 = [];

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




  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Map<String, dynamic> dataToInsertPurchaseReturn = {};
  Map<String, dynamic> dataToInsertPurchaseReturnItem = {};

  Future<void> insertDataPurchaseReturnItem(Map<String, dynamic> dataToInsertPurchaseReturnItem) async {
    const String apiUrl = 'http://localhost:3309/purchase_ret_item'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertPurchaseReturnItem': dataToInsertPurchaseReturnItem}),
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
  Future<void> updateRawMaterial(String prodCode, String prodName,String unit,int qty,String modifyDate) async {
    final Uri url = Uri.parse('http://localhost:3309/updateRawMaterial'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'prodCode': prodCode,
        'prodName': prodName,
        'unit':unit.toString(),
        /* 'preturnNo': preturnNo,*/
        'qty': qty,
        "modifyDate":date.toString(),
      }),
    );
    if (response.statusCode == 200) {
      print('Update successful');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
      throw Exception('Failed to update');
    }
  }

  Future<void> updateReturnQty(String prodCode, String prodName,String invoiceNo,int returnQty, String returnTotal, String modifyDate) async {
    final Uri url = Uri.parse('http://localhost:3309/updateReturnQty'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'prodCode': prodCode,
        'prodName': prodName,
        'invoiceNo': invoiceNo,
        'returnQty': returnQty,
        'returnTotal':returnTotal,
        "modifyDate":date.toString(),
      }),
    );
    if (response.statusCode == 200) {
      print('Update successful');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
      throw Exception('Failed to update');
    }
  }

  Future<List<String>> getSuggestionsForReason(String query) async {
    final List<String> reasonSuggestions = ['Mismatch', 'Damage'];
    final filteredSuggestions = reasonSuggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return filteredSuggestions;
  }


  Future<void> purchaseReturnItemToDatabase() async {
    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');
    if (returnNumber.isEmpty) {
      returnNumber = 'PR$year$month/001';
    }
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers.length; i++) {
      Map<String, dynamic> dataToInsertPurchaseReturnItem = {

        "date": date.toString(),
        "invoiceNo": invoiceNo.text,
        "preturnNo": returnNumber,
        "supCode": supCode.text,
        "supName": supName.text,
        "supAddress": supAddress.text,
        "supMobile": supMobile.text,
        "pincode": pincode.text,
        'prodCode': controllers[i][0].text,
        'prodName': controllers[i][1].text,
        'unit':controllers[i][2].text,
        'qty': controllers[i][3].text,
        'rate': controllers[i][4].text,
        'amt': controllers[i][5].text,
        'gst': controllers[i][6].text,
        'amtGST': controllers[i][7].text,
        'total': controllers[i][8].text,
        'reason': controllers[i][9].text,
        'grandTotal': grandTotal.text,
      };
      insertFutures.add(insertDataPurchaseReturnItem(dataToInsertPurchaseReturnItem)); // Await here
      updateRawMaterial(controllers[i][0].text,
        controllers[i][1].text,
        controllers[i][2].text,
        int.parse(controllers[i][3].text),
        date.toString(),
      );

      updateReturnQty(controllers[i][0].text, controllers[i][1].text, invoiceNo.text,  int.parse(controllers[i][3].text),grandTotal.text, date.toString());

    }

    try {

      await Future.wait(insertFutures); // Await for all insertions to complete
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }
  Future<void> updateSupplierDetails(String invoiceNo,String grandTotal) async {
    final response = await http.put(
      Uri.parse('http://localhost:3309/returnTotal_update/$invoiceNo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        // Corrected key name
        'returnTotal': grandTotal, // Corrected key name
      }),
    );

    if (response.statusCode == 200) {
      print('Data updated successfully');
    } else {
      print('Error updating data: ${response.body}');
    }
  }

  List<String> filterSuppliersByInvoice(String invoiceNumber) {
    if (invoiceNumber.isEmpty) {
      return [];
    }

    List<String> filteredSuppliers = data
        .where((item) =>
    (item['invoiceNo']?.toString()?.toLowerCase() ?? '') == invoiceNumber.toLowerCase())
        .map((item) => item['supName'].toString())
        .toSet()
        .toList();

    return filteredSuppliers;
  }


  final FocusNode _suppliernameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_suppliernameFocusNode);
    });
    //   saveReturnNumber();
    addRow();
    fetchData();
    fetchData3();
    filterData3(invoiceNo.text);
    loadReturnNumber();
    loadReturnNumber();
    reNoFetch();
     fetchDataByInvoiceNumber(invoiceNo.text);
    setState(() {
      filterPoNo(invoiceNo.text);
    });
  }
  String selectedCustomer=" ";
  String selectedInvoiceNo='';
  Map<int, double> fetchedQuantities = {};
  Map<int, double> fetchedtotalWeight = {};
  double fetchedQuantity = 0.0;
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
              'reason': rows[i]['reason'],
            };

            for (int j = 0; j < 10; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }

            controllers.add(rowControllers);
            focusNodes.add(List.generate(9, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);
            fetchedQuantities[i] = double.tryParse(rows[i]['qty']) ?? 0.0;
            grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
          }
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  List<Map<String, dynamic>> data = [];

  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_purchase/');
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
  Future<void> fetchData3() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_purchase_return_invoice/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          data3 = itemGroups.cast<Map<String, dynamic>>();
        });
        print('Data: $data3');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }
  List<Map<String, dynamic>> filteredData = [];
  void filterData3(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData3= data3;
        setState(() {
          errorMessage = null;
        });
      } else {
        final existingSupplier = data3.firstWhere(
              (item) => item['invoiceNo']?.toString() == searchText,
          orElse: () => {},
        );
      }
    });
  }
  void filterData(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = data;
        supCode.clear();
        supAddress.clear();
        supMobile.clear();
        pincode.clear();
        grandTotal.clear();
        setState(() {
          errorMessage = null;
        });
      } else {
        final existingSupplier = data.firstWhere(
              (item) => item['invoiceNo']?.toString() == searchText,
          orElse: () => {},
        );
        if (existingSupplier.isNotEmpty) {
          supName.text = existingSupplier['supName']?.toString() ?? '';
          supMobile.text = existingSupplier['supMobile']?.toString() ?? '';
          supAddress.text = existingSupplier['supAddress']?.toString() ?? '';
          supCode.text = existingSupplier['supCode']?.toString() ?? '';
          pincode.text = existingSupplier['pincode']?.toString() ?? '';
          grandTotal.text = existingSupplier['grandTotal']?.toString() ?? '';
        } else {
          supMobile.clear();
          supAddress.clear();
          supCode.clear();
          pincode.clear();
          grandTotal.clear();
          setState(() {
            errorMessage = null;
          });
        }
      }
    });
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


  Future<void> saveReturnNumber() async {
    try {
      for (int i = 0; i < controllers.length; i++) {
        String productCode = controllers[i][0].text;
        String productName = controllers[i][1].text;
        String unit = controllers[i][2].text;
        int quantity = int.parse(controllers[i][3].text);
        int availableQuantity = await getAvailableQuantity(productCode, productName, unit);

        if (availableQuantity < quantity) {
          return; // Stop the saving process
        }
      }
    } catch (e) {
      print('Error saving return number: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save data. Please try again."),
        ),
      );
    }
  }

/*  Future<void> saveReturnNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentReturnNumber', currentReturnNumber);}*/


  Future<int> getAvailableQuantity(String productCode, String productName, String unit) async {
    final url = Uri.parse('http://localhost:3309/get_available_quantity?prodCode=$productCode&prodName=$productName&unit=$unit');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['qty'];
    } else {
      throw Exception('Failed to fetch available quantity');
    }
  }


  String generateReturnId() {
    String formattedDateYear = DateFormat('yy').format(DateTime.now());
    String formattedDateMonth = DateFormat('MM').format(DateTime.now());
    String formattedNumber = currentReturnNumber.toString().padLeft(3, '0');
    String returnNumber = 'RN/$formattedDateYear$formattedDateMonth/$formattedNumber';
    return returnNumber;
  }
  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['preturnNo'];
  }
  String returnNumber = "";
  String? preturnNo;
  List<Map<String, dynamic>> codedata = [];
  String generateId() {
    DateTime now= DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');
    if (RNO != null) {
      String ID = RNO!.substring(7);
      int idInt = int.parse(ID) + 1;
      String id = 'PR$year$month/${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  List<Map<String, dynamic>> returnNoData = [];
  String? RNO;

  Future<void> reNoFetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_returnNo'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          RNO = getNameFromJsonData(item);
          print('poNo: $RNO');
        }
        setState(() {
          returnNoData = jsonData.cast<Map<String, dynamic>>();
          returnNumber = generateId(); // Call generateId here
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
  Widget build(BuildContext context) {
    DateTime Date = DateTime.now();
    final formattedDate = DateFormat("dd-MM-yyyy").format(Date);
    invoiceNo.addListener(() {
      fetchDataByInvoiceNumber(invoiceNo.text);
      filterData(invoiceNo.text);
      filterPoNo(invoiceNo.text);
    });
    return MyScaffold(
      route: "purchase_return",backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                //SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SizedBox(
                    height: 180,
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
                                    Text("Purchase Return Entry",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
                                  ],
                                ),
                                Container(
                                  width: 100,
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
                                          child: Text(returnNumber.isEmpty ? "PR${DateTime.now().year % 100}${DateTime.now().month.toString().padLeft(2, '0')}/001" : returnNumber)),
                                      const Divider(
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 200,height: 50,
                                  child: TypeAheadFormField<String>(
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: invoiceNo,focusNode: _suppliernameFocusNode,
                                      style: const TextStyle(fontSize: 13),
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          // Clear supName, supCode, supMobile, supAddress, grandTotal, and table data
                                          supName.clear();
                                          supCode.clear();
                                          supMobile.clear();
                                          supAddress.clear();
                                          pincode.clear();
                                          grandTotal.clear();
                                          controllers.clear();
                                          focusNodes.clear();
                                          isRowFilled.clear();
                                          rowData.clear();
                                          setState(() {
                                            errorMessage = null;
                                          });
                                        } else {
                                          fetchDataByInvoiceNumber(invoiceNo.text);
                                        }
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
                                            .startsWith(pattern.toLowerCase()) &&
                                            !(item['prodName']?.toString()?.toLowerCase() ?? '').startsWith('gsm'))
                                            .map((item) => item['invoiceNo'].toString())
                                            .toSet() // Remove duplicates using a Set
                                            .toList();
                                        suggestions.removeWhere((existingInvoiceNo) =>
                                        isMachineNameExists(existingInvoiceNo) &&
                                            existingInvoiceNo != invoiceNo.text);
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
                                        fetchDataByInvoiceNumber(invoiceNo.text);
                                        if (isMachineNameExists(invoiceNo.text)) {
                                          errorMessage = '* Invoice Number already exists';
                                        } else {
                                          errorMessage = null;
                                        }
                                        setState(() {
                                          if (invoiceNo.text.isEmpty) {
                                            grandTotal.clear();
                                            errorMessage = null;
                                          }
                                        });
                                      });
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

                          ]
                      ),
                    ),

                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SizedBox(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Wrap(
                        children: [
                          Padding(
                            padding:  EdgeInsets.only(left:900),
                            child: Text(
                              errorMessage ?? '',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Supplier Details",style: TextStyle(
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
                                  width: 220,height: 70,
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: supName,
                                    style: TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: "Supplier/ Company Name",
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black), // Set the border color here
                                      ),
                                    ),
                                  ),
                                ),
                                /* Padding(
                                  padding: const EdgeInsets.only(bottom: 36),
                                  child: SizedBox(
                                    width: 220,
                                    height: 34,
                                    child:
                                    TypeAheadFormField<String>(
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: supName,

                                        style: const TextStyle(fontSize: 13),
                                        onChanged: (value) {
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          supName.value = supName.value.copyWith(
                                            text: capitalizedValue,
                                            selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                          );
                                          setState(() {
                                            errorMessage=null;
                                          });
                                          fetchDataByInvoiceNumber(invoiceNo.text,);
                                        },
                                        decoration: InputDecoration(
                                          // suffixIcon: Icon(Icons.search),
                                          fillColor: Colors.white,
                                          filled: true,
                                          labelText: "Supplier/Company Name",
                                          labelStyle: TextStyle(fontSize: 13),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      suggestionsCallback: (pattern) async {
                                        if (pattern.isEmpty) {
                                          return filterSuppliersByInvoice(invoiceNo.text);
                                        }
                                        List<String> suggestions = filterSuppliersByInvoice(invoiceNo.text)
                                            .where((supplier) => supplier.toLowerCase().startsWith(pattern.toLowerCase()))
                                            .toList();
                                        return suggestions;
                                      },
                                      *//*suggestionsCallback: (pattern) async {
                                        if (pattern.isEmpty) {
                                          return [];
                                        }
                                        List<String> suggestions =data
                                            .where((item) =>
                                            (item['supName']?.toString()?.toLowerCase() ?? '')
                                                .startsWith(pattern.toLowerCase()))
                                            .map((item) => item['supName'].toString())
                                            .toSet() // Remove duplicates using a Set
                                            .toList();
                                        return suggestions;
                                      },*//*
                                      itemBuilder: (context, suggestion) {
                                        return ListTile(
                                          title: Text(suggestion),
                                        );
                                      },
                                      onSuggestionSelected: (suggestion) {
                                        setState(() {
                                          selectedCustomer = suggestion;
                                          supName.text = suggestion;
                                        });
                                        print('Selected Customer: $selectedCustomer');
                                      },
                                    ),
                                  ),
                                ),*/
                                SizedBox(width: 20,),
                                SizedBox(
                                  width: 220, height: 70,
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: supCode,
                                    style: TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: "Supplier Code",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),

                                      ),
                                    ),
                                  ),
                                ),SizedBox(width: 20,),
                                SizedBox(
                                  width: 220,height: 70,
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: supMobile,
                                    style: TextStyle(fontSize: 13),
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
                                ),SizedBox(width: 20,),
                                SizedBox(
                                  width: 220,height: 70,
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: supAddress,
                                    style: TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: "Address",
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black), // Set the border color here
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20,),
                                SizedBox(
                                  width: 220,height: 70,
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: pincode,
                                    style: TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: "Pincode",
                                      hintText: "Pincode",
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black), // Set the border color here
                                      ),
                                    ),
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: FocusTraversalGroup(
                                    policy: OrderedTraversalPolicy(),
                                    child: Table(
                                      border: TableBorder.all(color: Colors.black),

                                      defaultColumnWidth: const FixedColumnWidth(140.0),
                                      columnWidths: const <int, TableColumnWidth>{
                                        0: FixedColumnWidth(120),
                                        1: FixedColumnWidth(120),
                                        2: FixedColumnWidth(100),
                                        3: FixedColumnWidth(100),
                                        4: FixedColumnWidth(100),
                                        5: FixedColumnWidth(100),
                                        6: FixedColumnWidth(100), 7: FixedColumnWidth(100),
                                        8: FixedColumnWidth(120),9: FixedColumnWidth(120),
                                        10: FixedColumnWidth(120),11: FixedColumnWidth(60),

                                      },
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children: [
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'Product Code',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'Product Name',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'Unit',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ), TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'Quantity',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'Rate',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'Amount',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'GST (%)',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'GST Amount',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'Total',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'Reason',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade200,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 15),
                                                      Text(
                                                        'Action',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      const SizedBox(height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Data rows
                                        for (var i = 0; i < controllers.length; i++)
                                          TableRow(
                                            children: [
                                              for (var j = 0; j < 10; j++)
                                                TableCell(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: j == 9 // Check if it's the "Reason" field
                                                        ? TypeAheadFormField<String>(
                                                      suggestionsCallback: (query) {
                                                        return getSuggestionsForReason(query);
                                                      },
                                                      itemBuilder: (context, suggestion) {
                                                        return ListTile(
                                                          title: Text(suggestion),
                                                        );
                                                      },
                                                      onSuggestionSelected: (suggestion) {
                                                        controllers[i][9].text = suggestion;
                                                        setState(() {
                                                          errorMessage ="";
                                                        });
                                                      },
                                                      textFieldConfiguration: TextFieldConfiguration(
                                                        controller: controllers[i][9],
                                                        decoration: const InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                        :  TextFormField(
                                                      style: TextStyle(fontSize: 13,
                                                        color: (j == 0 || j == 1 || j == 2 || j == 3 || j == 5 || j == 6 || j == 7) ? Colors.black : Colors.grey, // Set the text color
                                                      ),

                                                      controller: controllers[i][j],
                                                      inputFormatters: [
                                                        UpperCaseTextFormatter(),
                                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                      ],
                                                      decoration: const InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      textAlign: j >= 4 && j <= 7 ? TextAlign.right : TextAlign.left,
                                                      enabled: (j == 3 || j == 7 || j == 3 || j == 4 || j == 8),
                                                      onChanged: (value) {
                                                        final int rowIndex = i;
                                                        final int colIndex = j;
                                                        final String key = _getKeyForColumn(colIndex);

                                                        updateFieldValidation();
                                                        setState(() {
                                                          rowData[rowIndex][key] = value;
                                                          isRowFilled[i] = controllers[i].every((controller) => controller.text.isNotEmpty);
                                                          if(!rowData[i]['prodName'].startsWith('GSM')){
                                                            if (colIndex == 3 || colIndex == 4 || colIndex == 6) {
                                                              double quantity = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
                                                             // double totweight = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;

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
/*
                                                              if (totweight > fetchedtotalWeight[rowIndex]!) {
                                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                  content: Text('Weight should be less than or equal to ${fetchedtotalWeight[rowIndex]}'),
                                                                  duration: Duration(seconds: 2),
                                                                ));
                                                                setState(() {
                                                                  controllers[i][4].text = fetchedtotalWeight[rowIndex].toString();

                                                                });

                                                                return;
                                                              }
*/



                                                              double rate = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;
                                                              double gst = double.tryParse(controllers[rowIndex][6].text) ?? 0.0;

                                                              double amount = quantity * rate;
                                                              double gstAmt = (amount * gst) / 100;
                                                              double total = amount + gstAmt;

                                                              controllers[rowIndex][5].text = amount.toStringAsFixed(2);
                                                              /*controllers[rowIndex][5].text = gst.toStringAsFixed(2);*/
                                                              controllers[rowIndex][7].text = gstAmt.toStringAsFixed(2);
                                                              controllers[rowIndex][8].text = total.toStringAsFixed(2);

                                                              grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
                                                            }}else{


                                                            if (colIndex == 3 || colIndex == 4 || colIndex == 6) {
                                                              double quantity = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
                                                              // double totweight = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;

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
/*
                                                              if (totweight > fetchedtotalWeight[rowIndex]!) {
                                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                  content: Text('Weight should be less than or equal to ${fetchedtotalWeight[rowIndex]}'),
                                                                  duration: Duration(seconds: 2),
                                                                ));

                                                                setState(() {
                                                                  controllers[i][4].text = fetchedtotalWeight[rowIndex].toString();

                                                                });
                                                                return;
                                                              }
*/


                                                              /*double rate = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;
                                                              double gst = double.tryParse(controllers[rowIndex][6].text) ?? 0.0;

                                                              double amount = totweight * rate;
                                                              double gstAmt = (amount * gst) / 100;
                                                              double total = amount + gstAmt;

                                                              controllers[rowIndex][5].text = amount.toStringAsFixed(2);
                                                              *//*controllers[rowIndex][5].text = gst.toStringAsFixed(2);*//*
                                                              controllers[rowIndex][7].text = gstAmt.toStringAsFixed(2);
                                                              controllers[rowIndex][8].text = total.toStringAsFixed(2);

                                                              grandTotal.text = calculateGrandTotal().toStringAsFixed(2);*/
                                                            }
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              TableCell(
                                                child: Wrap(
                                                  children: [
                                                    Center(
                                                      child: IconButton(
                                                        icon: Icon(Icons.remove_circle_outline),
                                                        color: Colors.red.shade600,
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: Text('Confirmation'),
                                                                content: Text('Are you sure you want to remove this Product?'),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    child: Text('No'),
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop(); // Close the alert box
                                                                    },
                                                                  ),
                                                                  TextButton(
                                                                    child: Text('Yes'),
                                                                    onPressed: () {


                                                                      removeRow(i); // Remove the row
                                                                      Navigator.of(context).pop(); // Close the alert box
                                                                      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PurchaseReturn()));

                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Wrap(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text("Grand Total  ₹ ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        SizedBox(
                                          width: 124,
                                          child: TextFormField(
                                            textAlign: TextAlign.right,
                                            readOnly: true,
                                            controller: grandTotal,
                                            style: const TextStyle(fontSize: 13),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              LengthLimitingTextInputFormatter(10),
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),SizedBox(
                                            width: 185,
                                            child: Text(" ")),
                                      ],
                                    ),
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
                      MaterialButton(
                        color: Colors.green.shade600,
                        onPressed: () async {


                          if (isMachineNameExists(invoiceNo.text)) {
                            setState(() {
                              errorMessage = '* Invoice Number already exists';
                            });
                            return;
                          } else {
                            setState(() {
                              errorMessage = null;
                            });
                          }

                          for (var i = 0; i < controllers.length; i++) {
                            bool isGSMProduct = rowData[i]['prodName'].startsWith('GSM');
                            if (controllers[i][3].text.isEmpty || controllers[i][9].text.isEmpty) {
                              setState(() {
                                errorMessage = '* Please fill all fields ';
                              });
                              return;
                            }

                          }
                          setState(() {
                            errorMessage = null;
                          });
                          if (invoiceNo.text.isNotEmpty) {
                            updateSupplierDetails(
                              invoiceNo.text,
                              grandTotal.text,
                            );
                          }


                          if (invoiceNo.text.isEmpty) {
                            setState(() {
                              errorMessage = '* Enter Invoice Number ';
                            });
                            return;
                          }
                          if(controllers.any((controller) =>
                          controller[0].text.isEmpty ||
                              controller[1].text.isEmpty ||
                              controller[3].text.isEmpty)){
                            errorMessage = '* Invalid Invoice Number';
                          }
                          List<Map<String, dynamic>> rowsDataToInsert = [];
                          rowsDataToInsert.add(dataToInsert);
                          purchaseReturnItemToDatabase();
                          try {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Purchase Returns"),
                                  content: const Text(
                                      "Saved successfully"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PurchaseReturn()));
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
                                          MaterialPageRoute(builder: (context) =>const PurchaseReturn()));// Close the alert box
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
                          /*                    Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>const Home()));*/
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
              ],
            ),
          ),
        ),
      ),
    );
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
      return 'reason';
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

