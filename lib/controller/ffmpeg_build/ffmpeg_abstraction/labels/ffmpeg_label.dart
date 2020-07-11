abstract class FFMPEGLabel {

  String label;

  FFMPEGLabel(this.label);

  String forMapping();
  String forFilterInput() => '[$label]';
}