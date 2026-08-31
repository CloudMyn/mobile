class SkpItem {
  final String kegiatan;
  final String target;
  final String realisasi;
  final String? keterangan;

  SkpItem({
    required this.kegiatan,
    required this.target,
    required this.realisasi,
    this.keterangan,
  });

  factory SkpItem.fromJson(Map<String, dynamic> json) {
    return SkpItem(
      kegiatan: json['kegiatan'] ?? '',
      target: json['target'] ?? '',
      realisasi: json['realisasi'] ?? '',
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kegiatan': kegiatan,
      'target': target,
      'realisasi': realisasi,
      'keterangan': keterangan,
    };
  }
}

class SkpReportModel {
  final int? id;
  final String filename;
  final DateTime uploadDate;
  final int? _periodMonth;
  final int? _periodYear;
  final List<SkpItem> items;
  final String status;
  final String? pegawaiName;

  int get periodMonth => _periodMonth ?? uploadDate.month;
  int get periodYear => _periodYear ?? uploadDate.year;

  SkpReportModel({
    this.id,
    required this.filename,
    required this.uploadDate,
    int? periodMonth,
    int? periodYear,
    this.items = const [],
    this.status = 'pending',
    this.pegawaiName,
  })  : _periodMonth = periodMonth ?? uploadDate.month,
        _periodYear = periodYear ?? uploadDate.year;

  factory SkpReportModel.fromJson(Map<String, dynamic> json) {
    final uploadDate = json['uploadDate'] != null
        ? DateTime.parse(json['uploadDate'])
        : DateTime.now();
    return SkpReportModel(
      id: json['id'],
      filename: json['filename'] ?? 'unknown.pdf',
      uploadDate: uploadDate,
      periodMonth: json['periodMonth'] ?? uploadDate.month,
      periodYear: json['periodYear'] ?? uploadDate.year,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => SkpItem.fromJson(i)).toList()
          : [],
      status: json['status'] ?? 'pending',
      pegawaiName: json['pegawaiName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'uploadDate': uploadDate.toIso8601String(),
      'periodMonth': periodMonth,
      'periodYear': periodYear,
      'items': items.map((i) => i.toJson()).toList(),
      'status': status,
      'pegawaiName': pegawaiName,
    };
  }

  SkpReportModel copyWith({
    int? id,
    String? filename,
    DateTime? uploadDate,
    int? periodMonth,
    int? periodYear,
    List<SkpItem>? items,
    String? status,
    String? pegawaiName,
  }) {
    return SkpReportModel(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      uploadDate: uploadDate ?? this.uploadDate,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      items: items ?? this.items,
      status: status ?? this.status,
      pegawaiName: pegawaiName ?? this.pegawaiName,
    );
  }
}
