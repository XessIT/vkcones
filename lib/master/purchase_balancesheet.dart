

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import '../home.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class RowData {
  TextEditingController invoicenumber =TextEditingController();
  TextEditingController invoiceamount =TextEditingController();
  TextEditingController checkamount =TextEditingController();
  TextEditingController deductionamount =TextEditingController();
  TextEditingController receivedamount = TextEditingController();
  RowData();
}

class PurchaseBalanceSheet extends StatefulWidget {
  const PurchaseBalanceSheet({Key? key}) : super(key: key);

  @override
  State<PurchaseBalanceSheet> createState() => _PurchaseBalanceSheetState();
}

class _PurchaseBalanceSheetState extends State<PurchaseBalanceSheet> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TextEditingController invoiceNo=TextEditingController();
  String? Process;
  List<List<TextEditingController>> controllers = [];
  String selectedCustCode = '';

  String? payType;


  String?errorMessage;
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filteredData = [];

  TextEditingController supName= TextEditingController();
  TextEditingController supCode= TextEditingController();
  TextEditingController transId= TextEditingController();
  TextEditingController chequeno= TextEditingController();
  TextEditingController balance= TextEditingController();
  TextEditingController debit= TextEditingController();
  TextEditingController credit= TextEditingController();
  TextEditingController grandTotal= TextEditingController();
  TextEditingController chequeAmt=TextEditingController();
  TextEditingController deductionAmt=TextEditingController();
  TextEditingController receivedAmt=TextEditingController();
  TextEditingController chequeAmtController = TextEditingController();


  late FocusNode invoiceNoFocusNode;
  late FocusNode chequeAmtFocusNode;
  late FocusNode deductionAmtFocusNode;
  late FocusNode receivedAmtFocusNode;
  late FocusNode saveButtonFocusNode;
  late List<FocusNode> focusOrder;
  double? dedamt; /// for dedecution AMt
  double? chequeamt; /// For cheque amt
  double? receivedamt;
  double? initialAmt;

  ///For Intialamt



  /// for new
  String? fetchgetitemgGroup="";
  String? fetchgetitemgName;


  List<String>  selectedInvoiceNo=[];

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  double calculateChequeAmount(int rowIndex) {
    double totalInvoiceAmount = 0.0;
    for (int i = 0; i < controllers.length; i++) {
      totalInvoiceAmount += double.tryParse(controllers[i][1].text) ?? 0.0;
    }

    return totalInvoiceAmount;
  }
  void updateReceivedAmt() {
    setState(() {
      for(int i=0; i <controllers.length;i++) {
        double invoiceAmount = double.tryParse(controllers[i][1].text) ?? 0.0;
        double deductionAmount = double.tryParse(controllers[i][3].text) ?? 0;
        double calculatedReceivedAmt = invoiceAmount - deductionAmount;
        controllers[i][3].text = calculatedReceivedAmt.toStringAsFixed(2);
      }});
  }

  double balanceAmount = 0;
  String creditBalance = "Db";
  void updateBalanceAmount() {
    setState(() {
      double grandTotalAmt = double.tryParse(grandTotal.text) ?? 0;
      double chequeAmount = double.tryParse(chequeAmt.text) ?? 0;

      double calculatedAmt;

      if (chequeAmount >= grandTotalAmt) {
        calculatedAmt = chequeAmount - grandTotalAmt;
        // Debit scenario: chequeAmount is greater than or equal to grandTotalAmt
        // calculatedAmt = 0;
      } else {
        // Credit scenario: chequeAmount is less than grandTotalAmt
        calculatedAmt = grandTotalAmt - chequeAmount;
      }
      // Set the balance amount
      balanceAmount = calculatedAmt;
      // Determine whether it's a credit or debit
      creditBalance = chequeAmount >= grandTotalAmt ? "Cr" : "Db";
      // Set the balance text
      balance.text = '${balanceAmount.toStringAsFixed(2)}$creditBalance';
    });
  }





  double grandTotalValue = 0.0;

  double calculateGrandTotal() {
    double grandTotalValue = 0.0;
    for (var i = 0; i < controllers.length; i++) {
      double total = double.tryParse(controllers[i][1].text) ?? 0.0;
      grandTotalValue += total;
      setState(() {
        grandTotal.text=grandTotalValue.toStringAsFixed(2);
      });
    }
    return grandTotalValue;
  }

