import 'package:flutter/material.dart';

class AppointmentTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hinttext;
  final TextInputType? keyboardType;

  const AppointmentTextfield({
    super.key,
    required this.controller,
    required this.hinttext,
    this.keyboardType,
  });

  void _increaseValue() {
    int currentValue = int.tryParse(controller.text) ?? 0;
    controller.text = (currentValue + 1).toString();
  }

  void _decreaseValue() {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      controller.text = (currentValue - 1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: 35,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: hinttext,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: keyboardType == TextInputType.number
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                      onTap: () {
                        _increaseValue();
                      },
                      child: Icon(Icons.keyboard_arrow_up)),
                  InkWell(
                      onTap: () {
                        _decreaseValue();
                      },
                      child: Icon(Icons.keyboard_arrow_down)),
                ],
              )
            : null,
      ),
    );
  }
}

class SurgeryAdmitTile extends StatelessWidget {
  final TextEditingController controller;
  final String hinttext;
  final TextInputType? keyboardType;

  const SurgeryAdmitTile({
    super.key,
    required this.controller,
    required this.hinttext,
    this.keyboardType,
  });

  void _increaseValue() {
    int currentValue = int.tryParse(controller.text) ?? 0;
    controller.text = (currentValue + 1).toString();
  }

  void _decreaseValue() {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      controller.text = (currentValue - 1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: 35,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: hinttext,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: keyboardType == TextInputType.number
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                      onTap: () {
                        _increaseValue();
                      },
                      child: Icon(Icons.keyboard_arrow_up)),
                  InkWell(
                      onTap: () {
                        _decreaseValue();
                      },
                      child: Icon(Icons.keyboard_arrow_down)),
                ],
              )
            : null,
      ),
    );
  }
}
