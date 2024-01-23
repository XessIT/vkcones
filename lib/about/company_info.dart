import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home.dart';
import '../main.dart';
class CompanyInfo extends StatefulWidget {
  const CompanyInfo({Key? key}) : super(key: key);

  @override
  State<CompanyInfo> createState() => _CompanyInfoState();
}

class _CompanyInfoState extends State<CompanyInfo> {
  final _formKey = GlobalKey<FormState>();
  RegExp emailRegExp = RegExp(r'^[\w-\.]+@(gmail\.com|yahoo\.com)$');
  void _resetForm() {
    _formKey.currentState!.reset();
  }
  void _cancelForm() {
    print('Form cancelled!');
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "company_info",
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(

              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 100.0,right: 100.0,top: 20,bottom: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                          children: [
                            SizedBox(height: 10,),
                            Text("Company Info", style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),),
                            SizedBox(height: 10,),

                            Wrap(

                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Company Name"),
                                SizedBox(width: 25,),

                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter Company Name';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3,),
                            Wrap(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Address      "),
                                SizedBox(width: 49,),
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter Address';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3,),
                            Wrap(
//mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Contact       "),
                                SizedBox(width: 49,),
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "* Enter Mobile Number";
                                      } else if (value.length < 10) {
                                        return "Mobile Number should be 10 digits";
                                      }  else{
                                        return null;}
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
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
                              ],
                            ),
                            SizedBox(height: 3,),
                            Wrap(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Mail Id         "),
                                SizedBox(width: 49,),
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your Email Address';
                                      }
                                      // Check if the entered email has the right format and domain
                                      if (!RegExp(r'^[\w-\.]+@(gmail\.com|yahoo\.com)$').hasMatch(value)) {
                                        return 'Please enter a valid mail Address';
                                      }
                                      // Return null if the entered email is valid
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3,),
                            Wrap(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("GST No       "),
                                SizedBox(width: 49,),
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter GST No';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3,),

                            Wrap(
                              //  mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("TIN No       "),
                                SizedBox(width: 49,),

                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter TN No';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3,),

                            Wrap(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("CST No      "),
                                SizedBox(width: 49,),
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter CST No';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3,),


                            Wrap(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Bank Name"),
                                SizedBox(width: 45,),
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter Bank Name';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),  SizedBox(height: 3,),

                            Wrap(
                              //  mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Account No"),
                                SizedBox(width: 43,),
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter Account No';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),  SizedBox(height: 3,),

                            Wrap(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Branch"),
                                SizedBox(width: 68,),
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter Branch';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),  SizedBox(height: 3,),

                            Wrap(
                              //  mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("IFSC Code"),
                                SizedBox(width: 44,),
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '* Enter IFSC Code';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 10,),
                            Wrap(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MaterialButton(
                                  color:Colors.green,onPressed: (){
                                  if(_formKey.currentState!.validate()){
                                    print("Success");
                                  }
                                },child: Text("Submit",style: TextStyle(color: Colors.white),),),
                                SizedBox(width: 15,),

                                MaterialButton(
                                  color:Colors.blue,onPressed: _resetForm,child: Text("Reset",style: TextStyle(color: Colors.white),),),
                                SizedBox(width: 10,),
                                MaterialButton(
                                  color: Colors.red.shade600,
                                  onPressed: (){
                                    _cancelForm();
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) =>Home()));
                                  },child: Text("Cancel",style: TextStyle(color: Colors.white),),)
                              ],
                            ),
                            SizedBox(height: 15,),
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ) );
  }
}
