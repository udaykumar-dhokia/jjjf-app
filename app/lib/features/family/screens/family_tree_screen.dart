import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:genealogy_chart/genealogy_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../models/user_model.dart';
import '../../../providers/family_provider.dart';
import '../../../providers/user_provider.dart';
import 'add_edit_family_member_screen.dart';
import '../../../core/widgets/skeleton_loading_wrapper.dart';

class FamilyTreeScreen extends StatefulWidget {
  final String? familyId;

  const FamilyTreeScreen({super.key, this.familyId});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.familyId != null) {
        context.read<FamilyProvider>().fetchFamilyById(widget.familyId!);
      } else {
        context.read<FamilyProvider>().fetchMyFamily();
      }
    });
  }

  void _showMemberOptions(BuildContext context, UserModel member, bool isHead) {
    if (!isHead) return; // Only Head can edit/delete

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const HugeIcon(
                  icon: HugeIcons.strokeRoundedEdit02,
                  color: AppTheme.primaryPurple,
                ),
                title: const Text('Edit Member'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditFamilyMemberScreen(memberToEdit: member),
                    ),
                  );
                },
              ),
              if (!member.isHeadOfFamily)
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete01,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Remove Member',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Remove Member'),
                        content: Text(
                          'Are you sure you want to remove ${member.firstName} from your family?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text(
                              'Remove',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      await context.read<FamilyProvider>().removeFamilyMember(
                        member.id,
                      );
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  List<FamilyMember> _mapToFamilyMembers(
    List<UserModel> users,
    UserModel? head,
  ) {
    if (head == null) return [];

    List<FamilyMember> members = [];

    // Add head
    members.add(
      FamilyMember(
        id: head.id,
        name: '${head.firstName} ${head.fatherName}',
        avatar:
            head.photoUrl ??
            'https://api.dicebear.com/10.x/glass/png?seed=${head.firstName}',
        status: MemberStatus.online,
        generation: 0,
        parentIds: users
            .where(
              (u) =>
                  u.relationshipToHead == 'FATHER' ||
                  u.relationshipToHead == 'MOTHER',
            )
            .map((u) => u.id)
            .toList(),
        spouseIds: users
            .where((u) => u.relationshipToHead == 'SPOUSE')
            .map((u) => u.id)
            .toList(),
      ),
    );

    // Add others
    for (var user in users) {
      if (user.id == head.id) continue;

      int generation = 0;
      List<String> parentIds = [];
      List<String> spouseIds = [];

      switch (user.relationshipToHead) {
        case 'SPOUSE':
          generation = 0;
          spouseIds = [head.id];
          break;
        case 'SON':
        case 'DAUGHTER':
          generation = 1;
          parentIds = [head.id];
          break;
        case 'GRANDSON':
        case 'GRANDDAUGHTER':
          generation = 2;
          // Fallback connect to head to avoid floating nodes
          parentIds = [head.id];
          break;
        case 'FATHER':
        case 'MOTHER':
          generation = -1;
          break;
        case 'BROTHER':
        case 'SISTER':
          generation = 0;
          parentIds = users
              .where(
                (u) =>
                    u.relationshipToHead == 'FATHER' ||
                    u.relationshipToHead == 'MOTHER',
              )
              .map((u) => u.id)
              .toList();
          // If no parents exist in the app yet, we cannot draw a sibling line naturally in this chart lib.
          // But they will appear in generation 0.
          break;
        default:
          generation = 0;
      }

      members.add(
        FamilyMember(
          id: user.id,
          name: '${user.firstName} ${user.fatherName}',
          avatar:
              user.photoUrl ??
              'https://api.dicebear.com/10.x/glass/png?seed=${user.firstName}',
          status: MemberStatus.online,
          generation: generation,
          parentIds: parentIds,
          spouseIds: spouseIds,
        ),
      );
    }

    return members;
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = context.watch<FamilyProvider>();
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.userProfile;
    final isReadOnly = widget.familyId != null;
    final isHead = !isReadOnly && (currentUser?.isHeadOfFamily ?? false);

    final familyData = isReadOnly ? familyProvider.viewingFamily : familyProvider.myFamily;
    final familyMembers = isReadOnly ? familyProvider.viewingMembers : familyProvider.members;
    final headOfFamily = isReadOnly ? familyProvider.viewingHeadOfFamily : familyProvider.headOfFamily;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: isReadOnly ? 'Family Tree' : 'My Family Tree',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () {
                if (isReadOnly) {
                  familyProvider.fetchFamilyById(widget.familyId!);
                } else {
                  familyProvider.fetchMyFamily();
                }
              },
            ),
          ],
        ),
        body: SkeletonLoadingWrapper(
          isLoading: familyProvider.isLoading,
          child: familyProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        familyProvider.error!,
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (isReadOnly) {
                            familyProvider.fetchFamilyById(widget.familyId!);
                          } else {
                            familyProvider.fetchMyFamily();
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : familyData == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedUserGroup,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Family Yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Create your family tree, become the head of the family, and start adding your relatives.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (!isReadOnly)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () async {
                                final success = await familyProvider
                                    .createFamily();
                                if (success && mounted) {
                                  context.read<UserProvider>().fetchMyProfile();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Family created successfully! You are now the Head.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Create Family',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : GenealogyChart.family(
                  enablePan: true,
                  enableZoom: true,
                  members: _mapToFamilyMembers(
                    familyMembers,
                    headOfFamily,
                  ),
                  layout: FamilyTreeLayout(
                    generationHeight:
                        250, // Increased to prevent node overlap and show edges clearly
                    siblingSpacing: 100,
                  ),
                  familyNodeStyle: FamilyNodeStyle.detailed,
                  familyNodeBuilder: (context, member, state) {
                    final userModel = familyMembers.firstWhere(
                      (m) => m.id == member.id,
                      orElse: () => headOfFamily!,
                    );
                    return Container(
                      width: 180,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.isSelected
                              ? AppTheme.primaryPurple
                              : Colors.grey.shade300,
                          width: state.isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: NetworkImage(member.avatar!),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              userModel.relationshipToHead == 'SELF'
                                  ? 'HEAD OF FAMILY'
                                  : (userModel.relationshipToHead ?? 'UNKNOWN').replaceAll(
                                      '_',
                                      ' ',
                                    ),
                              style: const TextStyle(
                                color: AppTheme.primaryPurple,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onMemberTap: (fm) {
                    if (isReadOnly) return;
                    final userModel = familyMembers.firstWhere(
                      (m) => m.id == fm.id,
                    );
                    _showMemberOptions(context, userModel, isHead);
                  },
                ),
        ),
        floatingActionButton: isHead
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddEditFamilyMemberScreen(),
                    ),
                  );
                },
                backgroundColor: AppTheme.primaryPurple,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedUserAdd01,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                label: const Text(
                  'Add Member',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : null,
      ),
    );
  }
}
