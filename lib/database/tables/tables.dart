import 'package:drift/drift.dart';
import 'package:photomall_studio_manager/controllers/ps_image_status_controller.dart';

class TransportData extends Table {
  @override
  String get tableName => 'transport_data';

  TextColumn get code => text().named('code').withLength(max: 30)();

  TextColumn get tag => text()
      .named('tag')
      .withLength(
        max: 30,
      )
      .nullable()();

  IntColumn get lastUpdatedAt => integer().named('last_updated_at')();

  IntColumn get updateRequired =>
      integer().named('update_required').withDefault(const Constant(0))();

  TextColumn get data => text().named('data').nullable()();

  TextColumn get role => text().named('role').nullable()();

  @override
  Set<Column> get primaryKey => {code};
}

class PhotomallStudioInfo extends Table {
  @override
  String get tableName => 'Photomall_studio_Info';

  TextColumn get code => text()
      .named('code')
      .withLength(max: 10)
      .customConstraint('NULL REFERENCES events(code)')();

  TextColumn get value => text().named('value')();

  TextColumn get role => text().named('role')();

  IntColumn get lastUpdatedAt => integer().named('last_updated_at')();

  @override
  Set<Column> get primaryKey => {code};
}

class Folders extends Table {
  @override
  String get tableName => 'folders';

  TextColumn get code => text().named('folder_code')();

  TextColumn get eventCode => text().named('event_code')();

  TextColumn get parentCode => text().named('parent_code').nullable()();

  TextColumn get name => text().named('name')();

  TextColumn get path => text().named('path').nullable()();

  BoolColumn get sync =>
      boolean().named('sync').withDefault(const Constant(false))();

  IntColumn get lastUpdatedAt => integer().named('last_updated_at')();

  TextColumn get deviceId => text().named('device_id').nullable()();

  TextColumn get segregationPath =>
      text().named('segregationPath').nullable()();

  TextColumn get customSegregationPath =>
      text().named('customSegregationPath').nullable()();

  TextColumn get segregationFormat =>
      text().named('segregationFormat').nullable()();

  IntColumn get filesCount => integer().named('files_count').nullable()();

  IntColumn get uploadStatus => integer().named('upload_status').nullable()();

  @override
  Set<Column> get primaryKey => {code};
}

class PhotoSelectionImages extends Table {
  @override
  String get tableName => 'photo_selection_Images';

  IntColumn get id => integer().named('id').autoIncrement()();

  TextColumn get eventCode => text().named('event_code').nullable()();

  TextColumn get code => text().named('Image_code').nullable()();

  TextColumn get folderCode => text().named('folder_code').nullable()();

  TextColumn get name => text().named('name').nullable()();

  TextColumn get path => text().named('path').nullable().nullable()();

  BoolColumn get uploaded => boolean()
      .named('uploaded')
      .withDefault(const Constant(false))
      .nullable()();

  IntColumn get lastUpdatedAt => integer().named('last_updated_at')();

  TextColumn get sha256 => text().named('sha_256').nullable()();

  TextColumn get md5hash => text().named('md5_hash').nullable()();

  TextColumn get preSignedURlCode =>
      text().named('pre_signed_url_code').nullable()();

/* @override
  Set<Column> get primaryKey => {code};*/
// Set<Column> get createIndexStmt => {code,archived};
}

class NotificationTable extends Table {
  @override
  String get tableName => 'notifications_table';

  IntColumn get id => integer().named('id').autoIncrement()();

  TextColumn get notification => text().named('notification_code').nullable()();

  TextColumn get eventCode => text().named('event_code').nullable()();

  TextColumn get notificationData =>
      text().named('notification_data').nullable()();

  BoolColumn get readStatus => boolean()
      .named('readStatus')
      .withDefault(const Constant(false))
      .nullable()();

  BoolColumn get confirmStatus => boolean()
      .named('confirmStatus')
      .withDefault(const Constant(true))
      .nullable()();

  DateTimeColumn get createdAt => dateTime().nullable()();
}

class PhotoSelectionImageCondition extends Table {
  @override
  String get tableName => 'photo_selection_imageStatus';

  TextColumn get code => text().named('code')(); // photo selection image code
  IntColumn get status => integer().named('status').nullable()();

  IntColumn get rating => integer().named('rating').nullable()();

  TextColumn get comment => text().named('comment').nullable()();

  @override
  Set<Column> get primaryKey => {code};
}

