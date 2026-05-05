import 'package:flutter/foundation.dart';

import '../supabase/supabase_client.dart';
import 'notification_service.dart';
import '../../features/projects/data/project_repository.dart';

class MilestoneCheckService {
  Future<void> checkDueMilestones() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user for milestone check');
        return;
      }

      final projectRepo = ProjectRepository(SupabaseConfig.client);
      final dueMilestones = await projectRepo.getDueMilestones(user.id);

      if (dueMilestones.isEmpty) return;

      debugPrint('Found ${dueMilestones.length} due milestone(s)');

      for (final ms in dueMilestones) {
        final milestoneId = ms['id'] as String;
        final milestoneTitle = ms['title'] as String;
        final projectsData = ms['projects'] as Map<String, dynamic>?;
        if (projectsData == null) continue;

        final clientsData = projectsData['clients'] as Map<String, dynamic>?;
        final clientName = clientsData?['name'] as String? ?? 'Unknown';

        await NotificationService.instance.showMilestoneDue(
          milestoneId: milestoneId,
          milestoneTitle: milestoneTitle,
          clientName: clientName,
        );
      }
    } catch (e) {
      debugPrint('Error checking due milestones: $e');
    }
  }
}
