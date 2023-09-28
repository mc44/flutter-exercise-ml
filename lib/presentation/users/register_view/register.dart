import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../register_viewmodel/register_viewmodel.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final RegisterViewModel viewModel = RegisterViewModel();
  bool _roleError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Create a new user",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) => viewModel.name = value!,
                validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number'),
                onSaved: (value) => viewModel.number = value!,
                validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) => viewModel.email = value!,
                validator: (value) {
                  const emailPattern =
                      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
                  final regExp = RegExp(emailPattern);

                  if (value!.isEmpty) {
                    return 'This field cannot be empty';
                  } else if (!regExp.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Select Role:', style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text('Admin'),
                leading: Radio<String>(
                  value: 'Admin',
                  groupValue: viewModel.role,
                  onChanged: (String? value) {
                    setState(() {
                      viewModel.role = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Employee'),
                leading: Radio<String>(
                  value: 'Employee',
                  groupValue: viewModel.role,
                  onChanged: (String? value) {
                    setState(() {
                      viewModel.role = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                  print("Role is: ${viewModel.role}");
                    if (viewModel.role == null || viewModel.role!.isEmpty) {
                      setState(() {
                        _roleError = true;
                      });
                    } else {
                      setState(() {
                        _roleError = false;
                      });
                      _formKey.currentState!.save();
                      viewModel.registerUser();
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text('Register'),
              ),
              if (_roleError)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Please select a role.",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),

    ],
    ),
    ),
    ),
    );
  }
}