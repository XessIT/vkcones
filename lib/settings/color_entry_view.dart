import 'package:flutter/material.dart';
import '../main.dart';
class ColourEntryView extends StatefulWidget {
  const ColourEntryView({Key? key}) : super(key: key);

  @override
  State<ColourEntryView> createState() => _ColourEntryViewState();
}

class _ColourEntryViewState extends State<ColourEntryView> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        route: "colour_entry_view",
        body: SingleChildScrollView(
          child: Form(
            child: Column(
                children: [
                  SizedBox(height: 20,),
                  Text("Item Colour Report", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),),
                  SizedBox(height: 50,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                              border: TableBorder.all(),
                              defaultColumnWidth: const FixedColumnWidth(140.0),
                              columnWidths: const <int, TableColumnWidth>{

                              },
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children:[
                                //Table row starting
                                TableRow(
                                    children: [
                                      TableCell(
                                          child:Center(
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 8,),
                                                Text('S.No',),
                                                const SizedBox(height: 8,)
                                              ],
                                            ),)),
                                      //Meeting Name

                                      TableCell(
                                          child:Center(
                                            child: Text('Item Group',),)),
                                      TableCell(
                                          child:Center(
                                            child: Text('Action',
                                            ),)),



                                    ]),
                                // Table row end

                                //Table row start
                                TableRow(
                                  // decoration: BoxDecoration(color: Colors.grey[200]),
                                    children: [

                                      TableCell(child: Center(child: Column(
                                        children: [
                                          const SizedBox(height: 10,),
                                          Text(""),
                                          const SizedBox(height: 10,)
                                        ],
                                      ))),
                                      TableCell(child: Center(child: Column(
                                        children: [
                                          const SizedBox(height: 10,),
                                          Text(""),
                                          const SizedBox(height: 10,)
                                        ],
                                      ))),
                                      TableCell(child:Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 45,height: 30,
                                              child: MaterialButton(

                                                color: Colors.green.shade600,
                                                onPressed: (){
                                                 // Navigator.push(context, MaterialPageRoute(builder: (context)=>GstEdit()));
                                                },child:Icon(Icons.edit_note,color: Colors.white,),),
                                            ),
                                            const SizedBox(width: 5,),
                                            SizedBox(width: 45,height: 30,
                                              child: MaterialButton(
                                                color: Colors.red.shade600,
                                                onPressed: (){},child:Icon(Icons.delete,color: Colors.white,),),
                                            ),
                                          ],
                                        ),
                                      )
                                      ),




                                    ]
                                )
                              ]
                          )
                      ),
                    ),
                  ),
                ]),
          ),
        ) );
  }
}
