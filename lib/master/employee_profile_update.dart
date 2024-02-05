import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:vinayaga_project/main.dart';
import '../home.dart';
import '../purchase/dummy_pretuen.dart';
import 'package:image_picker/image_picker.dart';

import 'Image.dart';

class EmployeeProfileUpdate extends StatefulWidget {
  const EmployeeProfileUpdate({Key? key}) : super(key: key);

  @override
  State<EmployeeProfileUpdate> createState() => _EmployeeProfileUpdateState();
}

class _EmployeeProfileUpdateState extends State<EmployeeProfileUpdate> {
  DateTime selectedDate = DateTime.now();
  TextEditingController empId = TextEditingController();
  TextEditingController empName = TextEditingController();
  TextEditingController empAddress = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController empMobile = TextEditingController();
  TextEditingController spouseMobile = TextEditingController();
  TextEditingController fatherMobile = TextEditingController();
  TextEditingController spouseName = TextEditingController();
  TextEditingController fatherName = TextEditingController();
  TextEditingController empPhoto = TextEditingController();
  TextEditingController education = TextEditingController();
  TextEditingController depName = TextEditingController();
  TextEditingController empPosition = TextEditingController();
  TextEditingController acHoldername = TextEditingController();
  TextEditingController acNumber = TextEditingController();
  TextEditingController ifsc = TextEditingController();
  TextEditingController pan = TextEditingController();
  TextEditingController bank = TextEditingController();
  TextEditingController branch = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController aadhar = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController daySalary = TextEditingController();
  // TextEditingController doj = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> supplierSuggestions = [];
  String? selectedCustomer="";
  String errorMessage ="";
  String previousEmpId = "";
  String previousEmpname = "";
  String? selectedSupplier="";
  DateTime date = DateTime.now();

  void clearEmployeeDetails() {
    setState(() {
      fatherName.text = "";
      fatherMobile.text = "";
      depName.text = "";
      branch.text = "";
      pan.text = "";
      bank.text = "";
      acNumber.text = "";
      acHoldername.text = "";
      ifsc.text = "";
      education.text = "";
      aadhar.text = "";
      pan.text = "";
      shifttype = "Shift Type";
      empName.text = "";
      empAddress.text = "";
      pincode.text = "";
      empMobile.text = "";
      // dateofbirth.text="";
      // agecontroller.text ="";
      // dateofJoin.text="";
      // dateofEnding.text="";
      bloodGroup = "Blood Group";
      gender = "Gender";
      maritalstatus = "Marital Status";
      salary = "Salary Type";
      empposition = "Employee Position";
      spouseName.text = "";
      spouseMobile.text = "";
      empPhoto.text = "";
      daySalary.text="";
    });
  }

/*  void clearEmployeeDetails() {
    setState(() {
      fatherName.text = "";
      fatherMobile.text = "";
      shifttype = "Shift Type";
      empName.text = "";
      empAddress.text = "";
      empMobile.text = "";
      bloodGroup = "Blood Group";
      gender = "Gender";
      maritalstatus = "Marital Status";
      salary = "Salary Type";
      empposition = "Employee Position";
      spouseName.text = "";
      spouseMobile.text = "";
    });
  }*/

  TextEditingController _textController = TextEditingController();

  // DateTime? dOB;
  bool dateSelected = false;
  DateTime? eod; // Declare eod as DateTime?
  DateTime dOB = DateTime.now();
  DateTime dOJ = DateTime.now();
  //DateTime eod = DateTime.now();
  bool gendererrormsg = true;
  bool salaryerrormsg = true;
  bool maritalstatuserrormsg = true;
  bool shifttypegrouperrormsg = true;
  bool emppositionerrormsg = true;
  String? gender;
  String? bloodGroup;
  String? shifttype;
  String? salary;
  String? maritalstatus;
  String? empposition;
  int agevalue = 0;
  String? _imageUrl = "photo/6b969e80f3ff11e9afc7acde48001122/67.jpg";

