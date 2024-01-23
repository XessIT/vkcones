
/*

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../home.dart';
import '../main.dart';
import '../purchase/purchase_overall_report.dart';
import '../sale/dc_individual_pdf.dart';
import '../sale/dc_view.dart';
import 'customer_report_pdf.dart';
import 'customeredit.dart';




class CustomerReport extends StatefulWidget {
  const CustomerReport({Key? key}) : super(key: key);
  @override
  State<CustomerReport> createState() => _CustomerReportState();
}

class _CustomerReportState extends State<CustomerReport> {
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  List<Map<String, dynamic>> data = [];
  @override


  void initState() {
    super.initState();
    //searchController;
    fetchData();
    _searchFocus.requestFocus();
    // filteredData = List.from(data);
    // filterData(''); // Add this line to show all data initially
  }

  FocusNode _searchFocus = FocusNode();
  List<Map<String, dynamic>> filteredData = [];
  List<List<TextEditingController>> controllers = [];
  List<List<FocusNode>> focusNodes = [];
  List<Map<String, dynamic>> rowData = [];
  bool showDeleteButtonInFirstRow = true;
  bool showInitialData = true;
  String selectedCustomer="";


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call filterData with an empty query when the page loads
    if (showInitialData) {
      filterData('');
    }
  }

  final TextEditingController searchController = TextEditingController();
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getcustomers'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        jsonData.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['date']);
          final DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA);
        });
        setState(() {
          data = jsonData.cast<Map<String, dynamic>>();
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
  void generateButtonPressed() {
    // Call your filterData function when the "Generate" button is pressed
    filterData(searchController.text);
  }


  void filterData(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredData = data.where((item) {
          final custName = item['custName'].toString().toLowerCase();
          final custCode = item['custCode'].toString().toLowerCase();
          final custMobile = item['custMobile'].toString().toLowerCase();

          return custName.contains(query.toLowerCase()) ||
              custCode.contains(query.toLowerCase()) ||
              custMobile.contains(query.toLowerCase());
        }).toList();
        showInitialData = false;
      } else {
        filteredData = List.from(data);
        showInitialData = true;
      }
    });
  }



  Future<void> deleteItem(BuildContext context, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3309/customerdelete/$id'),
      );
      if (response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerReport() )); // Close the dialog
      } else {
        throw Exception('Error deleting Item Group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete Item Group: $e');
    }
  }

  void showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this Customer?'),
          actions: [
            TextButton(
              onPressed: () {
                onDelete(id); // Call the onDelete function
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerReport() )); // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),

          ],
        );
      },
    );
  }

  void onDelete(int id) {
    // Implement your delete logic here
    // For example, you can call your existing deleteItem function
    deleteItem(context, id);
  }




  @override
  Widget build(BuildContext context) {

    return MyScaffold(
        route: "customer_report",
        body: SingleChildScrollView(
          child: Form(
            child: SingleChildScrollView(
              child: Column(children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Wrap(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: const Icon(
                                  Icons.note_alt_outlined,
                                  size: 25,
                                ),
                              ),
                              Text(
                                "Customer Entry",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 220,
                                          height: 50,
                                          child:
                                          TypeAheadFormField<String>(
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
                                              List<String> custMobilesuggestions =data
                                                  .where((item) =>
                                                  (item['custMobile']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['custMobile'].toString())
                                                  .toSet() // Remove duplicates using a Set
                                                  .toList();
                                              List<String> suggestions = [
                                                ...custNamesuggestions,
                                                ...custCodesuggestions,
                                                ...custMobilesuggestions,
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
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        MaterialButton(
                                          onPressed: (){
                                            searchController.addListener(() {
                                              filterData(searchController.text);
                                            });
                                            if (showInitialData)
                                              Text('Display Initial Data');
                                            else
                                              Text('Display Filtered Data');
                                            generateButtonPressed();
                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                          ),
                                          color: Colors.green.shade600,
                                          child: const Text(
                                            "Generate",
                                            style:
                                            TextStyle(color: Colors.white),
                                          ),

                                        ),

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: const Text(
                                'Report Details',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding:  EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      // SizedBox(height: 10,),

                                      PaginatedDataTable(
                                        columnSpacing:20.0,
                                        //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        rowsPerPage:25,
                                        columns:   const [
                                          DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("     Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("  Customer Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Customer/Company Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Customer Mobile",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Customer Address",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("       GSTIN",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("     Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                                        ],
                                        source: _YourDataTableSource(filteredData, context, onDelete, showDeleteConfirmationDialog),

                                      ),

                                      if( filteredData.isEmpty)          Text("",style: (TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),)
                                    ],
                                  ),
                                )
                            ),
                          ),
                        ),
                      ],
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerReportPDFView(
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
                            */
