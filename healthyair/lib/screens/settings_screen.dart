// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/air_quality_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedUnit = 'AQI';
  String _updateFrequency = '1 hour';
  List<String> _favoriteLocations = [];
  TextEditingController _cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedUnit = prefs.getString('selected_unit') ?? 'AQI';
      _updateFrequency = prefs.getString('update_frequency') ?? '1 hour';
      _favoriteLocations = prefs.getStringList('favorite_locations') ?? [];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setString('selected_unit', _selectedUnit);
    await prefs.setString('update_frequency', _updateFrequency);
    await prefs.setStringList('favorite_locations', _favoriteLocations);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置已保存')),
    );
  }

  void _addFavoriteLocation() {
    if (_formKey.currentState!.validate()) {
      final city = _cityController.text.trim();
      setState(() {
        if (!_favoriteLocations.contains(city)) {
          _favoriteLocations.add(city);
          _cityController.clear();
        }
      });
      _saveSettings();
    }
  }

  void _removeFavoriteLocation(String location) {
    setState(() {
      _favoriteLocations.remove(location);
    });
    _saveSettings();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: '保存设置',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('常规设置'),
            const SizedBox(height: 16),
            
            // 通知设置
            Card(
              child: SwitchListTile(
                title: const Text('启用通知'),
                subtitle: const Text('当空气质量发生显著变化时收到通知'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 单位设置
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '显示单位',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedUnit,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedUnit = newValue;
                          });
                        }
                      },
                      items: <String>['AQI', 'CAQI', 'μg/m³']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 更新频率设置
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '数据更新频率',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _updateFrequency,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _updateFrequency = newValue;
                          });
                        }
                      },
                      items: <String>['30 分钟', '1 小时', '3 小时', '6 小时']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('收藏的位置'),
            const SizedBox(height: 16),
            
            // 添加收藏位置
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: '城市名称',
                        hintText: '输入城市名称',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入城市名称';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      try {
                        final provider = Provider.of<AirQualityProvider>(context, listen: false);
                        await provider.fetchAirQualityForCity(_cityController.text.trim());
                        // If we reach here, the city is valid
                        _addFavoriteLocation();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('无法找到城市: ${e.toString()}')),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('添加'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 收藏位置列表
            if (_favoriteLocations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('暂无收藏的位置'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _favoriteLocations.length,
                itemBuilder: (context, index) {
                  final location = _favoriteLocations[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(location),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                final provider = Provider.of<AirQualityProvider>(context, listen: false);
                                await provider.fetchAirQualityForCity(location);
                                Navigator.pop(context); // Go back to home screen after fetching
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('更新失败: ${e.toString()}')),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFavoriteLocation(location),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('关于应用'),
            const SizedBox(height: 16),
            
            // 关于和许可证
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('关于 Healthy Air'),
                    onTap: () {
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('隐私政策'),
                    onTap: () {
                      // Show privacy policy
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('隐私政策'),
                          content: const SingleChildScrollView(
                            child: Text(
                              '我们非常重视您的隐私。应用需要位置权限以提供当前位置的空气质量数据。所有位置数据仅用于获取当地的空气质量信息，不会用于其他目的或与第三方共享。',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('关闭'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text('分享应用'),
                    onTap: () {
                      // Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('分享功能即将推出!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Clear all preferences (reset to default)
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('重置设置'),
                      content: const Text('确定要将所有设置重置为默认值吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.pop(context);
                            _loadSettings(); // Reload default settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('所有设置已重置')),
                            );
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.red[900],
                ),
                child: const Text('重置所有设置'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}