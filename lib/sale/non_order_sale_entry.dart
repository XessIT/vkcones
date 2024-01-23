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
import 'nonsale_pdf.dart';
class NonrderSaleEntry extends StatefulWidget {
  const NonrderSaleEntry({Key? key}) : super(key: key);
  @override
  State<NonrderSaleEntry> createState() => _NonrderSaleEntryState();
}
class _NonrderSaleEntryState extends State<NonrderSaleEntry> {

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

/*
  double calculateTotal(int rowIndex) {
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
*/
  double calculateTotal(int rowIndex) {
    double quantity = double.tryParse(controllers[rowIndex][2].text) ?? 0.0;
    double rate = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
    double total = quantity * rate;
    controllers[rowIndex][4].text = total.toStringAsFixed(2);
    return total;
  }

  double calculateGrandTotal() {
    double grandTotalValue = 0.0;
    for (var i = 0; i < controllers.length; i++) {
      double total = double.tryParse(controllers[i][4].text) ?? 0.0;
      grandTotalValue += total;
    }
    return grandTotalValue;
  }

  void addRow() {
    setState(() {
      List<TextEditingController> rowControllers = [];
      List<FocusNode> rowFocusNodes = [];

      for (int j = 0; j < 5; j++) {
        rowControllers.add(TextEditingController());
        rowFocusNodes.add(FocusNode());
      }

      controllers.add(rowControllers);
      focusNodes.add(rowFocusNodes);

      isRowFilled.add(false);

/*
      Map<String, dynamic> row = {
        'prodCode': '',
        'prodName': '',
        'qty': '',
        'rate':'',
        'amt':'',
        'gst':'',
        'amtGST':'',
        'amountGST':'',
        'total':'',
      };
*/
      Map<String, dynamic> row = {
        'prodName': '',
        'qty': '',
        'rate':'',
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
  int serialnumber =1;


  TextEditingController gstin=TextEditingController();

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Map<String, dynamic> dataToInsertPurchaseReturn = {};
  Map<String, dynamic> dataToInsertPurchaseReturnItem = {};
  Future<void> insertDataPurchaseReturnItem(Map<String, dynamic> dataToInsertPurchaseReturnItem) async {
    const String apiUrl = 'http://localhost:3309/nonsales_insert'; // Replace with your server details
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
              builder: (context) =>NonSalesGeneratePDF(invoiceNo: invoiceNumber, custName: custName.text, custAddress: custAddress.text, custMobile: custMobile.text, date: date.toString(), grandtotal:grandTotal.text)),
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
  Future<void> purchaseReturnItemToDatabase() async
  {
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
          controllers.add(List.generate(4, (j) => TextEditingController()));
        }
        print("Inserting data for row $i");
        Map<String, dynamic> dataToInsertPurchaseReturnItem = {
          "invoiceNo":invoiceNumber,
          "date": date.toString(),
          "custName": custName.text,
          "custAddress": custAddress.text,
          "custMobile": custMobile.text,
          'prodName': controllers[i][1].text,
          'rate': controllers[i][3].text,
          'qty': controllers[i][2].text,
          'total': controllers[i][4].text,
          'grandTotal': grandTotal.text,
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
    super.initState();  //add Row
    addRow();
    fetchData();
    loadInvoiceNumber();
    reNoFetch();
    fetchData2();
    fetchItemGroups();
    fetchItemName();
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
        custCode.clear(); custName.clear();
      } else {
        filteredData = data.where((item) {
          String id = item['orderNo']?.toString()?.toLowerCase() ?? '';
          return id == searchText.toLowerCase();
        }).toList();
        if (filteredData.isNotEmpty) {
          Map<String, dynamic> order = filteredData.first;
          custCode.text = order['custCode']?.toString() ?? '';
          custName.text = order['custName']?.toString() ?? '';
        } else {
          custCode.clear();custName.clear();
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
          deliveryType = existingSupplier['deliveryType'];
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
        print('Data sales customer: $data2');
      } else {
        print('Error sales customer: ${response.statusCode}');
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
      final response = await http.get(Uri.parse('http://localhost:3309/get_Noninvoice_no'));
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


// Function to show the alert dialog
  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Customer not found'),
          content: Text('The customer does not exist. Do you want to continue?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform any action you want when the user chooses to continue
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Working Good")));
              },
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    DateTime Date = DateTime.now();
    final formattedDate = DateFormat("dd/MM/yyyy").format(Date);
    return MyScaffold(
        route: "non_order_entry_sales",
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
                        height: 120,
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
                                          Text("Non Order Sales Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),

                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 100,
                                            child: Column(
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
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 20,),
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
                            color: Colors.blue.shade100,
                            border: Border.all(color: Colors.grey), // Add a border for the box
                            borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                          ),
                          child: Wrap(
                            children: [
                              Padding(
                                padding:  EdgeInsets.only(left:800),
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
                                          width: 220,height: 70,
                                          child: TextFormField(
                                            //readOnly: true,
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
                                            onChanged: (value){
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
                                        ),
                                        SizedBox(width: 55,),
                                        SizedBox(
                                          width: 220,height: 70,
                                          child: TextFormField(//readOnly: true,
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
                                        ),
                                        SizedBox(width: 55,),
                                        SizedBox(
                                          width: 220,height: 70,
                                          child: TextFormField(
                                            //  readOnly: true,
                                            controller: custAddress,
                                            style: TextStyle(fontSize: 13),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              labelText: "Location",
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black), // Set the border color here
                                              ),
                                            ),
                                            onChanged: (value){
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
                                ],
                              ),

/*
                              Wrap(
                                children: [
                                  SizedBox(width: 20,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      children: [

                                //        SizedBox(width: 53,),



                                        SizedBox(
                                          width: 220,
                                          height:40,
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
                                            height:40,
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
*/
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
                                padding: const EdgeInsets.only(left: 30),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: FocusTraversalGroup(
                                    policy: OrderedTraversalPolicy(),
                                    child: Table(
                                      border: TableBorder.all(
                                          color: Colors.black54
                                      ),
                                      defaultColumnWidth: const FixedColumnWidth(180.0),
                                      columnWidths: const <int, TableColumnWidth>{
                                         0: FixedColumnWidth(80),
                                        // 3: FixedColumnWidth(100),
                                        // 4: FixedColumnWidth(100),
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
                                                      Text('S.No',style: TextStyle(fontWeight: FontWeight.bold,),),
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
                                                      const SizedBox(height:15 ),
                                                      Text('Product Name',style: TextStyle(fontWeight: FontWeight.bold),),

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
                                                      const SizedBox(height: 15),
                                                      Text(' Rate',style: TextStyle(fontWeight: FontWeight.bold),),
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
                                              for (var j = 0; j < 5; j++)
                                              /*  j==0
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


                                                    :*/
                                                TableCell(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child:j==0? TextFormField(
                                                      style: TextStyle(fontSize: 13),
                                                      initialValue: serialnumber.toString(),
                                                      textAlign: TextAlign.center,
                                                      readOnly: true,
                                                      //controller: controllers[i][0],
                                                      inputFormatters: [UpperCaseTextFormatter()],
                                                      decoration: const InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),onChanged: (value){
                                                      controllers[i][0].text = value;
                                                      // serialnumber =int.parse(value!);
                                                    },
                                                    ): TextFormField(
                                                        style: TextStyle(fontSize: 13),
                                                        controller: controllers[i][j],
                                                        inputFormatters: [UpperCaseTextFormatter()],
                                                        decoration: const InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                        ),
                                                        textAlign: (j >= 0 && j <= 4) ? TextAlign.center : TextAlign.right,
                                                        enabled: j == 1 || j == 2 || j == 3 || j == 4 ,
                                                        onChanged: (value) async {
                                                          final int rowIndex = i;
                                                          final int colIndex = j;
                                                          final String key = _getKeyForColumn(colIndex);
                                                          updateFieldValidation();
                                                          setState(() {
                                                            rowData[rowIndex][key] = value;
                                                            isRowFilled[i] = controllers[i].every((controller) => controller.text.isNotEmpty);
                                                            errorMessage = '';
                                                            if (colIndex == 2 || colIndex == 3 || colIndex == 4) {
                                                              double quantity = double.tryParse(controllers[rowIndex][2].text) ?? 0.0;
                                                              double rate = double.tryParse(controllers[rowIndex][3].text) ?? 0.0;
                                                              double total = quantity * rate;
                                                              controllers[rowIndex][4].text = total.toStringAsFixed(2);
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
                                                        visible: i == controllers.length-1 /*&& isRowFilled[i]*/,
                                                        child: Align(
                                                          alignment: Alignment.center,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(Icons.add_circle_outline,color: Colors.green,),
                                                                onPressed: () {
                                                                  addRow(
                                                                  );
                                                                  serialnumber++;
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
                              ),
                              SizedBox(height:110,),



                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 120,),

                                  Text("Grand Total  ₹ ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                                  SizedBox(width: 20,),

                                  SizedBox(
                                    width: 160,
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

                          /*    ElevatedButton(onPressed: () async {
                            if(_formKey.currentState!.validate()){
                            bool customerExists = await checkCustomerExists();
                            if (customerExists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Success to save data"),
                                  ),
                                   );

                            } else {
                              // Customer doesn't exist, show alert message
                              showAlertDialog();
                            }}

                          }, child: Text("Test")),*/
                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () async {
                              if(custName.text.isEmpty){
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

                              } else if (grandTotal.text =="0.0"||grandTotal.text =="0.00") {
                                setState(() {
                                  errorMessage = '* Enter a Sales items ';
                                });
                              }
                              else {
                                List<Map<String, dynamic>> rowsDataToInsert = [];
                                rowsDataToInsert.add(dataToInsert);
                                purchaseReturnItemToDatabase();
                                try {
                                  setState(() {
                                    isDataSaved = true;
                                  });
                                  setState(() {
                                    currentInvoiceNumber++;
                                    isDataSaved = true;
                                  });
                                  saveInvoiceNumber();
                                } catch (e) {
                                  print('Error inserting data: $e');
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
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) =>const NonrderSaleEntry()));// Close the alert box
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
      return 's.no';
    case 1:
      return 'prodName';
    case 2:
      return 'qty';
    case 3:
      return 'rate';
    case 4:
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



