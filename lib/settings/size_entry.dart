import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vinayaga_project/settings/size_report.dart';

import '../main.dart';
class SizeEntry extends StatefulWidget {
  const SizeEntry({Key? key}) : super(key: key);

  @override
  State<SizeEntry> createState() => _SizeEntryState();
}

class _SizeEntryState extends State<SizeEntry> {
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return MyScaffold(
        route: "size_entry",backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                    children: [
                      SizedBox(height: 20,),
                      Text("Size Creation", style: TextStyle(

                        fontWeight: FontWeight.bold,

                        fontSize:screenWidth< 600 ? 16:20,
                      ),),
                      SizedBox(height: 30,),
                      Wrap(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Size"),
                              SizedBox(height: 5,),
                              SizedBox(
                                width: screenWidth < 600 ? double.infinity : 300,
                                child: TextFormField(
                                  // inputFormatters: [
                                  //   FilteringTextInputFormatter.allow(
                                  //     RegExp(r'^[0-9./]*$'), // Allow only numbers, dots, and slashes
                                  //   ),
                                  // ],
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return "* Enter Size";
                                    }else{
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter Size",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height:30 ,),

                      Wrap(
                        children: [

                          MaterialButton(
                            color:Colors.green,onPressed: (){
                              if(_formKey.currentState!.validate()){}
                          },child: Text("Submit",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 15,),
                          MaterialButton(
                            color:Colors.blue,onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> SizeReport()));
                          },child: Text("View",style: TextStyle(color: Colors.white),),),
                          SizedBox(width: 15,),
                          MaterialButton(
                            color:Colors.red,onPressed: _resetForm,
                            child: Text("Reset",style: TextStyle(color: Colors.white),),),


                        ],
                      ),
                    ]),
              ),
            ),
          ),
        ) );
  }
}
