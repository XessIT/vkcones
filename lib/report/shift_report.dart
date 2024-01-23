import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/report/shift_overall_report.dart';
import '../home.dart';
import '../main.dart';
import 'package:intl/intl.dart';


class ShiftReport extends StatefulWidget {
  const ShiftReport({Key? key}) : super(key: key);

  @override
  State<ShiftReport> createState() => _ShiftReportState();
}
class _ShiftReportState extends State<ShiftReport> {

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



  Future<void> deleteItem(BuildContext context, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3309/shift_delete/$id'),
      );
      if (response.statusCode == 200) {
      } else {
        throw Exception('Error deleting Item Group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete Item Group: $e');
    }
  }
  void onDelete(int id) {
    deleteItem(context, id);
  }
  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/fetch_shift/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          data = itemGroups.cast<Map<String, dynamic>>();
          filteredData = List<Map<String, dynamic>>.from(data);
          filteredData.sort((a, b) {
            DateTime? dateA = DateTime.tryParse(a['fromDate'] ?? '');
            DateTime? dateB = DateTime.tryParse(b['toDate'] ?? '');
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
        // If the search text is empty, show all data without filtering
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        searchText = searchText.toLowerCase(); // Convert search text to lowercase once

        filteredData = data.where((item) {
          String first_name = item['first_name']?.toString()?.toLowerCase() ?? '';
          String emp_code = item['emp_code']?.toString()?.toLowerCase() ?? '';
          String shiftType = item['shiftType']?.toString()?.toLowerCase() ?? '';

          return first_name.contains(searchText) ||
              emp_code.contains(searchText) ||
              shiftType.contains(searchText);
        }).toList();
      }

      filteredData.sort((a, b) {
        DateTime? dateA = DateTime.tryParse(a['fromDate'] ?? '');
        DateTime? dateB = DateTime.tryParse(b['toDate'] ?? '');

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
      if (!isDateRangeValid) {
        return;
      }
      filteredData = data.where((item) {
        String startDateStr = item['fromDate']?.toString() ?? '';
        String endDateStr = item['toDate']?.toString() ?? '';
        DateTime? startDate = DateTime.tryParse(startDateStr);
        DateTime? endDate = DateTime.tryParse(endDateStr);

        if (startDate != null && endDate != null) {
          bool dateInRange = !startDate.isAfter(toDate!) && !endDate.isBefore(fromDate!);

          String empName = item['first_name']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchController.text.toLowerCase();
          bool matchesEmployeeName = empName.contains(searchTextLowerCase);

          return dateInRange && matchesEmployeeName;
        }
        return false;
      }).toList();
      if (searchController.text.isNotEmpty) {
        String searchTextLowerCase = searchController.text.toLowerCase();
        filteredData = filteredData.where((item) {

          String first_name = item['first_name']?.toString()?.toLowerCase() ?? '';
          String emp_code= item['emp_code']?.toString()?.toLowerCase() ?? '';
          String shiftType = item['shiftType']?.toString()?.toLowerCase() ?? '';

          return first_name.contains(searchTextLowerCase) ||
              emp_code.contains(searchTextLowerCase) ||
              shiftType.contains(searchTextLowerCase);
        }).toList();
      }
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
      route: "shift_report",
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
                                Icon(Icons.sell,),
                                SizedBox(width:10,),
                                Text(
                                  'Shift Report',
                                  style: TextStyle(
                                    fontSize:20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Wrap(
                                  // mainAxisAlignment: MainAxisAlignment.start,
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
                                                  lastDate: DateTime(2100),
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
                                                  lastDate: DateTime(2100),
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
                                    //SizedBox(width: 11,),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 37,left:10),
                                      child: SizedBox(
                                        width: 220,
                                        height: 40,
                                        child: TypeAheadFormField<String>(
                                          textFieldConfiguration: TextFieldConfiguration(
                                            onChanged: (value){
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              searchController.value = searchController.value.copyWith(
                                                text: capitalizedValue,
                                                selection: TextSelection.collapsed(offset: capitalizedValue.length),);
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
                                            List<String> first_namesuggestions =data
                                                .where((item) =>
                                                (item['first_name']?.toString()?.toLowerCase() ?? '')
                                                    .startsWith(pattern.toLowerCase()))
                                                .map((item) => item['first_name'].toString())
                                                .toSet() // Remove duplicates using a Set
                                                .toList();
                                            List<String> emp_codesuggestion = data
                                                .where((item) =>
                                                (item['emp_code']?.toString()?.toLowerCase() ?? '')
                                                    .startsWith(pattern.toLowerCase()))
                                                .map((item) => item['emp_code'].toString())
                                                .toSet() // Remove duplicates using a Set
                                                .toList();
                                            List<String> shiftTypesuggestions = data
                                                .where((item) =>
                                                (item['shiftType']?.toString()?.toLowerCase() ?? '')
                                                    .startsWith(pattern.toLowerCase()))
                                                .map((item) => item['shiftType'].toString())
                                                .toSet() // Remove duplicates using a Set
                                                .toList();
                                            List<String> suggestions = [
                                              ...first_namesuggestions,
                                              ...emp_codesuggestion,
                                              ...shiftTypesuggestions,
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
                                    Padding(
                                      padding: const EdgeInsets.only(top:37,left:20),
                                      child:
                                      MaterialButton(
                                        color: Colors.green.shade500,
                                        height: 40,
                                        onPressed: () {
                                          if (fromDate == null || toDate == null) {
                                            setState(() {
                                              isDateRangeValid = false;
                                            });
                                          } else if (fromDate!.isAfter(toDate!)) {
                                            setState(() {
                                              isDateRangeValid = false;
                                            });
                                          } else {
                                            isDateRangeValid = true;
                                            filterData(searchController.text);
                                          }
                                        },
                                        child: const Text("Generate", style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.refresh),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ShiftReport()));
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
                            const SizedBox(height: 20,),
                            filteredData.isEmpty? Text("No Data Available",style: (TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),):
                            PaginatedDataTable(
                              columnSpacing:110,
                              //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              rowsPerPage:25,
                              columns:   const [
                                DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Employee ID",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Employee Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Start Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("End Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Shift Type",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Alter Employee",style: TextStyle(fontWeight: FontWeight.bold),))),
                                // DataColumn(label: Center(child: Text("     Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                              ],
                              source: _YourDataTableSource(filteredData,context,generatedButton,onDelete),
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
                        child:filteredData.isEmpty?Text(""):
                        MaterialButton(
                          color: Colors.green.shade600,
                          height: 40,
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ShiftOverallReport(
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
                          },child: const Text("CANCEL",style: TextStyle(color: Colors.white),),),
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
  final Function(int) onDelete;

  _YourDataTableSource(this.data,this.context, this.generatedButton, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }

    final row = data[index];
    final id=row["id"];

    return DataRow(
      cells: [
        DataCell(Center(child: Text("${index + 1}"))),
        /*  DataCell(Center(
          child: Text(
            row["date"] != null
                ? DateFormat('dd-MM-yyyy').format(
              DateTime.parse("${row["date"]}").toLocal(),
            )
                : "",
          ),
        )),*/

        // DataCell(Center(child: Text("${row["invoiceNo"]}"))),
        DataCell(Center(child: Text("${row["emp_code"]}"))),
        DataCell(Center(child: Text("${row["first_name"]}"))),
        DataCell(Center(child: Text(
          row["fromDate"] != null
              ? DateFormat('dd-MM-yyyy').format(
            DateTime.parse("${row["fromDate"]}").toLocal(),
          )
              : "",
        ),)),
        DataCell(Center(child: Text(
          row["toDate"] != null
              ? DateFormat('dd-MM-yyyy').format(
            DateTime.parse("${row["toDate"]}").toLocal(),
          )
              : "",
        ),)),
        DataCell(Center(child: Text("${row["shiftType"]}"))),
        DataCell(Center(
          child: Text(
            "${row["alterEmp"] ?? ""}${row["alterEmpID"] != null ? " - (${row["alterEmpID"]})" : ""}"
                ?? "-",
          ),
        )),
      ],
    );
  }


  void showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this Shift?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const ShiftReport()));
                onDelete(id); // Call the onDelete function
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

