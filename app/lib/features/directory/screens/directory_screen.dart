import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/directory_provider.dart';
import '../../../models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/directory_filter_sheet.dart';
import 'contact_detail_screen.dart';
import '../../../core/widgets/skeleton_loading_wrapper.dart';

class DirectoryScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const DirectoryScreen({super.key, this.onMenuTap});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

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
        appBar: CustomAppBar(
          title: 'Directory',
          leading: widget.onMenuTap != null
              ? IconButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedMenu01,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                  onPressed: widget.onMenuTap,
                )
              : null,
          actions: [
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: _isSearchExpanded
                    ? AppTheme.primaryPurple
                    : Colors.black87,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = !_isSearchExpanded;
                  if (!_isSearchExpanded) {
                    _searchController.clear();
                    context.read<DirectoryProvider>().setSearchQuery('');
                  }
                });
              },
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedFilterHorizontal,
                    color: provider.activeFilter.isEmpty
                        ? Colors.black87
                        : AppTheme.primaryPurple,
                    size: 24,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                        ),
                        child: const DirectoryFilterSheet(),
                      ),
                    );
                  },
                ),
                if (!provider.activeFilter.isEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isSearchExpanded
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: CustomTextField(
                        controller: _searchController,
                        onChanged: provider.setSearchQuery,
                        hintText: 'Search by Name, Gotra, or City...',
                        prefixIcon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          color: AppTheme.primaryPurple,
                          size: 20,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            // Contact List
            Expanded(
              child: SkeletonLoadingWrapper(
                isLoading: provider.isLoading,
                child: provider.error != null
                    ? Center(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _buildContactList(
                        provider.isLoading && provider.filteredContacts.isEmpty
                            ? List.generate(5, (index) => UserModel.dummy())
                            : provider.filteredContacts,
                      ),
              ),
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
      physics: const BouncingScrollPhysics(),
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
                          radius: 16,
                          backgroundColor: AppTheme.primaryPurple.withOpacity(
                            0.1,
                          ),
                          backgroundImage: contact.photoUrl != null
                              ? NetworkImage(contact.photoUrl!) as ImageProvider
                              : NetworkImage(
                                  'https://api.dicebear.com/10.x/glass/png?seed=${contact.firstName}',
                                ),
                        ),
                        title: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${contact.firstName} ${contact.fatherName}'
                                        .trim(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: ' | ${contact.gaon}',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Text(
                          contact.currentCity,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                        trailing:
                            (contact.whatsappNumber != null &&
                                contact.whatsappNumber!.isNotEmpty)
                            ? IconButton(
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedWhatsapp,
                                  color: Color(0xFF25D366),
                                  size: 24,
                                ),
                                onPressed: () async {
                                  final String waPhone = contact.whatsappNumber!
                                      .replaceAll(RegExp(r'\D'), '');
                                  final String finalPhone = waPhone.length == 10
                                      ? '91$waPhone'
                                      : waPhone;
                                  final Uri url = Uri.parse(
                                    'https://wa.me/$finalPhone',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                              )
                            : (contact.isPhoneNumberVisible &&
                                  contact.phoneNumber.isNotEmpty)
                            ? IconButton(
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCall02,
                                  color: AppTheme.primaryPurple,
                                  size: 24,
                                ),
                                onPressed: () async {
                                  final Uri url = Uri.parse(
                                    'tel:${contact.phoneNumber}',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                              )
                            : null,
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
