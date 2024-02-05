
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

import 'machine_entry.dart';

class Raw_material extends StatefulWidget {
  const Raw_material({Key? key}) : super(key: key);
  @override
  State<Raw_material> createState() => _Raw_materialState();
}
class _Raw_materialState extends State<Raw_material> {
  List<String> supplierSuggestions = [];
  String selectedSupplier = "";
  FocusNode supMobileFocusNode = FocusNode();
  FocusNode pincodeFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController();

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
  List<Map<String, dynamic>> data1 = [];
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
      Uri.parse('http://localhost:3309/Raw_materil_ProductName'),
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
      Uri.parse('http://localhost:3309/Raw_materil_ProductCode'),
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
      Uri.parse('http://localhost:3309/Raw_materil_UnitInPO'),
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


  Future<String> fetchqty(String prodCode, String prodName) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/Raw_materil_Qty'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prodCode': prodCode, 'prodName': prodName}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['qty'].toString(); // Convert to String if needed
    } else {
      throw Exception('Failed to fetch QTY from Raw_material');
    }
  }


  Future<List<String>> fetchSuggestions(String pattern) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/fetch_Raw_materil_Suggestions'), // Replace with your actual endpoint
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

  List<String> itemGroupValues = [];

  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_Raw_Material/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          data = itemGroups.cast<Map<String, dynamic>>();
          filteredData = List<Map<String, dynamic>>.from(data);
          filteredData.sort((a, b) {
            DateTime? dateA = DateTime.tryParse(a['date'] ?? '');
            DateTime? dateB = DateTime.tryParse(b['date'] ?? '');
            if (dateA == null || dateB == null) {
              return 0;
            }
            return dateB.compareTo(dateA);
          });
        });

        print('Data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void filterData(String searchText) {
    print("Search Text: $searchText");
    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all data without filtering by supplier name
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        filteredData = data.where((item) {
          String supName = item['prodName']?.toString()?.toLowerCase() ?? '';
          String prodCode = item['prodCode']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();

          return supName.contains(searchTextLowerCase) ||
              prodCode.contains(searchTextLowerCase);

        }).toList();
      }

      // Sort filteredData in descending order based on the "date" field
      filteredData.sort((a, b) {
        DateTime? dateA = DateTime.tryParse(a['date'] ?? '');
        DateTime? dateB = DateTime.tryParse(b['date'] ?? '');

        if (dateA == null || dateB == null) {
          return 0;
        }

        return dateB.compareTo(dateA);
      });
    });
    print("Filtered Data Length: ${filteredData.length}");
  }
  void applyDateFilter() {
    setState(() {

      if (searchController.text.isNotEmpty) {
        String searchTextLowerCase = searchController.text.toLowerCase();
        filteredData = filteredData.where((item) {
          String supName = item['prodName']?.toString()?.toLowerCase() ?? '';
          String prodCode = item['prodCode']?.toString()?.toLowerCase() ?? '';

          return supName.contains(searchTextLowerCase) ||
              prodCode.contains(searchTextLowerCase);
        }).toList();
      }
      filteredData.sort((a, b) {
        DateTime? dateA = DateTime.tryParse(a['date'] ?? '');
        DateTime? dateB = DateTime.tryParse(b['date'] ?? '');
        if (dateA == null || dateB == null) {
          return 0;
        }
        return dateB.compareTo(dateA); // Compare in descending order
      });
    });
  }


  @override
  void initState() {
    super.initState();
    fetchData();
    ponumfetch();
    addRow();
    supNameFocusNode.requestFocus();
  }
  bool isDataSaved = false;

  int currentOrderNumber = 1;
  bool checkName = false;

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
        'qty': qty,
        "modifyDate":date.toString(),
      }),
    );
    if (response.statusCode == 200) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Raw Metirial'),
            content: Text('Update Successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Raw_material()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      print('Update successful');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
      throw Exception('Failed to update');
    }
  }

  Future<void> rawmetrialupdate() async {
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers.length; i++) {
      updateRawMaterial(controllers[i][0].text,
        controllers[i][1].text,
        controllers[i][2].text,
        int.parse(controllers[i][3].text),
        date.toString(),
      );
    }

    try {
      await Future.wait(insertFutures); // Await for all insertions to complete
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }


  String? rawmatirealqty;

  Future<void> withprintingValueGet(String selectedGSM) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/fetch_with_Qty'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'qty': selectedGSM}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("data of raw material- $data");
      setState(() {
        rawmatirealqty = data['qty'];
        print("{{{{$rawmatirealqty}}}");
      });
    } else {
      // Handle errors
      print('Error fetching data from server: ${response.statusCode}');
    }
  }


  Future<void> insertDataSupItem1(Map<String, dynamic> dataToInsertSupItem1) async {
    const String apiUrl = 'http://localhost:3309/rawmeterial_entry'; // Replace with your server details
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
    List<Future<void>> insertFutures = [];
    for (var i = 0; i < controllers.length; i++) {
      Map<String, dynamic> dataToInsertSupItem1 = {
        "date":eod.toString(),
        'prodCode': controllers[i][0].text,
        'prodName': controllers[i][1].text,
        'unit':controllers[i][2].text,
        'qty': controllers[i][3].text,
      };
      insertFutures.add(insertDataSupItem1(dataToInsertSupItem1)); // Await here
    }
    try {
      await Future.wait(insertFutures); // Await for all insertions to complete
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    DateTime Date = DateTime.now();
    final formattedDate = DateFormat("dd-MM-yyyy").format(Date);
    searchController.addListener(() {
      filterData(searchController.text);
    });
    return MyScaffold(
        route: "raw_material_entry",backgroundColor: Colors.white,
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
                      //height: 120,
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
                          child:  Wrap(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.local_grocery_store, size:30),
                                          Text("Raw Material",style: TextStyle(fontSize:22,fontWeight: FontWeight.bold),),
                                          IconButton(
                                            icon: Icon(Icons.refresh),
                                            onPressed: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Raw_material()));
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.arrow_back),
                                            onPressed: () {
                                              // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalaryCalculation()));
                                              Navigator.pop(context);
                                            },
                                          ),
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
                                                        firstDate: DateTime(2000),
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
                                        0: FixedColumnWidth(250),
                                        1: FixedColumnWidth(250),
                                        2: FixedColumnWidth(150),
                                        3: FixedColumnWidth(150),
                                        4: FixedColumnWidth(150),
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
                                                        NumericTextFormatter(),
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
                                                          errorMessage = ''; // Clear the error message when the user types in the table
                                                        });

                                                        // Add a condition to check if the value is greater than the fetched quantity
                                                        final double enteredValue = double.tryParse(value) ?? 0.0;
                                                        final String prodCode = controllers[rowIndex][0].text;
                                                        final String prodName = controllers[rowIndex][1].text;
                                                        final String fetchedQty = await fetchqty(prodCode, prodName);
                                                        final double fetchedValue = double.tryParse(fetchedQty) ?? 0.0;

                                                        if (enteredValue > fetchedValue) {
                                                          // Show an alert message here
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: Text('Alert'),
                                                                content: Text('The entered value is greater than the fetched quantity: $fetchedQty.'),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                      // Update the value in j==3 field with the fetched quantity
                                                                      controllers[rowIndex][j].text = fetchedQty;
                                                                    },
                                                                    child: Text('OK'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      },
                                                    ) : j == 2
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
                                                        final String key = _getKeyForColumn(colIndex);                                                        updateFieldValidation();
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
                                                            final qty = await fetchqty(prodCode!, prodName!);
                                                            print(qty);
                                                            // Update the unit controller
                                                            controllers[rowIndex][2].text = unit;
                                                            controllers[rowIndex][2].text = qty;
                                                            setState(() {
                                                              rowData[rowIndex][key] = value;
                                                              errorMessage = ''; // Clear the error message when the user types in the table
                                                            });
                                                          },
                                                        ),
                                                        suggestionsCallback: (pattern) async {
                                                          List<String> suggestions = await fetchSuggestions(pattern);
                                                          // Filter out suggestions that start with "GSM" in prodCode or prodName
                                                          suggestions = suggestions.where((suggestion) {
                                                            final match = RegExp(r'^(.+?) - (.+)$').firstMatch(suggestion);
                                                            final productCode = match?.group(1)?.trim() ?? '';
                                                            final productName = match?.group(2)?.trim() ?? '';
                                                            return !productCode.startsWith('GSM') && !productName.startsWith('GSM');
                                                          }).toList();
                                                          return suggestions;
                                                        },
                                                        itemBuilder: (context, suggestion) {
                                                          return ListTile(
                                                            title: Text(suggestion),
                                                          );
                                                        },
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
                                                              });
                                                            } else {
                                                              selectedProducts.add(selectedProductKey);
                                                              setState(() {
                                                                controllers[rowIndex][0].text = productCode!;
                                                                controllers[rowIndex][1].text = productName!;
                                                              });
                                                              // Fetch unit based on prodCode and prodName
                                                              final unit = await fetchUnitInPO(productCode!, productName!);
                                                              final qty = await fetchqty(productCode!, productName!); // Await the result
                                                              controllers[rowIndex][2].text = unit;
                                                              controllers[rowIndex][3].text = qty; // Set the qty
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
                              //validateDropdown();\
                              if (areTableFieldsEmpty) {
                                setState(() {
                                  errorMessage = '* Fill all fields in the table';
                                });
                              }
                              else {
                                setState(() {
                                  errorMessage = ''; // Clear the error message
                                });
                                if (_formKey.currentState!.validate()){// &&
                                  try {
                                    for (var i = 0; i < controllers.length; i++) {
                                      updateRawMaterial(controllers[i][0].text,
                                        controllers[i][1].text,
                                        controllers[i][2].text,
                                        int.parse(controllers[i][3].text),
                                        date.toString(),
                                      );
                                    }
                                    setState(() {
                                      submitItem();
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
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Raw_material()));
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
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Align(
                                  alignment:Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top:20 , left:5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 220,
                                          height: 50,
                                          child:
                                          TypeAheadFormField<String>(
                                            textFieldConfiguration: TextFieldConfiguration(
                                              controller: searchController,

                                              style: const TextStyle(fontSize: 13),
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(Icons.search),
                                                fillColor: Colors.white,
                                                filled: true,
                                                labelText: "Search",
                                                labelStyle: TextStyle(fontSize: 13),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                            suggestionsCallback: (pattern) async {
                                              if (pattern.isEmpty) {
                                                return [];
                                              }
                                              List<String> prodNamesuggestions =data
                                                  .where((item) =>
                                                  (item['prodName']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['prodName'].toString())
                                                  .toSet() // Remove duplicates using a Set
                                                  .toList();
                                              List<String> prodCodesuggestions =data
                                                  .where((item) =>
                                                  (item['prodCode']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['prodCode'].toString())
                                                  .toSet() // Remove duplicates using a Set
                                                  .toList();
                                              List<String>suggestions =[
                                                ...prodNamesuggestions,
                                                ...prodCodesuggestions
                                              ].toSet() // Remove duplicates using a Set
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
                                                searchController.text = suggestion;
                                              });
                                              print('Selected Customer: $selectedCustomer');
                                            },
                                          ),
                                        ),
                                        if (supplierSuggestions.isNotEmpty)
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: supplierSuggestions.length,
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  title: Text(supplierSuggestions[index]),
                                                  onTap: () {
                                                    setState(() {
                                                      selectedSupplier = supplierSuggestions[index];
                                                      searchController.text = selectedSupplier;
                                                      filteredData;
                                                    });},);},),),],),),
                                ),
                                filteredData.isEmpty? Text("No Data Available",style: (TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),):
                                PaginatedDataTable(
                                  columnSpacing:80.0,
                                  rowsPerPage:25,
                                  columns:   const [
                                    DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("    Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Product Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("            Product Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    //DataColumn(label: Center(child: Text("Weight",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Total Weight",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Available Quantity",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Modify Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  ], source: _YourDataTableSource(filteredData,context,generatedButton),
                                ),],),),),),),

                  ]),
            ),
          ),
        )
    );
  }
}

