import 'package:objectbox/objectbox.dart';

@Entity()
class MemoryEntry {
  @Id()
  int id = 0;

  late String title;
  late String bodyText;

  @Property(type: PropertyType.date)
  late DateTime createdAt;

  double? latitude;
  double? longitude;
  String? locationName;

  String? voiceMemoPath;
  String? voiceTranscript;

  String? _photoPaths;
  String? _tags;

  @Transient()
  List<String> get photoPaths =>
      _photoPaths?.isNotEmpty == true ? _photoPaths!.split('|') : [];

  @Transient()
  set photoPaths(List<String> value) =>
      _photoPaths = value.isEmpty ? null : value.join('|');

  @Transient()
  List<String> get tags =>
      _tags?.isNotEmpty == true ? _tags!.split('|') : [];

  @Transient()
  set tags(List<String> value) =>
      _tags = value.isEmpty ? null : value.join('|');

  int? moodScore;
  bool syncedToCloud = false;
}