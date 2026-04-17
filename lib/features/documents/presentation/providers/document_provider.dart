import 'package:flutter/foundation.dart';
import '../../data/repositories/document_repository.dart';
import '../../domain/entities/document_entity.dart';

class DocumentProvider with ChangeNotifier {
  final DocumentRepository _repository = DocumentRepository();

  List<DocumentEntity> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<DocumentEntity> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _documents = await _repository.listDocuments();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request a presigned upload URL from the server
  Future<Map<String, String>> requestUpload({
    required String fileName,
    required String mimeType,
    required int fileSize,
  }) {
    return _repository.requestUpload(
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileSize,
    );
  }

  /// Confirm an upload after the file is in S3
  Future<void> confirmUpload(String documentId) async {
    await _repository.confirmUpload(documentId);
    await loadDocuments();
  }

  Future<String> getDownloadUrl(String documentId) {
    return _repository.getDownloadUrl(documentId);
  }

  Future<void> deleteDocument(String documentId) async {
    await _repository.deleteDocument(documentId);
    _documents.removeWhere((d) => d.id == documentId);
    notifyListeners();
  }
}
