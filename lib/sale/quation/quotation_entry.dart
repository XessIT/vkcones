import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart'as http;
import 'package:vinayaga_project/sale/quation/quotation_entry_pdf.dart';
import '../../home.dart';
import '../../purchase/customer_order_edit.dart';

class RowData {
  String? itemGroup;
  String? itemName;

  List<String> itemNames = [];
  List<String> itemSizes = [];
  List<String> itemColors = [];
  int? quantity;

  TextEditingController qtyController = TextEditingController();
  TextEditingController totalQtyController = TextEditingController();
  RowData({this.itemGroup, this.itemName,this.quantity});
}
class QuotationEntry extends StatefulWidget {
  const QuotationEntry({Key? key}) : super(key: key);
  @override
  State<QuotationEntry> createState() => _QuotationEntryState();
}
class _QuotationEntryState extends State<QuotationEntry> {
  TextEditingController companyName =TextEditingController();
  TextEditingController cusName =TextEditingController();
  TextEditingController address =TextEditingController();
  TextEditingController pincode =TextEditingController();
  TextEditingController contact =TextEditingController();
  TextEditingController payType =TextEditingController();
  RegExp pincodeRegex = RegExp(r'^[0-9]{6}$');
  DateTime date = DateTime.now();
  List<List<TextEditingController>> controllers = [];
  List<List<FocusNode>> focusNodes = [];
  Map<String, dynamic> dataToInsert = {};
  List<RowData> rowData = [];
  List<String> itemGroups = [];
  List<String> itemNames = [];
  bool isFirstRowRemovalEnabled = false;
  final ScrollController _scrollController = ScrollController();



