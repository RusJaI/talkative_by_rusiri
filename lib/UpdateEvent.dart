import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tts_with_local_notif/LocalNotificationScreen.dart';
import 'DbConnect.dart';
import 'main.dart';
import 'model/Event.dart';


class UpdateEvent extends StatefulWidget {
  final Event event;

  UpdateEvent({Key key, @required this.event}) : super(key: key);

  @override
  UpdateEventState createState() => new UpdateEventState(event: event);
}
class UpdateEventState extends State<UpdateEvent>{
  final Event event;
  var fromdate;
  final eventnameController = TextEditingController();
  String dropdownValue;

  UpdateEventState({Key key, @required this.event}){
    dropdownValue = Event.getStringValueofFrequency(event.repeat);
    eventnameController.text=event.eventname;
    fromdate=event.fromdate;
  }


  final _formKey1 = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DbConnect dbConnect=DbConnect.instance;

  var _isButtonEnabled = false;
  bool notwholeday=false;

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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
              title: Text("Edit/Delete Event"),
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
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
                                      initialValue: Event.stringToDatetime(event.fromdate).toString(),
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
                                   ),

                          Container(
                            child: FloatingActionButton.extended(
                              label: Text("Save"),
                              onPressed:()=>{
                                if (_formKey1.currentState.validate()) {
                                  updateeventtodb(),
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
                            padding: EdgeInsets.only(top:20.0),
                          ),
                             Container(
                               child: FloatingActionButton.extended(
                                 label: Text("Delete Task"),
                                 backgroundColor: Colors.red,
                                 onPressed:()=>{
                                   dbConnect.deleteEvent(event.id),
                                     Navigator.pop(context),
                                     Navigator.push(context,
                                         MaterialPageRoute(
                                             builder: (context) => MyApp()
                                         )
                                     ),
                                     // _showToast(_scaffoldKey.currentContext),
                                 },
                                 heroTag: "btnDelete",
                               ),
                               padding: EdgeInsets.only(top:25.0),
                             ),

                                  ],
                                ),
                            //padding: EdgeInsets.only(left: 8.0,right: 8.0,top: 20.0,bottom: 40.0),
                            padding: EdgeInsets.only(left: 8.0,right: 8.0,),
                          ),
                           ],
                         ),
                       ),
                ]
            ),
          ),
      ),
    );
  }

  void updateeventtodb(){
    int drpdwn=Event.getIntValueofFrequency(dropdownValue);
     //print("before insert : "+eventnameController.text+" "+fromdate+""+drpdwn.toString());
    Event event_new= new Event(id:event.id,eventname: eventnameController.text,fromdate: fromdate,repeat: drpdwn);
    var val= dbConnect.updateEvent(event_new);
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
      message= "Success!";
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
