import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'filter_section.dart';

void showFilterBottomSheet(BuildContext context) {
  final isDarkMode = AppTheme.isDarkMode(context);
  final primaryColor = const Color(0xFF4B6EFF);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Habits',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Divider(
                  color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                ),

                // Filter by Title
                FilterSection(
                  title: 'Filter by Title',
                  icon: Icons.title,
                  primaryColor: primaryColor,
                  isDarkMode: isDarkMode,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search title...',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black38,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDarkMode ? Colors.white54 : Colors.black38,
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),

                // Filter by Start Time - simplified
                FilterSection(
                  title: 'Filter by Start Time',
                  icon: Icons.access_time,
                  primaryColor: primaryColor,
                  isDarkMode: isDarkMode,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTimeFilterOption(
                              isDarkMode,
                              'Morning',
                              Icons.wb_sunny
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTimeFilterOption(
                              isDarkMode,
                              'Evening',
                              Icons.wb_twilight
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Apply filters button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildApplyButton(isDarkMode, primaryColor),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildTimeFilterOption(bool isDarkMode, String title, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: isDarkMode
          ? Colors.white.withOpacity(0.05)
          : Colors.grey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    ),
  );
}

Widget _buildApplyButton(bool isDarkMode, Color primaryColor) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          primaryColor,
          const Color(0xFF8C61FF),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: const Center(
          child: Text(
            'Apply Filters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}