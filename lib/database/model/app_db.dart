import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photomall_studio_manager/database/dao/image_dao.dart';

import '../../objectbox.g.dart'; // created by `flutter pub run build_runner build`
import '../dao/album_dao.dart';
import '../dao/event_dao.dart';
import '../dao/folder_dao.dart';
import '../dao/notifications_dao.dart';
import '../dao/order_dao.dart';
import '../dao/photo_selection_dao.dart';
import '../dao/photomall_studio_info.dart';
import '../dao/ps_image_status.dart';
import '../dao/transporter_dao.dart';
import '../dao/upload_status_dao.dart';
import 'dart:io';

class ObjectBox {
  late final Store store;

  ObjectBox._create(this.store);

  static ObjectBox? _instance;

  static Future<ObjectBox> create() async {
    if (_instance != null) return _instance!;

    final docsDir = await getApplicationDocumentsDirectory();

    print('🗂 ObjectBox store path: $docsDir');
    final store = await openStore(
      directory: p.join(docsDir.path, "photomall_db"),
macosApplicationGroup: "photomall.app"
    );

    _instance = ObjectBox._create(store);
    return _instance!;
  }

  /// Optional: expose DAOs from here
  late final PhotoMallStudioInfoDao photoMallStudioInfoDao =
      PhotoMallStudioInfoDao(store);
  late final EventModelDao eventModelDao = EventModelDao(store);
  late final AlbumModelDao albumModelDao = AlbumModelDao(store);
  late final FolderModelDao folderModelDao = FolderModelDao(store);
  late final NotificationsDao notificationsDao = NotificationsDao(store);
  late final OrderModelDao orderModelDao = OrderModelDao(store);
  late final ImageModelDao imageModelDao = ImageModelDao(store);
  late final PhotoSelectionImageStatusDao photoSelectionImageStatusDao =
      PhotoSelectionImageStatusDao(store);
  late final PhotoSelectionDao photoSelectionDao = PhotoSelectionDao(store);
  late final TransporterDao transporterDao = TransporterDao(store);
  late final UploadStatusDao uploadStatusDao = UploadStatusDao(store);
}
