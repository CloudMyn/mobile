import 'package:flutter/material.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';

class RequestSupervisorPage extends StatelessWidget {
  const RequestSupervisorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopAppBar(
        title: 'Ajukan Atasan Baru',
        variant: AppTopAppBarVariant.standard,
      ),
      body: const Center(
        child: Text('Form pengajuan atasan (Tahap Pengembangan)'),
      ),
    );
  }
}
