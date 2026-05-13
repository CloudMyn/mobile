import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/comment_item.dart';
import '../../data/models/informasi_category.dart';
import '../../data/models/informasi_item.dart';

class InformasiController extends GetxController {
  final items = <InformasiItem>[].obs;
  final categories = <InformasiCategory>[].obs;
  final commentsMap = <String, List<CommentItem>>{}.obs;
  final selectedCategoryId = Rx<String?>(null);
  final dateRange = Rx<DateTimeRange?>(null);
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  List<InformasiItem> get pinnedItems =>
      items.where((i) => i.isPinned).take(2).toList();

  List<InformasiItem> get filteredItems {
    var result = items.where((i) => !i.isPinned).toList();
    if (selectedCategoryId.value != null) {
      result = result.where((i) => i.categoryId == selectedCategoryId.value).toList();
    }
    if (dateRange.value != null) {
      final range = dateRange.value!;
      result = result
          .where((i) =>
              !i.publishedAt.isBefore(range.start) &&
              !i.publishedAt.isAfter(range.end))
          .toList();
    }
    return result;
  }

  void selectCategory(String? id) {
    selectedCategoryId.value = id;
    items.refresh();
  }

  void applyDateRange(DateTimeRange? range) {
    dateRange.value = range;
    items.refresh();
  }

  void resetFilters() {
    selectedCategoryId.value = null;
    dateRange.value = null;
    items.refresh();
  }

  List<CommentItem> commentsFor(String articleId) =>
      commentsMap[articleId] ?? [];

  int totalComments(String articleId) {
    int count = 0;
    void countRecursive(List<CommentItem> list) {
      count += list.length;
      for (final c in list) {
        countRecursive(c.replies);
      }
    }
    countRecursive(commentsFor(articleId));
    return count;
  }

  void addComment(
    String articleId,
    String content,
    String authorName, {
    String? parentId,
    int parentDepth = 0,
  }) {
    final newDepth = parentDepth == 0 ? 1 : (parentDepth >= 3 ? 3 : parentDepth + 1);
    final newComment = CommentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: authorName,
      content: content,
      parentId: parentId,
      createdAt: DateTime.now(),
      depth: newDepth,
      replies: const [],
    );

    final currentList = List<CommentItem>.from(commentsMap[articleId] ?? []);

