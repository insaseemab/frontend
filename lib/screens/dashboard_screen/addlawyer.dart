import 'package:flutter/material.dart';

class AddLawyerPage extends StatefulWidget {
  const AddLawyerPage({super.key});

  @override
  State<AddLawyerPage> createState() => _AddLawyerPageState();
}

class _AddLawyerPageState extends State<AddLawyerPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final specializationController = TextEditingController();
  final cityController = TextEditingController();
  final experienceController = TextEditingController();
  final casesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Lawyer"),
        backgroundColor: Color(0xFF6B4F3F),
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) => value!.isEmpty ? "Enter name" : null,
              ),

              // Specialization
              TextFormField(
                controller: specializationController,
                decoration: const InputDecoration(labelText: "Specialization"),
                validator: (value) =>
                    value!.isEmpty ? "Enter specialization" : null,
              ),

              // City
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "Location"),
                validator: (value) => value!.isEmpty ? "Location" : null,
              ),

              // Experience
              TextFormField(
                controller: experienceController,
                decoration: const InputDecoration(
                  labelText: "Experience (years)",
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Enter experience" : null,
              ),

              // Cases
              TextFormField(
                controller: casesController,
                decoration: const InputDecoration(labelText: "Total Cases"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter cases" : null,
              ),

              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newLawyer = {
                      "name": nameController.text,
                      "specialization": specializationController.text,
                      "Location": cityController.text,
                      "experience": "${experienceController.text} years",
                      "cases": casesController.text,
                      "rating": "0.0",
                      "status": "",
                    };

                    Navigator.pop(context, newLawyer);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4F3F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
