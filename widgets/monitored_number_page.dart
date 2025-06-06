// File: lib/widgets/monitored_number_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_login_demo/app_styles.dart'; // Replace your_app_name

class MonitoredNumberCard extends StatelessWidget {
  final String displayName;
  final String phoneNumberJid; // Full JID
  final bool isOnline;

  const MonitoredNumberCard({
    super.key,
    required this.displayName,
    required this.phoneNumberJid,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Simple way to try and extract number part from JID for display if needed
    final String numberPart = phoneNumberJid.split('@').first;

    return Card(
      elevation: AppStyles.isWeb ? AppStyles.cardElevationWeb / 2 : (theme.brightness == Brightness.light ? AppStyles.cardElevationMobileLight + 1 : AppStyles.cardElevationMobileDark +1),
      margin: EdgeInsets.symmetric(vertical: AppStyles.smallSpacing / 1.5, horizontal: AppStyles.pageHorizontalPadding / 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppStyles.defaultSpacing * 0.75,
          vertical: AppStyles.smallSpacing * 0.5,
        ),
        leading: CircleAvatar(
          backgroundColor: isOnline ? Colors.green.shade400 : Colors.grey.shade400,
          child: Icon(
            isOnline ? Icons.person_outline_rounded : Icons.person_off_outlined,
            color: Colors.white,
            size: AppStyles.mediumIconSize * 0.9,
          ),
        ),
        title: Text(
          displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: AppStyles.listTileTitleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          numberPart, // Display the number part of JID
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: AppStyles.listTileSubtitleSize * 0.9,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: AppStyles.smallSpacing, vertical: AppStyles.smallSpacing / 2),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
          ),
          child: Text(
            isOnline ? 'Online' : 'Offline', // TODO: Localize
            style: TextStyle(
              color: isOnline ? Colors.green.shade700 : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: AppStyles.smallTextSize * 0.95,
            ),
          ),
        ),
        onTap: () {
          // TODO: Implement action on tap, e.g., view details or history
          print('Tapped on $displayName ($phoneNumberJid)');
        },
      ),
    );
  }
}
