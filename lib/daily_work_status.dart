



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart'as http;
import 'package:vinayaga_project/purchase/customer_order_edit.dart';
import '../../main.dart';
import '../home.dart';
import 'master/balanacesheet_entry.dart';


class RowData {
  String? prodgsm;
  String? itemGroup;
  String? itemName;
  int? quantity;
  List<String> itemNames = [];
  TextEditingController weights=TextEditingController();
  TextEditingController totalqty=TextEditingController();
  TextEditingController numofproduction=TextEditingController();
  TextEditingController finishwight=TextEditingController();
  TextEditingController finishreel=TextEditingController();
  TextEditingController finisedwgt=TextEditingController();
  TextEditingController remainreel=TextEditingController();
  TextEditingController remainwgt=TextEditingController();
  TextEditingController qtyController = TextEditingController();

  RowData({this.itemGroup,this.itemName,this.quantity});

}
class DailyWorkStatus extends StatefulWidget {
  const DailyWorkStatus({Key? key}) : super(key: key);

  @override
  State<DailyWorkStatus> createState() => _DailyWorkStatusState();
}
class _DailyWorkStatusState extends State<DailyWorkStatus> {
  //DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  DateTime fromDate = DateTime.now();
  bool visibleprinting =true;
  // DateTime toDate = DateTime.now();
  TextEditingController controller= TextEditingController();

  Future<List<Map<String, dynamic>>> fetchDuplicateEntry() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_daily_work_status'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("$data");
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  Future<bool> checkDuplicateEntry(Map<String, dynamic> dataToInsertorditem) async {
    // Your logic to check for duplicate entry
    List<Map<String, dynamic>> unitEntries = await fetchDuplicateEntry();
    return unitEntries.any((entry) =>
    entry['machineType'] == dataToInsertorditem['machineType'] &&
        entry['shiftType'] == dataToInsertorditem['shiftType'] &&
        entry['machineName'] == dataToInsertorditem['machineName'] &&
        entry['person1'] == dataToInsertorditem['person1'] &&
        entry['person2'] == dataToInsertorditem['person2'] &&
        entry['createDate'] == dataToInsertorditem['createDate']);
  }


  DateTime date = DateTime.now();
  String? selectedmachinefinishing;
  Future<void> fetchData(String shiftType, String machName, DateTime desiredDate) async {
    final response = await http.get(
      Uri.parse('http://localhost:3309/fetch_daily_Work_status?shiftType=$shiftType&machName=$machName&desiredDate=$desiredDate'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      if (data.isNotEmpty) {
        if (data[0]['winding_opOneName'] != null) {
          person1.text = data[0]['winding_opOneName'] ?? '';
          person1code.text = data[0]['winding_oPempcode1'] ?? '';
          person2.text = data[0]['winding_assOne'] ?? '';
          person2code.text = data[0]['winding_empcode1'] ?? '';
          person3.text = data[0]['winding_asstwo'] ?? '';
          person3code.text = data[0]['winding_empcode2'] ?? '';
        } else {
          person1.text = data[0]['winding_asstwo'] ?? '';
          //person1code.text = data[0]['winding_oPempcode1'] ?? '';
          person2code.text = data[0]['winding_oPempcode1'] ?? '';
          person3code.text = data[0]['winding_empcode1'] ?? '';
          person2.text = data[0]['winding_assOne'] ?? '';
        }
      } else {
        print('Empty data array');
      }
      print("$data     fetch data end ");
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
    }
  }




  void _cancelForm() {
    print('Form cancelled!');
  }
//  List<String> supplierSuggestions = [];
  TextEditingController person1 = TextEditingController();
  TextEditingController person1code = TextEditingController();
  TextEditingController person2 = TextEditingController();
  TextEditingController person2code = TextEditingController();
  TextEditingController person3 = TextEditingController();
  TextEditingController person3code = TextEditingController();
  String? deptType;
  String? shiftType;
  String? errormsg='';
  TextEditingController machineNameController = TextEditingController();
  TextEditingController productionQuantityController = TextEditingController();
  TextEditingController extraproductionamt = TextEditingController();
  TextEditingController numofreels = TextEditingController();
  TextEditingController kgofreels = TextEditingController();
  TextEditingController totalweight = TextEditingController();
  TextEditingController reelsgsm = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  bool isExtraProductionVisible = false;



  //TextEditingController fromDate = TextEditingController();

  // String selectedSupplier = "";
  List<Map<String, dynamic>> data = [];
  String selectedCustomer = '';
  bool person1Visible = false;
  bool person2Visible = false;
  bool person3Visible = false;
  bool productionVisible=false;


  showProductionQuantity() {
    setState(() {
      if (deptType!= null&&
          shiftType!=null&&
          machineNameController.text.isNotEmpty
      ) {
        productionVisible = true;
      } else {
        productionVisible = false;
      }
    });
  }
  bool windvidisible = false;
  bool finishvisible = false;
  bool printvisible = false;
  List<String> machiNameFinishing =[];
  Future<void> filtermachineNameFinish(String machineType) async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_machinename_finishing?machineType=$machineType');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;
        final Set<String> uniquegsmname =
        units.map((item) => item['machineName'] as String).toSet();
        machiNameFinishing=uniquegsmname.toList();
        setState(() {
          print("machine Name -$machiNameFinishing");
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


  Future<void> updateRawMaterial( String prodName,int qty,int totalweight,String modifyDate) async {
    final Uri url = Uri.parse('http://localhost:3309/RawMaterialupdatedailywork'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'prodName': prodName,
        'qty': qty,
        'totalweight':totalweight,
        'modifyDate':date.toString(),
      }),
    );
    if (response.statusCode == 200) {
      print('Raw material Update successful');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
      throw Exception('Failed to update');
    }
  }

  @override
  void initState() {
    super.initState();
    showProductionQuantity();
    getgsm();
    getitem();
    getitemname();
    getitemgroup();
    addRow();
    // TODO: implement initState
    //  _selectedDate = _getNextMonday();
    date = DateTime.now();
    fromDate = DateTime.now(); // Initialize selectedDate with a default value
    controller = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(fromDate),
    );
  }
  bool printdep=false;
  int serialnumber =1;
  void updateTotalWeight() {
    String weightsText = kgofreels.text;
    List<String> weightsList = weightsText.split(',');

    int calculatedTotalWeight = 0;

    for (String weight in weightsList) {
      int individualWeight = int.tryParse(weight.trim()) ?? 0;
      calculatedTotalWeight += individualWeight;
    }

    // Update the totalweight field
    totalweight.text = calculatedTotalWeight.toString();
  }

