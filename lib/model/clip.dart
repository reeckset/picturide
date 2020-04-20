import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:picturide/model/file_wrapper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clip.g.dart';

@JsonSerializable()
class Clip implements FileWrapper {

  static final int maxTempoDurationPower = 5;
  static final int minTempoDurationPower = -2;

  int tempoDurationPower;
  double startTimestamp;
  String filePath;

  Clip({@required this.filePath,
    this.tempoDurationPower = 1,
    this.startTimestamp = 0.0});

  Clip.fromClip(Clip c){
    this.tempoDurationPower = c.tempoDurationPower;
    this.filePath = c.filePath;
    this.startTimestamp = c.startTimestamp;
  }

  incrementTempoDuration(){
    tempoDurationPower++;
    if(tempoDurationPower > maxTempoDurationPower){
      tempoDurationPower = minTempoDurationPower;
    }
  }

  decrementTempoDuration(){
    tempoDurationPower--;
    if(tempoDurationPower < minTempoDurationPower){
      tempoDurationPower = maxTempoDurationPower;
    }
  }

  String getTempoDurationText() {
      if(tempoDurationPower == null) tempoDurationPower = 1;
      return (tempoDurationPower < 0 ? '1/' : '')
      + pow(2, tempoDurationPower.abs()).toInt().toString();
  }


  double getTempoDurationMultiplier() =>
    pow(2.0, tempoDurationPower.toDouble());

  @override
  String getFilePath() => filePath;

  //serialization
  factory Clip.fromJson(Map<String, dynamic> json) => 
    _$ClipFromJson(json);
  Map<String, dynamic> toJson() => _$ClipToJson(this);
}