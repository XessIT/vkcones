import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:vinayaga_project/main.dart';
import 'package:vinayaga_project/master/shift_view.dart';
import 'package:vinayaga_project/sale/dc.dart';
import 'package:http/http.dart' as http;
import '../home.dart';
import 'package:intl/intl.dart';

import '../purchase/product_overall_report.dart';
class ShiftCreation extends StatefulWidget {
  const ShiftCreation({Key? key}) : super(key: key);

  @override
  State<ShiftCreation> createState() => _ShiftCreationState();
}

class _ShiftCreationState extends State<ShiftCreation> {
  final _formKey = GlobalKey<FormState>();

  DateTime date = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate2 = DateTime.now();
  DateTime toDate = DateTime.now();
  String? errorMessage="";
  String? shiftType;
  bool generatedButton = false;

  Map<String, String> shiftTimingsMap = {
    'General': '9:00AM - 6:00PM',
    'Morning': '8:00AM - 8:00PM',
    'Night': '8:00PM - 8:00AM',
  };


  void _resetForm() {
    _formKey.currentState!.reset();
  }
  void _cancelForm() {
    print('Form cancelled!');
  }
  Map<String, dynamic> dataToInsert = {};
  List<String> supplierSuggestions = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController empName=TextEditingController();
  TextEditingController empID=TextEditingController();
  TextEditingController shiftTiming=TextEditingController();
  TextEditingController controller2= TextEditingController();
  TextEditingController controller= TextEditingController();
  final ScrollController _scrollController = ScrollController();



  String selectedSupplier = "";
  bool isDateRangeValid=true;
  DateTime? fromdate;


