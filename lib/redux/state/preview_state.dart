import 'package:meta/meta.dart';

class PreviewState {

  double currentTime;
  int selectedClip;

  factory PreviewState.create() {
    return PreviewState(
      currentTime: 0,
    );
  }

  PreviewState({
    @required this.currentTime
  });

  PreviewState.fromPreviewState(PreviewState p):
    currentTime = p.currentTime,
    selectedClip = p.selectedClip;
  
}