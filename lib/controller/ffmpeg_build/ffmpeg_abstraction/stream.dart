abstract class FFMPEGStream {

  FFMPEGStream sourceStream;

  FFMPEGStream({this.sourceStream});

  List<String> build() {
    sourceStream.updateInputIndicesAndReturnNext(0);
    final filterComplex = buildFilterComplex().replaceAll(RegExp(r'\n|\s'), '');
    return[
      ...buildInputArgs(),
      ...filterComplex != ''
        ? ['-filter_complex', filterComplex]
        : [],
      ...buildMappingArgs(),
      ...buildOutputArgs()
    ];
  }
  
  List<String> buildInputArgs() {
    if(sourceStream == null) {
      throw Exception(
        'Input behavior not overriden for Stream with no sourceStream'
      );
    }
    return sourceStream.buildInputArgs();
  }
  String buildFilterComplex() {
    if(sourceStream == null) {
      throw Exception(
        'Filter Stream has no source stream'
      );
    }
    return sourceStream.buildFilterComplex();
  }

  List<String> buildOutputArgs() {
    if(sourceStream == null) {
      throw Exception(
        'Output Stream has no source stream'
      );
    }
    return sourceStream.buildOutputArgs();
  }

  List<String> buildMappingArgs() {
    if(sourceStream == null) {
      return [];
    }
    return sourceStream.buildMappingArgs();
  }

  bool hasVideoStream(){
    return getVideoStreamLabel() != null;
  }

  bool hasAudioStream(){
    return getAudioStreamLabel() != null;
  }

  String getVideoStreamLabel() {
    return sourceStream.getVideoStreamLabel();
  }

  String getAudioStreamLabel() {
    return sourceStream.getAudioStreamLabel();
  }

  int updateInputIndicesAndReturnNext(int newStartIndex) {
    return sourceStream.updateInputIndicesAndReturnNext(newStartIndex);
  }

}