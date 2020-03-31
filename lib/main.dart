import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'about.dart';
import 'contact.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _value = 6;
  bool _rememberMe = false;
  double _volume = 0.0;
  Item selectedUser;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSwitched = false;
  bool _progressBarActive = false;
  var _postsData = ["Apple", "Samsung", "Nokia"];
  Future<Album> _futureAlbum;
  final _formKey = GlobalKey<FormState>();
  String _formTextField = "";

  @override
  void initState() {
    super.initState();
    _futureAlbum = fetchAlbum();
  }

  Future<Null> _selectDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<Null> _selectTimePicker(BuildContext context) async {
    final TimeOfDay picked_s = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });
    if (picked_s != null && picked_s != _selectedTime)
      setState(() {
        _selectedTime = picked_s;
      });
  }

  Widget _buildExpansionPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((ItemExpansion item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: ListTile(
              title: Text(item.expandedValue),
              subtitle: Text('To delete this panel, tap the trash can icon'),
              trailing: Icon(Icons.delete),
              onTap: () {
                setState(() {
                  _data.removeWhere((currentItem) => item == currentItem);
                });
              }),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  buildList() {
    List<Widget> list = List<Widget>();
    _postsData.forEach((item) => list.add(Text(item)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        leading: Icon(Icons.menu),
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.videocam), onPressed: () => {}),
          IconButton(icon: Icon(Icons.account_circle), onPressed: () => {}),
          PopupMenuButton<Choice>(
            itemBuilder: (BuildContext context) {
              return choices.skip(2).map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Contact'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Setting'),
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          // - Buttons
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text("Raised Button"),
                    onPressed: () {
                      return showAlertDialog(context);
                    },
                    color: Colors.red,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    splashColor: Colors.grey,
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () {},
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text(
                      "Flat Button",
                    ),
                  ),
                ),
                Expanded(
                  child: OutlineButton(
                    onPressed: () {},
                    color: Colors.blue,
                    textColor: Colors.black,
                    splashColor: Colors.redAccent,
                    child: Text(
                      "Outline Button",
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // - Slider Volume
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          Container(
            child: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.volume_mute,
                        size: 30,
                      ),
                      Expanded(
                          child: Slider(
                              value: _value.toDouble(),
                              min: 1.0,
                              max: 10.0,
                              divisions: 10,
                              activeColor: Colors.red,
                              inactiveColor: Colors.black,
                              label: _value.toString(),
                              onChanged: (double newValue) {
                                setState(() {
                                  _value = newValue.round();
                                });
                              },
                              semanticFormatterCallback: (double newValue) {
                                return '${newValue.round()} dollars';
                              })),
                      Icon(
                        Icons.volume_up,
                        size: 30,
                      )
                    ])),
          ),
          // - Anchor Link
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'This is no Link, ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'but this is',
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://google.com');
                      },
                  ),
                ],
              ),
            ),
          ),
          // - Image
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          Container(
            child: Image.asset('images/1.jpg'),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Icons
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(children: <Widget>[
              Expanded(
                child: Icon(Icons.ac_unit, color: Colors.red, size: 25.0),
              ),
              Expanded(
                child:
                Icon(Icons.access_alarm, color: Colors.green, size: 25.0),
              ),
              Expanded(
                child: Icon(Icons.accessibility_new,
                    color: Colors.blue, size: 25.0),
              ),
              Expanded(
                child: Icon(Icons.phone, color: Colors.orange, size: 25.0),
              ),
            ]),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Icon Button
          Container(
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.volume_up),
                  tooltip: 'Increase volume by 10',
                  onPressed: () {
                    setState(() {
                      _volume += 10;
                    });
                  },
                ),
                Text('Volume : $_volume'),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.share),
                    color: Colors.amber,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Select Option
          Container(
            child: DropdownButton<Item>(
              hint: Text("Select an item"),
              value: selectedUser,
              onChanged: (Item item) {
                setState(() {
                  selectedUser = item;
                });
              },
              items: users.map((Item user) {
                return DropdownMenuItem<Item>(
                  value: user,
                  child: Row(
                    children: <Widget>[
                      user.icon,
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        user.name,
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Image Slider
          Container(
            child: CarouselSlider(
              height: 180.0,
              autoPlay: false,
              enlargeCenterPage: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              pauseAutoPlayOnTouch: Duration(seconds: 10),
              autoPlayCurve: Curves.fastOutSlowIn,
              items: [1, 2, 3, 4, 5].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(color: Colors.white),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset('images/1.jpg'),
                        ));
                  },
                );
              }).toList(),
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Checkbox
          Container(
            child: Row(
              children: <Widget>[
                Checkbox(
                    value: _rememberMe,
                    onChanged: (bool newValue) {
                      setState(() {
                        _rememberMe = newValue;
                      });
                    }),
                Text("I understand"),
                Checkbox(
                    value: !_rememberMe,
                    onChanged: (bool newValue) {
                      setState(() {
                        _rememberMe = newValue;
                      });
                    }),
                Text("Are you agree?"),
              ],
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Radio Box
          Container(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Gender: Male'),
                  leading: Radio(
                    value: SingingCharacter.male,
                    groupValue: _character,
                    onChanged: (SingingCharacter value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Gender: Female'),
                  leading: Radio(
                    value: SingingCharacter.female,
                    groupValue: _character,
                    onChanged: (SingingCharacter value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Date Picker
          Container(
            child: RaisedButton(
              child: Text("Calendar: Date Picker"),
              onPressed: () => _selectDatePicker(context),
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Time Picker
          Container(
            child: RaisedButton(
              color: Colors.green,
              textColor: Colors.white,
              child: Text("Calendar: Time Picker"),
              onPressed: () => _selectTimePicker(context),
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Switch
          Container(
            child: Row(
              children: <Widget>[
                Switch(
                  value: _isSwitched,
                  onChanged: (value) {
                    setState(() {
                      _isSwitched = value;
                    });
                  },
                ),
                Switch(
                    focusColor: Colors.red,
                    value: !_isSwitched,
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        _isSwitched = !value;
                      });
                    }),
                Text("Swith Example")
              ],
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Text Field
          Container(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Enter your name:',
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                hintText: 'Please enter your name.',
                helperText: "This is an helper text for you.",
              ),
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Alert Dialog
          Container(
            child: RaisedButton(
              child: Text("Show Alert Dialog"),
              onPressed: () {
                Alert(
                    context: context,
                    title: "RFLUTTER",
                    desc: "Flutter is awesome.")
                    .show();
              },
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Confirm Alert Dialog
          Container(
            child: RaisedButton(
              color: Colors.green,
              child: Text("Show Confirm Dialog"),
              onPressed: () {
                Alert(
                  context: context,
                  type: AlertType.error,
                  title: "RFLUTTER ALERT",
                  desc: "Flutter is more awesome with RFlutter Alert.",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Ok",
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      //width: 120,
                    ),
                    DialogButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      //width: 120,
                    )
                  ],
                ).show();
              },
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Bottom Sheet
          Container(
            child: RaisedButton(
              child: Text('Show Modal Bottom Sheet'),
              onPressed: () {
                _showModalSheet(context);
              },
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Expansion Panel
          Container(
            child: SingleChildScrollView(
              child: Container(
                child: _buildExpansionPanel(),
              ),
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Simple Dialog
          Container(
            child: FlatButton(
              color: Colors.deepPurpleAccent,
              textColor: Colors.white,
              child: Text("Simple Dialog"),
              onPressed: () {
                showDialog(
                    context: context,
                    child: AlertDialog(
                      title: Text("Title Here"),
                      content: Text("Description here."),
                    ));
              },
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Snack Bar
          Container(
            child: RaisedButton(
              child: Text('Show SnackBar: Not Working'),
              onPressed: () {},
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Card
          Container(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.album),
                    title: Text('Card: The Enchanted Nightingale'),
                    subtitle:
                    Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: const Text('BUY TICKETS'),
                        onPressed: () {},
                      ),
                      FlatButton(
                        child: const Text('LISTEN'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Chip
          Container(
            child: Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.grey.shade800,
                child: Text('AB'),
              ),
              label: Text('Chip: Aaron Burr'),
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Circular Progress Indicator
          Container(
            child: FlatButton(
              color: Colors.red,
              textColor: Colors.white,
              child: Text("Circular Indicator"),
              onPressed: () {
                setState(() {
                  _progressBarActive = true;
                });
              },
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Data Table
          Container(
            child: DataTable(
              sortColumnIndex: 0,
              sortAscending: true,
              columns: [
                DataColumn(label: Text('RollNo')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Class')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('1')),
                  DataCell(Text('Arya')),
                  DataCell(Text('6')),
                ]),
                DataRow(cells: [
                  DataCell(Text('12')),
                  DataCell(Text('John')),
                  DataCell(Text('9')),
                ]),
                DataRow(cells: [
                  DataCell(Text('42')),
                  DataCell(Text('Tony')),
                  DataCell(Text('8')),
                ]),
              ],
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // Tooltip
          Container(
            child: Tooltip(
              message: "This is tooltip button.",
              child: FlatButton(
                color: Colors.lime,
                child: Text("Tooltip Button"),
                onPressed: () {},
              ),
            ),
          ),
          // - Divider
          Divider(
            height: 40.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - List Tile
          Container(
            height: 220.0,
            child: ListView(
              children: <Widget>[
                Card(child: ListTile(title: Text('One-line ListTile'))),
                Card(
                  child: ListTile(
                    leading: FlutterLogo(),
                    title: Text('One-line with leading widget'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('One-line with trailing widget'),
                    trailing: Icon(Icons.more_vert),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: FlutterLogo(),
                    title: Text('One-line with both widgets'),
                    trailing: Icon(Icons.more_vert),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('One-line dense ListTile'),
                    dense: true,
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: FlutterLogo(size: 56.0),
                    title: Text('Two-line ListTile'),
                    subtitle: Text('Here is a second line'),
                    trailing: Icon(Icons.more_vert),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: FlutterLogo(size: 72.0),
                    title: Text('Three-line ListTile'),
                    subtitle: Text(
                        'A sufficiently long subtitle warrants three lines.'),
                    trailing: Icon(Icons.more_vert),
                    isThreeLine: true,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Stepper
          Container(
            child: Stepper(
              steps: [
                Step(
                  title: Text("First"),
                  subtitle: Text("This is our first article"),
                  content: Text(
                      "In this article, I will tell you how to create a page."),
                  isActive: true,
                ),
                Step(
                    title: Text("Second"),
                    subtitle: Text("Constructor"),
                    content: Text("Let's look at its construtor."),
                    state: StepState.editing,
                    isActive: false),
              ],
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - GridView
          Container(
            height: 220.0,
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              controller: ScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: List.generate(4, (index) {
                return Container(
                  height: 150.0,
                  color: Colors.green,
                  margin: new EdgeInsets.all(1.0),
                  child: Center(
                    child: Text(
                      'A + $index',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40.0,
                          backgroundColor: Colors.green),
                    ),
                  ),
                );
              }),
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Looping
          Container(
            child: Row(
              children: buildList(),
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          Container(
            child: FutureBuilder<Album>(
              future: _futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    "Title: " + snapshot.data.title,
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 24,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Form Validation
          Container(
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Enter your name:',
                        hintText: 'Please enter your name.',
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onSaved: (String val) {
                        _formTextField = val;
                      }),
                  RaisedButton(
                    child: Text('Submit'),
                    color: Colors.green,
                    textColor: Colors.white,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        showDialog(
                            context: context,
                            child: AlertDialog(
                              title: Text("Dialog:"),
                              content: Text(_formTextField),
                            ));
                      }
                    },
                  ),
                ])),
          ),
          Divider(
            height: 50.0,
            thickness: 10.0,
            color: Colors.red,
          ),
          // - Navigation
          Container(
            child: Row(
              children: <Widget>[
                FlatButton(
                  child: Text("Home"),
                  onPressed: () {},
                ),
                FlatButton(
                  child: Text("About"),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutPage()));
                  },
                ),
                FlatButton(
                  child: Text("Contact"),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ContactPage()));
                  },
                ),
              ],
            ),
          )
          // - Simple App
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 40.0,
            height: 40.0,
            child: FloatingActionButton(
              onPressed: () {
                _settingModalBottomSheet(context);
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.orange,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          FloatingActionButton(
            heroTag: "btn2",
            child: Icon(Icons.keyboard_arrow_up),
            backgroundColor: Colors.green,
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            title: Text('Messages'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text('Profile')),
        ],
      ),
    );
  }
}

final animalList = ['Horse', 'Cow', 'Camel', 'Sheep', 'Goat'];

enum SingingCharacter { male, female }

SingingCharacter _character = SingingCharacter.male;

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Car', icon: Icons.directions_car),
  const Choice(title: 'Bicycle', icon: Icons.directions_bike),
  const Choice(title: 'Boat', icon: Icons.directions_boat),
  const Choice(title: 'Bus', icon: Icons.directions_bus),
  const Choice(title: 'Train', icon: Icons.directions_railway),
  const Choice(title: 'Walk', icon: Icons.directions_walk),
];

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("My title"),
    content: Text("This is my message."),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

List<Item> users = <Item>[
  const Item(
      'Android',
      Icon(
        Icons.android,
        color: const Color(0xFF167F67),
      )),
  const Item(
      'Flutter',
      Icon(
        Icons.flag,
        color: const Color(0xFF167F67),
      )),
  const Item(
      'ReactNative',
      Icon(
        Icons.format_indent_decrease,
        color: const Color(0xFF167F67),
      )),
  const Item(
      'iOS',
      Icon(
        Icons.mobile_screen_share,
        color: const Color(0xFF167F67),
      )),
];

void _settingModalBottomSheet(context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.music_note),
                  title: Text('Music'),
                  onTap: () => {}),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Video'),
                onTap: () => {},
              ),
              ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  onTap: () => {}),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Call'),
                onTap: () => {},
              ),
            ],
          ),
        );
      });
}

void _showModalSheet(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          child: Text('Hello From Modal Bottom Sheet'),
          padding: EdgeInsets.all(40.0),
        );
      });
}

class ItemExpansion {
  ItemExpansion({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<ItemExpansion> generateItems(int numberOfItems) {
  return List.generate(numberOfItems, (int index) {
    return ItemExpansion(
      headerValue: 'Panel $index',
      expandedValue: 'This is item number $index',
    );
  });
}

List<ItemExpansion> _data = generateItems(2);

class Album {
  final int userId;
  final int id;
  final String title;

  Album({this.userId, this.id, this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

Future<Album> fetchAlbum() async {
  final response =
  await http.get('https://jsonplaceholder.typicode.com/albums/1');

  if (response.statusCode == 200) {
    return Album.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}
