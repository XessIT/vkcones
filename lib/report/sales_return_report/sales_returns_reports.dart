import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/report/sales_return_report/sale_return_individual_reports.dart';
import 'package:vinayaga_project/sale/sales_return/sales_return_report_pdf.dart';
import '../../home.dart';
import '../../sale/sales_return/sales_return_individual_pdf.dart';

class SalesReturnsReports extends StatefulWidget {
  const SalesReturnsReports({Key? key}) : super(key: key);
  @override
  State<SalesReturnsReports> createState() => _SalesReturnsReportsState();
}
class _SalesReturnsReportsState extends State<SalesReturnsReports> {

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
  final ScrollController _scrollController = ScrollController();




  List<String> itemGroupValues = [];
  List<String> invoiceNumber = [];
  String selectedCustomer="";
  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/get_sales_return_report');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;
        Set<String> uniqueInvoiceNumbers = Set();
        List<Map<String, dynamic>> uniqueData = [];
        for (var item in itemGroups) {
          String invoiceNo = item['salRetNo'];
          if (!uniqueInvoiceNumbers.contains(invoiceNo)) {
            uniqueInvoiceNumbers.add(invoiceNo);
            uniqueData.add(item);
          }
        }

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
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        filteredData = data.where((item) {
          String custName = item['custName']?.toString()?.toLowerCase() ?? '';
          String custCode = item['custCode']?.toString()?.toLowerCase() ?? '';
          String invoiceNo = item['invoiceNo']?.toString()?.toLowerCase() ?? '';
          String salRetNo = item['salRetNo']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();
          return custName.contains(searchTextLowerCase) ||
              custCode.contains(searchTextLowerCase) ||
              invoiceNo.contains(searchTextLowerCase) ||
              salRetNo.contains(searchTextLowerCase);
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
          String custName = item['custName']?.toString()?.toLowerCase() ?? '';
          String custCode = item['custCode']?.toString()?.toLowerCase() ?? '';
          String invoiceNo = item['invoiceNo']?.toString()?.toLowerCase() ?? '';
          String salRetNo = item['salRetNo']?.toString()?.toLowerCase() ?? '';

          return custName.contains(searchTextLowerCase) ||
              custCode.contains(searchTextLowerCase) ||
              invoiceNo.contains(searchTextLowerCase) ||
              salRetNo.contains(searchTextLowerCase);

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

    _searchFocus.requestFocus();
    filteredData = List<Map<String, dynamic>>.from(data);
  }
  final FocusNode _searchFocus = FocusNode();

  @override
  Widget build(BuildContext context) {

    final formattedDate = fromDate != null ? DateFormat("dd-MM-yyyy").format(fromDate!) : "";
    final formattedDate2 = toDate != null ? DateFormat("dd-MM-yyyy").format(toDate!) : "";

    return MyScaffold(
      route: "sales_return_reportss",backgroundColor: Colors.white,
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
                             Row(
                              children: [
                                Icon(Icons.report,),
                                SizedBox(width:10,),
                                Text(
                                  'Sales Return Report',
                                  style: TextStyle(
                                    fontSize:20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.refresh),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> SalesReturnsReports()));
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
                              padding: const EdgeInsets.only(left:20),
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
                                                  labelText: "Search",
                                                  labelStyle: TextStyle(fontSize: 11),
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
                                                List<String> invoiceNosuggestions =data
                                                    .where((item) =>
                                                    (item['invoiceNo']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map((item) => item['invoiceNo'].toString())
                                                    .toSet() // Remove duplicates using a Set
                                                    .toList();
                                                List<String> salRetNoCodesuggestions =data
                                                    .where((item) =>
                                                    (item['salRetNo']?.toString()?.toLowerCase() ?? '')
                                                        .startsWith(pattern.toLowerCase()))
                                                    .map((item) => item['salRetNo'].toString())
                                                    .toSet() // Remove duplicates using a Set
                                                    .toList();
                                                List<String> suggestions = [
                                                  ...custNamesuggestions,
                                                  ...custCodesuggestions,
                                                  ...invoiceNosuggestions,
                                                  ...salRetNoCodesuggestions
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
                                        padding: const EdgeInsets.only(top:37,left:20),
                                        child: MaterialButton(
                                          color: Colors.green.shade500,
                                          height: 40,
                                          onPressed: () {
                                            filterData(searchController.text);
                                            searchController.addListener(() {
                                              filterData(searchController.text);

                                            });
                                            generatedButton = true;
                                            if (fromDate!.isAfter(toDate!)) {
                                              setState(() {
                                                // Show an ersror message if 'From Date' is greater than 'To Date'
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
                                              ? "* 'From Date' must be less than\n  or equal to 'To Date'."
                                              : "Enter any one Field" ,
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
                            filteredData.isNotEmpty?
                            Scrollbar(
                              thumbVisibility: true,
                              controller: _scrollController,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController,
                                child: SizedBox(
                                  width: 1100,
                                  child: PaginatedDataTable(

                                    columnSpacing:filteredData.isNotEmpty?50.0:180,
                                    //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    rowsPerPage:25,
                                    columns:    [
                                      DataColumn(label: Center(child: filteredData!.isNotEmpty?Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),):Text(""))),
                                      DataColumn(label: Center(child:filteredData!.isNotEmpty? Text("Date",style: TextStyle(fontWeight: FontWeight.bold),):Text(""))),
                                      DataColumn(label: Center(child:filteredData!.isNotEmpty? Text("Invoice No",style: TextStyle(fontWeight: FontWeight.bold)):Text(""),)),
                                      DataColumn(label: Center(child: filteredData!.isNotEmpty?Text("Sales Return No",style: TextStyle(fontWeight: FontWeight.bold)):Text(""),)),
                                      DataColumn(label: Center(child:filteredData!.isNotEmpty? Text("Customer Code",style: TextStyle(fontWeight: FontWeight.bold)):Text(""))),
                                      DataColumn(label: Center(child:filteredData!.isNotEmpty? Text("Customer/Company Name",style: TextStyle(fontWeight: FontWeight.bold)):Text(""))),
                                      DataColumn(label: Center(child:filteredData!.isNotEmpty? Text("Grand Total",style: TextStyle(fontWeight: FontWeight.bold)):Text(""))),
                                      DataColumn(
                                        label: Center(child:filteredData!.isNotEmpty? Text("    Action", style: TextStyle(fontWeight: FontWeight.bold)):Text("")),

                                      ),
                                    ],
                                    source: _YourDataTableSource(filteredData,context,generatedButton),

                                  ),
                                ),
                              ),
                            ):Text("No Data Available",style: TextStyle(fontWeight: FontWeight.bold,),)
                            /*  SizedBox(height: 16),
                            if (filteredData.isNotEmpty)
                              Text(
                                'Total Grand Total: ${calculateTotalGrandTotal(filteredData)}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),*/
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
                      if( filteredData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                          child: MaterialButton(
                            color: Colors.green.shade600,
                            height: 40,
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>SalesReturnReportPDF(
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

  _YourDataTableSource(this.data, this.context, this.generatedButton);

  @override
  DataRow? getRow(int index) {
    if (data.isEmpty) {
      // If filteredData is empty, show a special row with a message
      return DataRow(cells: [
        DataCell(
          Center(
            child: Text(
              '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),DataCell(
          Center(
            child: Text(
              '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),DataCell(
          Center(
            child: Text(
              'No data found.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),DataCell(
          Center(
            child: Text(
              '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),DataCell(
          Center(
            child: Text(
              '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),DataCell(
          Center(
            child: Text(
              '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),DataCell(
          Center(
            child: Text(
              '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),DataCell(
          Center(
            child: Text(
              '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ]);
    }

    if (index >= data.length) {
      return null;
    }

    final row = data[index];

    return DataRow(
      cells: [
        DataCell(Center(child: Text("${index + 1}"))),
        DataCell(Center(child: Text(row["date"] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse("${row["date"]}")) : "",),)),
        DataCell(Center(child: Text("${row["invoiceNo"]}"))),
        DataCell(Center(child: Text("${row["salRetNo"]}"))),
        DataCell(Center(child: Text("${row["custCode"]}"))),
        DataCell(Center(child: Text("${row["custName"]}"))),
        DataCell(Center(child: Text("${row["grandTotal"]}"))),
        DataCell(Center(
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SalesReturnIndividualReport(
                    salRetNo: row["salRetNo"],
                    custCode: row["custCode"],
                    custName: row["custName"],
                    custpincode: row["pincode"],
                    grandtotal: row["grandTotal"],
                    date: row["date"],
                  )));
                },
                icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue,),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SalesReturnIndividualReportPDFView(
                    salRetNo: row["salRetNo"],
                    custCode: row["custCode"],
                    custName: row["custName"],
                    custpincode: row["pincode"],
                    grandtotal: row["grandTotal"],
                    date: row["date"],
                  )));
                },
                icon: Center(child: const Icon(Icons.print, color: Colors.blue,)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  @override
  int get rowCount => data.isEmpty ? 1 : data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

