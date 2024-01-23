import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/purchase_individual_report.dart';
import 'package:vinayaga_project/purchase/purchase_overall_report.dart';
import 'package:vinayaga_project/purchase/purchase_report_view.dart';

import '../home.dart';
import 'no_return_purchase_individual_pdf.dart';

class PurchaseReport extends StatefulWidget {
  const PurchaseReport({Key? key}) : super(key: key);
  @override
  State<PurchaseReport> createState() => _PurchaseReportState();
}
class _PurchaseReportState extends State<PurchaseReport> {
  DateTime selectedDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  TextEditingController searchController = TextEditingController();
  String toselecteddate ='' ;
  String fromselecteddate = '';
  List<Map<String, dynamic>> data = [];
  final TextEditingController toselectedDate = TextEditingController();
  final TextEditingController fromselectedDate = TextEditingController();
  final TextEditingController  _FromDatecontroller = TextEditingController();
  final TextEditingController  _ToDatecontroller = TextEditingController();
  TextEditingController custCode = TextEditingController();
  List<Map<String, dynamic>> filteredData = [];
  bool generatedButton = false;
  int numberOfRowsToShow = 25;
  String? errorMessage;
  List<Map<String, dynamic>> customerdata = [];
  String selectedSupplier = '';
  bool showSuggestions = false;

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
    fetchData().then((_) {
      setState(() {
        filteredData = List.from(data);
      });
    });
  }


  // @override
  // void initState() {
  //   super.initState();
  //   fetchData();
  //   _searchFocus.requestFocus();
  //   filteredData = List.from(data);
  // }


  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/filter_purchase_report/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        // Use a set to store unique invoice numbers
        Set<String> uniqueInvoiceNumbers = Set();

        // Filter out duplicates based on invoiceNo
        List<Map<String, dynamic>> uniqueData = [];
        for (var item in itemGroups) {
          String invoiceNo = item['invoiceNo'];
          if (!uniqueInvoiceNumbers.contains(invoiceNo)) {
            uniqueInvoiceNumbers.add(invoiceNo);
            uniqueData.add(item);
          }
        }

        // Sort the unique data by date
        uniqueData.sort((a, b) {
          DateTime dateTimeA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(0);
          DateTime dateTimeB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(0);
          return dateTimeB.compareTo(dateTimeA); // Sort in descending order
        });

        setState(() {
          data = uniqueData;
        });

        print('Data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  FocusNode _searchFocus = FocusNode();

  bool isAnyFieldNotEmpty() {
    return _FromDatecontroller.text.isNotEmpty ||
        _ToDatecontroller.text.isNotEmpty ||
        searchController.text.isNotEmpty;
  }

  void filterData(String searchText) {
    setState(() {
      if (_FromDatecontroller.text.isNotEmpty && _ToDatecontroller.text.isNotEmpty) {
        applyDateFilter();
      } else {
        if (searchText.isEmpty) {
          filteredData = List.from(data);
        } else {
          filteredData = data.where((item) {
            String supName = item['supName']?.toString()?.toLowerCase() ?? '';
            String supCode = item['supCode']?.toString()?.toLowerCase() ?? '';
            String invoiceNo = item['invoiceNo']?.toString()?.toLowerCase() ?? '';
            String searchTextLowerCase = searchText.toLowerCase();
            return supName.contains(searchTextLowerCase) ||
                supCode.contains(searchTextLowerCase) ||
                invoiceNo.contains(searchTextLowerCase);

          }).toList();
        }
      }
    });
  }

  double calculateTotal(List<Map<String, dynamic>> filteredData) {
    double totalSalary = 0;
    for (var row in filteredData) {
      totalSalary += double.parse(row['grandTotal'] ?? '0');
    }
    return totalSalary;
  }

  double Grandtotal = 0;
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
          String supName = item['supName']?.toString()?.toLowerCase() ?? '';
          String supCode = item['supCode']?.toString()?.toLowerCase() ?? '';
          String invoiceNo = item['invoiceNo']?.toString()?.toLowerCase() ?? '';

          return supName.contains(searchTextLowerCase) ||
              supCode.contains(searchTextLowerCase) ||
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
      Grandtotal = calculateTotal(filteredData);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    filterData('');
  }

  @override
  Widget build(BuildContext context) {
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    var formattedToDate = DateFormat('dd-MM-yyyy').format(selectedToDate);
    // searchController.addListener(() {
    //   filterData(''
    //     // searchController.text,
    //     // fromselectedDate.text,
    //     // toselectedDate.text,
    //   );
    // });


    return MyScaffold(
      route: "purchase_report",
      body: SingleChildScrollView(
        child: Form(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 10,),
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
                                  Icons.shopping_cart, // Replace with the icon you want to use
                                  // Replace with the desired icon color
                                ),
                                const Text("Purchase Report", style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22
                                ),),
                              ],),
                              Text(
                                errorMessage ?? '',
                                style: TextStyle(color: Colors.red),
                              ),
                            ]),
                        Padding(
                          padding: const EdgeInsets.only(top:20.0),
                          child: Wrap(
                            children: [
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
                              SizedBox(width:10,),
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
                              SizedBox(width:10,),
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
                                    List<String> supNamesuggestions = data
                                        .where((item) =>
                                        (item['supName']?.toString()?.toLowerCase() ?? '')
                                            .startsWith(pattern.toLowerCase()))
                                        .map((item) => item['supName'].toString())
                                        .toSet() // Remove duplicates using a Set
                                        .toList();
                                    List<String> supCodesuggestions = data
                                        .where((item) =>
                                        (item['supCode']?.toString()?.toLowerCase() ?? '')
                                            .startsWith(pattern.toLowerCase()))
                                        .map((item) => item['supCode'].toString())
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
                                      ...supNamesuggestions,
                                      ...supCodesuggestions,
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
                                      selectedSupplier = suggestion;
                                      searchController.text = suggestion;
                                    });
                                    print('Selected Customer: $selectedSupplier');
                                  },
                                ),
                              ),
                              SizedBox(width:10,),
                              MaterialButton(
                                color: Colors.green.shade600,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                height: 40,
                                onPressed: () {
                                  filterData(searchController.text);
                                  searchController.addListener(() {
                                    filterData(searchController.text);

                                  });

                                  if (searchController.text.isNotEmpty) {
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
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Align(
                                    alignment:Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text("Report Details",style: TextStyle(fontSize:17,fontWeight: FontWeight.bold),),
                                    )),
                                Align(
                                    alignment:Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (generatedButton || searchController.text.isNotEmpty)
                                            SizedBox(
                                              width:200,
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                    hintText:"Total : ₹${calculateTotal(filteredData).toStringAsFixed(2)}",
                                                    hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                                    border:OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    )
                                                ),
                                                /* */
                                                //
                                              ),
                                            ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                            const SizedBox(height: 20,),
                            PaginatedDataTable(
                              columnSpacing:74.0,
                              //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              rowsPerPage:25,
                              columns:   const [
                                DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("    Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Invoice No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Supplier Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Supplier/Company Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Grand Total",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("     Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                              ],
                              source: _YourDataTableSource(filteredData,context,generatedButton),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                        child: MaterialButton(
                          color: Colors.green.shade600,
                          height: 40,
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>PurchaseOverallReport(
                              customerData : filteredData,
                            )));
                          },child: const Text("Print",style: TextStyle(color: Colors.white),),),

                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                        child: MaterialButton(
                          color: Colors.red.shade600,
                          height: 40,
                          onPressed: (){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>const Home()));
// Close the alert box
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
                          child: const Text("Cancel",style: TextStyle(color: Colors.white),),),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
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
        DataCell(Center(child: Text("${row["invoiceNo"]}"))),
        DataCell(Center(child: Text("${row["supCode"]}"))),
        DataCell(Center(child: Text("${row["supName"]}"))),

        DataCell(
          Center(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 17),
                child: Text(
                  "${(double.parse(row["grandTotal"]) - double.parse(row["returnTotal"])).toStringAsFixed(2)}",
                ),
              ),
            ),
          ),
        ),
        DataCell(Center(child:
        Row(
          children: [
            IconButton(icon: Icon(Icons.remove_red_eye_outlined,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>purchaseView(
                invoiceNo: row["invoiceNo"],
                supMobile:row["supMobile"],
                date:row["date"],
                supCode:row["supCode"],
                supName:row["supName"],
                supAddress:row["supAddress"],
                pincode:row["pincode"],
                prodCode:row["prodCode"],
                prodName:row["prodName"],
                qty:row["qty"],
                rate:row["rate"],
                amtGST:row["amtGST"],
                total:row["total"],
                payType:row["payType"],
              )));
            },),
            IconButton(
              icon: Icon(Icons.print, color: Colors.blue),
              onPressed: () {
                if (double.parse("${row["returnTotal"]}") == 0.00) {
                  // Navigate to NoReturnPurchaseIndividualReport page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoReturnPurchaseIndividualReport(
                        invoiceNo: row["invoiceNo"],
                        date: row["date"],
                        supCode: row["supCode"],
                        supName: row["supName"],
                        supMobile: row["supMobile"],
                        supAddress: row["supAddress"],
                        pincode: row["pincode"],
                        prodCode: row["prodCode"],
                        prodName: row["prodName"],
                        qty: row["qty"],
                        rate: row["rate"],
                        amtGST: row["amtGST"],
                        total: row["total"],
                        grandTotal: row["grandTotal"],
                        payType: row["payType"],
                      ),
                    ),
                  );
                } else {
                  // Navigate to PurchaseIndividualReport page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PurchaseIndividualReport(
                        invoiceNo: row["invoiceNo"],
                        date: row["date"],
                        supCode: row["supCode"],
                        supName: row["supName"],
                        supMobile: row["supMobile"],
                        supAddress: row["supAddress"],
                        pincode: row["pincode"],
                        prodCode: row["prodCode"],
                        prodName: row["prodName"],
                        qty: row["qty"],
                        rate: row["rate"],
                        amtGST: row["amtGST"],
                        total: row["total"],
                        grandTotal: row["grandTotal"],
                        payType: row["payType"],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        )),
      ],
    )  ;}

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
