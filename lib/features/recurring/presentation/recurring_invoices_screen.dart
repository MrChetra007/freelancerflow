import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/recurring_provider.dart';
import 'create_recurring_screen.dart';
import 'widgets/recurring_invoice_tile.dart';

class RecurringInvoicesScreen extends ConsumerWidget {
  const RecurringInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(recurringInvoicesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Recurring Invoices'),
      ),
      body: recurringAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.repeat, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No recurring invoices yet'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return RecurringInvoiceTile(
                invoice: invoice,
                onToggle: () async {
                  await ref
                      .read(recurringInvoiceRepositoryProvider)
                      .toggleActive(invoice.id!, !invoice.isActive);
                  ref.invalidate(recurringInvoicesProvider);
                },
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateRecurringScreen(recurring: invoice),
                    ),
                  );
                  ref.invalidate(recurringInvoicesProvider);
                },
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Recurring Invoice'),
                      content: const Text(
                        'Are you sure you want to delete this recurring invoice? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && invoice.id != null) {
                    await ref
                        .read(recurringInvoiceRepositoryProvider)
                        .delete(invoice.id!);
                    ref.invalidate(recurringInvoicesProvider);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Error loading recurring invoices')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateRecurringScreen()),
          );
          ref.invalidate(recurringInvoicesProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Recurring'),
      ),
    );
  }
}
