class EventDetailArguments {
  String? eventCode;
  String? eventName;
  String studioCode;
  String? folderCode;
  String? rootPath;
  bool isSubFolder;

  EventDetailArguments(
      {this.rootPath,
      this.eventCode,
      this.eventName,
      required this.studioCode,
      this.folderCode,
      this.isSubFolder = false});
}
