import 'package:flutter/material.dart';

import '../main.dart';
import 'color_entry_view.dart';

class ColoursEntry extends StatefulWidget {
  const ColoursEntry({Key? key}) : super(key: key);

  @override
  State<ColoursEntry> createState() => _ColoursEntryState();
}

class _ColoursEntryState extends State<ColoursEntry> {
  final _formKey = GlobalKey<FormState>();

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      route: "color_entry",backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Text(
                    "Color Creation",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center( // Center the GST text and text box
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        const Text("Color"),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "* Enter color";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Enter color",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                    children: [
                      MaterialButton(
                        color: Colors.green,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {}
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
                              builder: (context) => ColourEntryView(),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
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
