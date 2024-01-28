
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinayaga_project/main.dart';
import 'package:vinayaga_project/purchase/po_entry_pdf.dart';
import 'package:vinayaga_project/purchase/po_pdf.dart';
import '../home.dart';
import 'package:http/http.dart' as http;

class PoCreation extends StatefulWidget {
  const PoCreation({Key? key}) : super(key: key);
  @override
  State<PoCreation> createState() => _PoCreationState();
}
class _PoCreationState extends State<PoCreation> {
  FocusNode supMobileFocusNode = FocusNode();
  FocusNode pincodeFocusNode = FocusNode();

  DateTime date = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  // DateTime deliverydate = DateTime.now();
  List<List<TextEditingController>> controllers = [];
  // List<List<FocusNode>> focusNodes = [];
  List<Map<String, dynamic>> rowData = [];
  List<bool> isRowFilled = [false];
  bool itemGroupExists = false;
  // String? deliveryType;
  bool dropdownValid = true;
  //bool itemGroupExists = false;
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  Map<String, dynamic> dataToInsert = {};
  bool readOnlyFields = false;
  final FocusNode supNameFocusNode = FocusNode();
  get row => null;
  String? errorMessage="";
  String selectedCustomer=" ";

  String suppliercode = '';
  String suppliername ='';
  String supplieraddress = '';
  String suppliermobile = '';
  String supplierpono = '';






  bool dropdownValid1 = true;

