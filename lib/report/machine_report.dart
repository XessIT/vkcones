
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;


import '../home.dart';
import 'Machine_view.dart';
import 'machine_overall_pdf.dart';



class MachineReport extends StatefulWidget {
  const MachineReport({Key? key}) : super(key: key);
  @override
  State<MachineReport> createState() => _MachineReportState();
}
class _MachineReportState extends State<MachineReport> {

  /* DateTime selectedDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  TextEditingController searchController = TextEditingController();
  String? selectedCustomer="";


  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/machine_report/');
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
          String id = item['machineName']?.toString()?.toLowerCase() ?? '';
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
          String id = item['machineName']?.toString()?.toLowerCase() ?? '';
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
    fetchData().then((_) {
      // Initialize 'filteredData' with all data
      setState(() {
        filteredData = List.from(data);
      });
    });

    _searchFocus.requestFocus();
  }
  final FocusNode _searchFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 375.0; // Adjust this value based on your design
    double defaultScreenHeight = 667.0; // Adjust this value based on your design

    // Get the actual screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate scale factors
    double widthScaleFactor = screenWidth / defaultScreenWidth;
    double heightScaleFactor = screenHeight / defaultScreenHeight;

    // Use these factors to scale your UI components
    double scaledWidth = screenWidth * widthScaleFactor;
    double scaledHeight = screenHeight * heightScaleFactor;
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

    var formattedToDate = DateFormat('dd-MM-yyyy').format(selectedToDate);
    searchController.addListener(() {
      filterData(searchController.text);
    });
    if (data.isEmpty) {
      return const CircularProgressIndicator(); // Show a loading indicator while data is fetched.
    }
*/

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
  DateTime? fromDate;
  DateTime? toDate;
  bool isDateRangeValid = true;
  final ScrollController _scrollController = ScrollController();