// Assuming you have a variable like this in your widget class
  // Default to Debit


  List<List<TextEditingController>> controllerstable =[];
  void _resetForm() {
    _formKey.currentState!.reset();
    supName.clear();
    invoiceNo.clear();
    chequeAmt.clear();
    deductionAmt.clear();
    grandTotal.clear();
    invoiceNo.clear();
    receivedAmt.clear();
    setState(() {
    });
  }


  ///for suggestion invoice field.... starts
  Future<void> fetchDataSuggestion() async {
    try {
      final Uri url = Uri.parse('http://localhost:3309/get_balancesheet_for_suggestion_purchase/');
      final Map<String, String> queryParams = {};
      if (invoiceNo.text != null) {
        queryParams['invoiceNo'] = invoiceNo.text;
      }
      if (queryParams.isNotEmpty) {
        url.replace(queryParameters: queryParams);
      }
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          suggesstiondata = itemGroups.cast<Map<String, dynamic>>();
        });

        // print('Data: $suggesstiondata');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }
  ///for suggestion invoice field.... ends





  void filterData(String searchText) {
    setState(() {
      List<String> searchList = searchText.split(' ');

      if (searchText.isEmpty) {
        filteredData = data;
        supName.clear();
        supCode.clear();
        grandTotal.clear();
        balance.clear();
        filteredData = data;
        controllers.clear();
        rowData.clear();
        //data = itemGroups.cast<Map<String, dynamic>>();
        data=[];
      } else {
        List<String> invoiceNos = searchText.split(',');
        //fetchDataForInvoice(selectedOrderNumbers);


        filteredData = data.where((item) {
          String id = item['invoiceNo']?.toString()?.toLowerCase() ?? '';
          return searchList.any((searchItem)=>id.contains(searchItem.toLowerCase()));
        }).toList();
        if (filteredData.isNotEmpty) {
          for (var i = 0; i < rowData.length; i++){
            Map<String, dynamic> order = filteredData.first;
            supName.text = order['supName']?.toString() ?? '';
            supCode.text = order['supCode']?.toString() ?? '';




            // rowData[i].invoicenumber.text = order['invoiceNo']?.toString() ?? '';
            // rowData[i].invoiceamount.text = order['grandTotal']?.toString() ?? '';
          }
        } else {
          for (var i = 0; i < rowData.length; i++) {
            supName.clear();
            supCode.clear();
            balance.clear();
            grandTotal.clear();

          }
        }
      }
    });
  }

  List<Map<String, dynamic>> filteredData3 = [];
  List<Map<String, dynamic>> data3 = [];
  Future<void> fetchData3() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/checkinvoiveNo_forbalancesheet_purchase'));
      if (response.statusCode == 200) {
        final List<dynamic> rows = jsonDecode(response.body);
        rows.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['date']);
          final DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA);
        });
        setState(() {
          data3 = rows.cast<Map<String, dynamic>>();
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
  void filterData3(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredData3 = data3.where((item) {
          final supName = item[''].toString().toLowerCase();
          return supName.contains(query.toLowerCase());
        }).toList();
      } else {

        filteredData3 = List.from(data3);
      }
    });
  }
  bool invoicenumberexiest(String name) {
    return data3.any((item) => item['invoiceNo'].toString().toLowerCase() == name.toLowerCase());
  }

  @override
  void dispose() {
    invoiceNoFocusNode.dispose();
    chequeAmtFocusNode.dispose();
    deductionAmtFocusNode.dispose();
    receivedAmtFocusNode.dispose();
    saveButtonFocusNode.dispose();
    super.dispose();
  }
  void handleTab() {
    if (invoiceNoFocusNode.hasFocus) {
      FocusScope.of(context).unfocus();
      FocusScope.of(context).requestFocus(chequeAmtFocusNode);
    } else if (chequeAmtFocusNode.hasFocus) {
      FocusScope.of(context).unfocus();
      FocusScope.of(context).requestFocus(deductionAmtFocusNode);
    } else if (deductionAmtFocusNode.hasFocus) {
      FocusScope.of(context).unfocus();
      FocusScope.of(context).requestFocus(receivedAmtFocusNode);
    } else if (receivedAmtFocusNode.hasFocus) {
      // Handle the last field, you can customize this behavior
      // For example, you can move focus to the first field
      FocusScope.of(context).unfocus();
      FocusScope.of(context).requestFocus(invoiceNoFocusNode);
    }
  }
  @override
  void initState() {
    super.initState();
    //addRow();
    chequeamt =initialAmt;
    invoiceNoFocusNode=FocusNode();
    chequeAmtFocusNode=FocusNode();
    deductionAmtFocusNode=FocusNode();
    receivedAmtFocusNode=FocusNode();
    invoiceNoFocusNode.requestFocus();//add Row
    controllers = List.generate(3, (_) => List.generate(6, (_) => TextEditingController()));

    //   fetchData3();
    fetchDataSuggestion();
    //  fetchData(selectedOrderNumbers);
    updateBalanceAmount();
    //updateBalanceAmount2();
    // updateDebitAmt();
    // updatecreitAmt();
    // updateReceivedAmt();

  }
  Map<String, dynamic> dataToInsert = {};
  Future<void> insertData(List<Map<String, dynamic>> rowsDataToInsert) async {
    const String apiUrl = 'http://localhost:3309/balanace_sheet_purchase';
    try {
      for (var dataToInsert in rowsDataToInsert) {
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
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  void validateDropdown() {
    setState(() {
      dropdownValid1 = Process != "Deduction Type";
    });
  }

  bool dropdownValid1 = true;
  // double grandTotalValue = 0.0;
  double chequeAmountValue = 0.0;

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
        );
      },
    );

    // Close the dialog after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

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
                Navigator.of(context).pop(); // Close the alert dialog
                setState(() {
                  if (index == 0) {
                    // If it's the first row, clear input values instead of removing i
                    //rowData[index].qtyController.text = "";
                  } else {
                    // Remove the row from the list for other rows
                    rowData.removeAt(index);
                  }
                });
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  List<RowData> rowData = [];
  void addRow() {
    setState(() {
      rowData.add(RowData(

      ));

    });
  }
  List<Map<String, dynamic>> suggesstiondata = [];

  bool isFirstRowRemovalEnabled = false;
  List<String> selectedOrderNumbers = [];
  void updateTableValues() {
    for (int i = 0; i < controllers.length; i++) {
      double invoiceAmount = double.tryParse(controllers[i][1].text) ?? 0.0;
      double deductionAmount = double.tryParse(controllers[i][3].text) ?? 0.0;
      double receivedAmount = double.tryParse(controllers[i][4].text) ?? 0.0;

      // Calculate Cheque Amount
      double chequeAmount = chequeamt! - invoiceAmount + deductionAmount;

      // Update the Cheque Amount field in the table
      controllers[i][2].text = chequeAmount.toStringAsFixed(2);
    }
  }

  ///table values fetch starts
