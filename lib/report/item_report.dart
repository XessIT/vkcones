import 'dart:convert';

import 'package:flutter/material.dart';

import '../main.dart';
import 'package:http/http.dart' as http;

class ItemCreationReport extends StatefulWidget {
  const ItemCreationReport({Key? key}) : super(key: key);
  @override
  State<ItemCreationReport> createState() => _ItemCreationReportState();
}
class _ItemCreationReportState extends State<ItemCreationReport> {
  List<Map<String, dynamic>> data = [];
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredData = [];

  bool showInitialData = true;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    searchController;
    fetchData();
   // _searchFocus.requestFocus();
    // filteredData = List.from(data);
  }

  //FocusNode _searchFocus = FocusNode();
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getItem'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          data = jsonData.cast<Map<String, dynamic>>();
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
  void filterData(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredData = data.where((item) {
          final itemName = item['itemName'].toString().toLowerCase();
          // final offerName = item['offerName'].toString().toLowerCase();
          // final validity = item['validity'].toString().toLowerCase();
          // final discount = item['discount'].toString().toLowerCase();
          // final offerType = item['First Name'].toString().toLowerCase();
          // final password = item['id'].toString().toLowerCase();
          return itemName.contains(query.toLowerCase());
          // offerName.contains(query.toLowerCase()) || validity.contains(query.toLowerCase()) ||
          // discount.contains(query.toLowerCase()
          // );
        }).toList();
        showInitialData = false; // Set the flag to false when filtering
      } else {
        // If query is empty, show all data
        filteredData = List.from(data);
        showInitialData = true;
        //showInitialData = true; // Set the flag to true when showing all data
      }
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call filterData with an empty query when the page loads
    if (showInitialData) {
      filterData('');
    }
  }

  Widget build(BuildContext context) {
    searchController.addListener(() {
      filterData(searchController.text);
    });
    if (data.isEmpty) {
      return CircularProgressIndicator(); // Show a loading indicator while data is fetched.
    }
    return MyScaffold(
        route: "item_report",
        body: SingleChildScrollView(
          child: Form(
            child: Center(
              child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text("Item Creation Report", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(right: 800),
                      child: Wrap(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             // const Text("Item Name"),
                              SizedBox(
                                width: 200,height: 70,
                                child: TextFormField(
                                  controller: searchController,
                                  style: TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    labelText: 'Item Name',
                                    hintText: 'Enter Item name',
                                    suffixIcon: Icon(Icons.search),
                                  ),
                                  //focusNode: _searchFocus,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ItemCreationReport()));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=>SalaryCalculation()));
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: _scrollController,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _scrollController,
                              child: Table(
                                  border: TableBorder.all(),
                                  defaultColumnWidth: const FixedColumnWidth(100.0),
                                  columnWidths: const <int, TableColumnWidth>{
                                    0:FixedColumnWidth(90),
                                    1:FixedColumnWidth(50),
                                    2:FixedColumnWidth(120),
                                    7:FixedColumnWidth(100),
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

                                          TableCell(
                                              child:Center(
                                                child: Text('Item Group',),)),

                                          TableCell(
                                              child:Center(
                                                child: Text('Item Name',),)),
                                          TableCell(
                                              child:Center(
                                                child: Text('HSN/SAC Code',
                                                ),)),
                                          TableCell(
                                              child:Center(
                                                child: Text('Size',
                                                ),)),
                                          TableCell(
                                              child:Center(
                                                child: Text('Colour',
                                                ),)),
                                          TableCell(
                                              child:Center(
                                                child: Text('Unit',
                                                ),)),
                                          TableCell(
                                              child:Center(
                                                child: Text('Gst%',
                                                ),)),
                                          TableCell(
                                              child:Center(
                                                child: Text('Sales Rate',
                                                ),)),
                                          TableCell(
                                              child:Center(
                                                child: Text('Action',
                                                ),)),
                                        ]),
                                    // Table row end

                                    //Table row start
                                          for (var i = 0; i < filteredData.length; i++) ...[
                                    TableRow(
                                      // decoration: BoxDecoration(color: Colors.grey[200]),
                                        children: [
                                          // 1 s.no
                                          TableCell(child: Center(child: Column(
                                            children: [
                                              const SizedBox(height: 10,),
                                              Text("${i+1}"),
                                              const SizedBox(height: 10,)
                                            ],
                                          ))),
                                          TableCell(child: Center(child: Column(
                                            children: [
                                              const SizedBox(height: 10,),
                                              Text("${filteredData[i]["itemGroup"]}"),
                                              const SizedBox(height: 10,)
                                            ],
                                          ))),
                                          TableCell(child:Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child:  Text("${filteredData[i]["itemName"]}"),
                                          )
                                          ),
                                          TableCell(child:Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child:  Text("${filteredData[i]["code"]}"),
                                          )
                                          ),
                                          TableCell(child:Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text("${filteredData[i]["size"]}"),
                                          )
                                          ),
                                          TableCell(child:Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child:  Text("${filteredData[i]["unit"]}"),
                                          )
                                          ),
                                          TableCell(child:Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text("${filteredData[i]["color"]}"),
                                          )
                                          ),  TableCell(child:Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child:Text("${filteredData[i]["gst"]}"),
                                          )
                                          ),
                                          TableCell(child:Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text("${filteredData[i]["rate"]}"),
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
                                  ]
                              )
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
