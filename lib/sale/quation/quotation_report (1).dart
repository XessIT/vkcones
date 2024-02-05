
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/purchase_individual_report.dart';
import 'package:vinayaga_project/purchase/purchase_orderin_pdf.dart';
import 'package:vinayaga_project/purchase/purchase_view.dart';
import 'package:vinayaga_project/purchase/purchaseview_pdf.dart';
import 'package:vinayaga_project/report/winding_report_pdf.dart';
import 'package:vinayaga_project/sale/quation/quotation_individual_report_pdf%20(2).dart';
import 'package:vinayaga_project/sale/quation/quotation_item_individual_report%20(4).dart';
import 'package:vinayaga_project/sale/quation/quotation_report_pdf%20(1).dart';

import '../../home.dart';




class QuotationReport extends StatefulWidget {
  const QuotationReport({Key? key}) : super(key: key);
  @override
  State<QuotationReport> createState() => _QuotationReportState();
}
class _QuotationReportState extends State<QuotationReport> {

  List<String> supplierSuggestions = [];
  String selectedSupplier = "";
  bool isDateRangeValid=true;
  final ScrollController _scrollController = ScrollController();

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
      final url = Uri.parse('http://localhost:3309/quotation_entry/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        // Use a Set to filter out duplicate custName values
        Set<String> uniqueCustNames = Set();

        // Filter out duplicate values based on 'custName'
        final List uniqueData = itemGroups
            .where((item) {
          String custName = item['quotNo']?.toString() ?? '';
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
          String supName = item['custName']?.toString()?.toLowerCase() ?? '';
          String quotNo = item['quotNo']?.toString()?.toLowerCase() ?? '';
          String custMobile = item['custMobile']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();

          return supName.contains(searchTextLowerCase) ||
              quotNo.contains(searchTextLowerCase) ||
              custMobile.contains(searchTextLowerCase);
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
          String quotNo = item['quotNo']?.toString()?.toLowerCase() ?? '';
          String custMobile = item['custMobile']?.toString()?.toLowerCase() ?? '';


          return supName.contains(searchTextLowerCase) ||
              quotNo.contains(searchTextLowerCase) ||
              custMobile.contains(searchTextLowerCase);
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
    // searchController.addListener(() {
    //   filterData(searchController.text);
    // });
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
                             Row(
                              children: [
                                Icon(Icons.report,),
                                SizedBox(width:10,),
                                Text(
                                  'Quotation Report',
                                  style: TextStyle(
                                    fontSize:20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.refresh),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> QuotationReport()));
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
                            Padding(
                              padding: const EdgeInsets.only(right:0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Wrap(
                                  //mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 37,left: 20),
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
                                    // SizedBox(width: 11,),
                                    Padding(
                                      padding: const EdgeInsets.only(top:37,left:10),
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
                                                List<String> quotNosuggestions =data
                                                    .where((item) =>
                                                    (item['quotNo']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map((item) => item['quotNo'].toString())
                                                    .toSet() // Remove duplicates using a Set
                                                    .toList();
                                                List<String> custMobilesuggestions =data
                                                    .where((item) =>
                                                    (item['custMobile']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map((item) => item['custMobile'].toString())
                                                    .toSet() // Remove duplicates using a Set
                                                    .toList();
                                                List<String> suggestions =[
                                                  ...custMobilesuggestions,
                                                  ...quotNosuggestions,
                                                  ...custNamesuggestions
                                                ]
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
                                        padding: const EdgeInsets.only(left:20,top:37),
                                        child: MaterialButton(
                                          color: Colors.green.shade500,
                                          height: 40,
                                          onPressed: () {
                                            filterData(searchController.text);
                                            searchController.addListener(() {
                                              filterData(searchController.text);
                                            });
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
                                          style: TextStyle(color: Colors.red, fontSize: 11),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10,)
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
                                child: SizedBox(
                                  width:1200,
                                  child: PaginatedDataTable(
                                    columnSpacing:110.0,
                                    //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    rowsPerPage:25,
                                    columns:   const [
                                      DataColumn(label: Center(child: Text("           S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Padding(
                                        padding: EdgeInsets.only(left:30),
                                        child: Text("  Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                      ))),
                                      DataColumn(label: Center(child: Text("     Quotation Number",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      //  DataColumn(label: Center(child: Text("Customer Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text("Customer/Company Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Padding(
                                        padding: EdgeInsets.only(left:35),
                                        child: Text("Mobile",style: TextStyle(fontWeight: FontWeight.bold),),
                                      ))),
                                      //DataColumn(label: Center(child: Text("     Action",style: TextStyle(fontWeight: FontWeight.bold),))),
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
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                        child: MaterialButton(
                          color: Colors.green.shade600,
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>QuotationReportPDFView(
                              quotNo: filteredData[0]['quotNo'],
                              custAddress: filteredData[0]['custAddress'],
                              customerData: filteredData, // Provide the actual custName value
                              date: filteredData[0]['date'], customerName: filteredData[0]['custName'], customerMobile: filteredData[0]['custMobile'], // Provide the actual custMobile value

                            )));
                          },child: const Text("PRINT",style: TextStyle(color: Colors.white),),),
                      ),
                      MaterialButton(
                        color: Colors.red,
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
                      SizedBox(width: 20,),
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
          child: Text(row["date"] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse("${row["date"]}")) : "",),)),
        DataCell(Center(child: Text("${row["quotNo"]}"))),
        DataCell(Center(child: Text("${row["custName"]}"))),
        DataCell(Center(child: Text("${row["custMobile"]}"))),
        /* DataCell(Center(child: Row(
          children: [
            IconButton(icon: Icon(Icons.remove_red_eye_outlined,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>QuotationItem(
                quotNo: row["quotNo"],
                date:row["date"],
                customerName:row["custName"],
                customerMobile:row["custMobile"],
                customerAddress:row["custAddress"],
                pincode:row["pincode"],
                custCode:row["custCode"],
              )));
            },),
            *//*IconButton(icon: Icon(Icons.print,color: Colors.blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>QuotationIndividualReportPDFView( quotNo: row["quotNo"],
                date:row["date"],
                customerName:row["custName"],
                customerMobile:row["custMobile"],
                customerAddress:row["custAddress"],
                custCode:row["custCode"],
              )));
            },*//*
          //  ),
          ],
        ))),*/
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