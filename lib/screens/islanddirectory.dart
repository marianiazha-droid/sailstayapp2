import 'package:flutter/material.dart';
import 'package:sailstayapp2/screens/islandlist.dart';

class IslandDirectoryScreen extends StatefulWidget {
  const IslandDirectoryScreen({super.key});

  @override
  State<IslandDirectoryScreen> createState() => _IslandDirectoryScreenState();
}

class _IslandDirectoryScreenState extends State<IslandDirectoryScreen> {
  String selectedState = 'Select State';
  RangeValues priceRange = const RangeValues(0, 250);
  final Set<String> selectedActivities = {};

  final List<String> states = [
    'Sabah',
    'Sarawak',
    'Terengganu',
    'Kedah',
    'Penang',
    'Pahang',
    'Johor',
  ];

  final List<String> activities = [
    'Snorkeling & Scuba Diving',
    'Sunset Cruise',
    'Jet Skiing',
    'Kayaking'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.asset(
              'assets/images/islanddirectory.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 180),

                // White Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What are you looking for?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // State Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedState,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'Select State',
                            child: Text('Select State'),
                          ),
                          ...states.map(
                            (state) => DropdownMenuItem(
                              value: state,
                              child: Text(state),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedState = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // Price Range
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price Range',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            RangeSlider(
                              values: priceRange,
                              min: 0,
                              max: 500,
                              divisions: 10,
                              activeColor: Colors.orange,
                              labels: RangeLabels(
                                'RM ${priceRange.start.round()}',
                                'RM ${priceRange.end.round()}',
                              ),
                              onChanged: (values) {
                                setState(() {
                                  priceRange = values;
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('RM ${priceRange.start.round()}'),
                                Text('RM ${priceRange.end.round()}'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Activity Type
                      const Text(
                        'Activity Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 10,
                        children: activities.map((activity) {
                          final isSelected =
                              selectedActivities.contains(activity);
                          return ChoiceChip(
                            label: Text(activity),
                            selected: isSelected,
                            selectedColor: Colors.orange.shade200,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedActivities.add(activity);
                                } else {
                                  selectedActivities.remove(activity);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 30),

                    SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1B0C5A), // button background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      foregroundColor: Colors.white, // text color when enabled
      disabledForegroundColor: Colors.grey.shade400, // text color when disabled
      disabledBackgroundColor: Colors.grey.shade600, // optional: button bg when disabled
    ),
    onPressed: selectedActivities.isEmpty
        ? null
        : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IslandListScreen(
                  selectedState: selectedState,
                  maxPrice: priceRange.end,
                  selectedActivities: selectedActivities.toList(),
                ),
              ),
            );
          },
    child: const Text(
      'Explore',
      style: TextStyle(fontSize: 18),
    ),
  ),
),
 

                    ],
                  ),
                ),
              ],
            ),
          ),

          // Header Text
          Positioned(
            left: 20,
            top: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Island Directory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Lets go island-hopping!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
