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
  final bool readOnly;
  final String? Function(String?)? validator;
  final void Function()? onTap;

  const SurgeryAdmitTile({
    super.key,
    this.onTap,
    this.readOnly = false,
    required this.controller,
    required this.hinttext,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: TextFormField(
        showCursor: !readOnly,
        onTap: onTap,
        maxLength: 35,
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hinttext,
          labelText: hinttext,
          labelStyle: TextStyle(color: Colors.blueGrey[700]),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blueGrey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blueAccent.shade200, width: 2),
          ),
         
        ),
      ),
    );
  }
}

