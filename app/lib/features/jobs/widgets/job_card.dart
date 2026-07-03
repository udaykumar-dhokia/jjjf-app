import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/job_model.dart';

class JobCard extends StatefulWidget {
  final JobModel job;

  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _isExpanded = false;

  void _launchWhatsApp(String phone, String roleTitle) async {
    // Remove '+' if present and non-numeric chars for wa.me
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final message = Uri.encodeComponent(
      "Hello, I saw your job post for $roleTitle on Jalore Jain Sangh app...",
    );
    final url = Uri.parse("https://wa.me/$cleanPhone?text=$message");

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      _launchPhone(phone);
    }
  }

  void _launchPhone(String phone) async {
    final url = Uri.parse("tel:$phone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint("Could not launch phone $e");
    }
  }

  void _launchLink(String link) async {
    var finalLink = link;
    if (!finalLink.startsWith('http')) {
      finalLink = 'https://$link';
    }
    final url = Uri.parse(finalLink);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Could not launch url $e");
    }
  }

  void _showLinksSheet(BuildContext context, List<String> links) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedLink01,
                        size: 24,
                        color: AppTheme.primaryPurple,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Attached Links',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ...links.map(
                  (link) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.backgroundLight,
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedGlobe02,
                        size: 18,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    title: Text(
                      link,
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 20,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: link));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    onTap: () {
                      _launchLink(link);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final user = job.postedBy;
    final hasWhatsapp =
        job.whatsappNumber != null && job.whatsappNumber!.isNotEmpty;
    final hasPhone = job.contactPhone != null && job.contactPhone!.isNotEmpty;
    final hasLinks = job.links.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      clipBehavior:
          Clip.antiAlias, // Ensures InkWell ripple stays inside rounded corners
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Industry
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      job.roleTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textDark,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.industry,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // City and Salary Row
              Wrap(
                spacing: 16.0,
                runSpacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        color: AppTheme.textLight,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.city,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  if (job.salaryRange != null && job.salaryRange!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedMoney01,
                          color: AppTheme.textLight,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.salaryRange!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textLight),
                        ),
                      ],
                    ),
                ],
              ),

              // Animated Expansion Area
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            job.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),

                          // Links Section
                          if (hasLinks) ...[
                            const SizedBox(height: 16),
                            if (job.links.length == 1)
                              OutlinedButton.icon(
                                onPressed: () => _launchLink(job.links.first),
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedLink01,
                                  size: 18,
                                ),
                                label: const Text('View Attached Link'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryPurple,
                                  side: const BorderSide(
                                    color: AppTheme.primaryPurple,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showLinksSheet(context, job.links),
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedLink01,
                                  size: 18,
                                ),
                                label: Text(
                                  'View Attached Links (${job.links.length})',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryPurple,
                                  side: const BorderSide(
                                    color: AppTheme.primaryPurple,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                          ],
                          const SizedBox(height: 8),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Footer: User Info and Actions
              Row(
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                    backgroundImage: user?.photoUrl != null
                        ? CachedNetworkImageProvider(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            color: AppTheme.primaryPurple,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // User Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.contactName.isNotEmpty
                              ? job.contactName
                              : 'Unknown Contact',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Posted ${job.createdAt != null ? _formatDate(job.createdAt!) : "recently"}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.textLight,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons (Only show when expanded, or show a single "Expand" icon if collapsed?)
                  // Let's show actions always, but we could hide them to encourage expanding.
                  // For now, let's keep them always visible so they can quick-call.
                  if (hasWhatsapp)
                    IconButton(
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedWhatsapp,
                        color: Colors.green,
                        size: 22,
                      ),
                      onPressed: () =>
                          _launchWhatsApp(job.whatsappNumber!, job.roleTitle),
                      tooltip: 'WhatsApp',
                    )
                  else if (hasPhone)
                    IconButton(
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCall02,
                        color: AppTheme.primaryPurple,
                        size: 22,
                      ),
                      onPressed: () => _launchPhone(job.contactPhone!),
                      tooltip: 'Call',
                    ),

                  // Visual indicator for expand/collapse
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
