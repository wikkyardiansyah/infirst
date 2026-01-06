import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Model untuk menyimpan data lokasi
class LocationData {
  final double latitude;
  final double longitude;
  final String? alamat;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.alamat,
  });
}

/// Service untuk mengelola lokasi GPS
class LocationService {
  /// Mengecek apakah layanan lokasi tersedia
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Meminta izin lokasi
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission;
  }

  /// Mengecek status izin lokasi
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Mendapatkan lokasi saat ini
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Cek apakah layanan lokasi aktif
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Cek izin
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied');
        return null;
      }

      // Dapatkan posisi
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Dapatkan alamat dari koordinat
      String? alamat = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        alamat: alamat,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Mengonversi koordinat menjadi alamat
  Future<String?> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Skip geocoding di web karena tidak didukung dengan baik
      if (kIsWeb) {
        return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.subAdministrativeArea != null && 
            place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        }
        if (place.administrativeArea != null && 
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        if (addressParts.isNotEmpty) {
          return addressParts.join(', ');
        }
      }

      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      debugPrint('Error getting address: $e');
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Membuka pengaturan lokasi perangkat
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Membuka pengaturan aplikasi untuk izin
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