/*  Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>const Home()));*//*
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
                ),
              ]),
            ),
          ),
        ));
  }
}

class _YourDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  final Function(int) onDelete;
  final Function(BuildContext, int) showDeleteConfirmationDialog;
  //final bool generatedButton;

  _YourDataTableSource(this.data, this.context, this.onDelete, this.showDeleteConfirmationDialog);


  void printButtonPressed(int rowIndex) {

    if (rowIndex >= 0 && rowIndex < data.length) {
      final selectedRowData = data[rowIndex];
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }


    final row = data[index];
    final id = row["id"];



    return DataRow(
      cells: [
        DataCell(Center(child: Text("${index + 1}"))),
        DataCell(Center(
          child:   Text(
            row["date"] != null
                ? DateFormat('dd-MM-yyyy').format(
              DateTime.parse("${row["date"]}"),
            ) : "",
          ),
        )),

        DataCell(Center(child: Text("${row["custCode"]}"))),
        DataCell(Center(child: Text("${row["custName"]}"))),
        DataCell(Center(child: Container(
            constraints: BoxConstraints(maxWidth:150),child: Text("${row["custMobile"]}")))),
        DataCell(Center(child: Text("${row["custAddress"]}"))),
        DataCell(Center(child: Text("${row["gstin"]}"))),
        DataCell(Center(child:Container(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.edit ,color:Colors. blue,),onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>custedit(
                    customerData:data,
                    id: row["id"],
                    date:row["date"],
                    custName:row["custName"],
                    custMobile:row["custMobile"],
                    custAddress:row["custAddress"],
                    pincode:row["pincode"],
                    custCode:row["custCode"],
                    gstin:row["gstin"],
                  )));
                },),

                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    showDeleteConfirmationDialog(context, id);
                  },
                ),
              ],
            ),
          ),
        ),)),
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

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/report/supplier_overall_pdf.dart';
import '../home.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import '../purchase/supplier_view.dart';
import 'customer_report_pdf.dart';
import 'customeredit.dart';


class CustomerReport extends StatefulWidget {
  const CustomerReport({Key? key}) : super(key: key);

  @override
  State<CustomerReport> createState() => _CustomerReportState();
}
class _CustomerReportState extends State<CustomerReport> {

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
        Uri.parse('http://localhost:3309/customerdelete/$id'),
      );
      if (response.statusCode == 200) {
        /*  Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );*/
      } else {
        throw Exception('Error deleting Item Group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete Item Group: $e');
    }
  }
  void onDelete(int id) {
    // Implement your delete logic here
    // For example, you can call your existing deleteItem function
    deleteItem(context, id);
  }

  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/getcustomers/');
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
          String supName = item['custName']?.toString()?.toLowerCase() ?? '';
          String supCode = item['custCode']?.toString()?.toLowerCase() ?? '';
          String supAddress = item['custMobile']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();

          return supName.contains(searchTextLowerCase) ||
              supCode.contains(searchTextLowerCase) ||
              supAddress.contains(searchTextLowerCase);
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
          String supName = item['custName']?.toString()?.toLowerCase() ?? '';
          String supCode = item['custCode']?.toString()?.toLowerCase() ?? '';
          String supAddress = item['custMobile']?.toString()?.toLowerCase() ?? '';

          return supName.contains(searchTextLowerCase) ||
              supCode.contains(searchTextLowerCase) ||
              supAddress.contains(searchTextLowerCase);

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
      route: "supplier_report",
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
                                  'Customer Report',
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
                                              if (pattern.isEmpty) {
                                                return [];
                                              }
                                              List<String> supNamesuggestions =data
                                                  .where((item) =>
                                                  (item['custName']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['custName'].toString())
                                                  .toSet() // Remove duplicates using a Set
                                                  .toList();
                                              List<String> supCodesuggestions = data
                                                  .where((item) =>
                                                  (item['custCode']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['custCode'].toString())
                                                  .toSet() // Remove duplicates using a Set
                                                  .toList();
                                              List<String> supAddresssuggestions = data
                                                  .where((item) =>
                                                  (item['custMobile']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['custMobile'].toString())
                                                  .toSet() // Remove duplicates using a Set
                                                  .toList();
                                              List<String> suggestions = [
                                                ...supNamesuggestions,
                                                ...supCodesuggestions,
                                                ...supAddresssuggestions,
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
                                  Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: MaterialButton(
                                        color: Colors.green.shade500,
                                        height: 40,
                                        onPressed: () {
                                          filterData(searchController.text);
                                          searchController.addListener(() {
                                            filterData(searchController.text);
                                          });},
                                        child: const Text("Generate", style: TextStyle(color: Colors.white)),
                                      )
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.refresh),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerReport()));
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
                              columnSpacing:68.0,
                              //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              rowsPerPage:25,
                              columns:   const [
                                DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("    Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Customer Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Customer/Company Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Address",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("   Mobile",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("     Action",style: TextStyle(fontWeight: FontWeight.bold),))),
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
                        child:
                        filteredData.isEmpty?Text(""):
                        MaterialButton(
                          color: Colors.green.shade600,
                          height: 40,
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerReportPDFView(
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
        DataCell(Center(
          child: Text(
            row["date"] != null
                ? DateFormat('dd-MM-yyyy').format(
              DateTime.parse("${row["date"]}").toLocal(),
            )
                : "",
          ),
        )),
        // DataCell(Center(child: Text("${row["invoiceNo"]}"))),
        DataCell(Center(child: Text("${row["custCode"]}"))),
        DataCell(Center(child: Text("${row["custName"]}"))),
        DataCell(Center(child: Text("${row["custAddress"]}"))),
        DataCell(Center(child: Text("${row["custMobile"]}"))),
        // DataCell(Center(child: Text("${row["custMobile"]}"))),
        // DataCell(Center(child: Text("${row["qty"]}"))),
        // DataCell(Center(child: Text("${row["amt"]}"))),
        /*   DataCell(Center(child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Text("${row["grandTotal"]}"),
            )))),*/
        DataCell(Center(child:
        Row(
          children: [
            IconButton(icon: Icon(Icons.edit ,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>custedit(
                customerData:data,
                id: row["id"],
                date:row["date"],
                custName:row["custName"],
                custMobile:row["custMobile"],
                custAddress:row["custAddress"],
                pincode:row["pincode"],
                custCode:row["custCode"],
                gstin:row["gstin"],
              )));
            },),
            IconButton(icon: Icon(Icons.delete,color:Colors. red,),
              onPressed: (){
                showDeleteConfirmationDialog(context, id);
              },),
          ],
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
          content: Text('Are you sure you want to delete this supplier?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const CustomerReport()));
                onDelete(id); // Call the onDelete function
                // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
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

