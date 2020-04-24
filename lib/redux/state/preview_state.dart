import 'package:meta/meta.dart';

@immutable
class PreviewState {

  final double currentTime;

  factory PreviewState.create() {
    return PreviewState(
      currentTime: 0,
    );
  }

  PreviewState({
    @required this.currentTime
  });
}