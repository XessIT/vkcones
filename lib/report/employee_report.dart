import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;

import '../home.dart';
import 'employeeDetails_pdf.dart';
import 'employeeDetails_report.dart';
import 'employee_report_pdf.dart';

class EmployeeReport extends StatefulWidget {
  const EmployeeReport({Key? key}) : super(key: key);
  @override
  State<EmployeeReport> createState() => _EmployeeReportState();
}
class _EmployeeReportState extends State<EmployeeReport> {
  List<String> supplierSuggestions = [];
  String selectedSupplier = "";
  bool isDateRangeValid=true;
  int currentPage = 1;
  int rowsPerPage = 10;
  String? selectedCustomer="";


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
      final url = Uri.parse('http://localhost:3309/employee_get_report/');
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
          String supName = item['emp_code']?.toString()?.toLowerCase() ?? '';
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
      route: "employee_report",
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
                                      'Employee Report',
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
                                          height: 70,
                                          child: TypeAheadFormField<String>(
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
                                                labelText: "Employee Name or ID", // Update label
                                                labelStyle: TextStyle(fontSize: 13, color: Colors.black),
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
                                                  .where((item) {
                                                String empName = item['first_name']?.toString()?.toLowerCase() ?? '';
                                                String empID = item['emp_code']?.toString()?.toLowerCase() ?? '';
                                                return empName.contains(pattern.toLowerCase()) || empID.contains(pattern.toLowerCase());
                                              })
                                                  .map<String>((item) =>
                                              '${item['first_name']} (${item['emp_code']})') // Modify this line to match your data structure
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
                                              String selectedEmpName = suggestion.split(' ')[0];
                                              String selectedEmpID = suggestion.split('(')[1].split(')')[0];
                                              setState(() {
                                                selectedCustomer = selectedEmpID;
                                                // Use selectedEmpID as needed
                                                searchController.text = selectedEmpID;

                                              });
                                              print('Selected Customer: $selectedCustomer, ID: $selectedEmpID');
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(bottom:20),
                                      child: IconButton(
                                        icon: Icon(Icons.refresh),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeReport()));
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom:20),
                                      child: IconButton(
                                        icon: Icon(Icons.arrow_back),
                                        onPressed: () {
                                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalaryCalculation()));
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),   ],
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
                            PaginatedDataTable(
                              columnSpacing:90.0,
                              rowsPerPage:25,
                              columns:   const [
                                DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Emp ID",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Employee Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Mobile",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Position",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("  Salary",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Action",style: TextStyle(fontWeight: FontWeight.bold),))),
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeReportPDF(
                              customerData : filteredData,
                            )));
                          },child: const Text("PRINT",style: TextStyle(color: Colors.white),),),

                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                        child: MaterialButton(
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
        DataCell(Center(child: Text("${row["emp_code"]}"))),
        DataCell(Center(child: Text("${row["first_name"]}"))),
        DataCell(Center(child: Text("${row["empMobile"]}"))),
        DataCell(Center(child: Text("${row["empPosition"]}"))),
        DataCell(Center(child: Text("${row["salary"]}"))),
        DataCell(Container(
          child: Row(children: [
            IconButton(
              onPressed: (){
                String fathername=row["fatherName"];
                String fatherMobile=row["fatherName"];
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeDetails(
                  // empPhoto:row["empPhoto"],
                  empID:row["emp_code"],
                  empName:row["first_name"],
                  empAddress :row["empAddress"],
                  pincode :row["pincode"],
                  empMobile:row["empMobile"],
                  dob:row["dob"],
                  age:row["age"],
                  bloodgroup:row["bloodgroup"],
                  gender:row["gender"],
                  maritalStatus:row["maritalStatus"],
                  gaurdian: fathername.isEmpty? row["spouseName"]??"":fathername,
                  gaurdianmobile:fatherMobile.isEmpty?row["spouseName"]??"":fatherMobile,
                  education:row["education"],
                  doj:row["doj"],
                  end:row["endingDate"],
                  deptName:row["deptName"],
                  empPosition:row["empPosition"],
                  salary:row["salaryType"],
                  daySalary:row["salary"],
                  shift:row["shift"],
                  acNumber:row["acNumber"],
                  acHoldername:row["acHoldername"],
                  bank:row["bank"],
                  branch:row["branch"],
                  ifsc:row["ifsc"],
                  pan:row["pan"],
                  aadhar:row["aadhar"],
                )
                ));
              },icon:const Icon(Icons.remove_red_eye_outlined),
              color: Colors.blue.shade600,
            ),

            IconButton(
              onPressed: (){
                String fathername=row["fatherName"];
                String fatherMobile=row["fatherName"];
                Navigator.push(context, MaterialPageRoute(builder: (context)=> EmployeeReportPdf(
                  // empPhoto:row["empPhoto"],
                  empID:row["emp_code"],
                  empName:row["first_name"],
                  empAddress :row["empAddress"],
                  pincode :row["pincode"],
                  empMobile:row["empMobile"],
                  dob:row["dob"],
                  age:row["age"],
                  bloodgroup:row["bloodgroup"],
                  gender:row["gender"],
                  maritalStatus:row["maritalStatus"],
                  gaurdian: fathername.isEmpty? row["spouseName"]??"":fathername,
                  gaurdianmobile:fatherMobile.isEmpty?row["spouseName"]??"":fatherMobile,
                  // fatherName:row["fatherName"]??"",
                  // fatherMobile:row["fatherMobile"]??"",
                  // spouseName:row["spouseName"]??"",
                  // spouseMobile:row["spouseMobile"]??"",
                  education:row["education"],
                  doj:row["doj"],
                  end:row["endingDate"],
                  deptName:row["deptName"],
                  empPosition:row["empPosition"],
                  salary:row["salaryType"],
                  shift:row["shift"],
                  daySalary:row["salary"],
                  acNumber:row["acNumber"],
                  acHoldername:row["acHoldername"],
                  bank:row["bank"],
                  branch:row["branch"],
                  ifsc:row["ifsc"],
                  pan:row["pan"],
                  aadhar:row["aadhar"],
                )
                ));
              },icon: Icon(Icons.print,),
              color: Colors.blue.shade600,
            ),

          ],),

        )),
        /* DataCell(Center(

          Row(children:[]),
            child: IconButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeEdiT(
              empPhoto:row["empPhoto"],
              empID:row["empID"],
              empName:row["empName"],
              empAddress :row["empAddress"],
              empMobile:row["empMobile"],
              dob:row["dob"],
              age:row["age"],
              bloodgroup:row["bloodgroup"],
              gender:row["gender"],
              maritalStatus:row["maritalStatus"],
              fatherName:row["fatherName"]??"",
              fatherMobile:row["fatherMobile"]??"",
              spouseName:row["spouseName"]??"",
              spouseMobile:row["spouseMobile"]??"",
              education:row["education"],
              doj:row["doj"],
              end:row["endingDate"],
              deptName:row["deptName"],
              empPosition:row["empPosition"],
              salary:row["salary"],
              shift:row["shift"],
              acNumber:row["acNumber"],
              acHoldername:row["acHoldername"],
              bank:row["bank"],
              branch:row["branch"],
              ifsc:row["ifsc"],
              pan:row["pan"],
              aadhar:row["aadhar"],
             )
            ));
          },icon: Icon(Icons.edit_note,)
        ),
           IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeEdiT(
                  empPhoto:row["empPhoto"],
                  empID:row["empID"],
                  empName:row["empName"],
                  empAddress :row["empAddress"],
                  empMobile:row["empMobile"],
                  dob:row["dob"],
                  age:row["age"],
                  bloodgroup:row["bloodgroup"],
                  gender:row["gender"],
                  maritalStatus:row["maritalStatus"],
                  fatherName:row["fatherName"]??"",
                  fatherMobile:row["fatherMobile"]??"",
                  spouseName:row["spouseName"]??"",
                  spouseMobile:row["spouseMobile"]??"",
                  education:row["education"],
                  doj:row["doj"],
                  end:row["endingDate"],
                  deptName:row["deptName"],
                  empPosition:row["empPosition"],
                  salary:row["salary"],
                  shift:row["shift"],
                  acNumber:row["acNumber"],
                  acHoldername:row["acHoldername"],
                  bank:row["bank"],
                  branch:row["branch"],
                  ifsc:row["ifsc"],
                  pan:row["pan"],
                  aadhar:row["aadhar"],
                )
                ));
              },icon: Icon(Icons.edit_note,)
          ),
        )),*/
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

