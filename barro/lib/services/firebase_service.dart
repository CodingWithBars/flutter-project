import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // Instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Example reference to a collection
  // CollectionReference get _users => _firestore.collection('users');
  // CollectionReference get _todos => _firestore.collection('todos');

  // TODO: Implement later for Firebase Database

  /// Adds a new document to a specified collection
  Future<void> addDocument(String collectionPath, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).add(data);
    } catch (e) {
      print('Error adding document: $e');
      rethrow;
    }
  }

  /// Updates an existing document
  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  /// Deletes a document
  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  /// Fetches a collection as a Stream
  Stream<QuerySnapshot> streamCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }
}