  RegExp nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
  RegExp panRegExp = RegExp("[A-Z]{5}[0-9]{4}[A-Z]{1}");
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Future<void> updateEmployee(String emp_code, String first_name, String empMobile, String empAddress, String pincode, String gender,String dob, String age,String bloodgroup,String maritalStatus,String spouseName,String spouseMobile,String empPhoto,String education,String aadhar,String doj,String endingDate,String empPosition,String deptName,String shift,String salary,String acNumber,String acHoldername,String branch,String ifsc,String pan,String bank,String fatherName, String fatherMobile,String dailySalary,String date,String status) async {
    final response = await http.put(
      Uri.parse('http://localhost:3309/employee/update/$emp_code'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'first_name': first_name,
        'empMobile': empMobile,
        'empAddress': empAddress,
        'pincode': pincode,
        'fatherName':fatherName,
        'fatherMobile':fatherMobile,
        'Status':status,
        'dob':dob,
        'age':age,
        'gender':gender,
        'bloodgroup':bloodgroup,
        'maritalStatus':maritalStatus,
        'spouseName':spouseName,
        'spouseMobile':spouseMobile,
        'empPhoto':empPhoto,
        'education':education,
        'aadhar':aadhar,
        'doj':doj,
        'endingDate':endingDate,
        'empPosition':empPosition,
        'deptName':deptName,
        'shift':shift,
        'salaryType':salary,
        'acNumber':acNumber,
        'acHoldername':acHoldername,
        'ifsc':ifsc,
        'branch':branch,
        'pan':pan,
        'bank':bank,
        'salary':dailySalary,
        'modifyDate':date,
      }),
    );
    if (response.statusCode == 200) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Employee"),
            content: Text("Updated Successfully."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeProfileUpdate()));
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      print('Employee updated successfully');
    } else {
      throw Exception('Failed to update employee');
    }
  }

  List<Map<String, dynamic>> data4 = [];
  List<Map<String, dynamic>> filteredData = [];





  void initState() {
    super.initState();
    fetchData5();
    fetchData6();
    clearEmployeeDetails();
    fetchEmployeeDetailsbyname(empId.text);
  }




  Future<void> fetchData5() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getemployee'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          data5 = jsonData.cast<Map<String, dynamic>>();
          if (data5.isNotEmpty) {
            Map<String, dynamic> firstItem = data5.first;
            _imageUrl = firstItem['photo']?.toString() ?? '';
          }
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
  List<Map<String, dynamic>> data5 = [];
  List<Map<String, dynamic>> filteredData5 = [];
  void filterData5(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData5 = data5;
        empId.clear();
        empName.clear();
        filteredData5 = data5;
      } else {
        filteredData5 = data5.where((item) {
          String id = item['first_name']?.toString()?.toLowerCase() ?? '';
          return id == searchText.toLowerCase();
        }).toList();
        if (filteredData5.isNotEmpty) {
          Map<String, dynamic> order = filteredData5.first;
          empId.text = order['emp_code']?.toString() ?? '';
          empName.text = order['first_name']?.toString() ?? '';
          _imageUrl=order['photo']?.toString() ?? '';
        } else {
          empId.clear();
          empName.clear();
        }
        print("_imageUrl: $_imageUrl");
      }
    });
  }

  void _pickImage(ImageSource source) {
    // Implement your image picking logic here
    // For example, you can use plugins like image_picker to handle image selection
  }


  //getemployeeName
  void fetchEmployeeDetailsbyname(String empId) async {
    if (empId.isEmpty) {
      clearEmployeeDetails();
      return;
    }
    final response = await http.get(Uri.parse('http://localhost:3309/employeebyname/$empId'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      print("Data received: $data");
      setState(() {
        empName.text = data['first_name'];
        empAddress.text = data['empAddress'] ?? "";
        pincode.text = data['pincode'] ?? "";
        empMobile.text = data['empMobile'] ?? "";
        dOB = DateTime.parse(data['dob']);
        fatherName.text= data['fatherName']??"";
        fatherMobile.text = data["fatherMobile"]??"";
        depName.text= data["deptName"]??"";
        branch.text = data["branch"]??"";
        pan.text = data["pan"]??"";
        bank.text = data["bank"]??"";
        acNumber.text = data["acNumber"]??"";
        acHoldername.text = data["acHoldername"].toString();
        ifsc.text = data["ifsc"]??"";
        education.text = data["education"]??"";
        aadhar.text = data["aadhar"]??"";
        pan.text =data["pan"]??"";
        shifttype= data["shift"]??"";
        if (!["Shift Type","General", "Morning", "Night"].contains(shifttype)) {
          shifttype = "Shift Type";
        }
      });
      empName.text = data['first_name'];
      empAddress.text = data['empAddress']??"";
      pincode.text = data['pincode']??"";
      empMobile.text = data['empMobile']??"";
      dOB = DateTime.parse(data['dob']);
      DateTime dob = DateTime.parse(data['dob']);
      dOJ = DateTime.parse(data['doj']);
      eod = DateTime.parse(data['endingDate']);
      bloodGroup = data['bloodgroup'];
      gender= data['gender']??"";
      maritalstatus = data["maritalStatus"]??"";
      salary = data["salary"]??"";
      empposition= data["empPosition"]??"";
      spouseName.text = data["spouseName"]??"";
      spouseMobile.text = data["spouseMobile"]??"";
      empPhoto.text = data["empPhoto"]??"";
      eod= data["endingDate"];
      // setState(() {
      //   if(dOB==DateTime.now())
      //     dOB =   dOB != DateTime.now() ?  DateTime.parse(data['dob']) : "";
      // });
    } else {
      print("its not empId");
    }
  }



  Map<String, dynamic> dataToInsertcustomer = {};

  Future<void> insertDatacustomer(Map<String, dynamic> dataToInsertcustomer) async {
    const String apiUrl = 'http://localhost:3309/employee_entry'; // Replace with your server details
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'dataToInsertcustomer': dataToInsertcustomer}),
      );
      if (response.statusCode == 200) {
        print('TableData inserted successfully');
        showSuccessDialog();
      } else {
        print('Failed to Table insert data');
        throw Exception('Failed to Table insert data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context, // Make sure to have access to the BuildContext
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Employee'),
          content: Text('Save Successfully'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                empId.clear();
                empName.clear();
                Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeProfileUpdate()));
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> customerDataToDatabase() async {
    List<Future<void>> insertFutures = [];
    if(dOB==DateTime.now()){
      setState(() {

      });
    }
    Map<String, dynamic> dataToInsertcustomer = {
      "date":date.toString(),
      "emp_code":empId.text,
      "first_name":empName.text,
      "fatherName":fatherName.text?? "",
      "fatherMobile": fatherMobile.text.isNotEmpty ? int.parse(fatherMobile.text) : null, // Convert to int if not empty
      "empAddress":empAddress.text,
      "pincode":pincode.text,
      "empMobile":empMobile.text,
      "gender":gender,
      "dob": dOB != DateTime.now() ? DateFormat('yyyy-MM-dd').format(dOB) : "",
      // "dob":dOB,
      "age":agevalue,
      "bloodgroup":bloodGroup,
      "maritalStatus":maritalstatus,
      "spouseName":spouseName.text,
      "spouseMobile":spouseMobile.text,
      "empPhoto":_imageUrl,
      "education":education.text,
      "aadhar":aadhar.text,
      "doj": dOJ != null ? DateFormat('yyyy-MM-dd').format(dOJ) : null,
      // "endingDate": eod != null ? DateFormat('yyyy-MM-dd').format(eod) : null,
      //  "endingDate":eod,
      "empPosition":empposition,
      "deptName":depName.text,
      "shift":shifttype,
      "salaryType":salary,
      "salary":daySalary.text,
      "acNumber":acNumber.text,
      "acHoldername":acHoldername.text,
      "branch":branch.text,
      "ifsc":ifsc.text,
      "pan":pan.text,
      "bank":bank.text,
    };
    insertFutures.add(insertDatacustomer(dataToInsertcustomer));
    await Future.wait(insertFutures);
  }


  bool isnonOrderNumExists(String name) {
    return data6.any((item) => item['emp_code'].toString().toLowerCase() == name.toLowerCase());
  }
  Future<void> fetchData6() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/getemployeid'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          data6 = jsonData.cast<Map<String, dynamic>>();
          if (data6.isNotEmpty) {
            Map<String, dynamic> firstItem = data6.first;
          }
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
  List<Map<String, dynamic>> data6 = [];
  List<Map<String, dynamic>> filteredData6 = [];

  void filterData6(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredData6 = data6;
        empAddress.clear();
        pincode.clear();
        empMobile.clear();
        filteredData6 = data6;
      } else {
        filteredData6 = data6.where((item) {
          String id = item['emp_code']?.toString()?.toLowerCase() ?? '';
          return id == searchText.toLowerCase();
        }).toList();
        if (filteredData6.isNotEmpty) {
          Map<String, dynamic> order = filteredData6.first;
          empAddress.text = order['empAddress']?.toString() ?? '';
          pincode.text = order['pincode']?.toString() ?? '';
          empMobile.text = order['empMobile']?.toString() ?? '';
          gender = order['gender']?.toString() ?? '';
          bloodGroup = order['bloodgroup']?.toString() ?? '';
          bloodGroup = order['bloodgroup']?.toString() ?? '';
          maritalstatus = order['maritalStatus']?.toString() ?? '';
          fatherName.text = order['fatherName']?.toString() ?? '';
          fatherMobile.text = order['fatherMobile']?.toString() ?? '';
          spouseMobile.text = order['spouseMobile']?.toString() ?? '';
          spouseName.text = order['spouseName']?.toString() ?? '';
          education.text = order['education'] ?? '';
          depName.text = order['deptName']?.toString() ?? '';
          empposition= order["empPosition"].toString() ??"";
          shifttype= order['shift']?.toString() ?? '';
          salary= order['salaryType']?.toString() ?? '';
          daySalary.text= order['salary']?.toString() ?? '';
          acNumber.text= order['acNumber']?.toString() ?? '';
          acHoldername.text= order['acHoldername']?.toString() ?? '';
          bank.text= order['bank']?.toString() ?? '';
          branch.text= order['branch']?.toString() ?? '';
          acHoldername.text= order['acHoldername']?.toString() ?? '';
          ifsc.text= order['ifsc']?.toString() ?? '';
          pan.text= order['pan']?.toString() ?? '';
          aadhar.text= order['aadhar']?.toString() ?? '';
          String dojString = order['doj']?.toString() ?? '';
          String dobString = order['dob']?.toString() ?? '';
          String eodString = order['endingDate']?.toString() ?? '';
          dOJ = (dojString.isNotEmpty ? DateTime.parse(dojString) : null)!;
          dOB = (dobString.isNotEmpty ? DateTime.parse(dobString) : null)!;
          eod = (eodString.isNotEmpty ? DateTime.parse(eodString) : null)!;
          age.text= order['age']?.toString() ?? '';
          _imageUrl=order['photo']?.toString() ?? '';
        } else {
          empAddress.clear();
          empMobile.clear();
        }
        print("_imageUrl: $_imageUrl");
      }
    });
  }

  List<Map<String, dynamic>> data7 = [];

  List<Map<String, dynamic>> filtered6 = [];


  Future<bool> checkForDuplicate(String empcode) async {
    const String apiUrl = 'http://localhost:3309/checking_empid'; // Replace with your server endpoint
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> sizeData = jsonDecode(response.body);
        return sizeData.any((item) => item['emp_code'] == empcode);
      } else {
        print('Failed to fetch data');
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    searchController.addListener(() {
      filterData5(searchController.text);
    });
    empId.addListener(() {
      filterData6(empId.text);
    });
    calculateAge();
    return MyScaffold(
      route: "employee_profile_update",backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: double.infinity, // Set the width to full page width
                  padding: EdgeInsets.all(8.0),
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
                          Row(
                            children: [
                              Icon(Icons.account_balance_sharp),SizedBox(width: 10,),
                              Text("Employee Entry",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                              IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> EmployeeProfileUpdate()));
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                    width: double.infinity, // Set the width to full page width
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.grey), // Add a border for the box
                      borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                    ),
                    child:Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Personal Details", style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),),

                          ],
                        ),
                        SizedBox(height: 30,),
                        Wrap(
                          spacing: 20.0, // Set the horizontal spacing between the children
                          runSpacing: 50.0,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet(context: context, builder: (ctx){
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                            leading: const Icon(Icons.storage),
                                            title: const Text("From Gallery"),
                                            onTap: () async {
                                              _pickImage(ImageSource.gallery);
                                            })
                                      ],
                                    );
                                  });
                                },
                                child:  _imageUrl!.isNotEmpty
                                    ? ClipOval(
                                  child: Image.network(
                                    _imageUrl!,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Text('Failed to load image');
                                    },
                                  ),
                                )
                                    : CircleAvatar(
                                  radius: 50,
                                  backgroundImage: AssetImage("assets/employee.png"),
                                  child: Icon(Icons.download, size: 15,color: Colors.brown,),
                                ),
                              ),
                            ),
                            SizedBox(width:80),
                            Padding(
                              padding: const EdgeInsets.only(top:30.0),
                              child:SizedBox(
                                width: 200,
                                child: TypeAheadFormField<String>(
                                  textFieldConfiguration: TextFieldConfiguration(
                                    controller: searchController,
                                    onChanged: (value) {
                                      fetchEmployeeDetailsbyname(empId.text);
                                      fetchData5();
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
                                    final processedPattern = pattern.replaceAll(' ', '').toLowerCase();
                                    List<String> suggestions = data5
                                        .where((item) {
                                      String empName = item['first_name']?.toString()?.toLowerCase() ?? '';
                                      String empId = item['emp_code']?.toString()?.toLowerCase() ?? '';

                                      // Modify this condition to check if the first letter matches
                                      return empName.isNotEmpty && empName[0] == processedPattern[0] ||
                                          empId.isNotEmpty && empId[0] == processedPattern[0];
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
                                    fetchData5();
                                    String selectedEmpName = suggestion.split(' ')[0];
                                    String selectedEmpID = suggestion.split('(')[1].split(')')[0];
                                    setState(() {
                                      selectedCustomer = selectedEmpName;
                                      searchController.text = selectedEmpName;
                                    });
                                    print('Selected Customer: $selectedCustomer, ID: $selectedEmpID');
                                  },
                                ),
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
                                    );
                                  },
                                ),
                              ),
                            SizedBox(width: 30,),
                            SizedBox(
                                width: 200, height: 70,
                                child: Text("")),
                            SizedBox(width: 30,),
                            // SizedBox(
                            //     width: 200, height: 70,
                            //     child: Text("")),
                          ],),
                        Wrap(
                          spacing: 36.0, // Set the horizontal spacing between the children
                          runSpacing: 20.0,
                          children: [
                            ///Employee ID
                            SizedBox(
                              width: 200, height: 70,
                              child: TextFormField(
                                readOnly: true,
                                controller: empId,
                                onChanged: (value) {
                                  setState(() {
                                    errorMessage = ""; // Reset error message when user types
                                  });
                                  fetchData6();
                                  fetchEmployeeDetailsbyname(empId.text);
                                  String capitalizedValue = capitalizeFirstLetter(
                                      value);
                                  empId.value = empId.value.copyWith(
                                    text: capitalizedValue,
                                    selection: TextSelection.collapsed(
                                        offset: capitalizedValue.length),
                                  );
                                },
                                style: TextStyle(fontSize: 13),
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

                            ///Employee Name
                            SizedBox(
                              width: 200, height: 70,
                              child: TextFormField(
                                readOnly: true,
                                controller: empName,
                                onChanged: (value) {
                                  String capitalizedValue = capitalizeFirstLetter(
                                      value);
                                  empName.value = empName.value.copyWith(
                                    text: capitalizedValue,
                                    selection: TextSelection.collapsed(
                                        offset: capitalizedValue.length),
                                  );
                                },
                                style: TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Employee Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            ///Address
                            SizedBox(
                              width: 200, height: 70,
                              child: TextFormField(
                                controller: empAddress,
                                onChanged: (value) {
                                  String capitalizedValue = capitalizeFirstLetter(
                                      value);
                                  empAddress.value = empAddress.value.copyWith(
                                    text: capitalizedValue,
                                    selection: TextSelection.collapsed(
                                        offset: capitalizedValue.length),
                                  );
                                },
                                style: TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Address",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 200, height: 70,
                              child: TextFormField(
                                controller: pincode,
                                onChanged: (value) {
                                  String capitalizedValue = capitalizeFirstLetter(
                                      value);
                                  pincode.value = pincode.value.copyWith(
                                    text: capitalizedValue,
                                  );
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6)
                                ],
                                style: TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Pincode",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ///2nd line
                        Wrap(
                          spacing: 36.0, // Set the horizontal spacing between the children
                          runSpacing: 20.0,
                          children: [
                            SizedBox(
                              width: 200, height: 70,
                              child: TextFormField(
                                controller: empMobile,
                                style: TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  prefixText: "+91",
                                  labelText: "Mobile Number",
                                  filled:true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10)
                                ],
                              ),
                            ),

                            Column(children: [
                              SizedBox(
                                width: 200,
                                height:70,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 16.0,
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white)),
                                    ),
                                    hint: const Text("Gender",style: TextStyle(fontSize:13),),
                                    isExpanded: true,
                                    value: gender,
                                    items: <String>[ "Gender", "Male", "Female",
                                    ]
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        gender = newValue!;
                                      });},),),),
                            ],),
                            ///Date of Join
                            SizedBox(
                              width: 200,
                              height: 70,
                              child: TextFormField(
                                style: TextStyle(fontSize: 13),
                                readOnly: true,
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: dOJ,
                                    firstDate: DateTime(1950),
                                    lastDate: dOJ,
                                  ).then((date) {
                                    if (date != null) {
                                      setState(() {
                                        dOJ = date;
                                      });
                                    }
                                  });
                                },
                                controller: TextEditingController(
                                  text: DateFormat('dd-MM-yyyy').format(dOJ),
                                ),
                                decoration: InputDecoration(
                                  labelText: "Date of Join",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200, height: 70,
                              child: TextFormField(
                                  controller: aadhar,
                                  style: TextStyle(fontSize: 13),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(12)
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Aadhar Number",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          8.0),
                                    ),
                                  )
                              ),
                            ),

                            ///Gender
                          ],
                        ),
                        ///3 line
                        Wrap(
                          spacing: 36.0, // Set the horizontal spacing between the children
                          runSpacing: 20.0,
                          children: [

                            Column(
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
                                          vertical: 10.0,
                                          horizontal: 16.0,
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.white)),
                                      ),
                                      hint: const Text("Employee Position",style: TextStyle(fontSize:13),),
                                      isExpanded: true,
                                      value: empposition,

                                      items: <String>["Employee Position",  "Operator", "Assistant",]
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          empposition = newValue!;
                                        });},),),),
                              ],
                            ),

                            /* Column(children: [
                            SizedBox(
                              width: 200,
                              height:35,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 16.0,
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.white)),
                                  ),
                                  hint: const Text("Shift Type",style: TextStyle(fontSize:12),),
                                  isExpanded: true,
                                  value: shifttype,
                                  items: <String>["Shift Type","General","Morning","Night"]
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      shifttype = newValue!;
                                    });},),),),

                          ],),*/
                            Column(children: [
                              SizedBox(
                                width: 200,
                                height:40,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 16.0,
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white)),
                                    ),
                                    hint: const Text("Salary Type",style: TextStyle(fontSize:12),),
                                    isExpanded: true,
                                    value: salary,
                                    items: <String>["Salary Type","Daily","Monthly"
                                    ]
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        salary = newValue!;
                                      });},),),),
                            ],),
                            ///shift Type n
                            SizedBox(
                              width: 200, height: 80,
                              child: TextFormField(
                                controller: daySalary,
                                onChanged: (value) {
                                  String capitalizedValue = capitalizeFirstLetter(
                                      value);
                                  daySalary.value = daySalary.value.copyWith(
                                    text: capitalizedValue,
                                    selection: TextSelection.collapsed(
                                        offset: capitalizedValue.length),
                                  );
                                },
                                style: TextStyle(fontSize: 13),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4)
                                ],
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: "Salary/Day(₹)",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        10,),
                                    )
                                ),
                              ),
                            ),
                            ///dummy space for alignment
                            SizedBox(width: 200,
                                child:Text("")
                            )
                          ],
                        ),

                      ],
                    )
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child:   Container(
                  width: double.infinity, // Set the width to full page width
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.grey), // Add a border for the box
                    borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                  ),
                  child:Column(
                    children: [
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.only(left:0.0),
                        child: Row(
                          children: [
                            Text("Optional Details", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17
                            ),),
                          ],
                        ),
                      ),

                      SizedBox(height: 20,),
                      Wrap(
                        spacing: 36.0, // Set the horizontal spacing between the children
                        runSpacing: 20.0,
                        children: [
                          ///Date Of Birth
                          SizedBox(
                            width: 200,
                            height: 70,
                            child: TextFormField(
                              style: TextStyle(fontSize: 13),
                              readOnly: true,
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),  // Use the current date if dOB is null
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                ).then((date) {
                                  if (date != null) {
                                    setState(() {
                                      date = date;
                                      calculateAge();
                                      dateSelected = true;
                                    });
                                    _textController.text = DateFormat('dd-MM-yyyy').format(date!);
                                  }
                                });
                              },
                              controller: _textController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "DOB",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          ///Age
                          SizedBox(
                            width: 200, height: 70,
                            child: TextFormField(
                              // controller:age,
                              style: TextStyle(fontSize: 13),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),],
                              decoration: InputDecoration(
                                filled:true,
                                fillColor: Colors.white,
                                labelText: "Age",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              controller: TextEditingController(
                                  text: agevalue.toString()),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 200,
                                height:40,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 16.0,
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white)),
                                    ),
                                    hint: const Text("Blood group",style: TextStyle(fontSize:13),),
                                    isExpanded: true,
                                    value: bloodGroup,
                                    items: <String>["Blood Group",  "A+", "A-",
                                      "A1+", "A1-",
                                      "A2+", "A2-",
                                      "A1B+", "A1B-",
                                      "A2B+", "A2B-",
                                      "AB+", "AB-",
                                      "B+", "B-",
                                      "O+", "O-",
                                      "BBG", "INRA",]
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        bloodGroup = newValue!;
                                      });},),),),
                            ],
                          ),
                          ///education
                          SizedBox(
                            width: 200, height: 70,
                            child: TextFormField(
                              controller: education,
                              onChanged: (value) {
                                fetchData6();
                                String capitalizedValue = capitalizeFirstLetter(
                                    value);
                                education.value = education.value.copyWith(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(
                                      offset: capitalizedValue.length),
                                );
                              },
                              style: TextStyle(fontSize: 13),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'[0-9]')) // Deny numeric characters
                              ],
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Qualification",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,),
                                  )
                              ),
                            ),
                          ),

                        ],
                      ),
                      Wrap(
                        spacing: 36.0, // Set the horizontal spacing between the children
                        runSpacing: 20.0,
                        children: [


                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 200,
                                height:38,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 16.0,
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white)),
                                    ),
                                    hint: const Text("Marital Status",style: TextStyle(fontSize:13),),
                                    isExpanded: true,
                                    value: maritalstatus,
                                    items: <String>["Marital Status", "Married", "Unmarried",]
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        maritalstatus = newValue!;
                                      });},),),),
                            ],
                          ),
                          if (maritalstatus == 'Married')

                            if (maritalstatus == 'Married')
                            ///Spouse Name
                              SizedBox(
                                width: 200,
                                height: 70,
                                child: TextFormField(
                                  controller: spouseName,
                                  onChanged: (value) {
                                    String capitalizedValue = capitalizeFirstLetter(value);
                                    spouseName.value = spouseName.value.copyWith(
                                      text: capitalizedValue,
                                      selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                    );
                                  },
                                  style: TextStyle(fontSize: 13),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'[0-9]')) // Deny numeric characters
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Spouse's Name",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                          if (maritalstatus == 'Married')

                          ///Spouse Mobile Number
                            if (maritalstatus == 'Married')
                              SizedBox(
                                width: 200, height: 70,
                                child: TextFormField(
                                  controller: spouseMobile,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    prefixText: "+91",
                                    labelText: "Spouse Mobile Number",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius
                                          .circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                    LengthLimitingTextInputFormatter(10)
                                  ],
                                ),
                              ),
                          if(maritalstatus == 'Unmarried'|| maritalstatus =="Marital Status")

                            if(maritalstatus == 'Unmarried'|| maritalstatus =="Marital Status")
                            ///Father Name
                              SizedBox(
                                width: 200, height: 70,
                                child: TextFormField(
                                  controller: fatherName,
                                  onChanged: (value) {
                                    String capitalizedValue = capitalizeFirstLetter(value);
                                    fatherName.value = fatherName.value.copyWith(
                                      text: capitalizedValue,
                                      selection: TextSelection.collapsed(offset: capitalizedValue.length),
                                    );
                                  },
                                  style: TextStyle(fontSize: 13),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'[0-9]')) // Deny numeric characters
                                  ],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: "Father's Name",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius
                                          .circular(10),
                                    ),
                                  ),
                                ),
                              ),
                          if(maritalstatus == 'Unmarried'|| maritalstatus =="Marital Status")

                            if(maritalstatus == 'Unmarried'|| maritalstatus =="Marital Status")
                            ///Father Mobile
                              SizedBox(
                                width: 200, height: 70,
                                child: TextFormField(
                                  controller: fatherMobile,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    prefixText: "+91",
                                    labelText: "Father Mobile Number",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius
                                          .circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                    LengthLimitingTextInputFormatter(10)
                                  ],
                                ),
                              ),
                          ///Department Name
                          SizedBox(
                            width: 200, height: 70,
                            child: TextFormField(
                                controller: depName,
                                onChanged: (value) {
                                  String capitalizedValue = capitalizeFirstLetter(
                                      value);
                                  depName.value =
                                      depName.value.copyWith(
                                        text: capitalizedValue,
                                        selection: TextSelection.collapsed(
                                            offset: capitalizedValue.length),
                                      );
                                },
                                style: TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Department Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0),
                                  ),
                                )
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 36.0, // Set the horizontal spacing between the children
                        runSpacing: 20.0,
                        children: [
                          SizedBox(
                            width: 200, height: 70,
                            child: TextFormField(
                                controller: acNumber,
                                style: (
                                    TextStyle(fontSize: 13)),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(16),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  labelText: "Account Number",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0),
                                  ),
                                )
                            ),
                          ),

                          SizedBox(
                            width: 200, height: 70,
                            child: TextFormField(
                              controller: acHoldername,
                              onChanged: (value) {
                                String capitalizedValue = capitalizeFirstLetter(
                                    value);
                                acHoldername.value =
                                    acHoldername.value.copyWith(
                                      text: capitalizedValue,
                                      selection: TextSelection.collapsed(
                                          offset: capitalizedValue.length),
                                    );
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'[0-9]')) // Deny numeric characters
                              ],
                              style: TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Account Holder Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,),
                                  )
                              ),
                            ),
                          ),
                          ///Bank Name
                          SizedBox(
                            width: 200, height: 70,
                            child: TextFormField(
                                controller: bank,
                                onChanged: (value) {
                                  String capitalizedValue = capitalizeFirstLetter(value);
                                  bank.value = bank.value.copyWith(
                                    text: capitalizedValue,
                                    selection: TextSelection.collapsed(
                                        offset: capitalizedValue.length),);},
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(r'[0-9]')) // Deny numeric characters
                                ],
                                style: TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  labelText: "Bank",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0),
                                  ),
                                )
                            ),
                          ),
                          SizedBox(
                            width: 200, height: 70,
                            child:TextFormField(
                              controller: branch,
                              onChanged: (value) {
                                String capitalizedValue = capitalizeFirstLetter(value);
                                branch.value = branch.value.copyWith(
                                  text: capitalizedValue,
                                  selection: TextSelection.collapsed(
                                      offset: capitalizedValue.length),
                                );
                              },
                              style: TextStyle(fontSize: 13),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'[0-9]')) // Deny numeric characters
                              ],
                              decoration: InputDecoration(
                                  labelText: "Branch",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,),
                                  )
                              ),
                            ),
                          ),
                          ///Account holder Name
                        ],
                      ),
                      Wrap(
                        spacing: 36.0, // Set the horizontal spacing between the children
                        runSpacing: 20.0,
                        children: [
                          SizedBox(
                            width: 200, height: 70,
                            child: TextFormField(
                                controller: ifsc,
                                style: TextStyle(fontSize: 13),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(12),
                                  UpperCaseTextFormatter()
                                ],
                                decoration: InputDecoration(
                                  labelText: "IFSC Code",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0),
                                  ),
                                )
                            ),
                          ),
                          SizedBox(
                            width: 200, height: 70,
                            child: TextFormField(
                                controller: pan,
                                style: TextStyle(fontSize: 13),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                  UpperCaseTextFormatter(),
                                ],
                                decoration: InputDecoration(
                                  labelText: "PAN Card Number",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0),
                                  ),
                                )
                            ),
                          ),
                          // SizedBox(width: 200, height: 70,),
                          ///end of date
                          SizedBox(
                            width: 200,
                            height: 70,
                            child: TextFormField(
                              style: TextStyle(fontSize: 13),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: eod ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    eod = pickedDate;
                                    dateSelected = true;
                                  });
                                }
                              },
                              // Set the initial value of the field to the selected date or null
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Ending Date",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),


                          SizedBox(width: 200, height: 70,),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top:20),
                            child: Text(errorMessage,style: TextStyle(color: Colors.red,fontSize: 15),),
                          ),
                        ],
                      )

                    ],
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(2.0),
              //   child:   Container(
              //     width: double.infinity, // Set the width to full page width
              //     padding: EdgeInsets.all(8.0),
              //     decoration: BoxDecoration(
              //       color: Colors.blue.shade50,
              //       border: Border.all(color: Colors.grey), // Add a border for the box
              //       borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
              //     ),
              //     child:Column(
              //       children: [
              //         SizedBox(height: 20,),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           children: [
              //             SizedBox(width: 5,),
              //             Text("Bank Details", style: TextStyle(
              //                 fontWeight: FontWeight.bold,
              //                 fontSize: 17
              //             ),),
              //           ],
              //         ),
              //         SizedBox(height: 20,),
              //
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.end,
              //           children: [
              //             Text(errorMessage,style: TextStyle(color: Colors.red),),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child:
                Wrap(
                  children: [
                    MaterialButton(
                      color: Colors.green.shade600,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          DateTime selectedDate = DateTime(dOB.year, dOB.month, dOB.day);
                          String formattedDOB = "${dOB.year}-${dOB.month.toString().padLeft(2, '0')}-${dOB.day.toString().padLeft(2, '0')}";
                          if (searchController.text.isEmpty) {
                            setState(() {
                              errorMessage = "* Select a Employee ID/Name ";
                            });
                          }
                          else if (empId.text.isEmpty) {
                            setState(() {
                              errorMessage = "* Enter a Employee ID ";
                            });
                          }
                          else if (empName.text.isEmpty) {
                            setState(() {
                              errorMessage = "* Enter a Employee Name ";
                            });
                          }
                          else if (empAddress.text.isEmpty) {
                            setState(() {
                              errorMessage = "* Enter a Employee Address ";
                            });
                          }
                          else if (pincode.text.isEmpty) {
                            setState(() {
                              errorMessage = "* Enter a Pincode ";
                            });
                          }
                          else if (pincode.text.length != 6) {
                            setState(() {
                              errorMessage = '* Enter a valid pincode';
                            });
                          }
                          else if (empMobile.text.isEmpty) {
                            setState(() {
                              errorMessage = "* Enter a Employee Mobile ";
                            });
                          }
                          else if (empMobile.text.length != 10) {
                            setState(() {
                              errorMessage = '* Mobile number should be 10 digits';
                            });
                          }
                          else if (gender == "Gender") {
                            setState(() {
                              errorMessage = "* Select a Gender ";
                            });
                          }

                          else if(empposition=="Employee Position"){
                            setState(() {
                              errorMessage ="* Select a Employee Position";
                            });
                          }
                          else if(salary==null){
                            setState(() {
                              errorMessage ="* Select a Salary Type";
                            });
                          } else if(shifttype==null){
                            setState(() {
                              errorMessage ="* Select a Shift Type";
                            });
                          }
                          // else if(daySalary.text.isEmpty){
                          //   setState(() {
                          //     errorMessage ="* Enter a Salary";
                          //   });
                          // }
                          // else if(acNumber.text.isEmpty){
                          //   setState(() {
                          //     errorMessage ="* Enter a Account Number";
                          //   });
                          // }
                          // else if(acHoldername.text.isEmpty){
                          //   setState(() {
                          //     errorMessage ="* Enter a Account Holder Name";
                          //   });
                          // }
                          // else if(bank.text.isEmpty){
                          //   setState(() {
                          //     errorMessage ="* Enter a Bank Name";
                          //   });
                          // }
                          // else if(branch.text.isEmpty){
                          //   setState(() {
                          //     errorMessage ="* Enter a Branch";
                          //   });
                          // }
                          // else if(ifsc.text.isEmpty) {
                          //   setState(() {
                          //     errorMessage = "* Enter a IFSC Code";
                          //   });
                          // }else if (!RegExp(r'^[A-Za-z]{4}[0][A-Z0-9]{6}$').hasMatch(ifsc.text)) {
                          //   setState(() {
                          //     errorMessage = "* Enter a valid IFSC Code";
                          //   });
                          // }
                          // else if(pan.text.isEmpty){
                          //   setState(() {
                          //     errorMessage ="* Enter a PAN Card Number";
                          //   });
                          // }
                          // else if (!RegExp("[A-Z]{5}[0-9]{4}[A-Z]{1}")
                          //     .hasMatch(pan.text)) {
                          //   setState(() {
                          //     errorMessage ="* Enter a Valid PAN number";
                          //   });
                          // }
                          // else if(aadhar.text.isEmpty){
                          //   setState(() {
                          //     errorMessage ="* Enter a Aadhar Number";
                          //   });
                          // }
                          // else if(aadhar.text.length !=12){
                          //   setState(() {
                          //     errorMessage ="* Aadhaar should be 12 digits";
                          //   });
                          // }
                          // else if(!RegExp(r'^[0-9]+$')
                          //     .hasMatch(aadhar.text)){
                          //   setState(() {
                          //     errorMessage ="* Aadhaar can only contain digits";
                          //   });
                          // }
                          else {
                            //customerDataToDatabase();
                            //String formattedDOB = "${dOB.year}-${dOB.month.toString().padLeft(2, '0')}-${dOB.day.toString().padLeft(2, '0')}";
                            bool isDuplicate= await checkForDuplicate(empId.text);
                            print('Is Duplicate: $isDuplicate');
                            if(isDuplicate){
                              print('Employee ID is a duplicate. Running updateEmployee...');
                              updateEmployee(
                                  empId.text,
                                  empName.text,
                                  empMobile.text,
                                  empAddress.text,
                                  pincode.text, gender.toString(),
                                  _textController.text,
                                  agevalue.toString(),
                                  bloodGroup.toString(),
                                  maritalstatus.toString(),
                                  spouseName.text,
                                  spouseMobile.text,
                                  empPhoto.text,
                                  education.text,aadhar.text,
                                  dOJ.toString(),
                                  eod.toString(),
                                  empposition.toString(),
                                  depName.text, shifttype.toString(),
                                  salary.toString(),
                                  acNumber.text,
                                  acHoldername.text,
                                  branch.text, ifsc.text, pan.text, bank.text,
                                  fatherName.text,
                                  fatherMobile.text,
                                  daySalary.text,
                                  date.toString(),
                                  "Available");
                            }
                            else {
                              print('Employee ID is not a duplicate. Running customerDataToDatabase...');
                              customerDataToDatabase();
                            }
                          }
                        }
                      },
                      child: Text("SAVE", style: TextStyle(
                          color: Colors.white),),),
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
                                        MaterialPageRoute(builder: (context) =>const EmployeeProfileUpdate()));// Close the alert box
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
                      child: Text("RESET", style: TextStyle(color: Colors
                          .white),),),
                    SizedBox(width: 10,),
                    MaterialButton(
                      color: Colors.red.shade600,
                      onPressed: (){
                        /*                    Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>const Home()));*/
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
                      }, child: Text("CANCEL", style: TextStyle(
                        color: Colors.white),),),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
  void calculateAge() {
    print('calculateAge called');
    final today = DateTime.now();
    final ageCalculation = today.year - dOB.year;
    if (today.month < dOB.month || (today.month == dOB.month && today.day < dOB.day)) {
      agevalue = ageCalculation - 1;
    } else {
      agevalue = ageCalculation;
    }
    print('Calculated age: $agevalue');
  }

}