  List<String> gsmname = [];
  List<String> gsm = [];
  List<Map<String, dynamic>> suggesstiondata = [];


  Future<void> getgsm() async {
    try {
      final url = Uri.parse('http://localhost:3309/getprodname/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> gsmname = responseData;

        setState(() {
          suggesstiondata = gsmname.cast<Map<String, dynamic>>();
          print('Item Groups: $gsmname');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getitem() async {
    try {
      final url = Uri.parse('http://localhost:3309/getprodname/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> tempgstgsm = responseData;
        final Set<String> uniquegetgsm =
        tempgstgsm.map((item) => item['prodName'] as String).toSet();
        gsm = uniquegetgsm.toList();
        gsm.sort();

        setState(() {
          print('Item Groups: $getgsm');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  Future<String> fetchweight(String prodName) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3309/fetchweightinraw'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prodName': prodName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if 'weight' key is present in the response
        if (data.containsKey('weight')) {
          return data['weight'].toString();
        } else {
          throw Exception('Weight not found in response');
        }
      } else {
        throw Exception('Failed to fetch unit from PO table. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Log the error for debugging purposes
      print('Error in fetchweight: $error');
      throw Exception('Failed to fetch unit from PO table');
    }
  }




  bool validateGSM(String gsm) {
    // Implement your GSM validation logic here
    // For example, check if it matches a certain pattern or condition
    return false; // Return true if GSM is invalid
  }

  List<RowData> rowData = [];

  List<String> itemGroups = [];
  List<String> itemNames = [];
  bool isFirstRowRemovalEnabled = false;
  int selectedCheckbox = 1;

  TextEditingController totalreel=TextEditingController();
  TextEditingController totalwgt=TextEditingController();
  TextEditingController finishreel=TextEditingController();
  TextEditingController finisedwgt=TextEditingController();



  void addRow() {
    setState(() {
      rowData.add(RowData());
    });
  }

  void deleteRow(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this row?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
                setState(() {
                  if (index == 0) {
                    // If it's the first row, clear input values instead of removing it
                    rowData[index].itemGroup = null;
                    // rowData[index].qtyController.text = "";
                  } else {
                    // Remove the row from the list for other rows
                    rowData.removeAt(index);
                  }
                });
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  void updateWeightsController(int index, String finishwightValue) {
    // Get the existing weight value
    String currentWeight = rowData[index].weights.text;

    // Split the finishwightValue into individual values
    List<String> finishWeights = finishwightValue.split(',');

    // Remove each finishwightValue from the current weight value
    for (String finishWeight in finishWeights) {
      currentWeight = currentWeight.replaceAll(finishWeight, '');
    }

    // Update the weights controller with the modified value
    rowData[index].weights.text = currentWeight;
  }

  Future<void> getitemgroup() async {
    try {
      final url = Uri.parse('http://localhost:3309/getitemGroup/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> tempItemGroup = responseData;
        final Set<String> uniqueItemGroups =
        tempItemGroup.map((item) => item['itemGroup'] as String).toSet();
        itemGroups = uniqueItemGroups.toList();
        itemGroups.sort();

        setState(() {
          print('Item Groups: $itemGroups');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getitemname() async {
    try {
      final url = Uri.parse('http://localhost:3309/getitemname/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> tempItemName = responseData;
        final Set<String> uniqueItemNames =
        tempItemName.map((item) => item['itemName'] as String).toSet();
        itemNames = uniqueItemNames.toList();
        itemNames.sort();

        setState(() {
          print('Item Groups: $itemNames');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }





//update without and with printing
  Future<void> updateprodution( String gsm, String numofproduction,String status,String date) async {
    final Uri url = Uri.parse('http://localhost:3309/updateproductiondailywork'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'gsm': gsm,
        'numofcones': numofproduction,
        'status':status,
        'date':date,
      }),
    );
    if (response.statusCode == 200) {
      print('Update winding production successfully');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
      throw Exception('Failed to update');
    }
  }

  //printing update
  Future<void> updatePrintingProduction(String gsm, String numofproduction, String status, String date) async {
    final Uri url = Uri.parse('http://localhost:3309/updateprinting_production');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'gsm': gsm,
        'numofcones': numofproduction,
        'status': status,
        'date': date,
      }),
    );

    if (response.statusCode == 200) {
      print('Printing Update successful');
    } else if (response.statusCode == 400) {
      // Handle the case where the gsm already exists
      print('Failed to update. Status code: ${response.statusCode}. ${response.body}');
    } else {
      // Handle other status codes
      print('Failed to update. Status code: ${response.statusCode}');
    }
  }

  //without printing update
  Future<void> updatewithoupriniting( String gsm, String numofproduction,String status,String date) async {
    final Uri url = Uri.parse('http://localhost:3309/updatewithoutprinting_production'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'gsm': gsm,
        'numofcones': numofproduction,
        'status':status,
        'date':date,
      }),
    );
    if (response.statusCode == 200) {
      print('Printing Update successful');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
      throw Exception('Failed to update');
    }
  }


  //update finishing production
  Future<void> updatefinishingprodution( String qty, String itemGroup,String itemName,String date) async {
    final Uri url = Uri.parse('http://localhost:3309/update_finishing_dailywork'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'qty': qty,
        'itemGroup': itemGroup,
        'itemName':itemName,
        'date':date,
      }),
    );
    if (response.statusCode == 200) {
      print('Update finishing production successfully');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
      throw Exception('Failed to finisghing update');
    }
  }

  //finishing decrese production
  Future<void> updatewithprintingtofinishing( String gsm, String numofproduction,String status,String date) async {
    final Uri url = Uri.parse('http://localhost:3309/updatewithprinting_production'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'gsm': gsm,
        'numofcones': numofproduction,
        'status':status,
        'date':date,
      }),
    );
    if (response.statusCode == 200) {
      print('Printing Update successful');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
      throw Exception('Failed to update');
    }
  }

  Map<String, dynamic> dataToInsertorditem = {};

  bool isDuplicate= false;

  Future<void> insertDataorderitem(Map<String, dynamic> dataToInsertorditem) async {
    const String apiUrl = 'http://localhost:3309/daily_work_status_entry'; // Replace with your server details
    try {
      String machineType = dataToInsertorditem['machineType'];
      String shiftType = dataToInsertorditem['shiftType'];
      String machineName = dataToInsertorditem['machineName'];
      String person1 =dataToInsertorditem['person1'];
      String person2 =dataToInsertorditem['person2'];
      String createDate =dataToInsertorditem['createDate'];
      List<Map<String, dynamic>> unitEntries = await fetchDuplicateEntry();
      bool isDuplicate = unitEntries.any((entry) =>
      entry['machineType'] == machineType &&
          entry['shiftType'] == shiftType &&
          entry['machineName'] == machineName &&
          entry['person1'] == person1 &&
          entry['person2'] == person2 &&
          entry['createDate'] == createDate
      );
      if (isDuplicate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Daily Work Status"),
              content: Text("This Entry Already exists on this date"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>DailyWorkStatus()));
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
        body: jsonEncode({'dataToInsertorditem': dataToInsertorditem}),
      );
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Daily Work Status"),
              content: Text("Saved Succesfully"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>DailyWorkStatus()));
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        print('daily work status data insert successfully');
      } else {
        print('Failed to insert data');
        throw Exception('Failed to insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  DateTime eod = DateTime.now();

  Future<void> submititemDataToDatabase() async {
    List<Future<void>> insertFutures = [];

    for (var i = 0; i < rowData.length; i++) {
      DateTime selectedDateWithoutTime = DateTime(eod.year, eod.month, eod.day);
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(selectedDateWithoutTime);
        print(controller.text);
      });
      Map<String, dynamic> dataToInsertorditem = {
        "machineType": deptType.toString(),
        "shiftType": shiftType.toString(),
        "person1": person1.text,
        "person2": person2.text,
        "person3": person3.text,
        "op_code": person1code.text,
        "ass_code1": person2code.text,
        "ass_code2": person3code.text,
        "machineName": selectedmachinefinishing.toString(),
        "productionQty": productionQuantityController.text,
        "extraproduction": extraproductionamt.text,
        "createDate": DateFormat('yyyy-MM-dd').format(selectedDateWithoutTime),
        "fromDate": fromDate.toString(),
        "toDate": DateTime.now().toString(),
        "gsm": rowData[i].prodgsm,
        "finish_reel": rowData[i].finishreel.text,
        "finish_weight": rowData[i].finishwight.text,
        "num_of_production": rowData[i].numofproduction.text,
      };
      insertFutures.add(insertDataorderitem(dataToInsertorditem));
    }
    for (var i = 0; i < rowData.length; i++) {
      if (isDuplicate==false){
        if (deptType == "Winding" ) {
          await updateprodution(
            rowData[i].prodgsm ?? "",
            rowData[i].numofproduction.text,
            selectedCheckbox == 1 ? "without printing" : "with printing",
            DateTime.now().toString(),
          );
          await updateRawMaterial(
            rowData[i].prodgsm ?? "",
            int.parse(rowData[i].finishreel.text),
            int.parse(rowData[i].finishwight.text),
            DateTime.now().toString(),
          );
        }
        else if (deptType == "Printing")
        {
          await updatePrintingProduction(
            rowData[i].prodgsm ?? "",
            rowData[i].numofproduction.text,
            "with printing",
            DateTime.now().toString(),
          );
          await updatewithoupriniting(
            rowData[i].prodgsm ?? "",
            rowData[i].numofproduction.text,
            "without printing",
            DateTime.now().toString(),
          );
        }
        else if (deptType == "Finishing") {
          await updatefinishingprodution(
            rowData[i].totalqty.text,
            rowData[i].itemGroup ?? "",
            rowData[i].itemName ?? "",
            DateTime.now().toString(),
          );
          await updatewithprintingtofinishing(
            rowData[i].prodgsm ?? "",
            rowData[i].numofproduction.text,
            "with printing",
            DateTime.now().toString(),
          );
        }
      }
    }
    try {
      await Future.wait(insertFutures);
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

/*  Future<void> submititemDataToDatabase() async {
    List<Future<void>> insertFutures = [];

    for (var i = 0; i < rowData.length; i++) {
      DateTime selectedDateWithoutTime = DateTime(eod.year, eod.month, eod.day);
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(selectedDateWithoutTime);
        print(controller.text);
      });
      Map<String, dynamic> dataToInsertorditem = {
        "machineType": deptType.toString(),
        "shiftType": shiftType.toString(),
        "person1": person1.text,
        "person2": person2.text,
        "person3": person3.text,
        "op_code": person1code.text,
        "ass_code1": person2code.text,
        "ass_code2": person3code.text,
        "machineName": selectedmachinefinishing.toString(),
        "productionQty": productionQuantityController.text,
        "extraproduction": extraproductionamt.text,
        "createDate": DateFormat('yyyy-MM-dd').format(selectedDateWithoutTime),
        "fromDate": fromDate.toString(),
        "toDate": DateTime.now().toString(),
        "gsm": rowData[i].prodgsm,
        "finish_reel": rowData[i].finishreel.text,
        "finish_weight": rowData[i].finishwight.text,
        "num_of_production": rowData[i].numofproduction.text,
      };

      insertFutures.add(insertDataorderitem(dataToInsertorditem));

      if (!isDuplicate) {
        if (deptType == "Winding") {
          await updateprodution(
            rowData[i].prodgsm ?? "",
            rowData[i].numofproduction.text,
            selectedCheckbox == 1 ? "without printing" : "with printing",
            DateTime.now().toString(),
          );
          await updateRawMaterial(
            rowData[i].prodgsm ?? "",
            int.parse(rowData[i].finishreel.text),
            int.parse(rowData[i].finishwight.text),
            DateTime.now().toString(),
          );
        } else if (deptType == "Printing") {
          await updatePrintingProduction(
            rowData[i].prodgsm ?? "",
            rowData[i].numofproduction.text,
            "with printing",
            DateTime.now().toString(),
          );
          await updatewithoupriniting(
            rowData[i].prodgsm ?? "",
            rowData[i].numofproduction.text,
            "without printing",
            DateTime.now().toString(),
          );
        } else if (deptType == "Finishing") {
          await updatefinishingprodution(
            rowData[i].totalqty.text,
            rowData[i].itemGroup ?? "",
            rowData[i].itemName ?? "",
            DateTime.now().toString(),
          );
          await updatewithprintingtofinishing(
            rowData[i].prodgsm ?? "",
            rowData[i].numofproduction.text,
            "with printing",
            DateTime.now().toString(),
          );
        }
      }
    }

    try {
      await Future.wait(insertFutures);
      print('All data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }*/




  int totalProductionQuantity = 0;

  ///calculation
  int calculateTotalProduction() {
    int totalProduction = 0;
    for (var row in rowData) {
      if (row.numofproduction.text.isNotEmpty) {
        totalProduction += int.parse(row.numofproduction.text);
      }
    }
    return totalProduction;
  }


// Update the extraproductionamt based on the productionQty and conditions
  void updateExtraProductionAmount() {
    if (productionQuantityController.text.isNotEmpty) {
      int productionQty = int.parse(productionQuantityController.text);

      // Check if the selected machine type is "Winding"
      bool isWindingMachine = deptType == "Winding";

      // Check if the selected machine type is "Finishing"
      bool isFinishingMachine = deptType == "Finishing";

      // Check if the selected machine type is "Printing"
      bool isPrintingMachine = deptType == "Printing";

      // Set visibility based on the conditions for different machine types
      isExtraProductionVisible = (isWindingMachine && productionQty >= 22000) ||
          (isFinishingMachine && productionQty >= 13500) ||
          (isPrintingMachine && productionQty >= 13500);

      // Example calculation for "Winding": 40 + (each 500 above 22000) * 40
      // Example calculation for "Finishing" or "Printing": 20
      int extraProductionAmount = isExtraProductionVisible
          ? (isWindingMachine
          ? (productionQty >= 22000 ? 40 : 0)
          : ((isFinishingMachine || isPrintingMachine) && productionQty >= 13500
          ? 20 + ((productionQty - 13500) ~/ 500) * 20
          : 0))
          : 0;

      extraproductionamt.text = extraProductionAmount.toString();
    } else {
      // Reset extraproductionamt if productionQuantityController is empty
      extraproductionamt.text = '';
    }
  }
  // int? rawQTY=0;
  // int? rawWeight =0;
  int? rawQTY;
  int? rawWeight;

  Future<void> rawMaterialValueGet(String selectedGSM) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/fetch_raw_material'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'gsm': selectedGSM}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print("data of raw material- $data");

      setState(() {
        rawQTY = data['qty'];
        rawWeight = data['totalweight'];
        print("{{{{$rawQTY $rawWeight}}}");
        print("{$rawWeight}");
      });

      // Use the fetched data (rawQTY and rawWeight)
    } else {
      // Handle errors
      print('Error fetching data from server: ${response.statusCode}');
    }
  }


  String? Numofcones;

  Future<void> withoutprintingValueGet(String selectedGSM) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/fetch_without_printing'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'gsm': selectedGSM}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("data of raw material- $data");
      setState(() {
        Numofcones = data['numofcones'];
        print("{{{{$Numofcones}}}");
      });
    } else {
      // Handle errors
      print('Error fetching data from server: ${response.statusCode}');
    }
  }

  String? printednumofcones;

  Future<void> withprintingValueGet(String selectedGSM) async {
    final response = await http.post(
      Uri.parse('http://localhost:3309/fetch_with_printing'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'gsm': selectedGSM}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print("data of raw material- $data");

      setState(() {

        printednumofcones = data['numofcones'];
        print("{{{{$printednumofcones}}}");

      });

      // Use the fetched data (rawQTY and rawWeight)
    } else {
      // Handle errors
      print('Error fetching data from server: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {

    return MyScaffold(
        route: "daily_work_status",backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                    children: [
                      SizedBox(
                        child:  Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            height: 80,
                            width: double.infinity, // Set the width to full page width
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey), // Add a border for the box
                              borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                            ),
                            child: Wrap(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top:15.0),
                                      child: Padding(
                                          padding: EdgeInsets.only(left:15.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.engineering,size: 30,),SizedBox(width: 10,),
                                              Text("Daily Work Status",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                                            ],
                                          )
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15,),
                                      child: Row(children: [
                                        SizedBox(
                                          width: 100,
                                          height: 50,
                                          child: TextFormField(
                                            style: TextStyle(fontSize: 13),
                                            readOnly: true,
                                            onTap: () {
                                              showDatePicker(
                                                context: context,
                                                initialDate: eod,
                                                firstDate: DateTime(2000),
                                                // Set the range of selectable dates
                                                lastDate: DateTime(2100) , //eod,
                                              ).then((date) {
                                                if (date != null) {
                                                  setState(() {
                                                    eod = date; // Update the selected date
                                                    print("$eod: date");
                                                    shiftType=null;
                                                    deptType= null;
                                                    selectedmachinefinishing = null;
                                                    productionQuantityController.clear();
                                                    numofreels.clear();
                                                    kgofreels.clear();
                                                    reelsgsm.clear();
                                                    extraproductionamt.clear();
                                                    person1.clear();
                                                    person1code.clear();
                                                    person2.clear();
                                                    person2code.clear();
                                                    person3.clear();
                                                    person3code.clear();
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
                                              labelText: "Date",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),

                                        ),
                                      ],),
                                    ),
                                    // Text("${person1.text} ${person2.text} ${person3.text} test"),

                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height:10),
                      Container(
                        width: double.infinity, // Set the width to full page width
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.grey), // Add a border for the box
                          borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                        ),
                        child:
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment:MainAxisAlignment.end,
                              children: [
                                Text(errormsg!,style: const TextStyle(color: Colors.red,fontSize: 14),),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Wrap(
                                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Visibility(
                                    visible: deptType == "Winding",
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left:0.0),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                value: selectedCheckbox == 1,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    shiftType=null;
                                                    selectedmachinefinishing = null;
                                                    person1.clear();
                                                    person1code.clear();
                                                    person2.clear();
                                                    person2code.clear();
                                                    person3.clear();
                                                    person3code.clear();
                                                    if (value != null && value) {
                                                      selectedCheckbox = 1;
                                                    } else {
                                                      // Toggle between 1 and 2
                                                      selectedCheckbox = selectedCheckbox == 1 ? 2 : 1;
                                                    }
                                                  });
                                                },
                                              ),
                                              Text("Without Printing"),
                                            ],
                                          ),),
                                        Padding(
                                          padding: const EdgeInsets.only(left:20),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                value: selectedCheckbox == 2,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    shiftType=null;
                                                    selectedmachinefinishing = null;
                                                    person1.clear();
                                                    person1code.clear();
                                                    person2.clear();
                                                    person2code.clear();
                                                    person3.clear();
                                                    person3code.clear();
                                                    if (value != null && value) {
                                                      selectedCheckbox = 2;
                                                    } else {
                                                      // Toggle between 2 and 1
                                                      selectedCheckbox = selectedCheckbox == 2 ? 1 : 2;
                                                    }
                                                  });
                                                },
                                              ),
                                              Text("With Printing"),
                                            ],
                                          ),
                                        ),
                                      ],),
                                  ),
                                  //machineType
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          height:70,
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButtonFormField<String>(
                                              decoration: const InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                contentPadding: EdgeInsets.symmetric(
                                                  vertical: 12.0,
                                                  horizontal: 16.0,
                                                ),
                                                disabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 0.5, color: Colors.white)),
                                              ),
                                              hint: const Text("Machine Type",style: TextStyle(fontSize:13,color: Colors.black),),
                                              isExpanded: true,
                                              value: deptType,
                                              items: <String>['Winding','Printing','Finishing']
                                                  .map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  deptType = newValue!;
                                                  showProductionQuantity();
                                                  filtermachineNameFinish(deptType!);
                                                  selectedmachinefinishing = null;
                                                  if(deptType=="Winding"){
                                                    person1Visible=true;
                                                    person2Visible=true;
                                                    person3Visible=true;
                                                  }
                                                  else if(deptType=="Printing"){
                                                    person1Visible=true;
                                                    person2Visible=true;
                                                    person3Visible=false;
                                                    visibleprinting=false;
                                                  }
                                                  else if(deptType=="Finishing"){
                                                    person1Visible=true;
                                                    person2Visible=true;
                                                    person3Visible=false;
                                                  }
                                                  shiftType =null;
                                                  person1.clear();
                                                  person1code.clear();
                                                  person2.clear();
                                                  person2code.clear();
                                                  person3.clear();
                                                  person3code.clear();
                                                  productionQuantityController.clear();
                                                  numofreels.clear();
                                                  kgofreels.clear();
                                                  reelsgsm.clear();
                                                  extraproductionamt.clear();
                                                  // Set a default value for shiftType
                                                });},),),),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  //shiftType
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if(deptType =="Winding"||deptType ==null)
                                          SizedBox(
                                            width: 200,
                                            height:70,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButtonFormField<String>(
                                                decoration: const InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding: EdgeInsets.symmetric(
                                                    vertical: 12.0,
                                                    horizontal: 16.0,
                                                  ),
                                                  disabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 0.5, color: Colors.white)),
                                                ),
                                                hint: const Text("Shift Type",style: TextStyle(fontSize:13,color: Colors.black),),
                                                isExpanded: true,
                                                value:shiftType,
                                                items: <String>['Morning','Night']
                                                    .map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: const TextStyle(fontSize: 13),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    shiftType = newValue!;
                                                    //  errormsg =null;
                                                    showProductionQuantity();
                                                  });},),),),
                                        if(deptType =="Finishing"|| deptType == "Printing")
                                          SizedBox(
                                            width: 200,
                                            height:70,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButtonFormField<String>(
                                                decoration: const InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding: EdgeInsets.symmetric(
                                                    vertical: 12.0,
                                                    horizontal: 16.0,
                                                  ),
                                                  disabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 0.5, color: Colors.white)),
                                                ),
                                                hint: const Text("Shift Type",style: TextStyle(fontSize:13,color: Colors.black),),
                                                isExpanded: true,
                                                value:shiftType,
                                                items: <String>['General']
                                                    .map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: const TextStyle(fontSize: 13),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    person1.clear();
                                                    person1code.clear();
                                                    person2.clear();
                                                    person2code.clear();
                                                    person3.clear();
                                                    person3code.clear();
                                                    shiftType = newValue!;
                                                    //  errormsg =null;
                                                    showProductionQuantity();
                                                  });},),),),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  //machine name
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ///finish
                                        DropdownButtonHideUnderline(
                                          child: SizedBox(height: 40,width: 200,
                                            child: DropdownButtonFormField<String>(
                                              decoration: const InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white
                                              ),
                                              hint: const Text("Machine Name",style: TextStyle(fontSize:13,color: Colors.black),),
                                              value:selectedmachinefinishing,
                                              items: machiNameFinishing.map((String value) {
                                                return DropdownMenuItem<String>(
                                                  //  enabled: false,
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: const TextStyle(fontSize: 15),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) async {
                                                setState(() {
                                                  person1.clear();
                                                  person1code.clear();
                                                  person2.clear();
                                                  person2code.clear();
                                                  person3.clear();
                                                  person3code.clear();
                                                  selectedmachinefinishing = newValue;
                                                });
                                                // Check for duplicate entry
                                                bool isDuplicate = await checkDuplicateEntry({
                                                  'machineType': deptType,
                                                  'shiftType': shiftType,
                                                  'machineName': selectedmachinefinishing,
                                                  'createDate': DateFormat('yyyy-MM-dd').format(eod),
                                                });

                                                if (isDuplicate) {
                                                  // Show alert for duplicate entry
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text('Duplicate Entry'),
                                                        content: Text('An entry with the same date, machineType, shiftType, and machineName already exists.'),
                                                        actions: <Widget>[
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
                                                } else {
                                                  // No duplicate entry, proceed to fetch data
                                                  fetchData(shiftType.toString(), selectedmachinefinishing.toString(), fromDate);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 200,
                                      height: 70,
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: productionQuantityController,
                                        style: const TextStyle(fontSize: 13),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value.isNotEmpty) {

                                              int productionQty = int.parse(value);

                                              // Check if the selected machine type is "Winding"
                                              bool isWindingMachine = deptType == "Winding";

                                              // Check if the selected machine type is "Finishing"
                                              bool isFinishingMachine = deptType == "Finishing";

                                              // Check if the selected machine type is "Printing"
                                              bool isPrintingMachine = deptType == "Printing";

                                              // Set visibility based on the conditions for different machine types
                                              isExtraProductionVisible = (isWindingMachine && productionQty >= 22000) ||
                                                  (isFinishingMachine && productionQty >= 13500) ||
                                                  (isPrintingMachine && productionQty >= 13500);

                                              // Example calculation for "Winding": 40 + (each 500 above 22000) * 40
                                              // Example calculation for "Finishing" or "Printing": 20
                                              int extraProductionAmount = isExtraProductionVisible
                                                  ? (isWindingMachine
                                                  ? (productionQty >= 22000 ? 40 : 0)
                                                  : ((isFinishingMachine || isPrintingMachine) && productionQty >= 13500
                                                  ? 20 + ((productionQty - 13500) ~/ 500) * 20
                                                  : 0))
                                                  : 0;

                                              errormsg = null;
                                              extraproductionamt.text = extraProductionAmount.toString();
                                            } else {
                                              // Reset visibility and clear the text if Production Qty is empty
                                              isExtraProductionVisible = false;
                                              extraproductionamt.text = '';
                                              errormsg = null;
                                            }
                                          });
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Production Qty",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(5)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      Visibility(
                                        visible:person1Visible,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              //const Text("Persion 1"),
                                              SizedBox(
                                                width: 200,
                                                height: 70,
                                                child: TextFormField(
                                                  readOnly: true,
                                                  style: const TextStyle(fontSize: 13),
                                                  controller: person1,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    labelText: deptType == 'Winding' ? 'Operator' : 'Person 1',
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                              ),                                            ],
                                          ),
                                        ),
                                      ),
                                      //w-p1
                                      const SizedBox(width: 20,),
                                      Visibility(
                                        visible: person2Visible,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              //const Text("Person 2"),
                                              SizedBox(
                                                width: 200,height: 70,
                                                child: TextFormField(readOnly: true,
                                                  style: const TextStyle(fontSize: 13),
                                                  controller: person2,
                                                  onChanged: (value){
                                                    setState(() {
                                                      errormsg =null;
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    labelText: "Person 2",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      //w-p2
                                      const SizedBox(width: 20,),
                                      Visibility(
                                        visible: person3Visible,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              //const Text("Person 2"),
                                              SizedBox(
                                                width: 200,height: 70,
                                                child: TextFormField(readOnly: true,
                                                  style: const TextStyle(fontSize: 13),
                                                  controller: person3,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    labelText: "Person 3",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20,),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            //const Text("Production"),
                                            if (isExtraProductionVisible)
                                            // Display the extra production amount field only when it's visible
                                              SizedBox(
                                                width: 200,
                                                height: 70,
                                                child: TextFormField(
                                                  readOnly: true,
                                                  controller: extraproductionamt,
                                                  style: const TextStyle(fontSize: 13),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      // Handle onChanged for extraproductionamt if needed
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    labelText: "Extra production(₹)",
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      //w-p3
                                    ],
                                  ),

                                ],
                              ),
                            ),

                            const Align(
                                alignment:Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Text("Product Details",
                                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                )),
                            const SizedBox(height: 20,),
                            Visibility(
                              visible: deptType != "Finishing",
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: FocusTraversalGroup(
                                  child: Padding(
                                    padding:  EdgeInsets.only(left: 0),
                                    child: Table(
                                      border: TableBorder.all(color: Colors.black54),
                                      defaultColumnWidth:  FixedColumnWidth(170.0),
                                      columnWidths:  <int, TableColumnWidth>{
                                        0: FixedColumnWidth(250),
                                        if(deptType =="Printing")
                                          1: FixedColumnWidth(0),
                                        if(deptType =="Printing")
                                          2: FixedColumnWidth(0),
                                      },
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children: [
                                        TableRow(children: [
                                          TableCell(
                                            child: Container(
                                              color: Colors.blue.shade100,
                                              child: Center(
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text('GSM', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                          Visibility(
                                            visible: deptType != "Printing",
                                            child: TableCell(
                                              child: Container(
                                                color: Colors.blue.shade100,
                                                child: Center(child: Column(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text('Finished No. \n of Reels', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: deptType != "Printing",
                                            child: TableCell(
                                              child: Container(
                                                color: Colors.blue.shade100,
                                                child: Center(child: Column(
                                                  children: [
                                                    Text('Finished Total \n  Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  ],
                                                )),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Container(
                                              color: Colors.blue.shade100,
                                              child: Center(child: Column(
                                                children: [
                                                  Text('No. of Cones \n Produced', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ],
                                              )),
                                            ),
                                          ),
                                          //action
                                          TableCell(
                                            child: Container(
                                              color: Colors.blue.shade100,
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                        for (var i = 0; i < rowData.length; i++)
                                          TableRow(children: [
                                            //GSM
                                            TableCell(
                                              child: SizedBox(
                                                height: 60,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                  color: Colors.blue.shade100,
                                                  child: Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: TypeAheadFormField<String?>(
                                                          textFieldConfiguration: TextFieldConfiguration(
                                                            onChanged: (value){

                                                            },
                                                            controller: TextEditingController(text: rowData[i].prodgsm),
                                                            decoration: InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                                            ),
                                                            inputFormatters: [CapitalizeInputFormatter()],
                                                          ),
                                                          suggestionsCallback: (pattern) async {
                                                            return suggesstiondata
                                                                .where((item) =>
                                                                (item['prodName']?.toString()?.toLowerCase() ?? '')
                                                                    .startsWith('gsm'))
                                                                .map((item) => item['prodName'].toString())
                                                                .toList();
                                                          },
                                                          itemBuilder: (context, suggestion) {
                                                            return ListTile(
                                                              title: Text(suggestion!),
                                                            );
                                                          },
                                                          onSuggestionSelected: (String? suggestion) async {
                                                            if (gsm.contains(suggestion)) {
                                                              setState(() {
                                                                rowData[i].prodgsm = suggestion;
                                                              });
                                                              rawMaterialValueGet( rowData[i].prodgsm!);
                                                              withoutprintingValueGet( rowData[i].prodgsm!);
                                                              withprintingValueGet( rowData[i].prodgsm!);
                                                              // Log to verify the suggestion and prodName
                                                              print('Selected prodName: $suggestion');
                                                              try {
                                                                // Call the fetchweight function with the selected prodName
                                                                String weight = await fetchweight(suggestion!);

                                                                // Log to verify the retrieved weight
                                                                print('Retrieved weight: $weight');

                                                                // Update the corresponding TextField with the retrieved weight
                                                                setState(() {
                                                                  rowData[i].weights.text = weight;
                                                                });
                                                              } catch (error) {
                                                                // Log any error during weight fetching
                                                                print('Error fetching weight: $error');
                                                              }
                                                            } else {
                                                              // Clear the itemGroup field if the suggestion is not in the itemGroups list
                                                              setState(() {
                                                                rowData[i].itemGroup = null;
                                                              });
                                                              // Show an error message
                                                            }
                                                          }
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),
                                            //TOTAL REELS
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                height: 60,
                                                color: Colors.blue.shade100,
                                                child: Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: TextFormField(
                                                    controller: rowData[i].finishreel,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (value) {
                                                      /*  if (rawQTY! < int.parse(value)) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              title: Text("Invalid Reel"),
                                                              content: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text("Available Reels is $rawQTY, cannot enter $value"),
                                                                  SizedBox(height: 10),
                                                                  Text("Please correct your input."),
                                                                ],
                                                              ),
                                                              actions: <Widget>[
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
                                                        setState(() {
                                                          _formKey.currentState!.reset();
                                                        });
                                                      }*/
                                                      setState(() {
                                                        // rowData[i].quantity = int.tryParse(value) ?? 0;
                                                      });
                                                    },

                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter.digitsOnly,
                                                      LengthLimitingTextInputFormatter(5)
                                                    ],
                                                    decoration: const InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            //FINISHED T REEL
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                height: 60,
                                                color: Colors.blue.shade100,
                                                child: Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: TextFormField(
                                                    controller: rowData[i].finishwight,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        // rowData[i].quantity = int.tryParse(value) ?? 0;
                                                      });
                                                    },
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter.digitsOnly,
                                                      LengthLimitingTextInputFormatter(5)
                                                    ],
                                                    decoration: const InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            //FINISHED T WEIGHT
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                height: 60,
                                                color: Colors.blue.shade100,
                                                child: Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: TextFormField(
                                                    controller: rowData[i].numofproduction,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if(deptType=="Printing")
                                                          if(int.parse(Numofcones!) < int.parse(value)){
                                                            _formKey.currentState!.reset();
                                                            setState(() {
                                                              //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("available Reels is $Numofcones,not enter $value")));
                                                            });
                                                          }
                                                        // Update the productionQuantityController based on the sum of numofproduction for all rows
                                                        int totalProduction = calculateTotalProduction();
                                                        productionQuantityController.text = totalProduction.toString();

                                                        // Update the extraproductionamt based on the productionQty and conditions
                                                        updateExtraProductionAmount();
                                                      });
                                                    },
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter.digitsOnly,
                                                      LengthLimitingTextInputFormatter(5)
                                                    ],
                                                    decoration: const InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            //REMAINING REEL
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Visibility(
                                                      visible: true,
                                                      child: IconButton(
                                                        icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                                                        onPressed: i > 0 ? () => deleteRow(i) : null,
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: i == rowData.length - 1 &&
                                                          rowData[i].prodgsm != null &&
                                                          rowData[i].finishreel != null &&
                                                          rowData[i].finishwight != null &&
                                                          rowData[i].numofproduction.text.isNotEmpty,
                                                      child: IconButton(
                                                        icon: Icon(Icons.add_circle_outline, color: Colors.green),
                                                        onPressed: () {
                                                          if (i > 0 &&
                                                              rowData[i].prodgsm == rowData[i - 1].prodgsm
                                                          ) {
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  title: Text('Alert'),
                                                                  content: Text('Already Exist the Products'),
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
                                                          } else {
                                                            // addRow();
                                                            // serialnumber++;
                                                            if (i == 0) {
                                                              // Enable the first row removal once a second row is added
                                                              setState(() {
                                                                isFirstRowRemovalEnabled = true;
                                                              });
                                                            }
                                                            // Check if the quantity is 0
                                                            if (rowData[i].numofproduction.text == '0' || rowData[i].finishreel.text == '0' || rowData[i].finishwight.text == '0' ) {
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title: Text('Alert'),
                                                                    content: Text('Value cannot be 0'),
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
                                                            else {
                                                              // Quantity is not 0, add the row

                                                              if (i == 0) {
                                                                // Enable the first row removal once a second row is added
                                                                setState(() {
                                                                  isFirstRowRemovalEnabled = true;
                                                                });
                                                              }
                                                              addRow();
                                                            }
                                                          }
                                                        },
                                                      ),


                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ]
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //finishing table
                            SizedBox(height: 20,),
                            Visibility(
                              visible: deptType == "Finishing",
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: FocusTraversalGroup(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Table(
                                      border: TableBorder.all(color: Colors.black54),
                                      defaultColumnWidth: const FixedColumnWidth(150.0),
                                      columnWidths: const <int, TableColumnWidth>{
                                        0: FixedColumnWidth(200),
                                        1: FixedColumnWidth(150),
                                        2: FixedColumnWidth(200),
                                        3: FixedColumnWidth(100),
                                        4: FixedColumnWidth(100),
                                      },
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children: [
                                        TableRow(children: [

                                          TableCell(
                                            child: Container(
                                              color: Colors.blue.shade100,
                                              child: Center(
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text('GSM', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                          TableCell(
                                            child: Container(
                                              color: Colors.blue.shade100,
                                              child: Center(
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 10),
                                                      Text('Item Group', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 10),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                          TableCell(
                                            child: Container(
                                              color: Colors.blue.shade100,
                                              child: Center(child: Column(
                                                children: [
                                                  SizedBox(height: 10),
                                                  Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(height: 10),
                                                ],
                                              )),
                                            ),
                                          ),
                                          TableCell(
                                            child: Container(
                                              color: Colors.blue.shade100,
                                              child: Center(child: Column(
                                                children: [
                                                  Text('No. of Cones \n Produced', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ],
                                              )),
                                            ),
                                          ),
                                          TableCell(
                                            child: Container(
                                              color: Colors.blue.shade100,
                                              child: Center(child: Column(
                                                children: [
                                                  SizedBox(height: 10),
                                                  Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(height: 10),
                                                ],
                                              )),
                                            ),
                                          ),
                                          TableCell(
                                            child: Container(
                                              color: Colors.blue.shade100,
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 10),
                                                    Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    SizedBox(height: 10),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),

                                        for (var i = 0; i < rowData.length; i++)
                                          TableRow(children: [
                                            TableCell(
                                              child: SizedBox(
                                                height: 60,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                  color: Colors.blue.shade100,
                                                  child: Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: TypeAheadFormField<String?>(
                                                          textFieldConfiguration: TextFieldConfiguration(
                                                            onChanged: (value){
                                                            },
                                                            controller: TextEditingController(text: rowData[i].prodgsm),
                                                            decoration: InputDecoration(
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                                            ),
                                                            inputFormatters: [CapitalizeInputFormatter()],
                                                          ),
                                                          suggestionsCallback: (pattern) async {
                                                            return suggesstiondata
                                                                .where((item) =>
                                                                (item['prodName']?.toString()?.toLowerCase() ?? '')
                                                                    .startsWith('gsm'))
                                                                .map((item) => item['prodName'].toString())
                                                                .toList();
                                                          },
                                                          itemBuilder: (context, suggestion) {
                                                            return ListTile(
                                                              title: Text(suggestion!),
                                                            );
                                                          },
                                                          onSuggestionSelected: (String? suggestion) async {
                                                            if (gsm.contains(suggestion)) {
                                                              setState(() {
                                                                rowData[i].prodgsm = suggestion;
                                                              });
                                                              withprintingValueGet( rowData[i].prodgsm!);

                                                              // Log to verify the suggestion and prodName
                                                              print('Selected prodName: $suggestion');

                                                              try {
                                                                // Call the fetchweight function with the selected prodName
                                                                String weight = await fetchweight(suggestion!);

                                                                // Log to verify the retrieved weight
                                                                print('Retrieved weight: $weight');

                                                                // Update the corresponding TextField with the retrieved weight
                                                                setState(() {
                                                                  rowData[i].weights.text = weight;
                                                                });
                                                              } catch (error) {
                                                                // Log any error during weight fetching
                                                                print('Error fetching weight: $error');
                                                              }
                                                            } else {
                                                              setState(() {
                                                                rowData[i].itemGroup = null;
                                                              });
                                                              // Show an error message
                                                            }
                                                          }
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: SizedBox(
                                                height: 60,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                  color: Colors.blue.shade100,
                                                  child: Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: TypeAheadFormField<String?>(
                                                        textFieldConfiguration: TextFieldConfiguration(
                                                          onChanged: (value){
                                                          },
                                                          controller: TextEditingController(text: rowData[i].itemGroup),
                                                          decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                                          ),
                                                          inputFormatters: [CapitalizeInputFormatter()],
                                                        ),
                                                        suggestionsCallback: (pattern) async {
                                                          return itemGroups.where((group) => group.toLowerCase().startsWith(pattern.toLowerCase()));
                                                        },
                                                        itemBuilder: (context, suggestion) {
                                                          return ListTile(
                                                            title: Text(suggestion!),
                                                          );
                                                        },
                                                        onSuggestionSelected: (String? suggestion) async {
                                                          if (itemGroups.contains(suggestion)) {
                                                            setState(() {
                                                              rowData[i].itemGroup = suggestion;
                                                              rowData[i].itemName = null;
                                                            });
                                                          } else {
                                                            // Clear the itemGroup field if the suggestion is not in the itemGroups list
                                                            setState(() {
                                                              rowData[i].itemGroup = null;
                                                            });
                                                            // Show an error messag
                                                          }
                                                        },
                                                      )

                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                  height: 60,
                                                  color: Colors.blue.shade100,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5.0),
                                                    child: TypeAheadFormField<String?>(
                                                      textFieldConfiguration: TextFieldConfiguration(
                                                        controller: TextEditingController(
                                                            text: rowData[i].itemName),
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                                        ),
                                                        inputFormatters: [CapitalizeInputFormatter()],
                                                      ),
                                                      suggestionsCallback: (pattern) async {
                                                        return itemNames.where((name) => name.toLowerCase().startsWith(pattern.toLowerCase()));
                                                      },
                                                      itemBuilder: (context, suggestion) {
                                                        return ListTile(
                                                          title: Text(suggestion!),
                                                        );
                                                      },
                                                      onSuggestionSelected: (String? suggestion) async {
                                                        setState(() {
                                                          print('Selected Item: $suggestion');
                                                          rowData[i].itemName = suggestion;
                                                          rowData[i].numofproduction.text = "";
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                height: 60,
                                                color: Colors.blue.shade100,
                                                child: Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: TextFormField(
                                                    controller: rowData[i].numofproduction,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        // Update the productionQuantityController based on the sum of numofproduction for all rows
                                                        int totalProduction = calculateTotalProduction();
                                                        productionQuantityController.text = totalProduction.toString();

                                                        // Update the extraproductionamt based on the productionQty and conditions
                                                        updateExtraProductionAmount();

                                                        // Convert numofproduction to int
                                                        int numofproductionValue = int.tryParse(value) ?? 0;

                                                        // Calculate totalqty only if numofproduction is a multiple of 500
                                                        int totalQty = numofproductionValue ~/ 500;
                                                        rowData[i].totalqty.text = totalQty.toString();
                                                      });
                                                    },
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter.digitsOnly,
                                                      LengthLimitingTextInputFormatter(5)
                                                    ],
                                                    decoration: const InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                                height: 60,
                                                color: Colors.blue.shade100,
                                                child: Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    controller: rowData[i].totalqty,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        //  rowData[i].quantity = int.tryParse(value) ?? 0;
                                                      });
                                                    },
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter.digitsOnly,
                                                      LengthLimitingTextInputFormatter(5)
                                                    ],
                                                    decoration: const InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Visibility(
                                                      visible: true,
                                                      child: IconButton(
                                                        icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                                                        onPressed: i > 0 ? () => deleteRow(i) : null,
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: i == rowData.length - 1 &&
                                                          rowData[i].prodgsm != null &&
                                                          rowData[i].itemGroup != null &&
                                                          rowData[i].itemName != null &&
                                                          rowData[i].numofproduction != null &&
                                                          rowData[i].totalqty.text.isNotEmpty,
                                                      child: IconButton(
                                                        icon: Icon(Icons.add_circle_outline, color: Colors.green),
                                                        onPressed: () {
                                                          if (i > 0 &&
                                                              rowData[i].prodgsm == rowData[i - 1].prodgsm &&
                                                              rowData[i].itemGroup == rowData[i - 1].itemGroup &&
                                                              rowData[i].itemName == rowData[i - 1].itemName) {
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  title: Text('Alert'),
                                                                  content: Text('Already Exist the Products'),
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
                                                          } else {
                                                            // Check if the quantity is 0
                                                            if (rowData[i].numofproduction.text == '0' && rowData[i].totalqty.text == '0')
                                                            {
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title: Text('Alert'),
                                                                    content: Text('Quantity cannot be 0'),
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
                                                            } else {
                                                              // Quantity is not 0, add the row
                                                              addRow();
                                                              serialnumber++;
                                                              if (i ==  0) {
                                                                // Enable the first row removal once a second row is added
                                                                setState(() {
                                                                  //   isFirstRowRemovalEnabled = true;
                                                                });
                                                              }
                                                            }
                                                          }
                                                        },
                                                      ),


                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ]
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 10,
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Wrap(
                        children: [
                          MaterialButton(
                            color: Colors.green,
                            onPressed: () async {
                              fromDate = date;
                              showProductionQuantity();
                              if (_formKey.currentState!.validate()) {
                                if (deptType == null) {
                                  setState(() {
                                    errormsg = "* Select a Machine Type";
                                  });
                                } else if (shiftType == null) {
                                  setState(() {
                                    errormsg = "* Select a Shift Type";
                                  });
                                }
                                else if (selectedmachinefinishing == null) {
                                  setState(() {
                                    errormsg = "* Select a Machine Name";
                                  });
                                }
                                else if (productionQuantityController.text.isEmpty) {
                                  setState(() {
                                    errormsg = "* Fill All fields in Table";
                                  });
                                }
                                else{
                                  await submititemDataToDatabase();
                                }
                              }
                            },
                            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 15,),
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
                                              MaterialPageRoute(builder: (context) =>const DailyWorkStatus()));// Close the alert box
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
                          const SizedBox(width: 10,),
                          MaterialButton(
                            color: Colors.red.shade600,
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
                                              MaterialPageRoute(builder: (context) => Home()));// Close the alert box
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
                      const SizedBox(height: 20,),
                    ]),
              ),
            ),
          ),
        ) );
  }
}



