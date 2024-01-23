/*
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/preturn_individual_pdf.dart';
import 'package:vinayaga_project/purchase/preturn_individual_view.dart';
import 'package:vinayaga_project/purchase/preturn_overall_pdf.dart';
import 'package:vinayaga_project/purchase/purchase_individual_report.dart';
import 'package:vinayaga_project/purchase/purchase_overall_report.dart';
import 'package:vinayaga_project/purchase/purchase_report_view.dart';

import '../home.dart';

class PurchaseReturnReport extends StatefulWidget {
  const PurchaseReturnReport({Key? key}) : super(key: key);
  @override
  State<PurchaseReturnReport> createState() => _PurchaseReturnReportState();
}
class _PurchaseReturnReportState extends State<PurchaseReturnReport> {





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
    // Example: Fetch your data and assign it to 'data'
    fetchData().then((_) {
      // Initialize 'filteredData' with all data
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
      final url = Uri.parse('http://localhost:3309/get_preturn/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        List<Map<String, dynamic>> sortedData = itemGroups.cast<Map<String, dynamic>>();
        sortedData.sort((a, b) {
          DateTime dateTimeA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(0);
          DateTime dateTimeB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(0);
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
            String id = item['supName']?.toString()?.toLowerCase() ?? '';
            String searchTextLowerCase = searchText.toLowerCase();
            return id.contains(searchTextLowerCase);
          }).toList();
        }
      }
    });
  }


  void applyDateFilter() {
    setState(() {
      filteredData = data.where((item) {
        String dateStr = item['date']?.toString() ?? '';
        DateTime? itemDate = DateTime.tryParse(dateStr);

        return itemDate != null &&
            itemDate.isAfter(selectedDate) &&
            itemDate.isBefore(selectedToDate.add(Duration(days: 1))) &&
            (selectedSupplier.isEmpty || item['supName'] == selectedSupplier);
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    filterData('');
  }
  @override
  Widget build(BuildContext context) {
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    var formattedToDate = DateFormat('dd-MM-yyyy').format(selectedToDate);
    searchController.addListener(() {
      filterData(''
        // searchController.text,
        // fromselectedDate.text,
        // toselectedDate.text,
      );
    });
    return MyScaffold(
      route: "purchase_return_report",
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
                                const Text("Purchase Return Report", style: TextStyle(
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
                                      labelText: "Supplier/Company Name",
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
                                    List<String> suggestions = data
                                        .where((item) =>
                                        (item['supName']?.toString()?.toLowerCase() ?? '')
                                            .startsWith(pattern.toLowerCase()))
                                        .map((item) => item['supName'].toString())
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
                              SizedBox(width:10,),
                              MaterialButton(
                                color: Colors.green.shade600,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                height: 40,
                                onPressed: () {
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
                            PaginatedDataTable(
                              columnSpacing:95.0,
                              //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              rowsPerPage:25,
                              columns:   const [
                                DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("    Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Return Number",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Supplier Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Supplier/Company Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                //DataColumn(label: Center(child: Text("Quantity",style: TextStyle(fontWeight: FontWeight.bold),))),
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>PreturnOverallReport(
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
        DataCell(Center(child: Text("${row["preturnNo"]}"))),
        DataCell(Center(child: Text("${row["supCode"]}"))),
        DataCell(Center(child: Text("${row["supName"]}"))),
        // DataCell(Center(child: Text("${row["custMobile"]}"))),
        // DataCell(Center(child: Text("${row["qty"]}"))),
        // DataCell(Center(child: Text("${row["amt"]}"))),
      DataCell(Center(child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Text("${row["qty"]}"),
            )))),

        DataCell(Center(child:
        Row(
          children: [
            IconButton(icon: Icon(Icons.remove_red_eye_outlined,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>preturnView(
                preturnNo: row["preturnNo"],
                date:row["date"],
                supCode:row["supCode"],
                supName:row["supName"],
                supMobile:row["supMobile"],
                supAddress:row["supAddress"],
                prodCode:row["prodCode"],
                prodName:row["prodName"],
                qty:row["qty"],
                rate:row["rate"],
                amtGST:row["amtGST"],
                total:row["total"],
              )));
            },),
            IconButton(icon: Icon(Icons.print,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>PreturnIndividualReport(
                preturnNo: row["preturnNo"],
                date:row["date"],
                supCode:row["supCode"],
                supName:row["supName"],
                supMobile:row["supMobile"],
                supAddress:row["supAddress"],
                prodCode:row["prodCode"],
                prodName:row["prodName"],
                qty:row["qty"],
                rate:row["rate"],
                amtGST:row["amtGST"],
                total:row["total"],
                grandTotal:row["grandTotal"],
              )));
            },),
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
*/










