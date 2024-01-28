import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package for TextInputFormatter
import 'package:vinayaga_project/main.dart';

import 'gst_report .dart';

//import 'gst_report.dart';

class GstEntry extends StatefulWidget {

  GstEntry({Key? key}) : super(key: key);
  @override
  State<GstEntry> createState() => _GstEntryState();
}

class _GstEntryState extends State<GstEntry> {
  static final  RegExp gstregex = RegExp(r"^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d[Z]{1}[A-Z\d]{1}$");

  final _formKey = GlobalKey<FormState>();

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      route: "gst_entry",backgroundColor: Colors.white,
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 50),
              Text(
                "GST Creation",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(
                height: 30,
              ),
              Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("GST"),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter GST";
                              }

                              if (!gstregex.hasMatch(value)) {
                                return '* Enter a valid GST';
                              }
                              else {
                                return null;
                              }
                            },
                            inputFormatters: [
                              UpperCaseTextFormatter(), // Apply the formatter
                            ],
                            decoration: InputDecoration(
                                hintText: "Enter GST",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        color: Colors.green.shade600,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {}
                        },
                        child: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      color: Colors.blue.shade600,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GstReport()));
                      },
                      child: const Text(
                        "View",
                        style: TextStyle(color: Colors.white),
                      )),
                  SizedBox(
                    width: 20,
                  ),
                  MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      color: Colors.red.shade600,
                      onPressed: _resetForm,
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
