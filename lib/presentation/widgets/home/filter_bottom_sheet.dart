import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'filter_section.dart';

void showFilterBottomSheet(
    BuildContext context, {
      required Function(String, List<String>) onApplyFilters,
    }) {
  final isDarkMode = AppTheme.isDarkMode(context);
  final primaryColor = const Color(0xFF4B6EFF);

  String titleFilter = '';
  List<String> selectedTimeFilters = [];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            // Use a fraction of available height and make it scrollable
            height: MediaQuery.of(context).size.height * 0.7,
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
                      Row(
                        children: [
                          // Reset button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                titleFilter = '';
                                selectedTimeFilters = [];
                              });
                            },
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                              ),
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
                    ],
                  ),
                ),

                Divider(
                  color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                ),

                // Make the content scrollable to avoid overflow
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter by Title
                        FilterSection(
                          title: 'Filter by Title',
                          icon: Icons.title,
                          primaryColor: primaryColor,
                          isDarkMode: isDarkMode,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  titleFilter = value;
                                });
                              },
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

                        // Filter by Start Time - modified to use rows
                        FilterSection(
                          title: 'Filter by Start Time',
                          icon: Icons.access_time,
                          primaryColor: primaryColor,
                          isDarkMode: isDarkMode,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                // First row: Morning and Afternoon
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTimeFilterOption(
                                        isDarkMode,
                                        'Morning',
                                        Icons.wb_sunny,
                                        selectedTimeFilters.contains('Morning'),
                                            () {
                                          setState(() {
                                            if (selectedTimeFilters.contains('Morning')) {
                                              selectedTimeFilters.remove('Morning');
                                            } else {
                                              selectedTimeFilters.add('Morning');
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildTimeFilterOption(
                                        isDarkMode,
                                        'Afternoon',
                                        Icons.wb_cloudy,
                                        selectedTimeFilters.contains('Afternoon'),
                                            () {
                                          setState(() {
                                            if (selectedTimeFilters.contains('Afternoon')) {
                                              selectedTimeFilters.remove('Afternoon');
                                            } else {
                                              selectedTimeFilters.add('Afternoon');
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Second row: Evening and Night
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTimeFilterOption(
                                        isDarkMode,
                                        'Evening',
                                        Icons.wb_twilight,
                                        selectedTimeFilters.contains('Evening'),
                                            () {
                                          setState(() {
                                            if (selectedTimeFilters.contains('Evening')) {
                                              selectedTimeFilters.remove('Evening');
                                            } else {
                                              selectedTimeFilters.add('Evening');
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildTimeFilterOption(
                                        isDarkMode,
                                        'Night',
                                        Icons.nights_stay,
                                        selectedTimeFilters.contains('Night'),
                                            () {
                                          setState(() {
                                            if (selectedTimeFilters.contains('Night')) {
                                              selectedTimeFilters.remove('Night');
                                            } else {
                                              selectedTimeFilters.add('Night');
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Apply filters button - keep it outside the scrollable area
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: _buildApplyButton(
                        isDarkMode,
                        primaryColor,
                            () {
                          // Apply the filters and close the bottom sheet
                          onApplyFilters(titleFilter, selectedTimeFilters);
                          Navigator.pop(context);
                        }
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildTimeFilterOption(
    bool isDarkMode,
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    ) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF4B6EFF).withOpacity(isDarkMode ? 0.2 : 0.1)
            : isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: const Color(0xFF4B6EFF), width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? const Color(0xFF4B6EFF)
                : isDarkMode ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF4B6EFF)
                  : isDarkMode ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildApplyButton(bool isDarkMode, Color primaryColor, VoidCallback onTap) {
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
        onTap: onTap,
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