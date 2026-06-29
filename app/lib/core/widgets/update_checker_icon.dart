import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../services/update_service.dart';
import 'update_dialog.dart';
import '../theme/app_theme.dart';

enum UpdateState { checking, upToDate, updateAvailable, error }

class UpdateCheckerIcon extends StatefulWidget {
  const UpdateCheckerIcon({super.key});

  @override
  State<UpdateCheckerIcon> createState() => _UpdateCheckerIconState();
}

class _UpdateCheckerIconState extends State<UpdateCheckerIcon> {
  UpdateState _state = UpdateState.checking;
  UpdateInfo? _updateInfo;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    setState(() => _state = UpdateState.checking);

    try {
      final updateService = UpdateService();
      final info = await updateService.checkForUpdates();

      if (mounted) {
        if (info.isAvailable) {
          setState(() {
            _state = UpdateState.updateAvailable;
            _updateInfo = info;
          });
          _showUpdateDialog(info);
        } else {
          setState(() {
            _state = UpdateState.upToDate;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = UpdateState.error);
      }
    }
  }

  void _showUpdateDialog(UpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(updateInfo: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          if (_state == UpdateState.updateAvailable && _updateInfo != null) {
            _showUpdateDialog(_updateInfo!);
          } else if (_state == UpdateState.upToDate ||
              _state == UpdateState.error) {
            _checkForUpdates();
          }
        },
        child: _buildIcon(),
      ),
    );
  }

  Widget _buildIcon() {
    switch (_state) {
      case UpdateState.checking:
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CupertinoActivityIndicator(
              color: AppTheme.primaryPurple,
              radius: 10,
            ),
          ),
        );
      case UpdateState.upToDate:
        return const Center(
          child: Tooltip(
            message: 'App is up to date',
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedCheckmarkBadge01,
              color: Colors.green,
              size: 24,
            ),
          ),
        );
      case UpdateState.updateAvailable:
        return Center(
          child: Tooltip(
            message: 'Update available',
            child: Stack(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedCloudDownload,
                  color: AppTheme.primaryPurple,
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
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
          ),
        );
      case UpdateState.error:
        return const Center(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedAlert02,
            color: Colors.grey,
            size: 24,
          ),
        );
    }
  }
}
