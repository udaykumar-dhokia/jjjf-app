import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../providers/matrimony_provider.dart';
import '../../../models/matrimony_access_request_model.dart';

class MatrimonyRequestsScreen extends StatefulWidget {
  const MatrimonyRequestsScreen({super.key});

  @override
  State<MatrimonyRequestsScreen> createState() =>
      _MatrimonyRequestsScreenState();
}

class _MatrimonyRequestsScreenState extends State<MatrimonyRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MatrimonyProvider>();
      if (provider.receivedRequests.isEmpty && provider.sentRequests.isEmpty) {
        provider.fetchRequests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Access Requests',
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppTheme.primaryPurple,
            size: 24,
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryPurple,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: Consumer<MatrimonyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading &&
              provider.receivedRequests.isEmpty &&
              provider.sentRequests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRequestList(
                provider.receivedRequests,
                isReceived: true,
                provider: provider,
              ),
              _buildRequestList(
                provider.sentRequests,
                isReceived: false,
                provider: provider,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestList(
    List<MatrimonialAccessRequest> requests, {
    required bool isReceived,
    required MatrimonyProvider provider,
  }) {
    return RefreshIndicator(
      onRefresh: () => provider.fetchRequests(),
      color: AppTheme.primaryPurple,
      child: requests.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Text(
                    isReceived
                        ? 'No pending requests received.'
                        : 'You haven\'t sent any requests.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                final name = req.otherPersonName ?? 'Unknown';
                final gotra = req.otherPersonGotra ?? 'Unknown';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primaryPurple.withOpacity(
                            0.1,
                          ),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            color: AppTheme.primaryPurple,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                gotra,
                                style: const TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: req.status == 'APPROVED'
                                      ? Colors.green.withOpacity(0.1)
                                      : (req.status == 'REJECTED'
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  req.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: req.status == 'APPROVED'
                                        ? Colors.green
                                        : (req.status == 'REJECTED'
                                              ? Colors.red
                                              : Colors.orange),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isReceived && req.status == 'PENDING') ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const HugeIcon(
                                  icon:
                                      HugeIcons.strokeRoundedCheckmarkCircle02,
                                  color: Colors.green,
                                  size: 32,
                                ),
                                onPressed: () => provider.updateRequestStatus(
                                  req.id,
                                  'APPROVED',
                                ),
                              ),
                              IconButton(
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancelCircle,
                                  color: Colors.red,
                                  size: 32,
                                ),
                                onPressed: () => provider.updateRequestStatus(
                                  req.id,
                                  'REJECTED',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
