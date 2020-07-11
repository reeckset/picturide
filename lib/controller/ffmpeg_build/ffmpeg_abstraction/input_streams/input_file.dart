class InputFile {
  String file;
  double durationSeconds, startTimeSeconds;
  bool loop;

  InputFile(
    this.file,
    {
      this.durationSeconds,
      this.startTimeSeconds,
      this.loop = false
    }
  );
}