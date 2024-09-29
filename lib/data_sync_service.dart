import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class DataSyncService {
  // Listen for connectivity changes
  void startConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (result[0] != ConnectivityResult.none) {
        //Online
        print("main online");
        syncUnsyncedData();
      }
    });
  }

  // Sync unsynced data when the device is online
  Future<void> syncUnsyncedData() async {
    var unsyncedBox = Hive.box('unsynced_data');
    var keys = unsyncedBox.keys;

    print("keys ${keys.length}");
    for (var key in keys) {
      var unsyncedQuiz = unsyncedBox.get(key);

      // Sync the data (you can implement your server sync logic here)
      try {
        await _sendDataToServer(unsyncedQuiz);

        // If the sync is successful, remove it from the unsynced box
        await unsyncedBox.delete(key);
        print('Data synced for key: $key');
      } catch (e) {
        print('Failed to sync data for key: $key. Error: $e');
      }
    }
  }

  // Mock method
  Future<void> _sendDataToServer(String quizData) async {
    // Here send the data to server.
    //http request
    print('Syncing data to server: $quizData');
  }
}