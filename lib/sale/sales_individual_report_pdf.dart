



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

class SalesIndividualReportPDFView extends StatefulWidget {

  final String? invoiceNo;
  final String? custName;
  final String? custCode;
  final String? custAddress;
  final String? grandtotal;
  final String? custpincode;
  final String? date;
  final String? transportNo;
  final int? custmobile;
final  String? customerData;

  SalesIndividualReportPDFView({
    required this.customerData ,Key? key,
    required this.invoiceNo,
    required this.custName,
    required this.custCode,
    required this.custAddress,
    required this.custmobile,
    required this.date,
    required this.grandtotal,
    required this.custpincode, required this.transportNo


  });

  @override
  State<SalesIndividualReportPDFView> createState() =>
      _SalesIndividualReportPDFViewState();
}

class _SalesIndividualReportPDFViewState
    extends State<SalesIndividualReportPDFView> {
  TextEditingController myTextController = TextEditingController();

  double totalAmountFromController = 0.0;
  double totalAmount = 0.0;
  double totalAmounts = 0.0;
  String? totalGSt;
  double totalGST = 0.0;
  double totalSales = 0.0;
  double totalqty = 0.0;

  // Initialize totalAmount

  Future<List<Map<String, dynamic>>> fetchUnitEntries(String invoiceNo) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3309/sales_item_view?invoiceNo=$invoiceNo'));

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

  pw.Widget _buildDataTable(List<Map<String, dynamic>> data, String? invoiceNo) {

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
                pw.Text('S.No',style: pw.TextStyle(fontSize: 9),),
                pw.SizedBox(height: 3),
              ])),
            ),
            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Item Group',style: pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 3),

            ])),

            pw.Center(child:
            pw.Column(children: [
              pw.SizedBox(height: 3),
              pw.Text('Item Name',style: pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 3),
            ])),

            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Rate/Cone',style: pw.TextStyle(fontSize: 9),),
                pw.SizedBox(height: 3),

              ])),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Quantity',style: pw.TextStyle(fontSize: 9),),
                pw.SizedBox(height: 3),
              ])),),

            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Amount',style: pw.TextStyle(fontSize: 9),),
                pw.SizedBox(height: 3),
              ])),),

            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('GST(%)',style: pw.TextStyle(fontSize: 9),),
                pw.SizedBox(height: 3),
              ])),),

            pw.Padding(
              padding: pw.EdgeInsets.only(right: 0),
              child: pw.Center(child:
              pw.Column(children: [
                pw.SizedBox(height: 3),
                pw.Text('Total',style: pw.TextStyle(fontSize: 9),),
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
                        pw.Text('${serialNumber++}',style: pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 3),
                      ]
                  ),
                ),
              ),
              pw.Center(
                  child: pw.Column(
                      children: [
                        pw.SizedBox(height: 3),
                        pw.Text(data[i]['itemGroup'],style: pw.TextStyle(fontSize: 9),),
                        pw.SizedBox(height: 3),
                      ])),
              pw.Center(child: pw.Column(
                  children: [
                    pw.SizedBox(height: 3),
                    pw.Text(data[i]['itemName'],style: pw.TextStyle(fontSize: 9)),
                    pw.SizedBox(height: 3),
                  ])),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['rate'],style: pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 3),

                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['qty'],style: pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 3),
                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['amt'],style: pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 3),
                    ])),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['amtGST'],style: pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 3),
                    ])),
              ),  pw.Padding(
                padding: pw.EdgeInsets.only(right: 0),
                child: pw.Center( child: pw.Column(
                    children: [
                      pw.SizedBox(height: 3),
                      pw.Text(data[i]['total'],style: pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 3),
                    ])),
              ),
            ],
          ),
      ],
    );
  }


  Future<Uint8List> _generatePdfWithCopies(

      PdfPageFormat format, int copies, String invoiceNo,
      ) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final image = await imageFromAssetBundle("assets/pillaiyar.png");
    final image1 = await imageFromAssetBundle("assets/sarswathi.png");
    final fontData = await rootBundle.load('assets/fonts/Algerian_Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final List<Map<String, dynamic>> data = await fetchUnitEntries(invoiceNo);
    totalGST = 0.0;
    totalSales = 0.0;
    totalqty = 0.0;


    int recordsPerPage ;
    for (var i = 0; i < copies; i++) {
      for (var j = 0; j < data.length; j += recordsPerPage) {
        recordsPerPage = (j == 0) ? 19 : 23;
        final List<Map<String, dynamic>> pageData =
        data.skip(j).take(recordsPerPage).toList();

        for (var item in pageData) {
          totalGST += double.parse(item['amtGST']);
          totalSales += double.parse(item['amt']);
          totalqty += double.parse(item['qty']);

        }
/*
        for (var item in pageData) {
          //totalGST += double.parse(item['amtGST']);
          totalSales += double.parse(item['amt']);
        }
*/

        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) {
              final double pageHeight = j == 0 ? format.availableHeight : format.availableHeight +90;
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
                                  ),
                                ),
                              )),
                        ],
                      ),),
                  pw.SizedBox(height: 5),
                  //pw.Divider(),
                  pw.Text(
                    'Sales Report',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),

                  pw.Padding(
                    padding: pw.EdgeInsets.only(top: 5.0),
                    child: pw.Container(
                      width: double.infinity,
                      height:pageHeight * 0.80,
                      padding: pw.EdgeInsets.all(0.0),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: pw.BorderRadius.circular(10.0),
                      ),
                      child: pw.Container(
                          child: pw.Column(children:[
                            pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Column(
                                      children: [
                                        pw.Row(
                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                          children: [
                                            pw.Align(
                                              alignment: pw.Alignment.topLeft,child:
                                            pw.Padding(
                                              padding: pw.EdgeInsets.only(right:0,bottom: 10,top: 10),
                                         child: pw.Text(
                                              "Customer Details",
                                              style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),)),
                                          ],
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
                                                          "Customer Code",
                                                          style: pw.TextStyle(
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(
                                                          "Customer/Company Name",
                                                          style: pw.TextStyle(
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(
                                                          "Customer Address",
                                                          style: pw.TextStyle(
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(
                                                          "Customer Pincode",
                                                          style: pw.TextStyle(
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(
                                                          "Customer Mobile",
                                                          style: pw.TextStyle(
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(
                                                          "Transport No",
                                                          style: pw.TextStyle(
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  pw.Padding(
                                                    padding: pw.EdgeInsets.all(3.0),
                                                    child: pw.Column(
                                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                      children: [
                                                        pw.Text(":", style: pw.TextStyle(fontSize: 9,)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(":", style: pw.TextStyle(fontSize: 9,)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(":", style: pw.TextStyle(fontSize: 9,)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(":", style: pw.TextStyle(fontSize: 9,)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(":", style: pw.TextStyle(fontSize: 9,)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(":", style: pw.TextStyle(fontSize: 9,)),
                                                      ],
                                                    ),
                                                  ),
                                                  pw.Padding(
                                                    padding: pw.EdgeInsets.all(4.0),
                                                    child: pw.Column(
                                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                      children: [
                                                        pw.Text(widget.custCode.toString(), style: pw.TextStyle(fontSize: 9,)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(widget.custName.toString(), style: pw.TextStyle(fontSize: 9,)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(widget.custAddress.toString(), style: pw.TextStyle(fontSize: 9,)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(widget.custpincode.toString(), style: pw.TextStyle(fontSize: 9,)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(widget.custmobile.toString(), style: pw.TextStyle(fontSize: 9,)),
                                                        pw.SizedBox(height: 3),
                                                        pw.Text(widget.transportNo.toString(), style: pw.TextStyle(fontSize: 9,)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                      ]),
                                  pw.Padding(
                                    padding: pw.EdgeInsets.only(right:10),
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Row(

                                          children: [
                                            pw.Text(
                                              "Date            ",
                                              style: pw.TextStyle(
                                                  fontSize: 7),
                                            ),
                                            pw.Text(
                                              widget.date != null
                                                  ? DateFormat("dd-MM-yyyy")
                                                  .format(DateTime.parse(
                                                  "${widget.date}").toLocal())
                                                  : "",
                                              style: pw.TextStyle(
                                                  fontSize: 7),
                                            ),

                                          ]
                                        ),
                                        pw.SizedBox(height:3),
                                        pw.Row(
                                          children: [
                                            pw.Text(
                                              "Invoice No  ",
                                              style: pw.TextStyle(
                                                                                                   fontSize: 7),
                                            ),
                                            pw.Text(
                                              " ${widget.invoiceNo.toString()}     ",
                                              style: pw.TextStyle(

                                                  fontSize: 7),
                                            ),

                                          ]
                                        ),
                                        pw.SizedBox(height:3),
                                        pw.Row(
                                          children: [
                                            pw.Text(
                                              "OrderNo     ",
                                              style: const pw.TextStyle(fontSize: 7),
                                            ),
                                           /* pw.Text(
                                              "${widget.customerData}     ",
                                              style: const pw.TextStyle(fontSize: 7),
                                            ),*/
                                          ]
                                        ),




                                      ]
                                  ),),




                                ]
                            ),
                            pw.Column(
                              children: [


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
                                pw.SizedBox(height: 5,),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(8),
                                  child:   pw.Container(
                                    width: 425,
                                    child:_buildDataTable(pageData, widget.invoiceNo),
                                  ),
                                ),
                                pw.SizedBox(height: 10,),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 21),
                                  child: pw.Container(
                                    child:
                                    pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.end,
                                        children: [
                                          pw.Text("Total",style: pw.TextStyle(fontSize: 9)),
                                          pw.SizedBox(width: 10,),

                                          pw.Padding(
                                            padding: pw.EdgeInsets.only(right: 0),
                                            child: pw.Container(
                                              padding: pw.EdgeInsets.all(2.0),
                                              decoration: pw.BoxDecoration(
                                                border: pw.Border.all(color: PdfColors.black),
                                                borderRadius: pw.BorderRadius.circular(1.0),
                                              ),
                                              child:
                                              pw.Row(
                                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                                children: [
                                                  //pw.Text("Total qty", style: pw.TextStyle(fontSize: 8)),
                                                  pw.SizedBox(width: 10),
                                                  pw.Text(totalqty.toStringAsFixed(2), style: pw.TextStyle(fontSize: 9)),
                                                ],
                                              ),),
                                          ),

                                          pw.Padding(
                                            padding: pw.EdgeInsets.only(right: 0),
                                            child: pw.Container(
                                              padding: pw.EdgeInsets.all(2.0),
                                              decoration: pw.BoxDecoration(
                                                border: pw.Border.all(color: PdfColors.black),
                                                borderRadius: pw.BorderRadius.circular(1.0),
                                              ),
                                              child:
                                              pw.Row(
                                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                                children: [
                                                  //pw.Text("Total Amount", style: pw.TextStyle(fontSize: 8)),
                                                  pw.SizedBox(width: 10),
                                                  pw.Text(totalSales.toStringAsFixed(2), style: pw.TextStyle(fontSize: 9)),
                                                ],
                                              ),),
                                          ),

                                          pw.Padding(
                                            padding: pw.EdgeInsets.only(right: 0),
                                            child: pw.Container(
                                              padding: pw.EdgeInsets.all(2.0),
                                              decoration: pw.BoxDecoration(
                                                border: pw.Border.all(color: PdfColors.black),
                                                borderRadius: pw.BorderRadius.circular(1.0),
                                              ),
                                              child:
                                              pw.Row(
                                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                                children: [
                                                  //pw.Text("Total GST:", style: pw.TextStyle(fontSize: 8)),
                                                  pw.SizedBox(width: 10),
                                                  pw.Text(totalGST.toStringAsFixed(2), style: pw.TextStyle(fontSize: 9)),
                                                ],
                                              ),),
                                          ),



                                          pw.Padding(
                                            padding: pw.EdgeInsets.only(right: 0),
                                            child: pw.Container(
                                              padding: pw.EdgeInsets.all(2.0),
                                              decoration: pw.BoxDecoration(
                                                border: pw.Border.all(color: PdfColors.black),
                                                borderRadius: pw.BorderRadius.circular(1.0),
                                              ),
                                              child:
                                              pw.Row(
                                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                                  children: [
                                                    pw.Text(    "    ${widget.grandtotal.toString()}",style: pw.TextStyle(fontSize: 9)),
                                                    //   pw.Text(    widget.grandtotal.toString(),style: pw.TextStyle(fontSize: 8)),
                                                  ]
                                              ),),
                                          ),
                                        ]
                                    ),),
                                ),




                               // pw.SizedBox(height: 20,),
                              ],
                            ),])
                      ),
                    ),
                  ),
                  pw.SizedBox(height:5,),

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
      appBar: AppBar(title: Text("Sales Report PDF"), centerTitle: true,),
      body: PdfPreview(
        build: (format) => _generatePdfWithCopies(format, 1, widget.invoiceNo!),
        onPrinted: (context) {},
      ),
    );
  }
}