  //get isDateRangeValid => null;

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
      searchController.addListener(() {
        filterData(searchController.text);
      });
      _searchFocus.requestFocus();
      filteredData = List<Map<String, dynamic>>.from(data);
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
      final url = Uri.parse('http://localhost:3309/machine_report/');
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
    return
      searchController.text.isNotEmpty;
  }
  void filterData(String searchText) {
    print("Search Text: $searchText");
    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all data without filtering by supplier name
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        filteredData = data.where((item) {
          String machineName = item['machineName']?.toString()?.toLowerCase() ?? '';
          String machineModel= item['machineModel']?.toString()?.toLowerCase() ?? ''; // Add this line
          String machineSupName = item['machineSupName']?.toString()?.toLowerCase() ?? ''; // Add this line
          String machineType = item['machineType']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();
          return machineName.contains(searchTextLowerCase) ||
              machineModel.contains(searchTextLowerCase) ||
              machineSupName.contains(searchTextLowerCase) ||
              machineType.contains(searchTextLowerCase);


        }).toList();
      }
      // Sort filteredData in descending order based on the "date" field



    });
    print("Filtered Data Length: ${filteredData.length}");
  }

  void applyDateFilter() {
    setState(() {

      if (searchController.text.isNotEmpty) {
        String searchTextLowerCase = searchController.text.toLowerCase();
        filteredData = filteredData.where((item) {
          String machineName = item['machineName']?.toString()?.toLowerCase() ?? '';
          String machineModel= item['machineModel']?.toString()?.toLowerCase() ?? ''; // Add this line
          String machineSupName = item['machineSupName']?.toString()?.toLowerCase() ?? ''; // Add this line
          String machineType = item['machineType']?.toString()?.toLowerCase() ?? '';


          return machineName.contains(searchTextLowerCase) ||
              machineModel.contains(searchTextLowerCase) ||
              machineSupName.contains(searchTextLowerCase) ||
              machineType.contains(searchTextLowerCase);

        }).toList();
      }

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
    return Builder(
      builder: (context) =>
          MyScaffold(
            route: "machine_report",
            body: SingleChildScrollView(
              child: Form(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height:10,),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          //  width: screenWidth * 0.8,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Wrap(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Icon(
                                        Icons.edit, // Replace with the icon you want to use
                                        // Replace with the desired icon color
                                      ),
                                      const Text("  Machine Report", style: TextStyle(
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
                                    SizedBox(width:10,),
                                    SizedBox(
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
                                          List<String> machineNamesuggestions = data
                                              .where((item) =>
                                              (item['machineName']?.toString()?.toLowerCase() ?? '')
                                                  .startsWith(pattern.toLowerCase()))
                                              .map((item) => item['machineName'].toString())
                                              .toSet() // Remove duplicates using a Set
                                              .toList();
                                          List<String> machineTypesuggestions = data
                                              .where((item) =>
                                              (item['machineType']?.toString()?.toLowerCase() ?? '')
                                                  .startsWith(pattern.toLowerCase()))
                                              .map((item) => item['machineType'].toString())
                                              .toSet() // Remove duplicates using a Set
                                              .toList();
                                          List<String> machineSupNamesuggestions = data
                                              .where((item) =>
                                              (item['machineSupName']?.toString()?.toLowerCase() ?? '')
                                                  .startsWith(pattern.toLowerCase()))
                                              .map((item) => item['machineSupName'].toString())
                                              .toSet() // Remove duplicates using a Set
                                              .toList();
                                          List<String> machineModelsuggestions = data
                                              .where((item) =>
                                              (item['machineModel']?.toString()?.toLowerCase() ?? '')
                                                  .startsWith(pattern.toLowerCase()))
                                              .map((item) => item['machineModel'].toString())
                                              .toSet() // Remove duplicates using a Set
                                              .toList();
                                          List<String> suggestions = [
                                            ...machineNamesuggestions,
                                            ...machineTypesuggestions,
                                            ...machineSupNamesuggestions,
                                            ...machineModelsuggestions
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
                                            selectedSupplier = suggestion;
                                            searchController.text = suggestion;
                                          });
                                          print('Selected Customer: $selectedSupplier');
                                        },
                                      ),
                                    ),
                                    SizedBox(width:40,),
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
                                            errorMessage = "* Select a FromDate and Todate";
                                          });
                                        }
                                      },
                                      child: const Text("Generate", style: TextStyle(color: Colors.white)),

                                    ),


                                    IconButton(
                                      icon: Icon(Icons.refresh),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>MachineReport()));
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

                      //  SizedBox(height:,),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
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
                                            filteredData.isEmpty? Text("No Data Available",style: (TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),):
                                            Scrollbar(
                                              thumbVisibility: true,
                                              controller: _scrollController,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                controller: _scrollController,
                                                child: SizedBox(
                                                  width: 1200,
                                                  child: PaginatedDataTable(
                                                    columnSpacing:60.0,
                                                    //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                    rowsPerPage:10,
                                                    columns:   const [
                                                      DataColumn(label: Center(child: Text("       S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                                      DataColumn(label: Center(child: Padding(
                                                        padding: EdgeInsets.only(left:30),
                                                        child: Text("  Date",style: TextStyle(fontWeight: FontWeight.bold),),
                                                      ))),
                                                      DataColumn(label: Center(child: Padding(
                                                        padding: EdgeInsets.only(left:40),
                                                        child: Text("Machine Model",style: TextStyle(fontWeight: FontWeight.bold),),
                                                      ))),
                                                      //  DataColumn(label: Center(child: Text("Customer Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                                      DataColumn(label: Center(child: Padding(
                                                        padding: EdgeInsets.only(left:30),
                                                        child: Text("Machine Name",style: TextStyle(fontWeight: FontWeight.bold),),
                                                      ))),
                                                      DataColumn(label: Center(child: Padding(
                                                        padding: EdgeInsets.only(left:20),
                                                        child: Text("Machine Type",style: TextStyle(fontWeight: FontWeight.bold),),
                                                      ))),
                                                      DataColumn(label: Center(child: Text("Machine Supplier Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                              
                                                      // DataColumn(label: Center(child: Text("Date of purchase",style: TextStyle(fontWeight: FontWeight.bold),))),
                                                      // DataColumn(label: Center(child: Text("Warranty Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                                      //DataColumn(label: Center(child: Text("     Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                                                    ],
                                                    source: _YourDataTableSource(filteredData,context),                                          ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //if(generatedButton==true)
                                    filteredData.isEmpty?Text(""):
                                    MaterialButton(
                                      color: Colors.green.shade600,
                                      onPressed: (){

                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>MachineReportPDF(
                                          // quotNo: filteredData[0]['quotNo'],
                                          // custAddress: filteredData[0]['custAddress'],
                                          // customerData: filteredData, // Provide the actual custName value
                                          // date: filteredData[0]['date'], customerName: filteredData[0]['custName'], customerMobile: filteredData[0]['custMobile'], // Provide the actual custMobile value
                                          customerData : filteredData,
                                        )
                                        ));
                                      },child: const Text("PRINT",style: TextStyle(color: Colors.white),),),
                                    SizedBox(width: 10,),
                                    MaterialButton(
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
          child: Text(row["date"] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse("${row["date"]}")) : "",),
        )),
        DataCell(Center(child: Text("${row["machineModel"]}"))),
        DataCell(Center(child: Text("${row["machineName"]}"))),
        DataCell(Center(child: Text("${row["machineType"]}"))),
        DataCell(Center(child: Text("${row["machineSupName"]}"))),
        // DataCell(Center(
        //   child: Text(row["purchaseDate"] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse("${row["purchaseDate"]}")) : "",),
        // )),
        // DataCell(Center(
        //   child: Text(row["warrantyDate"] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse("${row["warrantyDate"]}")) : "",),
        // )),
        /*   DataCell(Center(child: Row(
          children: [
            IconButton(icon: Icon(Icons.remove_red_eye_outlined,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>QuotationItem(
                quotNo: row["quotNo"],
                date:row["date"],
                customerName:row["custName"],
                customerMobile:row["custMobile"],
                customerAddress:row["custAddress"],
                custCode:row["custCode"],
              )));
            },),
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


