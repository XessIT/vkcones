/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import '../home.dart';
import 'balancesheet_pdf.dart';

class BalanceSheetReport extends StatefulWidget {
  const BalanceSheetReport({Key? key}) : super(key: key);

  @override
  State<BalanceSheetReport> createState() => _BalanceSheetReportState();
}

class _BalanceSheetReportState extends State<BalanceSheetReport> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  List<Map<String, dynamic>> data = [];
  TextEditingController searchController = TextEditingController();
  String selectedCustomer = '';
  TextEditingController invoiceNo = TextEditingController();
  final TextEditingController toselectedDate = TextEditingController();
  final TextEditingController fromselectedDate = TextEditingController();
  TextEditingController grandTotalController = TextEditingController();
  TextEditingController deductionAmntcontroller = TextEditingController();
  TextEditingController receivedAmntcontroller = TextEditingController();
  TextEditingController debitAmntcontroller = TextEditingController();
  TextEditingController creditAmntcontroller = TextEditingController();
  TextEditingController chequeAmntcontroller = TextEditingController();
  final TextEditingController  _FromDatecontroller = TextEditingController();
  final TextEditingController  _ToDatecontroller = TextEditingController();
  TextEditingController totalvalue = TextEditingController();
  TextEditingController totalbalance = TextEditingController();


  String? errorMessage;
  bool generatedButton = false;
  bool isDataLoaded = false;
  DateTime? fromDate;
  DateTime? toDate;


  void calculatechequeTotal(List<Map<String, dynamic>> data) {
    double grandTotal = 0.0;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["chequeAmt"]}");
      grandTotal += totalAmount;
    }
    chequeAmntcontroller.text = grandTotal.toStringAsFixed(2);
  }

  void calculateGrandTotal(List<Map<String, dynamic>> data) {
    double grandTotal = 0.0;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["grandTotal"]}");
      grandTotal += totalAmount;
    }
    grandTotalController.text = grandTotal.toStringAsFixed(2);
  }

  void calculatedeductionTotal(List<Map<String, dynamic>> data) {
    double deductionAmt = 0.0;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["deductionAmt"]}");
      deductionAmt += totalAmount;
    }
    deductionAmntcontroller.text = deductionAmt.toStringAsFixed(2);
  }

  void calculatereceivedTotal(List<Map<String, dynamic>> data) {
    double receivedAmt = 0.00;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["receivedAmt"]}");
      receivedAmt += totalAmount;
    }
    receivedAmntcontroller.text = receivedAmt.toStringAsFixed(2);
  }

  void calculatedebitTotal(List<Map<String, dynamic>> data) {
    double debitAmt = 0.00;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["debit"]}");
      debitAmt += totalAmount;
    }
    debitAmntcontroller.text = debitAmt.toStringAsFixed(2);
  }

  void calculatecreditTotal(List<Map<String, dynamic>> data) {
    double creditAmt = 0.00;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["credit"]}");
      creditAmt += totalAmount;
    }
    creditAmntcontroller.text = creditAmt.toStringAsFixed(2);
  }

  void updateReceivedAmt() {
    setState(() {
      double chequeAmount = double.tryParse(grandTotalController.text) ?? 0;
      double deductionAmount = double.tryParse(chequeAmntcontroller.text) ?? 0;
      double calculatedReceivedAmt = chequeAmount - deductionAmount;
      totalvalue.text = calculatedReceivedAmt.toStringAsFixed(2);
    });
  }





  void updateBalanceAmount() {
    setState(() {
      double grandTotalAmt = double.tryParse(debitAmntcontroller.text) ?? 0;
      double chequeAmount = double.tryParse(creditAmntcontroller.text) ?? 0;

      print(chequeAmount);
      print(grandTotalAmt);

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
      creditBalance = chequeAmount >= grandTotalAmt ? "CREDIT BALANCE" : "DEBIT BALANCE";

      // Set the balance text with fixed string format (without "Credit" or "Debit")
      totalbalance.text = '${balanceAmount.toStringAsFixed(2)}';
    });
  }



