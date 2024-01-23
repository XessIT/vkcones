import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/report/winding_report_pdf.dart';

import '../home.dart';
import 'finishing_report_pdf.dart';

class FinishingReport extends StatefulWidget {
  const FinishingReport({Key? key}) : super(key: key);
  @override
  State<FinishingReport> createState() => _FinishingReportState();
}
class _FinishingReportState extends State<FinishingReport> {

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
  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/finishing_entry_get_report/');
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
        // If the search text is empty, show all data without filtering by supplier name
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        filteredData = data.where((item) {
          String machName = item['machName']?.toString()?.toLowerCase() ?? '';
          String assOne = item['assOne']?.toString()?.toLowerCase() ?? ''; // Add this line
          String opOneName = item['opOneName']?.toString()?.toLowerCase() ?? ''; // Add this line

          String searchTextLowerCase = searchText.toLowerCase();
          return machName.contains(searchTextLowerCase) ||
              assOne.contains(searchTextLowerCase) ||
              opOneName.contains(searchTextLowerCase);

        }).toList();
      }
      // Sort filteredData in descending order based on the "date" field
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
          bool dateInRange = !startDate.isAfter(_ToDatecontroller!) && !endDate.isBefore(_FromDatecontroller!);

          String empName = item['machName']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchController.text.toLowerCase();
          bool matchesEmployeeName = empName.contains(searchTextLowerCase);

          return dateInRange && matchesEmployeeName;
        }
        return false;
      }).toList();
    });
  }


  @override
  void initState() {
    super.initState();
    fetchData();
    searchController.addListener(() {
      filterData(searchController.text);
    });
    _searchFocus.requestFocus();
    filteredData = List<Map<String, dynamic>>.from(data);
  }
  final FocusNode _searchFocus = FocusNode();
  DateTime? _FromDatecontroller;
  DateTime? _ToDatecontroller;

  @override
  Widget build(BuildContext context) {

    final formattedDate = _FromDatecontroller != null ? DateFormat("dd-MM-yyyy").format(_FromDatecontroller!) : "";
    final formattedDate2 = _ToDatecontroller != null ? DateFormat("dd-MM-yyyy").format(_ToDatecontroller!) : "";

    searchController.addListener(() {
      filterData(searchController.text);
    });

    return MyScaffold(
      route: "finishing_report",
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
                                  'Finishing Report',
                                  style: TextStyle(
                                    fontSize:20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
                                                initialDate: _FromDatecontroller ?? DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100),
                                              ).then((date) {
                                                if (date != null) {
                                                  setState(() {
                                                    _FromDatecontroller = date;
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
                                                initialDate: _ToDatecontroller ?? DateTime.now(),
                                                firstDate: DateTime(2000), // Set the range of selectable dates
                                                lastDate: DateTime(2100),
                                              ).then((date) {
                                                if (date != null) {
                                                  setState(() {
                                                    _ToDatecontroller = date;
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
                                              controller: searchController,

                                              style: const TextStyle(fontSize: 13),
                                              onChanged: (value) {
                                                String capitalizedValue = capitalizeFirstLetter(value);
                                                searchController.value = searchController.value.copyWith(
                                                  text: capitalizedValue,
                                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                );
                                              },
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(Icons.search),
                                                fillColor: Colors.white,
                                                filled: true,
                                                labelText: "",
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
                                              List<String> machNameSuggestions = data
                                                  .where((item) =>
                                                  (item['machName']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['machName'].toString())
                                                  .toSet()
                                                  .toList();
                                              List<String> assOneSuggestions = data
                                                  .where((item) =>
                                                  (item['assOne']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['assOne'].toString())
                                                  .toSet()
                                                  .toList();
                                              List<String> opOneNameSuggestions = data
                                                  .where((item) =>
                                                  (item['opOneName']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['opOneName'].toString())
                                                  .toSet()
                                                  .toList();

                                              // Combine all suggestions and remove duplicates using a Set
                                              List<String> suggestions = [
                                                ...machNameSuggestions,
                                                ...assOneSuggestions,
                                                ...opOneNameSuggestions,
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
                                  SizedBox(width:20),
                                  Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: MaterialButton(
                                        color: Colors.green.shade500,
                                        height: 40,
                                        onPressed: () {
                                          if (_FromDatecontroller == null || _ToDatecontroller == null) {
                                            setState(() {
                                              // Show an error message if either of the dates is not selected
                                              isDateRangeValid = false;
                                            });
                                          } else if (_FromDatecontroller!.isAfter(_ToDatecontroller!)) {
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>FinishingReport()));
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
                                        isDateRangeValid == false && (fromDate == null || toDate == null)
                                            ? "* Enter a 'From and To Date'."
                                            : "* 'From Date' must be less than\n  or equal to 'To Date'.",
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                ],
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
                            filteredData.isNotEmpty?
                            SizedBox(
                              // width:1000,
                              child: PaginatedDataTable(
                                columnSpacing:130.0,
                                //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                rowsPerPage:25,
                                columns:   const [
                                  DataColumn(label: Center(child: Text("     S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  DataColumn(label: Center(child: Text("Shift date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  DataColumn(label: Center(child: Text("From date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  DataColumn(label: Center(child: Text("To date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  DataColumn(label: Center(child: Text("   Machine Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  DataColumn(label: Center(child: Text("        Person-1",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  //DataColumn(label: Center(child: Text("Operator Name-2",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  DataColumn(label: Center(child: Text("        Person-2",style: TextStyle(fontWeight: FontWeight.bold),))),

                                ],
                                source: _YourDataTableSource(filteredData,context,generatedButton),
                              ),
                            ):
                            Text("No Data Available",style: (TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),)
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>FinishingReportPdf(
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
        DataCell(Center(child: Text(row["shiftdate"] != null
            ? DateFormat('dd-MM-yyyy').format(DateTime.parse("${row["shiftdate"]}").toLocal())
            : "",),)),
        DataCell(Center(
          child: Text(
            row["fromDate"] != null
                ? DateFormat('dd-MM-yyyy').format(
              DateTime.parse("${row["fromDate"]}").toLocal(),
            )
                : "",
          ),
        )),  /// From Date
        DataCell(Center(
          child: Text(
            row["toDate"] != null
                ? DateFormat('dd-MM-yyyy').format(
              DateTime.parse("${row["toDate"]}").toLocal(),
            )
                : "",
          ),
        )), /// To Date
        DataCell(Center(child: Text("${row["machName"]}"))),
        DataCell(Center(child: Text("${row["opOneName"]}"))),
        DataCell(Center(child: Text("${row["assOne"]}"))),
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