  Future<void> insertData(Map<String, dynamic> rowsDataToInsert) async {
    const String apiUrl = 'http://localhost:3309/quotation';
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
/*  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    final String apiUrl = 'http://localhost:3309/quotation'; // Replace with your server details
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
  }*/


  Map<String, dynamic> dataToInsertitem = {};
  String custCodeValue = '';
  String customerCode ='';
  String customerName = '';
  String retrivecusName = '';
  String retrivecusAddress = '';
  String cName = '';
  String cAddress = '';

  ///get old customer details start code
  TextEditingController custName =TextEditingController();
  TextEditingController custAddress =TextEditingController();
  TextEditingController custMobile =TextEditingController();
  List<Map<String, dynamic>> codedata = [];
  List<Map<String, dynamic>> itemdata = [];
  List<Map<String, dynamic>> filteredData = [];
  bool showInitialData = true;
  ///get old customer details end code

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
//generate code
  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    // Use the key "name" to access the value of the "name" column.
    return jsonItem['quotNo'];
  }
  List<Map<String, dynamic>> data = [];
  String? quotationNo;
  Future<void> quotfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/quotationNo'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          quotationNo = getNameFromJsonData(item);
          print('quotNo: $quotationNo');
        }
        setState(() {
          data = jsonData.cast<Map<String, dynamic>>();
          quotationNumber = generateId(); // Call generateId here
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

  List<Map<String, dynamic>> data2 = [];
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getItem'));
      if (response.statusCode == 200) {
        final List<dynamic> apiData = json.decode(response.body);
        setState(() {
          data2 = apiData.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }


  String quotationNumber ="";


  String generateId() {
    if (quotationNo != null) {
      String iddd = quotationNo!.substring(1);
      int idInt = int.parse(iddd) + 1;
      String id = 'Q${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }


  @override
  void initState() {
    super.initState();
    quotfetch();
    addRow();
    fetchData();
    getitemname();
    getitem();
    fetchData();
  }

  List<bool> isRowFilled = [false];
/*  void addRow() {
    setState(() {
      List<TextEditingController> rowControllers = [];
      List<FocusNode> rowFocusNodes = [];
      for (int j = 0; j < 3; j++) {
        rowControllers.add(TextEditingController());
        rowFocusNodes.add(FocusNode());
        isRowFilled.add(false);
      }
      controllers.add(rowControllers);
      focusNodes.add(rowFocusNodes);
      // Set focus on the first input field of the newly added row
      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(rowFocusNodes[0]);
      });
    });
  }*/
  void removeRow(int index) {
    setState(() {
      controllers.removeAt(index);
      focusNodes.removeAt(index);
      if(controllers.isEmpty){
        addRow();
      }
      // isRowFilled.removeAt(index);
    });
  }
  bool allFieldsFilled = false;
  void updateFieldValidation() {
    bool allValid = true;
    for (var i = 0; i < controllers.length; i++) {
      for (var j = 0; j < 3; j++) {
        if (controllers[i][j].text.isEmpty) {
          allValid = false;
          break;
        }
      }
    }
    setState(() {
      allFieldsFilled = allValid;
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
  final _formKey = GlobalKey<FormState>();
  DateTime currentDate = DateTime.now();
  void _resetForm() {
    _formKey.currentState!.reset();
  }
  void _cancelForm() {
    print('Form cancelled!');
  }
  String dropdownvalue = "Choose...";
  String? errorMessage="";

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

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "quotation_entry",backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8,right: 8,top:8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    //  SizedBox(width: 5,),
                                    Icon(Icons.edit_note,size: 30,),
                                    SizedBox(width: 5,),
                                    Text("Quotation Entry", style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Container(
                                  width:120,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        child: Wrap(
                                          children: [
                                            Text(
                                              DateFormat('dd-MM-yyyy').format(currentDate), // Change the date format here
                                              style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(color: Colors.grey),
                                      Text("Quotation Number",style: TextStyle(fontWeight: FontWeight.bold)),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(quotationNumber.isEmpty? "Q001" :quotationNumber,style: TextStyle(
                                            color: Colors.black
                                        ),),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),

                  SizedBox(height: 1,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color:Colors.blue[50],
                        border: Border.all(color: Colors.grey), // Add a border for the box
                        borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                      ),
                      child: Column(
                        children: [
                          Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:12,top: 10),
                                child: Text("Customer Details",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      errorMessage ?? '',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height:10),
                          Wrap(
                            runSpacing: 10,
                            spacing: 35,
                            children: [
                              SizedBox(
                                width: 220,height: 70,
                                child: TextFormField(
                                  controller: custName,
                                  onChanged: (value) {
                                    setState(() {
                                      errorMessage = null; // Reset error message when user types
                                    });
                                    String capitalizedValue = capitalizeFirstLetter(value);
                                    custName.value = custName.value.copyWith(
                                      text: capitalizedValue,
                                      selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                    );
                                  },
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    label: Text("Customer/Company Name",style: TextStyle(fontSize: 13),),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 220,height: 70,
                                child: TextFormField(
                                  controller: custMobile,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    prefix: Text("+91"),
                                    label: Text("Customer Mobile",style: TextStyle(fontSize: 13),),
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
                                width: 220,height: 70,
                                child: TextFormField(
                                  controller: custAddress,
                                  style: TextStyle(fontSize: 13),
                                  onChanged: (value) {
                                    setState(() {
                                      errorMessage = null; // Reset error message when user types
                                    });
                                    String capitalizedValue = capitalizeFirstLetter(value);
                                    custAddress.value = custAddress.value.copyWith(
                                      text: capitalizedValue,
                                      selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                    );
                                  },
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    // hintText: "Address",
                                    label: Text("Customer Address",style: TextStyle(fontSize: 13),),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 220,height: 70,
                                child: TextFormField(
                                  controller: pincode,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,

                                    label: Text("Pincode",style: TextStyle(fontSize: 13),),
                                    hintText: ("Pincode"),
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

                            ],
                          ),
                          const Align(
                              alignment:Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Text("Product Details",
                                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                              )),
                          const SizedBox(height: 20,),

                          Scrollbar(
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
                                      //4: FixedColumnWidth(100),
                                      /*      5: FixedColumnWidth(100),
                                        6: FixedColumnWidth(100),*/
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
                                                Text('Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                                                SizedBox(height: 10),
                                              ],
                                            )),
                                          ),
                                        ),
                                        /*  TableCell(
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
                                                  },
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter.allow(
                                                      RegExp(r'^\d{0,2}\.?\d{0,2}'),
                                                    ),
                                                    LengthLimitingTextInputFormatter(10),
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
                                                    visible: true,  // Check this condition
                                                    child: IconButton(
                                                      icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                                                      onPressed: i >= 0 ? () => deleteRow(i) : null,
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
                                                              setState(() {
                                                                isFirstRowRemovalEnabled = true;
                                                              });
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
                                        ]
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child:
                    Wrap(
                      children: [
                        MaterialButton(
                          color: Colors.green.shade600,
                          onPressed: () {
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
                              if (custName.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Customer/Company Name';
                                });
                              }
                              else if (custMobile.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Customer Mobile';
                                });
                              } else if (custMobile.text.length != 10) {
                                setState(() {
                                  errorMessage = '* Mobile number should be 10 digits';
                                });
                              } else if (custAddress.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Customer Address ';
                                });
                              }
                              else if(pincode.text.isEmpty){
                                setState(() {
                                  errorMessage = '* Enter a pincode';
                                });

                              }
                              else if (pincode.text.length != 6) {
                                setState(() {
                                  errorMessage = '* Enter a valid pincode';
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
                              else {
                                if (quotationNumber.isEmpty) {
                                  quotationNumber = 'Q001';
                                }
                                dataToInsert = {
                                  "quotNo": quotationNumber,
                                  "custName": custName.text.trim(),
                                  "custAddress": custAddress.text.trim(),
                                  "custMobile": custMobile.text.trim(),
                                  "pincode": pincode.text.trim(),
                                  "unit":"500",
                                  'itemGroup': rowData[i].itemGroup,
                                  'itemName': rowData[i].itemName,
                                  'rate':rowData[i].qtyController.text,
                                  "date": date.toString(),
                                };
                                insertData(dataToInsert);
                                // Show alert after saving the data
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Quotation'),
                                      content: Text('Save Successfully'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => QuotationEntry()),
                                            );
                                          },
                                          child: Text('OK'),
                                        ),

                                        TextButton(
                                          onPressed: () {
                                            // Retrieve values from text form fields
                                            String customerName = custName.text;
                                            String customerMobile = custMobile.text;
                                            String customerAddress = custAddress.text;
                                            String customerpincode = pincode.text;
                                            String quationNo = quotationNumber;
                                            String date = DateFormat('dd-MM-yyyy').format(currentDate);
                                            // Do something with the values, for example, print them
                                            print('Customer Name: $customerName');
                                            print('Customer Mobile: $customerMobile');
                                            print('Customer Address: $customerAddress');
                                            print('Quotation Number: $quationNo');
                                            print('Current Date: $date');
                                            // Navigate to the next screen with the values
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => QuotationEntryPDF(
                                                  quationNo: quationNo,
                                                  customerName: customerName,
                                                  customerMobile: customerMobile,
                                                  customerAddress: customerAddress,
                                                  pincode: customerpincode,
                                                ),
                                              ),
                                            );
                                            //   Navigator.push(context, MaterialPageRoute(builder: (context)=> QuotationEntry()));
                                          },
                                          child: Text('Print'),
                                        ),

                                      ],
                                    );
                                  },
                                );
                              }

                            }

                          },
                          child: Text("SUBMIT", style: TextStyle(color: Colors.white)),
                        ),

                        SizedBox(width: 10,),
                        MaterialButton(
                          color: Colors.blue.shade600,
                          onPressed: (){// Close the alert box
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
                                            MaterialPageRoute(builder: (context) =>const QuotationEntry()));// Close the alert box
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
                          child:Text("RESET",style: TextStyle(color: Colors.white),),),
                        SizedBox(width: 10,),
                        MaterialButton(
                          color: Colors.red.shade600,
                          onPressed: (){
                            /*  Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>const Home()));*/// Close the alert box
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
        ) );
  }
}

