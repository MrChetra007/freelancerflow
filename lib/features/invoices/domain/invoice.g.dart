// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvoiceImpl _$$InvoiceImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceImpl(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String,
      projectId: json['project_id'] as String?,
      invoiceNumber: json['invoice_number'] as String,
      status:
          $enumDecodeNullable(_$InvoiceStatusEnumMap, json['status']) ??
          InvoiceStatus.draft,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxPercent: (json['tax_percent'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      notes: json['notes'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      sentAt: json['sent_at'] == null
          ? null
          : DateTime.parse(json['sent_at'] as String),
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$InvoiceImplToJson(_$InvoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'client_id': instance.clientId,
      'project_id': instance.projectId,
      'invoice_number': instance.invoiceNumber,
      'status': _$InvoiceStatusEnumMap[instance.status]!,
      'issue_date': instance.issueDate.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
      'subtotal': instance.subtotal,
      'tax_percent': instance.taxPercent,
      'tax_amount': instance.taxAmount,
      'discount_percent': instance.discountPercent,
      'discount_amount': instance.discountAmount,
      'total': instance.total,
      'currency': instance.currency,
      'notes': instance.notes,
      'payment_terms': instance.paymentTerms,
      'pdf_url': instance.pdfUrl,
      'sent_at': instance.sentAt?.toIso8601String(),
      'paid_at': instance.paidAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'draft',
  InvoiceStatus.sent: 'sent',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
  InvoiceStatus.cancelled: 'cancelled',
};
