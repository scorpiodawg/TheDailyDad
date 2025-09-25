import 'package:logging/logging.dart';

void setupLogger() {
  Logger.root.level = Level.ALL; // Set the root logger to log all messages
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}
