const String createImage = 'create';
const String deleteImage = 'delete';
const String updateImage = 'update';

class LocalDirectoryController {
  upsertLocalImages(List<String> localFiles, List<String> directoryFiles,
      Function(String, List<String>?) callback) {
    List<String> create = []; // insert this event
    List<String> delete = []; // delete this event
    List<String> update = []; // change update required as true
    for (int i = 0; i < directoryFiles.length; i++) {
      if (localFiles.contains(directoryFiles[i])) {
        update.add(directoryFiles[i]);
      }
      if (!localFiles.contains(directoryFiles[i])) {
        create.add(directoryFiles[i]);
      }
    }
    for (int i = 0; i < localFiles.length; i++) {
      if (!directoryFiles.contains(localFiles[i])) {
        delete.add(localFiles[i]);
      }
    }
    if (create.isNotEmpty) {
      callback(createImage, create);
    }
    if (update.isNotEmpty) {
      callback(deleteImage, create);
    }
    if (update.isNotEmpty) {
      callback(updateImage, create);
    }
  }
}