// Assuming you have a variable like this in your widget class
  double balanceAmount = 0;
  String creditBalance = "Db";


  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/getBalance/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        // Use a Set to filter out duplicate custName values
        Set<String> uniqueCustNames = Set();

        // Filter out duplicate values based on 'custName'
        final List uniqueData = itemGroups
            .where((item) {
          String custName = item['invoiceNo']?.toString() ?? '';
          if (!uniqueCustNames.contains(custName)) {
            uniqueCustNames.add(custName);
            return true;
          }
          return false;
        })
            .toList();

        setState(() {
          data = uniqueData.cast<Map<String, dynamic>>();
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
  */
/* Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/getBalance/');
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
        // Handle error here, e.g., show an error message.
      }
    } catch (error) {
      print('Error: $error');
      // Handle error here, e.g., show an error message.
    }
  }*//*

  List<Map<String, dynamic>> filteredData = [];


  void filterData(String searchText) {
    setState(() {
      if (_FromDatecontroller.text.isNotEmpty && _ToDatecontroller.text.isNotEmpty) {
        applyDateFilter();
      } else {
        if (searchText.isEmpty) {
          filteredData = List.from(data);
        } else {
          filteredData = data.where((item) {
            String custName = item['custName']?.toString()?.toLowerCase() ?? '';
            String custCode = item['custCode']?.toString()?.toLowerCase() ?? '';
            String invoiceNo = item['invoiceNo']?.toString()?.toLowerCase() ?? '';
            String searchTextLowerCase = searchText.toLowerCase();
            return custName.contains(searchTextLowerCase) ||
                custCode.contains(searchTextLowerCase) ||
                invoiceNo.contains(searchTextLowerCase);

          }).toList();
        }
      }
      calculatechequeTotal(filteredData);
      calculateGrandTotal(filteredData);
      calculatedeductionTotal(filteredData);
      calculatereceivedTotal(filteredData);
      updateBalanceAmount();
      updateReceivedAmt();
    });
  }

*/
/*  void applyDateFilter() {
    setState(() {
      filteredData = data.where((item) {
        String dateStr = item['date']?.toString() ?? '';
        DateTime? itemDate = DateTime.tryParse(dateStr);
        return itemDate != null &&
            itemDate.isAfter(selectedDate) &&
            itemDate.isBefore(selectedToDate.add(Duration(days: 1))) &&
            (selectedCustomer.isEmpty || item['custName'] == selectedCustomer);
      }).toList();
      if (searchController.text.isNotEmpty) {
        String searchTextLowerCase = searchController.text.toLowerCase();
        filteredData = filteredData.where((item) {
          String id = item['custName']?.toString()?.toLowerCase() ?? '';
          return id.contains(searchTextLowerCase);
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
  }*//*


  void applyDateFilter() {
    setState(() {

      filteredData = data.where((item) {
        String dateStr = item['date']?.toString() ?? '';
        DateTime? itemDate = DateTime.tryParse(dateStr);

        return itemDate != null &&
            itemDate.isAfter(selectedDate) &&
            itemDate.isBefore(selectedToDate.add(Duration(days: 1)));
      }).toList();

      if (searchController.text.isNotEmpty) {
        String searchTextLowerCase = searchController.text.toLowerCase();
        filteredData = filteredData.where((item) {
          String custName = item['custName']?.toString()?.toLowerCase() ?? '';
          String custCode = item['custCode']?.toString()?.toLowerCase() ?? '';
          String invoiceNo = item['invoiceNo']?.toString()?.toLowerCase() ?? '';

          return custName.contains(searchTextLowerCase) ||
              custCode.contains(searchTextLowerCase) ||
              invoiceNo.contains(searchTextLowerCase);


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

  bool isAnyFieldNotEmpty() {
    return _FromDatecontroller.text.isNotEmpty ||
        _ToDatecontroller.text.isNotEmpty ||
        searchController.text.isNotEmpty;
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    filterData('');
  }

  @override
  void initState() {
    super.initState();
    searchController;
    updateReceivedAmt();
    updateBalanceAmount();
    //updatebalanceAmt();
    fetchData();
    fetchData().then((_) {
      setState(() {
        filteredData = List.from(data);
      });
    });
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  TextEditingController calculatorInputController = TextEditingController();
  TextEditingController answerInputController = TextEditingController();

  void _refreshControllers() {
    if (generatedButton) {
      filterData(searchController.text);
      applyDateFilter();
      calculatechequeTotal(filteredData);
      calculateGrandTotal(filteredData);
      calculatedeductionTotal(filteredData);
      calculatereceivedTotal(filteredData);
      calculatedebitTotal(filteredData);
      calculatecreditTotal(filteredData);
      updateReceivedAmt();
      updateBalanceAmount();
      // updatebalanceAmt();
    }
  }

  void _showCalculator() {
    showDialog(

      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Calculator ( + - * / )"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: calculatorInputController,
                decoration: InputDecoration(
                  hintText: "Enter Value",
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 10),
              TextField(
                controller: answerInputController,
                decoration: InputDecoration(
                    hintText: "Answer"
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _calculate();
                },
                child: Text("Calculate"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _calculate() {
    String expression = calculatorInputController.text;
    Parser p = Parser();
    ContextModel cm = ContextModel();

    try {
      Expression exp = p.parse(expression);
      double result = exp.evaluate(EvaluationType.REAL, cm);

      answerInputController.text = result.toString();
    } catch (e) {
      answerInputController.text = 'Error';
    }

    // Navigator.of(context).pop(); // Close the calculator dialog
  }


  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.of(context).size;
    var textSize = screenSize.width > 600 ? 20.0 : 16.0;

    // Determine the maximum width for the container based on the screen size
    var containerMaxWidth = screenSize.width > 600 ? 600.0 : screenSize.width;

    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    var formattedToDate = DateFormat('dd-MM-yyyy').format(selectedToDate);
    searchController.addListener(() {
      filterData(''
        // searchController.text,
        // fromselectedDate.text,
        // toselectedDate.text,
      );
    });
    return  MyScaffold(route: 'balancesheetreport', body: Form( key: _formKey,
        child: SingleChildScrollView(
          child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color:Colors.grey[50],
                      border: Border.all(color: Colors.grey), // Add a border for the box
                      borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                    ),
                    child: Wrap(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(
                                  Icons.account_balance_sharp, // Replace with the icon you want to use
                                  // Replace with the desired icon color
                                  size: 30, ),SizedBox(width: 10,),
                                Text("Balance Sheet Report", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: textSize,
                                ),),
                              ],),

                              Text(
                                errorMessage ?? '',
                                style: TextStyle(color: Colors.red),
                              ),
                            ]),

                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Wrap(
                            spacing: 15.0, // Set the horizontal spacing between the children
                            runSpacing: 20.0,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text("From Date"),
                                  // SizedBox(height: 5,),
                                  SizedBox(
                                    width: 200,
                                    height: 70,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 13),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '* Enter From Date';
                                        }
                                        return null;
                                      },
                                      onTap: () async {
                                        final pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime(2000), // Set it to an earlier date if needed
                                          lastDate: DateTime.now(), // Set the last date to the current date
                                        );
                                        if (pickedDate != null) {
                                          if (pickedDate.isBefore(selectedToDate) || pickedDate.isAtSameMomentAs(selectedToDate)) {
                                            setState(() {
                                              selectedDate = pickedDate;
                                              formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                                            });
                                            _FromDatecontroller.text = formattedDate;
                                          } else {
                                            // Show an error message or handle the case where From Date is after To Date.
                                            setState(() {
                                              errorMessage = 'From Date must be before or equal to To Date';
                                            });
                                          }
                                        }
                                      },
                                      controller: _FromDatecontroller, // Set the initial value of the field to the selected date
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.calendar_month),
                                        labelText: "From Date",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text("To Date"),
                                  // SizedBox(height: 5,),
                                  SizedBox(
                                    width: 200,
                                    height: 70,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 13),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '* Enter To Date';
                                        }
                                        return null;
                                      },
                                      onTap: () async {
                                        final pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: selectedToDate,
                                          firstDate: DateTime(2000), // Set it to an earlier date if needed
                                          lastDate: DateTime.now(), // Set the last date to the current date
                                        );
                                        if (pickedDate != null) {
                                          if (pickedDate.isAfter(selectedDate) || pickedDate.isAtSameMomentAs(selectedDate)) {
                                            setState(() {
                                              selectedToDate = pickedDate;
                                              formattedToDate = DateFormat('dd-MM-yyyy').format(selectedToDate);
                                            });
                                            _ToDatecontroller.text = formattedToDate;
                                          } else {
                                            // Show an error message or handle the case where To Date is before From Date.
                                            setState(() {
                                              errorMessage = 'To Date must be after or equal to From Date';
                                            });
                                          }
                                        }
                                      },
                                      controller: _ToDatecontroller, // Set the initial value of the field to the selected date
                                      decoration: InputDecoration(
                                          labelText: "To Date",
                                          suffixIcon: Icon(Icons.calendar_month)
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 220,
                                    height: 40,
                                    child: TypeAheadFormField<String>(
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: searchController,
                                        onChanged: (value){
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          searchController.value = searchController.value.copyWith(
                                            text: capitalizedValue,
                                            selection: TextSelection.collapsed(offset: capitalizedValue.length),);
                                        },
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
                                        // Check if the pattern is empty before providing suggestions
                                        if (pattern.isEmpty) {
                                          return [];
                                        }
                                        // TODO: Implement logic to get suggestions based on the entered pattern
                                        // For example, fetch suggestions from 'custName' values in your data.
                                        List<String> custNamesuggestions = data
                                            .where((item) =>
                                            (item['custName']?.toString()?.toLowerCase() ?? '')
                                                .startsWith(pattern.toLowerCase()))
                                            .map((item) => item['custName'].toString())
                                            .toSet() // Remove duplicates using a Set
                                            .toList();
                                        List<String> custCodesuggestions = data
                                            .where((item) =>
                                            (item['custCode']?.toString()?.toLowerCase() ?? '')
                                                .startsWith(pattern.toLowerCase()))
                                            .map((item) => item['custCode'].toString())
                                            .toSet() // Remove duplicates using a Set
                                            .toList();
                                        List<String> invoiceNosuggestions = data
                                            .where((item) =>
                                            (item['invoiceNo']?.toString()?.toLowerCase() ?? '')
                                                .startsWith(pattern.toLowerCase()))
                                            .map((item) => item['invoiceNo'].toString())
                                            .toSet() // Remove duplicates using a Set
                                            .toList();
                                        List<String> suggestions = [
                                          ...custNamesuggestions,
                                          ...custCodesuggestions,
                                          ...invoiceNosuggestions,
                                        ].toSet().toList();

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
                                ],
                              ),
                              MaterialButton(
                                color: Colors.green.shade600,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                height: 40,
                                onPressed: () {
                                  updateReceivedAmt();
                                  updateBalanceAmount();
                                  // updatebalanceAmt();
                                  if (_FromDatecontroller.text.isNotEmpty && _ToDatecontroller.text.isNotEmpty) {
                                    setState(() {
                                      errorMessage = null; // Reset error message when both fields are selected
                                    });
                                    generatedButton = true;
                                    filterData(searchController.text);
                                  } else if (searchController.text.isNotEmpty) {
                                    setState(() {
                                      errorMessage = null; // Reset error message when only custName is selected
                                    });
                                    generatedButton = true;
                                    filterData(searchController.text);
                                  } else {
                                    setState(() {
                                      errorMessage = "Select FromDate and Todate";
                                    });
                                  }
                                },
                                child: const Text("Generate", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>BalanceSheetReport()));
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalaryCalculation()));
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 1,),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(" Balance Sheet",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            // Heading
                            Container(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: FutureBuilder<List<Map<String, dynamic>>>(
                                    future: Future.value(filteredData),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        // Your table-building logic
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return CircularProgressIndicator(); // or some loading indicator
                                      }
                                      if (filteredData.isNotEmpty ||
                                          filteredData.isEmpty){
                                        calculateGrandTotal(filteredData);
                                        calculatechequeTotal(filteredData);
                                        calculatedeductionTotal(filteredData);
                                        calculatereceivedTotal(filteredData);
                                        calculatedebitTotal(filteredData);
                                        calculatecreditTotal(filteredData);
                                        return Table(
                                            border: TableBorder.all(
                                                color: Colors.black54
                                            ),
                                            defaultColumnWidth: const FixedColumnWidth(605.0),
                                            columnWidths: const <int, TableColumnWidth>{
                                              0: FixedColumnWidth(52),
                                              1: FixedColumnWidth(110),
                                              2: FixedColumnWidth(115),
                                              3: FixedColumnWidth(115),
                                              4: FixedColumnWidth(115),
                                              5: FixedColumnWidth(140),
                                              6: FixedColumnWidth(80),
                                              7: FixedColumnWidth(80),
                                              8: FixedColumnWidth(80),
                                              9: FixedColumnWidth(80),
                                              10: FixedColumnWidth(80),
                                              11: FixedColumnWidth(80),
                                            },
                                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                            children:[
                                              //Table row starting
                                              TableRow(children: [
                                                TableCell(
                                                  child: Container(
                                                    color: Colors.blue.shade200,
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(height: 15,),
                                                          Text('S.No',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 15,)
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
                                                          const SizedBox(height: 15,),
                                                          Text('Date',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 15,)
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
                                                          const SizedBox(height: 8,),
                                                          Text('Invoice\n'
                                                              'Number',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 8,)
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
                                                          const SizedBox(height: 8,),
                                                          Text('Cheque\n Number',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 8,)
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
                                                          const SizedBox(height: 8,),
                                                          Text('Customer \n Code',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 8,)
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
                                                          const SizedBox(height: 8,),
                                                          Text('Customer/\nCompany Name',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 8,)
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
                                                          const SizedBox(height: 8,),
                                                          Text('Invoice \nAmount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 8,)
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
                                                          const SizedBox(height: 8,),
                                                          Text('Cheque \nAmount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 8,)
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
                                                          const SizedBox(height: 8,),
                                                          Text('Deduction\n Amount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 8,)
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
                                                          const SizedBox(height: 8,),
                                                          Text('Received \n Amount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 8,)
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
                                                          const SizedBox(height: 8,),
                                                          Text('Debit \n Amount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 8,)
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
                                                          const SizedBox(height: 8,),
                                                          Text('Credit \nAmount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                          const SizedBox(height: 8,)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                              if (generatedButton)
                                                for (var i = 0; i < filteredData.length; i++) ...[
                                                  TableRow(
                                                    children: [
                                                      // 1 s.no
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Text("${i + 1}"),
                                                              const SizedBox(height: 10,),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Text(
                                                                DateFormat('dd-MM-yyyy').format(DateTime.parse(filteredData[i]["date"])),
                                                                style: TextStyle(),
                                                              ),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Text("${filteredData[i]["invoiceNo"]}"),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Text("${filteredData[i]["chequeNo"]}"),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Text("${filteredData[i]["custCode"]}",
                                                              ),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Text("${filteredData[i]["custName"]}",
                                                              ),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Align(
                                                                  alignment:Alignment.topRight,
                                                                  child: Text("${filteredData[i]["grandTotal"] ?? ""}",
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Align(
                                                                alignment:Alignment.topRight,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Text("${filteredData[i]["chequeAmt"] ?? ""}",
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Align(
                                                                alignment:Alignment.topRight,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Text("${filteredData[i]["deductionAmt"] ?? ""}",
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Align(
                                                                alignment:Alignment.topRight,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Text("${filteredData[i]["receivedAmt"] ?? ""}",
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Align(
                                                                alignment:Alignment.topRight,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Text("${filteredData[i]["debit"] ?? ""}",
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(height: 10,),
                                                              Align(
                                                                alignment:Alignment.topRight,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Text("${filteredData[i]["credit"] ?? ""}",
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10,)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                            ]
                                        );}
                                      return Container();
                                    }
                                ),
                              ),
                            ),

                            if(generatedButton)
                              Padding(
                                padding: const EdgeInsets.only(right:0.0),
                                child: Wrap(
                                    children:[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.calculate),
                                            onPressed: () {
                                              _showCalculator();
                                            },
                                          ),
                                          Text("GrandTotal",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                          Icon(Icons.currency_rupee,size: 15,),
                                          SizedBox(width: 10,),
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: 12),
                                                  readOnly: true,
                                                  controller:  grandTotalController,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    semanticCounterText: AutofillHints.streetAddressLevel1,
                                                    // labelText: "Grand Total of invoice Amount",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: 12),
                                                  readOnly: true,
                                                  controller: chequeAmntcontroller,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    // labelText: "Total",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: 12),
                                                  readOnly: true,
                                                  controller: deductionAmntcontroller,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    // labelText: "Total",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: 12),
                                                  readOnly: true,
                                                  controller: receivedAmntcontroller,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    // labelText: "Total",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: 12),
                                                  readOnly: true,
                                                  controller: debitAmntcontroller,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    // labelText: "Total",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: 12),
                                                  readOnly: true,
                                                  controller: creditAmntcontroller,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    // labelText: "Total",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ]
                                ),
                              ),
                            if(generatedButton)
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 230,
                                        height: 50,
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: totalbalance,
                                          decoration: InputDecoration(
                                            // Add this line to set prefix text
                                            prefixText: creditBalance == "CREDIT BALANCE" ? "CREDIT BALANCE: " : "DEBIT BALANCE: ",
                                            prefixStyle: TextStyle(
                                              color: creditBalance == "CREDIT BALANCE" ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            // labelText: "Total",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],)
                          ],
                        ),
                      ),
                    ),],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // if(generatedButton==true)
                      if(generatedButton)
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                          child: MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: (){
                              String TotalgrandTotal = grandTotalController.text;
                              String TotalchequeAmnt = chequeAmntcontroller.text;
                              String TotaldeductionAmnt = deductionAmntcontroller.text;
                              String TotalreceivedAmnt = receivedAmntcontroller.text;
                              String TotaldebitAmnt = debitAmntcontroller.text;
                              String TotalcreditdAmnt = creditAmntcontroller.text;
                              String balance = totalbalance.text;

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BalanaceSheetPDF(
                                        customerData: filteredData,
                                        TotalgrandTotal: TotalgrandTotal,
                                        TotaldeductionAmnt: TotaldeductionAmnt,
                                        TotalreceivedAmnt: TotalreceivedAmnt,
                                        TotalchequeAmnt: TotalchequeAmnt,
                                        TotaldebitAmnt:TotaldebitAmnt,
                                        TotalcreditdAmnt:TotalcreditdAmnt,
                                        balance:balance,
                                        creditBalance: creditBalance,
                                      )));
                            },child: const Text("PRINT",style: TextStyle(color: Colors.white),),),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                        child: MaterialButton(
                          color: Colors.red.shade600,
                          onPressed: (){
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
                          child: Text("CANCEL",style: TextStyle(color: Colors.white),),),
                      ),
                    ],
                  ),
                )
              ]), )));
  }
}


*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import '../home.dart';
import 'balancesheet_pdf.dart';

class BalanceSheetReport extends StatefulWidget {
  const BalanceSheetReport({Key? key}) : super(key: key);

  @override
  State<BalanceSheetReport> createState() => _BalanceSheetReportState();
}

class _BalanceSheetReportState extends State<BalanceSheetReport> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  List<Map<String, dynamic>> data = [];
  TextEditingController searchController = TextEditingController();
  String selectedCustomer = '';
  TextEditingController invoiceNo = TextEditingController();
  final TextEditingController toselectedDate = TextEditingController();
  final TextEditingController fromselectedDate = TextEditingController();
  TextEditingController grandTotalController = TextEditingController();
  TextEditingController deductionAmntcontroller = TextEditingController();
  TextEditingController receivedAmntcontroller = TextEditingController();
  TextEditingController debitAmntcontroller = TextEditingController();
  TextEditingController creditAmntcontroller = TextEditingController();
  TextEditingController chequeAmntcontroller = TextEditingController();
  final TextEditingController  _FromDatecontroller = TextEditingController();
  final TextEditingController  _ToDatecontroller = TextEditingController();
  TextEditingController totalvalue = TextEditingController();
  TextEditingController totalbalance = TextEditingController();
  final ScrollController _scrollController = ScrollController();




  String? errorMessage;
  bool generatedButton = false;
  bool isDataLoaded = false;
  DateTime? fromDate;
  DateTime? toDate;


  void calculatechequeTotal(List<Map<String, dynamic>> data) {
    double grandTotal = 0.0;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["chequeAmt"]}");
      grandTotal += totalAmount;
    }
    chequeAmntcontroller.text = grandTotal.toStringAsFixed(2);
  }

  void calculateGrandTotal(List<Map<String, dynamic>> data) {
    double grandTotal = 0.0;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["grandTotal"]}");
      grandTotal += totalAmount;
    }
    grandTotalController.text = grandTotal.toStringAsFixed(2);
  }

  void calculatedeductionTotal(List<Map<String, dynamic>> data) {
    double deductionAmt = 0.0;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["deductionAmt"]}");
      deductionAmt += totalAmount;
    }
    deductionAmntcontroller.text = deductionAmt.toStringAsFixed(2);
  }

  void calculatereceivedTotal(List<Map<String, dynamic>> data) {
    double receivedAmt = 0.00;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["receivedAmt"]}");
      receivedAmt += totalAmount;
    }
    receivedAmntcontroller.text = receivedAmt.toStringAsFixed(2);
  }

  void calculatedebitTotal(List<Map<String, dynamic>> data) {
    double debitAmt = 0.00;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["debit"]}");
      debitAmt += totalAmount;
    }
    debitAmntcontroller.text = debitAmt.toStringAsFixed(2);
  }

  void calculatecreditTotal(List<Map<String, dynamic>> data) {
    double creditAmt = 0.00;
    for (var i = 0; i < filteredData.length; i++) {
      double totalAmount = double.parse("${data[i]["credit"]}");
      creditAmt += totalAmount;
    }
    creditAmntcontroller.text = creditAmt.toStringAsFixed(2);
  }

  void updateReceivedAmt() {
    setState(() {
      double chequeAmount = double.tryParse(grandTotalController.text) ?? 0;
      double deductionAmount = double.tryParse(chequeAmntcontroller.text) ?? 0;
      double calculatedReceivedAmt = chequeAmount - deductionAmount;
      totalvalue.text = calculatedReceivedAmt.toStringAsFixed(2);
    });
  }

/*  void updatebalanceAmt() {
    setState(() {
      double debittotalAmount = double.tryParse(debitAmntcontroller.text) ?? 0;
      double credittotalAmount = double.tryParse(creditAmntcontroller.text) ?? 0;
      double calculatedReceivedAmt = debittotalAmount - credittotalAmount;
      totalbalance.text = calculatedReceivedAmt.toStringAsFixed(2);
    });
  }*/



  void updateBalanceAmount() {
    setState(() {
      double grandTotalAmt = double.tryParse(debitAmntcontroller.text) ?? 0;
      double chequeAmount = double.tryParse(creditAmntcontroller.text) ?? 0;

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
      creditBalance = chequeAmount >= grandTotalAmt ? "CREDIT BALANCE" : "DEBIT BALANCE";

      // Set the balance text with fixed string format (without "Credit" or "Debit")
      totalbalance.text = '${balanceAmount.toStringAsFixed(2)}';
    });
  }



// Assuming you have a variable like this in your widget class
  double balanceAmount = 0;
  String creditBalance = "Db";

  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/getBalance/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        // Use a Set to filter out duplicate custName values
        Set<String> uniqueCustNames = Set();

        // Filter out duplicate values based on 'custName'
        final List uniqueData = itemGroups
            .where((item) {
          String custName = item['invoiceNo']?.toString() ?? '';
          if (!uniqueCustNames.contains(custName)) {
            uniqueCustNames.add(custName);
            return true;
          }
          return false;
        })
            .toList();

        setState(() {
          data = uniqueData.cast<Map<String, dynamic>>();
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
  List<Map<String, dynamic>> filteredData = [];


  void filterData(String searchText) {
    setState(() {
      if (_FromDatecontroller.text.isNotEmpty && _ToDatecontroller.text.isNotEmpty) {
        applyDateFilter();
      } else {
        if (searchText.isEmpty) {
          //filteredData = List.from(data);
        } else {
          filteredData = data.where((item) {
            String id = item['custName']?.toString()?.toLowerCase() ?? '';
            String custCode = item['custCode']?.toString()?.toLowerCase() ?? '';
            String invoiceNo = item['invoiceNo']?.toString()?.toLowerCase() ?? '';
            String searchTextLowerCase = searchText.toLowerCase();
            return id.contains(searchTextLowerCase) ||
                custCode.contains(searchTextLowerCase) ||
                invoiceNo.contains(searchTextLowerCase);
          }).toList();
        }
      }
      calculatechequeTotal(filteredData);
      calculateGrandTotal(filteredData);
      calculatedeductionTotal(filteredData);
      calculatereceivedTotal(filteredData);
      calculatedebitTotal(filteredData);
      calculatecreditTotal(filteredData);
      //updatebalanceAmt();
      updateBalanceAmount();
      updateReceivedAmt();
    });
  }

/*  void applyDateFilter() {
    setState(() {
      filteredData = data.where((item) {
        String dateStr = item['date']?.toString() ?? '';
        DateTime? itemDate = DateTime.tryParse(dateStr);
        return itemDate != null &&
            itemDate.isAfter(selectedDate) &&
            itemDate.isBefore(selectedToDate.add(Duration(days: 1))) &&
            (selectedCustomer.isEmpty || item['custName'] == selectedCustomer);
      }).toList();
      if (searchController.text.isNotEmpty) {
        String searchTextLowerCase = searchController.text.toLowerCase();
        filteredData = filteredData.where((item) {
          String id = item['custName']?.toString()?.toLowerCase() ?? '';
          return id.contains(searchTextLowerCase);
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
  }*/

  void applyDateFilter() {
    setState(() {

      filteredData = data.where((item) {
        String dateStr = item['date']?.toString() ?? '';
        DateTime? itemDate = DateTime.tryParse(dateStr);

        return itemDate != null &&
            itemDate.isAfter(selectedDate) &&
            itemDate.isBefore(selectedToDate.add(Duration(days: 1))) &&
            (selectedCustomer.isEmpty || item['custName'] == selectedCustomer);
      }).toList();

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

  bool isAnyFieldNotEmpty() {
    return _FromDatecontroller.text.isNotEmpty ||
        _ToDatecontroller.text.isNotEmpty ||
        searchController.text.isNotEmpty;
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    filterData('');
  }

  @override
  void initState() {
    super.initState();
    searchController;
    updateReceivedAmt();
    updateBalanceAmount();
    //updatebalanceAmt();
    fetchData();
    fetchData().then((_) {
      setState(() {
        filteredData = List.from(data);
      });
    });
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  TextEditingController calculatorInputController = TextEditingController();
  TextEditingController answerInputController = TextEditingController();

  void _refreshControllers() {
    if (generatedButton) {
      filterData(searchController.text);
      applyDateFilter();
      calculatechequeTotal(filteredData);
      calculateGrandTotal(filteredData);
      calculatedeductionTotal(filteredData);
      calculatereceivedTotal(filteredData);
      calculatedebitTotal(filteredData);
      calculatecreditTotal(filteredData);
      updateReceivedAmt();
      updateBalanceAmount();
      // updatebalanceAmt();
    }
  }

  void _showCalculator() {
    showDialog(

      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Calculator ( + - * / )"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: calculatorInputController,
                decoration: InputDecoration(
                  hintText: "Enter Value",
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 10),
              TextField(
                controller: answerInputController,
                decoration: InputDecoration(
                    hintText: "Answer"
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _calculate();
                },
                child: Text("Calculate"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _calculate() {
    String expression = calculatorInputController.text;
    Parser p = Parser();
    ContextModel cm = ContextModel();

    try {
      Expression exp = p.parse(expression);
      double result = exp.evaluate(EvaluationType.REAL, cm);

      answerInputController.text = result.toString();
    } catch (e) {
      answerInputController.text = 'Error';
    }

    // Navigator.of(context).pop(); // Close the calculator dialog
  }


  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.of(context).size;
    var textSize = screenSize.width > 600 ? 20.0 : 16.0;

    // Determine the maximum width for the container based on the screen size
    var containerMaxWidth = screenSize.width > 600 ? 600.0 : screenSize.width;

    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    var formattedToDate = DateFormat('dd-MM-yyyy').format(selectedToDate);
    searchController.addListener(() {
      filterData(''
        // searchController.text,
        // fromselectedDate.text,
        // toselectedDate.text,
      );
    });
    return  MyScaffold(route: 'balancesheetreport', body: Form( key: _formKey,
        child: SingleChildScrollView(
          child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color:Colors.grey[50],
                      border: Border.all(color: Colors.grey), // Add a border for the box
                      borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                    ),
                    child: Wrap(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(
                                  Icons.account_balance_sharp, // Replace with the icon you want to use
                                  // Replace with the desired icon color
                                  size: 30, ),SizedBox(width: 10,),
                                Text("Balance Sheet Report", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: textSize,
                                ),),
                              ],),

                              Text(
                                errorMessage ?? '',
                                style: TextStyle(color: Colors.red),
                              ),
                            ]),

                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Wrap(
                            spacing: 15.0, // Set the horizontal spacing between the children
                            runSpacing: 20.0,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text("From Date"),
                                  // SizedBox(height: 5,),
                                  SizedBox(
                                    width: 200,
                                    height: 70,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 13),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '* Enter From Date';
                                        }
                                        return null;
                                      },
                                      onTap: () async {
                                        final pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime(2000), // Set it to an earlier date if needed
                                          lastDate: DateTime.now(), // Set the last date to the current date
                                        );
                                        if (pickedDate != null) {
                                          if (pickedDate.isBefore(selectedToDate) || pickedDate.isAtSameMomentAs(selectedToDate)) {
                                            setState(() {
                                              selectedDate = pickedDate;
                                              formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                                            });
                                            _FromDatecontroller.text = formattedDate;
                                          } else {
                                            // Show an error message or handle the case where From Date is after To Date.
                                            setState(() {
                                              errorMessage = 'From Date must be before or equal to To Date';
                                            });
                                          }
                                        }
                                      },
                                      controller: _FromDatecontroller, // Set the initial value of the field to the selected date
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.calendar_month),
                                        labelText: "From Date",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text("To Date"),
                                  // SizedBox(height: 5,),
                                  SizedBox(
                                    width: 200,
                                    height: 70,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 13),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '* Enter To Date';
                                        }
                                        return null;
                                      },
                                      onTap: () async {
                                        final pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: selectedToDate,
                                          firstDate: DateTime(2000), // Set it to an earlier date if needed
                                          lastDate: DateTime.now(), // Set the last date to the current date
                                        );
                                        if (pickedDate != null) {
                                          if (pickedDate.isAfter(selectedDate) || pickedDate.isAtSameMomentAs(selectedDate)) {
                                            setState(() {
                                              selectedToDate = pickedDate;
                                              formattedToDate = DateFormat('dd-MM-yyyy').format(selectedToDate);
                                            });
                                            _ToDatecontroller.text = formattedToDate;
                                          } else {
                                            // Show an error message or handle the case where To Date is before From Date.
                                            setState(() {
                                              errorMessage = 'To Date must be after or equal to From Date';
                                            });
                                          }
                                        }
                                      },
                                      controller: _ToDatecontroller, // Set the initial value of the field to the selected date
                                      decoration: InputDecoration(
                                          labelText: "To Date",
                                          suffixIcon: Icon(Icons.calendar_month)
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: containerMaxWidth > 220 ? 220 : containerMaxWidth,
                                    //width: 220,
                                    height: 40,
                                    child: TypeAheadFormField<String>(
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: searchController,
                                        onChanged: (value){
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          searchController.value = searchController.value.copyWith(
                                            text: capitalizedValue,
                                            selection: TextSelection.collapsed(offset: capitalizedValue.length),);
                                        },
                                        style: const TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          suffixIcon: Icon(Icons.search),
                                          fillColor: Colors.white,
                                          filled: true,
                                          labelText: "Customer/Company Name",
                                          labelStyle: TextStyle(fontSize: 13),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      suggestionsCallback: (pattern) async {
                                        // Check if the pattern is empty before providing suggestions
                                        if (pattern.isEmpty) {
                                          return [];
                                        }
                                        // TODO: Implement logic to get suggestions based on the entered pattern
                                        // For example, fetch suggestions from 'custName' values in your data.
                                        List<String> custNamesuggestions = data
                                            .where((item) =>
                                            (item['custName']?.toString()?.toLowerCase() ?? '')
                                                .startsWith(pattern.toLowerCase()))
                                            .map((item) => item['custName'].toString())
                                            .toSet() // Remove duplicates using a Set
                                            .toList();
                                        List<String> custCodesuggestions = data
                                            .where((item) =>
                                            (item['custCode']?.toString()?.toLowerCase() ?? '')
                                                .startsWith(pattern.toLowerCase()))
                                            .map((item) => item['custCode'].toString())
                                            .toSet() // Remove duplicates using a Set
                                            .toList();
                                        List<String> invoiceNosuggestions = data
                                            .where((item) =>
                                            (item['invoiceNo']?.toString()?.toLowerCase() ?? '')
                                                .startsWith(pattern.toLowerCase()))
                                            .map((item) => item['invoiceNo'].toString())
                                            .toSet() // Remove duplicates using a Set
                                            .toList();
                                        List<String> suggestions = [
                                          ...custNamesuggestions,
                                          ...custCodesuggestions,
                                          ...invoiceNosuggestions,
                                        ].toSet().toList();

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
                                ],
                              ),
                              MaterialButton(
                                color: Colors.green.shade600,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                height: 40,
                                onPressed: () {
                                  updateReceivedAmt();
                                  updateBalanceAmount();
                                  // updatebalanceAmt();
                                  if (_FromDatecontroller.text.isNotEmpty && _ToDatecontroller.text.isNotEmpty) {
                                    setState(() {
                                      errorMessage = null; // Reset error message when both fields are selected
                                    });
                                    generatedButton = true;
                                    filterData(searchController.text);
                                  } else if (searchController.text.isNotEmpty) {
                                    setState(() {
                                      errorMessage = null; // Reset error message when only custName is selected
                                    });
                                    generatedButton = true;
                                    filterData(searchController.text);
                                  } else {
                                    setState(() {
                                      errorMessage = "Select FromDate and Todate";
                                    });
                                  }
                                },
                                child: const Text("Generate", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 1,),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(" Balance Sheet",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            // Heading
                            Container(
                              child: Scrollbar(
                                thumbVisibility: true,
                                controller: _scrollController,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _scrollController,
                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                      future: Future.value(filteredData),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          // Your table-building logic
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else {
                                          return CircularProgressIndicator(); // or some loading indicator
                                        }
                                        if (filteredData.isNotEmpty ||
                                            filteredData.isEmpty){
                                          calculateGrandTotal(filteredData);
                                          calculatechequeTotal(filteredData);
                                          calculatedeductionTotal(filteredData);
                                          calculatereceivedTotal(filteredData);
                                          calculatedebitTotal(filteredData);
                                          calculatecreditTotal(filteredData);
                                          return Table(
                                              border: TableBorder.all(
                                                  color: Colors.black54
                                              ),
                                              defaultColumnWidth: const FixedColumnWidth(605.0),
                                              columnWidths: const <int, TableColumnWidth>{
                                                0: FixedColumnWidth(52),
                                                1: FixedColumnWidth(110),
                                                2: FixedColumnWidth(120),
                                                3: FixedColumnWidth(100),
                                                4: FixedColumnWidth(100),
                                                5: FixedColumnWidth(140),
                                                6: FixedColumnWidth(110),
                                                7: FixedColumnWidth(110),
                                                8: FixedColumnWidth(110),
                                                9: FixedColumnWidth(110),
                                                10: FixedColumnWidth(110),
                                                11: FixedColumnWidth(110),
                                              },
                                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                              children:[
                                                //Table row starting
                                                TableRow(children: [
                                                  TableCell(
                                                    child: Container(
                                                      color: Colors.blue.shade200,
                                                      child: Center(
                                                        child: Column(
                                                          children: [
                                                            const SizedBox(height: 15,),
                                                            Text('S.No',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 15,)
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
                                                            const SizedBox(height: 15,),
                                                            Text('Date',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 15,)
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
                                                            const SizedBox(height: 8,),
                                                            Text('Invoice\n'
                                                                'Number',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8,)
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
                                                            const SizedBox(height: 8,),
                                                            Text('Cheque\n Number',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8,)
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
                                                            const SizedBox(height: 8,),
                                                            Text('Customer \n Code',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8,)
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
                                                            const SizedBox(height: 8,),
                                                            Text('Customer/\nCompany Name',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8,)
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
                                                            const SizedBox(height: 8,),
                                                            Text('Invoice \nAmount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8,)
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
                                                            const SizedBox(height: 8,),
                                                            Text('Cheque \nAmount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8,)
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
                                                            const SizedBox(height: 8,),
                                                            Text('Deduction\n Amount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8,)
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
                                                            const SizedBox(height: 8,),
                                                            Text('Received \n Amount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8,)
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
                                                            const SizedBox(height: 8,),
                                                            Text('Debit \n Amount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8,)
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
                                                            const SizedBox(height: 8,),
                                                            Text('Credit \nAmount',style: TextStyle(fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8,)
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                                if (generatedButton)
                                                  for (var i = 0; i < filteredData.length; i++) ...[
                                                    TableRow(
                                                      children: [
                                                        // 1 s.no
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Text("${i + 1}"),
                                                                const SizedBox(height: 10,),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Text(
                                                                  DateFormat('dd-MM-yyyy').format(DateTime.parse(filteredData[i]["date"])),
                                                                  style: TextStyle(),
                                                                ),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 20,right: 10),
                                                            child: Column(
                                                              //crossAxisAlignment: CrossAxisAlignment.center, // Center children vertically
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Text("${filteredData[i]["invoiceNo"]}"),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Text("${filteredData[i]["chequeNo"]}"),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Text("${filteredData[i]["custCode"]}",
                                                                ),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Text("${filteredData[i]["custName"]}",
                                                                ),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Align(
                                                                    alignment:Alignment.topRight,
                                                                    child: Text("${filteredData[i]["grandTotal"] ?? ""}",
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Align(
                                                                  alignment:Alignment.topRight,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Text("${filteredData[i]["chequeAmt"] ?? ""}",
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Align(
                                                                  alignment:Alignment.topRight,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Text("${filteredData[i]["deductionAmt"] ?? ""}",
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Align(
                                                                  alignment:Alignment.topRight,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Text("${filteredData[i]["receivedAmt"] ?? ""}",
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Align(
                                                                  alignment:Alignment.topRight,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Text("${filteredData[i]["debit"] ?? ""}",
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(height: 10,),
                                                                Align(
                                                                  alignment:Alignment.topRight,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Text("${filteredData[i]["credit"] ?? ""}",
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 10,)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],

                                                if(generatedButton)
                                                  TableRow(

                                                      children: [
                                                        TableCell(
                                                          child: Text(""),
                                                        ),  /// s.no
                                                        TableCell(
                                                          child: Text(""),
                                                        ), ///date
                                                        TableCell(
                                                          child: Text(""),
                                                        ), /// invoice no
                                                        TableCell(
                                                          child: Text(""),
                                                        ), /// cheque No
                                                        TableCell(
                                                          child: Text(""),
                                                        ), /// customer code
                                                        TableCell(
                                                          child: Row(
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(Icons.calculate),
                                                                onPressed: () {
                                                                  _showCalculator();
                                                                },
                                                              ),
                                                              Text("GrandTotal", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                              //Icon(Icons.currency_rupee, size: 12),
                                                            ],
                                                          ),
                                                        ),  /// grand total & company name
                                                        TableCell(
                                                            child:  Padding (
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end, // Align the content to the end of the row
                                                                children: [
                                                                  Icon(Icons.currency_rupee, size: 12),
                                                                  Text(
                                                                    grandTotalController.text, // Display the value from grandTotalController
                                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                                    textAlign: TextAlign.right,
                                                                  ),
                                                                ],
                                                              ),
                                                            ) ),///invoice amt
                                                        TableCell(
                                                            child:  Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end, // Align the content to the end of the row
                                                                children: [
                                                                  Icon(Icons.currency_rupee, size: 12),

                                                                  Text(
                                                                    chequeAmntcontroller.text, // Display the value from grandTotalController
                                                                    style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                                                                    textAlign: TextAlign.right,
                                                                  ),
                                                                ],
                                                              ),
                                                            ) ), ///chequ amt
                                                        TableCell(
                                                            child:  Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end, // Align the content to the end of the row
                                                                children: [
                                                                  Icon(Icons.currency_rupee, size: 12),
                                                                  Text(
                                                                    deductionAmntcontroller.text, // Display the value from grandTotalController
                                                                    style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                                                                    textAlign: TextAlign.right,
                                                                  ),
                                                                ],
                                                              ),
                                                            ) ), /// ded amt
                                                        TableCell(
                                                            child:  Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end, // Align the content to the end of the row
                                                                children: [
                                                                  Icon(Icons.currency_rupee, size: 12),

                                                                  Text(
                                                                    receivedAmntcontroller.text, // Display the value from grandTotalController
                                                                    style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                                                                    textAlign: TextAlign.right,
                                                                  ),
                                                                ],
                                                              ),
                                                            ) ), ///recevived amt
                                                        TableCell(
                                                            child:  Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end, // Align the content to the end of the row

                                                                children: [
                                                                  Icon(Icons.currency_rupee, size: 12),

                                                                  Text(
                                                                    debitAmntcontroller.text, // Display the value from grandTotalController
                                                                    style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                                                                    textAlign: TextAlign.right,
                                                                  ),
                                                                ],
                                                              ),
                                                            ) ), /// debit amt
                                                        TableCell(
                                                            child:  Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end, // Align the content to the end of the row
                                                                children: [
                                                                  Icon(Icons.currency_rupee, size: 12),

                                                                  Text(
                                                                    creditAmntcontroller.text, // Display the value from grandTotalController
                                                                    style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                                                                    textAlign: TextAlign.right,
                                                                  ),
                                                                ],
                                                              ),
                                                            ) ), /// credit amt


                                                      ]

                                                  ),
                                              ]
                                          );}
                                        return Container();
                                      }
                                  ),
                                ),
                              ),
                            ),

                            /* if(generatedButton)
                               Wrap(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,

                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.calculate),
                                          onPressed: () {
                                            _showCalculator();
                                          },
                                        ),
                                        Text("GrandTotal",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                        Icon(Icons.currency_rupee,size: 15,),
                                        SizedBox(width: 10,),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: TextFormField(
                                                style: TextStyle(fontSize: 12),
                                                readOnly: true,
                                                controller:  grandTotalController,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  semanticCounterText: AutofillHints.streetAddressLevel1,
                                                  // labelText: "Grand Total of invoice Amount",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: TextFormField(
                                                style: TextStyle(fontSize: 12),
                                                readOnly: true,
                                                controller: chequeAmntcontroller,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  // labelText: "Total",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: TextFormField(
                                                style: TextStyle(fontSize: 12),
                                                readOnly: true,
                                                controller: deductionAmntcontroller,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  // labelText: "Total",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: TextFormField(
                                                style: TextStyle(fontSize: 12),
                                                readOnly: true,
                                                controller: receivedAmntcontroller,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  // labelText: "Total",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: TextFormField(
                                                style: TextStyle(fontSize: 12),
                                                readOnly: true,
                                                controller: debitAmntcontroller,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  // labelText: "Total",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: TextFormField(
                                                style: TextStyle(fontSize: 12),
                                                readOnly: true,
                                                controller: creditAmntcontroller,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  // labelText: "Total",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),*/

                            if(generatedButton)
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 230,
                                        height: 50,
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: totalbalance,
                                          decoration: InputDecoration(
                                            // Add this line to set prefix text
                                            prefixText: creditBalance == "CREDIT BALANCE" ? "CREDIT BALANCE: " : "DEBIT BALANCE: ",
                                            prefixStyle: TextStyle(
                                              color: creditBalance == "CREDIT BALANCE" ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            // labelText: "Total",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],)
                          ],
                        ),
                      ),
                    ),],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // if(generatedButton==true)
                      if(generatedButton)
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                          child: MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: (){
                              String TotalgrandTotal = grandTotalController.text;
                              String TotalchequeAmnt = chequeAmntcontroller.text;
                              String TotaldeductionAmnt = deductionAmntcontroller.text;
                              String TotalreceivedAmnt = receivedAmntcontroller.text;
                              String TotaldebitAmnt = debitAmntcontroller.text;
                              String TotalcreditdAmnt = creditAmntcontroller.text;
                              String balance = totalbalance.text;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BalanaceSheetPDF(
                                        customerData: filteredData,
                                        TotalgrandTotal: TotalgrandTotal,
                                        TotaldeductionAmnt: TotaldeductionAmnt,
                                        TotalreceivedAmnt: TotalreceivedAmnt,
                                        TotalchequeAmnt: TotalchequeAmnt,
                                        TotaldebitAmnt:TotaldebitAmnt,
                                        TotalcreditdAmnt:TotalcreditdAmnt,
                                        balance:balance,
                                        creditBalance: creditBalance,
                                      )));
                            },child: const Text("PRINT",style: TextStyle(color: Colors.white),),),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                        child: MaterialButton(
                          color: Colors.red.shade600,
                          onPressed: (){
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
                          child: Text("CANCEL",style: TextStyle(color: Colors.white),),),
                      ),
                    ],
                  ),
                )
              ]), )), backgroundColor: Colors.white,);
  }
}


