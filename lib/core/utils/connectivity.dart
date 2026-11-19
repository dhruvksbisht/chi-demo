import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the device has a network link. Payments need one (NFR-04): the pay buttons are
/// disabled with a message while offline, and nothing is ever queued for later.
///
/// Only the link is checked, not reachability of Juice; that is the server's job in production.
final onlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool isOnline(List<ConnectivityResult> r) =>
      r.any((c) => c != ConnectivityResult.none);
  try {
    yield isOnline(await connectivity.checkConnectivity());
    yield* connectivity.onConnectivityChanged.map(isOnline);
  } on MissingPluginException {
    // Widget tests and unsupported platforms have no plugin: assume online.
    debugPrint('connectivity plugin unavailable; assuming online');
    yield true;
  }
});

extension OnlineX on WidgetRef {
  /// Online unless the device has positively reported no connection.
  bool get isOnline => watch(onlineProvider).value ?? true;
}