/*
  Future<void> fetchDataByOrderNumber(List<String> invoiceNos) async {
    try {
      if (invoiceNos.isEmpty) {
        setState(() {
          controllers.clear();
        });
        return;
      }

      final url = Uri.parse('http://localhost:3309/balance_sheet_values_get_for_table?invoiceNos=${invoiceNos.join(',')}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;

        setState(() {
          // Clear data structures before populating them with new data
          controllers.clear();

          for (var i = 0; i < rows.length; i++) {

            List<TextEditingController> rowControllers = [];
            Map<String, dynamic> row = {
              'invoiceNo': rows[i]['invoiceNo'],
              'grandTotal': rows[i]['grandTotal'],
              'custCode':rows[i]["custCode"],
              'custName':rows[i]["custName"],
            };
            print('Response Fetch Data: $responseData');
            print('Rows: $rows');
            custCode.text= row["custCode"].toString()??"";
            custName.text= row["custName"].toString()??"";


            if (selectedCustCode.isNotEmpty && row["custCode"] != selectedCustCode) {
              // Display an error or handle it as needed
              setState(() {
                errorMessage = 'CustCode does not match the previous selection, Click the Reset Button Enter A valid data Again';
                {
               custCode.clear();
               custName.clear();
               invoiceNo.clear();
               grandTotal.clear();

                }
              }
             );
              return;
            }
            // Set the selected custCode for future comparison
            selectedCustCode = row["custCode"];

            setState(() {
              if(invoiceNo.text.isEmpty){
                custCode.clear();
                custName.clear();

              }

            });
            for (int j = 0; j < 6; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }
            controllers.add(rowControllers);
          }
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          selectedCustCode = '';

        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        selectedCustCode = '';

      });
    }
  }
*/
  Future<void> fetchDataByOrderNumber(List<String> invoiceNos) async {
    try {
      if (invoiceNos.isEmpty) {
        setState(() {
          controllers.clear();
          grandTotal.clear(); // Clear grandTotal when invoiceNos is empty

        });
        return;
      }

      final url = Uri.parse('http://localhost:3309/balance_sheet_values_purchase?invoiceNos=${invoiceNos.join(',')}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData;

        setState(() {
          // Clear data structures before populating them with new data
          controllers.clear();

          for (var i = 0; i < rows.length; i++) {
            List<TextEditingController> rowControllers = [];
            Map<String, dynamic> row = {
              'invoiceNo': rows[i]['invoiceNo'],
              'grandTotal': rows[i]['grandTotal'],
              'supCode': rows[i]["supCode"],
              'supName': rows[i]["supName"],
            };
            print('Response Fetch Data: $responseData');
            print('Rows: $rows');
            supCode.text = row["supCode"].toString() ?? "";
            supName.text = row["supName"].toString() ?? "";
            grandTotal.text = row["grandTotal"].toString() ?? "";

            if (selectedCustCode.isNotEmpty && row["supCode"] != selectedCustCode) {
              // Display an error in an alert dialog
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Alert'),
                    content: Text('Customer Code/ Company Name does not match the previous selection'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => PurchaseBalanceSheet()));
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );

              setState(() {
                supCode.clear();
                supName.clear();
                invoiceNo.clear();
                grandTotal.clear();
              });

              return;
            }

            // Set the selected custCode for future comparison
            selectedCustCode = row["supCode"];

            setState(() {
              if (invoiceNo.text.isEmpty) {
                supCode.clear();
                supName.clear();
                grandTotal.clear();

              }
            });
            for (int j = 0; j < 5; j++) {
              TextEditingController controller = TextEditingController(text: row[_getKeyForColumn(j)]);
              rowControllers.add(controller);
            }
            controllers.add(rowControllers);
          }
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          selectedCustCode = '';
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        selectedCustCode = '';
      });
    }
  }


  void calculate(){
    for (int i = 0; i < controllers.length; i++){
      controllers[i][3].text =dedamt!.toStringAsFixed(2);
      double invoiceAmont= double.tryParse(controllers[i][1].text)??0.0;
      double dedectionAmount= double.tryParse(controllers[i][3].text)??0.0;
      double receivedAmount =invoiceAmont-dedectionAmount;
      controllers[i][3].text = receivedAmount.toString();
      print(controllers[i][3].text);


    }
  }

  ///table values fetch ends
  ///


  @override
  Widget build(BuildContext context)
  {
    calculateGrandTotal();
    invoiceNo.addListener(() {
      fetchDataByOrderNumber(selectedInvoiceNo);
      fetchDataSuggestion();//

    });
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event.logicalKey == LogicalKeyboardKey.tab && event is RawKeyDownEvent) {
          handleTab();
        }
      },
      child: MyScaffold(
          route: 'balancesheet_entry_purchase',backgroundColor: Colors.white,
          body:Form(
            key: _formKey,
            child: Column(
              children: [
                //   Text("gt${grandTotal.text}"),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey), // Add a border for the box
                      borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                    ),child: Wrap(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined,size: 30,),SizedBox(width: 10,),
                                Text("Balance Sheet",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Wrap(
                              children: [
                                SizedBox(
                                  width:300,
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Text(
                                            DateFormat('dd-MM-yyyy').format(selectedDate),
                                            style:TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(height: 3,),
                                        Divider(
                                          color: Colors.grey.shade600,
                                        ),
                                        Wrap(
                                            children:[
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,

                                                child: SizedBox(width: 300,
                                                  child: TypeAheadFormField<String>(
                                                    textFieldConfiguration: TextFieldConfiguration(
                                                      controller: invoiceNo,
                                                      style: const TextStyle(fontSize: 13),
                                                      onChanged: (value) {
                                                        if (invoicenumberexiest(invoiceNo.text)) {
                                                          setState(() {
                                                            errorMessage = '* This Invoice Already Saved';
                                                          });
                                                          //showErrorMessage(errorMessage!);
                                                          return;
                                                        }
                                                        setState(() {
                                                          errorMessage = null;
                                                          if(invoiceNo.text.isEmpty)
                                                          {

                                                            chequeno.clear();
                                                            transId.clear();
                                                            chequeAmt.clear();
                                                            receivedAmt.clear();
                                                            deductionAmt.clear();
                                                            grandTotal.clear();
                                                            balance.clear();


                                                          }
                                                          // Reset error message when the user types
                                                        });
                                                      },

                                                      inputFormatters:
                                                      [UpperCaseTextFormatter(),
                                                        NoBackspaceDeleteFormatter(),
                                                      ],
                                                      decoration: InputDecoration(
                                                        fillColor: Colors.white, filled: true,
                                                        labelText: "Invoice Number",
                                                        labelStyle: TextStyle(fontSize: 13),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),),
                                                        suffixIcon: invoiceNo.text.isNotEmpty
                                                            ? IconButton(
                                                          icon: Icon(Icons.clear),
                                                          onPressed: () {
                                                            Navigator.push(context,
                                                                MaterialPageRoute(builder: (context) =>const PurchaseBalanceSheet()));// Close the alert box
                                                          },
                                                        )
                                                            : null,
                                                      ),

                                                    ),
                                                    suggestionsCallback: (pattern) async {
                                                      List<String> inputParts = pattern.split(',').map((part) => part.trim()).toList();
                                                      String currentInput = inputParts.isNotEmpty ? inputParts.last : '';
                                                      List<String> suggestions;
                                                      if (currentInput.isNotEmpty) {
                                                        suggestions = suggesstiondata
                                                            .where((item) =>
                                                        (item['invoiceNo']?.toString().toLowerCase() ?? '')
                                                            .startsWith(currentInput.toLowerCase()) &&
                                                            !selectedOrderNumbers.contains(item['invoiceNo'].toString()))
                                                            .map((item) => item['invoiceNo'].toString())
                                                            .toSet()
                                                            .toList();
                                                      } else {
                                                        suggestions = suggesstiondata
                                                            .where((item) => !selectedOrderNumbers.contains(item['invoiceNo'].toString()))
                                                            .map((item) => item['invoiceNo'].toString())
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
                                                      // Find the corresponding custCode for the selected invoice

                                                      if (!selectedInvoiceNo.contains(suggestion)) {
                                                        setState(() {

                                                          selectedInvoiceNo.add(suggestion);
                                                          invoiceNo.text = selectedInvoiceNo.join(', ');
                                                          suggesstiondata.removeWhere((item) => item['invoiceNo'].toString() == suggestion,

                                                          );
                                                        });
                                                      }

                                                      print('Selected Order Numbers: $selectedOrderNumbers');
                                                    },
                                                  ),
                                                ),
                                              ),

                                            ]
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],)
                    ],
                  ),
                  ),
                ),


                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        width: double.infinity, // Set the width to full page width
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.grey), // Add a border for the box
                          borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                        ),
                        child:
                        Column(children: [
                          Wrap(
                            children:[
                              Row(mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0,bottom: 10),
                                    child: Text(
                                      errorMessage ?? '',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30,),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Wrap(
                                  spacing: 36.0, // Set the horizontal spacing between the children
                                  runSpacing: 20.0,
                                  children: [

                                    SizedBox(
                                      width: 220,height: 70,
                                      child: TextFormField(
                                        controller: supCode,
                                        readOnly: true,
                                        style: TextStyle(fontSize: 13),
                                        onChanged: (value) {
                                          setState(() {
                                            errorMessage = null; // Reset error message when user types
                                          });
                                        },
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                        ],
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Supplier Code",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ), /// Customer Code
                                    SizedBox(
                                      width: 220,height: 70,
                                      child: TextFormField(
                                        controller: supName,
                                        readOnly: true,
                                        style: TextStyle(fontSize: 13),
                                        onChanged: (value) {
                                          balance.clear();
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          supName.value = supName.value.copyWith(
                                            text: capitalizedValue,
                                            selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                          );
                                          setState(() {
                                            errorMessage = null; // Reset error message when user types
                                          });
                                        },
                                        onEditingComplete: () {
                                          // Move focus to the next controller in the order
                                          FocusScope.of(context).requestFocus(chequeAmtFocusNode);
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Supplier/Company Name",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ), /// Company Name
                                    /*SizedBox(
                                      width: 220,height: 70,
                                      child: TextFormField(
                                        controller: chequeno,

                                        style: TextStyle(fontSize: 13),
                                        onChanged: (value) {
                                          setState(() {
                                            errorMessage = null; // Reset error message when user types
                                          });
                                        },
                                        inputFormatters: [
                                          // UpperCaseTextFormatter(),
                                          FilteringTextInputFormatter.digitsOnly, // Allow only numeric input
                                          LengthLimitingTextInputFormatter(6)
                                        ],
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Cheque Number",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),*//// Ceque Number
                                    SizedBox(
                                      width: 220,
                                      height: 70,
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: grandTotal,
                                        style: TextStyle(fontSize: 13),
                                        onChanged: (value) {

                                          setState(() {
                                            grandTotal.text = calculateGrandTotal().toStringAsFixed(2);
                                          });

                                          // The onChanged callback is not needed for a readOnly field
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Invoice Amount",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
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
                                          items: <String>['RTGS','NEFT','Cash',]
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
                                     /// Bank name
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 36.0, // Set the horizontal spacing between the children
                                  runSpacing: 20.0,
                                  children: [
                                    SizedBox(
                                      width: 220,height: 70,
                                      child: TextFormField(
                                        controller: transId,
                                        style: TextStyle(fontSize: 13),
                                        onChanged: (value) {
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          transId.value = transId.value.copyWith(
                                            text: capitalizedValue,
                                            selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                          );
                                          setState(() {
                                            errorMessage = null; // Reset error message when user types
                                          });
                                        },
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                        ],
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Transaction Id",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 220,
                                      height: 70,
                                      child: TextFormField(
                                        onChanged: (value) {
                                          setState(() {
                                            updateBalanceAmount();
                                          });
                                          setState(() {
                                            receivedamt = double.tryParse(value) ?? 0.0;

                                            // Ensure received amount is not greater than cheque amount
                                            if (receivedamt != null && chequeamt != null && receivedamt! > chequeamt!) {
                                              chequeAmt.text = chequeamt.toString();
                                              receivedamt = chequeamt;
                                            }

                                            for (int i = 0; i < controllers.length; i++) {
                                              if (i == 0) {
                                                controllers[i][2].text = receivedamt.toString();
                                                double invoiceAmount = double.tryParse(controllers[i][1].text) ?? 0.0;
                                                controllers[i][3].text = ((receivedamt ?? 0.0) - invoiceAmount).toString();
                                              } else {
                                                double previousChequeAmt = double.tryParse(controllers[i - 1][2].text) ?? 0.0;
                                                double previousInvoiceAmt = double.tryParse(controllers[i - 1][1].text) ?? 0.0;
                                                double newChequeAmt = previousChequeAmt - previousInvoiceAmt;
                                                controllers[i][2].text = newChequeAmt.toString();

                                                double currentInvoiceAmount = double.tryParse(controllers[i][1].text) ?? 0.0;
                                                double balanceAmount = newChequeAmt - currentInvoiceAmount;

                                                // Check for null before assigning to controllers[i][3].text
                                                controllers[i][3].text = (balanceAmount ?? 0.0).toString();
                                              }
                                            }
                                          });

                                          setState(() {
                                            if (value.isEmpty) {
                                              // If receivedAmt is empty, clear related fields and return
                                              for (int i = 0; i < controllers.length; i++) {
                                                controllers[i][2].text = '';
                                                controllers[i][3].text = '';
                                              }
                                              errorMessage = null; // Reset error message
                                              return;
                                            }

                                            double chequeAmtValue = double.tryParse(chequeAmt.text) ?? 0.0;
                                            double receivedAmtValue = double.tryParse(receivedAmt.text) ?? 0.0;

                                            // Check if deductionAmt is greater than or equal to chequeAmt
                                            if (receivedAmtValue >= chequeAmtValue) {
                                              errorMessage = ' Received Amount should be less than Cheque Amount';
                                              // Clear deductionAmt field
                                              receivedAmt.text = '';


                                              return;
                                            } else {
                                              errorMessage = null; // Reset error message when user types
                                            }

                                            double receivedamt = chequeAmtValue - receivedAmtValue;
                                            // receivedAmt.text = receivedamt.toStringAsFixed(2);
                                          });


                                        },
                                        controller: chequeAmt,
                                        style: TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Paid Amount",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9!@#\$%^&*(),.?":{}|<>]*$')),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      width: 220,height: 70,
                                      child: TextFormField(
                                        controller: balance,
                                        style: TextStyle(fontSize: 13),
                                        onChanged: (value) {
                                          setState(() {
                                            /*   double grandTotalValue = double.tryParse(grandTotal.text) ?? 0.0;
                                          double chequeAmtValue = double.tryParse(chequeAmt.text) ?? 0.0;
                                          double balanceValue = grandTotalValue - chequeAmtValue;
                                          balance.text = balanceValue.toStringAsFixed(2);*/

                                            errorMessage = null; // Reset error message when user types
                                          });
                                        },
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                        ],
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Balance Amount",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),   /// Balance
                                    /// Invoice Amount

                                    /*SizedBox(
                                      width: 220,height: 38,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black),
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.white,
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            // Step 3.
                                            value: Process,
                                            // Step 4.
                                            hint: Text("Deduction Type",style:TextStyle(fontSize: 13,color: Colors.black)),
                                            items: <String>['Checking And Processing Fee','TDS','Others',]
                                                .map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(fontSize: 11),
                                                ),
                                              );
                                            }).toList(),
                                            // Step 5.
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                Process = newValue!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ), /// Deduction Type
                                    SizedBox(
                                      width: 220,
                                      child: TextFormField(
                                        onEditingComplete: () {
                                          // Move focus to the next controller in the order
                                          FocusScope.of(context).requestFocus(focusOrder[2]);
                                        },
                                        onChanged: (value) {


                                          // Update receivedAmt based on the deductionAmt and chequeAmt
                                          setState(() {
                                            double chequeAmtValue = double.tryParse(chequeAmt.text) ?? 0.0;
                                            double deductionAmtValue = double.tryParse(deductionAmt.text) ?? 0.0;

                                            // Check if deductionAmt is greater than or equal to chequeAmt
                                            if (deductionAmtValue >= chequeAmtValue) {
                                              errorMessage = 'Deduction Amount should be less than Cheque Amount';
                                              // Clear deductionAmt field
                                              deductionAmt.text = '';
                                              return;
                                            } else {
                                              errorMessage = null; // Reset error message when user types
                                            }

                                            double receivedamt = chequeAmtValue - deductionAmtValue;
                                            // receivedAmt.text = receivedamt.toStringAsFixed(2);
                                          });



                                        },
                                        controller: deductionAmt,
                                        style: TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Deduction Amount",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number, // Use TextInputType.number for numeric keyboard
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9!@#\$%^&*(),.?":{}|<>]*$')),
                                        ],
                                      ),
                                    ),*/ ///deductionAmt

                                  ],
                                ),
                              ),
                            /*  Wrap(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 220,
                                      height: 70,
                                      child: TextFormField(
                                        onChanged: (value) {
                                          setState(() {
                                            receivedamt = double.tryParse(value) ?? 0.0;

                                            // Ensure received amount is not greater than cheque amount
                                            if (receivedamt != null && chequeamt != null && receivedamt! > chequeamt!) {
                                              receivedAmt.text = chequeamt.toString();
                                              receivedamt = chequeamt;
                                            }

                                            for (int i = 0; i < controllers.length; i++) {
                                              if (i == 0) {
                                                controllers[i][2].text = receivedamt.toString();
                                                double invoiceAmount = double.tryParse(controllers[i][1].text) ?? 0.0;
                                                controllers[i][3].text = ((receivedamt ?? 0.0) - invoiceAmount).toString();
                                              } else {
                                                double previousChequeAmt = double.tryParse(controllers[i - 1][2].text) ?? 0.0;
                                                double previousInvoiceAmt = double.tryParse(controllers[i - 1][1].text) ?? 0.0;
                                                double newChequeAmt = previousChequeAmt - previousInvoiceAmt;
                                                controllers[i][2].text = newChequeAmt.toString();

                                                double currentInvoiceAmount = double.tryParse(controllers[i][1].text) ?? 0.0;
                                                double balanceAmount = newChequeAmt - currentInvoiceAmount;

                                                // Check for null before assigning to controllers[i][3].text
                                                controllers[i][3].text = (balanceAmount ?? 0.0).toString();
                                              }
                                            }
                                          });

                                          setState(() {
                                            if (value.isEmpty) {
                                              // If receivedAmt is empty, clear related fields and return
                                              for (int i = 0; i < controllers.length; i++) {
                                                controllers[i][2].text = '';
                                                controllers[i][3].text = '';
                                              }
                                              errorMessage = null; // Reset error message
                                              return;
                                            }

                                            double chequeAmtValue = double.tryParse(chequeAmt.text) ?? 0.0;
                                            double receivedAmtValue = double.tryParse(receivedAmt.text) ?? 0.0;

                                            // Check if deductionAmt is greater than or equal to chequeAmt
                                            if (receivedAmtValue >= chequeAmtValue) {
                                              errorMessage = ' Received Amount should be less than Cheque Amount';
                                              // Clear deductionAmt field
                                              receivedAmt.text = '';


                                              return;
                                            } else {
                                              errorMessage = null; // Reset error message when user types
                                            }

                                            double receivedamt = chequeAmtValue - receivedAmtValue;
                                            // receivedAmt.text = receivedamt.toStringAsFixed(2);
                                          });


                                        },
                                        controller: receivedAmt,
                                        style: TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Received Cheque Amount",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9!@#\$%^&*(),.?":{}|<>]*$')),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ///Recevived cheque amt
                                  SizedBox(width: 20,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 220,height: 70,
                                      child: TextFormField(
                                        controller: balance,
                                        style: TextStyle(fontSize: 13),
                                        onChanged: (value) {
                                          setState(() {
                                            *//*   double grandTotalValue = double.tryParse(grandTotal.text) ?? 0.0;
                                            double chequeAmtValue = double.tryParse(chequeAmt.text) ?? 0.0;
                                            double balanceValue = grandTotalValue - chequeAmtValue;
                                            balance.text = balanceValue.toStringAsFixed(2);*//*

                                            errorMessage = null; // Reset error message when user types
                                          });
                                        },
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                        ],
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Balance Amount",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),   /// Balance

                                  SizedBox(width: 10,),

                                ],)*/
                            ],
                          ),

                        ],),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Table(
                      border: TableBorder.all(color: Colors.black),
                      defaultColumnWidth: const FixedColumnWidth(260.0),
                      children: [

                        TableRow(
                          decoration: BoxDecoration(color: Colors.blue.shade200),
                          children: const [
                            TableCell(
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 15),
                                    Text('Invoice No', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 15),
                                    Text('Invoice Amount ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 15),
                                    Text('Cheque Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 15),
                                    Text('Balance Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),

/*
                            TableCell(
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 15),
                                    Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
*/
                          ],
                        ),

                        for (int i = 0; i < controllers.length; i++)
                          if(invoiceNo.text.isNotEmpty)
                            TableRow(
                              children: [
                                for (int j = 0; j < 4; j++)
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        style: TextStyle(fontSize: 13, color: Colors.black),
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: controllers[i][j]
                                        ,
                                        onChanged: (value){
                                          if (value.length > 2) {
                                            controllers[i][j].text = value.substring(0, 2);
                                          }
                                          setState(() {
                                            grandTotal.text = calculateGrandTotal().toStringAsFixed(2);

                                          });

                                        },

                                      ),
                                    ),
                                  ),
/*
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                      onPressed: () {
                                        // Handle the deletion of the row here
                                        setState(() {
                                          controllers.removeAt(i);
                                        });
                                      },
                                      icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade600),
                                    ),
                                  ),
                                ),
*/






/*
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Handle the deletion of the row here
                                      setState(() {
                                        controllers.removeAt(i);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.white, // Set the background color to white
                                    ),
                                    child: Icon(Icons.remove_circle_outline,color: Colors.red.shade600,
                                    ),


                                    // Replace 'Text' with 'Icon'
                                  ),
                                ),
                              ),
*/

                              ],
                            ),
                      ],
                    ),



                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                          child:  MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // saveButtonFocusNode.requestFocus();
                                final date = selectedDate.toIso8601String();
                                List<Map<String, dynamic>> rowsDataToInsert = [];
                                if (invoiceNo.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a invoice Number';
                                  });
                                }
                                else if (invoicenumberexiest(invoiceNo.text)) {
                                  setState(() {
                                    errorMessage = '* This invoice Number Already Saved';
                                  });
                                  return;
                                }
                                else if (supName.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Customer Name';
                                  });
                                }
                                else if (transId.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter Transaction Id';
                                  });
                                }
                                else if (chequeAmt.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Cheque Amount';
                                  });
                                }
                               /* else if (Process == null) {
                                  setState(() {
                                    errorMessage = '* Select a Deduction Type';
                                  });
                                }
                                else if (deductionAmt.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a deduction Amount';
                                  });
                                }*/
                             /*   else if (receivedAmt.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Received Amount';
                                  });
                                }*/
                                else {
                                  double grandTotalAmt = double.tryParse(grandTotal.text) ?? 0;
                                  double chequeAmount = double.tryParse(chequeAmt.text) ?? 0;
                                  double calculatedAmt;

                                  if (chequeAmount >= grandTotalAmt) {
                                    calculatedAmt = chequeAmount - grandTotalAmt;
                                  } else {
                                    calculatedAmt = grandTotalAmt - chequeAmount;
                                  }

                                  String creditOrDebit = chequeAmount >= grandTotalAmt ? "Db" : "Cr";


                                  for (var i = 0; i < controllers.length; i++) {
                                    if (i >= controllers.length) {
                                      controllers.add(List.generate(5, (j) => TextEditingController()));
                                    }
                                    Map<String, dynamic> dataToInsert = {
                                      "invoiceNo": invoiceNo.text,
                                      'date': selectedDate.toString(),
                                      'supCode':supCode.text,
                                      'supName': supName.text,
                                      'chequeAmt': chequeAmt.text,
                                      "grandTotal": grandTotal.text,
                                      'payType':payType,
                                      'chequeNo':chequeno.text,
                                      'transId':transId.text,
                                      'credit': creditOrDebit == "Db" ? calculatedAmt.toStringAsFixed(2) : "0.00",
                                      'debit': creditOrDebit == "Cr" ? calculatedAmt.toStringAsFixed(2) : "0.00",
                                      'individual_invoice':controllers[i][0].text,
                                      'individual_Amt':controllers[i][1].text,
                                      'individual_cheque':controllers[i][2].text,
                                      'individual_balance':controllers[i][3].text,
                                    };
                                    rowsDataToInsert.add(dataToInsert);
                                  }
                                  try {
                                    await insertData(rowsDataToInsert);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Balance Sheet'),
                                          content: Text('Saved Successfully'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('OK'),
                                              onPressed: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(builder: (context) =>PurchaseBalanceSheet()));// Close the alert box
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    print('Error inserting data: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Failed to save data. Please try again."),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: Text("SAVE", style: TextStyle(color: Colors.white)),
                          ),

                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                          child:MaterialButton(
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
                                              MaterialPageRoute(builder: (context) =>const PurchaseBalanceSheet()));// Close the alert box
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
                            // onPressed: _resetForm,
                            child: const Text("RESET",style: TextStyle(color: Colors.white),),),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                          child: MaterialButton(
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
                            child: const Text("CANCEL",style: TextStyle(color: Colors.white),),),
                        ),


                      ],
                    ),
                  ],
                ),

              ],
            ),
          )


      ),
    );

  }
}



String _getKeyForColumn(int columnIndex) {
  switch (columnIndex) {
    case 0:
      return 'invoiceNo';
    case 1:
      return 'grandTotal';
    case 2:
      return 'Received Amount';
    case 3:
      return 'Balance Amount';

    default:
      return '';
  }
}


class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase() ?? '', // Convert to uppercase
      selection: newValue.selection,
    );
  }
}
class NoBackspaceDeleteFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Prevent backspace and delete by returning oldValue
    if (newValue.text.length < oldValue.text.length) {
      return oldValue;
    }
    return newValue;
  }
}