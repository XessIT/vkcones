import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:vinayaga_project/purchase/product_edit.dart';
import 'package:vinayaga_project/purchase/product_overall_report.dart';
import '../home.dart';
import '../main.dart';
import 'package:intl/intl.dart';



class ProductCodeCreation extends StatefulWidget {
  const ProductCodeCreation({Key? key}) : super(key: key);

  @override
  State<ProductCodeCreation> createState() => _ProductCodeCreationState();
}
class _ProductCodeCreationState extends State<ProductCodeCreation> {







  DateTime date = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  List<String> supplierSuggestions = [];
  String selectedSupplier = "";
  bool isDateRangeValid=true;
  String? ProductUnit;

  int currentPage = 1;
  int rowsPerPage = 10;
  String? errorMessage="";

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
  TextEditingController prodCode = TextEditingController();
  TextEditingController GSM = TextEditingController();
  //TextEditingController productUnit = TextEditingController();
  // TextEditingController purchaseRate = TextEditingController();
  String? productUnit;

  List<String> itemGroupValues = [];
  List<String> invoiceNumber = [];
  bool isNameDuplicate = false;
  TextEditingController prodName =TextEditingController();
  Map<String, dynamic> dataToInsert = {};
  bool isDataSaved = false;
  final FocusNode supNameFocusNode = FocusNode();
  List<Map<String, dynamic>> data = [];




