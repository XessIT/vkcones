

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AttendancePdf extends StatefulWidget {
  int sn = 0;
  final List<Map<String, dynamic>> customerData;


  AttendancePdf({
    required this.customerData,
  });

  @override
  State<AttendancePdf> createState() => _AttendancePdfState();
}

class _AttendancePdfState extends State<AttendancePdf> {
  double calculateTotalWorkingSalary(List<Map<String, dynamic>> filteredData) {
    double totalSalary = 0;
    for (var row in filteredData) {
      totalSalary += double.parse(row['working_salary'] ?? '0');
    }
    return totalSalary;
  }

  double getTotalWorkingSalary() {
    return calculateTotalWorkingSalary(widget.customerData);
  }

  final pw.TextStyle defaultTextStyle = pw.TextStyle(fontSize: 8);

  String formatTime(String timeString) {
    if (timeString != null && timeString != "00:00:00") {
      List<String> timeParts = timeString.split(':');

      if (timeParts.length == 3) {
        DateTime dateTime = DateTime(1970, 1, 1, int.parse(timeParts[0]), int.parse(timeParts[1]), int.parse(timeParts[2]));
        return DateFormat('h:mm a').format(dateTime);
      }
    }
    return "0";
  }

  String formatTimeOrZero(String timeString) {
    if (timeString != null && timeString != "00:00:00" && timeString != "0") {
      List<String> timeParts = timeString.split(':');

      if (timeParts.length == 3) {
        DateTime dateTime = DateTime(1970, 1, 1, int.parse(timeParts[0]), int.parse(timeParts[1]), int.parse(timeParts[2]));
        return DateFormat('h:mm a').format(dateTime);
      }
    }
    return "0";
  }
  String formatDuration(String durationInMinutes) {
    try {
      if (durationInMinutes != null) {
        int minutes = int.tryParse(durationInMinutes) ?? 0;
        Duration duration = Duration(minutes: minutes);

        int hours = duration.inHours;
        int remainingMinutes = duration.inMinutes.remainder(60);

        String formattedDuration = '';

        if (hours > 0) {
          formattedDuration += '$hours h';
        }

        if (remainingMinutes > 0) {
          if (hours > 0) {
            formattedDuration += ' ';
          }
          formattedDuration += '$remainingMinutes m';
        }

        return formattedDuration.trim();
      }
    } catch (e) {
      // Handle the exception, e.g., log the error or return a default value
      print('Error formatting duration: $e');
    }

    return ""; // Return a default value if there's an error
  }

  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
    // ... (rest of your code)
    // Get the current date and time
    DateTime now = DateTime.now();

