import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../providers/directory_provider.dart';
import '../../../models/user_model.dart';
import 'contact_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch latest directory on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DirectoryProvider>().fetchDirectory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<UserModel>> _groupContacts(List<UserModel> contacts) {
    Map<String, List<UserModel>> grouped = {};
    for (var contact in contacts) {
      if (contact.firstName.isEmpty) continue;
      String initial = contact.firstName[0].toUpperCase();
      if (!grouped.containsKey(initial)) {
        grouped[initial] = [];
      }
      grouped[initial]!.add(contact);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(
          title: 'Directory',
          foregroundColor: AppTheme.primaryPurple,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.setSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search by Name, Gotra, or City...',
                    prefixIcon: HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Contact List
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryPurple,
                      ),
                    )
                  : provider.error != null
                  ? Center(
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : _buildContactList(provider.filteredContacts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(List<UserModel> contacts) {
    if (contacts.isEmpty) {
      return const Center(
        child: Text(
          'No contacts found.',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }

    final grouped = _groupContacts(contacts);
    final sortedKeys = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        String letter = sortedKeys[index];
        List<UserModel> sectionContacts = grouped[letter]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: sectionContacts.asMap().entries.map((entry) {
                  int idx = entry.key;
                  UserModel contact = entry.value;
                  bool isLast = idx == sectionContacts.length - 1;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryPurple.withOpacity(
                            0.1,
                          ),
                          backgroundImage: NetworkImage(
                            'https://api.dicebear.com/10.x/glass/png?seed=${contact.firstName}',
                          ),
                        ),
                        title: Text(
                          '${contact.firstName} ${contact.fatherName} ${contact.gotra}'
                              .trim(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          contact.currentCity,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ContactDetailScreen(contact: contact),
                            ),
                          );
                        },
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          indent: 72,
                          endIndent: 16,
                          color: Colors.black12,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