class Events extends Table {
  @override
  String get tableName => 'events';

  TextColumn get code => text().named('code')();

  TextColumn get studioCode => text().named('studio_code')();

  TextColumn get name => text().named('name')();

  TextColumn get categoryName => text().named('category_name')();

  BoolColumn get published =>
      boolean().named('published').withDefault(const Constant(false))();

  IntColumn get lastUpdatedAt => integer().named('last_updated_at')();

  TextColumn get coverImage => text().named('cover_image').nullable()();

  TextColumn get userName => text().named('user_name').nullable()();

  IntColumn get screenDisplay => integer().named('screen_display').nullable()();

  IntColumn get pageNumber => integer().named('page_number').nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();

  @override
  Set<Column> get primaryKey => {code};
// Set<Column> get createIndexStmt => {code,archived};
}

class PhotoSelections extends Table {
  @override
  String get tableName => 'photo_selections';

  TextColumn get code => text().named('code')();

  TextColumn get eventCode => text().named('event_code')();

  BoolColumn get published =>
      boolean().named('published').withDefault(const Constant(false))();

  BoolColumn get confirmedStatus =>
      boolean().named('confirmed_status').withDefault(const Constant(false))();

  IntColumn get lastUpdatedAt => integer().named('last_updated_at')();

  IntColumn get confirmedLastUpdatedAt => integer()
      .named('confirmed_last_updated_at')
      .withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {code};
// Set<Column> get createIndexStmt => {code,archived};
}

  class Albums extends Table {
    @override
    String get tableName => 'albums';

    TextColumn get code => text().named('code')();

    TextColumn get name => text().named('name').nullable()();

    TextColumn get size => text().named('size').nullable()();

    TextColumn get path => text().named('path').nullable()();

    IntColumn get type => integer().named('type')();

    TextColumn get eventCode => text().named('event_code')();

    IntColumn get lastUpdatedAt => integer().named('last_updated_at')();

    IntColumn get orderLastUpdatedAt =>
        integer().named('order_last_updated_at')();

    TextColumn get deviceId => text().named('device_id').nullable()();

    IntColumn get filesCount => integer().named('files_count').nullable()();

    IntColumn get imagesCount => integer().named('images_count').nullable()();

    TextColumn get directoryModifiedTime =>
        text().named('directory_modified_time').nullable()();

    IntColumn get uploadStatus => integer().named('upload_status').nullable()();

    @override
    Set<Column> get primaryKey => {code};
  // Set<Column> get createIndexStmt => {code,archived};
  }

class Orders extends Table {
  @override
  String get tableName => 'orders';

  IntColumn get id => integer().named('id').autoIncrement()();

  TextColumn get eventCode => text().named('event_code').nullable()();

  TextColumn get code => text().named('code').nullable()();

  TextColumn get albumCode => text().named('album_code')();

  TextColumn get name => text().named('name').nullable()();

  TextColumn get path => text().named('path').nullable()();

  BoolColumn get uploaded => boolean()
      .named('uploaded')
      .withDefault(const Constant(false))
      .nullable()();

  TextColumn get sha256 => text().named('sha_256').nullable()();

  TextColumn get md5hash => text().named('md5_hash').nullable()();

  TextColumn get preSignedURlCode =>
      text().named('pre_signed_url_code').nullable()();

  TextColumn get ratio => text().named('ratio').nullable()();

  TextColumn get screenDisplay2ImageUrl =>
      text().named('screen_display2_image_url').nullable()();

  TextColumn get screenDisplay2Md5hash =>
      text().named('screen_display2_md5_hash').nullable()();

  TextColumn get screenDisplay2PreSignedURlCode =>
      text().named('screen_display2_pre_signed_url_code').nullable()();
  IntColumn get compressionStatus =>
      integer().named('compression_status').nullable()();
}

class UploadState extends Table {
  @override
  String get tableName => 'uploading_progress';

  IntColumn get id => integer().named('id').autoIncrement()();

  TextColumn get eventName => text().named('code').nullable()();

  TextColumn get albumName => text().named('album_name')();

  TextColumn get uploadingImageName =>
      text().named('uploading_image').nullable()();

  IntColumn get totalFilesCount =>
      integer().named('total_files_count').nullable()();

  IntColumn get remainingFilesCount =>
      integer().named('remaining_files_count').nullable()();

  BoolColumn get uploadComplete =>
      boolean().named('upload').withDefault(const Constant(false)).nullable()();
}