    // Format the date
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);

    // Format the time in AM/PM
    String formattedTime = DateFormat('hh.mm a').format(now);


    return pw.Container(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$formattedDate   $formattedTime',
            style: pw.TextStyle(fontSize: 4),
          ),
          pw.SizedBox(width: 665),
          pw.Padding(padding: const pw.EdgeInsets.only(right: 20,),
            child:  pw.Text(
              'Page $currentPage of $totalPages',
              style: pw.TextStyle(fontSize: 4),
            ),)
        ],
      ),
    );
  }

  int serialNumber=1;
  Future<Uint8List> _generatePdfWithCopies(PdfPageFormat format, int copies) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final List<Map<String, dynamic>> customerData = widget.customerData;
    const int recordsPerPage = 11;

    for (var i = 0; i < copies; i++) {
      for (var j = 0; j < customerData.length; j += recordsPerPage) {
        final List<Map<String, dynamic>> pageData =
        customerData.skip(j).take(recordsPerPage).toList();
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              return pw.Column(
                children: [
                  if (j == 0)
                    pw.Container(
                      child:
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.only(top: 20,),
                            child:
                            pw.Container(
                                height: 70,
                                width: 70,
                                child: pw.Image(image)

                            ),),

                          pw.Padding(padding:pw.EdgeInsets.only(right: 10),
                            child:    pw.Column(children: [
                              pw.Text("VINAYAGA CONES",
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 20,

                                    fontWeight: pw.FontWeight.bold,)),
                              pw.SizedBox(height: 5),
                              pw.Text("(Manufactures of : QUALITY PAPER CONES)",
                                  style: pw.TextStyle(
                                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 5),
                              pw.Container(
                                  constraints: const pw.BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: pw.Text(
                                      "5/624-I5,SOWDESWARI \n"
                                          "NAGAR,VEPPADAI,ELANTHAKUTTAI(PO)TIRUCHENGODE(T.K)\n"
                                          "NAMAKKAL-638008 ",
                                      style: const pw.TextStyle(fontSize: 8),
                                      textAlign: pw.TextAlign.center))
                            ]), ),

                          pw.Padding(
                              padding: const pw.EdgeInsets.only(top:20),
                              child: pw.Container(
                                height: 70,
                                width: 70,
                                child: pw.Container(
                                  child: pw.Image(image1,
                                  ),
                                ),
                              )),
                        ],
                      ),),
                  pw.SizedBox(height: 1),
                  pw.Divider(),
                  pw.Text(
                    'Attendance Report',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Expanded(
                    child: pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Text('      S.No', style: defaultTextStyle.merge(pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(child: pw.Text('Date',
                                  style: pw.TextStyle(fontSize: 8,
                                      fontWeight: pw.FontWeight.bold)),
                              ),),
                            pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('Emp code',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ),
                            pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('Name',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ),
                            pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('shift',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ),
                            pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('check-in',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ),  pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('lunch_out',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ), pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('lunch_in',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ), pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('check_out',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ),
                            pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('late check-in',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ),
                            pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('Lunch late',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ),
                            pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('Early check_out',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ),
                            pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('remark',
                                      style: pw.TextStyle(fontSize: 8,
                                          fontWeight: pw.FontWeight.bold)),)
                            ),
                            // Add more Text widgets for additional columns if needed
                          ],
                        ),


                        ...pageData.asMap().entries.map((entry) {
                          int sn = entry.key + 1; // Calculate the S.No based on the entry index (starting from 1)
                          var data = entry.value;
                          return pw.TableRow(children: [
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child:
                                pw.Text('${serialNumber++}',style: pw.TextStyle(fontSize: 8)),
                              ),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(data["inDate"] != null
                                    ? DateFormat('yyyy-MM-dd').format(
                                  DateTime.parse("${data["inDate"]}").toLocal(),)
                                    : "",
                                    style: pw.TextStyle(fontSize: 8)),),
                            ),
                            pw.Container(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text(data['emp_code'].toString(),
                                      style: pw.TextStyle(fontSize: 8)),)
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(data['first_name'].toString(),
                                    style: pw.TextStyle(fontSize: 8)),),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(data['shiftType'].toString(),
                                    style: pw.TextStyle(fontSize: 8)),),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(
                                  formatTime(data['check_in']),
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(
                                  formatTimeOrZero(data['lunch_out']),
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(
                                  formatTimeOrZero(data['lunch_in']),
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(
                                  formatTime(data['check_out']),
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(
                                  formatDuration(data['latecheck_in']),
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(
                                  formatDuration(data['late_lunch'].toString()),
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(
                                  formatDuration(data['earlycheck_out']),
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                            pw.Container(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(data['remark'].toString(),
                                    style: pw.TextStyle(fontSize: 8)),),
                            ),
                          ]);
                        }
                        ).toList(),
                      ],
                    ),
                  ),

                  pw.Align(
                    alignment: pw.Alignment.bottomCenter,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.SizedBox(height: 20),
                        _buildFooter(context, j ~/ recordsPerPage + 1, (customerData.length / recordsPerPage).ceil()),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        );
      }
      //return pdf.save() ?? Uint8List(0);
    }
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance PDF"), centerTitle: true,),
      body:
      PdfPreview(
        build: (format) => _generatePdfWithCopies(
          PdfPageFormat.a4.copyWith(
            width: PdfPageFormat.a4.height,
            height: PdfPageFormat.a4.width,
          ),
          1,
        ),
        onPrinted: (context) {},
      ),
    );
  }
}

















