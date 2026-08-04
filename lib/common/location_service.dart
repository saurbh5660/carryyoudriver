import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

final _log = Logger();

abstract class LocationListener {
  void onLocationUpdated(Position position);
  void onLocationDisabled();
}

class LocationService {
  final LocationListener listener;
  Timer? _timer;
  StreamSubscription<Position>? _positionSub;

  LocationService(this.listener);

  /// Start receiving location updates.
  ///
  /// 1. Immediately seeds from `getLastKnownPosition()` so the UI has a
  ///    valid (lat, lng) to render against even before the first live fix.
  /// 2. Subscribes to a position stream for smooth live updates.
  /// 3. Keeps the legacy 30-second timer as a safety net in case the
  ///    stream is throttled / paused by the OS.
  Future<void> startLocationUpdates() async {
    _log.i("LocationService: startLocationUpdates");
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _log.i("LocationService: serviceEnabled=$serviceEnabled");
    if (!serviceEnabled) {
      listener.onLocationDisabled();
      return;
    }

    permission = await Geolocator.checkPermission();
    _log.i("LocationService: checkPermission=$permission");
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      _log.i("LocationService: requestPermission=$permission");
      if (permission == LocationPermission.denied) {
        listener.onLocationDisabled();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _log.w("LocationService: deniedForever - cannot get location");
      listener.onLocationDisabled();
      return;
    }

    // 1) Instant seed from the OS's last-known position so the map has
    //    a real (lat, lng) to render the car marker against without
    //    waiting for a fresh GPS fix.
    try {
      final last = await Geolocator.getLastKnownPosition();
      _log.i("LocationService: lastKnown=${last?.latitude},${last?.longitude}");
      if (last != null) {
        listener.onLocationUpdated(last);
      }
    } catch (e) {
      _log.w("LocationService: getLastKnownPosition failed: $e");
    }

    // 2) Kick off a real GPS fix in parallel.
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).then((p) {
      _log.i("LocationService: getCurrentPosition=${p.latitude},${p.longitude}");
      listener.onLocationUpdated(p);
    }).catchError((e) {
      _log.w("LocationService: getCurrentPosition failed: $e");
    });

    // 3) Continuous live updates.
    await _positionSub?.cancel();
    try {
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(
        (p) {
          _log.i(
            "LocationService: stream=${p.latitude},${p.longitude}",
          );
          listener.onLocationUpdated(p);
        },
        onError: (e) {
          _log.w("LocationService: stream error: $e");
        },
      );
    } catch (e) {
      _log.w("LocationService: getPositionStream failed: $e");
    }

    // 4) Safety-net poll every 30s in case the stream gets paused by
    //    the OS (e.g. backgrounding).
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        listener.onLocationUpdated(position);
      } catch (_) {
        // ignore - stream is the primary source
      }
    });
  }

  /// Stop all listeners when the screen closes.
  void stopLocationUpdates() {
    _timer?.cancel();
    _timer = null;
    _positionSub?.cancel();
    _positionSub = null;
  }
}