  Map<String, dynamic> dataToInsertProduct = {};
  Future<void> insertDataSup(Map<String, dynamic> dataToInsertProduct) async {
    const String apiUrl = 'http://localhost:3309/productcode_creation'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertProduct': dataToInsertProduct}),
      );
      if (response.statusCode == 200) {
        print('TableData inserted successfully');
      } else {
        print('Failed to Table insert data');
        throw Exception('Failed to Table insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }
  Future<void> supDataToDatabase() async {
    if (isNameDuplicate) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Product name already exists."),
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
      return;
    }
    List<Future<void>> insertFutures = [];
    if (ProdCode.isEmpty) {
      ProdCode = 'PC001';
    }
    Map<String, dynamic> dataToInsertProduct = {
      'date': date.toString(),
      'prodName': prodName.text,
      'prodCode': ProdCode,
      'unit':productUnit.toString(),
      'gsm':GSM.text,
      // "prodRate":purchaseRate.text,
    };
    insertFutures.add(insertDataSup(dataToInsertProduct));
    await Future.wait(insertFutures);
  }
  Future<void> deleteItem(BuildContext context, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3309/product_delete/$id'),
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
  Future<void> fetchData() async {
    try {
      final url = Uri.parse('http://localhost:3309/fetch_productCode/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> itemGroups = responseData;
        Set<String> uniqueCustNames = Set();

        // Filter out duplicate values based on 'custName'
        final List uniqueData = itemGroups
            .where((item) {
          //    String custName =item['checkOrderNo'].isEmpty? item['orderNo']:item['checkOrderNo']?.toString() ?? '';
          String custName = item['prodCode']?.toString() ?? '';
          if (!uniqueCustNames.contains(custName)) {
            uniqueCustNames.add(custName);
            return true;
          }
          return false;
        })
            .toList();
        setState(() {
          data = uniqueData.cast<Map<String, dynamic>>();
          filteredData = List<Map<String, dynamic>>.from(data);



        });


        /*   setState(() {
          filteredData.sort((a, b) {
            DateTime? dateA = DateTime.tryParse(a['date'] ?? '');
            DateTime? dateB = DateTime.tryParse(b['date'] ?? '');
            if (dateA == null || dateB == null) {
              return 0;
            }
            return dateB.compareTo(dateA);
          });
        });*/

        print('Data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  List<Map<String, dynamic>> filteredData = [];

  void applyDateFilter() {
    setState(() {
      if(!isDateRangeValid){
        return;
      }
      filteredData = data.where((item) {
        String dateStr = item['date']?.toString() ?? '';
        DateTime? itemDate = DateTime.tryParse(dateStr);

        if (itemDate != null &&
            !itemDate.isBefore(fromDate!) &&
            !itemDate.isAfter(toDate!.add(Duration(days: 1)))) {
          return true;
        }
        return false;
      }).toList();
      if (searchController.text.isNotEmpty) {
        String searchTextLowerCase = searchController.text.toLowerCase();
        filteredData = filteredData.where((item) {
          String id = item['supName']?.toString()?.toLowerCase() ?? '';
          return id.contains(searchTextLowerCase);
        }).toList();
      }
      filteredData.sort((a, b) {
        DateTime? dateA = DateTime.tryParse(a['date'] ?? '');
        DateTime? dateB = DateTime.tryParse(b['date'] ?? '');
        if (dateA == null || dateB == null) {
          return 0;
        }
        return dateB.compareTo(dateA); // Compare in descending order
      });
    });
  }



  String? getNameFromJsonData(Map<String, dynamic> jsonItem) {
    return jsonItem['prodCode'];
  }
  String ProdCode = '';
  // String? prodCode;
  List<Map<String, dynamic>> ponumdata = [];
  String? PONO;
  List<Map<String, dynamic>> codedata = [];
  String generateId() {
    //DateTime now=DateTime.now();
    // String year=(now.year%100).toString();
    // String month=now.month.toString().padLeft(2,'0');

    if (PONO != null) {
      String ID = PONO!.substring(2);
      int idInt = int.parse(ID) + 1;
      String id = 'PC${idInt.toString().padLeft(3, '0')}';
      print(id);
      return id;
    }
    return "";
  }
  Future<void> ponumfetch() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/get_product_code'));
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
  @override
  void initState() {
    super.initState();
    fetchData();
    ponumfetch();
    /* fetchData1();*/
    supNameFocusNode.requestFocus();
  }
  bool isReelVisible = false;

  @override
  Widget build(BuildContext context) {

    DateTime Date = DateTime.now();
    final formattedDate = DateFormat("dd-MM-yyyy").format(Date);
/*    prodName.addListener(() {
      filterData1(prodName.text);
    });*/
    prodCode.text= generateId();
    /*  if (data.isEmpty) {
      return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),  // Change the color as needed
        strokeWidth: 1,
      );
    }*/
    return MyScaffold(
      route: "product_code_creation",backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(right:8 , left:8),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  SizedBox(
                    //width: 700,
                    child: Container(
                      width: double.infinity, // Set the width to full page width
                      padding: EdgeInsets.all(16.0), // Add padding for spacing
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey), // Add a border for the box
                        borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                      ),
                      child: Wrap(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.edit, size:30),
                                    Text("Product Creation",style: TextStyle(fontSize:23,fontWeight: FontWeight.bold),),
                                  ],
                                ),
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
                  SizedBox(height: 5,),
                  SizedBox(
                    //width: 700,
                    //height: 400,
                    child: Container(
                      width: double.infinity, // Set the width to full page width
                      padding: EdgeInsets.all(16.0), // Add padding for spacing
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.grey), // Add a border for the box
                        borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                      ),
                      child:Padding(
                        padding: const EdgeInsets.only(left:10),
                        child: Wrap(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 13),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Enter Details",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),),

                                  ],
                                ),
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.end,
                                  children:[
                                    Text(
                                      errorMessage ?? '',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ]),
                              SizedBox(height:20),
                              Wrap(
                                spacing: 35,
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 220,
                                    height: 70,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 13),
                                      readOnly: true,
                                      controller: TextEditingController(text: ProdCode.isEmpty ? "PC001" : "PRODUCT CODE : $ProdCode"),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    height: 70,
                                    child: TextFormField(
                                      controller: prodName,
                                      style: TextStyle(fontSize: 13),
                                      onChanged: (value) {
                                        String capitalizedValue = capitalizeFirstLetter(value);
                                        prodName.value = prodName.value.copyWith(
                                          text: capitalizedValue,
                                          selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                        );
                                        setState(() {
                                          errorMessage = null; // Reset error message when user types
                                        });
                                      },
                                      inputFormatters: [
                                        UpperCaseTextFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                        labelText: "Product Name",
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      // Remove the autofocus property
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    height:38,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        value: productUnit,
                                        hint:Text("Product Unit",style:TextStyle(fontSize: 13,color: Colors.black),),
                                        items: <String>['Kg','Litre','Nos','Pack']
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
                                            productUnit = newValue!;
                                          });
                                        },
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
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child:
                    Wrap(
                      children: [
                        MaterialButton(
                          color: Colors.green.shade600,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (prodName.text.isEmpty) {
                                setState(() {
                                  errorMessage = '* Enter a Product Name';
                                });
                              }else if(prodName.text == "0"|| prodName.text=="00"){
                                setState(() {
                                  errorMessage =
                                  '* Enter a Valid Product Name';
                                });
                              }
                              else if(productUnit==null){
                                setState(() {
                                  errorMessage =
                                  '* Select a Product Unit';
                                });
                              }
                              else if (prodName.text.length < 3) {
                                setState(() {
                                  errorMessage = '* Product Name has at least 3 letters';
                                });
                              }
                              else {
                                bool isDuplicate = data.any((item) {
                                  String existingName = item['prodName']
                                      ?.toString() ?? '';
                                  return existingName.toLowerCase() ==
                                      prodName.text.toLowerCase();
                                });
                                if (isDuplicate) {
                                  setState(() {
                                    errorMessage =
                                    'Product name is already Exist';
                                  });
                                }
                                else {
                                  List<Map<String, dynamic>> rowsDataToInsert = [
                                  ];
                                  rowsDataToInsert.add(dataToInsert);
                                  supDataToDatabase();
                                  try {
                                    setState(() {
                                      isDataSaved = true;
                                    });
                                    prodName.clear();
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Product"),
                                          content: const Text(
                                              "Saved Successfully"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProductCodeCreation()));
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
                            }
                            //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProductCodeCreation()));
                          },
                          child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 20,),
                        MaterialButton(
                          color: Colors.blue.shade600,
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>const ProductCodeCreation()));// Close the alert box
                          },
                          child: const Text("RESET",style: TextStyle(color: Colors.white),),),
                        const SizedBox(width: 20,),
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
                  SingleChildScrollView(
                    child: Container(
                      width:double.infinity,
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
                                  child: Text("Product Details",style: TextStyle(fontSize:17,fontWeight: FontWeight.bold),),
                                )),
                            const SizedBox(height: 20,),
                            PaginatedDataTable(
                              columnSpacing:145.0,
                              //  header: const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              rowsPerPage:5,
                              columns:   const [
                                DataColumn(label: Center(child: Text("S.No",style: TextStyle(fontWeight: FontWeight.bold),))),
                                // DataColumn(label: Center(child: Text("    Date",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Product Code",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("         Product Name",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text("Unit",style: TextStyle(fontWeight: FontWeight.bold),))),
                                //  DataColumn(label: Center(child: Text("Purchase\nRate",style: TextStyle(fontWeight: FontWeight.bold),))),
                                DataColumn(label: Center(child: Text(" Action",style: TextStyle(fontWeight: FontWeight.bold),))),
                              ],
                              source: _YourDataTableSource(filteredData,context,generatedButton,onDelete),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          color: Colors.green.shade600,
                          height: 40,
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductOverallReport(
                              customerData : filteredData,
                            )));
                          },child: const Text("Print",style: TextStyle(color: Colors.white),),),
                      ),
                      /*   Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          color: Colors.red.shade600,
                          height: 40,
                          onPressed: (){
                            Navigator.pop(context);
                          },child: const Text("Cancel",style: TextStyle(color: Colors.white),),),
                      ),*/
                    ],
                  )
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
        DataCell(Center(child: Text("${row["prodCode"]}"))),
        DataCell(Center(child: Text("${row["prodName"]}"))),
        DataCell(Center(child: Text("${row["unit"]}"))),
        //   DataCell(Center(child: Text("${row["prodRate"]}"))),
        DataCell(Center(child:
        Row(
          children: [
            IconButton(icon: Icon(Icons.edit,color:Colors. blue,),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>productView(
                id:row["id"],
                prodCode:row["prodCode"],
                prodName:row["prodName"],
                unit:row["unit"],
                //   prodRate:row["prodRate"],

              )));
            },),
            /*IconButton(icon: Icon(Icons.delete,color:Colors. red,),
              onPressed: (){
                showDeleteConfirmationDialog(context, id);
              },),*/
          ],
        ),
        )),

      ],
    );

  }


  void showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          /*title: Text('Confirm'),*/
          content: Text('Are you sure you want to delete this Product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const ProductCodeCreation()));
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
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
