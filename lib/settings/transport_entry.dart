import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package for TextInputFormatter
import 'package:vinayaga_project/settings/transport_report.dart';
//import 'package:vinayaga_project/settings/transport_report.dart';

import '../main.dart';

class TransPortEntry extends StatefulWidget {
  const TransPortEntry({Key? key}) : super(key: key);

  @override
  State<TransPortEntry> createState() => _TransPortEntryState();
}

class _TransPortEntryState extends State<TransPortEntry> {
  RegExp truckNumberPattern = RegExp(r'^([A-Z0-9]{2}\s?[A-Z0-9]{2}\s?[A-Z]{1,2}\s?\d{1,4})\s?$');

  final _formKey = GlobalKey<FormState>();

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      route: "transport_entry",backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Transport Number Creation",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 40),
                  Wrap(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Transport Number"),
                          SizedBox(height: 5),
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "* Enter Transport Number";
                                } else if (!truckNumberPattern.hasMatch(value)) {
                                  return '* Enter a valid Transport Number';
                                } else {
                                  return null;
                                }
                              },
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                              ],
                              decoration: InputDecoration(
                                hintText: "Transport Number",
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
                  SizedBox(height: 30),
                  Wrap(
                    children: [
                      MaterialButton(
                        color: Colors.green,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Form is valid, add your submission logic here
                          }
                        },
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 15),
                      MaterialButton(
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransportReport(),
                            ),
                          );
                        },
                        child: Text(
                          "View",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 15),
                      MaterialButton(
                        color: Colors.red,
                        onPressed: _resetForm,
                        child: Text(
                          "Reset",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

