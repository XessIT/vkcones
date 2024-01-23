import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import '../home.dart';
import '../main.dart';
import '../purchase/dummy_pretuen.dart';


class ItemGroupPage extends StatefulWidget {
  const ItemGroupPage({Key? key}) : super(key: key);
  @override
  State<ItemGroupPage> createState() => _ItemGroupPageState();
}
class _ItemGroupPageState extends State<ItemGroupPage> {

  @override
  void initState() {
    fetchData();
    getunit();
    getgst();
    saleRate.addListener(() {
      String text = saleRate.text;

      // Allow only digits and a single dot
      text = text.replaceAll(RegExp(r'[^0-9.]'), '');

      // Ensure only one dot is present
      if (text.contains('.') && text.indexOf('.') != text.length - 1) {
        List<String> parts = text.split('.');
        text = '${parts[0]}.${parts[1].substring(0, 2)}'; // Limit to 2 decimal places
      }

      // Update the controller's text with the formatted text
      saleRate.value = saleRate.value.copyWith(
        text: text,
        selection: TextSelection.fromPosition(
          TextPosition(offset: text.length),
        ),
      );
    });
    saleRate.addListener(() {
      String text = saleRate.text;

      // Allow only digits and a single dot
      text = text.replaceAll(RegExp(r'[^0-9.]'), '');

      // Ensure only one dot is present
      if (text.contains('.') && text.indexOf('.') != text.length - 1) {
        List<String> parts = text.split('.');
        text = '${parts[0]}.${parts[1].substring(0, 2)}'; // Limit to 2 decimal places
      }

      // Update the controller's text with the formatted text
      saleRate.value = saleRate.value.copyWith(
        text: text,
        selection: TextSelection.fromPosition(
          TextPosition(offset: text.length),
        ),
      );
    });
  }
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController itemName=TextEditingController();
  TextEditingController itemGroupcontroll =TextEditingController();
  TextEditingController han_sac_code=TextEditingController();
  TextEditingController saleRate=TextEditingController();


  String? errorMessage ;
  Map<String, dynamic> dataToInsert = {};
  Future<void> insertData(Map<String, dynamic> dataToInsert) async {
    final String apiUrl = 'http://localhost:3309/itemcreation'; // Replace with your server details

    // Extract values for checking duplicates
    String itemGroup = dataToInsert['itemGroup'];
    String itemName = dataToInsert['itemName'];
    // Check if there's a duplicate entry in the database
    List<Map<String, dynamic>> unitEntries = await fetchUnitEntries();
    bool isDuplicate = unitEntries.any((entry) =>
    entry['itemGroup'] == itemGroup &&
        entry['itemName'] == itemName );
    if (isDuplicate) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Item"),
            content: Text("This item already exists in the database."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
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

    try {
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
              title: Text("Item"),
              content: Text("Saved successfully."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemGroupPage()));
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
    }
  }

