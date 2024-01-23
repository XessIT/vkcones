import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vinayaga_project/main.dart';
import 'package:http/http.dart' as http;
import 'home.dart';

class LoginPAge extends StatefulWidget {
  const LoginPAge({Key? key}) : super(key: key);

  @override
  State<LoginPAge> createState() => _LoginPAgeState();
}



class _LoginPAgeState extends State<LoginPAge> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filteredData = [];
  bool showWarning = false;
  bool _obscureText2 = true;
  String warningMessage = '';


  void _performLogin() {
    if (username.text.isEmpty && password.text.isEmpty) {
      setState(() {
        showWarning = true;
        warningMessage = "Enter username and password";
      });
    } else if (username.text.isEmpty) {
      setState(() {
        showWarning = true;
        warningMessage = "Enter username";
      });
    } else if (password.text.isEmpty) {
      setState(() {
        showWarning = true;
        warningMessage = "Enter password";
      });
    } else if (username.text == "admin" && password.text == "admin") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );}
    // } else {
    //   setState(() {
    //     showWarning = true;
    //     warningMessage = "Incorrect username or password";
    //   });
    // }
  }



  @override
  void initState() {
    super.initState();
    barrierDismissible: false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Vinayaga Cones'
              ),
        ),
        // Customize the AppBar as needed
      ),
     // route: "loginpage",
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70.0),
                      child: Container(
                        width: 400,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            SizedBox(height: 20,),
                            Center(
                              child: Container(
                                child: Stack(
                                  children: [
                                    ClipOval(
                                      child: Image.asset(
                                        'assets/god2.jpg',
                                        width: 150,
                                        height: 150,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 220,
                                child: TextFormField(
                                  controller: username,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: "Username",
                                  ),
                                  onEditingComplete: () {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 220,
                                child: TextFormField(
                                  controller: password,
                                  textInputAction: TextInputAction.done, // Change to "done" for the last field
                                  obscureText: _obscureText2,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: "Password",
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText2 ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText2 = !_obscureText2;
                                        });
                                      },
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),

                            MaterialButton(
                              color: Colors.blueAccent.shade400,
                              onPressed: () {
                                if(_formKey.currentState!.validate()){
                                if (username.text.isEmpty) {
                                   setState(() {
                                    //showWarning = true;
                                    warningMessage = "Enter a username";
                                  });
                                } else if (password.text.isEmpty) {
                                     setState(() {
                                   // showWarning = true;
                                    warningMessage = "Enter a password";
                                  });
                                } else if(username.text.isNotEmpty&&password.text.isNotEmpty){
                                  if(username.text == "admin"&&password.text == "admin"){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Home()),
                                    );
                                  }else{
                                    setState(() {
                                      //showWarning = true;
                                      warningMessage = "Incorrect username or password";
                                    });

                                  }

                                }
                              /*  else if (username.text == "admin" && password.text == "admin") {
                                      Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Home()),
                                  );
                                }*/
                               /* else {
                                  setState(() {
                                   // showWarning = true;
                                    warningMessage = "Incorrect username or password";
                                  });
                                }*/}
                              },
                              child: Text(
                                "LOGIN",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            SizedBox(height: 10,),
                         //   if (showWarning)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(warningMessage??"",
                              //    "* The username or password is incorrect.",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

      ),
    );
  }
}
