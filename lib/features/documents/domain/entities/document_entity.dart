class DocumentEntity {
  final String id;
  final String userId;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentEntity({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentEntity.fromJson(Map<String, dynamic> json) {
    return DocumentEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      fileSize: json['fileSize'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isConfirmed => status == 'confirmed';

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
