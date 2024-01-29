/*
import 'package:flutter/material.dart';

import '../main.dart';
class SalaryPaymentReport extends StatefulWidget {
  const SalaryPaymentReport({Key? key}) : super(key: key);

  @override
  State<SalaryPaymentReport> createState() => _SalaryPaymentReportState();
}

class _SalaryPaymentReportState extends State<SalaryPaymentReport> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "machine_report",
        body: SingleChildScrollView(
          child: Form(
            child: Center(
              child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text("Machine Report", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(right: 800),
                      child: Wrap(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Machine Name"),
                              SizedBox(
                                width: 200,height: 70,
                                child: TextFormField(style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                                border: TableBorder.all(),
                                defaultColumnWidth: const FixedColumnWidth(140.0),
                                columnWidths: const <int, TableColumnWidth>{
                                  0:FixedColumnWidth(90),
                                  1:FixedColumnWidth(100),
                                  2:FixedColumnWidth(100),
                                  7:FixedColumnWidth(150),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children:[
                                  //Table row starting
                                  TableRow(
                                      children: [
                                        TableCell(
                                            child:Center(
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 8,),
                                                  Text('S.No',),
                                                  const SizedBox(height: 8,)
                                                ],
                                              ),)),
                                        //Meeting Name

                                        TableCell(
                                            child:Center(
                                              child: Text('Machine Name',),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Machine Model',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Machine SerialNo',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Machine SupplierName',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Purchase Date',
                                              ),)),
                                        const TableCell(
                                            child:Center(
                                              child: Text('Warranty Date',
                                              ),)),
                                        TableCell(
                                            child:Center(
                                              child: Text('Action',
                                              ),)),



                                      ]),
                                  // Table row end

                                  //Table row start
                                  TableRow(
                                    // decoration: BoxDecoration(color: Colors.grey[200]),
                                      children: [

                                        TableCell(child: Center(child: Column(
                                          children: [
                                            const SizedBox(height: 10,),
                                            Text(""),
                                            const SizedBox(height: 10,)
                                          ],
                                        ))),
                                        TableCell(child: Center(child: Column(
                                          children: [
                                            const SizedBox(height: 10,),
                                            Text(""),
                                            const SizedBox(height: 10,)
                                          ],
                                        ))),
                                        TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(""),
                                        )
                                        ),

                                        TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(""),
                                        )
                                        ),
                                        TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(""),
                                        )
                                        ),  TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(""),
                                        )
                                        ),
                                        TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(""),
                                        )
                                        ),
                                        TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 45,height: 30,
                                                child: MaterialButton(

                                                  color: Colors.green.shade600,
                                                  onPressed: (){},child:Icon(Icons.edit_note,color: Colors.white,),),
                                              ),
                                              const SizedBox(width: 5,),
                                              SizedBox(width: 45,height: 30,
                                                child: MaterialButton(
                                                  color: Colors.red.shade600,
                                                  onPressed: (){},child:Icon(Icons.delete,color: Colors.white,),),
                                              ),
                                            ],
                                          ),
                                        )
                                        ),




                                      ]
                                  )
                                ]
                            )
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        ) );
  }
}
*/
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;

import '../home.dart';
import '../sale/quation/quotation_individual_report_pdf (2).dart';
import '../sale/quation/quotation_item_individual_report (4).dart';




class SalaryPaymentReport extends StatefulWidget {
  const SalaryPaymentReport({Key? key}) : super(key: key);
  @override
  State<SalaryPaymentReport> createState() => _SalaryPaymentReportState();
}
class _SalaryPaymentReportState extends State<SalaryPaymentReport> {
  DateTime selectedDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  TextEditingController searchController = TextEditingController();

