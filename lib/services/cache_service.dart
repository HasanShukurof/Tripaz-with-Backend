import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String KEY_TOURS = 'cached_tours';
  static const String KEY_TOUR_DETAILS = 'cached_tour_details_';
  static const String KEY_WISHLIST = 'cached_wishlist';
  static const String KEY_BOOKINGS = 'cached_bookings';
  static const String KEY_USER_DATA = 'cached_user_data';
  static const Duration DEFAULT_CACHE_DURATION = Duration(hours: 1);

  // Önbellek süresini kontrol etmek için zaman damgaları
  static const String TIMESTAMP_TOURS = 'timestamp_tours';
  static const String TIMESTAMP_TOUR_DETAILS = 'timestamp_tour_details_';
  static const String TIMESTAMP_WISHLIST = 'timestamp_wishlist';
  static const String TIMESTAMP_BOOKINGS = 'timestamp_bookings';
  static const String TIMESTAMP_USER_DATA = 'timestamp_user_data';

  // Veriyi önbelleğe kaydetme
  Future<void> saveData<T>(String key, T data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Null kontrolü ekleyelim
      if (data == null) {
        print('Önbelleğe null veri kaydedilemez: $key');
        return;
      }

      // Object'i JSON'a çevirirken hata oluşmaması için try-catch ekleyelim
      String jsonData;
      try {
        jsonData = json.encode(data);
      } catch (e) {
        print('JSON dönüştürme hatası: $e');
        return;
      }

      await prefs.setString(key, jsonData);

      // Zaman damgasını kaydet
      final timestampKey = 'timestamp_$key';
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
      print('Veri başarıyla önbelleğe kaydedildi: $key');
    } catch (e) {
      print('Önbelleğe kaydetme hatası: $e');
    }
  }

  // Önbellekten veri okuma
  Future<T?> getData<T>(String key, T Function(Map<String, dynamic>) fromJson,
      {Duration? cacheDuration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(key);

      if (jsonData == null) {
        print('Önbellekte veri bulunamadı: $key');
        return null;
      }

      // Önbellek süresini kontrol et
      final duration = cacheDuration ?? DEFAULT_CACHE_DURATION;
      final timestampKey = 'timestamp_$key';
      final timestamp = prefs.getInt(timestampKey);

      if (timestamp != null) {
        final storedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        if (now.difference(storedTime) > duration) {
          // Önbellek süresi dolmuş, null döndür
          print('Önbellek süresi dolmuş: $key');
          await clearCache(key); // Eski veriyi temizle
          return null;
        }
      }

      try {
        final Map<String, dynamic> data = json.decode(jsonData);
        return fromJson(data);
      } catch (e) {
        print('JSON ayrıştırma hatası: $e');
        await clearCache(key); // Hatalı veriyi temizle
        return null;
      }
    } catch (e) {
      print('Önbellekten veri okuma hatası: $e');
      return null;
    }
  }

  // Önbellekten listeyi okuma
  Future<List<T>?> getDataList<T>(
      String key, T Function(Map<String, dynamic>) fromJson,
      {Duration? cacheDuration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(key);

      if (jsonData == null) {
        print('Önbellekte liste bulunamadı: $key');
        return null;
      }

      // Önbellek süresini kontrol et
      final duration = cacheDuration ?? DEFAULT_CACHE_DURATION;
      final timestampKey = 'timestamp_$key';
      final timestamp = prefs.getInt(timestampKey);

      if (timestamp != null) {
        final storedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        if (now.difference(storedTime) > duration) {
          // Önbellek süresi dolmuş, null döndür
          print('Önbellek liste süresi dolmuş: $key');
          await clearCache(key); // Eski veriyi temizle
          return null;
        }
      }

      try {
        final List<dynamic> dataList = json.decode(jsonData);
        List<T> result = [];

        for (var item in dataList) {
          if (item is Map<String, dynamic>) {
            try {
              // Her öğeyi güvenli bir şekilde dönüştür
              result.add(fromJson(item));
            } catch (e) {
              print('Öğe dönüştürme hatası: $e, Öğe: $item');
              // Hatalı öğeyi atla ve devam et
            }
          }
        }

        // Eğer hiçbir öğe dönüştürülemediyse null döndür
        if (result.isEmpty && dataList.isNotEmpty) {
          print('Hiçbir öğe başarıyla dönüştürülemedi');
          await clearCache(key); // Hatalı veriyi temizle
          return null;
        }

        return result;
      } catch (e) {
        print('Önbellekten liste okuma JSON hatası: $e');
        await clearCache(key); // Hatalı veriyi temizle
        return null;
      }
    } catch (e) {
      print('Önbellekten liste okuma hatası: $e');
      await clearCache(key); // Sorunlu key'i temizle
      return null;
    }
  }

  // Belirli bir veriyi önbellekten silme
  Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      await prefs.remove('timestamp_$key');
      print('Önbellek temizlendi: $key');
    } catch (e) {
      print('Önbellek temizleme hatası: $e');
    }
  }

  // Tüm önbelleği temizleme
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = <String>[];

      // Önbellek anahtarlarını bul
      prefs.getKeys().forEach((key) {
        if (key.startsWith('cached_') || key.startsWith('timestamp_')) {
          keysToRemove.add(key);
        }
      });

      // Anahtarları sil
      for (var key in keysToRemove) {
        await prefs.remove(key);
      }
      print('Tüm önbellek temizlendi');
    } catch (e) {
      print('Tüm önbelleği temizleme hatası: $e');
    }
  }

  // Önbelleğin geçerli olup olmadığını kontrol et
  Future<bool> isCacheValid(String key, {Duration? cacheDuration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(key);

      if (jsonData == null) {
        return false;
      }

      final timestampKey = 'timestamp_$key';
      final timestamp = prefs.getInt(timestampKey);

      if (timestamp == null) {
        return false;
      }

      final duration = cacheDuration ?? DEFAULT_CACHE_DURATION;
      final storedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      return now.difference(storedTime) <= duration;
    } catch (e) {
      print('Önbellek geçerlilik kontrolü hatası: $e');
      return false;
    }
  }
}
