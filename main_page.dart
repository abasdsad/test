import 'package:flutter/material.dart';
import 'package:flutter_login_demo/app_styles.dart';
import 'package:provider/provider.dart';
import 'app_styles.dart'; // Replace your_app_name
import 'l10n/app_localizations.dart'; // Replace your_app_name
import 'package:flutter_login_demo/tabs/numbers_tab.dart'; // Replace your_app_name
import 'package:flutter_login_demo/tabs/settings_tab.dart'; // Replace your_app_name
import 'package:flutter_login_demo/tabs/shop_tab.dart'; // Replace your_app_name
import 'package:flutter_login_demo/theme_provider.dart'; // Replace your_app_name
// Import other necessary files

class MainPage extends StatefulWidget {
  // If you need to pass the logged-in user's phone number
  final String? ownerPhoneNumber;

  const MainPage({super.key, this.ownerPhoneNumber});

  static const String routeName = '/main';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      NumbersTab(ownerPhoneNumber: widget.ownerPhoneNumber), // Pass ownerPhoneNumber
      const ShopTab(),
      const SettingsTab(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appLocalizations = AppLocalizations.of(context)!;

    // Determine active and inactive colors based on theme
    Color activeColor = themeProvider.themeMode == ThemeMode.light
        ? Theme.of(context).colorScheme.primary // whatsappGreen for light
        : Theme.of(context).colorScheme.secondary; // A vibrant color for dark

    Color inactiveColor = themeProvider.themeMode == ThemeMode.light
        ? Colors.grey[600]!
        : Colors.grey[400]!;


    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt_rounded),
            label: appLocalizations.bottomNavNumbers,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag_rounded),
            label: appLocalizations.bottomNavShop,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: appLocalizations.bottomNavSettings,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: activeColor,
        unselectedItemColor: inactiveColor,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).cardColor, // Or specific color
        type: BottomNavigationBarType.fixed, // Ensures all labels are visible
        selectedFontSize: AppStyles.smallTextSize * 1.1, // Slightly larger for selected
        unselectedFontSize: AppStyles.smallTextSize,
        elevation: 8.0,
      ),
    );
  }
}