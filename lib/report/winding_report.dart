import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/report/winding_report_pdf.dart';

import '../home.dart';

class WindingReport extends StatefulWidget {
  const WindingReport({Key? key}) : super(key: key);
  @override
  State<WindingReport> createState() => _WindingReportState();
}
class _WindingReportState extends State<WindingReport> {

  DateTime selectedDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  String toselecteddate ='' ;
  String fromselecteddate = '';
  List<Map<String, dynamic>> data = [];
  DateTime? _FromDatecontroller;
  DateTime? _ToDatecontroller;
  final TextEditingController toselectedDate = TextEditingController();
  final TextEditingController fromselectedDate = TextEditingController();
  // final TextEditingController  _FromDatecontroller = TextEditingController();
  // final TextEditingController  _ToDatecontroller = TextEditingController();
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
    // Example: Fetch your data and assign it to 'data'
    fetchData().then((_) {
      // Initialize 'filteredData' with all data
      setState(() {
        filteredData = List.from(data);
      });
    });
  }




  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/winding_entry_get_report/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        List<Map<String, dynamic>> sortedData = itemGroups.cast<Map<String, dynamic>>();
        sortedData.sort((a, b) {
          DateTime dateTimeA = DateTime.tryParse(a['shiftdate'] ?? '') ?? DateTime(0);
          DateTime dateTimeB = DateTime.tryParse(b['shiftdate'] ?? '') ?? DateTime(0);
          return dateTimeB.compareTo(dateTimeA); // Sort in descending order
        });

        setState(() {
          data = sortedData;
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

/*  bool isAnyFieldNotEmpty() {
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
            String id = item['machName']?.toString()?.toLowerCase() ?? '';
            String searchTextLowerCase = searchText.toLowerCase();
            return id.contains(searchTextLowerCase);
          }).toList();
        }
      }
    });
  }*/
  bool isDateRangeValid=true;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    //filterData('');
  }
  @override
  Widget build(BuildContext context) {
    final formattedDate = _FromDatecontroller != null ? DateFormat("dd-MM-yyyy").format(_FromDatecontroller!) : "";
    final formattedDate2 = _ToDatecontroller != null ? DateFormat("dd-MM-yyyy").format(_ToDatecontroller!) : "";

    searchController.addListener(() {
      //filterData(searchController.text);
    });


    return MyScaffold(
      route: "winding_report",backgroundColor: Colors.white,
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
                              const Row(children: [
                                Icon(
                                  Icons.shopping_cart, // Replace with the icon you want to use
                                  // Replace with the desired icon color
                                ),
                                Text("Winding Report", style: TextStyle(
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
                                padding: const EdgeInsets.only(top: 7),
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
                                        labelText: "Employee Name",
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
                                      List<String> suggestions = data
                                          .where((item) =>
                                          (item['empName']?.toString()?.toLowerCase() ?? '')
                                              .startsWith(pattern.toLowerCase()))
                                          .map((item) => item['empName'].toString())
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
                                        selectedSupplier = suggestion;
                                        searchController.text = suggestion;
                                      });
                                      print('Selected Customer: $selectedSupplier');
                                    },
                                  ),
                                ),
                              ),
                              /*if (supplierSuggestions.isNotEmpty)
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
                                ),*/
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child:
                                MaterialButton(
                                  color: Colors.green.shade500,
                                  height: 40,
                                  onPressed: () {
                                    if (_FromDatecontroller == null || _ToDatecontroller == null) {
                                      setState(() {
                                        isDateRangeValid = false;
                                      });
                                    } else if (_FromDatecontroller!.isAfter(_ToDatecontroller!)) {
                                      setState(() {
                                        isDateRangeValid = false;
                                      });
                                    } else {
                                      isDateRangeValid = true;
                                      applyDateFilter();
                                    }
                                  },
                                  child: const Text("Generate", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>WindingReport()));
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
                                child: SizedBox(
                                  width:1200,
                                  child: PaginatedDataTable(
                                    columnSpacing:30.0,
                                    //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    rowsPerPage:25,
                                    columns:   const [
                                      DataColumn(label: Center(child: Text("   S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("    Shift date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("   From Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("   To Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("   Shift Type",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("   Machine Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("    Printing Status",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("     Operator",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("    Assistant 1",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("     Assistant 2",style: TextStyle(fontWeight: FontWeight.bold),))),

                                    ],
                                    source: _YourDataTableSource(filteredData,context,generatedButton),
                                  ),
                                ),
                              ),
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>WindingReportPdf(
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
        DataCell(Center(
          child: Text(
            row["shiftdate"] != null
                ? DateFormat('dd-MM-yyyy').format(
              DateTime.parse("${row["shiftdate"]}").toLocal(),
            )
                : "",
          ),
        )),
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
        DataCell(Center(child: Text("${row["shiftType"]}"))),
        DataCell(Center(child: Text("${row["machName"]}"))),
        DataCell(Center(child: Text(row["status"] ?? ''))),
        DataCell(Center(child: Text("${row["opOneName"]}"))),
        DataCell(Center(child: Text("${row["assOne"]}"))),
        DataCell(Center(child: Text("${row["asstwo"]}")))
        /*DataCell(Center(child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Text("${row["shiftType"]}"),
            )))),*/

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