  Map<String, dynamic> dataToInsertShift = {};
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> data4 = [];

  Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/fetch_shift'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("6666666666666666666666666666666666666666666:$data");
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  Future<void> insertDataShift(Map<String, dynamic> dataToInsertShift) async {
    const apiUrl = 'http://localhost:3309/shift_data'; // Replace with your server address
    try {
      List<Map<String, dynamic>> unitEntries = await fetchUnitEntries();
      bool isDuplicate = unitEntries.any((entry) {
        String entryFromDate = entry['fromDate'];
        String entryToDate = entry['toDate'];

        DateTime existingFromDate = DateTime.parse(entryFromDate);
        DateTime existingToDate = DateTime.parse(entryToDate);

        DateTime newFromDate = DateTime.parse(dataToInsertShift['fromDate']);
        DateTime newToDate = DateTime.parse(dataToInsertShift['toDate']);

        // Check for date range overlap
        bool overlap = !(newToDate.isBefore(existingFromDate) || newFromDate.isAfter(existingToDate));

        // Check for emp_code match
        bool empCodeMatch = entry['emp_code'] == dataToInsertShift['emp_code'];

        return overlap && empCodeMatch;
      });

      if (isDuplicate) {
        // Display your duplicate entry dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Shift"),
              content: Text("This Empolyee already exists within the specified date"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftCreation()));
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        print('Duplicate entry, not inserted');
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertSup': dataToInsertShift}),
      );

      if (response.statusCode == 200) {
        print('Data inserted successfully');
      } else {
        print('Failed to insert data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<String> filteredSuggestions(List<Map<String, dynamic>> data, Map<String, dynamic> dataToInsertShift) {
    DateTime newFromDate = DateTime.parse(dataToInsertShift['fromDate']);
    DateTime newToDate = DateTime.parse(dataToInsertShift['toDate']);

    return data
        .where((item) {
      DateTime existingFromDate = DateTime.parse(item['fromDate']);
      DateTime existingToDate = DateTime.parse(item['toDate']);
      bool overlap = !(newToDate.isBefore(existingFromDate) || newFromDate.isAfter(existingToDate));
      bool empCodeMatch = item['emp_code'] == dataToInsertShift['emp_code'];
      return !overlap || !empCodeMatch;
    })
        .map((item) => item['first_name'].toString())
        .toSet()
        .toList();
  }

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

  Future<void> fetchShift() async {
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
  void filterShift(String searchText) {
    print("Search Text: $searchText");
    setState(() {
      if (searchText.isEmpty) {
        // If the search text is empty, show all data without filtering by supplier name
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        filteredData = data.where((item) {
          String first_name = item['first_name']?.toString()?.toLowerCase() ?? '';
          String emp_code= item['emp_code']?.toString()?.toLowerCase() ?? '';
          String shiftType = item['shiftType']?.toString()?.toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();

          return first_name.contains(searchTextLowerCase) ||
              emp_code.contains(searchTextLowerCase) ||
              shiftType.contains(searchTextLowerCase);
        }).toList();
      }
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


  bool ordernumberexiest(String name) {
    return data.any((item) => item['emp_code'].toString().toLowerCase() == name.toLowerCase());
  }


  String selectedCustomer = '';
  final FocusNode empNameFocusNode = FocusNode();

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getemployeename'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          data4 = jsonData.cast<Map<String, dynamic>>();
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
  List<Map<String, dynamic>> filteredData4 = [];
  void filterData(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData4 = data4;
        empID.clear();
        filteredData4 = data4;
      } else {
        filteredData4 = data4.where((item) {
          String id = item['first_name']?.toString()?.toLowerCase() ?? '';
          return id == searchText.toLowerCase();
        }).toList();
        if (filteredData4.isNotEmpty) {
          Map<String, dynamic> order = filteredData4.first;
          empID.text = order['emp_code']?.toString() ?? '';
        } else {
          empID.clear();
        }
      }
    });
  }


  String empIDValue = '';
  String?callUnit;









  List<String> existingEmpIDs = []; // Replace this with your actual data source



  List<Map<String, dynamic>> filteredData3 = [];
  List<Map<String, dynamic>> data3 = [];


  Future<void> fetchData3() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/checkorderNo_forcustomerorder'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        jsonData.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['date']);
          final DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA);
        });
        setState(() {
          data3 = jsonData.cast<Map<String, dynamic>>();
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
  void filterData3(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredData3 = data3.where((item) {
          final custName = item[''].toString().toLowerCase();
          return custName.contains(query.toLowerCase());
        }).toList();
      } else {
        filteredData3 = List.from(data3);
      }
    });
  }


  @override
  void initState() {
    super.initState();
    fetchData();
    empNameFocusNode.requestFocus();
    fetchShift();
    fetchData3();
    date = DateTime.now();
    fromDate = DateTime.now();
    toDate2 = fromDate.add(Duration(days: 6));
    toDate = fromDate.add(Duration(days: 6));
    _dNnDate = _getNextMonday();
    _generalDate2 = _getNextSaturday();
    controller2.text = DateFormat('dd-MM-yyyy').format(_generalDate2);
    controller.text = DateFormat('dd-MM-yyyy').format(_dNnDate);
    toDate2 = _generalDate2.add(Duration(days: 6));
    toDate = _dNnDate.add(Duration(days: 6));
    _searchFocus.requestFocus();
  }

  late DateTime _dNnDate;
  late DateTime _generalDate2;

  DateTime _getNextMonday() {
    DateTime now = DateTime.now();
    int dayOfWeek = now.weekday;
    int difference = (dayOfWeek <= 1) ? (1 - dayOfWeek) : (8 - dayOfWeek);
    return now.add(Duration(days: difference));
  }

  DateTime _getNextSaturday() {
    DateTime now = DateTime.now();
    int daysUntilSaturday = DateTime.saturday - now.weekday;
    if (daysUntilSaturday <= 0) {
      daysUntilSaturday += 7; // If today is Saturday, move to the next Saturday
    }
    return now.add(Duration(days: daysUntilSaturday));
  }


  final FocusNode _searchFocus = FocusNode();

  void validateDropdown() {
    setState(() {
      dropdownValid1 = shiftType != "Shift Type";
    });
  }

  bool dropdownValid1 = true;
  String shiftTime="Shift Timing";


  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  final TextEditingController dob = TextEditingController();

  DateTime firstSelectableYear = DateTime.now();

  DateTime _calculateInitialDate() {
    DateTime currentDate = DateTime.now();

    // If the current day is not Monday (weekday 1), find the next Monday
    while (currentDate.weekday != 1) {
      currentDate = currentDate.add(Duration(days: 1));
    }

    return currentDate;
  }

  bool isGeneralShift = true;

  @override
  Widget build(BuildContext context) {
    DateTime Date = DateTime.now();
    final formattedDate = DateFormat("dd-MM-yyyy").format(Date);
    searchController.addListener(() {
      filterShift(searchController.text);
    });
    empName.addListener(() {
      filterData(empName.text);
    });
    return MyScaffold(
        route: "shift_entry",backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        width: double.infinity, // Set the width to full page width
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey), // Add a border for the box
                          borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                        ),
                        child:Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.edit),
                                        const Text("  Shift Creation", style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        ),),
                                        IconButton(
                                          icon: Icon(Icons.refresh),
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> ShiftCreation()));
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
                                    SizedBox(height: 20,),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ]
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        width: double.infinity, // Set the width to full page width
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.grey), // Add a border for the box
                          borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Shift Details",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  errorMessage ?? '',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            SizedBox(height: 8,),
                            Padding(
                              padding: const EdgeInsets.only(left: 130),
                              child: Wrap(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: SizedBox(
                                        width: 220,height:34,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButtonFormField<String>(
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            value: shiftType,
                                            hint:Text("Shift Type",style:TextStyle(fontSize: 13),),
                                            items: <String>['General','Morning','Night',]
                                                .map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(fontSize: 13),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                shiftType = newValue!;
                                                shiftTiming.text = shiftTimingsMap[shiftType] ?? '';
                                                isGeneralShift = shiftType == 'General';
                                              });
                                              setState(() {
                                                errorMessage = null;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 70),

                                    Visibility(
                                      visible: isGeneralShift,
                                      child: SizedBox(
                                        width: 220,
                                        height: 70,
                                        child: TextFormField(
                                          readOnly: true,
                                          style: TextStyle(fontSize: 13),
                                          controller: controller2,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: "From Date",
                                            border: InputBorder.none,
                                          ),
                                          onTap: () async {
                                            DateTime nextSaturday = _getNextSaturday();
                                            DateTime? pickdate = await showDatePicker(
                                              context: context,
                                              initialDate: _generalDate2 ?? nextSaturday,
                                              firstDate: nextSaturday,
                                              lastDate: DateTime(2100),
                                              selectableDayPredicate: (DateTime date) {
                                                return date.weekday == 6;
                                              },
                                            );
                                            if (pickdate != null) {
                                              setState(() {
                                                _generalDate2 = pickdate;
                                                controller2.text = DateFormat('dd-MM-yyyy').format(pickdate);
                                                // Calculate the dynamic "To Date" based on the selected "From Date"
                                                toDate2 = pickdate.add(Duration(days: 6));
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),

                                    Visibility(
                                      visible: !isGeneralShift,
                                      child: SizedBox(
                                        width: 220,
                                        height: 70,
                                        child: TextFormField(
                                          readOnly: true,
                                          style: TextStyle(fontSize: 13),
                                          controller: controller,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: "Form Date",
                                            border: InputBorder.none,
                                          ),
                                          onTap: () async {
                                            DateTime nextMonday = _getNextMonday();
                                            DateTime? pickdate = await showDatePicker(
                                              context: context,
                                              initialDate: _dNnDate ?? nextMonday,
                                              firstDate: nextMonday,
                                              lastDate: DateTime(2100),
                                              selectableDayPredicate: (DateTime date) {
                                                return date.weekday == 1; // Allow only Mondays to be selected
                                              },
                                            );
                                            if (pickdate != null) {
                                              setState(() {
                                                _dNnDate = pickdate;
                                                controller.text = DateFormat('dd-MM-yyyy').format(pickdate);
                                                toDate = pickdate.add(Duration(days: 6));
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 70),
                                    Visibility(
                                      visible: isGeneralShift,
                                      child: SizedBox(
                                        width: 220,
                                        height: 70,
                                        child: TextFormField(
                                          style: TextStyle(fontSize: 13),
                                          readOnly: true,
                                          controller: TextEditingController(text: DateFormat('dd-MM-yyyy').format(toDate2)),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelText: "To Date",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: !isGeneralShift,
                                      child: SizedBox(
                                        width: 220,
                                        height: 70,
                                        child: TextFormField(
                                          style: TextStyle(fontSize: 13),
                                          readOnly: true,
                                          controller: TextEditingController(text: DateFormat('dd-MM-yyyy').format(toDate)),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelText: "To Date",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 70,),
                                  ]
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 130),
                              child:  Wrap(
                                children: [
                                  SizedBox(
                                    width: 220,
                                    height:50,
                                    child: TypeAheadFormField<String>(
                                      textFieldConfiguration: TextFieldConfiguration(
                                        controller: empName,
                                        onChanged: (value) async {
                                          //   await checkDuplicateEmpID();
                                          String capitalizedValue = capitalizeFirstLetter(value);
                                          empName.value = empName.value.copyWith(
                                            text: capitalizedValue,
                                            selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                          );
                                          setState(() {
                                            errorMessage = null; // Reset error message when user types
                                          });
                                        },
                                        style: const TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          labelText: "Employee Name",
                                          labelStyle: TextStyle(fontSize: 13,color: Colors.black),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      suggestionsCallback: (pattern) async {
                                        if (pattern.isEmpty) {
                                          List<String> allSuggestions = data4
                                              .map((item) => item['first_name'].toString())
                                              .toSet()
                                              .toList();
                                          allSuggestions.sort(); // Sort suggestions alphabetically
                                          return allSuggestions;
                                        }
                                        // Your existing logic for filtering based on user input
                                        List<String> suggestions = data4
                                            .where((item) =>
                                        (item['first_name']?.toString()?.toLowerCase() ?? '').contains(pattern.toLowerCase()) ||
                                            (item['emp_code']?.toString()?.toLowerCase() ?? '').contains(pattern.toLowerCase()))
                                            .map((item) => item['first_name'].toString())
                                            .toSet()
                                            .toList();
                                        suggestions.sort(); // Sort suggestions alphabetically
                                        return suggestions;
                                      },

                                      itemBuilder: (context, suggestion) {
                                        Map<String, dynamic> customerData = data4.firstWhere(
                                              (item) => item['first_name'].toString() == suggestion,
                                          orElse: () => Map<String, dynamic>(),
                                        );
                                        return ListTile(
                                          title: Text('${customerData['first_name']} (${customerData['emp_code']})'),
                                        );
                                      },
                                      onSuggestionSelected: (suggestion) {
                                        Map<String, dynamic> customerData = data4.firstWhere(
                                              (item) => item['first_name'].toString() == suggestion,
                                          orElse: () => Map<String, dynamic>(),
                                        );
                                        setState(() {
                                          selectedCustomer = suggestion;
                                          empName.text = suggestion;
                                        });
                                        print('Selected Customer: $selectedCustomer, Customer Code: ${customerData['emp_code']}');
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 70,),
                                  SizedBox(
                                    width: 220,height: 70,
                                    child: TextFormField(
                                      readOnly: true,
                                      onChanged: (value) {
                                        setState(() {
                                          errorMessage=null;
                                        });
                                      },
                                      controller: empID,
                                      style: TextStyle(fontSize: 13),
                                      inputFormatters: [
                                        UpperCaseTextFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "Employee ID",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 70,),
                                  SizedBox(
                                    width: 220,
                                    child: TextFormField(
                                      controller: shiftTiming,
                                      style: TextStyle(
                                          fontSize: 13),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        LengthLimitingTextInputFormatter(2),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        labelText: "Shift Timing",
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      Wrap(
                        children: [
                          MaterialButton(
                            color: Colors.green.shade600,
                            onPressed: () async {
                              if(_formKey.currentState!.validate()){
                                if (empName.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter Employee Name';
                                  });
                                }else if (empID.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter Employee ID';
                                  });
                                }
                                else if (shiftType==null) {
                                  setState(() {
                                    errorMessage = '* Select a Shift Type';
                                  });
                                  return;
                                }
                                else if (errorMessage == null){
                                  validateDropdown();
                                  Map<String, dynamic> dataToInsertShift = {
                                    'date':date.toIso8601String(),
                                    'first_name': empName.text,
                                    'emp_code': empID.text, // Replace with your date and time
                                    'shiftType':shiftType.toString(),
                                    'shiftTime': shiftTiming.text,
                                    'fromDate':isGeneralShift==true? _generalDate2.toLocal().toString().split(' ')[0]:_dNnDate.toLocal().toString().split(' ')[0],
                                    'toDate':isGeneralShift==true? toDate2.toLocal().toString().split(' ')[0]:toDate.toLocal().toString().split(' ')[0],
                                    //"checkDuplicateDate":isGeneralShift==true? _generalDate2.toLocal().toString().split(' ')[0]:_dNnDate.toLocal().toString().split(' ')[0],

                                  };
                                  insertDataShift(dataToInsertShift);
                                  try{
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Shift"),
                                          content: Text(" Saved successfully."),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftCreation()));
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                  catch (e) {
                                    print('Error inserting data: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Failed to save data. Please try again."),
                                      ),
                                    );
                                  }
                                }
                              }

                              print("Successfull");
                            },
                            child: Text("SUBMIT",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 10,),
                          MaterialButton(
                            color: Colors.blue.shade600,
                            onPressed: (){
                              /*  Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>const Home()));*/// Close the alert box
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text('Do you want to Reset?'),
                                    actions: <Widget>[

                                      TextButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) =>const ShiftCreation()));// Close the alert box
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
                            child:Text("RESET",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 10,),
                          MaterialButton(
                            color: Colors.red.shade600,
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
                            child: Text("CANCEL",style: TextStyle(color: Colors.white),),)
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
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
                                SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                                  //  filterData(selectedSupplier);
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 20,),
                                Scrollbar(
                                  thumbVisibility: true,
                                  controller: _scrollController,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _scrollController,
                                    child: SizedBox(
                                      width:1300,
                                      child: PaginatedDataTable(
                                        columnSpacing:87,
                                        //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        rowsPerPage:25,
                                        columns:   const [
                                          DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Employee ID",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Employee Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("From Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("To Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Shift Type",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Alter Employee ",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          //DataColumn(label: Center(child: Text("Shift Time",style: TextStyle(fontWeight: FontWeight.bold),))),
                                          DataColumn(label: Center(child: Text("Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                                        ],
                                        source: _YourDataTableSource(filteredData,context,generatedButton,onDelete),
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
                  ]),
            ),
          ),
        ) );
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
        DataCell(
          Center(
            child: Row(
              children: [
                if (row["alterEmp"] == null || row["alterEmp"].isEmpty)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftView(
                        id: row["id"],
                        empID: row["emp_code"],
                        empName: row["first_name"],
                        fromDate: row["fromDate"],
                        toDate: row["toDate"],
                        shiftType: row["shiftType"],
                        shiftTime: row["shiftTime"],
                      )));
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDeleteConfirmationDialog(context, id);
                  },
                ),
              ],
            ),
          ),
        ),

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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const ShiftCreation()));
                onDelete(id); // Call the onDelete function
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