import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/preturn_individual_pdf.dart';
import 'package:vinayaga_project/purchase/preturn_individual_view.dart';
import 'package:vinayaga_project/purchase/preturn_overall_pdf.dart';
import 'package:vinayaga_project/purchase/purchase_individual_report.dart';
import 'package:vinayaga_project/purchase/purchase_orderin_pdf.dart';
import 'package:vinayaga_project/purchase/purchase_view.dart';
import 'package:vinayaga_project/purchase/purchaseview_pdf.dart';
import 'package:vinayaga_project/report/winding_report_pdf.dart';

import '../home.dart';


class PurchaseReturnReport extends StatefulWidget {
  const PurchaseReturnReport({Key? key}) : super(key: key);
  @override
  State<PurchaseReturnReport> createState() => _PurchaseReturnReportState();
}
class _PurchaseReturnReportState extends State<PurchaseReturnReport> {

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
      final url = Uri.parse('http://localhost:3309/get_preturn/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        // Use a Set to filter out duplicate custName values
        Set<String> uniqueCustNames = Set();

        // Filter out duplicate values based on 'custName'
        final List uniqueData = itemGroups
            .where((item) {
          String custName = item['preturnNo']?.toString() ?? '';
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

  void filterData(String searchText) {
    print("Search Text: $searchText");
    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all data without filtering by supplier name
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        filteredData = data.where((item) {
          String supName = item['supName']?.toString()?.toLowerCase() ?? '';
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
          String id = item['supName']?.toString()?.toLowerCase() ?? '';
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
      Grandtotal = calculateTotal(filteredData);
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

  @override
  Widget build(BuildContext context) {

    final formattedDate = fromDate != null ? DateFormat("dd-MM-yyyy").format(fromDate!) : "";
    final formattedDate2 = toDate != null ? DateFormat("dd-MM-yyyy").format(toDate!) : "";

    searchController.addListener(() {
      filterData(searchController.text);
    });

    return MyScaffold(
      route: "purchase_return_report",
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
                                  'Purchase Return Report',
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
                                              onChanged: (value) {
                                                String capitalizedValue = capitalizeFirstLetter(value);
                                                searchController.value = searchController.value.copyWith(
                                                  text: capitalizedValue,
                                                  selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                );
                                              },
                                              style: const TextStyle(fontSize: 13),
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(Icons.search),
                                                fillColor: Colors.white,
                                                filled: true,
                                                labelText: "Supplier/Company Name",
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
                                              List<String> suggestions =data
                                                  .where((item) =>
                                                  (item['supName']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['supName'].toString())
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
                                          if (fromDate == null || toDate == null) {
                                            setState(() {
                                              // Show an error message if either of the dates is not selected
                                              isDateRangeValid = false;
                                            });
                                          } else if (fromDate!.isAfter(toDate!)) {
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
                                        style: TextStyle(color: Colors.red, fontSize: 11),
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
                            const SizedBox(height: 20,),
                            PaginatedDataTable(
                              columnSpacing:95.0,
                              //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              rowsPerPage:25,
                              columns:   const [
                                DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("    Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Return Number",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Supplier Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Supplier/Company Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                //DataColumn(label: Center(child: Text("Quantity",style: TextStyle(fontWeight: FontWeight.bold),))),
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>PreturnOverallReport(
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
        DataCell(Center(child: Text("${row["preturnNo"]}"))),
        DataCell(Center(child: Text("${row["supCode"]}"))),
        DataCell(Center(child: Text("${row["supName"]}"))),
        // DataCell(Center(child: Text("${row["custMobile"]}"))),
        // DataCell(Center(child: Text("${row["qty"]}"))),
        // DataCell(Center(child: Text("${row["amt"]}"))),


        DataCell(Center(child:
        Row(
          children: [
            IconButton(icon: Icon(Icons.remove_red_eye_outlined,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>preturnView(
                preturnNo: row["preturnNo"],
                date:row["date"],
                supCode:row["supCode"],
                supName:row["supName"],
                supMobile:row["supMobile"],
                supAddress:row["supAddress"],
                pincode:row["pincode"],
                prodCode:row["prodCode"],
                prodName:row["prodName"],
                qty:row["qty"],
                rate:row["rate"],
                amtGST:row["amtGST"],
                total:row["total"],
              )));
            },),
            IconButton(icon: Icon(Icons.print,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>PreturnIndividualReport(
                preturnNo: row["preturnNo"],
                date:row["date"],
                supCode:row["supCode"],
                supName:row["supName"],
                supMobile:row["supMobile"],
                supAddress:row["supAddress"],
                prodCode:row["prodCode"],
                prodName:row["prodName"],
                pincode:row["pincode"],
                qty:row["qty"],
                rate:row["rate"],
                amtGST:row["amtGST"],
                total:row["total"],
                grandTotal:row["grandTotal"],
              )));
            },),
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


