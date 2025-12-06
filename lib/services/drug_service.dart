/// Drug/Narkotika Service untuk Supabase
/// CRUD operations untuk data narkotika
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/drug_model.dart';

class DrugService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Get semua drugs
  Future<List<DrugModel>> getAllDrugs() async {
    try {
      final response = await _supabase
          .from('drugs')
          .select()
          .order('name', ascending: true);
      
      return (response as List)
          .map((drug) => DrugModel.fromMap(drug))
          .toList();
    } catch (e) {
      throw Exception('Failed to load drugs: $e');
    }
  }
  
  /// Get drug by ID
  Future<DrugModel?> getDrugById(String id) async {
    try {
      final response = await _supabase
          .from('drugs')
          .select()
          .eq('id', id)
          .single();
      
      return DrugModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }
  
  /// Search drugs by name
  Future<List<DrugModel>> searchDrugs(String query) async {
    try {
      final response = await _supabase
          .from('drugs')
          .select()
          .ilike('name', '%$query%')
          .order('name', ascending: true);
      
      return (response as List)
          .map((drug) => DrugModel.fromMap(drug))
          .toList();
    } catch (e) {
      throw Exception('Failed to search drugs: $e');
    }
  }
  
  /// Filter drugs by category
  Future<List<DrugModel>> getDrugsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('drugs')
          .select()
          .eq('category', category)
          .order('name', ascending: true);
      
      return (response as List)
          .map((drug) => DrugModel.fromMap(drug))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter drugs: $e');
    }
  }
  
  /// Filter drugs by risk level
  Future<List<DrugModel>> getDrugsByRiskLevel(String riskLevel) async {
    try {
      final response = await _supabase
          .from('drugs')
          .select()
          .eq('risk_level', riskLevel)
          .order('name', ascending: true);
      
      return (response as List)
          .map((drug) => DrugModel.fromMap(drug))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter drugs by risk: $e');
    }
  }
  
  /// Add new drug (Admin only)
  Future<void> addDrug(DrugModel drug) async {
    try {
      await _supabase.from('drugs').insert(drug.toMap());
    } catch (e) {
      throw Exception('Failed to add drug: $e');
    }
  }
  
  /// Update drug (Admin only)
  Future<void> updateDrug(DrugModel drug) async {
    try {
      await _supabase.from('drugs').update(drug.toMap()).eq('id', drug.id);
    } catch (e) {
      throw Exception('Failed to update drug: $e');
    }
  }
  
  /// Delete drug (Admin only)
  Future<void> deleteDrug(String id) async {
    try {
      await _supabase.from('drugs').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete drug: $e');
    }
  }
}