    if (parentId == null) {
      commentsMap[articleId] = [...currentList, newComment];
    } else {
      commentsMap[articleId] = _insertReply(currentList, parentId, newComment);
    }
  }

  List<CommentItem> _insertReply(
    List<CommentItem> list,
    String targetId,
    CommentItem reply,
  ) {
    return list.map((c) {
      if (c.id == targetId) {
        return c.copyWith(replies: [...c.replies, reply]);
      }
      if (c.replies.isNotEmpty) {
        return c.copyWith(replies: _insertReply(c.replies, targetId, reply));
      }
      return c;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  //  Mock data
  // ---------------------------------------------------------------------------
  void _loadMockData() {
    categories.assignAll([
      const InformasiCategory(
        id: 'pengumuman',
        name: 'Pengumuman',
        color: Color(0xFF1565C0),
        icon: Icons.campaign_rounded,
      ),
      const InformasiCategory(
        id: 'kebijakan',
        name: 'Kebijakan',
        color: Color(0xFF2E7D32),
        icon: Icons.policy_rounded,
      ),
      const InformasiCategory(
        id: 'agenda',
        name: 'Agenda',
        color: Color(0xFFED6C02),
        icon: Icons.event_rounded,
      ),
      const InformasiCategory(
        id: 'berita',
        name: 'Berita',
        color: Color(0xFF6A1B9A),
        icon: Icons.newspaper_rounded,
      ),
    ]);

    final now = DateTime.now();

    items.assignAll([
      InformasiItem(
        id: 'inf-01',
        title: 'Perubahan Sistem Presensi Mulai Bulan Juni 2026',
        content:
            'Dalam rangka meningkatkan akurasi dan keamanan data kehadiran pegawai, Pemerintah Kabupaten Barru akan mengimplementasikan sistem presensi berbasis biometrik wajah secara penuh mulai 1 Juni 2026. Semua pegawai diwajibkan untuk melakukan pendaftaran wajah (face enrollment) paling lambat tanggal 25 Mei 2026 melalui aplikasi ini.\n\nProses pendaftaran membutuhkan waktu kurang dari 5 menit dan dapat dilakukan langsung dari smartphone masing-masing. Bagi yang mengalami kendala teknis, silakan hubungi Bidang IT Diskominfo.\n\nKetentuan lebih lanjut akan disampaikan melalui surat edaran resmi.',
        categoryId: 'pengumuman',
        author: 'Bidang Kepegawaian',
        isPinned: true,
        publishedAt: now.subtract(const Duration(hours: 3)),
        tags: ['presensi', 'biometrik', 'kebijakan'],
        commentCount: 4,
        viewCount: 128,
      ),
      InformasiItem(
        id: 'inf-02',
        title: 'Jadwal Upacara Peringatan Hari Kebangkitan Nasional 2026',
        content:
            'Sehubungan dengan Hari Kebangkitan Nasional tanggal 20 Mei 2026, seluruh ASN di lingkungan Pemerintah Kabupaten Barru diwajibkan mengikuti upacara bendera yang akan diselenggarakan:\n\nHari/Tanggal: Rabu, 20 Mei 2026\nWaktu: Pukul 07.30 WITA\nTempat: Lapangan Kantor Bupati Barru\nPakaian: PDH Warna Krem\n\nAbsensi kehadiran upacara akan tercatat dalam sistem presensi. Tidak hadir tanpa keterangan yang sah akan dianggap alpha.',
        categoryId: 'agenda',
        author: 'Bagian Umum Setda',
        isPinned: true,
        publishedAt: now.subtract(const Duration(hours: 8)),
        tags: ['upacara', 'hari nasional'],
        commentCount: 2,
        viewCount: 95,
      ),
      InformasiItem(
        id: 'inf-03',
        title: 'Penyesuaian Besaran TPP Triwulan II Tahun 2026',
        content:
            'Berdasarkan Keputusan Bupati Barru No. 012/2026 tentang Penyesuaian Besaran Tambahan Penghasilan Pegawai (TPP), terdapat perubahan komponen dan besaran TPP yang berlaku mulai April–Juni 2026.\n\nPerubahan utama meliputi penyesuaian komponen kehadiran dan kinerja sesuai dengan evaluasi semester I. Informasi lengkap dapat dilihat pada portal SIMPEG atau menghubungi Bagian Keuangan.',
        categoryId: 'kebijakan',
        author: 'Bagian Keuangan Setda',
        isPinned: false,
        publishedAt: now.subtract(const Duration(days: 1)),
        tags: ['TPP', 'keuangan', 'kebijakan'],
        commentCount: 6,
        viewCount: 210,
      ),
      InformasiItem(
        id: 'inf-04',
        title: 'Pelatihan Aplikasi e-Kinerja ASN Angkatan III',
        content:
            'Badan Kepegawaian Daerah mengundang seluruh ASN untuk mengikuti Pelatihan Penggunaan Aplikasi e-Kinerja ASN Angkatan III yang akan dilaksanakan secara online melalui platform Zoom Meeting.\n\nPendaftaran dibuka hingga 18 Mei 2026. Peserta yang telah mendaftar akan mendapatkan link pertemuan melalui email dinas masing-masing.',
        categoryId: 'agenda',
        author: 'Badan Kepegawaian Daerah',
        isPinned: false,
        publishedAt: now.subtract(const Duration(days: 2)),
        tags: ['pelatihan', 'e-kinerja', 'ASN'],
        commentCount: 3,
        viewCount: 87,
      ),
      InformasiItem(
        id: 'inf-05',
        title: 'Hasil Penilaian Kinerja ASN Semester I 2026',
        content:
            'Hasil penilaian kinerja ASN periode Januari–Juni 2026 telah selesai direkapitulasi. Nilai kinerja dapat dilihat masing-masing melalui dashboard e-Kinerja. Bagi ASN yang keberatan dengan hasil penilaian, dapat mengajukan sanggahan paling lambat 20 Mei 2026.',
        categoryId: 'berita',
        author: 'BKD Barru',
        isPinned: false,
        publishedAt: now.subtract(const Duration(days: 3)),
        tags: ['kinerja', 'penilaian'],
        commentCount: 8,
        viewCount: 312,
      ),
      InformasiItem(
        id: 'inf-06',
        title: 'Pengumuman Peserta Seleksi Jabatan Pimpinan Tinggi Pratama',
        content:
            'Panitia Seleksi Jabatan Pimpinan Tinggi Pratama di Lingkungan Pemerintah Kabupaten Barru mengumumkan peserta yang lulus seleksi administrasi. Seleksi kompetensi akan dilaksanakan pada 25–27 Mei 2026 bertempat di BKN Regional IV Makassar.',
        categoryId: 'pengumuman',
        author: 'Bagian Organisasi Setda',
        isPinned: false,
        publishedAt: now.subtract(const Duration(days: 4)),
        tags: ['seleksi', 'jabatan', 'JPT'],
        commentCount: 12,
        viewCount: 445,
      ),
      InformasiItem(
        id: 'inf-07',
        title: 'Kebijakan Baru: Pengajuan Cuti Harus via Aplikasi',
        content:
            'Terhitung mulai 1 Juni 2026, seluruh pengajuan cuti ASN di lingkungan Pemkab Barru wajib dilakukan melalui aplikasi presensi ini. Pengajuan manual (kertas) tidak akan diproses. Pastikan Anda sudah memiliki akun yang aktif dan memahami alur pengajuan cuti di menu Pengajuan.',
        categoryId: 'kebijakan',
        author: 'Bidang Kepegawaian',
        isPinned: false,
        publishedAt: now.subtract(const Duration(days: 5)),
        tags: ['cuti', 'digital', 'kebijakan'],
        commentCount: 15,
        viewCount: 523,
      ),
      InformasiItem(
        id: 'inf-08',
        title: 'Peluncuran Fitur Presensi Geofencing Seluruh OPD',
        content:
            'Fitur presensi berbasis geofencing kini telah aktif untuk seluruh OPD di Kabupaten Barru. Dengan fitur ini, sistem secara otomatis memverifikasi bahwa presensi dilakukan dari dalam area kantor. Bagi OPD yang belum terdata titik lokasinya, harap segera menghubungi Diskominfo.',
        categoryId: 'berita',
        author: 'Dinas Kominfo Barru',
        isPinned: false,
        publishedAt: now.subtract(const Duration(days: 7)),
        tags: ['geofencing', 'presensi', 'teknologi'],
        commentCount: 9,
        viewCount: 278,
      ),
    ]);

    // Mock comments untuk artikel pertama
    commentsMap['inf-01'] = [
      CommentItem(
        id: 'c1',
        authorName: 'Andi Rahman',
        content: 'Apakah ada panduan teknis untuk proses pendaftaran wajah? Khawatir HP saya tidak support.',
        createdAt: now.subtract(const Duration(hours: 2)),
        depth: 1,
        replies: [
          CommentItem(
            id: 'c1r1',
            authorName: 'Bidang IT Diskominfo',
            content: 'Panduan lengkap akan dikirim ke email dinas masing-masing. Untuk spesifikasi minimum HP, kamera depan minimal 5MP sudah cukup.',
            parentId: 'c1',
            createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
            depth: 2,
            replies: [
              CommentItem(
                id: 'c1r1r1',
                authorName: 'Andi Rahman',
                content: 'Terima kasih, HP saya kameranya 8MP jadi aman dong ya.',
                parentId: 'c1r1',
                createdAt: now.subtract(const Duration(hours: 1)),
                depth: 3,
                replies: const [],
              ),
            ],
          ),
        ],
      ),
      CommentItem(
        id: 'c2',
        authorName: 'Sri Wahyuni',
        content: 'Kalau pegawai yang bertugas di lapangan dan sulit akses internet gimana pak?',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
        depth: 1,
        replies: [
          CommentItem(
            id: 'c2r1',
            authorName: 'Bidang Kepegawaian',
            content: 'Untuk pegawai tugas lapangan ada mekanisme khusus. Harap koordinasikan dengan atasan langsung dan BKD.',
            parentId: 'c2',
            createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
            depth: 2,
            replies: const [],
          ),
        ],
      ),
    ];

    commentsMap['inf-05'] = [
      CommentItem(
        id: 'c3',
        authorName: 'Baharuddin',
        content: 'Saya tidak bisa mengakses dashboard e-Kinerja, selalu error 403.',
        createdAt: now.subtract(const Duration(days: 2, hours: 3)),
        depth: 1,
        replies: [
          CommentItem(
            id: 'c3r1',
            authorName: 'Admin e-Kinerja',
            content: 'Mohon kirimkan NIP dan screenshot error ke email helpdesk@barrukab.go.id untuk kami tindaklanjuti.',
            parentId: 'c3',
            createdAt: now.subtract(const Duration(days: 2, hours: 2)),
            depth: 2,
            replies: const [],
          ),
        ],
      ),
    ];
  }
}