  void addRow() {
    setState(() {
      List<TextEditingController> rowControllers = [];
      List<FocusNode> rowFocusNodes = [];

      for (int j = 0; j < 4; j++) {
        rowControllers.add(TextEditingController());
        rowFocusNodes.add(FocusNode());
      }

      controllers.add(rowControllers);
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




  bool isDataValid() {
    for (int i = 0; i < rowData.length; i++) {
      if (rowData[i]['prodCode'].isEmpty ||
          rowData[i]['prodName'].isEmpty ||
          rowData[i]['unit'].isEmpty ||
          rowData[i]['qty'].isEmpty) {
        return false;
      }
    }
    return true;
  }


  void updateFieldValidation() {
    bool allValid = true;
    for (var i = 0; i < controllers.length; i++) {
      for (var j = 0; j < 4; j++) {
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
  void removeRow(int rowIndex) {
    // Assuming controllers is a List<List<TextEditingController>> representing your text controllers
    setState(() {
      controllers.removeAt(rowIndex); // Remove the controllers for the row
      rowData.removeAt(rowIndex); // Remove the data for the row
    });
  }
/*
  void removeRow(int index) {
    setState(() {
      for (var controller in controllers[index]) {
        controller.dispose();
      }
      if (index >= 0 && index < controllers.length) {
        controllers.removeAt(index);
        //focusNodes.removeAt(index);
        isRowFilled.removeAt(index);
        rowData.removeAt(index);
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
  // ("Purchase order report PDF")
  @override
  void dispose() {
    for (var rowControllers in controllers) {
      for (var controller in rowControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  TextEditingController supName =TextEditingController();
  TextEditingController supCode =TextEditingController();
  TextEditingController supMobile=TextEditingController();
  TextEditingController supAddress=TextEditingController();
  TextEditingController prodCode=TextEditingController();
  TextEditingController prodName=TextEditingController();
  TextEditingController qty=TextEditingController();
  TextEditingController deliveryDate=TextEditingController();
  TextEditingController pincode=TextEditingController();
  DateTime eod = DateTime.now();

/*
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
*/
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Map<String, dynamic> dataToInsertSupplier1 = {};
  Map<String, dynamic> dataToInsertSupItem1 = {};
  Map<String, dynamic> dataToInsertSup = {};

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
  Future<bool> checkForDuplicate(String size) async {
    List<dynamic> sizeData = await fetchSizeData();
    for (var item in sizeData) {
      if (item['supCode'] == size) {
        return true; // Size already exists, return true
      }
    }
    return false; // Size is unique, return false
  }




  Future<void> insertDataSupItem1(Map<String, dynamic> dataToInsertSupItem1) async {
    const String apiUrl = 'http://localhost:3309/po_items'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertSupItem1': dataToInsertSupItem1}),
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
  Future<void> submitItem() async {
    String purchaseDateString = deliveryDate.text;
    String formattedDeliveryDate = deliveryDate.text ?? ''; // Provide a default value if null

    // Check if deliveryDate is null, and set a default value if needed
    DateTime purchaseDateTime;
    if (purchaseDateString != null && purchaseDateString.isNotEmpty) {
      purchaseDateTime = DateFormat('dd-MM-yyyy').parse(purchaseDateString);
    } else {
      // Set a default date or handle it according to your requirements
      purchaseDateTime = DateTime.now();
    }

    DateTime now = DateTime.now();
    String year = (now.year % 100).toString();
    String month = now.month.toString().padLeft(2, '0');

    List<Future<void>> insertFutures = [];
    if (poNumber.isEmpty) {
      poNumber = 'PO$year$month/001';
    }
    for (var i = 0; i < controllers.length; i++) {
      Map<String, dynamic> dataToInsertSupItem1 = {
        'poNo':poNumber,
        'supName': supName.text,
        'supCode': supCode.text,
        'deliveryDate': formattedDeliveryDate,
        'prodCode': controllers[i][0].text,
        'prodName': controllers[i][1].text,
        'qty': controllers[i][3].text,
        'date': eod.toString(),
        'unit': controllers[i][2].text,
        // Use deliveryDate.text instead of deliveryDate
      };
      insertFutures.add(insertDataSupItem1(dataToInsertSupItem1)); // Await here
    }

    try {
      await Future.wait(insertFutures);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('PO'),
            content: Text('Saved Successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PoCreation()),
                  );
                },
                child: Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  // Retrieve values from text form fields
                  String supplierName = supName.text;
                  String supplierCode = supCode.text;
                  //String? deliverytype = deliveryType;
                  String? deliverydate = deliveryDate.toString();
                  String? date = eod.toString();
                  String PoNo = generateId();
                  print('Customer Name: $supplierName');
                  print('Customer Mobile: $supplierCode');
                  print('Customer Address: $supplieraddress');
                  print('Quotation Number: $PoNo');
                  print('Current Date: $date');
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoentryPDF(
                        poNo: generateId(),
                        supCode: supplierCode,
                        supName: supName.text,
                        // deliveryType: deliverytype, // replace "" with a default value if necessary
                        deliveryDate: deliveryDate.text,
                        date: date,
                        supMobile: supMobile.text,
                        supAddress: supAddress.text,
                        //date: date,
                      ),
                    ),
                  );
                  //   Navigator.push(context, MaterialPageRoute(builder: (context)=> QuotationEntry()));
                },
                child: Text('PRINT'),
              ),

            ],
          );
        },
      );// Await for all insertions to complete
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }
  bool isDuplicateProductCode(String productCode, int currentRowIndex) {
    for (int i = 0; i < controllers.length; i++) {
      if (i != currentRowIndex &&
          controllers[i][0].text == productCode ) {
        return true;
      }
    }
    return false;
  }
  bool isDuplicateProductName(String productName, int currentRowIndex) {
    for (int i = 0; i < controllers.length; i++) {
      if (i != currentRowIndex &&
          controllers[i][1].text == productName ) {
        return true;
      }
    }
    return false;
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

  void filterData(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = data;
        readOnlyFields = false;
        supCode.clear();
        supAddress.clear();
        pincode.clear();
        supMobile.clear();
      } else {
        final existingSupplier = data.firstWhere(
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
          for (var item in data) {
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
  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/fetch_supplier/');
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


  int currentPoNumber = 1;
  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['poNo'];
  }
  String poNumber = "";
  String? poNo;
  List<Map<String, dynamic>> ponumdata = [];
  String? PONO;
  List<Map<String, dynamic>> codedata = [];
  String generateId() {
    DateTime now=DateTime.now();
    String year=(now.year%100).toString();
    String month=now.month.toString().padLeft(2,'0');

    if (PONO != null) {
      String ID = PONO!.substring(7);
      int idInt = int.parse(ID) + 1;
      String id = 'PO$year$month/${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ponumfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_poNo'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          PONO = getNameFromJsonData(item);
          print('poNo: $PONO');
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
  bool validateTableFields() {
    for (var i = 0; i < controllers.length; i++) {
      for (var j = 0; j < 4; j++) {
        if (controllers[i][j].text.isEmpty) {
          return true;
        }
      }
    }
    return false;
  }
  Set<String> selectedProducts = Set();
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
  final FocusNode _suppliernameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_suppliernameFocusNode);
    });
    fetchData();
    ponumfetch();
    addRow();
    supNameFocusNode.requestFocus();
  }
  bool isDataSaved = false;

  int currentOrderNumber = 1;
  bool checkName = false;


  @override
  Widget build(BuildContext context) {
    DateTime Date = DateTime.now();
    final formattedDate = DateFormat("dd-MM-yyyy").format(Date);
    supName.addListener(() {
      filterData(supName.text);
    });

    return MyScaffold(
        route: "po_creation",backgroundColor: Colors.black,
        body:  Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                  children: [
                    // Text("PO Creation",style:Theme.of(context).textTheme.displayLarge),
                    SizedBox(height: 15,),
                    SizedBox(
                      //width: 800,
                      height: 120,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.local_grocery_store, size:30),
                                          Text("Purchase Order",style: TextStyle(fontSize:22,fontWeight: FontWeight.bold),),
                                        ]
                                    ),
                                    Container(
                                      width: 100,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child:SizedBox(
                                                  child: TextFormField(
                                                    style: TextStyle(fontSize: 13),
                                                    readOnly: true,
                                                    onTap: () {
                                                      showDatePicker(
                                                        context: context,
                                                        initialDate: eod,
                                                        firstDate: DateTime(1950),
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
                                                /*Text(
                                                  formattedDate,
                                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                ),*/
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "PO Number",
                                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              /*  poNumber.isEmpty ?
                                          Align(
                                            alignment: Alignment.topLeft,
                                            alignment: Alignment.topLeft,
                                            child: Text("PO000"),
                                          ):*/
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(poNumber.isEmpty ? "PO${DateTime.now().year % 100}${DateTime.now().month.toString().padLeft(2, '0')}/001" : poNumber),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ]
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2,),
                    SizedBox(
                      // width: 800,
                      //height: 400,
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
                          child:Padding(
                            padding: const EdgeInsets.only(left:10),
                            child: Wrap(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 13),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Text("Supplier Details",style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:const EdgeInsets.only(left: 0),
                                    child: Wrap(
                                      spacing: 35,
                                      children: [
                                        SizedBox(
                                          width: 220,height: 70,
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
                                        ),SizedBox(width: 32,),

                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 36),
                                          child:SizedBox(
                                            width: 220,
                                            height:50,
                                            child: TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: supName,
                                                focusNode: _suppliernameFocusNode,
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
                                                List<String> suggestions = data
                                                    .where((item) =>
                                                (item['supName']?.toString()?.toLowerCase() ?? '').contains(pattern.toLowerCase()) ||
                                                    (item['supCode']?.toString()?.toLowerCase() ?? '').contains(pattern.toLowerCase()))
                                                    .map((item) => item['supName'].toString())
                                                    .toSet()
                                                    .toList();
                                                return suggestions;
                                              },
                                              itemBuilder: (context, suggestion) {
                                                Map<String, dynamic> customerData = data.firstWhere(
                                                      (item) => item['supName'].toString() == suggestion,
                                                  orElse: () => Map<String, dynamic>(),
                                                );
                                                return ListTile(
                                                  title: Text('${customerData['supName']} (${customerData['supCode']})'),
                                                );
                                              },
                                              onSuggestionSelected: (suggestion) {
                                                Map<String, dynamic> customerData = data.firstWhere(
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
                                        SizedBox(width: 32,),
                                        SizedBox(
                                          width: 220,height: 70,
                                          child: TextFormField(
                                            readOnly: readOnlyFields,
                                            controller: supAddress,
                                            style: TextStyle(fontSize: 13),
                                            onChanged: (value) {
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              supAddress.value = supAddress.value.copyWith(
                                                text: capitalizedValue,
                                                selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                              );
                                              setState(() {
                                                errorMessage=null;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              labelText: "Supplier Address",
                                              filled: true,
                                              fillColor: Colors.white,
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
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Wrap(
                                      spacing: 35,
                                      children: [
                                        SizedBox(
                                          width: 220,height: 70,
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
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(6),
                                              FilteringTextInputFormatter.digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                              labelText: "Pincode",
                                              hintText: "Pincode",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 32,),
                                        SizedBox(
                                          width: 220, height: 70,
                                          child: TextFormField(
                                            focusNode: supMobileFocusNode,
                                            readOnly: readOnlyFields,
                                            controller: supMobile, style: TextStyle(fontSize: 13),
                                            onChanged: (value){
                                              setState(() {
                                                errorMessage = null;
                                                if (value.isEmpty) {
                                                  errorMessage = null;
                                                }
                                                if (value.length == 10) {
                                                } else {
                                                  // Update error message when the mobile number is not valid
                                                  errorMessage = '* Mobile number should be 10 digits';
                                                }// Reset error message when user types
                                              });
                                            },
                                            decoration: InputDecoration(
                                              prefixText: "+91 ",
                                              labelText: "Supplier Mobile",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(10)
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 32,),
                                        SizedBox(
                                          width: 220,
                                          height: 70,
                                          child: TextFormField(style: TextStyle(fontSize: 13),
                                            readOnly: true, // Set the field as read-only
                                            onTap: () async {
                                              DateTime? pickDate = await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime(
                                                      2100));
                                              if (pickDate == null)
                                                return;
                                              {
                                                setState(() {
                                                  deliveryDate.text = pickDate != null
                                                      ? DateFormat('dd-MM-yyyy').format(pickDate)
                                                      : ''; // Provide a default value if null
                                                });
                                              }
                                              // setState(() {
                                              //   errorMessage = null; // Reset error message when user types
                                              // });
                                            },
                                            controller: deliveryDate, // Set the initial value of the field to the selected date
                                            decoration: InputDecoration(
                                              labelText: "Expected Delivery Date",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),SizedBox(width: 32,),
                                      ],
                                    ),
                                  ),
                                  Padding (
                                    padding: EdgeInsets.only(bottom: 12,left: 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text("Product Details",style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Table(
                                      border: TableBorder.all(color: Colors.black54),
                                      columnWidths: const <int, TableColumnWidth>{
                                        0: FixedColumnWidth(292),
                                        1: FixedColumnWidth(292),
                                        2: FixedColumnWidth(200),
                                        3: FixedColumnWidth(150),
                                      },
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children: [
                                        // Table header row
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade100,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 8),
                                                      Text('Product Code', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 8),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade100,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 8),
                                                    Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 8),
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
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 8),
                                                    Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 8),
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
                                        for (var i = 0; i < controllers.length; i++)
                                          TableRow(
                                            children: [
                                              for (var j = 0; j < 4; j++)
                                                TableCell(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: j == 3
                                                        ? TextFormField(
                                                      style: TextStyle(fontSize: 13),
                                                      controller: controllers[i][j],
                                                      inputFormatters: [
                                                        NumericTextFormatter(), // Apply the custom formatter for numeric input only to the qty controller
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
                                                      controller: controllers[i][j],
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
                                                        : TypeAheadFormField<String>(
                                                        textFieldConfiguration: TextFieldConfiguration(
                                                          controller: controllers[i][j],
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
                                                            final prodCode = controllers[rowIndex][0].text;
                                                            final prodName = controllers[rowIndex][1].text;
                                                            final unit = await fetchUnitInPO(prodCode, prodName);

                                                            // Update the unit controller
                                                            controllers[rowIndex][2].text = unit;
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

                                                            if (controllers.any((row) => row[0].text == productCode && row != controllers[rowIndex])) {
                                                              showWarningMessage('Product with code $productCode already selected in another row!');
                                                              setState(() {
                                                                controllers[rowIndex][0].text = ''; // Clear the product code
                                                                controllers[rowIndex][1].text = ''; // Clear the product code
                                                              });
                                                            } else {
                                                              if (selectedProducts.isNotEmpty) {
                                                                final previousProductName = selectedProducts.last.split('-').last;

                                                                if ((previousProductName.startsWith('GSM') && !productName!.startsWith('GSM')) ||
                                                                    (!previousProductName.startsWith('GSM') && productName!.startsWith('GSM'))) {
                                                                  showWarningMessage('Product name mismatched Please check!');
                                                                  setState(() {
                                                                    controllers[rowIndex][0].text = '';
                                                                    controllers[rowIndex][1].text = '';
                                                                    // Clear the product code
                                                                  });
                                                                  return;
                                                                }
                                                              }

                                                              selectedProducts.add(selectedProductKey);
                                                              setState(() {
                                                                controllers[rowIndex][0].text = productCode!;
                                                                controllers[rowIndex][1].text = productName!;
                                                              });

                                                              // Fetch unit based on prodCode and prodName
                                                              final unit = await fetchUnitInPO(productCode!, productName!);

                                                              controllers[rowIndex][2].text = unit;
                                                            }
                                                          }
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
                                                                      if (controllers.length == 1) {
                                                                        // If there is only one row, clear the data instead of removing the row
                                                                        clearAllRows();
                                                                        Navigator.of(context).pop();
                                                                      } else {
                                                                        // If there are multiple rows, remove the entire row
                                                                        removeRow(i);
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
                                                        visible: i == controllers.length - 1,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [

                                                            IconButton(
                                                              icon: Icon(Icons.add_circle_outline, color: Colors.green),
                                                              onPressed: () {

                                                                if (controllers[i][0].text.isNotEmpty && controllers[i][1].text.isNotEmpty && controllers[i][2].text.isNotEmpty && controllers[i][3].text.isNotEmpty) {
                                                                  addRow();
                                                                } else {
                                                                  showWarningMessage(' Fields cannot be empty!');
                                                                }


                                                              },
                                                            )

                                                            // IconButton(
                                                            //   icon: Icon(Icons.add_circle_outline, color: Colors.green),
                                                            //   onPressed: () {
                                                            //     addRow();
                                                            //   },
                                                            // ),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child:Text(
                                          errorMessage ?? '',
                                          style: TextStyle(color: Colors.red,fontSize: 15),
                                        ),
                                      ),

                                    ],
                                  ),


/*
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Table(
                                      border: TableBorder.all(
                                          color: Colors.black54
                                      ),

                                     // defaultColumnWidth: const FixedColumnWidth(140.0),
                                      columnWidths: const <int, TableColumnWidth>{
                                        0: FixedColumnWidth(292),
                                        1: FixedColumnWidth(292),
                                        2: FixedColumnWidth(200),
                                        3: FixedColumnWidth(150),

                                      },
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children: [
                                        // Table header row
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Container(
                                                color:Colors.blue.shade100,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 8),
                                                      Text('Product Code',style: TextStyle(fontWeight: FontWeight.bold),),
                                                      const SizedBox(height: 8),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade100,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 8),
                                                    Text('Product Name',style: TextStyle(fontWeight: FontWeight.bold),),
                                                    const SizedBox(height: 8),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade100,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 8),
                                                    Text('Unit',style: TextStyle(fontWeight: FontWeight.bold),),
                                                    const SizedBox(height: 8),
                                                  ],
                                                ),


                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade100,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 8),
                                                    Text('Quantity',style: TextStyle(fontWeight: FontWeight.bold),),
                                                    const SizedBox(height: 8),
                                                  ],
                                                ),


                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                color: Colors.blue.shade100,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 8),
                                                    Text('Action',style: TextStyle(fontWeight: FontWeight.bold),),
                                                    const SizedBox(height: 8),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Table data rows
                                        for (var i = 0; i < controllers.length; i++)
                                          TableRow(
                                            children: [
                                              for (var j = 0; j < 4; j++)
                                                TableCell(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: j == 3
                                                        ? TextFormField(
                                                      style: TextStyle(fontSize: 13),
                                                      controller: controllers[i][j],
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
                                                        : TypeAheadFormField<String>(
                                                      textFieldConfiguration: TextFieldConfiguration(
                                                        controller: controllers[i][j],
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
                                                      onSuggestionSelected: (suggestion) async {
                                                        // Handle selection of a suggestion
                                                        final int rowIndex = i;
                                                        final int colIndex = j;
                                                        final String key = _getKeyForColumn(colIndex);
                                                        final productName = suggestion.split('-')[1].trim();

                                                        if (key == 'prodCode') {
                                                          final productCode = suggestion.split('-')[0].trim();
                                                          setState(() {
                                                            controllers[rowIndex][0].text = productCode;
                                                            controllers[rowIndex][1].text = productName;
                                                          });
                                                        } else if (key == 'prodName') {
                                                          final productCode = await fetchProductCode(productName);
                                                          setState(() {
                                                            controllers[rowIndex][0].text = productCode;
                                                            controllers[rowIndex][1].text = productName;
                                                          });
                                                        }
                                                      },
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
                                                  visible: i == controllers.length - 1,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.add_circle_outline, color: Colors.green),
                                                        onPressed: () {
                                                          addRow();
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              */
/* TableCell(
                                                child:

                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      if (controllers.length ==controllers.length && i != controllers.length - 1)
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
                                                    // if (controllers.length ==controllers.length && i != controllers.length - 1)
                                                      IconButton(
                                                        icon: Icon(Icons.add_circle_outline, color: Colors.green),
                                                        onPressed: () {
                                                          addRow();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            ),*//*

                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
*/
                                ]
                            ),
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
                              bool areTableFieldsEmpty = validateTableFields();
                              String enteredSupCode = supCode.text;
                              bool isDuplicate = await checkForDuplicate(
                                  enteredSupCode);
                              //validateDropdown();

                              if (supName.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Supplier/Company Name';
                                });
                              }
                              else if (supAddress.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Supplier Address';
                                });
                              }
                              else if (pincode.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Supplier pincode';
                                });
                              }
                              else if (pincode.text.length != 6) {
                                setState(() {
                                  errorMessage = '* Enter a valid pincode';
                                });
                                FocusScope.of(context).requestFocus(pincodeFocusNode);
                                return;
                              }
                              else if (supMobile.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Supplier Mobile';
                                });
                                FocusScope.of(context).requestFocus(supMobileFocusNode);
                                return;
                              }
                              else if (supMobile.text.length != 10) {
                                setState(() {
                                  errorMessage = '* Mobile number should be 10 digits';
                                });
                              }
                              // else if (deliveryDate.text.isEmpty) {
                              //   setState(() {
                              //     errorMessage = '* Select a Expected Delivery Date';
                              //   });
                              //   return;
                              // }
                              else if (areTableFieldsEmpty) {
                                setState(() {
                                  errorMessage = '* Fill all fields in the table';
                                });
                              }
                              else {
                                setState(() {
                                  errorMessage = ''; // Clear the error message
                                });
                                if (_formKey.currentState!.validate()){// &&
                                  /* supName.text.isNotEmpty &&
                                  supMobile.text.isNotEmpty &&
                                  supAddress.text.isNotEmpty &&
                                  deliveryDate.text.isNotEmpty &&
                                  deliveryType != null &&*/
                                  // !controllers.any((controller) =>
                                  // controller[0].text.isEmpty ||
                                  //     controller[1].text.isEmpty ||
                                  //     controller[2].text.isEmpty)) {
                                  //  for (var i = 0; i < controllers.length; i++) {
                                  List<Map<String,
                                      dynamic>> rowsDataToInsert = [];
                                  rowsDataToInsert.add(dataToInsert);
                                  try {
                                    if (isDuplicate) {
                                      submitItem();
                                    } else {
                                      supDataToDatabase();
                                      submitItem();
                                    }
                                    setState(() {
                                      currentPoNumber++;
                                      isDataSaved = true;
                                    });
                                    setState(() {
                                      //  deliveryType = null;
                                    });
                                    //clearAllRows();
                                  }
                                  catch (e) {
                                    print('Error inserting data: $e');
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Failed to save data. Please try again."),
                                      ),
                                    );
                                  }
                                  //}
                                } else {
                                  setState(() {
                                    errorMessage =
                                    '* Fill all fields in the table';
                                  });
                                }
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
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> PoCreation()));
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
                              );                            },
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
                            child: Text("CANCEL",style: TextStyle(color: Colors.white),),)
                        ],
                      ),
                    ),

                  ]),
            ),
          ),
        )
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
    default:
      return '';
  }
}

class NumericTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only numeric input
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
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

