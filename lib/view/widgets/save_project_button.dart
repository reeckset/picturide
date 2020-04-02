import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picturide/controller/project_storage.dart';
import 'package:picturide/model/project.dart';

class SaveProjectButton extends StatefulWidget {
  final Project project;

  SaveProjectButton(this.project);

  @override
  _SaveProjectButtonState createState() => _SaveProjectButtonState();
}

class _SaveProjectButtonState extends State<SaveProjectButton> {

  bool isSaving = false;

  _save(){
    setState(() {
      isSaving = true;
    });
    saveProject(widget.project)
      .then((_){
        setState((){
          isSaving = false;
        });
      });
  }


  @override
  Widget build(BuildContext context) =>
    IconButton(
      icon: Icon(isSaving ? Icons.timer : Icons.save),
      onPressed: _save
    );
  
}