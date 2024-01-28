import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart'as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';

import '../home.dart';
import 'PrintingView.dart';
import 'WindingView.dart';
import 'finishing_view.dart';

class WorkerTab extends StatefulWidget {
  const WorkerTab({Key? key}) : super(key: key);

  @override
  State<WorkerTab> createState() => _WorkerTabState();
}

class _WorkerTabState extends State<WorkerTab> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,

      child: MyScaffold(
        route: 'winding',backgroundColor: Colors.white,

        body: WillPopScope(
          onWillPop: () async {
            // Your custom navigation logic here
            // For example, if you want to navigate to a different screen:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Home()),
            );
            // Return false to prevent default back navigation
            return false;
          },
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  // TabBar widget
                  const TabBar(
                    tabAlignment: TabAlignment.center,
                    //  controller: _tabController,
                    // isScrollable: true,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.black,
                    tabs: [
                      Tab(text: 'Winding'),
                      Tab(text: 'Printing'),
                      Tab(text: 'Finishing'),
                    ],
                  ),

                  const SizedBox(height: 10,),
                  // TabBarView widget
                  Container(
                      height:1000,
                      child: TabBarView(children: [
                        WindingEntry(),
                        // SizeEntry(),
                        // ColorsEntry(),
                        PrintingEntry(),

                        FinishingEntry(),
                      ])
                  )],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

///winding

class WindingEntry extends StatefulWidget {
  const WindingEntry({Key? key}) : super(key: key);

  @override
  State<WindingEntry> createState() => _WindingEntryState();
}
class _WindingEntryState extends State<WindingEntry> {
  final _formKey = GlobalKey<FormState>();
  DateTime date = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  late TextEditingController controller;

  late DateTime eod;// Declare as late since it will be initialized in the constructor

  DateTime _calculateInitialDate() {
    DateTime currentDate = DateTime.now();

    // If the current day is not Monday (weekday 1), find the next Monday
    while (currentDate.weekday != 1) {
      currentDate = currentDate.add(Duration(days: 1));
    }

    return currentDate;
  }