class _YourDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  final bool generatedButton;

  _YourDataTableSource(this.data,this.context, this.generatedButton);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }

    final row = data[index];

    return DataRow(
      cells: [
        DataCell(Center(child: Text("${index + 1}"))),
        DataCell(Center(
          child: Text(
            row["date"] != null
                ? DateFormat('dd-MM-yyyy').format(
              DateTime.parse("${row["date"]}").toLocal(),
            )
                : "",
          ),
        )),
        DataCell(Center(child: Text("${row["prodCode"]}"))),
        DataCell(Center(child: Text("${row["prodName"]}"))),
        //  DataCell(Center(child: Text("${row["supName"]}"))),
        // DataCell(Center(child: Text("${row["custMobile"]}"))),
        //DataCell(Center(child: Text(row["weight"] != null ? "${row["weight"]}" : "-"))),
        DataCell(Center(child: Text(row["totalweight"] != null ? "${row["totalweight"]}" : "-"))),
        DataCell(Center(child: Text("${row["qty"]}"))),
        DataCell(Center(
          child: Text(
            row["modifyDate"] != null
                ? DateFormat('dd-MM-yyyy').format(
              DateTime.parse("${row["modifyDate"]}").toLocal(),
            )
                : "",
          ),
        )),
      ],
    );
  }
  @override
  int get rowCount => data.length;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
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

