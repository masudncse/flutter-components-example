import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact"),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Contact Page...'),
          onPressed: () {},
        ),
      ),
    );
  }
}