  List<String> itemGroupValues = [];
  List<String> quotNumber = [];
  String selectedCustomer = '';

  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/quotation_entry/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;
        setState(() {
          data = itemGroups.cast<Map<String, dynamic>>();
        });
        print('Data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  final TextEditingController  _FromDatecontroller = TextEditingController();
  final TextEditingController  _ToDatecontroller = TextEditingController();


  bool generatedButton = false;
  bool isAnyFieldNotEmpty() {
    return _FromDatecontroller.text.isNotEmpty ||
        _ToDatecontroller.text.isNotEmpty ||
        searchController.text.isNotEmpty;
  }


  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filteredData = [];
  void filterData(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData = data;
      } else {
        filteredData = data.where((item) {
          String id = item['custName']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();
          return id.contains(searchTextLowerCase);
        }).toList();
      }
    });
  }

  String? errorMessage;

  void applyDateFilter() {
    setState(() {
      if (searchController.text.isEmpty) {
        filteredData = data.where((item) {
          String dateStr = item['date']?.toString() ?? '';
          DateTime? itemDate = DateTime.tryParse(dateStr);

          if (itemDate != null &&
              !itemDate.isBefore(selectedDate) &&
              !itemDate.isAfter(selectedToDate.add(Duration(days: 1)))) {
            return true;
          }
          return false;
        }).toList();
      } else {
        filteredData = data.where((item) {
          String id = item['custName']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchController.text.toLowerCase();
          String dateStr = item['date']?.toString() ?? '';
          DateTime? itemDate = DateTime.tryParse(dateStr);

          if (itemDate != null &&
              !itemDate.isBefore(selectedDate) &&
              !itemDate.isAfter(selectedToDate.add(Duration(days: 1))) &&
              id.contains(searchTextLowerCase)) {
            return true;
          }
          return false;
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();

    _searchFocus.requestFocus();
  }
  final FocusNode _searchFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

    var formattedToDate = DateFormat('dd-MM-yyyy').format(selectedToDate);
    searchController.addListener(() {
      filterData(searchController.text);
    });

    return MyScaffold(
      route: "salary_payment_report",backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height:10,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                            const Row(
                              children: [
                                Icon(Icons.edit_note,),
                                SizedBox(width:10,),
                                Text(
                                  'Salary Payment Report',
                                  style: TextStyle(
                                    fontSize:22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:550),
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: 150),
                                    child: Text(
                                      errorMessage ?? '',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 37,left: 23),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text("From Date"),
                                  // SizedBox(height: 5,),
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
                                      // onChanged: (query) {
                                      //   filterData(query);
                                      // },
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
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 37,left: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text("To Date"),
                                  // SizedBox(height: 5,),
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
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 30,top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 220,
                                    height: 40,
                                    child: TypeAheadFormField<String>(
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: searchController,
                                        style: const TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          suffixIcon: Icon(Icons.search),
                                          fillColor: Colors.white,
                                          filled: true,
                                          labelText: "Customer/Company Name",
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
                                            (item['custName']?.toString()?.toLowerCase() ?? '')
                                                .startsWith(pattern.toLowerCase()))
                                            .map((item) => item['custName'].toString())
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
                                        // Store the selected customer name in the state variable
                                        setState(() {
                                          selectedCustomer = suggestion;
                                          // Update the text field's controller with the selected name
                                          searchController.text = suggestion;
                                        });
                                        print('Selected Customer: $selectedCustomer');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width:10,),

                            MaterialButton(
                              color: Colors.green.shade600,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                              height: 40,
                              onPressed: () {
                                if (isAnyFieldNotEmpty()) {
                                  generatedButton = true;

                                  // No need to set selectedCustomer here, it's already done in onSuggestionSelected
                                  print('Before Filter: selectedCustomer=$selectedCustomer');

                                  filterData(searchController.text);
                                  applyDateFilter();

                                  print('After Filter: selectedCustomer=$selectedCustomer');
                                } else {
                                  setState(() {
                                    errorMessage = "At least one field is mandatory";
                                  });
                                }
                              },
                              child: const Text("Generate", style: TextStyle(color: Colors.white)),
                            ),


                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                //  SizedBox(height:,),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
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
                                          child: Text("Report Details",style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),)),
                                      const SizedBox(height: 20,),
                                      PaginatedDataTable(
                                        columnSpacing:100.0,
                                        //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        rowsPerPage:10,
                                        columns:   const [
                                          DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Employee ID",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          //  DataColumn(label: Center(child: Text("Customer Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Employee Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Position",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("     Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                                        ],
                                        source: _YourDataTableSource(filteredData,context),                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(generatedButton==true)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                                  child: MaterialButton(
                                    shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),

                                    color: Colors.green.shade600,
                                    height: 40,
                                    onPressed: (){

                                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalaryPaymentReportPDFView(
                                      //   quotNo: filteredData[0]['quotNo'],
                                      //   custAddress: filteredData[0]['custAddress'],
                                      //   customerData: filteredData, // Provide the actual custName value
                                      //   date: filteredData[0]['date'], customerName: filteredData[0]['custName'], customerMobile: filteredData[0]['custMobile'], // Provide the actual custMobile value
                                      //
                                      // )
                                      // ));
                                    },child: const Text("PRINT",style: TextStyle(color: Colors.white),),),
                                ),
                              MaterialButton(
                                shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                color: Colors.red,

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
                              SizedBox(width: 20,),
                            ],
                          )
                        ],
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
  _YourDataTableSource(this.data,this.context);

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
          child: Text(row[""] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse("${row["date"]}")) : "",),)),
        DataCell(Center(child: Text("${row[""]}"))),
        //DataCell(Center(child: Text("${row["custCode"]}"))),
        DataCell(Center(child: Text("${row[""]}"))),
        DataCell(Center(child: Row(
          children: [
            IconButton(icon: Icon(Icons.print,color: Colors.blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>QuotationIndividualReportPDFView( quotNo: row["quotNo"],
                date:row["date"],
                customerName:row["custName"],
                customerMobile:row["custMobile"],
                customerAddress:row["custAddress"],
                custCode:row["custCode"],
              )));
            },
            ),
          ],
        ))),
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