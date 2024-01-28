import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/sale/salespdf.dart';
import '../../home.dart';
class OldEntrySales extends StatefulWidget {
  const OldEntrySales({Key? key}) : super(key: key);
  @override
  State<OldEntrySales> createState() => _OldEntrySalesState();
}
class _OldEntrySalesState extends State<OldEntrySales> {

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
  String? payType;
  String? deliveryType;
  static final RegExp gstregex2 = RegExp(r"^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d{1}[Z]{1}[A-Z\d]{1}$");


  double calculateTotal(int rowIndex) {
    double quantity = double.tryParse(controllers[rowIndex][4].text) ?? 0.0;//qty-4
    double unit = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;//unit-3
    double rate = double.tryParse(controllers[rowIndex][2].text) ?? 0.0;//rate -2
    double amount = (quantity * unit) * rate;
    double gst = double.tryParse(controllers[rowIndex][5].text) ?? 0.0;//amtGst-6
    double total = (amount * gst)/100;
    controllers[rowIndex][8].text = total.toStringAsFixed(2);//total-7

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

      Map<String, dynamic> row = {
        'itemGroup': '',
        'itemName': '',
        'rate': '',
        'unit':'',
        'qty':'',
        'gst':'',
        'amt':'',
        'amtGST':'',
        'total':'',
      };

      rowData.add(row);

      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(rowFocusNodes[0]);
      });
    });
    grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
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



  TextEditingController orderNo=TextEditingController();
  TextEditingController invoiceNo=TextEditingController();
  TextEditingController custCode=TextEditingController();
  TextEditingController custName=TextEditingController();
  TextEditingController custMobile=TextEditingController();
  TextEditingController custAddress=TextEditingController();
  TextEditingController grandTotal=TextEditingController();
  TextEditingController id=TextEditingController();
  bool isDataSaved = false;


  TextEditingController gstin=TextEditingController();


  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Map<String, dynamic> dataToInsertPurchaseReturn = {};
  Map<String, dynamic> dataToInsertPurchaseReturnItem = {};
  Future<void> insertDataPurchaseReturnItem(Map<String, dynamic> dataToInsertPurchaseReturnItem) async {
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
        print('TableData inserted successfully');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                SalesGeneratePDF(invoiceNo: generateId(),orderNo:orderNo.text,custCode:custCode.text,custName:custName.text,custAddress:custAddress.text,custMobile:custMobile.text,date:date.toString(), grandtotal:grandTotal.text), // Pass dataToInsert to the PDF screen
          ),
        );
      } else {
        print('Failed to insert data into the table');
        throw Exception('Failed to insert data into the table');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  Future<void> purchaseReturnItemToDatabase() async {
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
          controllers.add(List.generate(8, (j) => TextEditingController()));
        }
        print("Inserting data for row $i");
        Map<String, dynamic> dataToInsertPurchaseReturnItem = {
          "invoiceNo":invoiceNumber,
          "date": date.toString(),
          "orderNo":orderNo.text,
          "custCode": custCode.text,
          "custName": custName.text,
          "custAddress": custAddress.text,
          "custMobile": custMobile.text,
          "gstin":gstin.text,
          "deliveryType":deliveryType,
          "payType":payType,
          'itemGroup': controllers[i][0].text,
          'itemName': controllers[i][1].text,
          'rate': controllers[i][2].text,
          'unit': controllers[i][3].text,
          'qty': controllers[i][4].text,
          'amt': controllers[i][6].text,
          'amtGST': controllers[i][7].text,
          'total': controllers[i][8].text,
          'grandTotal': grandTotal.text,
          "salesQty":controllers[i][4].text,
        };
        insertFutures.add(insertDataPurchaseReturnItem(dataToInsertPurchaseReturnItem));
        print("Data inserted for row $i");
        print('Inserting data: $dataToInsertPurchaseReturnItem');

      }

      await Future.wait(insertFutures); // Await for all insertions to complete
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    addRow();
    fetchData();
    fetchItemGroup();
    loadInvoiceNumber();
    reNoFetch();
    fetchData2();
    fetchDataByOrderNumber(orderNo.text);
  }

  Future<void> fetchDataByOrderNumber(String orderNo) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_sales_items?orderNo=$orderNo');
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
              // 'size': rows[i]['size'],
              // 'color': rows[i]['color'],
              'rate': rows[i]['rate'].toString(),
              'unit': rows[i]['unit'].toString(),
              'qty': rows[i]['qty'].toString(),
              'gst': rows[i]['gst'].toString(),
            };

            for (int j = 0; j < 9; j++) {
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
            controllers.add(rowControllers);
            focusNodes.add(List.generate(8, (i) => FocusNode()));
            rowData.add(row);
            isRowFilled.add(true);
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

        print('Data: $data');
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
  void filterData(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = data;
        custName.clear();
        custCode.clear();
      } else {

        List<Map<String, dynamic>> filteredRows = data.where((item) {
          String id = item['orderNo']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        controllers.clear();
        focusNodes.clear();
        isRowFilled.clear();
        rowData.clear();

        filteredData = data.where((item) {
          String id = item['orderNo']?.toString() ?? '';
          return id.contains(searchText);
        }).toList();

        if (filteredData.isNotEmpty) {
          Map<String, dynamic> order = filteredData.first;
          custName.text = order['custName']?.toString() ?? '';
          custCode.text = order['custCode']?.toString() ?? '';
          deliveryType = order['deliveryType']?.toString() ?? '';

        } else {
          setState(() {
            custName.clear();
            custCode.clear();
          });
        }
      }
    });
  }
  String selectedInvoiceNo='';

  List<Map<String, dynamic>> filteredData2 = [];
  List<Map<String, dynamic>> data2 = [];
  void filterData2(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData2 = data2;
        custMobile.clear();
        custAddress.clear();
        gstin.clear();
      } else {
        final existingSupplier = data2.firstWhere(
              (item) => item['custCode']?.toString() == searchText,
          orElse: () => {}, // Use an empty map literal as the default value
        );

        if (existingSupplier.isNotEmpty) {
          custMobile.text = existingSupplier['custMobile']?.toString() ?? '';
          custAddress.text = existingSupplier['custAddress'];
          gstin.text = existingSupplier['gstin'];
        } else {
          custMobile.clear();
          custAddress.clear();
          gstin.clear();
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
  double amtgstc= 0.0;
  Future<void> saveInvoiceNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentInvoiceNumber', currentInvoiceNumber);
  }
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
    if (RNO != null) {
      String ID = RNO!.substring(7);
      int idInt = int.parse(ID) + 1;
      String id = 'IN$year$month/${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  List<Map<String, dynamic>> returnNoData = [];
  String? RNO;
  Future<void> reNoFetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_invoice_no'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          RNO = getNameFromJsonData(item);
          print('poNo: $RNO');
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
  List<String> itemGroupsSuggestions = [];
  List<String> itemNamesSuggestions = [];
  List<String> gst = [];


  Future<void> fetchItemGroup() async {
    try {
      final url = Uri.parse('http://localhost:3309/getitemGroup/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> tempItemGroup = responseData;
        itemGroupsSuggestions = tempItemGroup.map((item) => item['itemGroup'] as String).toSet().toList();
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> fetchItemName(String itemGroup, int index) async {
    try {
      final url = Uri.parse('http://localhost:3309/getitemname_by_itemgroup?itemGroup=$itemGroup');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;

        // Extract unique item names from the response
        itemNamesSuggestions = units.map((item) => item['itemName'] as String).toSet().toList();
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> fetchUnit(int index, String itemGroup, String itemName) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_unit_by_iG_iN?itemGroup=$itemGroup&itemName=$itemName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final unit = responseData['unit'] as String;

        // Update the unit in the corresponding controller
        setState(() {
          controllers[index][3].text = unit;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> fetchRate(int index, String itemGroup, String itemName) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_rate_by_iG_iN?itemGroup=$itemGroup&itemName=$itemName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final rate = responseData['rate'] as String;

        // Update the rate in the corresponding controller
        setState(() {
          controllers[index][2].text = rate;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> fetchRateAndUnit(int index, String itemGroup, String itemName) async {
    await fetchUnit(index, itemGroup, itemName);
    await fetchRate(index, itemGroup, itemName);
    await fetchGST(index, itemGroup, itemName);
  }
  Future<void> fetchGST(int index, String itemGroup, String itemName) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_gst_by_iG_iN?itemGroup=$itemGroup&itemName=$itemName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final unit = responseData['gst'];

        // Update the unit in the corresponding controller
        setState(() {
          controllers[index][5].text = unit;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void calculateValues(int index) {
    try {
      // Extract quantity, unit price, GST rate, etc., from controllers
      double quantity = double.tryParse(controllers[index][4].text.replaceAll(',', '')) ?? 0.0;
      double unitPrice = double.tryParse(controllers[index][3].text.replaceAll(',', '')) ?? 0.0;
      double gstRate = double.tryParse(controllers[index][5].text.replaceAll(',', '')) ?? 0.0;

      // Calculate other values based on your logic
      double amount = quantity * unitPrice;
      double gstAmount = (amount * gstRate) / 100.0;
      double total = amount + gstAmount;

      // Update the corresponding controllers with the calculated values
      setState(() {
        controllers[index][6].text = amount.toStringAsFixed(2);
        controllers[index][7].text = gstAmount.toStringAsFixed(2);
        controllers[index][8].text = total.toStringAsFixed(2);
      });
    } catch (error) {
      print('Error calculating values: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    DateTime Date = DateTime.now();
    final formattedDate = DateFormat("dd/MM/yyyy").format(Date);
    orderNo.addListener(() {
      filterData(orderNo.text);
      fetchDataByOrderNumber(orderNo.text);
    });
    custCode.addListener(() {
      filterData2(custCode.text);
    });
    return MyScaffold(
        route: "old_entry_sales",
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
                                          SizedBox(height: 15,),
                                          const Icon(Icons.local_grocery_store, size:30),
                                          Text("Sales Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),

                                        ],
                                      ),
                                      Row(
                                        children: [
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
                                                    "Invoice Number",
                                                    style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(height: 5,),
                                                Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(invoiceNumber.isEmpty ? "IN${DateTime.now().year % 100}${DateTime.now().month.toString().padLeft(2, '0')}/001" : invoiceNumber)),
                                                const Divider(
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20,),
                                        ],
                                      ),

                                    ]
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 200,height: 50,
                                      child: TypeAheadFormField<String>(
                                        textFieldConfiguration: TextFieldConfiguration(
                                          controller: orderNo,
                                          style: const TextStyle(fontSize: 13),
                                          onChanged: (value) {
                                            setState(() {
                                              errorMessage = null; // Reset error message when the user types
                                            });
                                            String capitalizedValue = capitalizeFirstLetter(value);
                                            orderNo.value =
                                                orderNo.value.copyWith(
                                                  text: capitalizedValue,
                                                  selection: TextSelection.collapsed(
                                                      offset: capitalizedValue
                                                          .length),
                                                );
                                          },
                                          inputFormatters:
                                          [UpperCaseTextFormatter()],
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
                                            suggestions = data
                                                .where((item) =>
                                                (item['orderNo']?.toString()?.toLowerCase() ?? '')
                                                    .startsWith(pattern.toLowerCase()))
                                                .map((item) => item['orderNo'].toString())
                                                .toSet() // Remove duplicates using a Set
                                                .toList();
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
                                            orderNo.text = suggestion;
                                          });
                                          print('Selected Invoice Number: $selectedInvoiceNo');
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                  ],
                                )

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
                            color: Colors.blue.shade100,
                            border: Border.all(color: Colors.grey), // Add a border for the box
                            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
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
                                    Text("Customer Details",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:16,
                                    ),),

                                  ],
                                ),
                              ),
                              Wrap(
                                children: [
                                  SizedBox(width: 20,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      children: [
                                        SizedBox(
                                          width: 220, height: 70,
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
                                          ),
                                        ),SizedBox(width: 55,),

                                        SizedBox(
                                          width: 220,height: 70,
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
                                          ),
                                        ),

                                        SizedBox(width: 55,),

                                        SizedBox(
                                          width: 220,height: 70,
                                          child: TextFormField(
                                            /* readOnly: true,*/
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
                                          ),
                                        ),SizedBox(width: 55,),
                                        SizedBox(
                                          width: 220,height: 70,
                                          child: TextFormField(
                                            /* readOnly: true,*/
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
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                children: [
                                  SizedBox(width: 20,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      children: [
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
                                        SizedBox(width: 53,),



                                        SizedBox(
                                          width: 220,
                                          height:34,
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
                                                });},),),),
                                        SizedBox(width: 1,),

                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 36,left: 54),
                                          child: SizedBox(
                                            width: 220,
                                            height:34,
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
                                                  });},),),),),
                                        SizedBox(width: 55,height: 50,),
                                        SizedBox(width: 221,height: 70,),
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

                              Wrap(
                                children: [
                                  SizedBox(width: 20,),
                                  SingleChildScrollView(
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
                                          9: FixedColumnWidth(120),


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
                                                  const SizedBox(height: 5),
                                                  Text('Rate\nper Unit', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  const SizedBox(height: 5),
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
                                                for (int j = 0; j < 9; j++)
                                                  j==0
                                                  ?TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: TypeAheadFormField<String>(
                                                        textFieldConfiguration: TextFieldConfiguration(
                                                          controller: controllers[i][0], // Adjust this based on your controller for itemGroup
                                                          decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,

                                                          ),
                                                        ),
                                                        suggestionsCallback: (pattern) async {
                                                          List<String> suggestions;
                                                          if (pattern.isNotEmpty) {
                                                            suggestions = itemGroupsSuggestions
                                                                .where((itemGroup) => itemGroup.toLowerCase().startsWith(pattern.toLowerCase()))
                                                                .toList();
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
                                                        onSuggestionSelected: (suggestion) async {
                                                          setState(() {
                                                            controllers[i][0].text = suggestion;                                                   });

                                                          await fetchItemName(suggestion, i);
                                                        },
                                                      ),
                                                    ),
                                                  ):j==1?TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: TypeAheadFormField<String>(
                                                        textFieldConfiguration: TextFieldConfiguration(
                                                          controller: controllers[i][1], // Adjust this based on your controller for itemName
                                                          decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          ),
                                                        ),
                                                        suggestionsCallback: (pattern) {
                                                          return itemNamesSuggestions
                                                              .where((itemName) => itemName.toLowerCase().startsWith(pattern.toLowerCase()))
                                                              .toList();
                                                        },
                                                        itemBuilder: (context, suggestion) {
                                                          return ListTile(
                                                            title: Text(suggestion),
                                                          );
                                                        },
                                                        onSuggestionSelected: (suggestion) {
                                                          setState(() async {
                                                            controllers[i][1].text = suggestion;
                                                            await fetchRateAndUnit(i, controllers[i][0].text, suggestion);

                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                  :TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: TextFormField(
                                                        style: TextStyle(fontSize: 13),
                                                        controller: controllers[i][j],
                                                        decoration: const InputDecoration(
                                                          filled:true,
                                                          fillColor: Colors.white,
                                                        ),
                                                        textAlign: (j >= 0 && j <= 6) ? TextAlign.center : TextAlign.right,
                                                        enabled: j==4 || j==5||j==0||j==1,
                                                        onChanged: (value) {
                                                          double quantity = double.tryParse(controllers[i][4].text) ?? 0.0;
                                                          double unit = double.tryParse(controllers[i][3].text) ?? 0.0;
                                                          double rate = double.tryParse(controllers[i][2].text) ?? 0.0;
                                                          double gst = double.tryParse(int.parse(controllers[i][5].text).toString())??0.0;
                                                          double amount = (quantity * (unit * rate));
                                                          double gstvalue = amount * (int.parse(gst.toString()) / 100);
                                                          double total = amount + gstvalue;
                                                          controllers[i][6].text = amount.toStringAsFixed(2);
                                                          controllers[i][7].text = gstvalue.toStringAsFixed(2);
                                                          controllers[i][8].text = total.toStringAsFixed(2);
                                                          final int rowIndex = i;
                                                          final int colIndex = j;
                                                          final String key = _getKeyForColumn(colIndex);
                                                          rowData[rowIndex][key] = value;
                                                          grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
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
                                  ),
                                ],
                              ),
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

                              if (orderNo.text.isNotEmpty) {

                              } else {
                                print('CustomerName cannot be empty');
                              }
                              if (orderNo.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter Order Number ';
                                });
                              }
                              else if(custCode.text.isEmpty){
                                setState(() {
                                  errorMessage = '* All fields are mandatory';
                                });

                              }else if(custName.text.isEmpty){
                                setState(() {
                                  errorMessage = '* All fields are mandatory';
                                });

                              }else if(custMobile.text.isEmpty){
                                setState(() {
                                  errorMessage = '* All fields are mandatory';
                                });

                              }else if(custAddress.text.isEmpty){
                                setState(() {
                                  errorMessage = '* All fields are mandatory';
                                });

                              }else if(payType ==null){
                                setState(() {
                                  errorMessage = '* Select a Paytype Type';
                                });

                              }
                              else if (gstin.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* GSTIN is mandatory';
                                });

                              }else if (!gstregex2.hasMatch(gstin.text)) {
                                setState(() {
                                  errorMessage = '* Invalid GSTIN';
                                });
                              }
                              else if (deliveryType==null) {
                                setState(() {
                                  errorMessage = '* Select the deliveryType';
                                });}
                              else {
                                List<Map<String, dynamic>> rowsDataToInsert = [];
                                rowsDataToInsert.add(dataToInsert);
                                purchaseReturnItemToDatabase();
                                try {
                                  setState(() {
                                    isDataSaved = true;
                                  });
                                  setState(() {
                                    for(int i= 0; i<controllers.length;i++) {
                                      // updateProduction(controllers[i][0].text, controllers[i][1].text, controllers[i][2].text, controllers[i][3].text, generateId(), int.parse(controllers[i][4].text));
                                      updateStock(controllers[i][0].text, controllers[i][1].text, int.parse(controllers[i][4].text));
                                    }
                                    currentInvoiceNumber++;
                                    isDataSaved = true;
                                  });
                                  saveInvoiceNumber();

                                  // showDialog(
                                  //   barrierDismissible: false,
                                  //   context: context,
                                  //   builder: (BuildContext context) {
                                  //     return AlertDialog(
                                  //       title: Text("Sales"),
                                  //       content: Text("saved successfully."),
                                  //       actions: <Widget>[
                                  //         TextButton(
                                  //           onPressed: () {
                                  //                                            },
                                  //           child: Text("Ok"),
                                  //         ),
                                  //       ],
                                  //     );
                                  //   },
                                  // );

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
                            },
                            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                          ),
                          // if (isDataSaved)
                          // SizedBox(width: 20,),
                          // if (isDataSaved)
                          //   MaterialButton(
                          //     color: Colors.blue.shade600,
                          //     onPressed: () async {
                          //       // Navigate to the PDF screen when pressed
                          //
                          //       // clearAllRows();
                          //       // orderNo.clear();
                          //       // custCode.clear();
                          //       // custName.clear();
                          //       // custMobile.clear();
                          //       // custAddress.clear();
                          //       // grandTotal.clear();
                          //     },
                          //     child: const Text("Generate PDF",
                          //         style: TextStyle(color: Colors.white)),
                          //   ),
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
                                              MaterialPageRoute(builder: (context) =>const OldEntrySales()));// Close the alert box
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
        ), backgroundColor: Colors.white, );
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
      return 'amtGST';
    case 8:
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