  // Constructor to initialize eod
  _WindingEntryState() {
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
      final response = await http.get(Uri.parse('http://localhost:3309/winding_entry_get_report'));
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


  /// fetchunit get into database
/*
  Future<List<Map<String, dynamic>>> fetchwindingAutoIncrement(String winding_ID) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/winding_Id_fetch?winding_ID=$winding_ID'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          for (var entry in data){
            selectedmachine = entry["machName"];
            // op2.text =entry["optwoName"];
            op1.text =entry["opOneName"];
            ass1.text =entry["assOne"];
            ass2.text =entry["asstwo"];
            //  ass3.text =entry["assthree"];
            dropdownvalue=entry['shiftType'];
          }
        });
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }
*/

  ///fetch details auto increment end
  bool enable = false;
  bool disable=true;

  ///autoincrement setup

  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['winding_ID'];
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
      String id = 'WI${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ponumfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_winding_code'));
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
      final response = await http.get(Uri.parse('http://localhost:3309/winding_entry_duplicatecheck'));
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
  bool isDuplicateEntry(DateTime selectedDate, String selectedMachine,
      String selectedShift,) {

    return windingData.any((entry) {
      DateTime entryDate = DateTime.parse(entry['shiftdate']);
      String entryMachineName = entry['machName'];
      String entryShift = entry['shiftType'];

      return selectedDate.isAtSameMomentAs(entryDate) &&
          selectedMachine == entryMachineName &&
          selectedShift == entryShift ;

    });
  }



  void onButtonPressed() {
    DateTime selectedDate = eod;
    String selectedMachine = selectedmachine.toString();
    String selectedShift = dropdownvalue;
    String selectedOperator = op1.text;

    // Check for duplicate entry
    if (isDuplicateEntry(selectedDate, selectedMachine,
      selectedShift,)) {
      print("dupdate------------------------------:$selectedDate");
      print("selectedMachine-----------------------:$selectedMachine");
      print("selectedShift:$selectedShift");
      print("selectedOperator:$selectedOperator");

      setState(() {
        errorMessage = "This entry is already stored.";
      });
    }
    else {
      print("errodate------------------------------:$selectedDate");
      print("selectedMachine-----------------------:$selectedMachine");
      print("selectedShift:$selectedShift");
      print("selectedOperator:$selectedOperator");
      if (ProdCode.isEmpty) {
        ProdCode = 'WI001';
      }
      dataToInsert = {
        'createdate':date.toString(),
        'winding_ID':ProdCode,
        'shiftdate':eod.toString(),
        "machName":selectedmachine.toString(),
        "opOneName": op1.text,
        "assOne": ass1.text,
        "asstwo": ass2.text,
        "emp_code1":emp_code1.text,
        "emp_code2":emp_code2.text,
        "emp_code3":emp_code3.text,
        "shiftType": dropdownvalue.toString(),
        "fromDate":fromDate.toString(),
        "toDate":toDate.toString(),
        "status": "Without Printing",
      };
      insertData(dataToInsert);
    }
  }

  List<Map<String, dynamic>> shiftData = [];

  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    const String apiUrl = 'http://localhost:3309/winding_entry/'; // Replace with your server details

    try {
      String machineNamee = dataToInsert['machName'];
      String ShiftType = dataToInsert['shiftType'];
      String OperatorName1 = dataToInsert['opOneName'];
      String FromDate = dataToInsert['fromDate'];
      String ToDate = dataToInsert['toDate'];
      String assOne =dataToInsert['assOne'];
      String asstwo =dataToInsert['asstwo'];
      String shiftdate =dataToInsert['shiftdate'];
      String Status =dataToInsert['status'];

      List<Map<String, dynamic>> unitEntries = await fetchUnitEntries();
      bool isDuplicate = unitEntries.any((entry) =>
      entry['machName'] == machineNamee &&
          entry['shiftType'] == ShiftType &&
          entry['opOneName'] == OperatorName1 &&
          entry['fromDate'] == FromDate &&
          entry['toDate'] == ToDate &&
          entry['assOne'] ==assOne &&
          entry['asstwo'] ==asstwo &&
          entry['shiftdate'] ==shiftdate &&
          entry['status'] ==Status

      );
      if (isDuplicate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Winding"),
              content: Text("This item already Stored...??"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                    //  updateqtyinProduction(machineName, ShiftType, OperatorName1,optwoName,assOne,asstwo,assthree ,int.parse(qty.text),formattedDate);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>WindingEntry()));
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
              title: Text("Winding Entry"),
              content: Text("saved successfully."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkerTab()));                  },
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


  List<String> machineName = [];
  String? selectedmachine;
  Future<void> getmachine() async {
    try {
      final url = Uri.parse('http://localhost:3309/getmachname/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> machinename = responseData;

        machineName = machinename.map((item) => item['machineName'] as String).toList();

        setState(() {
          // Print itemGroupValues to check if it's populated correctly.
          print('Sizes: $machineName');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  TextEditingController op1 =TextEditingController();
  TextEditingController op2 =TextEditingController();
  TextEditingController ass1 =TextEditingController();
  TextEditingController ass2 =TextEditingController();
  TextEditingController ass3 =TextEditingController();
  TextEditingController emp_code1=TextEditingController();
  TextEditingController emp_code2=TextEditingController();
  TextEditingController emp_code3=TextEditingController();
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

  Future<void> filtermachineName() async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_machinename/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;
        final Set<String> uniqueItemGroups =
        units.map((item) => item['machineName'] as String).toSet();
        machiNameCall=uniqueItemGroups.toList();
        setState(() {
          print("machine Name -$machiNameCall");
        });

        if (responseData is List<dynamic>) {

          print('machine Data:');

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
  String?callUnit;
  List<Map<String, dynamic>> persondata = [];

  /*Future<void> filterFromtodateData(
      String fromDate, String toDate, String shiftType,  String shiftdate ) async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_fromtodate2?fromDate=$fromDate&toDate=$toDate&shiftType=$shiftType&shiftdate=$shiftdate');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List<dynamic>) {
          setState(() {
            persondata =
            List<Map<String, dynamic>>.from(responseData.cast<Map<String, dynamic>>());
          });

          print('Person Data:');
          for (var data in persondata) {
            print('Name: ${data['first_name']},Emp code : ${data['emp_code']}');
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
*/

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
          String supName = item['first_name']?.toString()?.toLowerCase() ?? '';
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
      final url = Uri.parse('http://localhost:3309/winding_entry_get_report_Without_Print/');
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
    toDate = fromDate.add(Duration(days: 5));
    controller = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(fromDate),
    );
    fetchWinding().then((data) {
      setState(() {
        windingData = data;
      });
    });
    ponumfetch();
    getmachine();
    fetchData();
    filtermachineName();
    filteredData = List<Map<String, dynamic>>.from(data
    );
    filterFromtodateData(fromDate.toString(),toDate.toString(),dropdownvalue);
    fetchWindingreport();

  }
  @override
  Widget build(BuildContext context) {
    prodCode.text= generateId();
    return Scaffold(
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
                                              child: Text("Winding Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),
                                            ),]
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 15),
                                        width: 100.0,
                                        child: Column(
                                          children: [
                                            Wrap(
                                              children: [
                                                Visibility(
                                                  visible: disable,
                                                  /// winding Create dateField
                                                  child: TextFormField(
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
                                                            ass1.clear();
                                                            ass2.clear();
                                                            selectedmachine = null;
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
                                    Visibility(
                                      visible: disable,
                                      child: Container(
                                        height: 40,
                                        width: 150,
                                        child:  Text(ProdCode.isEmpty? "WI001":ProdCode,style: TextStyle(fontSize: 15,color: Colors.black),),
                                      ),
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
                                                        // DateTime? selectedDate = await
                                                        showDatePicker(
                                                          context: context,
                                                          initialDate: _calculateInitialDate(),
                                                          // initialDate: fromDate,
                                                          firstDate: fromDate,
                                                          lastDate: DateTime(2100),
                                                          selectableDayPredicate: (DateTime date) {
                                                            // Allow only Mondays to be selected
                                                            return date.weekday == 1; // Monday corresponds to weekday 1
                                                          } ,

                                                        ).then((date) {
                                                          if (date != null) {
                                                            setState(() {
                                                              fromDate = date;
                                                              toDate = fromDate.add(Duration(days: 6));
                                                              controller.text = DateFormat('dd-MM-yyyy').format(fromDate);
                                                              dropdownvalue = "Shift Type";
                                                              // eod = fromDate;
                                                              op1.clear();
                                                              ass1.clear();
                                                              ass2.clear();
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
                                                ),   /// winding from date
                                                SizedBox(width: 50),
                                                SizedBox(
                                                  width: 200,
                                                  height: 70,
                                                  child: TextFormField(
                                                    style: TextStyle(fontSize: 13),
                                                    readOnly: true,
/*
                                                    onTap: () {
                                                      showDatePicker(
                                                        context: context,
                                                        initialDate: toDate ?? fromDate.add(Duration(days: 6)),
                                                        firstDate: fromDate.add(Duration(days: 1)),
                                                        lastDate: DateTime(2100),
                                                      ).then((date) {
                                                        if (date != null) {
                                                          setState(() {
                                                            toDate = date;
                                                            dropdownvalue = "Shift Type";
                                                            op1.clear();
                                                            ass1.clear();
                                                            ass2.clear();
                                                            selectedmachine= null;
                                                          });
                                                        }
                                                      });
                                                    },
*/
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
                                                        // hint: Text("Shift type"),
                                                        items: <String>['Shift Type','Morning','Night',]
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
                                                            ass1.clear();
                                                            ass2.clear();
                                                            selectedmachine =null;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),     /// shift Type
                                                SizedBox(width: 50),
                                                SizedBox(
                                                  width: 200,
                                                  height:38,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(color: Colors.grey),
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButtonFormField<String>(
                                                        hint: const Text("Machine Name"),
                                                        value:selectedmachine, // Use selectedSize to store the selected value
                                                        items: machiNameCall.map((String value) {
                                                          return DropdownMenuItem<String>(
                                                            //  enabled: false,
                                                            value: value,
                                                            child: Text(
                                                              value,
                                                              style: const TextStyle(fontSize: 15),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (String? newValue) {
                                                          setState(() {
                                                            selectedmachine = newValue;
                                                            errorMessage = null; // Reset error message when a new value is selected

                                                            /*   op1.clear();
                                                            ass1.clear();
                                                            ass2.clear();
                                                            ass3.clear();*/
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ), /// Machine Name
                                              ],
                                            ),
                                          ],
                                        ),
                                      ), /// Winding From Date And To date , Shift Type , Machine Name
                                      SizedBox(width: 50,),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Wrap(
                                          //crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            SizedBox(
                                              width: 200, height: 70,
                                              child: TypeAheadFormField<String>(
                                                textFieldConfiguration: TextFieldConfiguration(

                                                  controller: op1,
                                                  focusNode: op1FocusNode,
                                                  enabled: selectedmachine != null,
                                                  onChanged: (query) {
                                                    if (selectedmachine !=null) {
                                                      setState(() {
                                                        op1.text = query;
                                                        errorMessage = null;
                                                      });
                                                    }

                                                    /*  if (query.isEmpty) {
                                                      // Clear emp code when the text field is cleared
                                                      setState(() {
                                                        emp_code1.text = ''; // or whatever initial value you want
                                                      });
                                                    }*/
                                                    if (query.isEmpty) {
                                                      // Clear emp code when the text field is cleared
                                                      setState(() {
                                                        emp_code1.text = ''; // or whatever initial value you want
                                                        if (opName1 != null && opName1!.isNotEmpty) {
                                                          selectedNames.add(opName1!); // Add the cleared name back to the list
                                                        }
                                                        opName1 = null; // Set opName1 to null after clearing the field
                                                      });
                                                    }

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
                                                      labelText: "Operator ",
                                                      labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                      border:selectedmachine != null
                                                          ?
                                                      OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ): null
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

                                                  suggestions = suggestions.where((suggestion) =>
                                                  suggestion != op2.text &&
                                                      suggestion != ass1.text &&
                                                      suggestion != ass2.text &&
                                                      suggestion != ass3.text).toList();

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
                                                  } else if (selectedEmpName == ass1.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 1";
                                                    });
                                                  } else if (selectedEmpName == ass2.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 2";
                                                    });
                                                  } else if (selectedEmpName == ass3.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 3";
                                                    });
                                                  } else {
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
                                            ),  /// operator 1
                                            SizedBox(width: 50,),
                                            SizedBox(
                                              width: 200, height: 70,
                                              child:  TypeAheadFormField<String>(
                                                textFieldConfiguration: TextFieldConfiguration(
                                                  controller: ass1,
                                                  enabled: selectedmachine != null,
                                                  onChanged: (query) {
                                                    if (selectedmachine != null)
                                                      setState(() {
                                                        ass1.text = query;
                                                        errorMessage = null; // Reset error message when the user types
                                                      });
                                                    if (query.isEmpty) {
                                                      // Clear emp code when the text field is cleared
                                                      setState(() {
                                                        emp_code2.text = ''; // or whatever initial value you want
                                                      });
                                                    }


                                                    String capitalizedValue = capitalizeFirstLetter(query);
                                                    ass1.value = ass1.value.copyWith(
                                                      text: capitalizedValue,
                                                      selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                    );
                                                  },
                                                  style: const TextStyle(fontSize: 13),
                                                  decoration: InputDecoration(
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      labelText: "Assistant 1",
                                                      labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                      border:selectedmachine != null
                                                          ?
                                                      OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ): null
                                                  ),
                                                ),
                                                suggestionsCallback: (pattern) async {
                                                  // If there are selected names in Operator 1, exclude them from suggestions
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

                                                  // If the input pattern is empty, return all names from persondata
                                                  if (pattern.isEmpty) {
                                                    return persondata
                                                        .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                        .toSet()
                                                        .toList();
                                                  }

                                                  // Filter suggestions based on the input pattern
                                                  List<String> suggestions = persondata
                                                      .where((item) =>
                                                  (item['first_name']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()) &&
                                                      item['emp_code']?.toString()?.toLowerCase() != empID?.toLowerCase() &&
                                                      item['emp_code']?.toString()?.toLowerCase() != empID2?.toLowerCase() &&
                                                      item['emp_code']?.toString()?.toLowerCase() != empID3?.toLowerCase())
                                                      .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                      .toSet()
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
                                                  //selectedOperator3 = suggestion;
                                                  setState(() {
                                                    emp_code2.text = selectedEmpID;
                                                    print(emp_code2.text);
                                                  });
                                                  selectedNames.add(suggestion);
                                                  if (selectedEmpID == empID) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Operator 1";
                                                    });

                                                  } else if (selectedEmpID == empID3) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 1";
                                                    });
                                                  } else if (selectedEmpID == empID4) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 2";
                                                    });
                                                  } else if (selectedEmpID == empID5) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 3";
                                                    });
                                                  } else {
                                                    setState(() {
                                                      errorMessage = null;
                                                      assName1 = selectedEmpName;
                                                      ass1.text = suggestion;
                                                    });
                                                    print('Selected Assistant 1: $assName1, ID: $selectedEmpID');
                                                  }
                                                },
                                              ),
                                            ),   /// Assistant 1
                                            SizedBox(width: 50,),
                                            SizedBox(
                                              width: 200, height: 70,
                                              child:  TypeAheadFormField<String>(
                                                textFieldConfiguration: TextFieldConfiguration(
                                                  controller: ass2,
                                                  enabled: selectedmachine != null,
                                                  onChanged: (query) {
                                                    if(selectedmachine != null) {
                                                      setState(() {
                                                        ass2.text =query;
                                                        errorMessage = null; // Reset error message when the user types
                                                      });
                                                      if (query.isEmpty) {
                                                        // Clear emp code when the text field is cleared
                                                        setState(() {
                                                          ass2.text = ''; // or whatever initial value you want
                                                        });
                                                      }
                                                    }
                                                    String capitalizedValue = capitalizeFirstLetter(query);
                                                    ass2.value = ass2.value.copyWith(
                                                      text: capitalizedValue,
                                                      selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                    );
                                                  },
                                                  style: const TextStyle(fontSize: 13),
                                                  decoration: InputDecoration(
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      labelText: "Assistant 2",
                                                      labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                      border:selectedmachine != null
                                                          ?
                                                      OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ): null
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
                                                      item['emp_code']?.toString()?.toLowerCase() != empID2?.toLowerCase() &&
                                                      item['emp_code']?.toString()?.toLowerCase() != empID3?.toLowerCase() )

                                                      .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                      .toSet()
                                                      .toList();

                                                  suggestions = suggestions.where((suggestion) =>
                                                  suggestion != op1.text &&
                                                      suggestion != op2.text &&
                                                      suggestion != ass1.text
                                                  ).toList();
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
                                                  //selectedOperator4 = suggestion;
                                                  setState(() {
                                                    emp_code3.text = selectedEmpID;
                                                    print(emp_code3.text);
                                                  });

                                                  selectedNames.add(suggestion);

                                                  if (selectedEmpID == empID || selectedEmpID == empID2 || selectedEmpID == empID3 || selectedEmpID == empID4 || selectedEmpID == empID5) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Operator or Assistant";
                                                    });
                                                  } else {
                                                    setState(() {
                                                      errorMessage = null;
                                                      assName2 = selectedEmpName;
                                                      ass2.text = suggestion;
                                                    });
                                                    print('Selected Assistant 2: $assName2, ID: $selectedEmpID');
                                                  }
                                                },
                                              ),
                                            ),   /// Assistant 2
                                            SizedBox(child: Container(width: 200, height: 70,))
                                          ],
                                        ),
                                      ),  /// Operator 1 , Assistant 1, Assistant 2
                                      SizedBox(width: 50,),

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
                                else if(selectedmachine == null){
                                  setState(() {
                                    errorMessage = '* Enter a machine name';
                                  });
                                }
                                else if(op1.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Operator';
                                  });
                                }
                                else if(ass1.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a Assistant 1';
                                  });
                                }
                                else if(ass2.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a Assistant 2';
                                  });
                                }
                                else if(emp_code3.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a correct Assistant 2';
                                  });
                                }
                                else if(emp_code2.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a correct Assistant 1';
                                  });
                                }
                                else if(emp_code1.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a correct Operator ';
                                  });
                                }
                                else {
                                  onButtonPressed();
                                  filterFromtodateData(fromDate.toString(),toDate.toString(),dropdownvalue);
                                  print("op1-${op1.text}");
                                  print("op2-${op2.text}");
                                  print("as1-${ass1.text}");
                                  print("as2-${ass2.text}");
                                  print("machname-${selectedmachine.toString()}");
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
                                              MaterialPageRoute(builder: (context) =>const WorkerTab()));// Close the alert box
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
                          ///when click update button enable product quantity and auto increment
                          // MaterialButton(
                          //   color: Colors.blue.shade600,
                          //   onPressed: (){
                          //     setState(() {
                          //       enable = true;
                          //       disable=false;
                          //     });
                          //
                          //   },child: Text("UPDATE",style: TextStyle(color: Colors.white),),)
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
                                    /*  SizedBox(
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
                                      ),*/
                                  ],
                                ),
                                const SizedBox(height: 20,),
                                PaginatedDataTable(
                                  columnSpacing:60,
                                  //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  rowsPerPage:25,
                                  columns:   const [
                                    DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("From Date ",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("To Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Shift Type",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Machine",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Operator 1",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Assistant 1 ",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Assistant 2",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    //DataColumn(label: Center(child: Text("Shift Time",style: TextStyle(fontWeight: FontWeight.bold),))),
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
  // final bool generatedButton;
  // final Function(int) onDelete;

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
        DataCell(Center(child: Text("${row["machName"]}"))),
        DataCell(Center(child: Text("${row["opOneName"]}"))),
        DataCell(Center(child: Text("${row["assOne"]}"))),
        DataCell(Center(child: Text("${row["asstwo"]}"))),
        DataCell(Center(child:
        Row(
          children: [
            IconButton(icon: Icon(Icons.edit,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>WindingView(
                id:row["id"],
                fromDate:row["fromDate"],
                toDate:row["toDate"],
                shiftType:row["shiftType"],
                machName:row["machName"],
                opOneName:row["opOneName"],
                assOne:row["assOne"],
                asstwo:row["asstwo"],
                emp_code1:row["emp_code1"],
                emp_code2:row["emp_code2"],
                emp_code3:row["emp_code3"],

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

///printing
class PrintingEntry extends StatefulWidget {
  const PrintingEntry({Key? key}) : super(key: key);

  @override
  State<PrintingEntry> createState() => _PrintingEntryState();
}
class _PrintingEntryState extends State<PrintingEntry> {
  final _formKey = GlobalKey<FormState>();
  DateTime date = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  late TextEditingController controller;

  late DateTime eod; // Declare as late since it will be initialized in the constructor

  // Constructor to initialize eod
  _PrintingEntryState() {
    eod = DateTime.now();
    eod = DateTime(eod.year, eod.month, eod.day);
  }

  DateTime _calculateInitialDate() {
    DateTime currentDate = DateTime.now();

    // If the current day is not Monday (weekday 1), find the next Monday
    while (currentDate.weekday != 6) {
      currentDate = currentDate.add(Duration(days: 1));
    }

    return currentDate;
  }


  final FocusNode op1FocusNode = FocusNode();

  Map<String, dynamic> dataToInsert = {};

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/printing_entry_get_report'));
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
  /// fetchunit get into database

  ///fetch details auto increment end
  bool enable = false;
  bool disable=true;

  ///autoincrement setup

  ///autoincrement setup

  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['printing_ID'];
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
      String id = 'PR${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ponumfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_printing_code'));
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


  ///autoincrement ending

  ///backend fetch process duplicate entry
  Future<List<Map<String, dynamic>>> fetchWinding() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/printing_entry_duplicatecheck'));
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
  bool isDuplicateEntry(DateTime selectedDate, String selectedMachine,
      String selectedShift,) {

    return windingData.any((entry) {
      DateTime entryDate = DateTime.parse(entry['shiftdate']);
      String entryMachineName = entry['machName'];
      String entryShift = entry['shiftType'];

      return selectedDate.isAtSameMomentAs(entryDate) &&
          selectedMachine == entryMachineName &&
          selectedShift == entryShift
      ;

    });
  }
  void onButtonPressed() {
    DateTime selectedDate = eod;
    String selectedMachine = selectedmachine.toString();
    String selectedShift = dropdownvalue;

    // Check for duplicate entry
    if (isDuplicateEntry(selectedDate, selectedMachine,
      selectedShift, )) {
      print("dupdate------------------------------:$selectedDate");
      print("selectedMachine-----------------------:$selectedMachine");
      print("selectedShift:$selectedShift");

      setState(() {
        errorMessage = "This entry is already stored.";
      });
    }
    else {
      print("errodate------------------------------:$selectedDate");
      print("selectedMachine-----------------------:$selectedMachine");
      print("selectedShift:$selectedShift");

      if (ProdCode.isEmpty) {
        ProdCode = 'PR001';
      }
      dataToInsert = {
        'createdate':date.toString(),
        'printing_ID':ProdCode,
        'shiftdate':eod.toString(),
        "machName":selectedmachine.toString(),
        "opOneName": op1.text,
        "assOne": ass1.text,
        "emp_code1":emp_code1.text,
        "emp_code2":emp_code2.text,
        "shiftType": dropdownvalue.toString(),
        "fromDate":fromDate.toString(),
        "toDate":toDate.toString(),
      };
      insertData(dataToInsert);
    }
  }

  List<Map<String, dynamic>> shiftData = [];

  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    const String apiUrl = 'http://localhost:3309/Printing_entry/'; // Replace with your server details

    try {
      String machineNamee = dataToInsert['machName'];
      String ShiftType = dataToInsert['shiftType'];
      String OperatorName1 = dataToInsert['opOneName'];
      String FromDate = dataToInsert['fromDate'];
      String ToDate = dataToInsert['toDate'];
      String assOne =dataToInsert['assOne'];
      String shiftdate =dataToInsert['shiftdate'];

      List<Map<String, dynamic>> unitEntries = await fetchUnitEntries();
      bool isDuplicate = unitEntries.any((entry) =>
      entry['machName'] == machineNamee &&
          entry['shiftType'] == ShiftType &&
          entry['opOneName'] == OperatorName1 &&
          entry['fromDate'] == FromDate &&
          entry['toDate'] == ToDate &&
          entry['assOne'] ==assOne &&
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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>PrintingEntry()));
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
              title: Text("Printing Entry"),
              content: Text("saved successfully."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkerTab()));                  },
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


  List<String> machineName = [];
  String? selectedmachine;
  Future<void> getmachine() async {
    try {
      final url = Uri.parse('http://localhost:3309/getmachname/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> machinename = responseData;

        machineName = machinename.map((item) => item['machineName'] as String).toList();

        setState(() {
          // Print itemGroupValues to check if it's populated correctly.
          print('Sizes: $machineName');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  TextEditingController op1 =TextEditingController();
  TextEditingController op2 =TextEditingController();
  TextEditingController ass1 =TextEditingController();
  TextEditingController ass2 =TextEditingController();
  TextEditingController ass3 =TextEditingController();
  TextEditingController emp_code1=TextEditingController();
  TextEditingController emp_code2=TextEditingController();
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

  Future<void> filtermachineName() async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_machinename_print/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;
        final Set<String> uniqueItemGroups =
        units.map((item) => item['machineName'] as String).toSet();
        machiNameCall=uniqueItemGroups.toList();
        setState(() {
          print("machine Name -$machiNameCall");
        });

        if (responseData is List<dynamic>) {

          print('machine Data:');

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
  String?callUnit;
  /*Map<String, dynamic> persondata = {};

  Future<void> filterFromtodateData(String fromDate, String toDate, String shiftType) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_fromtodate?fromDate=$fromDate&toDate=$toDate&shiftType=$shiftType');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic>) {
          // Ensure that responseData is a Map
          setState(() {
            persondata = responseData;
          });

          // Now, 'persondata' contains the map of data
          print('Person Data:');
          print('Name: ${persondata['first_name']}, ');
        } else {
          print('Error: Response data is not a Map');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
*/
  List<Map<String, dynamic>> persondata = [];


  Future<void> filterFromtodateData3(
      String fromDate, String toDate, String shiftType ) async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_fromtodate2?fromDate=$fromDate&toDate=$toDate&shiftType=$shiftType');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List<dynamic>) {
          setState(() {
            persondata =
            List<Map<String, dynamic>>.from(responseData.cast<Map<String, dynamic>>());
          });

          print('Person Data:');
          for (var data in persondata) {
            print('Name: ${data['first_name']},Emp code : ${data['emp_code']}');
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
          String supName = item['first_name']?.toString()?.toLowerCase() ?? '';
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
  String printing_ID = '';
  Set<String> assignedNames = {};
  List<String> assignedNamesForDate = [];


  /// This is  for Report View In Same Page

  List<Map<String, dynamic>> filteredDataNew = [];
  List<Map<String, dynamic>> dataNew = [];
  Future<void> fetchPrintingreport() async {
    try {
      final url = Uri.parse('http://localhost:3309/printing_entry_get_report/');
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
    toDate = fromDate.add(Duration(days: 6));
    controller = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(fromDate),
    );
    fetchWinding().then((data) {
      setState(() {
        windingData = data;
      });
    });
    ponumfetch();
    getmachine();
    fetchData();
    filtermachineName();
    filteredData = List<Map<String, dynamic>>.from(data);
    filterFromtodateData3(fromDate.toString(),toDate.toString(),dropdownvalue);
    fetchPrintingreport();
  }
  @override
  Widget build(BuildContext context) {
    prodCode.text= generateId();
    return Scaffold(
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
                                              child: Text("Printing Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),
                                            ),

                                          ]
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 15),
                                        width: 100.0,
                                        child: Column(
                                          children: [
                                            Wrap(
                                              ///prniting entry create date field
                                              children: [
                                                Visibility(
                                                  visible: disable,
                                                  child: TextFormField(
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
                                                            ass1.clear();// Update the selected date
                                                            selectedmachine = null;

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
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20,),
                                            ///winding id textformfiled
                                            // Wrap(
                                            //   children: [
                                            //     Visibility(
                                            //       visible:enable,
                                            //       child: SizedBox(
                                            //         child: TextFormField(
                                            //           controller: windingId,
                                            //           style: const TextStyle(fontSize: 13),
                                            //           inputFormatters: [
                                            //             UpperCaseTextFormatter()
                                            //           ],
                                            //           decoration: InputDecoration(
                                            //             fillColor: Colors.white,
                                            //             filled: true,
                                            //             labelText: "Winding ID",
                                            //             labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                            //             border: OutlineInputBorder(
                                            //               borderRadius: BorderRadius.circular(10),
                                            //             ),
                                            //             suffixIcon: Icon(Icons.search),
                                            //           ),
                                            //
                                            //           onChanged: (value) {
                                            //             setState(() {
                                            //               winding_ID = value;
                                            //               if (value.isEmpty) {
                                            //                 setState(() {
                                            //                   // machineName.clear();
                                            //
                                            //                 });
                                            //
                                            //                 op2.text = '';
                                            //                 op1.text = '';
                                            //                 ass1.text = '';
                                            //                 ass2.text = '';
                                            //                 ass3.text = '';
                                            //                //
                                            //                 // dropdownvalue = ''; // Assuming dropdownvalue is a String
                                            //               } else {
                                            //                 // Fetch data only when winding_ID is not empty
                                            //                 fetchwindingAutoIncrement(value);
                                            //               }
                                            //             });
                                            //
                                            //           },
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
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
                                    Visibility(
                                      visible: disable,
                                      child: Container(
                                        height: 40,
                                        width: 150,
                                        child:  Text(ProdCode.isEmpty? "PR001":ProdCode,style: TextStyle(fontSize: 15,color: Colors.black),),
                                      ),
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
                                                    /// from date field in Prinring Entry
                                                    child: TextFormField(
                                                      style: TextStyle(fontSize: 13),
                                                      readOnly: true,
                                                      onTap: () {
                                                        showDatePicker(
                                                          context: context,
                                                          initialDate: _calculateInitialDate(),
                                                          // initialDate: fromDate,
                                                          firstDate: fromDate,
                                                          lastDate: DateTime(2100),
                                                          selectableDayPredicate: (DateTime date) {
                                                            // Allow only Mondays to be selected
                                                            return date.weekday == 6; // Monday corresponds to weekday 1
                                                          } ,

                                                        ).then((date) {
                                                          if (date != null) {
                                                            setState(() {
                                                              fromDate = date;
                                                              toDate = fromDate.add(Duration(days: 6));
                                                              controller.text = DateFormat('dd-MM-yyyy').format(fromDate);
                                                              dropdownvalue = "Shift Type";
                                                              //   eod = fromDate;
                                                              op1.clear();
                                                              ass1.clear();
                                                              selectedmachine = null;
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
                                                  /// to date field in printing enty
                                                  child: TextFormField(
                                                    style: TextStyle(fontSize: 13),
                                                    readOnly: true,
/*
                                                    onTap: () {
                                                      showDatePicker(
                                                        context: context,
                                                        initialDate: toDate ?? fromDate.add(Duration(days: 7)),
                                                        firstDate: fromDate.add(Duration(days: 1)),
                                                        lastDate: DateTime(2100),
                                                      ).then((date) {
                                                        if (date != null) {
                                                          setState(() {
                                                            toDate = date;
                                                            dropdownvalue = "Shift Type";
                                                            op1.clear();
                                                            ass1.clear();
                                                            selectedmachine = null;
                                                          });
                                                        }
                                                      });
                                                    },
*/
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
                                                ),  /// TO date
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
                                                        // hint: Text("Shift type"),
                                                        items: <String>['Shift Type','General']
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
                                                          filterFromtodateData3(fromDate.toString(),toDate.toString(),newValue!);
                                                          setState(() {
                                                            dropdownvalue = newValue!;
                                                            op1.clear();
                                                            ass1.clear();
                                                            selectedmachine =null;

                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 50),
                                                SizedBox(
                                                  width: 200,
                                                  height:38,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(color: Colors.grey),
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButtonFormField<String>(
                                                        hint: const Text("Machine Name"),
                                                        value:selectedmachine, // Use selectedSize to store the selected value
                                                        items: machiNameCall.map((String value) {
                                                          return DropdownMenuItem<String>(
                                                            //  enabled: false,
                                                            value: value,
                                                            child: Text(
                                                              value,
                                                              style: const TextStyle(fontSize: 15),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (String? newValue) {
                                                          setState(() {
                                                            selectedmachine = newValue;
                                                            errorMessage = null;
                                                            /*op1.clear();
                                                            ass1.clear();*/
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 50,),

                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Wrap(
                                          //crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            SizedBox(
                                              width: 200, height: 70,
                                              child: TypeAheadFormField<String>(
                                                textFieldConfiguration: TextFieldConfiguration(

                                                  controller: op1,
                                                  focusNode: op1FocusNode,
                                                  enabled: selectedmachine != null,
                                                  onChanged: (query) {
                                                    if (selectedmachine !=null) {
                                                      setState(() {
                                                        op1.text = query;
                                                        errorMessage = null;
                                                      });
                                                      if (query.isEmpty) {
                                                        // Clear emp code when the text field is cleared
                                                        setState(() {
                                                          emp_code1.text = ''; // or whatever initial value you want
                                                        });
                                                      }
                                                    }

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
                                                      labelText: "Person 1",
                                                      labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                      border:selectedmachine != null
                                                          ?
                                                      OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ): null
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

                                                  suggestions = suggestions.where((suggestion) =>
                                                  suggestion != op2.text &&
                                                      suggestion != ass1.text &&
                                                      suggestion != ass2.text &&
                                                      suggestion != ass3.text).toList();

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
                                                  } else if (selectedEmpName == ass1.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 1";
                                                    });
                                                  } else if (selectedEmpName == ass2.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 2";
                                                    });
                                                  } else if (selectedEmpName == ass3.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 3";
                                                    });
                                                  } else {
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
                                              width: 200, height: 70,
                                              child:  TypeAheadFormField<String>(
                                                textFieldConfiguration: TextFieldConfiguration(
                                                  controller: ass1,
                                                  enabled: selectedmachine != null,
                                                  onChanged: (query) {
                                                    if (selectedmachine !=null) {
                                                      setState(() {
                                                        ass1.text = query;
                                                        errorMessage = null;
                                                      });
                                                      if (query.isEmpty) {
                                                        // Clear emp code when the text field is cleared
                                                        setState(() {
                                                          emp_code2.text = ''; // or whatever initial value you want
                                                        });
                                                      }

                                                    }
                                                    String capitalizedValue = capitalizeFirstLetter(query);
                                                    ass1.value = ass1.value.copyWith(
                                                      text: capitalizedValue,
                                                      selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                    );
                                                  },
                                                  style: const TextStyle(fontSize: 13),
                                                  decoration: InputDecoration(
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      labelText: "Person 2",
                                                      labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                      border:selectedmachine != null
                                                          ?
                                                      OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ): null
                                                  ),
                                                ),
                                                suggestionsCallback: (pattern) async {
                                                  // If there are selected names in Operator 1, exclude them from suggestions
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

                                                  // If the input pattern is empty, return all names from persondata
                                                  if (pattern.isEmpty) {
                                                    return persondata
                                                        .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                        .toSet()
                                                        .toList();
                                                  }

                                                  // Filter suggestions based on the input pattern
                                                  List<String> suggestions = persondata
                                                      .where((item) =>
                                                  (item['first_name']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()) &&
                                                      item['emp_code']?.toString()?.toLowerCase() != empID?.toLowerCase() &&
                                                      item['emp_code']?.toString()?.toLowerCase() != empID2?.toLowerCase() &&
                                                      item['emp_code']?.toString()?.toLowerCase() != empID3?.toLowerCase())
                                                      .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                      .toSet()
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
                                                    emp_code2.text = selectedEmpID;
                                                    print(emp_code2.text);
                                                  });
                                                  //selectedOperator3 = suggestion;
                                                  selectedNames.add(suggestion);



                                                  if (selectedEmpID == empID) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Operator 1";
                                                    });

                                                  } else if (selectedEmpID == empID3) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 1";
                                                    });
                                                  } else if (selectedEmpID == empID4) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 2";
                                                    });
                                                  } else if (selectedEmpID == empID5) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 3";
                                                    });
                                                  } else {
                                                    setState(() {
                                                      errorMessage = null;
                                                      assName1 = selectedEmpName;
                                                      ass1.text = suggestion;
                                                    });
                                                    print('Selected Assistant 1: $assName1, ID: $selectedEmpID');
                                                  }
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 50,),

                                            SizedBox(child: Container(width: 200, height: 75,)),

                                            SizedBox(width: 50,),

                                            SizedBox(child: Container(width: 200, height: 75,))





                                          ],
                                        ),
                                      ),

                                      /// operator 2 value
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
                                else if(selectedmachine == null){
                                  setState(() {
                                    errorMessage = '* Enter a machine name';
                                  });
                                }
                                else if(op1.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Person 1';
                                  });
                                }
                                else if(ass1.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a Person 2';
                                  });
                                }
                                else if(emp_code1.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a correct employee name 1';
                                  });
                                }
                                else if(emp_code2.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a correct employee name 2';
                                  });
                                }



                                else {
                                  onButtonPressed();
                                  filterFromtodateData3(fromDate.toString(),toDate.toString(),dropdownvalue);
                                  print("op1-${op1.text}");
                                  print("op2-${op2.text}");
                                  print("as1-${ass1.text}");
                                  print("as2-${ass2.text}");
                                  print("as3-${ass3.text}");
                                  print("machname-${selectedmachine.toString()}");
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
                                              MaterialPageRoute(builder: (context) =>const WorkerTab()));// Close the alert box
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
                              );                          },child:Text("RESET",style: TextStyle(color: Colors.white),),),
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
                          ///when click update button enable product quantity and auto increment
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
                                  columnSpacing:70,
                                  //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  rowsPerPage:25,
                                  columns:   const [
                                    DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("From Date ",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("To Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Shift Type",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Machine",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Person 1",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Person 2",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    // DataColumn(label: Center(child: Text("Person 3",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    //DataColumn(label: Center(child: Text("Shift Time",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text(" Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  ],
                                  source: _YourDataTableSourcePrinting(filteredDataNew,context,),
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
class _YourDataTableSourcePrinting extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  // final bool generatedButton;
  // final Function(int) onDelete;

  _YourDataTableSourcePrinting(this.data,this.context);

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
        DataCell(Center(child: Text("${row["machName"]}"))),
        DataCell(Center(child: Text("${row["opOneName"]}"))),
        DataCell(Center(child: Text("${row["assOne"]}"))),
        // DataCell(Center(child: Text("${row["asstwo"]}"))),
        DataCell(Center(child:
        Row(
          children: [
            IconButton(icon: Icon(Icons.edit,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>PrintingView(
                id:row["id"],
                fromDate:row["fromDate"],
                toDate:row["toDate"],
                shiftType:row["shiftType"],
                machName:row["machName"],
                opOneName:row["opOneName"],
                assOne:row["assOne"],
                //asstwo:row["asstwo"],
                emp_code1:row["emp_code1"],
                emp_code2:row["emp_code2"],
                //emp_code3:row["emp_code3"],

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

///finshing

class FinishingEntry extends StatefulWidget {
  const FinishingEntry({Key? key}) : super(key: key);

  @override
  State<FinishingEntry> createState() => _FinishingEntryState();
}
class _FinishingEntryState extends State<FinishingEntry> {
  final _formKey = GlobalKey<FormState>();
  DateTime date = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  late TextEditingController controller;



  late DateTime eod; // Declare as late since it will be initialized in the constructor

  // Constructor to initialize eod
  _FinishingEntryState() {
    eod = DateTime.now();
    eod = DateTime(eod.year, eod.month, eod.day);
  }
  DateTime _calculateInitialDate() {
    DateTime currentDate = DateTime.now();

    // If the current day is not Monday (weekday 1), find the next Monday
    while (currentDate.weekday != 6) {
      currentDate = currentDate.add(Duration(days: 1));
    }

    return currentDate;
  }

  final FocusNode op1FocusNode = FocusNode();

  Map<String, dynamic> dataToInsert = {};

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/finishing_entry_get_report'));
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
  /// fetchunit get into database


  ///fetch details auto increment end
  bool enable = false;
  bool disable=true;


  ///autoincrement setup

  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['finishing_ID'];
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
      String id = 'FI${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ponumfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_finishing_code'));
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

  ///backend fetch process duplicate entry finishing
  Future<List<Map<String, dynamic>>> fetchWinding() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/finishing_entry_duplicatecheck'));
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
  bool isDuplicateEntry(DateTime selectedDate, String selectedMachine,
      String selectedShift,) {

    return windingData.any((entry) {
      DateTime entryDate = DateTime.parse(entry['shiftdate']);
      String entryMachineName = entry['machName'];
      String entryShift = entry['shiftType'];

      return selectedDate.isAtSameMomentAs(entryDate) &&
          selectedMachine == entryMachineName &&
          selectedShift == entryShift ;

    });
  }
  void onButtonPressed() {
    DateTime selectedDate = eod;
    String selectedMachine = selectedmachine.toString();
    String selectedShift = dropdownvalue;

    // Check for duplicate entry
    if (isDuplicateEntry(selectedDate, selectedMachine,
      selectedShift,)) {
      print("dupdate------------------------------:$selectedDate");
      print("selectedMachine-----------------------:$selectedMachine");
      print("selectedShift:$selectedShift");

      setState(() {
        errorMessage = "This entry is already stored.";
      });
    }
    else {
      print("errodate------------------------------:$selectedDate");
      print("selectedMachine-----------------------:$selectedMachine");
      print("selectedShift:$selectedShift");
      if (ProdCode.isEmpty) {
        ProdCode = 'FI001';
      }
      dataToInsert = {
        'createdate':date.toString(),
        'finishing_ID':ProdCode,
        'shiftdate':eod.toString(),
        "machName":selectedmachine.toString(),
        "opOneName": op1.text,
        "assOne": ass1.text,
        "shiftType": dropdownvalue.toString(),
        "fromDate":fromDate.toString(),
        "toDate":toDate.toString(),
        "emp_code1":emp_code1.text,
        "emp_code2":emp_code2.text,
      };
      insertData(dataToInsert);
    }
  }

  List<Map<String, dynamic>> shiftData = [];

  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    const String apiUrl = 'http://localhost:3309/finishing_entry/'; // Replace with your server details

    try {
      String machineNamee = dataToInsert['machName'];
      String ShiftType = dataToInsert['shiftType'];
      String OperatorName1 = dataToInsert['opOneName'];
      String FromDate = dataToInsert['fromDate'];
      String ToDate = dataToInsert['toDate'];
      String assOne =dataToInsert['assOne'];
      String shiftdate =dataToInsert['shiftdate'];

      List<Map<String, dynamic>> unitEntries = await fetchUnitEntries();
      bool isDuplicate = unitEntries.any((entry) =>
      entry['machName'] == machineNamee &&
          entry['shiftType'] == ShiftType &&
          entry['opOneName'] == OperatorName1 &&
          entry['fromDate'] == FromDate &&
          entry['toDate'] == ToDate &&
          entry['assOne'] ==assOne &&
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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>FinishingEntry()));
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
              title: Text("Finishing Entry"),
              content: Text("saved successfully."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkerTab()));                  },
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


  List<String> machineName = [];
  String? selectedmachine;


  /// get machine type query
  Future<void> getmachine() async {
    try {
      final url = Uri.parse('http://localhost:3309/getmachname/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> machinename = responseData;

        machineName = machinename.map((item) => item['machineName'] as String).toList();

        setState(() {
          // Print itemGroupValues to check if it's populated correctly.
          print('Sizes: $machineName');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  /// machine type query ended

  TextEditingController op1 =TextEditingController();
  TextEditingController op2 =TextEditingController();
  TextEditingController ass1 =TextEditingController();
  TextEditingController ass2 =TextEditingController();
  TextEditingController ass3 =TextEditingController();
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

  Future<void> filtermachineName() async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_machinename_printing/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;
        final Set<String> uniqueItemGroups =
        units.map((item) => item['machineName'] as String).toSet();
        machiNameCall=uniqueItemGroups.toList();
        setState(() {
          print("machine Name -$machiNameCall");
        });

        if (responseData is List<dynamic>) {

          print('machine Data:');

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
  String?callUnit;
  List<Map<String, dynamic>> persondata = [];

  Future<void> filterFromtodateData4(
      String fromDate, String toDate, String shiftType,) async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_fromtodate2?fromDate=$fromDate&toDate=$toDate&shiftType=$shiftType');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List<dynamic>) {
          setState(() {
            persondata =
            List<Map<String, dynamic>>.from(responseData.cast<Map<String, dynamic>>());
          });

          print('Person Data:');
          for (var data in persondata) {
            print('Name: ${data['first_name']},Emp code : ${data['emp_code']}');
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
          String supName = item['first_name']?.toString()?.toLowerCase() ?? '';
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
  TextEditingController emp_code1=TextEditingController();
  TextEditingController emp_code2=TextEditingController();
  String finishing_ID = '';

  /// finishing

  List<Map<String, dynamic>> filteredDataNew = [];
  List<Map<String, dynamic>> dataNew = [];
  Future<void> fetchWindingreport() async {
    try {
      final url = Uri.parse('http://localhost:3309/finishing_entry_get_report/');
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
    toDate = fromDate.add(Duration(days: 5));
    controller = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(fromDate),
    );
    fetchWinding().then((data) {
      setState(() {
        windingData = data;
      });
    });
    ponumfetch();
    getmachine();
    fetchData();
    filtermachineName();
    fetchWindingreport();
    filteredData = List<Map<String, dynamic>>.from(data);
    filterFromtodateData4(fromDate.toString(),toDate.toString(),dropdownvalue,);

  }
  @override
  Widget build(BuildContext context) {
    prodCode.text= generateId();
    return Scaffold(
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
                                              child: Text("Finishing Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),
                                            ),
                                          ]
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 15),
                                        width: 100.0,
                                        child: Column(
                                          children: [
                                            Wrap(
                                              /// finishing create date field
                                              children: [
                                                Visibility(
                                                  visible: disable,
                                                  child: TextFormField(
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
                                                            dropdownvalue = "Shift Type";// Update the selected date
                                                            op1.clear();
                                                            ass1.clear();
                                                            selectedmachine = null;

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
                                                ),
                                              ],
                                            ),
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
                                    Visibility(
                                      visible: disable,
                                      child: Container(
                                        height: 40,
                                        width: 150,
                                        child:  Text(ProdCode.isEmpty? "FI001":ProdCode,style: TextStyle(fontSize: 15,color: Colors.black),),
                                      ),
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
                                                      onTap: () {
                                                        showDatePicker(
                                                          context: context,
                                                          initialDate: _calculateInitialDate(),
                                                          // initialDate: fromDate,
                                                          firstDate: fromDate,
                                                          lastDate: DateTime(2100),
                                                          selectableDayPredicate: (DateTime date) {
                                                            // Allow only Mondays to be selected
                                                            return date.weekday == 6; // Monday corresponds to weekday 1
                                                          } ,

                                                        ).then((date) {
                                                          if (date != null) {
                                                            setState(() {
                                                              fromDate = date;
                                                              toDate = fromDate.add(Duration(days: 6));
                                                              controller.text = DateFormat('dd-MM-yyyy').format(fromDate);
                                                              dropdownvalue = "Shift Type";
                                                              //    eod = fromDate;
                                                              op1.clear();
                                                              ass1.clear();
                                                              selectedmachine= null;
                                                              // Update the selected date
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
                                                ),
                                                SizedBox(width: 50),
                                                SizedBox(
                                                  width: 200,
                                                  height: 70,
                                                  child: TextFormField(
                                                    style: TextStyle(fontSize: 13),
                                                    readOnly: true,
/*
                                                    onTap: () {
                                                      showDatePicker(
                                                        context: context,
                                                        initialDate: toDate ?? fromDate.add(Duration(days: 6)),
                                                        firstDate: fromDate.add(Duration(days: 1)),
                                                        lastDate: DateTime(2100),
                                                      ).then((date) {
                                                        if (date != null) {
                                                          setState(() {
                                                            toDate = date;
                                                            dropdownvalue = "Shift Type";
                                                            op1.clear();
                                                            ass1.clear();
                                                            selectedmachine = null;
                                                          });
                                                        }
                                                      });
                                                    },
*/
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
                                                        // hint: Text("Shift type"),
                                                        items: <String>['Shift Type','General',]
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
                                                          filterFromtodateData4(fromDate.toString(),toDate.toString(),newValue!, );
                                                          setState(() {
                                                            dropdownvalue = newValue!;
                                                            op1.clear();
                                                            ass1.clear();
                                                            selectedmachine =null;


                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 50),
                                                SizedBox(
                                                  width: 200,
                                                  height:38,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(color: Colors.grey),
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButtonFormField<String>(
                                                        hint: const Text("Machine Name"),
                                                        value:selectedmachine, // Use selectedSize to store the selected value
                                                        items: machiNameCall.map((String value) {
                                                          return DropdownMenuItem<String>(
                                                            //  enabled: false,
                                                            value: value,
                                                            child: Text(
                                                              value,
                                                              style: const TextStyle(fontSize: 15),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (String? newValue) {
                                                          setState(() {
                                                            selectedmachine = newValue;
                                                            errorMessage = null;
                                                            /*op1.clear();
                                                            ass1.clear();*/
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),


                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Wrap(
                                          //crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            SizedBox(
                                              width: 200, height: 70,
                                              child: TypeAheadFormField<String>(
                                                textFieldConfiguration: TextFieldConfiguration(

                                                  controller: op1,
                                                  focusNode: op1FocusNode,
                                                  enabled: selectedmachine != null,
                                                  onChanged: (query) {
                                                    if (selectedmachine !=null) {
                                                      setState(() {
                                                        op1.text = query;
                                                        errorMessage = null;
                                                      });
                                                      if (query.isEmpty) {
                                                        // Clear emp code when the text field is cleared
                                                        setState(() {
                                                          emp_code1.text = ''; // or whatever initial value you want
                                                        });
                                                      }
                                                    }

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
                                                      labelText: "Person 1",
                                                      labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                      border:selectedmachine != null
                                                          ?
                                                      OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ): null
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

                                                  suggestions = suggestions.where((suggestion) =>
                                                  suggestion != op2.text &&
                                                      suggestion != ass1.text &&
                                                      suggestion != ass2.text &&
                                                      suggestion != ass3.text).toList();

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
                                                  } else if (selectedEmpName == ass1.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Person  1";
                                                    });
                                                  } else if (selectedEmpName == ass2.text) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in person 2";
                                                    });
                                                  } else {
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
                                              width: 200, height: 70,
                                              child:  TypeAheadFormField<String>(
                                                textFieldConfiguration: TextFieldConfiguration(
                                                  controller: ass1,
                                                  enabled: selectedmachine != null,
                                                  onChanged: (query) {
                                                    if (selectedmachine !=null) {
                                                      setState(() {
                                                        ass1.text = query;
                                                        errorMessage = null;
                                                      });
                                                      if (query.isEmpty) {
                                                        // Clear emp code when the text field is cleared
                                                        setState(() {
                                                          emp_code2.text = ''; // or whatever initial value you want
                                                        });
                                                      }
                                                    }
                                                    String capitalizedValue = capitalizeFirstLetter(query);
                                                    ass1.value = ass1.value.copyWith(
                                                      text: capitalizedValue,
                                                      selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                                    );
                                                  },
                                                  style: const TextStyle(fontSize: 13),
                                                  decoration: InputDecoration(
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      labelText: "person 2",
                                                      labelStyle: TextStyle(fontSize: 13, color: Colors.black),
                                                      border:selectedmachine != null
                                                          ?
                                                      OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ): null
                                                  ),
                                                ),
                                                suggestionsCallback: (pattern) async {
                                                  // If there are selected names in Operator 1, exclude them from suggestions
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

                                                  // If the input pattern is empty, return all names from persondata
                                                  if (pattern.isEmpty) {
                                                    return persondata
                                                        .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                        .toSet()
                                                        .toList();
                                                  }

                                                  // Filter suggestions based on the input pattern
                                                  List<String> suggestions = persondata
                                                      .where((item) =>
                                                  (item['first_name']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()) &&
                                                      item['emp_code']?.toString()?.toLowerCase() != empID?.toLowerCase() &&
                                                      item['emp_code']?.toString()?.toLowerCase() != empID2?.toLowerCase() &&
                                                      item['emp_code']?.toString()?.toLowerCase() != empID3?.toLowerCase())
                                                      .map<String>((item) => '${item['first_name']} (${item['emp_code']})')
                                                      .toSet()
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
                                                    emp_code2.text = selectedEmpID;
                                                    print(emp_code2.text);
                                                  });
                                                  //selectedOperator3 = suggestion;
                                                  selectedNames.add(suggestion);



                                                  if (selectedEmpID == empID) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Operator 1";
                                                    });

                                                  } else if (selectedEmpID == empID3) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 1";
                                                    });
                                                  } else if (selectedEmpID == empID4) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 2";
                                                    });
                                                  } else if (selectedEmpID == empID5) {
                                                    setState(() {
                                                      errorMessage = "Already Assigned the ID in Assistant 3";
                                                    });
                                                  } else {
                                                    setState(() {
                                                      errorMessage = null;
                                                      assName1 = selectedEmpName;
                                                      ass1.text = suggestion;
                                                    });
                                                    print('Selected Assistant 1: $assName1, ID: $selectedEmpID');
                                                  }
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 50,),
                                            Container(
                                              height: 50,
                                              width: 200,
                                            ),
                                            Container(
                                              height: 50,
                                              width: 200,
                                            ),
                                          ],
                                        ),
                                      ),
                                      /// operator 2 value
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
                                else if(selectedmachine == null){
                                  setState(() {
                                    errorMessage = '* Enter a machine name';
                                  });
                                }
                                else if(op1.text.isEmpty) {
                                  setState(() {
                                    errorMessage = '* Enter a Person 1';
                                  });
                                }
                                else if(ass1.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a Person 2';
                                  });
                                }
                                else if(emp_code1.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a correct employee name 1';
                                  });
                                }
                                else if(emp_code2.text.isEmpty){
                                  setState(() {
                                    errorMessage = '* Enter a correct employee name 2';
                                  });
                                }



                                else {
                                  onButtonPressed();
                                  filterFromtodateData4(fromDate.toString(),toDate.toString(),dropdownvalue,);
                                  print("op1-${op1.text}");
                                  print("op2-${op2.text}");
                                  print("as1-${ass1.text}");
                                  print("as2-${ass2.text}");
                                  print("as3-${ass3.text}");
                                  print("machname-${selectedmachine.toString()}");
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
                                              MaterialPageRoute(builder: (context) =>const WorkerTab()));// Close the alert box
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
                              );                          },child:Text("RESET",style: TextStyle(color: Colors.white),),),
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
                          ///when click update button enable product quantity and auto increment
                          // MaterialButton(
                          //   color: Colors.blue.shade600,
                          //   onPressed: (){
                          //     setState(() {
                          //       enable = true;
                          //       disable=false;
                          //     });
                          //
                          //   },child: Text("UPDATE",style: TextStyle(color: Colors.white),),)
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
                                  columnSpacing:70,
                                  //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  rowsPerPage:25,
                                  columns:   const [
                                    DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("From Date ",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("To Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Shift Type",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Machine",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Person 1",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text("Person 2",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    // DataColumn(label: Center(child: Text("Person 3",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    //DataColumn(label: Center(child: Text("Shift Time",style: TextStyle(fontWeight: FontWeight.bold),))),
                                    DataColumn(label: Center(child: Text(" Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                                  ],
                                  source: _YourDataTableSourceFinishing(filteredDataNew,context,),
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
class _YourDataTableSourceFinishing extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  // final bool generatedButton;
  // final Function(int) onDelete;

  _YourDataTableSourceFinishing(this.data,this.context);

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
        DataCell(Center(child: Text("${row["machName"]}"))),
        DataCell(Center(child: Text("${row["opOneName"]}"))),
        DataCell(Center(child: Text("${row["assOne"]}"))),
        // DataCell(Center(child: Text("${row["asstwo"]}"))),
        DataCell(Center(child:
        Row(
          children: [
            IconButton(icon: Icon(Icons.edit,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>FinishingView(
                id:row["id"],
                fromDate:row["fromDate"],
                toDate:row["toDate"],
                shiftType:row["shiftType"],
                machName:row["machName"],
                opOneName:row["opOneName"],
                assOne:row["assOne"],
                //asstwo:row["asstwo"],
                emp_code1:row["emp_code1"],
                emp_code2:row["emp_code2"],
                //emp_code3:row["emp_code3"],

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
