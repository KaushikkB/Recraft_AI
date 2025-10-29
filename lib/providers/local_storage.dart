import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_item_model.dart';

/// Service for local data persistence using SharedPreferences
class LocalStorageService {
  static const String _savedItemsKey = 'saved_upcycling_items';

  late SharedPreferences _prefs;

  /// Initialize SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save an item to local storage
  Future<void> saveItem(SavedItemModel item) async {
    try {
      final savedItems = await getSavedItems();
      savedItems.add(item);

      final jsonList = savedItems.map((item) => item.toJson()).toList();
      await _prefs.setString(_savedItemsKey, json.encode(jsonList));
    } catch (e) {
      print('❌ Error saving item: $e');
      throw Exception('Failed to save item locally');
    }
  }

  /// Get all saved items
  Future<List<SavedItemModel>> getSavedItems() async {
    try {
      final jsonString = _prefs.getString(_savedItemsKey);
      if (jsonString == null) return [];

      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((itemJson) => SavedItemModel.fromJson(itemJson)).toList();
    } catch (e) {
      print('❌ Error loading saved items: $e');
      return [];
    }
  }

  /// Delete a saved item
  Future<void> deleteItem(String id) async {
    try {
      final savedItems = await getSavedItems();
      savedItems.removeWhere((item) => item.id == id);

      final jsonList = savedItems.map((item) => item.toJson()).toList();
      await _prefs.setString(_savedItemsKey, json.encode(jsonList));
    } catch (e) {
      print('❌ Error deleting item: $e');
      throw Exception('Failed to delete item');
    }
  }
}