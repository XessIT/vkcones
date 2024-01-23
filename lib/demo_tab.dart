import 'package:flutter/material.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _field1FocusNode = FocusNode();
  final _field2FocusNode = FocusNode();
  final _field3FocusNode = FocusNode();
  final _field4FocusNode = FocusNode();

  @override
  void dispose() {
    _field1FocusNode.dispose();
    _field2FocusNode.dispose();
    _field3FocusNode.dispose();
    _field4FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Field 1'),
              textInputAction: TextInputAction.next,
              onEditingComplete: () => _field1FocusNode.nextFocus(),
              focusNode: _field1FocusNode,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Field 2'),
              textInputAction: TextInputAction.next,
              onEditingComplete: () => _field2FocusNode.nextFocus(),
              focusNode: _field2FocusNode,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Field 3'),
              textInputAction: TextInputAction.next,
              onEditingComplete: () => _field3FocusNode.nextFocus(),
              focusNode: _field3FocusNode,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Field 4'),
              textInputAction: TextInputAction.done,
              focusNode: _field4FocusNode,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyForm(),
  ));
}