/*
MaterialButton(
color: Colors.green.shade600,
onPressed: () async {

if (_formKey.currentState!.validate()) {
String formattedDOB = "${dOB.year}-${dOB.month.toString().padLeft(2, '0')}-${dOB.day.toString().padLeft(2, '0')}";
if (searchController.text.isEmpty) {
setState(() {
errorMessage = "* Select a Employee ID/Name ";
});
}
else if (empId.text.isEmpty) {
setState(() {
errorMessage = "* Enter a Employee ID ";
});
}
else if (empName.text.isEmpty) {
setState(() {
errorMessage = "* Enter a Employee Name ";
});
}
else if (empAddress.text.isEmpty) {
setState(() {
errorMessage = "* Enter a Employee Address ";
});
}
else if (pincode.text.isEmpty) {
setState(() {
errorMessage = "* Enter a Pincode ";
});
}
else if (pincode.text.length != 6) {
setState(() {
errorMessage = '* Enter a valid pincode';
});
}
else if (empMobile.text.isEmpty) {
setState(() {
errorMessage = "* Enter a Employee Mobile ";
});
}
else if (empMobile.text.length != 10) {
setState(() {
errorMessage = '* Mobile number should be 10 digits';
});
}
else if (bloodGroup == "Blood Group") {
setState(() {
errorMessage = "* Select a Blood group ";
});
}
else if (gender == "Gender") {
setState(() {
errorMessage = "* Select a Gender ";
});
}
else if(depName.text.isEmpty){
setState(() {
errorMessage ="* Enter a Department Name";
});
}
else if(empposition==null){
setState(() {
errorMessage ="* Select a Employee Position";
});
}
else if(salary==null){
setState(() {
errorMessage ="* Select a Salary Type";
});
} else if(shifttype==null){
setState(() {
errorMessage ="* Select a Shift Type";
});
}
else if(acNumber.text.isEmpty){
setState(() {
errorMessage ="* Enter a Account Number";
});
}
else if(acHoldername.text.isEmpty){
setState(() {
errorMessage ="* Enter a Account Holder Name";
});
}
else if(bank.text.isEmpty){
setState(() {
errorMessage ="* Enter a Bank Name";
});
}
else if(branch.text.isEmpty){
setState(() {
errorMessage ="* Enter a Branch";
});
}
else if(ifsc.text.isEmpty) {
setState(() {
errorMessage = "* Enter a IFSC Code";
});
}else if (!RegExp(r'^[A-Za-z]{4}[0][A-Z0-9]{6}$').hasMatch(ifsc.text)) {
setState(() {
errorMessage = "* Enter a valid IFSC Code";
});
}
else if(pan.text.isEmpty){
setState(() {
errorMessage ="* Enter a PAN Card Number";
});
}
else if (!RegExp("[A-Z]{5}[0-9]{4}[A-Z]{1}")
    .hasMatch(pan.text)) {
setState(() {
errorMessage ="* Enter a Valid PAN number";
});
}
else if(aadhar.text.isEmpty){
setState(() {
errorMessage ="* Enter a Aadhar Number";
});
}
else if(aadhar.text.length !=12){
setState(() {
errorMessage ="* Aadhaar should be 12 digits";
});
}
else if(!RegExp(r'^[0-9]+$')
    .hasMatch(aadhar.text)){
setState(() {
errorMessage ="* Aadhaar can only contain digits";
});
}

else {
customerDataToDatabase();
String formattedDOB = "${dOB.year}-${dOB.month.toString().padLeft(2, '0')}-${dOB.day.toString().padLeft(2, '0')}";
bool isDuplicate= await checkForDuplicate(searchController.text);
*/
/*  if(isDuplicate){
                              updateEmployee(
                                  empId.text,
                                  empName.text,
                                  empMobile.text,
                                  empAddress.text,
                                  gender.toString(),
                                  formattedDOB,
                                  agevalue.toString(),
                                  bloodGroup.toString(),
                                   maritalstatus.toString(),
                                  spouseName.text,
                                  spouseMobile.text,
                                  empPhoto.text,
                                  education.text,
                                  aadhar.text,
                                  dOJ.toString(),
                                  eod.toString(),
                                  empposition.toString(),
                                  depName.text,
                                  shifttype.toString(),
                                  salary.toString(),
                                  acNumber.text,
                                  acHoldername.text,
                                  branch.text,
                                  ifsc.text,
                                  pan.text,
                                  bank.text,
                                  fatherName.text,
                                  fatherMobile.text,
                                  "Available",
                                  "",
                              );
                            }
                            else {
                              customerDataToDatabase();
                            }*//*

}
}
} ,
child: Text("SAVE", style: TextStyle(
color: Colors.white),),),*/
