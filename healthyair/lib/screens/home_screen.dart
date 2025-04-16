import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/air_quality_provider.dart';
import '../widgets/pollutant_card.dart';
import '../widgets/aqi_summary_widget.dart';
import '../models/air_quality_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure we have data
    final provider = Provider.of<AirQualityProvider>(context, listen: false);
    if (provider.airQualityData == null) {
      provider.initializeLocationAndData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthy Air - Air Quality Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AirQualityProvider>(context, listen: false).refreshData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<AirQualityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(provider.error ?? 'Unknown error'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (provider.airQualityData == null) {
            return const Center(child: Text('No data available'));
          }
          
          final airQualityData = provider.airQualityData!;
          
          return RefreshIndicator(
            onRefresh: provider.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City and update time information
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              provider.currentCity,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Last updated: ${airQualityData.time}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // AQI summary widget
                    AQISummaryWidget(airQualityData: airQualityData),
                    
                    const SizedBox(height: 32),
                    
                    // Section title for pollutants
                    Text(
                      'Key Pollutants',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Pollutant cards
                    if (airQualityData.pollutants.isEmpty)
                      const Center(
                        child: Text('No pollutant data available'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: airQualityData.pollutants.length,
                        itemBuilder: (context, index) {
                          final pollutantKey = airQualityData.pollutants.keys.elementAt(index);
                          final pollutant = airQualityData.pollutants[pollutantKey]!;
                          
                          // Check if this is the dominant pollutant
                          bool isDominant = pollutantKey == airQualityData.dominantPollutant;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: PollutantCard(
                              pollutant: pollutant,
                              isDominant: isDominant,
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Navigation to detailed information
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.info_outline),
                        label: const Text('View Pollutant Health Info'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/pollutant-details');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}