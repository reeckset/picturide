import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:path/path.dart';
import 'package:picturide/model/clip.dart';
import 'package:picturide/view/widgets/edit_clip.dart';
import 'package:picturide/redux/state/app_state.dart';

class EditClipPage extends StatefulWidget {
  final Clip originalClip;
  EditClipPage(this.originalClip, {Key key}) : super(key: key);

  @override
  EditClipPageState createState() => EditClipPageState();
}

class EditClipPageState extends State<EditClipPage> {
  final IjkMediaController controller = IjkMediaController();
  final _scrollController = ScrollController();
  List<Clip> clipsToAdd = [];

  _submit(context){
    controller.getVideoInfo().then((VideoInfo fileInfo){
      controller.stop();
      Navigator.pop(context, clipsToAdd);
    });
  }

  _scrollToBottom(){
    Timer(Duration(milliseconds: 100),() {
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn
        );
      } catch (e) {}
    });
  }

  _addClip(){
    this.setState((){
      this.clipsToAdd.add(widget.originalClip);
      this._scrollToBottom();
    });
  }

  _onClipChange(newClip, index){
    this.setState((){
      this.clipsToAdd[index] = newClip;
    });
  }

  @override
  void initState() {
    super.initState();
    controller.setNetworkDataSource(
      widget.originalClip.filePath, autoPlay: true);
    _addClip();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.stop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(
            'Clip Editing'
        )),
        body: Column(children: [
              _separatorText(basename(
                widget.originalClip.filePath
                )),
              previewer(context),
              _separatorText('Clips:'),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  children: <Widget>[...clipsToAdd.asMap().entries.map(
                    (entry) => EditClip(
                      entry.value, controller,
                      onChange: (newClip) => _onClipChange(newClip, entry.key)
                    )
                  ).toList(),
                  FlatButton(
                    child: Text('Add another clip from this file'),
                    onPressed: _addClip,),
                  ],
                ),
              ),
              RaisedButton(
                child: Text('Done'),
                onPressed: () => _submit(context),
              )
        ]),
      )
    );
  }
  
  _separatorText(string){
    return Padding(padding: EdgeInsets.all(5.0),
      child: Text(
        string,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0)
    ),);
  }

  previewer(context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Container(
      height:  mediaQuery.size.width / StoreProvider
        .of<AppState>(context).state.history.project.getAspectRatio(),
      child: IjkPlayer(
        mediaController: controller,
      ),);
  }
}