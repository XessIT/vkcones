import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vinayaga_project/main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;




class CSVfileSelecter extends StatefulWidget {
  @override
  State<CSVfileSelecter> createState() => _CSVfileSelecterState();
}

class _CSVfileSelecterState extends State<CSVfileSelecter> {
  List <List<dynamic>>_data=[];
  String? _filepath;

  void pickFile()async{
    if (!kIsWeb && Platform.isAndroid) {
      // Handle web-specific file picking logic (if needed)
      print('Web platform detected. File picking not supported on web yet.');
      return;
    }
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if(result == null) return;
    print (result.files.first.name);
    _filepath =result.files.first.path!;
    final input =File(_filepath!).openRead();
    final fields =await input
    .transform(utf8.decoder)
    .transform(const CsvToListConverter())
    .toList();
    print(fields);
    print(result.files.first.name);
    _filepath = result.files.first.path!;
    print('Selected File Path: $_filepath');
    setState(() {
      _data =fields;
    });
  }
/*
//2nd try
  String _fileName = '';
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name!;
      });
    }
  }
*/

  /*//1st try
  void pickCSVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      print('File picker result: $result');

      print('File picked: ${result.files.first.name}');
      print('File path: ${result.files.first.path}');
      String filePath = result.files.first.path!;
      await uploadFile(filePath);
    } else {
      print("Canceled the selection");
      // User canceled the file picking
    }
  }
  Future<void> uploadFile(String filePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3309/upload'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'csvFile',
        filePath,
      ),
    );

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('File uploaded successfully');
      } else {
        print('Failed to upload file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }*/
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      route: "/csv_file_select",
      backgroundColor: Colors.white,
        body: Column(
          children: [
            SizedBox(width: 400,height: 70,
              child: TextFormField(
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: Icon(Icons.download,color: Colors.blue,), onPressed: () {  pickFile();},
                  )
                ),
              ),
            ),

            SizedBox(height: 20),
            Text('Selected File: $_filepath'),
          ],
        ),
    );
  }


}
