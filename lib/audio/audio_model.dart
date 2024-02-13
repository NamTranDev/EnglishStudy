// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:english_study/model/transcript.dart';

class AudioModel {
  static const FILE_PATH = 'file_path';
  static const ASSET_PATH = 'asset_path';
  static const TRANSCRIPT = 'transcripts';

  int? id;
  String? title;
  List<Transcript>? transcripts;
  AudioModel({
    this.id,
    this.title,
    this.transcripts,
  });
}
