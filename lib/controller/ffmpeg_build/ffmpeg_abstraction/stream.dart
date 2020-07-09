abstract class FFMPEGStream {

  FFMPEGStream sourceStream;

  FFMPEGStream({this.sourceStream});

  build() {
    final filterComplex = buildFilterComplex();
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

  String getVideoStreamLabel() {
    return sourceStream.getVideoStreamLabel();
  }

  String getAudioStreamLabel() {
    return sourceStream.getAudioStreamLabel();
  }

}