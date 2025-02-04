import 'package:flutter/material.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = {
    "field1": TextEditingController(),
    "field2": TextEditingController(),
    "field3": TextEditingController(),
  };
  bool _submitted = false; // Track if the form was submitted

  @override
  void initState() {
    super.initState();
    _controllers.forEach((key, controller) {
      controller.addListener(() {
        if (_submitted) {
          _formKey.currentState!
              .validate(); // Re-validate the form when user types
        }
      });
    });
  }

  String? validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null; // No error if the field has a value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _controllers["field1"],
                decoration: InputDecoration(
                    labelText: 'Field 1',
                    errorBorder: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder()),
                validator: validateField,
              ),
              TextFormField(
                controller: _controllers["field2"],
                decoration: InputDecoration(
                    labelText: 'Field 2',
                    errorBorder: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder()),
                validator: validateField,
              ),
              TextFormField(
                controller: _controllers["field3"],
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(),
                    labelText: 'Field 3',
                    errorBorder: OutlineInputBorder()),
                validator: validateField,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _submitted = true; // Mark form as submitted
                  });
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Form is valid!')),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
