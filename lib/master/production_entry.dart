import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import '../home.dart';

class ProductionEntry extends StatefulWidget {
  const ProductionEntry({Key? key}) : super(key: key);
  @override
  State<ProductionEntry> createState() => _ProductionEntryState();
}
class _ProductionEntryState extends State<ProductionEntry> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TextEditingController qty=TextEditingController();
  TextEditingController roundqty=TextEditingController();
  TextEditingController unitController=TextEditingController();
  TextEditingController itemGroupcontroll=TextEditingController();
  TextEditingController itemNamecontroll=TextEditingController();
  TextEditingController saleorderdate = TextEditingController();
  TextEditingController damgecone = TextEditingController();
  TextEditingController totalcone = TextEditingController();
  List<Map<String, dynamic>> suggesstiondata = [];
  List<Map<String, dynamic>> suggesstiondataitemName = [];
  String selectedInvoiceNo='';

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
  //String? selectedItemGroup;
  List<String> itemGroups = [];


  Future<void> getitem() async {
    try {
      final url = Uri.parse('http://localhost:3309/itemGroups/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;

        setState(() {
          suggesstiondata = itemGroups.cast<Map<String, dynamic>>();
          print('Item Groups: $itemGroups');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // String? selecteditemname;
  List<String> itemNames = [];
  Future<void> getitemname(String itemGroup) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_item_names_by_itemGroup?itemGroup=$itemGroup'); // Fix URL
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;
        /* final Set<String> uniqueItemNames =
        units.map((item) => item['itemName'] as String).toSet();
        itemNames = uniqueItemNames.toList(); // Convert back to List
        itemNames.sort();*/
        setState(() {
          suggesstiondataitemName = units.cast<Map<String, dynamic>>();
          print('Item Groups: $itemGroups');
        });
        print('Sorted Item Names: $itemNames');
        setState(() {
          print('Item Names: $itemNames');
          setState(() {
          });
          //    selecteditemname = null;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  List<String> units = [];
  String? selectedunit;
  int callUnit =0;
  Future<void> filterUnitData(String itemGroup, String itemName) async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_unit_by_iG_iN?itemGroup=$itemGroup&itemName=$itemName');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final unit = responseData['unit'];
        print('Unit in filterUnitData: $unit');
        callUnit = unit;
        setState(() {
          print('CallUnit: $callUnit');
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  String? errormessage;
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
        machineName.sort();
        setState(() {
          print('Sizes: $machineName');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  List<String> machiNameFinishing =[];
  Future<void> filtermachineNameFinish(String machineType) async {
    try {
      final url = Uri.parse(
          'http://localhost:3309/get_machinename_finishing?machineType=$machineType');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;
        final Set<String> uniqueItemGroups =
        units.map((item) => item['machineName'] as String).toSet();
        machiNameFinishing=uniqueItemGroups.toList();
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


  Future<bool> checkForDuplicate(String itemGroup, String itemName) async {
    List<dynamic> sizeData = await fetchStock();
    for (var item in sizeData) {
      if (item['itemGroup'] == itemGroup &&
          item['itemName'] == itemName){
        return true;
      }
    }
    return false;
  }

  Future<bool> checkForDuplicateProduction(String itemGroup, String itemName,String machineName, String date) async {
    List<dynamic> sizeData = await fetchProduction();
    for (var item in sizeData) {
      if (item['machineName'] == machineName &&
          item['itemGroup'] == itemGroup &&
          item['itemName'] == itemName &&
          item['date'] == date){
        return true;
      }
    }
    return false;
  }

  Future<void> updateqtyinProduction(String machineName,String itemGroup, String itemName,int totalconesIncrement,int qtyIncrement,String date) async {
    final String url = 'http://localhost:3309/dummy_production_qty_increament/update/$machineName/$itemGroup/$itemName/$date';
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, dynamic> body = {
      'qtyIncrement': qtyIncrement.toString(),
      'totalconesIncrement': qtyIncrement.toString(),
    };
    try {
      final http.Response response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        print('Production updated successfully');
      } else {
        print('Failed to update production. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating production: $e');
    }
  }

  Future<void> updateStock(String itemGroup, String itemName,int qtyIncrement,int totalconesIncrement) async {
    final String url = 'http://localhost:3309/stock/update/$itemGroup/$itemName';
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, dynamic> body = {
      'qtyIncrement': qtyIncrement.toString(),
      'totalconesIncrement': totalconesIncrement.toString(),// Convert qtyIncrement to String
    };
    try {
      final http.Response response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        print('Production updated successfully');
      } else {
        print('Failed to update production. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating production: $e');
    }
  }


  Future<List<Map<String, dynamic>>> fetchStock() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/stock_get_report'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }
  Future<List<Map<String, dynamic>>> fetchProduction() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/production_entry_get_report'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/production_entry_get_report'));
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
  //production insert
  Map<String, dynamic> dataToInsert = {};
  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    const String apiUrl = 'http://localhost:3309/production_entry';
    try {
      String machineName = dataToInsert['machineName'];
      String itemGroup = dataToInsert['itemGroup'];
      String itemName = dataToInsert['itemName'];
      String date =dataToInsert['date'];
      List<Map<String, dynamic>> unitEntries = await fetchUnitEntries();
      bool isDuplicate = unitEntries.any((entry) =>
      entry['machineName'] == machineName &&
          entry['itemGroup'] == itemGroup &&
          entry['itemName'] == itemName &&
          entry['date'] == date
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
                    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                    // updateqtyinProduction(selectedmachine.toString(), itemGroupcontroll.text, itemNamecontroll.text, int.parse(roundqty.text),int.parse(qty.text), formattedDate);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductionEntry()));
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
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Production"),
              content: Text("Saved successfully"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductionEntry()));
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        print('Data inserted successfully');
      } else {
        print('Failed to insert data');
        throw Exception('Failed to insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }}

  //stock insert
  Map<String, dynamic> dataToInsert2 = {};
  Future<void> insertData2(Map<String, dynamic> dataToInsert2) async {
    final String apiUrl = 'http://localhost:3309/stock_insert';
    String itemGroup = dataToInsert2['itemGroup'];
    String itemName = dataToInsert2['itemName'];
    int unit = callUnit;
    dataToInsert2['unit'] = unit;

    print('Checking for duplicates: itemGroup: $itemGroup, itemName: $itemName');

    List<Map<String, dynamic>> unitEntries = await fetchStock();
    bool isDuplicate = unitEntries.any((entry) =>
    entry['itemGroup'] == itemGroup &&
        entry['itemName'] == itemName
    );
    if (isDuplicate) {
      print('Duplicate entry, not inserted');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsert2': dataToInsert2}),
      );
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  String machineType ="Finishing";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getmachine();
    getitem();
    filtermachineNameFinish(machineType);
    saleorderdate.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    damgecone.addListener(updateQuantity);
  }
  String saleorderDate = ''; // Initialize with an empty string or handle nullability accordingly
  String selectedMachine = ''; // Initialize with an empty string or handle nullability accordingly
  String itemGroup = ''; // Initialize with an empty string or handle nullability accordingly
  String itemName = ''; // Initialize with an empty string or handle nullability accordingly




  void updateQuantity() {
    int totalCone = int.tryParse(totalcone.text) ?? 0;
    int damageCone = int.tryParse(damgecone.text) ?? 0;
    int quantity = totalCone - damageCone;

    // Update the qtyController text with the calculated quantity
    qty.text = quantity.toString();

    // Calculate the number of units each equivalent to 500 cones
    int units = quantity ~/ 500;

    // Update the roundqty controller text
    roundqty.text = units.toString();
  }





  Future<double> fetchProductionQuantity(String createDate, String machineName, String itemGroup, String itemName) async {
    try {
      final url = Uri.parse('http://localhost:3309/get_production_quantity?createDate=$createDate&machineName=$machineName&itemGroup=$itemGroup&itemName=$itemName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        double productionQty = double.tryParse(responseData['productionQty'].toString()) ?? 0.0;
        setState(() {
          totalcone.text = productionQty.toString();
        });
        return productionQty;
      } else {
        print('Error fetching production quantity: ${response.statusCode}');
        return 0.0;
      }
    } catch (error) {
      print('Error fetching production quantity: $error');
      return 0.0;
    }
  }


  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "production_entry",backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child:  SingleChildScrollView(
            child: Center(
              child: Column(
                  children: [
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
                                    const Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.edit_note, size:30),
                                          Padding(
                                            padding: EdgeInsets.only(right:0),
                                            child: Text("Production Entry",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold),),
                                          ),
                                        ]),
                                    SizedBox(
                                      width: 140,
                                      child: TextFormField(style: TextStyle(fontSize: 13),
                                        readOnly: true, // Set the field as read-only
                                        onTap: () async {
                                          DateTime? pickDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(
                                                1900),
                                            lastDate: DateTime.now(),
                                          );
                                          if (pickDate == null)
                                            return;
                                          {
                                            setState(() {
                                              saleorderdate.text =
                                                  DateFormat(
                                                      'dd-MM-yyyy')
                                                      .format(
                                                      pickDate);
                                              errormessage=null;
                                            });
                                          }
                                        },
                                        controller: saleorderdate, // Set the initial value of the field to the selected date
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText: "Date",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                            borderRadius: BorderRadius.circular(10.0),),
                          child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(errormessage??"",style: TextStyle(color: Colors.red)),],),
                                SizedBox(height: 30,),
                                Wrap(
                                    spacing: 10,
                                    children: [
                                      //machine name
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            DropdownButtonHideUnderline(
                                              child: SizedBox(height: 40,width: 200,
                                                child: DropdownButtonFormField<String>(
                                                  decoration: const InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white
                                                  ),
                                                  hint: const Text("Machine Name",style: TextStyle(fontSize:13,color: Colors.black),),
                                                  value:selectedmachine,
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
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      selectedmachine = newValue;
                                                      //    errormsg =null;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //Item Group
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              height: 50,
                                              child: TypeAheadFormField<String>(
                                                textFieldConfiguration: TextFieldConfiguration(
                                                  controller: itemGroupcontroll,
                                                  decoration: InputDecoration(
                                                    fillColor: Colors.white,
                                                    filled: true,
                                                    labelText: "Item Group",
                                                    labelStyle: TextStyle(fontSize: 13),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                                suggestionsCallback: (pattern) async {
                                                  return suggesstiondata
                                                      .where((item) =>
                                                      (item['itemGroup']?.toString()?.toLowerCase() ?? '')
                                                          .startsWith(pattern.toLowerCase()))
                                                      .map((item) => item['itemGroup'].toString())
                                                      .toList();
                                                },
                                                itemBuilder: (context, suggestion) {
                                                  return ListTile(
                                                    title: Text(suggestion),
                                                  );
                                                },
                                                onSuggestionSelected: (suggestion) async {
                                                  setState(() {
                                                    itemGroupcontroll.text = suggestion;
                                                    getitemname(itemGroupcontroll.text);
                                                  });
                                                  print('Selected Item Group: $suggestion');
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //Item Name
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              height: 50,
                                              child: TypeAheadFormField<String>(
                                                textFieldConfiguration: TextFieldConfiguration(
                                                  controller: itemNamecontroll,
                                                  decoration: InputDecoration(
                                                    fillColor: Colors.white,
                                                    filled: true,
                                                    labelText: "Item Name",
                                                    labelStyle: TextStyle(fontSize: 13),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                                suggestionsCallback: (pattern) async {
                                                  return suggesstiondataitemName
                                                      .where((item) =>
                                                      (item['itemName']?.toString()?.toLowerCase() ?? '')
                                                          .startsWith(pattern.toLowerCase()))
                                                      .map((item) => item['itemName'].toString())
                                                      .toList();
                                                },
                                                itemBuilder: (context, suggestion) {
                                                  return ListTile(
                                                    title: Text(suggestion),
                                                  );
                                                },
                                                onSuggestionSelected: (suggestion) async {
                                                  setState(() {
                                                    itemNamecontroll.text = suggestion;
                                                  });
                                                  // Call fetchProductionQuantity with the selected criteria
                                                },
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 200, height: 70,
                                              child: TextFormField(
                                                controller: totalcone,
                                                onChanged: (value){
                                                  qty.clear();
                                                },
                                                style: const TextStyle(fontSize: 13),
                                                keyboardType: TextInputType.number,
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter.digitsOnly,
                                                  LengthLimitingTextInputFormatter(6)
                                                ],
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  labelText: "Total Cones",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 200, height: 70,
                                            child: TextFormField(
                                              controller: damgecone,
                                              style: const TextStyle(fontSize: 13),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.digitsOnly,
                                                LengthLimitingTextInputFormatter(5)
                                              ],
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "Damage",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 200, height: 70,
                                            child: TextFormField(
                                              readOnly: true,
                                              controller: qty,
                                              onChanged: (value){
                                                updateQuantity();
                                              },
                                              style: const TextStyle(fontSize: 13),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.digitsOnly,
                                                LengthLimitingTextInputFormatter(6)
                                              ],
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "Quantity",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 200, height: 70,
                                            child: TextFormField(
                                              readOnly: true,
                                              controller: roundqty,
                                              style: const TextStyle(fontSize: 13),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.digitsOnly,
                                                LengthLimitingTextInputFormatter(4)
                                              ],
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "Pack",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: SizedBox(
                                          width: 200, height: 70,
                                          child: const Text("")),
                                    ),
                                  ],),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child:
                                  Wrap(
                                    children: [
                                      MaterialButton(
                                        color: Colors.green.shade600,
                                        onPressed: () async {
                                          if(_formKey.currentState!.validate()){
                                            if(selectedmachine == null){
                                              setState(() {
                                                errormessage = "* Select a Machine name";
                                              });
                                            }
                                            else if(itemGroupcontroll.text.isEmpty){
                                              setState(() {
                                                errormessage = "* Select a Item Group";
                                              });
                                            }
                                            else if(itemNamecontroll.text.isEmpty){
                                              setState(() {
                                                errormessage = "* Select a Item Name";
                                              });
                                            }
                                            else if(qty.text =="0"||qty.text=="00"||qty.text=="000"||qty.text=="0000"||qty.text=="00000"||qty.text=="000000"||qty.text=="0000000"||qty.text=="00000000"){
                                              setState(() {
                                                errormessage = "* Enter a valid Quantity";
                                              });
                                            }
                                            else if(qty.text.isEmpty){
                                              setState(() {
                                                errormessage = "* Enter a Quantity";
                                              });
                                            }
                                            else{
                                              final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                                              final dataToInsert = {
                                                'date':formattedDate,
                                                'machineName':selectedmachine,
                                                'itemGroup':itemGroupcontroll.text,
                                                'itemName':itemNamecontroll.text,
                                                'qty':qty.text.trim(),
                                                'num_of_cones':totalcone.text,
                                                'damage':damgecone.text,
                                                'createDate':DateTime.now().toString(),
                                              };
                                              insertData(dataToInsert);//p
                                              insertData2(dataToInsert2);//s
                                              bool isDuplicate = await checkForDuplicate(itemGroupcontroll.text!, itemNamecontroll.text!,);
                                              bool isDuplicateProduction = await checkForDuplicateProduction(itemGroupcontroll.text!, itemNamecontroll.text!, selectedmachine.toString(), selectedDate.toString());
                                              if(isDuplicateProduction){
                                                // updateqtyinProduction(selectedmachine.toString(), itemGroupcontroll.text, itemNamecontroll.text,int.parse(roundqty.text),int.parse(qty.text),selectedDate.toString());
                                              }
                                              if (isDuplicate) {
                                                //updateStock(itemGroupcontroll.text!, itemNamecontroll.text!, int.parse(roundqty.text), int.parse(qty.text));
                                              }else {
                                                final dataToInsert2 = {
                                                  'date':selectedDate.toString(),
                                                  'itemGroup': itemGroupcontroll.text,
                                                  'itemName': itemNamecontroll.text,
                                                  'unit':callUnit,
                                                  'qty': roundqty.text,
                                                  'num_of_cones': qty.text,
                                                };
                                                insertData2(dataToInsert2); //s
                                              }
                                            }}
                                        },child: Text("SAVE",style: TextStyle(color: Colors.white),),),
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
                                                          MaterialPageRoute(builder: (context) =>const ProductionEntry()));// Close the alert box
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
                                ),
                              ]
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
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase() ?? '', // Convert to uppercase
      selection: newValue.selection,
    );
  }
}


