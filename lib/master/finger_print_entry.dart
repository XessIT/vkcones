import 'package:flutter/material.dart';
import 'package:vinayaga_project/main.dart';

import '../home.dart';

class FingerPrint extends StatefulWidget {
  FingerPrint({Key? key}) : super(key: key);
  @override
  State<FingerPrint> createState() => _FingerPrintState();
}
class _FingerPrintState extends State<FingerPrint> {
  final _formKey = GlobalKey<FormState>();
  // RegExp nameRegExp = RegExp(r'^[a-zA-Z\,]+(\s[a-zA-Z]+,)?$');

  void _resetForm() {
    _formKey.currentState!.reset();
  }
  void _cancelForm() {
    print('Form cancelled!');
  }

  //GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      route: "finger_print_entry",
      body: Form(
        key: _formKey,
        child:  Center(
          child: Column(
            children: [
              SizedBox(height: 30,),
              Text("Finger Print Device",style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
              SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("FP ID"),
                        SizedBox(height: 7,),
                        SizedBox(
                          width: 200, height: 70,
                          child: TextFormField(style: TextStyle(fontSize: 13),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '* Enter FP Id';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("FB Device Name"),
                        SizedBox(height: 7,),
                        SizedBox(
                          width: 200, height: 70,
                          child: TextFormField(style: TextStyle(fontSize: 13),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '* Enter FB Device Name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 7,),
                        const Text("IP Address"),
                        SizedBox(
                          width: 200, height: 70,
                          child: TextFormField(style: TextStyle(fontSize: 13),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '* Enter IP Address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      color: Colors.green.shade600,
                      onPressed: (){
                        if(_formKey.currentState!.validate()){}
                      }, child: const Text("Submit",style: TextStyle(color: Colors.white),)),
                  SizedBox(
                    width: 10,
                  ),
                  MaterialButton(
                    color: Colors.blue.shade600,
                    onPressed: _resetForm,child:Text("Reset",style: TextStyle(color: Colors.white),),),
                    SizedBox(width: 10,),

                  MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      color: Colors.red.shade600,
                      onPressed: (){
                        _cancelForm();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>Home()));
                      }, child: const Text("Cancel",style: TextStyle(color: Colors.white),)),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



