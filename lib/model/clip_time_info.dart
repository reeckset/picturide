class ClipTimeInfo {
  static final beatsPerBar = 4;
  int songIndex;
  double startTime, duration, beats, beatNumber;

  ClipTimeInfo({
    this.beatNumber, this.beats, this.songIndex, this.startTime, this.duration
  });

  isOnBarFirstBeat() => beatNumber % beatsPerBar == 0;

  isOnBeat() => beatNumber % 1 == 0;

  isSyncedToBeat() => 
    //clips that last for less than a bar, stay within their bar's limits
    (beats >= beatsPerBar || (beatNumber % beatsPerBar + beats) <= beatsPerBar)
    //big clips (more than a beat long) always start on beat
    && (beats < 1 || beatNumber % 1 == 0)
    //small clips stay within a beat
    && (beats > 1 || (beatNumber % 1 + beats) <= 1)
    //clips that last a bar or longer start on a bar's first beat
    && (beats < beatsPerBar || beatNumber % beatsPerBar == 0);

  isFirstOfTrack() => beatNumber == 0;
}