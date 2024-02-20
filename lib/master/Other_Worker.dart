import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart'as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../home.dart';
import '../main.dart';
import 'Other_Worker_View.dart';




/// Other Worker dart

class Other_worker extends StatefulWidget {
  const Other_worker({Key? key}) : super(key: key);

  @override
  State<Other_worker> createState() => _Other_workerState();
}
class _Other_workerState extends State<Other_worker> {
  final _formKey = GlobalKey<FormState>();
  DateTime date = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  late TextEditingController controller;

  late DateTime eod;// Declare as late since it will be initialized in the constructor


  // Constructor to initialize eod
  _Other_workerState() {
    eod = DateTime.now();
    eod = DateTime(eod.year, eod.month, eod.day);
  }


  final FocusNode op1FocusNode = FocusNode();

  Map<String, dynamic> dataToInsert = {};

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/other_working_entry_report'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(":$data");
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }



  String machname="Machine Name";
  String opOneName="Shift Type";



  ///fetch details auto increment end
  bool enable = false;
  bool disable=true;

  ///autoincrement setup

  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['others_working_ID'];
  }
  String ProdCode = '';
  // String? prodCode;
  List<Map<String, dynamic>> ponumdata = [];
  String? PONO;
  List<Map<String, dynamic>> codedata = [];
  String generateId() {
    if (PONO != null) {
      String ID = PONO!.substring(2);
      int idInt = int.parse(ID) + 1;
      String id = 'OW${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ponumfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/other_working_entry_code'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for(var item in jsonData){
          PONO = getNameFromJsonData(item);
          print('prodCode: $PONO');
        }
        setState(() {
          ponumdata = jsonData.cast<Map<String, dynamic>>();
          ProdCode = generateId(); // Call generateId here

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

  ///autoincrement ending

  ///backend fetch process duplicate entry
  Future<List<Map<String, dynamic>>> fetchWinding() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/other_entry_duplicatecheck'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(":$data");
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  List<Map<String, dynamic>> windingData = [];
  bool isDuplicateEntry(DateTime selectedDate,
      String selectedShift,) {

    return windingData.any((entry) {
      DateTime entryDate = DateTime.parse(entry['shiftdate']);
      String entryShift = entry['shiftType'];

      return selectedDate.isAtSameMomentAs(entryDate) &&

          selectedShift == entryShift ;

    });
  }
  void onButtonPressed() {
    DateTime selectedDate = eod;

    String selectedShift = dropdownvalue;
    String selectedOperator = op1.text;

    // Check for duplicate entry
    if (isDuplicateEntry(selectedDate,
      selectedShift,)) {
      print("dupdate------------------------------:$selectedDate");
      print("selectedShift:$selectedShift");
      print("selectedOperator:$selectedOperator");

      setState(() {
        errorMessage = "This entry is already stored.";
      });
    }
    else {
      print("errodate------------------------------:$selectedDate");
      print("selectedShift:$selectedShift");
      print("selectedOperator:$selectedOperator");
      if (ProdCode.isEmpty) {
        ProdCode = 'OW001';
      }
      dataToInsert = {

        'createdate':date.toString(),
        'others_working_ID':ProdCode,
        'shiftdate':eod.toString(),
        "opOneName": op1.text,
        "emp_code1":emp_code1.text,
        "shiftType": dropdownvalue.toString(),
        "fromDate":fromDate.toString(),
        "toDate":toDate.toString(),
        "workingType":wrk_type.text,

      };
      insertData(dataToInsert);
    }
  }

  List<Map<String, dynamic>> shiftData = [];

  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    const String apiUrl = 'http://localhost:3309/other_working_entry/'; // Replace with your server details

    try {
      String ShiftType = dataToInsert['shiftType'];
      String OperatorName1 = dataToInsert['opOneName'];
      String FromDate = dataToInsert['fromDate'];
      String ToDate = dataToInsert['toDate'];
      String shiftdate =dataToInsert['shiftdate'];


      List<Map<String, dynamic>> unitEntries = await fetchUnitEntries();
      bool isDuplicate = unitEntries.any((entry) =>

      entry['shiftType'] == ShiftType &&
          entry['opOneName'] == OperatorName1 &&
          entry['fromDate'] == FromDate &&
          entry['toDate'] == ToDate &&
          entry['shiftdate'] ==shiftdate


      );
      if (isDuplicate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Production"),
              content: Text("This item already exists on this date. do you want continue...??"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                    //  updateqtyinProduction(machineName, ShiftType, OperatorName1,optwoName,assOne,asstwo,assthree ,int.parse(qty.text),formattedDate);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Other_worker()));
                  },
                  child: Text("yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the alert dialog
                  },
                  child: Text("No"),
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
        body: jsonEncode({'dataToInsert': dataToInsert}),
      );

      if (response.statusCode == 200) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Other_Working_Entry"),
              content: Text("saved successfully."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Other_worker()));                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to insert data');
        throw Exception('Failed to insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }


  /// backend fetch proceess // duplicate check and insert data End .



  TextEditingController op1 =TextEditingController();
  TextEditingController emp_code1=TextEditingController();
  TextEditingController wrk_type=TextEditingController();

  String? errorMessage;
  String dropdownvalue = "Shift Type";
  String validname1="";
  List<String> selectedNames = []; /// for suggestion fillter


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

  List<String> machiNameCall =[];

  String?callUnit;
  List<Map<String, dynamic>> persondata = [];

  Future<void> filterFromtodateData(
      String fromDate, String toDate, String shiftType) async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_fromtodate2?fromDate=$fromDate&toDate=$toDate&shiftType=$shiftType');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List<dynamic>) {
          setState(() {
            persondata = List<Map<String, dynamic>>.from(
                responseData.cast<Map<String, dynamic>>());
          });

          print('Person Data:');
          for (var data in persondata) {
            print('Name: ${data['first_name']}, Emp code : ${data['emp_code']}');
          }
        } else {
          print('Error: Response data is not a List');
          print('Response Body: $responseData');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void filterData(String searchText) {
    print("Search Text: $searchText");
    setState(() {
      if (searchText.isEmpty) {
        filteredData = List<Map<String, dynamic>>.from(data);
      } else {
        filteredData = data.where((item) {
          String supName = item['first_name']?.toString().toLowerCase() ?? '';
          String searchTextLowerCase = searchText.toLowerCase();

          return supName.contains(searchTextLowerCase);
        }).toList();
      }
    });
    print("Filtered Data Length: ${filteredData.length}");
  }

  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  String? opName1="";
  String? empID="";
  String? opName2="";
  String? empID2="";
  String? assName1="";
  String? empID3="";
  String? assName2="";
  String? empID4="";
  String? assName3="";
  String? empID5="";
  String? selectedOperator2 = "";
  String? selectedOperator1 = "";
  String? selectedOperator3 = "";
  String? selectedOperator4 = "";
  String? selectedOperator5 = "";
  TextEditingController prodCode = TextEditingController();
  TextEditingController windingId = TextEditingController();
  String winding_ID = '';

  /// This is  for Report View In Same Page

  List<Map<String, dynamic>> filteredDataNew = [];
  List<Map<String, dynamic>> dataNew = [];
  Future<void> fetchWindingreport() async {
    try {
      final url = Uri.parse('http://localhost:3309/other_working_entry_report/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          dataNew = itemGroups.cast<Map<String, dynamic>>();
          filteredDataNew = List<Map<String, dynamic>>.from(dataNew);
          filteredDataNew.sort((a, b) {
            DateTime? dateA = DateTime.tryParse(a['shiftdate'] ?? '');
            DateTime? dateB = DateTime.tryParse(b['shiftdate'] ?? '');
            if (dateA == null || dateB == null) {
              return 0;
            }
            return dateB.compareTo(dateA);
          });
        });

        print('Data: $dataNew');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    date = DateTime.now();
    //fetchShiftData();
    fromDate = DateTime.now();
    toDate = fromDate;
    controller = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(fromDate),
    );
    fetchWinding().then((data) {
      setState(() {
        windingData = data;
      });
    });
    ponumfetch();
    fetchData();
    filteredData = List<Map<String, dynamic>>.from(data
    );
    filterFromtodateData(fromDate.toString(),toDate.toString(),dropdownvalue);
    fetchWindingreport();

  }
  @override
  Widget build(BuildContext context) {
    prodCode.text= generateId();
    return MyScaffold(
        route: 'Other',backgroundColor: Colors.white,

        body: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                  children: [
                    SizedBox(height: 20,),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.edit_note, size:30),
                                            const Padding(
                                              padding: EdgeInsets.only(right:0),
                                              child: Text("Other Workers Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),
                                            ),]
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 15),
                                        width: 100.0,
                                        child: Column(
                                          children: [
                                            Wrap(
                                              children: [
                                                TextFormField(
                                                  style: TextStyle(fontSize: 13),
                                                  readOnly: true,
                                                  onTap: () {
                                                    showDatePicker(
                                                      context: context,
                                                      initialDate: eod,
                                                      firstDate: DateTime.now(),
                                                      // Set the range of selectable dates
                                                      lastDate: DateTime(2100),
                                                    ).then((date) {
                                                      if (date != null) {
                                                        setState(() {
                                                          eod =
                                                              date;
                                                          dropdownvalue = "Shift Type";
                                                          op1.clear();

                                                          // Update the selected date
                                                        });
                                                      }
                                                    });

                                                  },

                                                  controller: TextEditingController(
                                                    text: DateFormat('dd-MM-yyyy').format(eod),
                                                  ),

                                                  // Set the initial value of the field to the selected date

                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,

                                                    labelText: "Shift Date",

                                                    border: OutlineInputBorder(

                                                      borderRadius: BorderRadius.circular(10),

                                                    ),

                                                  ),

                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20,),
                                            ///winding id textformfiled
                                          ],
                                        ),
                                      ),
                                    ]   ),
                              ]
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 0.0),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ///auto increment fetched data
                                    Container(
                                      height: 40,
                                      width: 150,
                                      child:  Text(ProdCode.isEmpty? "OW001":ProdCode,style: TextStyle(fontSize: 15,color: Colors.black),),
                                    ),
                                    Text(
                                      errorMessage ?? '',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30,),
                                Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    width: 200,
                                                    height: 70,

                                                    child: TextFormField(
                                                      style: TextStyle(fontSize: 13),
                                                      readOnly: true,
                                                      onTap: () async  {
                                                        DateTime currentDate = DateTime.now();
                                                        showDatePicker(
                                                          context: context,
                                                          initialDate: fromDate,
                                                          firstDate:currentDate,
                                                          lastDate: currentDate.add(Duration(days: 10)),

                                                        ).then((date) {
                                                          if (date != null) {
                                                            setState(() {
                                                              fromDate = date;
                                                              // toDate = fromDate.add(Duration(days: 5));
                                                              controller.text = DateFormat('dd-MM-yyyy').format(fromDate);
                                                              dropdownvalue = "Shift Type";

                                                            });
                                                          }
                                                        });
                                                      },

                                                      controller: controller,
                                                      decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        labelText: "From Date",
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    )
                                                ),   /// from date
                                                SizedBox(width: 50),
                                                SizedBox(
                                                  width: 200,
                                                  height: 70,
                                                  child: TextFormField(
                                                    style: TextStyle(fontSize: 13),
                                                    readOnly: true,
                                                    onTap: () {
                                                      DateTime currentDate = DateTime.now();
                                                      showDatePicker(
                                                        context: context,
                                                        //initialDate: toDate ?? fromDate.add(Duration(days: 6)),
                                                        initialDate: toDate,
                                                        firstDate:currentDate,
                                                        lastDate:  currentDate.add(Duration(days: 10)),
                                                      ).then((date) {
                                                        if (date != null) {
                                                          setState(() {
                                                            toDate = date;
                                                            dropdownvalue = "Shift Type";

                                                          });
                                                        }
                                                      });
                                                    },
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
                                                ),   ///winding TO Date
                                                SizedBox(width: 50),
                                                SizedBox(
                                                  width: 200, height:38 ,
                                                  child: Container(
                                                    // color: Colors.white,

                                                    padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(color: Colors.black),
                                                        borderRadius: BorderRadius.circular(5)

                                                    ),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButton<String>(
                                                        value: dropdownvalue,
                                                        hint: Text("Shift type"),
                                                        items: <String>['Shift Type','Morning',]
                                                            .map<DropdownMenuItem<String>>((String value) {
                                                          return DropdownMenuItem<String>(
                                                            // enabled: false,
                                                            value: value,
                                                            child: Text(
                                                              value,
                                                              style: TextStyle(fontSize: 12),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        // Step 5.
                                                        onChanged: (String? newValue) {
                                                          filterFromtodateData(fromDate.toString(),toDate.toString(),newValue!);
                                                          setState(() {
                                                            dropdownvalue = newValue!;
                                                            op1.clear();

                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),     /// shift Type
                                                SizedBox(width: 50),
/*
                                                SizedBox(
                                                  width: 200, height: 70,
                                                  child: TypeAheadFormField<String>(
                                                    textFieldConfiguration: TextFieldConfiguration(

                                                      controller: op1,
                                                      focusNode: op1FocusNode,
                                                      enabled: true,
                                                      onChanged: (query) {
                                                        setState(() {
                                                          errorMessage = null;
                                                        });

                                                        String capitalizedValue = capitalizeFirstLetter(query);
                                                        op1.value = op1.value.copyWith(
                                                          text: capitalizedValue,
                                                          selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                        );
                                                      },
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.deny(RegExp(r'\d')),
                                                      ],
                                                      style: const TextStyle(fontSize: 13),
                                                      decoration: InputDecoration(
                                                        fillColor: Colors.white,
                                                        filled: true,
                                                        labelText: "Employee",
                                                        labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                    suggestionsCallback: (pattern) async {
                                                      if (selectedNames.isNotEmpty) {
                                                        List<String> suggestions = persondata
                                                            .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                            .toSet()
                                                            .toList();

                                                        suggestions = suggestions
                                                            .where((suggestion) => !selectedNames.contains(suggestion))
                                                            .toList();

                                                        return suggestions;
                                                      }
                                                      List<String> suggestions = persondata
                                                          .where((item) =>
                                                      (item['first_name']?.toString()?.toLowerCase() ?? '')
                                                          .startsWith(pattern.toLowerCase()) &&
                                                          item['emp_code']?.toString()?.toLowerCase() != empID?.toLowerCase() &&
                                                          item['emp_code']?.toString()?.toLowerCase() != empID2?.toLowerCase())
                                                          .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                          .toSet()
                                                          .toList();

*/
/*
                                                      suggestions = suggestions.where((suggestion) =>
                                                      suggestion != op2.text &&
                                                          suggestion != ass1.text &&
                                                          suggestion != ass2.text &&
                                                          suggestion != ass3.text).toList();
*//*


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
                                                        emp_code1.text = selectedEmpID;
                                                        print(emp_code1.text);
                                                      });

                                                      selectedNames.add(suggestion);

                                                      //selectedOperator1 = suggestion;

                                                      bool isValidID = data.any((item) =>
                                                      '${item['emp_code']}'.toLowerCase() == selectedEmpID.toLowerCase());
                                                      validname1 = isValidID.toString();

                                                      if (selectedOperator2 != null && suggestion == selectedOperator2 && suggestion == selectedOperator3 && suggestion == selectedOperator4 && suggestion == selectedOperator5) {
                                                        setState(() {
                                                          errorMessage = "Already Assigned the ID in Operator ";
                                                        });
                                                      } else if (selectedEmpID == empID2) {
                                                        setState(() {
                                                          errorMessage = "Already Assigned the ID in Operator 2";
                                                        });
                                                      }
                                                       else {
                                                        setState(() {
                                                          opName1 = selectedEmpName;
                                                          empID = selectedEmpID;
                                                          op1.text = suggestion;
                                                        });

                                                        Future.delayed(Duration(milliseconds: 100), () {
                                                          setState(() {
                                                            op1FocusNode.unfocus();
                                                            op1FocusNode.canRequestFocus = false;
                                                          });
                                                        });
                                                      }

                                                      print('Selected Operator Name 1: $opName1, ID: $selectedEmpID');
                                                    },
                                                  ),
                                                ),
*/

                                              ],
                                            ),
                                            Wrap(
                                                children: [
                                                  SizedBox(
                                                    width: 200, height: 70,
                                                    child: TypeAheadFormField<String>(
                                                      textFieldConfiguration: TextFieldConfiguration(

                                                        controller: op1,
                                                        focusNode: op1FocusNode,
                                                        enabled: true,
                                                        onChanged: (query) {
                                                          setState(() {
                                                            errorMessage = null;
                                                          });

                                                          String capitalizedValue = capitalizeFirstLetter(query);
                                                          op1.value = op1.value.copyWith(
                                                            text: capitalizedValue,
                                                            selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                          );
                                                        },
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter.deny(RegExp(r'\d')),
                                                        ],
                                                        style: const TextStyle(fontSize: 13),
                                                        decoration: InputDecoration(
                                                          fillColor: Colors.white,
                                                          filled: true,
                                                          labelText: "Employee",
                                                          labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                      suggestionsCallback: (pattern) async {
                                                        if (selectedNames.isNotEmpty) {
                                                          List<String> suggestions = persondata
                                                              .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                              .toSet()
                                                              .toList();

                                                          suggestions = suggestions
                                                              .where((suggestion) => !selectedNames.contains(suggestion))
                                                              .toList();

                                                          return suggestions;
                                                        }
                                                        List<String> suggestions = persondata
                                                            .where((item) =>
                                                        (item['first_name']?.toString()?.toLowerCase() ?? '')
                                                            .startsWith(pattern.toLowerCase()) &&
                                                            item['emp_code']?.toString()?.toLowerCase() != empID?.toLowerCase() &&
                                                            item['emp_code']?.toString()?.toLowerCase() != empID2?.toLowerCase())
                                                            .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                            .toSet()
                                                            .toList();

/*
                                                      suggestions = suggestions.where((suggestion) =>
                                                      suggestion != op2.text &&
                                                          suggestion != ass1.text &&
                                                          suggestion != ass2.text &&
                                                          suggestion != ass3.text).toList();
*/

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
                                                          emp_code1.text = selectedEmpID;
                                                          print(emp_code1.text);
                                                        });

                                                        selectedNames.add(suggestion);

                                                        //selectedOperator1 = suggestion;

                                                        bool isValidID = data.any((item) =>
                                                        '${item['emp_code']}'.toLowerCase() == selectedEmpID.toLowerCase());
                                                        validname1 = isValidID.toString();

                                                        if (selectedOperator2 != null && suggestion == selectedOperator2 && suggestion == selectedOperator3 && suggestion == selectedOperator4 && suggestion == selectedOperator5) {
                                                          setState(() {
                                                            errorMessage = "Already Assigned the ID in Operator ";
                                                          });
                                                        } else if (selectedEmpID == empID2) {
                                                          setState(() {
                                                            errorMessage = "Already Assigned the ID in Operator 2";
                                                          });
                                                        }
                                                        else {
                                                          setState(() {
                                                            opName1 = selectedEmpName;
                                                            empID = selectedEmpID;
                                                            op1.text = suggestion;
                                                          });

                                                          Future.delayed(Duration(milliseconds: 100), () {
                                                            setState(() {
                                                              op1FocusNode.unfocus();
                                                              op1FocusNode.canRequestFocus = false;
                                                            });
                                                          });
                                                        }

                                                        print('Selected Operator Name 1: $opName1, ID: $selectedEmpID');
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 50,),
                                                  SizedBox(
                                                    width: 200,
                                                    height: 70,
                                                    child: TextFormField(
                                                      controller: wrk_type,
                                                      //focusNode: op1FocusNode,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          errorMessage = null;
                                                        });
                                                      },
                                                      style: const TextStyle(fontSize: 13),
                                                      decoration: InputDecoration(
                                                        fillColor: Colors.white,
                                                        filled: true,
                                                        labelText: "Working Type ",
                                                        labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                  ),


                                                ]

                                            )
                                          ],
                                        ),
                                      ), /// Winding From Date And To date , Shift Type , Machine Name

                                    ]),

                              ]
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child:
                      Wrap(
                        children: [
                          MaterialButton(

                            color: Colors.green.shade600,
                            onPressed: (){
                              if(_formKey.currentState!.validate()){

                                if(dropdownvalue == "Shift Type"){
                                  setState(() {
                                    errorMessage = '* Select a shift';
                                  });
                                }

                                else if(op1.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Person 1';
                                  });
                                }
                                else if(emp_code1.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a correct Person 1';
                                  });
                                }
                                else if(wrk_type.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Working Type ';
                                  });
                                }




                                else {
                                  onButtonPressed();
                                  filterFromtodateData(fromDate.toString(),toDate.toString(),dropdownvalue);
                                  print("op1-${op1.text}");
                                  print("workingType-${wrk_type.text}");
                                  print("shift -${dropdownvalue.toString()}");

                                }

                              }
                            },


                            child: Text("SAVE",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 10,),
                          MaterialButton(
                            color: Colors.blue.shade600,
                            onPressed: (){
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
                                              MaterialPageRoute(builder: (context) =>const Other_worker()));// Close the alert box
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
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text('Do you want to Cancel?'),
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
                            },child: Text("CANCEL",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 10,),
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
                                  ],
                                ),
                                const SizedBox(height: 20,),
                                PaginatedDataTable(
                                  columnSpacing:100,
                                  rowsPerPage:25,
                                  columns:   const [
                                    DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("From Date ",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("To Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Shift Type",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Employee",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Work Type",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text(" Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  ],
                                  source: _YourDataTableSource(filteredDataNew,context,),
                                ),
                                //    SizedBox(height: 200,),
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

  _YourDataTableSource(this.data,this.context);

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
        DataCell(Center(child: Text(
          row["fromDate"] != null
              ? DateFormat('dd-MM-yyyy').format(
            DateTime.parse("${row["fromDate"]}").toLocal(),
          )
              : "",
        ),)), /// from date
        DataCell(Center(child: Text(
          row["toDate"] != null
              ? DateFormat('dd-MM-yyyy').format(
            DateTime.parse("${row["toDate"]}").toLocal(),
          )
              : "",
        ),)), ///to date
        DataCell(Center(child: Text("${row["shiftType"]}"))),
        DataCell(Center(child: Text("${row["opOneName"]}"))),
        DataCell(Center(child: Text("${row["workingType"]}"))),
        DataCell(Center(child:
        Row(
          children: [
            IconButton(icon: Icon(Icons.edit,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Other_Worker_view(
                id:row["id"],
                fromDate:row["fromDate"],
                toDate:row["toDate"],
                shiftType:row["shiftType"],
                opOneName:row["opOneName"],
                emp_code1:row["emp_code1"],
                workingType:row["workingType"],


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



