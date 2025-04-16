// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';
import '../providers/air_quality_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../widgets/history_item_card.dart';
import '../widgets/feedback_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _feedbackController = TextEditingController();
  
  late TabController _tabController;
  
  // User data
  String _userName = '';
  String _userEmail = '';
  
  // Form data
  bool _useCurrentLocation = true;
  int _notificationThreshold = 100;
  bool _enableNotifications = true;
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  
  // User history
  List<Map<String, dynamic>> _searchHistory = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _loadUserPreferences();
    
    // Initialize city controller with current location if authenticated
    if (_auth.currentUser != null) {
      final provider = Provider.of<AirQualityProvider>(context, listen: false);
      _cityController.text = provider.currentCity;
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _cityController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }
  
  // Load user data if authenticated
  Future<void> _loadUserData() async {
    if (_auth.currentUser != null) {
      setState(() {
        _userName = _auth.currentUser?.displayName ?? 'User';
        _userEmail = _auth.currentUser?.email ?? '';
      });
      
      // Load search history
      await _loadSearchHistory();
    }
  }
  
  // Load user preferences from Firestore
  Future<void> _loadUserPreferences() async {
    if (_auth.currentUser != null) {
      setState(() => _isLoading = true);
      
      try {
        final doc = await _firestore
            .collection('user_preferences')
            .doc(_auth.currentUser!.uid)
            .get();
            
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _useCurrentLocation = data['useCurrentLocation'] ?? true;
            _notificationThreshold = data['notificationThreshold'] ?? 100;
            _enableNotifications = data['enableNotifications'] ?? true;
            
            if (!_useCurrentLocation && data['preferredCity'] != null) {
              _cityController.text = data['preferredCity'];
            }
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading preferences: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Load search history from Firestore
  Future<void> _loadSearchHistory() async {
    if (_auth.currentUser != null) {
      setState(() => _isLoadingHistory = true);
      
      try {
        final snapshot = await _firestore
            .collection('search_history')
            .doc(_auth.currentUser!.uid)
            .collection('searches')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();
            
        setState(() {
          _searchHistory = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      } finally {
        setState(() => _isLoadingHistory = false);
      }
    }
  }
  
  // Save user preferences to Firestore
  Future<void> _saveUserPreferences() async {
    if (_auth.currentUser != null) {
      setState(() => _isLoading = true);
      
      try {
        await _firestore
            .collection('user_preferences')
            .doc(_auth.currentUser!.uid)
            .set({
              'useCurrentLocation': _useCurrentLocation,
              'preferredCity': _cityController.text,
              'notificationThreshold': _notificationThreshold,
              'enableNotifications': _enableNotifications,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully')),
        );
        
        // Update provider if needed
        if (!_useCurrentLocation && _cityController.text.isNotEmpty) {
          final provider = Provider.of<AirQualityProvider>(context, listen: false);
          provider.setCity(_cityController.text);
          await provider.refreshData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Get current location and update city field
  Future<void> _useCurrentLocationAction() async {
    setState(() => _isLoading = true);
    
    try {
      final position = await _locationService.getCurrentPosition();
      final cityName = await _locationService.getCityFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      setState(() {
        _cityController.text = cityName;
        _useCurrentLocation = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Handle user authentication
  Future<void> _handleAuth() async {
    if (_auth.currentUser != null) {
      // Log out
      await _auth.signOut();
      setState(() {
        _userName = '';
        _userEmail = '';
        _searchHistory = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    } else {
      // Show login dialog
      _showLoginDialog();
    }
  }
  
  // Show login/signup dialog
  void _showLoginDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    
    bool isSignUp = false;
    bool isLoading = false;
    String errorMessage = '';
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isSignUp ? 'Sign Up' : 'Login'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSignUp) 
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    if (isSignUp) const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            isSignUp = !isSignUp;
                            errorMessage = '';
                          });
                        },
                        child: Text(
                          isSignUp ? 'Already have an account? Login' : 'Need an account? Sign Up',
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setDialogState(() {
                      isLoading = true;
                      errorMessage = '';
                    });
                    
                    try {
                      if (isSignUp) {
                        // Create new account
                        final userCredential = await _auth.createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        );
                        
                        // Update display name
                        await userCredential.user!.updateDisplayName(nameController.text.trim());
                        
                        // Create initial preferences document
                        await _firestore
                            .collection('user_preferences')
                            .doc(userCredential.user!.uid)
                            .set({
                              'useCurrentLocation': true,
                              'enableNotifications': true,
                              'notificationThreshold': 100,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            
                      } else {
                        // Login
                        await _auth.signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        );
                      }
                      
                      // Close dialog and refresh UI
                      Navigator.pop(context);
                      _loadUserData();
                      _loadUserPreferences();
                      
                    } catch (e) {
                      setDialogState(() {
                        errorMessage = e.toString();
                        isLoading = false;
                      });
                    }
                  },
                  child: Text(isSignUp ? 'Sign Up' : 'Login'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  // Submit feedback
  void _submitFeedback() {
    showDialog(
      context: context,
      builder: (context) => FeedbackDialog(
        onSubmit: (feedback) async {
          if (_auth.currentUser != null) {
            try {
              await _firestore.collection('feedback').add({
                'userId': _auth.currentUser!.uid,
                'userEmail': _auth.currentUser!.email,
                'feedback': feedback,
                'timestamp': FieldValue.serverTimestamp(),
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback submitted. Thank you!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error submitting feedback: $e')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to submit feedback')),
            );
          }
        },
      ),
    );
  }
  
  // Remove history item
  Future<void> _removeHistoryItem(String docId) async {
    if (_auth.currentUser != null) {
      try {
        await _firestore
            .collection('search_history')
            .doc(_auth.currentUser!.uid)
            .collection('searches')
            .doc(docId)
            .delete();
            
        // Refresh history
        await _loadSearchHistory();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History item removed')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Preferences'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Profile Tab
          _buildProfileTab(),
          
          // Preferences Tab
          _buildPreferencesTab(),
          
          // History Tab
          _buildHistoryTab(),
        ],
      ),
    );
  }
  
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User profile section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: _auth.currentUser != null
                        ? Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          )
                        : const Icon(Icons.person, size: 50, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  
                  // User info
                  _auth.currentUser != null
                      ? Column(
                          children: [
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Not logged in',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 24),
                  
                  // Login/Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleAuth,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _auth.currentUser != null ? 'Logout' : 'Login / Sign Up',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Help and feedback section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help'),
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Send Feedback'),
                  onTap: _submitFeedback,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // App version
          Center(
            child: Text(
              'Healthy Air v1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreferencesTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Login reminder
                  if (_auth.currentUser == null)
                    Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.amber),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Login Required',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Please login to save your preferences',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Location preferences
                  Text(
                    'Location Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Use current location toggle
                          SwitchListTile(
                            title: const Text('Use Current Location'),
                            subtitle: const Text('Automatically detect your location for air quality data'),
                            value: _useCurrentLocation,
                            onChanged: (value) {
                              setState(() {
                                _useCurrentLocation = value;
                                if (value) {
                                  _useCurrentLocationAction();
                                }
                              });
                            },
                          ),
                          
                          const Divider(),
                          
                          // Manual city selection
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Preferred City',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  hintText: 'Enter city name',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.my_location),
                                    onPressed: _useCurrentLocationAction,
                                  ),
                                ),
                                enabled: !_useCurrentLocation,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notification preferences
                  Text(
                    'Notification Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enable notifications toggle
                          SwitchListTile(
                            title: const Text('Enable Notifications'),
                            subtitle: const Text('Receive air quality alerts and updates'),
                            value: _enableNotifications,
                            onChanged: (value) {
                              setState(() {
                                _enableNotifications = value;
                              });
                            },
                          ),
                          
                          const Divider(),
                          
                          // AQI notification threshold
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AQI Alert Threshold',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Notify me when AQI exceeds:',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: _notificationThreshold.toDouble(),
                                      min: 50,
                                      max: 200,
                                      divisions: 15,
                                      label: _notificationThreshold.toString(),
                                      onChanged: _enableNotifications
                                          ? (value) {
                                              setState(() {
                                                _notificationThreshold = value.round();
                                              });
                                            }
                                          : null,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _notificationThreshold.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _auth.currentUser != null
                          ? _saveUserPreferences
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please login to save preferences')),
                              );
                              _tabController.animateTo(0); // Go to profile tab
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Save Preferences',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
  
  Widget _buildHistoryTab() {
    return _auth.currentUser == null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Login Required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please login to view your search history',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _tabController.animateTo(0); // Go to profile tab
                  },
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          )
        : _isLoadingHistory
            ? const Center(child: CircularProgressIndicator())
            : _searchHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No Search History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your search history will appear here',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _searchHistory.length,
                    itemBuilder: (context, index) {
                      final item = _searchHistory[index];
                      return Dismissible(
                        key: Key(item['id'] ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          _removeHistoryItem(item['id']);
                        },
                        child: HistoryItemCard(
                          cityName: item['city'] ?? 'Unknown',
                          aqi: item['aqi']?.toString() ?? 'N/A',
                          time: item['timestamp'] != null
                              ? (item['timestamp'] as Timestamp).toDate().toString()
                              : 'Unknown time',
                          onTap: () {
                            final provider = Provider.of<AirQualityProvider>(context, listen: false);
                            provider.setCity(item['city']);
                            provider.refreshData();
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                        ),
                      );
                    },
                  );
  }
}