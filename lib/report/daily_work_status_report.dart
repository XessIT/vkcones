import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/report/dailyWorkstatus_pdf.dart';

import '../home.dart';
import 'daily_work_report_view.dart';

class DailyWorkStatusReport extends StatefulWidget {
  const DailyWorkStatusReport({Key? key}) : super(key: key);

  @override
  State<DailyWorkStatusReport> createState() => _DailyWorkStatusReportState();
}


class _DailyWorkStatusReportState extends State<DailyWorkStatusReport> {

  ///report view declare
  List<String> supplierSuggestions = [];
  String selectedSupplier = "";
  bool isDateRangeValid=true;
  int currentPage = 1;
  int rowsPerPage = 10;

  void updateFilteredData() {
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex = currentPage * rowsPerPage;

    setState(() {
      filteredData = datas.sublist(startIndex, endIndex);
    });
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  String selectedCustomer = '';

  bool generatedButton = false;
  DateTime? fromDates;
  DateTime? toDate;
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> itemGroupValues = [];
  List<String> invoiceNumber = [];
  // String selectedCustomer="";



  Future<void> fetchDataReport() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_daily_work_status/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        //  final List<dynamic> itemGroups = responseData;

        // Use a Set to filter out duplicate custName values
        //Set<String> uniqueCustNames = Set();

        // Filter out duplicate values based on 'custName'
        // final List uniqueData = itemGroups
        //     .where((item) {
        //   //    String custName =item['checkOrderNo'].isEmpty? item['orderNo']:item['checkOrderNo']?.toString() ?? '';
        //   String custName = item['machineType']?.toString() ?? '';
        //   if (!uniqueCustNames.contains(custName)) {
        //     uniqueCustNames.add(custName);
        //     return true;
        //   }
        //   return false;
        // })
        //     .toList();

        setState(() {
          datas = responseData.cast<Map<String, dynamic>>();
          filteredData = List<Map<String, dynamic>>.from(datas);
          filteredData.sort((a, b) {
            DateTime? dateA = DateTime.tryParse(a['fromDate'] ?? '');
            DateTime? dateB = DateTime.tryParse(b['fromDate'] ?? '');
            if (dateA == null || dateB == null) {
              return 0;
            }
            return dateB.compareTo(dateA);
          });
        });

        print('Data: $datas');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  List<Map<String, dynamic>> datas = [];
  List<Map<String, dynamic>> filteredData = [];

  void filterData(String searchText) {
    print("Search Text: $searchText");
    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all data without filtering by supplier name
        filteredData = List<Map<String, dynamic>>.from(datas);
      } else {
        filteredData = datas.where((item) {
          String supName = item['machineType']?.toString().toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();

          return supName.contains(searchTextLowerCase);
        }).toList();
      }

      // Sort filteredData in descending order based on the "date" field
      filteredData.sort((a, b) {
        DateTime? dateA = DateTime.tryParse(a['fromDate'] ?? '');
        DateTime? dateB = DateTime.tryParse(b['fromDate'] ?? '');

        if (dateA == null || dateB == null) {
          return 0;
        }

        return dateB.compareTo(dateA);
      });
    });
    //  if (kDebugMode) {
    print("Filtered Data Length: ${filteredData.length}");
    //   }
  }

  void applyDateFilter() {
    setState(() {
      if(!isDateRangeValid){
        return;
      }
      filteredData = datas.where((item) {
        String dateStr = item['fromDate']?.toString() ?? '';
        DateTime? itemDate = DateTime.tryParse(dateStr);

        if (itemDate != null &&
            !itemDate.isBefore(fromDates!) &&
            !itemDate.isAfter(toDate!.add(const Duration(days: 1)))) {
          return true;
        }
        return false;
      }).toList();
      if (searchController.text.isNotEmpty) {
        String searchTextLowerCase = searchController.text.toLowerCase();
        filteredData = filteredData.where((item) {
          String id = item['machineType']?.toString().toLowerCase() ?? '';
          return id.contains(searchTextLowerCase);
        }).toList();
      }
      filteredData.sort((a, b) {
        DateTime? dateA = DateTime.tryParse(a['fromDate'] ?? '');
        DateTime? dateB = DateTime.tryParse(b['fromDate'] ?? '');
        if (dateA == null || dateB == null) {
          return 0;
        }
        return dateB.compareTo(dateA);
        // Compare in descending order
      });
    });
  }

  void initState() {
    super.initState();
    fetchDataReport();
    _searchFocus.requestFocus();
    filteredData = List<Map<String, dynamic>>.from(datas);
  }


  final FocusNode _searchFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final formattedDate = fromDates != null ? DateFormat("dd-MM-yyyy").format(fromDates!) : "";
    final formattedDate2 = toDate != null ? DateFormat("dd-MM-yyyy").format(toDate!) : "";

    searchController.addListener(() {
      filterData(searchController.text);
    });

    return MyScaffold(route: '/DWSreport',backgroundColor: Colors.white, body: Center(
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
                            'Daily Work Status Report',
                            style: TextStyle(
                              fontSize:20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                      const Align(
                          alignment:Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text("Report Details",style: TextStyle(fontSize:17,fontWeight: FontWeight.bold),),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                      /*  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return '* Enter Date';
                                                    }
                                                    return null;
                                                  },*/
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: fromDates ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                        ).then((date) {
                                          if (date != null) {
                                            setState(() {
                                              fromDates = date;
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
                                      /* validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return '* Enter Date';
                                                    }
                                                    return null;
                                                  },*/
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
                            SizedBox(width: 11,),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
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
                                          labelText: "Department Name",
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
                                        List<String> suggestions =datas
                                            .where((item) =>
                                            (item['machineType']?.toString()?.toLowerCase() ?? '')
                                                .startsWith(pattern.toLowerCase()))
                                            .map((item) => item['machineType'].toString())
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
                                                filterData(selectedSupplier);
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
                                padding: const EdgeInsets.all(20.0),
                                child: MaterialButton(
                                  color: Colors.green.shade500,
                                  height: 40,
                                  onPressed: () {
                                    if (fromDates == null || toDate == null) {
                                      setState(() {
                                        // Show an error message if either of the dates is not selected
                                        isDateRangeValid = false;
                                      });
                                    } else if (fromDates!.isAfter(toDate!)) {
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
                            IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>DailyWorkStatusReport()));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalaryCalculation()));
                                Navigator.pop(context);
                              },
                            ),

                            if (!isDateRangeValid)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0), // Adjust the top padding as needed
                                child: Text(
                                  isDateRangeValid == false && (fromDates == null || toDate == null)
                                      ? "* Enter a 'From and To Date'."
                                      : "* 'From Date' must be less than\n  or equal to 'To Date'.",
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20,),
                      filteredData.isEmpty? Text("No Data Available",style: (TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),):
                      Scrollbar(
                        thumbVisibility: true,
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: SizedBox(
                            width:1200,
                            child: PaginatedDataTable(
                              columnSpacing:30, rowsPerPage:25,
                              columns: [
                                const DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold,),))),
                                const DataColumn(label: Center(child: Text("Shift Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("Department Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("Shift Type",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("Machine Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("    Person 1",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("    Person 2",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("    Person 3",style: TextStyle(fontWeight: FontWeight.bold),))),
                                const DataColumn(label: Center(child: Text("Finished reels",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),))),
                                const DataColumn(label: Center(child: Text("Finsihed Weight",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),))),
                                const DataColumn(label: Center(child: Text("Production\n Qty",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),))),
                                const DataColumn(label: Center(child: Text("Extra Production",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),))),
                                const DataColumn(label: Center(child: Text("Action",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),))),



/*
                                      const DataColumn(label: Center(child: Text("Grand Total",style: TextStyle(fontWeight: FontWeight.bold),))),
*/
                                /* DataColumn(
                                              label: const Center(child: Text("   Action", style: TextStyle(fontWeight: FontWeight.bold))),
                                              onSort: (columnIndex, ascending) {
                                              },
                                              tooltip: "Action",
                                            ),*/

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
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                              child: MaterialButton(
                                color: Colors.green.shade600,
                                height: 40,
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Dailyworkstatus_pdf(
                                    customerData : filteredData,
                                  )));
                                },child: const Text("PRINT",style: TextStyle(color: Colors.white),),),

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
                                child: const Text("CANCEL",style: TextStyle(color: Colors.white),),),
                            ),
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
    ));
  }
}
class _YourDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> datas;
  final BuildContext context;
  final bool generatedButton;

  _YourDataTableSource(this.datas,this.context, this.generatedButton);

  @override
  DataRow? getRow(int index) {
    if (index >= datas.length) {
      return null;
    }

    final row = datas[index];

    return DataRow(
      cells: [
        DataCell(Center(child: Text("${index + 1}"))),
        DataCell(Center(child: Text(row["createDate"] != null
            ? DateFormat('dd-MM-yyyy').format(DateTime.parse("${row["createDate"]}").toLocal())
            : "",),)),
        DataCell(Center(child: Text("${row["machineType"]}"))),
        DataCell(Center(child: Text("${row["shiftType"]}"))),
        DataCell(Center(child: Text("${row['machineName']}",textAlign: TextAlign.start,))),
        DataCell(Center(child: Text("${row["person1"]}",textAlign: TextAlign.start,))),
        DataCell(Center(child: Text("${row["person2"]}",textAlign: TextAlign.start,))),
        DataCell(Center(child: Text("${row["person3"]}",textAlign: TextAlign.start,))),
        DataCell(Center(child: Text("${row["finish_reel"]}"))),
        DataCell(Center(child: Text("${row["finish_weight"]}"))),
        DataCell(Center(child: Text("${row["productionQty"]}"))),
        DataCell(Center(child: Text("${row["extraproduction"]}"))),
        DataCell(Center(child:Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            height:50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //  if(generatedButton == true)
                IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined),
                  color: Colors.blue.shade600,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyWorkView(
                          shiftType: row["shiftType"].toString(),
                          machineName: row["machineName"].toString(),
                          machineType: row["machineType"].toString(),
                          deliveryDate: row["deliveryDate"]?.toString() ?? '', // Handle null case
                          deliveryType: row["deliveryType"]?.toString() ?? '', // Handle null case
                          operator: row["person1"].toString(),
                          assistentone: row["person2"].toString(),
                          assistenttwo: row["person3"].toString(),
                          totalproduction: row["productionQty"].toString(),
                          extraproduction: row["extraproduction"].toString(),
                          qty: row["qty"].toString(),
                          date: row["createDate"].toString(),
                          //grandTotal:row["grandTotal"].toString(),
                          customerData: datas,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(width: 10,),
                //   if(generatedButton == true)
                /*IconButton(
                  icon: const Icon(Icons.print),
                  color: Colors.blue.shade600,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerOrderIndividualReport(
                          orderNo: row["orderNo"].toString(),
                          date: row["date"],
                          customerName: row["custName"],
                          customerMobile: row["custMobile"].toString(),
                          customerAddress: row["custAddress"].toString(),
                          customercode: row["custCode"].toString(),
                          itemGroup: row["itemGroup"].toString(),
                          deliveryType: row["deliveryType"]?.toString(),
                          deliveryDate: row["deliveryDate"],
                          itemName: row["itemName"].toString(),
                          qty: row["qty"].toString(),
                          GSTIN: row["gstin"].toString(),
                        ),
                      ),
                    );
                  },
                ),*/

              ],
            ),
          ),
        ),)),
      ],
    );
  }

  @override
  int get rowCount => datas.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
