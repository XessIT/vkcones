

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/report/winding_report_pdf.dart';
import 'package:vinayaga_project/sale/sales_individual_report_pdf.dart';
import 'package:vinayaga_project/sale/sales_individual_view.dart';
import 'package:vinayaga_project/sale/sales_report_pdf.dart';

import '../home.dart';


class SalesReport extends StatefulWidget {
  const SalesReport({Key? key}) : super(key: key);
  @override
  State<SalesReport> createState() => _SalesReportState();
}
class _SalesReportState extends State<SalesReport> {
  double grandTotalSum = 0.0;


  List<String> supplierSuggestions = [];
  String selectedSupplier = "";
  bool isDateRangeValid=true;
  int currentPage = 1;
  int rowsPerPage = 10;

  void updateFilteredData() {
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex = currentPage * rowsPerPage;

    setState(() {
      filteredData = data.sublist(startIndex, endIndex);
    });
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  bool generatedButton = false;
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController searchController = TextEditingController();

  List<String> itemGroupValues = [];
  List<String> invoiceNumber = [];
  String selectedCustomer="";
  double totalGrandTotal = 0.0;

  double calculateTotal(List<Map<String, dynamic>> filteredData) {
    double totalSalary = 0;
    for (var row in filteredData) {
      totalSalary += double.parse(row['grandTotal'] ?? '0');
    }
    return totalSalary;
  }


  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_sales_entry/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        // Use a Set to filter out duplicate custName values
        Set<String> uniqueCustNames = Set();

        // Filter out duplicate values based on 'custName'
        final List uniqueData = itemGroups
            .where((item) {
          String custName = item['orderNo']?.toString() ?? '';
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

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filteredData = [];
  TextEditingController sum =TextEditingController();

  void filterData(String searchText) {
    print("Search Text: $searchText");
    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all data without filtering by supplier name
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        filteredData = data.where((item) {
          String custName = item['custName']?.toString()?.toLowerCase() ?? '';
          String custCode  = item['custCode']?.toString()?.toLowerCase() ?? '';
          String invoiceNo = item['invoiceNo']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();

          return custName.contains(searchTextLowerCase) ||
              custCode.contains(searchTextLowerCase) ||
              invoiceNo.contains(searchTextLowerCase);

        }).toList();
      }
      grandTotal = 0;
      for (var item in filteredData) {
        double rowGrandTotal = double.parse(item["grandTotal"].toString());
        grandTotal += rowGrandTotal;
      }

      // Update the sum.text after recalculating grandTotal
      if( filteredData==true)
        sum.text = double.tryParse(grandTotal.toString()).toString();
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
  // Callback function to update grandTotalSum
  void updateGrandTotal(double total) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        grandTotalSum = total;
      });
    });
  }




  double Grandtotal = 0;
  void applyDateFilter() {
    setState(() {
      if(!isDateRangeValid){
        return;
      }
      filteredData = data.where((item) {
        String dateStr = item['date']?.toString() ?? '';
        DateTime? itemDate = DateTime.tryParse(dateStr);

        if (itemDate != null &&
            !itemDate.isBefore(fromDate!) &&
            !itemDate.isAfter(toDate!.add(Duration(days: 1)))) {
          return true;
        }
        return false;
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
        return dateB.compareTo(dateA);
        // Compare in descending order
      });
      Grandtotal = calculateTotal(filteredData);
    });
  }


  @override
  void initState() {
    super.initState();
    fetchData();
    _searchFocus.requestFocus();
    filteredData = List<Map<String, dynamic>>.from(data);
  }
  final FocusNode _searchFocus = FocusNode();

  @override
  Widget build(BuildContext context) {

    final formattedDate = fromDate != null ? DateFormat("dd-MM-yyyy").format(fromDate!) : "";
    final formattedDate2 = toDate != null ? DateFormat("dd-MM-yyyy").format(toDate!) : "";

    // searchController.addListener(() {
    //   filterData(searchController.text);
    // });

    return MyScaffold(
      route: "sales_report",backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    child:   Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.report,),
                                SizedBox(width:10,),
                                Text(
                                  'Sales Report',
                                  style: TextStyle(
                                    fontSize:20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Wrap(
                                  //mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 37,left: 15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 220,
                                            height: 70,
                                            child: TextFormField(style: const TextStyle(fontSize: 13),
                                              readOnly: true, // Set the field as read-only
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return '* Enter Date';
                                                }
                                                return null;
                                              },
                                              onTap: () {
                                                showDatePicker(
                                                  context: context,
                                                  initialDate: fromDate ?? DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime.now(),
                                                ).then((date) {
                                                  if (date != null) {
                                                    setState(() {
                                                      fromDate = date;
                                                      // applyDateFilter();
                                                    });
                                                  }
                                                });
                                              },
                                              controller: TextEditingController(text: formattedDate.toString().split(' ')[0]), // Set the initial value of the field to the selected date
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(Icons.calendar_month),
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "From Date",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(top: 37,left:10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 220,
                                            height: 70,
                                            child: TextFormField(style: TextStyle(fontSize: 13),
                                              readOnly: true,
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return '* Enter Date';
                                                }
                                                return null;
                                              },
                                              onTap: () {
                                                showDatePicker(
                                                  context: context,
                                                  initialDate: toDate ?? DateTime.now(),
                                                  firstDate: DateTime(2000), // Set the range of selectable dates
                                                  lastDate: DateTime.now(),
                                                ).then((date) {
                                                  if (date != null) {
                                                    setState(() {
                                                      toDate = date;
                                                      //applyDateFilter();
                                                    });
                                                  }
                                                });
                                              },
                                              controller: TextEditingController(text: formattedDate2.toString().split(' ')[0]), // Set the initial value of the field to the selected date
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(Icons.calendar_month),
                                                fillColor: Colors.white,
                                                filled: true,
                                                labelText: "To Date",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                isDense: true,
                                              ),

                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 37 , left:10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 220,
                                            height: 50,
                                            child:
                                            TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                onChanged: (value) {
                                                  String capitalizedValue = capitalizeFirstLetter(value);
                                                  searchController.value = searchController.value.copyWith(
                                                    text: capitalizedValue,
                                                    selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                  );
                                                },
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
                                                List<String> custNamesuggestions =data
                                                    .where((item) =>
                                                    (item['custName']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map((item) => item['custName'].toString())
                                                    .toSet() // Remove duplicates using a Set
                                                    .toList();
                                                List<String> custCodesuggestions =data
                                                    .where((item) =>
                                                    (item['custCode']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map((item) => item['custCode'].toString())
                                                    .toSet() // Remove duplicates using a Set
                                                    .toList();
                                                List<String> invoiceNOsuggestions =data
                                                    .where((item) =>
                                                    (item['invoiceNo']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map((item) => item['invoiceNo'].toString())
                                                    .toSet() // Remove duplicates using a Set
                                                    .toList();
                                                List<String> suggestions = [
                                                  ...custNamesuggestions,
                                                  ...custCodesuggestions,
                                                  ...invoiceNOsuggestions,
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
                                                        // filterData(selectedSupplier);
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top:37,left:20),
                                        child: MaterialButton(
                                          color: Colors.green.shade500,
                                          height: 40,
                                          onPressed: () {
                                            searchController.addListener(() {
                                              filterData(searchController.text);
                                            });
                                            // filterData(selectedSupplier);
                                            if (fromDate!.isAfter(toDate!)) {
                                              setState(() {
                                                // Show an error message if 'From Date' is greater than 'To Date'
                                                isDateRangeValid = false;
                                              });
                                            } else {
                                              // If both dates are selected and 'From Date' is not greater than 'To Date', proceed with generating the report.
                                              isDateRangeValid = true;
                                              applyDateFilter();
                                            }
                                          },
                                          child: const Text("Generate", style: TextStyle(color: Colors.white)),
                                        )
                                    ),

                                    if (!isDateRangeValid)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0), // Adjust the top padding as needed
                                        child: Text(
                                          isDateRangeValid == false && (fromDate == null || toDate == null)
                                              ? "* Enter a 'From and To Date'."
                                              : "* 'From Date' must be less than\n  or equal to 'To Date'.",
                                          style: TextStyle(color: Colors.red, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 15,)
                          ],
                        ),
                      ),
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
                                  padding: EdgeInsets.only(left: 5),

                                  child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Report Details",style: TextStyle(fontSize:17,fontWeight: FontWeight.bold),),
                                      Align(
                                          alignment:Alignment.topLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (generatedButton || searchController.text.isNotEmpty)
                                                  SizedBox(
                                                    width:150,
                                                    child: TextFormField(
                                                      decoration: InputDecoration(
                                                          hintText:"Total : ₹${calculateTotal(filteredData)}",
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

                                )),

                            const SizedBox(height: 20,),
                            filteredData.isEmpty? Text("No Data Available",style: (TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),):
                            PaginatedDataTable(
                              columnSpacing:70, rowsPerPage:25,
                              columns: [
                                const DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold,),))),
                                const DataColumn(label: Center(child: Text("Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("Invoice No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("Customer Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("Customer/Company Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("Grand Total",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(
                                  label: const Center(child: Text("   Action", style: TextStyle(fontWeight: FontWeight.bold))),
                                  onSort: (columnIndex, ascending) {
                                  },
                                  tooltip: "Action",
                                ),

                              ],
                              source: _YourDataTableSource(filteredData, context, generatedButton, updateGrandTotal),
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
                      filteredData.isEmpty? Text("")
                          :
                      MaterialButton(
                        color: Colors.green,
                        shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>SaleReportPDF(
                            customerData: filteredData,
                          )));
                        },child: const Text("PRINT",style: TextStyle(color: Colors.white),),),
                      SizedBox(width: 20,),

                      MaterialButton(
                        shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                        color: Colors.red,

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
                        child: const Text("CANCEL",style: TextStyle(color: Colors.white),),),


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
class YourData {
  final double grandTotal;

  YourData({required this.grandTotal});
}
double grandTotal = 0.0;

class _YourDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  List<Map<String, dynamic>> customerdata = [];
  final BuildContext context;
  final bool generatedButton;
  final Function(double) onGrandTotalChange;
  Future<List<Map<String, dynamic>>> fetchReturnItems(String invoiceNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/sales_return_item_view?invoiceNo=$invoiceNo'));
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


  _YourDataTableSource(this.data, this.context, this.generatedButton, this.onGrandTotalChange);
  double grandTotal = 0.0; // Add a variable to keep track of the grand total


  void printButtonPressed(int rowIndex) {


    if (rowIndex >= 0 && rowIndex < data.length) {
      final selectedRowData = data[rowIndex];
      Navigator.push(context, MaterialPageRoute(builder: (context) => SaleReportPDF(
        customerData: [selectedRowData], // Pass the selected row data as a list
      )));
    }
  }
  @override
  DataRow? getRow(int index) {
    final row = data[index];
    customerdata = List.from(data);

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
        DataCell(Center(child: Text("${row["custCode"]}"))),
        DataCell(Center(child: Text("${row["custName"]}"))),
        DataCell(Center(child: Text("${row["grandTotal"]}"))),
        DataCell(Center(
          child: Row(
            children: [
              //  if(generatedButton == true)
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalesView(
                        customerData:row["checkOrderNo"]=="" ?row["orderNo"]:row["checkOrderNo"],
                        invoiceNo: row["invoiceNo"],
                        custName: row["custName"],
                        custCode: row["custCode"],
                        custAddress: row["custAddress"],
                        custmobile: row["custMobile"],
                        itemGroup: row["itemGroup"],
                        transportNo: row["transportNo"],
                        date: row["date"],
                        grandtotal: row["grandTotal"], custpincode: row["pincode"],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue,),
              ),
              //    if(generatedButton == true)
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalesIndividualReportPDFView(
                        customerData:row["checkOrderNo"]=="" ?row["orderNo"]:row["checkOrderNo"],
                        invoiceNo: row["invoiceNo"],
                        custName: row["custName"],
                        custCode: row["custCode"],
                        custAddress: row["custAddress"],
                        custmobile: row["custMobile"],
                        transportNo: row["transportNo"],
                        date: row["date"],
                        grandtotal: row["grandTotal"], custpincode: row["pincode"],
                      ),
                    ),
                  );

                  //              printButtonPressed(index);

                },
                icon: const Icon(Icons.print, color: Colors.blue),
              ),
            ],
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
