import 'package:flutter/material.dart';
import 'package:flutter_login_demo/add_number_page.dart'; // Replace your_app_name
import 'package:flutter_login_demo/app_styles.dart'; // Replace your_app_name
import 'package:flutter_login_demo/l10n/app_localizations.dart'; // Replace your_app_name

import 'package:flutter_login_demo/widgets/monitored_number_page.dart';

 // Replace your_app_name
// Import ApiService and a model for MonitoredNumber if you create one

// Dummy data for now
class MonitoredNumber {
  final String id;
  final String displayNumber; // e.g., "Work Phone" or the number itself
  final String jid;
  bool isOnline; // This will be updated from backend

  MonitoredNumber({
    required this.id,
    required this.displayNumber,
    required this.jid,
    this.isOnline = false,
  });
}

class NumbersTab extends StatefulWidget {
  final String? ownerPhoneNumber;
  const NumbersTab({super.key, this.ownerPhoneNumber});

  @override
  State<NumbersTab> createState() => _NumbersTabState();
}

class _NumbersTabState extends State<NumbersTab> {
  // TODO: Replace with actual data fetched from API
  List<MonitoredNumber> _monitoredNumbers = [
    MonitoredNumber(id: '1', displayNumber: 'Alice (Test)', jid: '1234567890@s.whatsapp.net', isOnline: true),
    MonitoredNumber(id: '2', displayNumber: 'Bob (Offline)', jid: '0987654321@s.whatsapp.net', isOnline: false),
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // TODO: Fetch monitored numbers from API if widget.ownerPhoneNumber is available
    // _fetchMonitoredNumbers();
    print("NumbersTab initialized with ownerPhoneNumber: ${widget.ownerPhoneNumber}");
  }

  // Future<void> _fetchMonitoredNumbers() async {
  //   if (widget.ownerPhoneNumber == null) return;
  //   setState(() { _isLoading = true; });
  //   // final apiService = ApiService();
  //   // await apiService.sendRequest<List<MonitoredNumber>>(
  //   //   endpoint: '/monitored-numbers/${widget.ownerPhoneNumber}',
  //   //   method: HttpMethod.get,
  //   //   onSuccess: (data) {
  //   //     setState(() {
  //   //       _monitoredNumbers = data;
  //   //       _isLoading = false;
  //   //     });
  //   //   },
  //   //   onError: (message, statusCode) {
  //   //     setState(() { _isLoading = false; });
  //   //     ScaffoldMessenger.of(context).showSnackBar(
  //   //       SnackBar(content: Text('Error fetching numbers: $message')),
  //   //     );
  //   //   },
  //   //   fromJson: (jsonList) => (jsonList as List).map((json) => MonitoredNumber.fromJson(json)).toList(), // You'll need a fromJson factory in MonitoredNumber
  //   // );
  // }


  void _navigateToAddNumberPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNumberPage(ownerPhoneNumber: widget.ownerPhoneNumber),
      ),
    ).then((value) {
      // If a number was added, refresh the list
      if (value == true) {
        // _fetchMonitoredNumbers();
        // For now, just a print statement
        print("Returned from AddNumberPage, potentially refresh list.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.monitoredNumbersTitle,
          style: TextStyle(fontSize: AppStyles.appBarTitleSize),
        ),
        // Potentially add actions like refresh here
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _monitoredNumbers.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppStyles.defaultSpacing),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_off_outlined, size: AppStyles.largeIconSize * 0.8, color: theme.iconTheme.color?.withOpacity(0.5)),
                        SizedBox(height: AppStyles.defaultSpacing),
                        Text(
                          appLocalizations.noMonitoredNumbers,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(fontSize: AppStyles.bodyTextSize),
                        ),
                         SizedBox(height: AppStyles.smallSpacing),
                        Text(
                          appLocalizations.noMonitoredNumbersHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: AppStyles.smallTextSize),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(AppStyles.pageHorizontalPadding / 2),
                  itemCount: _monitoredNumbers.length,
                  itemBuilder: (context, index) {
                    final number = _monitoredNumbers[index];
                    return MonitoredNumberCard(
                      displayName: number.displayNumber,
                      isOnline: number.isOnline, // This will be dynamic later
                      phoneNumberJid: number.jid,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddNumberPage,
        label: Text(appLocalizations.addNumberButton),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
      ),
    );
  }
}
