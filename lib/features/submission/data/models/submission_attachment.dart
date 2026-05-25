class SubmissionAttachment {
  final int id;
  final String fileName;
  final String? fileUrl;
  final int? fileSizeKb;
  final String? mimeType;

  const SubmissionAttachment({
    required this.id,
    required this.fileName,
    this.fileUrl,
    this.fileSizeKb,
    this.mimeType,
  });

  factory SubmissionAttachment.fromJson(Map<String, dynamic> json) {
    return SubmissionAttachment(
      id: json['id'] as int,
      fileName: json['file_name'] as String? ?? '',
      fileUrl: json['file_url'] as String?,
      fileSizeKb: json['file_size_kb'] as int?,
      mimeType: json['mime_type'] as String?,
    );
  }

  bool get isImage {
    final type = mimeType?.toLowerCase() ?? '';
    if (type.startsWith('image/')) return true;
    final ext = fileName.split('.').last.toLowerCase();
    return const {'jpg', 'jpeg', 'png', 'gif', 'webp'}.contains(ext);
  }

  String get extensionLabel {
    return fileName.split('.').last.toUpperCase();
  }
}
