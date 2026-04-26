import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../data/clients_provider.dart';
import '../domain/client.dart';

class AddClientScreen extends ConsumerStatefulWidget {
  final String? clientId;

  const AddClientScreen({super.key, this.clientId});

  @override
  ConsumerState<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends ConsumerState<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCountry = 'US';
  String _selectedCurrency = 'USD';
  String _avatarColor = '#2563EB';
  bool _isLoading = false;
  Client? _existingClient;

  final _currencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'JPY',
    'SGD',
    'THB',
    'KHR',
  ];
  final _countries = {
    'US': 'United States',
    'GB': 'United Kingdom',
    'CA': 'Canada',
    'AU': 'Australia',
    'DE': 'Germany',
    'FR': 'France',
    'ES': 'Spain',
    'IT': 'Italy',
    'JP': 'Japan',
    'CN': 'China',
    'IN': 'India',
    'KH': 'Cambodia',
    'TH': 'Thailand',
    'SG': 'Singapore',
    'MY': 'Malaysia',
  };

  final _avatarColors = [
    '#2563EB',
    '#7C3AED',
    '#DB2777',
    '#DC2626',
    '#EA580C',
    '#CA8A04',
    '#16A34A',
    '#0D9488',
  ];

  bool get isEditing => widget.clientId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadClient();
    }
  }

  Future<void> _loadClient() async {
    final repo = ref.read(clientRepositoryProvider);
    final client = await repo.getClient(widget.clientId!);
    if (client != null && mounted) {
      setState(() {
        _existingClient = client;
        _nameController.text = client.name;
        _emailController.text = client.email ?? '';
        _phoneController.text = client.phone ?? '';
        _companyController.text = client.company ?? '';
        _notesController.text = client.notes ?? '';
        _selectedCountry = client.country ?? 'US';
        _selectedCurrency = client.currency;
        _avatarColor = client.avatarColor;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;

      if (isEditing && _existingClient != null) {
        final updated = _existingClient!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          company: _companyController.text.trim().isEmpty
              ? null
              : _companyController.text.trim(),
          country: _selectedCountry,
          currency: _selectedCurrency,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          avatarColor: _avatarColor,
        );
        await ref.read(clientsProvider.notifier).updateClient(updated);
      } else {
        final newClient = Client(
          id: '',
          userId: userId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          company: _companyController.text.trim().isEmpty
              ? null
              : _companyController.text.trim(),
          country: _selectedCountry,
          currency: _selectedCurrency,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          avatarColor: _avatarColor,
          createdAt: DateTime.now(),
        );
        await ref.read(clientsProvider.notifier).addClient(newClient);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(isEditing ? 'Edit Client' : 'New Client'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveClient,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(
                      int.parse(_avatarColor.replaceFirst('#', '0xFF')),
                    ),
                    child: Text(
                      _nameController.text
                          .split(' ')
                          .take(2)
                          .map((e) => e.isNotEmpty ? e[0] : '')
                          .join()
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: _avatarColors.map((color) {
                final isSelected = color == _avatarColor;
                return GestureDetector(
                  onTap: () => setState(() => _avatarColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v?.trim().isEmpty == true ? 'Name is required' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCountry,
                    decoration: const InputDecoration(labelText: 'Country'),
                    items: _countries.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCountry = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCurrency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCurrency = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
