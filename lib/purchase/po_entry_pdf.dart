
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart'as http;
import 'package:vinayaga_project/purchase/po_creations.dart';

class PoentryPDF extends StatefulWidget {
  String? poNo;
  String? date;
  String? supName;
  String? supCode;
  String? supAddress;
  String? supMobile;
  //String? deliveryType;
  String? deliveryDate;

  PoentryPDF({super.key,
    required this.poNo,
    required this.date,
    required this.supCode,
    required this.supMobile,
    required this.supAddress,
    required this.supName,
    //required this.deliveryType,
    required this.deliveryDate,
  });

  @override
  State<PoentryPDF> createState() =>
      _PoIndividualReportState();
}

class _PoIndividualReportState
    extends State<PoentryPDF> {
  int totalqty = 0;
  Future<List<Map<String, dynamic>>> fetchUnitEntries(String PoNumber) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/po_view_item?poNo=$PoNumber'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }



  Future<List<Map<String, dynamic>>> fetchEntries(String supcode) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/fetch_sup_details?supCode=$supcode'));
      if (response.statusCode == 200) {
        final List<dynamic> customerdata = json.decode(response.body);
        return customerdata.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error loading unit entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unit entries: $e');
    }
  }

  String formatDate(String? inputDate) {
    if (inputDate != null && inputDate.isNotEmpty) {
      try {
        final parsedDate = DateFormat("dd-MM-yyyy").parseStrict(inputDate);
        return DateFormat("dd-MM-yyyy").format(parsedDate.toLocal());
      } catch (e) {
        // Handle the parsing error, return an empty string or another default value
        print("Error parsing date: $e");
      }
    }
    return "";
  }
  pw.Widget _buildFooter(pw.Context context, int currentPage, int totalPages) {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Format the date
    String formattedDate = DateFormat('dd-MM-yyy').format(now);

    // Format the time in AM/PM
    String formattedTime = DateFormat('hh.mm a').format(now);

    return pw.Container(
      child: pw.Row(
        //mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '       $formattedDate   $formattedTime',
            style: pw.TextStyle(fontSize:4),
          ),
          pw.SizedBox(width: 393),
          pw.Padding(
            padding: pw.EdgeInsets.only(right:0),
            child:
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 4),
            ),),

        ],
      ),
    );
  }
  int serialNumber = 1;
  DateTime currentDate = DateTime.now();


  pw.Widget _buildDataTable(List<Map<String, dynamic>> data, String? poNum) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('S.No',style: pw.TextStyle(fontSize:9),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Product Code',style: pw.TextStyle(fontSize:9)),
              pw.SizedBox(height: 3),

            ])),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Product Name',style: pw.TextStyle(fontSize:9)),
              pw.SizedBox(height: 3),
            ])),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Unit',style: pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 3),
            ])),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Quantity',style: pw.TextStyle(fontSize: 9),),
                pw.SizedBox(height: 3),
              ])),
            ),
          ],
        ),
        for (int i = 0; i < data.length; i++)
          pw.TableRow(
            children: [
              pw.Center(
                child: pw.Padding(
                  padding: pw.EdgeInsets.only(left: 0),
                  child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text((i + 1).toString(),style: pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 3),
                      ]
                  ),
                ),
              ),
              pw.Center(
                  child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['prodCode'],style: pw.TextStyle(fontSize: 9),),
                        pw.SizedBox(height: 3),
                      ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data[i]['prodName'],style: pw.TextStyle(fontSize: 9)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data[i]['unit'],style: pw.TextStyle(fontSize: 9)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['qty'],style: pw.TextStyle(fontSize:9)),
                      pw.SizedBox(height: 3),
                    ])),
              ),
            ],
          ),
      ],
    );
  }


  Future<Uint8List> _generatePdfWithCopies(
      PdfPageFormat format, int copies, String invNo,String supCode,) async {
    final pdf = pw.Document();
    // final image = await imageFromAssetBundle("assets/pillaiyar.png");
    // final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    // final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    //final ttf = pw.Font.ttf(fontData.buffer.asByteData());


    final List<Map<String, dynamic>> supdata = await fetchEntries(supCode);
    final List<Map<String, dynamic>> data = await fetchUnitEntries(invNo);
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    totalqty = 0;

    int recordsPerPage = 10;
    final filteredData = data.where((item) => item['poNo'] == invNo).toList();

    for (var i = 0; i < copies; i++) {
      for (var j = 0; j < filteredData.length; j += recordsPerPage) {
        recordsPerPage = (j == 0) ? 10 : 15;
        final List<Map<String, dynamic>> pageData =
        filteredData.skip(j).take(recordsPerPage).toList();
        for (var item in pageData) {
          totalqty += int.parse(item['qty'].toString()) ?? 0;
        }
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              final double pageHeight = j == 0 ? format.availableHeight : format.availableHeight +80;
              return pw.Padding(padding: pw.EdgeInsets.only(top: 5),
                  child:
                  pw.Column(
                    children: [
                      if (j == 0)
                        pw.Padding(
                          padding:pw.EdgeInsets.only(top: 5),
                          child:
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
                                    pw.SizedBox(height: 7),
                                    pw.Text("(Manufactures of : QUALITY PAPER CONES)",
                                        style: pw.TextStyle(
                                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    pw.SizedBox(height: 7),
                                    pw.Container(
                                        constraints: const pw.BoxConstraints(
                                          maxWidth: 300,
                                        ),
                                        child: pw.Text(
                                            "5/624-I5,SOWDESWARI \n"
                                                "NAGAR,VEPPADAI,ELANTHAKUTTAI(PO)TIRUCHENGODE(T.K)\n"
                                                "NAMAKKAL-638008 ",
                                            style: const pw.TextStyle(fontSize: 6),
                                            textAlign: pw.TextAlign.center))
                                  ]), ),

                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(top:20),
                                  child: pw.Container(
                                      height: 70,
                                      width: 70,
                                      child: pw.Container(
                                        child: pw.Image(image1,
                                          // ),
                                        ),
                                      )),)
                              ],
                            ),),),
                      pw.Divider(),
                      pw.Text(
                        'Purchase Order',
                        style: pw.TextStyle(fontSize: 14 , fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height:5),

                      pw.Padding(
                        padding: pw.EdgeInsets.only(top: 5.0),
                        child: pw.Expanded( child: pw.Container(
                          height:pageHeight * 0.55,
                          //   width: double.infinity,
                          padding: pw.EdgeInsets.all(0.0),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey),
                            borderRadius: pw.BorderRadius.circular(10.0),
                          ),

                          child: pw.Container(


                            child: pw.Column(
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(left:20,top: 10),
                                  child: pw.Row(
                                    children: [
                                      pw.Text(
                                        "Supplier Details",
                                        style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: pw.EdgeInsets.only(left:300),
                                        child: pw.Align(
                                          alignment: pw.Alignment.topRight,
                                          child: pw.SizedBox(
                                            width: 50,
                                            child: pw.Container(
                                              width: 50,
                                              child: pw.Column(
                                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                                children: [
                                                  pw.Text(
                                                    widget.date != null
                                                        ? DateFormat("dd-MM-yyyy").format(DateTime.parse("${widget.date}").toLocal())
                                                        : "",
                                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 5),
                                                  ),
                                                  pw.Divider(
                                                    color: PdfColors.grey,
                                                  ),
                                                  pw.Text(
                                                    "PO Number",
                                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 5),
                                                  ),
                                                  pw.SizedBox(height: 5),
                                                  pw.Text(
                                                    widget.poNo.toString(),
                                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 5),
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
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(left: 20,bottom: 10 ),
                                  child: pw.Column(
                                    children: [
                                      pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.start,
                                        children: [
                                          pw.Padding(
                                            padding: pw.EdgeInsets.all(3.0),
                                            child: pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text(
                                                  "Supplier Code",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                                pw.Text(
                                                  "Supplier Name",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                                pw.Text(
                                                  "Supplier Address",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                                pw.Text(
                                                  "Supplier Pincode",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                                pw.Text(
                                                  "Supplier Mobile",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                // pw.SizedBox(height: 5),
                                                // pw.Text(
                                                //   "Delivery Type",
                                                //   style: pw.TextStyle(
                                                //     fontSize: 10,
                                                //   ),
                                                // ),
                                                pw.SizedBox(height: 5),
                                                pw.Text(
                                                  "Delivery Date",
                                                  style: pw.TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                pw.SizedBox(height: 5),
                                              ],
                                            ),
                                          ),
                                          pw.Padding(
                                            padding: pw.EdgeInsets.all(3.0),
                                            child: pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                // pw.SizedBox(height: 5),
                                                // pw.Text(":", style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                              ],
                                            ),
                                          ),
                                          pw.Padding(
                                            padding: pw.EdgeInsets.all(3.0),
                                            child:
                                            pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: [
                                                pw.Text(widget.supCode.toString(), style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(widget.supName.toString(), style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold)),
                                                pw.SizedBox(height: 4),
                                                pw.Text(supdata[0]["supAddress"].toString(), style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text(supdata[0]["pincode"].toString(), style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                pw.Text("+91 "+supdata[0]["supMobile"].toString(), style: pw.TextStyle(fontSize: 10,)),
                                                pw.SizedBox(height: 5),
                                                // pw.Text(widget.deliveryType.toString(), style: pw.TextStyle(fontSize: 10,)),
                                                pw.Text(
                                                  widget.deliveryDate != null
                                                      ? formatDate(widget.deliveryDate)
                                                      : "",
                                                  style: pw.TextStyle(fontSize: 10),
                                                ),
                                                pw.SizedBox(height:4),
                                                pw.Text("")

                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                pw.Align(
                                  alignment: pw.Alignment.topLeft,
                                  child: pw.Padding(
                                    padding: pw.EdgeInsets.only(left:20,bottom: 10,top: 10),
                                    child: pw.Text(
                                      "Product Details",
                                      style: pw.TextStyle(fontSize: 12,fontWeight: pw.FontWeight.bold),
                                    ),
                                  ),
                                ),
                                pw.Container(
                                   //height:200,
                                    child: pw.Column(
                                        children: [
                                          pw.Padding(
                                            padding: pw.EdgeInsets.all(8),
                                            child:   pw.Container(
                                              width: 425,
                                              child:_buildDataTable(pageData, widget.poNo),
                                            ),
                                          ),
                                          if (j == filteredData.length)
                                            pw.Padding(
                                              padding: pw.EdgeInsets.only(right: 22),
                                              child: pw.Container(
                                                child: pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                                  children: [
                                                    pw.Text("Total", style: pw.TextStyle(fontSize: 6)),
                                                    pw.SizedBox(width: 6),

                                                    pw.Container(
                                                      height: 13,
                                                      width: 65,
                                                      //color: PdfColors.pink
                                                      padding: pw.EdgeInsets.all(2.0),
                                                      decoration: pw.BoxDecoration(
                                                        border: pw.Border.all(color: PdfColors.black),
                                                        borderRadius: pw.BorderRadius.circular(1.0),
                                                      ),
                                                      child: pw.FittedBox(
                                                        fit: pw.BoxFit.scaleDown,
                                                        child:
                                                        pw.Text(totalqty.toString(),
                                                            style: pw.TextStyle(fontSize: 6)),
                                                        alignment: pw.Alignment.center,
                                                      ),
                                                    ),


                                                  ],
                                                ),


                                              ),
                                            ),

                                        ]

                                    )
                                ),
                                pw.SizedBox(height:130),

                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 380),
                                  child:pw.Text("Terms & Conditions",style:pw.
                                  TextStyle(fontSize: 8,),),),
                                pw.SizedBox(height: 10),
                                pw.Padding(
                                  padding:pw.EdgeInsets.only(right:230),
                                  child:
                                  pw.Column(
                                      crossAxisAlignment:pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text("*  Products may be returned within [2] days, subject to our return policy. ",
                                          style:pw.TextStyle(fontSize: 6,),
                                        ),
                                        pw.SizedBox(height: 5),
                                        pw.Text("*  Payment is due upon receipt of invoice, unless otherwise agreed in writing.",
                                          style:pw.TextStyle(fontSize:6,),
                                        ),
                                        pw.SizedBox(height: 5),
                                        pw.Text("*  Delivery dates are estimates; delays do not constitute a breach of contract.",
                                          style:pw.TextStyle(fontSize: 6,),
                                        ),
                                      ]
                                  ),),
                              ],
                            ),
                          ),
                        ),),
                      ),
                      pw.SizedBox(height: 5,),
                      pw.Container(
                        /*alignment: pw.Alignment.topRight,*/
                        child:_buildFooter(context, j ~/ recordsPerPage + 1, (data.length / recordsPerPage).ceil()),),

                    ],
                  )
              );
            },
          ),
        );}
    }
    return pdf.save();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>PoCreation()));
          },
        ),
        title: Text("Purchase Order"),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1, widget.poNo!,widget.supCode!),
        onPrinted: (context) {},
      ),
    );
  }
}

