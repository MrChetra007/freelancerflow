import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/project.dart';
import '../domain/milestone.dart';

class ProjectRepository {
  final SupabaseClient _client;

  ProjectRepository(this._client);

  String _toDbStatus(ProjectStatus status) {
    return status.name.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  Future<List<Project>> getProjects() async {
    final response = await _client
        .from('projects')
        .select()
        .eq('is_archived', false)
        .order('created_at', ascending: false);
    return response.map((json) => _projectFromDb(json)).toList();
  }

  Future<List<Project>> getProjectsByClient(String clientId) async {
    final response = await _client
        .from('projects')
        .select()
        .eq('client_id', clientId)
        .eq('is_archived', false)
        .order('created_at', ascending: false);
    return response.map((json) => _projectFromDb(json)).toList();
  }

  Future<Project?> getProject(String id) async {
    final response = await _client
        .from('projects')
        .select()
        .eq('id', id)
        .single();
    return _projectFromDb(response);
  }

  Future<Project> createProject(Project project) async {
    final response = await _client
        .from('projects')
        .insert({
          'user_id': project.userId,
          'client_id': project.clientId,
          'title': project.title,
          'description': project.description,
          'status': _toDbStatus(project.status),
          'budget': project.budget,
          'currency': project.currency,
          'start_date': project.startDate?.toIso8601String().split('T')[0],
          'deadline': project.deadline?.toIso8601String().split('T')[0],
          'is_archived': project.isArchived,
        })
        .select()
        .single();
    return _projectFromDb(response);
  }

  Future<Project> updateProject(Project project) async {
    final response = await _client
        .from('projects')
        .update({
          'title': project.title,
          'description': project.description,
          'status': _toDbStatus(project.status),
          'budget': project.budget,
          'currency': project.currency,
          'start_date': project.startDate?.toIso8601String().split('T')[0],
          'deadline': project.deadline?.toIso8601String().split('T')[0],
          'is_archived': project.isArchived,
          'completed_at': project.completedAt?.toIso8601String(),
        })
        .eq('id', project.id!)
        .select()
        .single();
    return _projectFromDb(response);
  }

  Future<void> deleteProject(String id) async {
    await _client.from('projects').delete().eq('id', id);
  }

  Future<List<Milestone>> getMilestones(String projectId) async {
    final response = await _client
        .from('milestones')
        .select()
        .eq('project_id', projectId)
        .order('sort_order', ascending: true);
    return response.map((json) => _milestoneFromDb(json)).toList();
  }

  Future<Milestone> createMilestone(Milestone milestone) async {
    final response = await _client
        .from('milestones')
        .insert({
          'project_id': milestone.projectId,
          'user_id': milestone.userId,
          'title': milestone.title,
          'is_completed': milestone.isCompleted,
          'due_date': milestone.dueDate?.toIso8601String().split('T')[0],
          'sort_order': milestone.sortOrder,
        })
        .select()
        .single();
    return _milestoneFromDb(response);
  }

  Future<Milestone> updateMilestone(Milestone milestone) async {
    final response = await _client
        .from('milestones')
        .update({
          'title': milestone.title,
          'is_completed': milestone.isCompleted,
          'due_date': milestone.dueDate?.toIso8601String().split('T')[0],
          'sort_order': milestone.sortOrder,
          'completed_at': milestone.completedAt?.toIso8601String(),
        })
        .eq('id', milestone.id!)
        .select()
        .single();
    return _milestoneFromDb(response);
  }

  Future<void> deleteMilestone(String id) async {
    await _client.from('milestones').delete().eq('id', id);
  }

  Project _projectFromDb(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      userId: json['user_id'],
      clientId: json['client_id'],
      title: json['title'],
      description: json['description'],
      status: _parseStatus(json['status']),
      budget: (json['budget'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      isArchived: json['is_archived'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  ProjectStatus _parseStatus(String? status) {
    return switch (status) {
      'in_progress' => ProjectStatus.inProgress,
      'completed' => ProjectStatus.completed,
      'on_hold' => ProjectStatus.onHold,
      'cancelled' => ProjectStatus.cancelled,
      _ => ProjectStatus.inProgress,
    };
  }

  Milestone _milestoneFromDb(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      projectId: json['project_id'],
      userId: json['user_id'],
      title: json['title'],
      isCompleted: json['is_completed'] ?? false,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      sortOrder: json['sort_order'] ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