  List<Map<String, dynamic>> data = [];
  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/fetch_item_duplicate/');
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
      // Handle any other errors, e.g., network issues
      print('Error: $error');
    }
  }


  // Future<void> insertData(Map<String, dynamic> dataToInsert) async {
  //   final String apiUrl = 'http://localhost:3309/itemcreation'; // Replace with your server details
  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode({'dataToInsert': dataToInsert}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text("Item"),
  //             content: Text("saved successfully."),
  //             actions: <Widget>[
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                   Navigator.push(context, MaterialPageRoute(builder: (context) => ItemGroupPage()));
  //                 },
  //                 child: Text("OK"),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //       print('Data inserted successfully');
  //     } else {
  //       print('Failed to insert data');
  //       throw Exception('Failed to insert data');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     throw Exception('Error: $e');
  //   }
  // }

  String itemGroupGet="";
  String itemNameGet="";
  /*List<String> size = [];
  String? selectedSize;
  Future<void> getsize() async {
    try {
      final url = Uri.parse('http://localhost:3309/size_entry/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> sizes = responseData;
        size = sizes.map((item) => item['size'] as String).toList();
        size.sort(); // This will sort the list in ascending order.

        setState(() {
          // Print itemGroupValues to check if it's populated correctly.
          print('Sizes: $size');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }*/

  List<String> unit = [];
  String? selectedunit;
  Future<void> getunit() async {
    try {
      final url = Uri.parse('http://localhost:3309/unit_entry/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> units = responseData;
        unit = units.map((item) => item['unit'] as String).toList();
        unit.sort();
        setState(() {
          print('Item Groups: $unit');
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  List<String> gst = [];
  String? selectedgst;
  Future<void> getgst() async {
    try {
      final url = Uri.parse('http://localhost:3309/gst_entry/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> gsts = responseData;
        setState(() {
          gst = gsts.map((item) => item['gst'] as String).toList();
          print('Item Groups: $gst');
        });
        gst.sort();
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  //for report
  Future<List<Map<String, dynamic>>> fetchUnitEntries() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getallitem'));
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

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);}
  //for delete
  Future<void> deleteItem(BuildContext context, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3309/item_delete/$id'),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Item"),
              content: Text("Deleted Successfully"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ItemGroupPage()));
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Error deleting gst: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }
  Future<void> confirmDelete(BuildContext context, int id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteItem(context, id);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      route: "/itempages",
      body:Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
              /*  SizedBox(
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
                                      const Icon(Icons.save_alt, size:30),
                                      const Padding(
                                        padding: EdgeInsets.only(right:0),
                                        child: Text("Item Name creation",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
                                      ),
                                    ]),
                                Text(errorMessage??"",style: TextStyle(color: Colors.red),),
                              ],
                            ),
                            SizedBox(height: 25,),
                            Wrap(
                                children: [

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 220,height: 70,
                                        child: TypeAheadFormField<String>(
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: itemGroupcontroll,
                                            style: const TextStyle(fontSize: 13),
                                            onChanged: (value) {
                                              setState(() {
                                                errorMessage = null; // Reset error message when the user types
                                              });
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              itemGroupcontroll.value =
                                                  itemGroupcontroll.value.copyWith(
                                                    text: capitalizedValue,
                                                    selection: TextSelection.collapsed(
                                                        offset: capitalizedValue
                                                            .length),
                                                  );
                                            },
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              labelText: "Item Group",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          suggestionsCallback: (pattern) async {
                                            List<String> suggestions;
                                            if (pattern.isNotEmpty) {
                                              suggestions = data
                                                  .where((item) =>
                                                  (item['itemGroup']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['itemGroup'].toString())
                                                  .toSet() // Remove duplicates using a Set
                                                  .toList();
                                            } else {
                                              suggestions = [];
                                            }
                                            return suggestions;
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            setState(() {
                                              itemNameGet = suggestion;
                                              itemGroupcontroll.text = suggestion;
                                            });
                                            print('Selected itemName: $itemNameGet');
                                          },
                                        ),
                                      ),


                                    ],
                                  ),
                                  const SizedBox(width: 150,),
                                  // item Name
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 220,height: 70,
                                        child: TypeAheadFormField<String>(
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: itemName,
                                            style: const TextStyle(fontSize: 13),
                                            onChanged: (value) {
                                              setState(() {
                                                errorMessage = null; // Reset error message when the user types
                                              });
                                              String capitalizedValue = capitalizeFirstLetter(value);
                                              itemName.value =
                                                  itemName.value.copyWith(
                                                    text: capitalizedValue,
                                                    selection: TextSelection.collapsed(
                                                        offset: capitalizedValue
                                                            .length),
                                                  );
                                            },
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              labelText: "Item Name",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          suggestionsCallback: (pattern) async {
                                            List<String> suggestions;
                                            if (pattern.isNotEmpty) {
                                              suggestions = data
                                                  .where((item) =>
                                                  (item['itemName']?.toString()?.toLowerCase() ?? '')
                                                      .startsWith(pattern.toLowerCase()))
                                                  .map((item) => item['itemName'].toString())
                                                  .toSet() // Remove duplicates using a Set
                                                  .toList();
                                            } else {
                                              suggestions = [];
                                            }
                                            return suggestions;
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            setState(() {
                                              itemNameGet = suggestion;
                                              itemName.text = suggestion;
                                            });
                                            print('Selected itemName: $itemNameGet');
                                          },
                                        ),
                                      ),

                                    ],
                                  ),
                                  const SizedBox(width: 150,),
                                  SizedBox(
                                    width: 220,height: 70,
                                    child: TextFormField(style: TextStyle(fontSize: 13),
                                      controller: saleRate,
                                      decoration: InputDecoration(
                                        labelText: "Rate per Unit",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      *//* inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10)
                                      ],*//*
                                    ),
                                  ),

                                  //unit

                                  // const SizedBox(width: 55,),
                                  //size
*//*
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        height: 33,
                                        child: Container(
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButtonFormField<String>(
                                              hint: const Text("Size",style:TextStyle(color: Colors.black)),
                                              value: selectedSize, // Use selectedSize to store the selected value
                                              items: size.map((String value) {
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
                                                  selectedSize = newValue; // Update selectedSize when a value is selected
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],),
*//*
                                ]),
                            SizedBox(height: 10,),

                            Wrap(
                              children: [
                                // const SizedBox(width: 45,),

                                //color
*//*
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      height: 33,
                                      child: Container(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButtonFormField<String>(
                                            hint:const Text("Color",style:TextStyle(color: Colors.black)),
                                            value: selectedcolor, // Use selectedSize to store the selected value
                                            items: color.map((String value) {
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
                                                selectedcolor = newValue; // Update selectedSize when a value is selected
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
*//*
                                // const SizedBox(width: 55,),
                                //rate
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    SizedBox(
                                      width: 220,
                                      height: 39,
                                      child: Container(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButtonFormField<String>(
                                            value: selectedunit, // Use selectedSize to store the selected value
                                            items: unit.map((String value) {
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
                                                selectedunit = newValue; // Update selectedSize when a value is selected
                                              });
                                            },
                                            hint:const Text("Unit",style:TextStyle(color: Colors.black)),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 150,),
                                //GST
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 220,
                                      height: 39,
                                      child: Container(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButtonFormField<String>(
                                            hint:const Text("GST(%)",style:TextStyle(color: Colors.black)),
                                            style: TextStyle(color: Colors.black),
                                            value:selectedgst , // Use selectedSize to store the selected value
                                            items: gst.map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(fontSize: 13),),);
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectedgst = newValue; // Update selectedSize when a value is selected
                                              });},),),),)],),
                                const SizedBox(width: 150,),
                                //hscn code
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 220,height: 70,
                                      child: TextFormField(style: const TextStyle(fontSize: 13),
                                        controller: han_sac_code,
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                        ],
                                        decoration: InputDecoration(
                                          labelText: "HSN/SAC Code",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),),),),],),
                              ],),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: MaterialButton(
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                      color: Colors.green.shade600,
                                      onPressed: () async {
                                        if (_formkey.currentState!.validate()) {
                                          if (itemGroupcontroll.text.isEmpty) {
                                            setState(() {
                                              errorMessage =
                                              '* Enter a Item Group';
                                            });
                                          }else if (itemName.text.isEmpty) {
                                            setState(() {
                                              errorMessage =
                                              '* Enter a Item Name';
                                            });
                                          }
                                          else if (saleRate.text.isEmpty) {
                                            setState(() {
                                              errorMessage =
                                              '* Enter a Rate per Unit';
                                            });
                                          }
                                          else if (selectedunit == null) {
                                            setState(() {
                                              errorMessage =
                                              '* Select a Unit';
                                            });
                                          }
                                          *//*  else if (selectedSize == null) {
                                            setState(() {
                                              errorMessage =
                                              '* Select a Size';
                                            });
                                          } else if (selectedcolor == null) {
                                            setState(() {
                                              errorMessage =
                                              '* Select a Color';
                                            });
                                          } *//*
                                          else if (selectedgst == null) {
                                            setState(() {
                                              errorMessage = '* Select a GST';
                                            });
                                          }  else
                                          if (han_sac_code.text.isEmpty) {
                                            setState(() {
                                              errorMessage =
                                              '* Enter a HSN/SAC Code';
                                            });
                                          } else {
                                            final dataToInsert = {
                                              "itemGroup":itemGroupcontroll.text,
                                              'itemName': itemName.text,
                                              'code': han_sac_code.text,
                                              //   'size': selectedSize,
                                              'unit': selectedunit,
                                              //  'color': selectedcolor,
                                              'gst': selectedgst,
                                              'rate': saleRate.text,
                                              "date": DateTime.now().toString()
                                            };
                                            await insertData(dataToInsert);
                                          }

                                        }
                                      }, child: const Text("SAVE",style: TextStyle(color: Colors.white),)),),
                                const SizedBox(width: 10,),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MaterialButton(
                                    color: Colors.blue.shade600,
                                    onPressed:(){
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
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ItemGroupPage()));}

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
                                    child: const Text("RESET", style: TextStyle(color: Colors.white)),),),
                                const SizedBox(width: 10,),
                                MaterialButton(
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
                                                  }

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
                                    }, child: const Text("CANCEL",style: TextStyle(color: Colors.white),)),
                              ],),
                          ]),),),),*/
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SingleChildScrollView(
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: fetchUnitEntries(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }
                              else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(child: Text('No data available.'));}
                              else {
                                snapshot.data!.sort((a, b) {
                                  int groupComparison = a['itemGroup'].compareTo(b['itemGroup']);
                                  if (groupComparison != 0) {
                                    return groupComparison;
                                  } else {
                                    int nameComparison = a['itemName'].compareTo(b['itemName']);
                                    if (nameComparison != 0) {
                                      return nameComparison;
                                    } else {
                                      int nameComparison = a['itemName'].compareTo(b['itemName']);
                                      if (nameComparison != 0) {
                                        return nameComparison;
                                      } else {
                                        return a['itemName'].compareTo(b['itemName']);
                                      }
                                    }
                                  }
                                });
                                return SizedBox(
                                  child: PaginatedDataTable(
                                    columnSpacing: 50,
                                    header: Text('Item Report'),
                                    columns: [
                                      DataColumn(label: Center(child: Text('S.No',style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text('Item Group',style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text('            Item Name',style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text('HSN/SAC Code',style: TextStyle(fontWeight: FontWeight.bold),))),
                                      // DataColumn(label: Center(child: Text('   Size',style: TextStyle(fontWeight: FontWeight.bold),))),
                                      // DataColumn(label: Center(child: Text('   Color',style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text('Pack Size',style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text('  Unit',style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text('Rate/cone',style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text('  GST%',style: TextStyle(fontWeight: FontWeight.bold),))),
                                      DataColumn(label: Center(child: Text('Action',style: TextStyle(fontWeight: FontWeight.bold),))),],
                                    rowsPerPage: 8,
                                    source: _YourDataTableSourceItemName(snapshot.data!,context,deleteItem),
                                  ),);}},),),),),),),
              ],),),),),);
  }
}
class _YourDataTableSourceItemName extends DataTableSource {
  final List<Map<String, dynamic>> _data;

  final BuildContext context;
  final Function(BuildContext, int) _deleteItem;

  _YourDataTableSourceItemName(this._data, this.context,this._deleteItem);
  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) {
      return null;
    }
    final item = _data[index];
    return DataRow(
      cells: [
        DataCell(Center(child: Text("  ${(index + 1).toString()}"))),
        DataCell(Center(child: Text("${item['itemGroup']}".toString()))),
        DataCell(Center(child: Text("${item['itemName']}".toString()))),
        DataCell(Center(child: Text("${item['hsn/sac']}"))),
        DataCell(Center(child: Text("${item['unit']}".toString()))),
         DataCell(Center(child: Text("   ${item['packSize']}"))),
        DataCell(Center(child: Text("   ${item['rate']}".toString()))),
        DataCell(Center(child: Text("   ${item['gst']}".toString()))),
        // DataCell(Center(child: Text("   ${item['code']}".toString()))),
        DataCell(Center(child:  IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Delete'),
                  content: Text('Are you sure you want to delete the item?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Yes'),
                      onPressed: () {
                        _deleteItem(context, item['id']);
                      },
                    ),
                    TextButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),

                  ],
                );
              },
            );
          },
        ),)),
      ],
    );
  }
  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
}


