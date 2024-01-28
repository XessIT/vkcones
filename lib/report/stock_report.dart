import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/report/stock_report_pdf.dart';

import '../home.dart';


class StockReport extends StatefulWidget {
  const StockReport({Key? key}) : super(key: key);
  @override
  State<StockReport> createState() => _StockReportState();
}
class _StockReportState extends State<StockReport> {

  List<String> supplierSuggestions = [];
  String selectedSupplier = "";
  bool isDateRangeValid=true;
  int currentPage = 1;
  int rowsPerPage = 10;
  final ScrollController _scrollController = ScrollController();
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
  String text="";
  List<String> itemGroupValues = [];
  List<String> invoiceNumber = [];
  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/stock_get_report/');
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

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filteredData = [];

  void filterData(String searchText) {
    print("Search Text: $searchText");
    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all data without filtering by supplier name
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        filteredData = data.where((item) {
          String supName = item['itemName']?.toString()?.toLowerCase() ?? '';
          //  String supitemName = item['itemName']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();

          return supName.contains(searchTextLowerCase);
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
  // void applyDateFilter() {
  //   setState(() {
  //     if(!isDateRangeValid){
  //       return;
  //     }
  //     filteredData = data.where((item) {
  //       String dateStr = item['date']?.toString() ?? '';
  //       DateTime? itemDate = DateTime.tryParse(dateStr);
  //
  //       if (itemDate != null &&
  //           !itemDate.isBefore(fromDate!) &&
  //           !itemDate.isAfter(toDate!.add(Duration(days: 1)))) {
  //         return true;
  //       }
  //       return false;
  //     }).toList();
  //     if (searchController.text.isNotEmpty) {
  //       String searchTextLowerCase = searchController.text.toLowerCase();
  //       filteredData = filteredData.where((item) {
  //         String id = item['empName']?.toString()?.toLowerCase() ?? '';
  //         return id.contains(searchTextLowerCase);
  //       }).toList();
  //     }
  //     filteredData.sort((a, b) {
  //       DateTime? dateA = DateTime.tryParse(a['date'] ?? '');
  //       DateTime? dateB = DateTime.tryParse(b['date'] ?? '');
  //       if (dateA == null || dateB == null) {
  //         return 0;
  //       }
  //       return dateB.compareTo(dateA); // Compare in descending order
  //     });
  //   });
  // }



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

    searchController.addListener(() {
      filterData(searchController.text);
    });
    /*if (data.isEmpty) {
      return const CircularProgressIndicator(); // Show a loading indicator while data is fetched.
    }*/
    return MyScaffold(
      route: "stock_report",backgroundColor: Colors.white,
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
                            Wrap(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.report,),
                                    SizedBox(width:10,),
                                    Text(
                                      'Stock Report',
                                      style: TextStyle(
                                        fontSize:20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 220,
                                          height: 50,
                                          child: TextFormField(
                                            focusNode: _searchFocus,
                                            controller: searchController,
                                            style: const TextStyle(fontSize: 13),
                                            onChanged: filterData,
                                            decoration: InputDecoration(
                                              labelText: "Item Name",
                                              suffixIcon: Icon(Icons.search),
                                              fillColor: Colors.white,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
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
                                                      filterData(selectedSupplier);
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.refresh),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>StockReport()));
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.arrow_back),
                                      onPressed: () {
                                        // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalaryCalculation()));
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                            const Align(
                                alignment:Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text("Report Details",style: TextStyle(fontSize:17,fontWeight: FontWeight.bold),),
                                )),
                            const SizedBox(height: 20,),
                            Scrollbar(
                              thumbVisibility: true,
                              controller: _scrollController,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController,
                                child: SizedBox(width: 1000,
                                  child: PaginatedDataTable(
                                    columnSpacing:130.0,
                                    rowsPerPage:25,
                                    columns:   const [
                                      DataColumn(label: Center(child: Text("           S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("          Item Group",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("          Item Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      // DataColumn(label: Center(child: Text("Size",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      // DataColumn(label: Center(child: Text("Color",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      //    DataColumn(label: Center(child: Text("  Unit",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("  Current Stock",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    ],
                                    source: _YourDataTableSource(filteredData,context,generatedButton),
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>StockeportPDF(
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
                ),
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
        DataCell(Center(child: Text("${row["itemGroup"]}"))),
        DataCell(Center(child: Text("${row["itemName"]}"))),
        // DataCell(Center(child: Text("${row["size"]}"))),
        // DataCell(Center(child: Text("${row["color"]}"))),
        // DataCell(Center(child: Text("${row["unit"]}"))),
        DataCell(Center(child: Text("${row["qty"]}"))),
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

