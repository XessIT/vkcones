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
import 'package:vinayaga_project/sale/sample_dc.dart';
import 'dc.dart';


class HandbilldcIndividualPDFView extends StatefulWidget {
  String? dcNo;
  String? invNo;
  String? custCode;
  String? custMobile;
  String? date;
  String? custName;
  String? custAddress;
  String? pincode;
  String? grandTotal;
  String? supplyPlace;

  HandbilldcIndividualPDFView({
    required this.dcNo,
    required this.date,
    required this.custCode,
    required this.invNo,
    required this.custMobile,
    required this.custName,
    required this.custAddress,
    required this.pincode,
    required this.supplyPlace,
    required this.grandTotal,
  });

  @override
  State<HandbilldcIndividualPDFView> createState() =>
      _HandbilldcIndividualPDFViewState();
}

class _HandbilldcIndividualPDFViewState
    extends State<HandbilldcIndividualPDFView> {
  double totalGST = 0.0;
  int totalqty = 0;
  double total = 0.0;
  double amnt = 0.0;
  double totalamt = 0.0;

  Future<List<Map<String, dynamic>>> fetchUnitEntries(String dcNo) async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3309/hand_dc_item_view?dcNo=$dcNo'));

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
            '$formattedDate   $formattedTime',
            style: pw.TextStyle(fontSize: 6),
          ),
          pw.SizedBox(width: 365),
          pw.Padding(padding: pw.EdgeInsets.only(right:15),child:
          pw.Text(
            'Page $currentPage of $totalPages',
            style: pw.TextStyle(fontSize: 6),
          ),)

        ],
      ),
    );
  }






  Future<Uint8List> _generatePdfWithCopies(

      PdfPageFormat format, int copies, String dcNo,
      ) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    var font = await PdfGoogleFonts.crimsonTextBold();
    var font1 = await PdfGoogleFonts.crimsonTextSemiBold();

    final List<Map<String, dynamic>> data = await fetchUnitEntries(dcNo);
    totalGST = 0.0;
    totalqty = 0;
    amnt = 0.0;
    total=0.0;
    totalamt=0.0;
    int serialNumber = 1;

    pw.Widget _buildDataTable(List<Map<String, dynamic>> data, String? dcNo) {
      double totalAmount = 0.0; // Initialize totalAmount for each iteration

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
                  pw.Text('S.No',style: pw.TextStyle(fontSize: 9,font:font),),
                  pw.SizedBox(height: 3),
                ])),
              ),
              pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Item Group',style: pw.TextStyle(fontSize: 9,font:font)),
                pw.SizedBox(height: 3),

              ])),

              pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Item Name',style: pw.TextStyle(fontSize: 9,font:font)),
                pw.SizedBox(height: 3),
              ])),

              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Rate',style: pw.TextStyle(fontSize: 9,font:font),),
                  pw.SizedBox(height: 3),
                ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Quantity(Pack)',style: pw.TextStyle(fontSize: 9,font:font),),
                  pw.SizedBox(height: 3),
                ])),
              ),pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Amount',style: pw.TextStyle(fontSize: 9,font:font),),
                  pw.SizedBox(height: 3),
                ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('GST',style: pw.TextStyle(fontSize: 9,font:font),),
                  pw.SizedBox(height: 3),
                ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center(child:
                pw.Column(children: [
                  pw.SizedBox(height: 3),
                  pw.Text('Total',style: pw.TextStyle(fontSize: 9,font:font),),
                  pw.SizedBox(height: 3),
                ])),),
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
                          pw.Text('${serialNumber++}',style: pw.TextStyle(fontSize: 9,font:font1)),
                          pw.SizedBox(height: 3),
                        ]
                    ),
                  ),
                ),
                pw.Center(
                    child: pw.Column(
                        children: [
                          pw.SizedBox(height: 3),
                          pw.Text(data[i]['itemGroup'],style: pw.TextStyle(fontSize: 9,font:font1),),
                          pw.SizedBox(height: 3),
                        ])),
                pw.Center(child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['itemName'],style: pw.TextStyle(fontSize: 9,font:font1)),
                      pw.SizedBox(height: 3),
                    ])),

                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 0),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['rateperunit'].toString(),style: pw.TextStyle(fontSize: 9,font:font1)),
                        pw.SizedBox(height: 3),
                      ])),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 3),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Align(alignment: pw.Alignment.center,
                          child: pw.Text(data[i]['qty'].toString(),style: pw.TextStyle(fontSize: 9,font:font1)),),
                        pw.SizedBox(height: 3),
                      ])),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 3),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Align(alignment: pw.Alignment.topRight,
                          child:  pw.Text(data[i]['amount'].toString(),style: pw.TextStyle(fontSize: 9,font:font1)),),
                        pw.SizedBox(height: 3),
                      ])),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 3),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Align(alignment: pw.Alignment.topRight,
                          child:  pw.Text(data[i]['gstAmnt'].toString(),style: pw.TextStyle(fontSize: 9,font:font1)),),
                        pw.SizedBox(height: 3),
                      ])),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 3),
                  child: pw.Center( child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Align(alignment: pw.Alignment.center,
                          child: pw.Text(data[i]['totalAmnt'].toString(),style: pw.TextStyle(fontSize: 9,font:font1)),),
                        pw.SizedBox(height: 3),
                      ])),
                ),
              ],
            ),
        ],
      );
    }


    final int recordsPerPage=10;
    for (var i = 0; i < copies; i++) {
      for (var j = 0; j < data.length; j += recordsPerPage) {
        final List<Map<String, dynamic>> pageData =
        data.skip(j).take(recordsPerPage).toList();

        for (var item in pageData) {
          totalqty += int.parse(item['qty']);
          total += double.parse(item['rateperunit']);
          amnt += double.parse(item['amount']);
          totalGST += double.parse(item['gstAmnt']);
          totalamt += double.parse(item['totalAmnt']);
        }
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              final double pageHeight =  format.availableHeight;
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
                                      style: const pw.TextStyle(fontSize: 7),
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
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Handbill Delivery Challan ',
                    style: pw.TextStyle(fontSize: 14,font:font, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(top: 5.0),
                    child: pw.Container(
                      width: double.infinity,
                      height:pageHeight * 0.79,
                      padding: pw.EdgeInsets.all(0.0),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: pw.BorderRadius.circular(10.0),
                      ),
                      child: pw.Container(
                        child: pw.Column(
                          children: [

                            pw.Padding(
                              padding: pw.EdgeInsets.only(left:20,bottom: 5,top: 10),
                              child: pw.Row(
                                children: [
                                  pw.Text(
                                    "Customer Details",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12,
                                      font:font,
                                    ),
                                  ),
                                  pw.SizedBox(width: 180),
                                  pw.Column(
                                      children: [
                                        pw.Align(
                                          alignment: pw.Alignment.topRight,
                                          child: pw.Padding(
                                            padding: pw.EdgeInsets.only(left:80,top:10),
                                            child: pw.Column(
                                              crossAxisAlignment:
                                              pw.CrossAxisAlignment.end,
                                              children: [
                                                pw.SizedBox(
                                                  width: 50,
                                                  child: pw.Container(
                                                    child: pw.Column(
                                                      mainAxisAlignment:
                                                      pw.MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        pw.Align(
                                                          alignment: pw.Alignment.topLeft,
                                                          child: pw.Text(
                                                            widget.date != null
                                                                ? DateFormat("dd-MM-yyyy")
                                                                .format(DateTime.parse(
                                                                "${widget.date}"))
                                                                : "",
                                                            style: pw.TextStyle(
                                                                fontWeight:
                                                                pw.FontWeight.bold,
                                                                fontSize: 7,font:font1),
                                                          ),
                                                        ),
                                                        pw.SizedBox(height:5),
                                                        pw.Row(

                                                            children: [
                                                              pw.Align(
                                                                alignment: pw.Alignment.topLeft,
                                                                child: pw.Text(
                                                                  "DC Number   :   ",
                                                                  style: pw.TextStyle(
                                                                      fontWeight:
                                                                      pw.FontWeight.bold,
                                                                      fontSize: 7,font:font1),
                                                                ),
                                                              ),
                                                              pw.Align(
                                                                alignment: pw.Alignment.topLeft,
                                                                child: pw.Text(
                                                                  widget.dcNo.toString(),
                                                                  style: pw.TextStyle(
                                                                    // fontWeight:
                                                                    // pw.FontWeight.bold,
                                                                      fontSize: 7,font:font1),
                                                                ),
                                                              ),

                                                            ]

                                                        ),
                                                        pw.SizedBox(height:5),

                                                        pw.Row(children: [

                                                          pw.Align(
                                                            alignment: pw.Alignment.topLeft,
                                                            child: pw.Text(
                                                              "Invoice Number  :  ",
                                                              style: pw.TextStyle(
                                                                  fontWeight:
                                                                  pw.FontWeight.bold,
                                                                  fontSize: 7,font:font1),
                                                            ),
                                                          ),

                                                          pw.Align(
                                                            alignment: pw.Alignment.topLeft,
                                                            child: pw.Text(
                                                              widget.invNo.toString(),
                                                              style: pw.TextStyle(
                                                                // fontWeight:
                                                                // pw.FontWeight.bold,
                                                                  fontSize: 7,font:font1),
                                                            ),
                                                          ),
                                                        ])
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ]
                                  )
                                ],
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.only(left: 20 ),
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
                                              "Customer/Company Name",
                                              style: pw.TextStyle(
                                         fontSize: 9,
                                                  font:font1

                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Customer Address",
                                              style: pw.TextStyle(
                                                  fontSize: 9,
                                                  font:font1
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Pincode",
                                              style: pw.TextStyle(
                                                  fontSize: 9,
                                                  font:font1
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Place of supply",
                                              style: pw.TextStyle(
                                                  fontSize: 9,
                                                  font:font1
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              "Customer Mobile",
                                              style: pw.TextStyle(
                                               fontSize: 9,
                                                  font:font1
                                              ),
                                            ),
                                            pw.SizedBox(height: 3),
                                          ],
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: pw.EdgeInsets.all(3.0),
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(":", style: pw.TextStyle(fontSize: 9,font:font1)),
                                            pw.SizedBox(height: 3),
                                          ],
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: pw.EdgeInsets.all(4.0),
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(widget.custName.toString(), style: pw.TextStyle(fontSize: 9,font:font1,fontWeight: pw.FontWeight.bold)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(widget.custAddress.toString(), style: pw.TextStyle(fontSize: 9,font:font1)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(widget.pincode.toString(), style: pw.TextStyle(fontSize: 9,font:font1)),
                                            pw.SizedBox(height: 3),
                                            pw.Text(widget.supplyPlace.toString(), style: pw.TextStyle(fontSize: 9,font:font1)),
                                            pw.SizedBox(height: 3),
                                            pw.Text("+91 "+widget.custMobile.toString(), style: pw.TextStyle(fontSize: 9,font:font1)),
                                            pw.SizedBox(height: 3),
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
                                  style: pw.TextStyle(fontSize: 12,font:font,fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 5,),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child:   pw.Container(
                                width: 425,
                                child:_buildDataTable(pageData, widget.dcNo),
                              ),
                            ),
                            pw.SizedBox(height: 10,),

                            pw.Padding(
                              padding: pw.EdgeInsets.only(right: 22),
                              child: pw.Container(
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    pw.Text("Total", style: pw.TextStyle(fontSize: 9,font:font1)),
                                    pw.SizedBox(width: 10),
                                    pw.Container(
                                      height: 13,
                                      width: 50,
                                      //color: PdfColors.pink
                                      padding: pw.EdgeInsets.all(2.0),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(color: PdfColors.black),
                                        borderRadius: pw.BorderRadius.circular(1.0),
                                      ),
                                      child: pw.Text(total.toStringAsFixed(2),
                                          style: pw.TextStyle(fontSize: 9,font:font1)),
                                    ),
                                    pw.Container(
                                      height: 13,
                                      width: 50,
                                      //color: PdfColors.pink
                                      padding: pw.EdgeInsets.all(2.0),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(color: PdfColors.black),
                                        borderRadius: pw.BorderRadius.circular(1.0),
                                      ),
                                      child: pw.Text(totalqty.toString(),
                                          style: pw.TextStyle(fontSize: 9,font:font1)),
                                    ),
                                    pw.Container(
                                      height: 13,
                                      width: 55,
                                      //color: PdfColors.pink
                                      padding: pw.EdgeInsets.all(2.0),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(color: PdfColors.black),
                                        borderRadius: pw.BorderRadius.circular(1.0),
                                      ),
                                      child: pw.Text(amnt.toStringAsFixed(2),
                                          style: pw.TextStyle(fontSize: 9,font:font1)),
                                    ),
                                    pw.Container(
                                      height: 13,
                                      width: 50,
                                      //color: PdfColors.pink
                                      padding: pw.EdgeInsets.all(2.0),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(color: PdfColors.black),
                                        borderRadius: pw.BorderRadius.circular(1.0),
                                      ),
                                      child: pw.Text(totalGST.toStringAsFixed(2),
                                          style: pw.TextStyle(fontSize: 9,font:font1)),
                                    ),
                                    pw.Container(
                                      height: 13,
                                      width: 50,
                                      //color: PdfColors.pink
                                      padding: pw.EdgeInsets.all(2.0),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(color: PdfColors.black),
                                        borderRadius: pw.BorderRadius.circular(1.0),
                                      ),
                                      child: pw.Text(data[i]['grandTotal'].toString(), style: pw.TextStyle(fontSize: 9,font:font1)),
                                    ),],

                                ),
                              ),),

                            pw.SizedBox(height: 20,),

                          ],
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height:5),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 7),
                    child: pw.Container(
                      alignment: pw.Alignment.topRight,
                      child:_buildFooter(context, j ~/ recordsPerPage + 1, (data.length / recordsPerPage).ceil()),),),

                  // Initialize totalAmount for each iteration

                ],
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
            Navigator.push(context, MaterialPageRoute(builder: (context)=>SampleDC()));
          },
        ),
        title: Text("Hand bill Delivery Challan"),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1, widget.dcNo!),
        onPrinted: (context) {},
      ),
    );
  }
}
