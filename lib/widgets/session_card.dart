import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
import 'custom_button.dart';
import 'neumorphic_container.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final String currentUserId;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;
  final Function(DateTime)? onReschedule;

  const SessionCard({
    super.key,
    required this.session,
    required this.currentUserId,
    this.onAccept,
    this.onReject,
    this.onComplete,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMentor = session.mentorId == currentUserId;
    final otherPartyName = isMentor ? session.learnerName : session.mentorName;
    final otherPartyPic = isMentor ? session.learnerProfilePic : session.mentorProfilePic;

    final dateStr = DateFormat('EEE, d MMM yyyy').format(session.scheduledDateTime);
    final timeStr = DateFormat('h:mm a').format(session.scheduledDateTime);

    return NeumorphicContainer(
      margin: const EdgeInsets.only(bottom: 16.0),
      borderRadius: 20.0,
      padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(otherPartyPic),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherPartyName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                      ),
                      Text(
                        isMentor ? 'Your Student' : 'Your Mentor',
                        style: TextStyle(fontSize: 11.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(session.status),
              ],
            ),
            const Divider(height: 24.0, thickness: 1.0),
            Text(
              session.skillName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14.0, color: theme.colorScheme.primary),
                const SizedBox(width: 6.0),
                Text(
                  '$dateStr at $timeStr',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            if (session.status == 'requested' && isMentor) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        side: BorderSide(color: theme.colorScheme.error),
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: onReject,
                      child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: onAccept,
                      child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ] else if (session.status == 'accepted') ...[
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      session.meetLink.isEmpty
                          ? Icons.chat_bubble_outline
                          : (session.meetLinkType.contains('Zoom') ? Icons.video_call : Icons.videocam),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.meetLink.isEmpty ? 'In-App Chat room' : session.meetLinkType,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                          ),
                          Text(
                            session.meetLink.isEmpty
                                ? 'Coordinate class details directly through peer messages.'
                                : 'Click join/copy to attend the virtual class.',
                            style: TextStyle(fontSize: 11.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ),
                    if (session.meetLink.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18.0),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: session.meetLink));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Meeting link copied to clipboard!')),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () {
                        // Open Date Picker for Reschedule
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        ).then((date) {
                          if (date != null && onReschedule != null) {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ).then((time) {
                              if (time != null) {
                                final selected = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                                onReschedule!(selected);
                              }
                            });
                          }
                        });
                      },
                      child: const Text('Reschedule'),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Completed green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: onComplete,
                      child: const Text('Mark Complete', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ] else if (session.status == 'rescheduled') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber, size: 16.0),
                        SizedBox(width: 6.0),
                        Text(
                          'Reschedule Requested',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: Colors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'Requested date: ${session.rescheduledDateTime != null ? DateFormat('EEE, d MMM, h:mm a').format(session.rescheduledDateTime!) : ""}',
                      style: TextStyle(fontSize: 12.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    if (session.rescheduledBy != currentUserId) ...[
                      const SizedBox(height: 8.0),
                      CustomButton(
                        text: 'Accept New Time',
                        verticalPadding: 8.0,
                        onPressed: onAccept, // Uses same accept action which resolves reschedule time
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (session.status == 'completed' && session.aiSummary != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: theme.colorScheme.secondary, size: 16.0),
                        const SizedBox(width: 6.0),
                        Text(
                          'AI Session Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      session.aiSummary!,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'accepted':
        color = const Color(0xFF10B981); // Green
        break;
      case 'rejected':
        color = const Color(0xFFEF4444); // Red
        break;
      case 'rescheduled':
        color = Colors.amber;
        break;
      case 'completed':
        color = const Color(0xFF3B82F6); // Blue
        break;
      case 'requested':
      default:
        color = const Color(0xFF64748B); // Slate
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
