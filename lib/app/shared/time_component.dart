import 'package:flutter/material.dart';

class TimeComponent extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onSelectedTime;

  TimeComponent({
    Key key,
    this.date,
    this.onSelectedTime,
  }) : super(key: key);

  @override
  _TimeComponentState createState() => _TimeComponentState();
}

class _TimeComponentState extends State<TimeComponent> {
  final List<String> _hours = List.generate(24, (index) => index++).map((h) => '${h.toString().padLeft(2, '0')}').toList();
  final List<String> _mins = List.generate(60, (index) => index++).map((h) => '${h.toString().padLeft(2, '0')}').toList();
  final List<String> _secs = List.generate(60, (index) => index++).map((h) => '${h.toString().padLeft(2, '0')}').toList();

  String _hoursSelected = '00';
  String _minsSelected = '00';
  String _secsSelected = '00';

  void invokeCallback() {
    var newDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      int.parse(_hoursSelected),
      int.parse(_minsSelected),
      int.parse(_secsSelected),
    );
    widget.onSelectedTime(newDate);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBox(_hours, (String value) {
          setState(() {
            _hoursSelected = value;
            invokeCallback();
          });
        }),
        _buildBox(_mins, (String value) {
          setState(() {
            _minsSelected = value;
            invokeCallback();
          });
        }),
        _buildBox(_secs, (String value) {
          setState(() {
            _secsSelected = value;
            invokeCallback();
          });
        }),
      ],
    );
  }

  Widget _buildBox(List<String> options, ValueChanged<String> onChange) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            spreadRadius: 0,
            blurRadius: 10,
            color: Colors.grey[800], //Theme.of(context).primaryColor,
            offset: Offset(2, 5),
          ),
        ],
      ),
      child: ListWheelScrollView(
        onSelectedItemChanged: (value) => onChange(value.toString().padLeft(2, '0')),
        itemExtent: 60,
        perspective: 0.007,
        physics: FixedExtentScrollPhysics(),
        children: options
            .map<Text>((e) => Text(
                  e,
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
