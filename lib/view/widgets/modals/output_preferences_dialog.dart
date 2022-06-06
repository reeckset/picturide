import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picturide/model/output_preferences.dart';
import 'package:picturide/model/project.dart';

outputPreferencesDialog(Project project, BuildContext context) async {
  OutputPreferences result = project.outputPreferences;
  await showDialog(
      context: context,
      builder: (BuildContext context) => 
        AlertDialog(
          title: Text('Output Preferences'),
          content: _OutputPreferencesSelector(project, (o) => result = o),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                result = null;
                Navigator.of(context).pop();
              },
            ),
          ],
        )
    );
    return result;
}


class _OutputPreferencesSelector extends StatefulWidget {
  final Project project;
  final Function(OutputPreferences) onChange;

  _OutputPreferencesSelector(this.project, this.onChange);

  @override
  _OutputPreferencesSelectorState createState() =>
    _OutputPreferencesSelectorState(this.project.outputPreferences);
}

class _OutputPreferencesSelectorState 
  extends State<_OutputPreferencesSelector> {

  OutputPreferences outputPreferences;

  _newOutputPreferences(
    OutputPreferences Function(OutputPreferences) modifier
  ) =>
    this.setState(() {
      outputPreferences = 
        modifier(OutputPreferences.fromOutputPreferences(outputPreferences));
      widget.onChange(outputPreferences);
    });

  _OutputPreferencesSelectorState(this.outputPreferences);

  @override
    Widget build(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Resolution'),
        _generateInputField(
          (o) => o.resolution['w'],
          (o, val) => o..resolution['w'] = val,
          'Width'),
        _generateInputField(
          (o) => o.resolution['h'],
          (o, val) => o..resolution['h'] = val,
          'Height'),
        
        Text('\nFramerate'),
        _generateInputField(
          (o) => o.framerate,
          (o, val) => o..framerate = val,
          'Framerate'),
      ]
    );

  _generateInputField(
    int Function(OutputPreferences) initialValueGetter,
    OutputPreferences Function(OutputPreferences o, int val) setter,
    String label
  ) =>
    TextFormField(
      initialValue:
        initialValueGetter(widget.project.outputPreferences).toString(),
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: (val) => { _newOutputPreferences(
        (OutputPreferences o) => setter(o, int.parse(val))
      )},
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
    );

  
}