import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'DbConnect.dart';
import 'main.dart';
import 'model/Event.dart';


class AddEvent extends StatefulWidget {
  final int year;
  final int month;
  final int day;

  AddEvent({Key key, @required this.year,this.month,this.day}) : super(key: key);

  @override
  AddEventState createState() => new AddEventState(year: year,month: month,day: day);
}
class AddEventState extends State<AddEvent>{
  final int year;
  final int month;
  final int day;
  var fromdate;
  var todate;
  AddEventState({Key key, @required this.year,this.month,this.day}){
    fromdate=DateTime(year,month,day).toString();
    todate=DateTime(year,month,day).toString();
  }

  final eventnameController = TextEditingController();

  final _formKey1 = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DbConnect dbConnect=DbConnect.instance;

  String _selectedtype="allday";
  var _isButtonEnabled = false;
  bool notwholeday=false;

  int repeat=1;

  bool is_successfullypushedtodb=false;

  bool is_todatechanged=false;

  ////////////////////////////////////////
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    eventnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dropdownValue = "No Repeat-Only Once";

    return Scaffold(
        appBar: AppBar(
            title: Text("Add New Event")
        ),
        body: Container(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Form(
                  key: _formKey1,
                  child: Container(
                          constraints: BoxConstraints(maxHeight: 200),
                          margin: EdgeInsets.only(left: 15.0,right: 15.0,top: 20.0,bottom: 10.0),
                          child: TextFormField(
                            // maxLines: 2,
                            controller:eventnameController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              icon: const Icon(Icons.meeting_room),
                              hintText: 'Event Description',
                              // enabled: false,
                            ),
                            validator: (value) {

                              if (value.isEmpty||value==null||value.trim()==""||value.trim()==null) {
                                _isButtonEnabled = false;
                                return 'Please Enter Valid Event Details';
                              }
                              /*  if(is_duplicating(value)){
                                _isButtonEnabled = false;
                                return 'You already have a class with this name.\nPlease enter valid class name';
                              }*/

                              _isButtonEnabled = true;
                              return null;
                            },
                          ),
                        ),
                    ),

                     Expanded(
                       child: Column(
                         children: [
                        Container(
                              child: Column(
                                children: [
                                  DateTimePicker(
                                    type: DateTimePickerType.dateTimeSeparate,
                                    dateMask: 'd MMM, yyyy',
                                    initialValue: DateTime(year,month,day).toString(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    icon: Icon(Icons.event),
                                    dateLabelText: 'Date',
                                    timeLabelText: "Time",
                                    onChanged: (val) => {
                                     // print(val),
                                      this.setState(() {
                                        fromdate=val;
                                      })
                                    },
                                    validator: (val) {
                                      //print(val);
                                      return null;
                                },
                                //onSaved: (val) => print(val),
                              ),
                                 Container(
                                   padding: EdgeInsets.only(left: 10.0,top: 20.0,right: 5.0,bottom: 5.0),
                                   child: DropdownButton<String>(
                                     value: dropdownValue,
                                     icon: const Icon(Icons.arrow_downward),
                                     iconSize: 34,
                                     elevation: 26,
                                     focusColor: Colors.lightBlue,
                                     style: const TextStyle(
                                         color: Colors.blueGrey,
                                          fontSize: 20.0
                                     ),
                                     underline: Container(
                                       height: 2,
                                       color: Colors.indigo[900],
                                     ),
                                     onChanged: (String newValue) {
                                       setState(() {
                                         dropdownValue = newValue;
                                       });
                                     },
                                     items: <String>['No Repeat-Only Once', 'Repeat Daily', 'Repeat for WeekDays']
                                         .map<DropdownMenuItem<String>>((String value) {
                                       return DropdownMenuItem<String>(
                                         value: value,
                                         child: Text(value),
                                       );
                                     }).toList(),
                                   ),
                                 )

                                ],
                              ),
            padding: EdgeInsets.only(left: 8.0,right: 8.0,top: 20.0,bottom: 65.0),
                            ),
                        Container(
                          child: FloatingActionButton.extended(
                            label: Text("Save"),
                            onPressed:()=>{
                              if (_formKey1.currentState.validate()) {
                                addeventtodb(),
                                Navigator.pop(context),
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context) => MyApp()
                                    )
                                ),
                               // _showToast(_scaffoldKey.currentContext),
                              },
                            },
                            heroTag: "btn4",
                          ),
                          padding: EdgeInsets.only(top:15.0),
                        ),
                         ],
                       ),
                     ),
              ]
          ),
        ),
    );
  }

  void addeventtodb(){
    if(!is_todatechanged){
      todate=DateTime.parse(fromdate).add(Duration(minutes: 1)).toString();
    }
     print("before insert : "+eventnameController.text+" "+fromdate+" "+todate+" "+repeat.toString());
    Event event= new Event(eventname: eventnameController.text,fromdate: fromdate,todate: todate,repeat: repeat);
    var val= dbConnect.addCalenderEvent(event);
    if(val!=null){//incorrect here..need to check whether val>0
      setState(() {
        is_successfullypushedtodb=true;
      });
    }else{
      is_successfullypushedtodb=false;
    }
   // var newDateTimeObj2 = new DateFormat("dd/MM/yyyy HH:mm:ss").parse("10/02/2000 15:13:09");
  }

  void _showToast(BuildContext context) {

    final scaffold =  _scaffoldKey.currentState;
    String message="";
    if(is_successfullypushedtodb==true){
      message= "Event Added!";
    }else{
      message= "Oops!Something went wrong";
    }
     scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: is_successfullypushedtodb?Colors.green:Colors.redAccent,
      ),
    );
  }

}
