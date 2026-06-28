import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _users = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    setState(() => _loading = true);
    final list = await _firestoreService.getAllUsers();
    setState(() {
      _users = list;
      _loading = false;
    });
  }

  void _toggleVerification(UserModel user, bool val) async {
    await _firestoreService.toggleUserVerification(user.uid, val);
    _loadUsers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? 'Mentor ${user.fullName} is verified!' : 'Verification removed.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteUser(UserModel user) async {
    // Confirm delete
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User?'),
          content: Text('Are you sure you want to permanently delete the account of ${user.fullName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _firestoreService.deleteUserAccount(user.uid);
                Navigator.pop(context);
                _loadUsers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User account deleted.'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Computed Stats
    final totalUsers = _users.length;
    final totalMentors = _users.where((u) => u.role == UserRole.mentor).length;
    final verifiedMentors = _users.where((u) => u.isVerifiedMentor).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Analytics Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Users',
                          value: totalUsers.toString(),
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Mentors',
                          value: totalMentors.toString(),
                          color: const Color(0xFF14B8A6), // Teal
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Verified Mentors',
                          value: verifiedMentors.toString(),
                          color: const Color(0xFFF59E0B), // Amber
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28.0),

                  // 2. User Management section
                  Text('Manage Profiles & Verification', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final u = _users[index];
                      final isMentor = u.role == UserRole.mentor;

                      return Card(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20.0,
                                backgroundImage: NetworkImage(u.profilePicture),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                                        if (u.isVerifiedMentor) ...[
                                          const SizedBox(width: 4.0),
                                          const Icon(Icons.verified, color: Colors.blue, size: 14.0),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      'Role: ${u.role.toString().split('.').last.toUpperCase()}',
                                      style: TextStyle(fontSize: 10.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                    ),
                                  ],
                                ),
                              ),
                              if (isMentor)
                                Row(
                                  children: [
                                    const Text('Verify:', style: TextStyle(fontSize: 11.0)),
                                    Switch(
                                      value: u.isVerifiedMentor,
                                      onChanged: (val) => _toggleVerification(u, val),
                                    ),
                                  ],
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20.0),
                                onPressed: () => _deleteUser(u),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
