import 'package:flutter/material.dart';

class DashboardButton extends StatelessWidget {
  DashboardButton({@required this.title, @required this.onTap});
  final String title;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        height: MediaQuery.of(context).size.width / 4,
        child: Center(
          child: Text(title),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Color(0xFF607D8B),
          border: Border.all(width: 1),
        ),
      ),
    );
  }
}
