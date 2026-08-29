import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MeowCatApp());
}

class MeowCatApp extends StatelessWidget {
  const MeowCatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '喵喵召唤术',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PlayerPage(),
    );
  }
}

class SoundItem {
  final String name;
  final String label;
  final String emoji;
  final String description;

  const SoundItem({
    required this.name,
    required this.label,
    required this.emoji,
    required this.description,
  });
}

class SoundCategory {
  final String name;
  final String emoji;
  final List<SoundItem> sounds;

  const SoundCategory({
    required this.name,
    required this.emoji,
    required this.sounds,
  });
}

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  int _currentIndex = 0;
  double _volume = 0.8;
  bool _isLooping = true;
  Timer? _sleepTimer;
  int? _sleepMinutes;
  bool _showSleepSelector = false;
  int _currentCategoryIndex = 0;

  final List<SoundCategory> _categories = const [
    // 全部合集
    SoundCategory(
      name: '全部合集',
      emoji: '🎵',
      sounds: [
        SoundItem(
          name: 'cat_collection_loop.mp3',
          label: '循环合集',
          emoji: '🔄',
          description: '全部片段循环播放',
        ),
        SoundItem(
          name: 'cat_full_4min.mp3',
          label: '完整4分钟',
          emoji: '⏱️',
          description: '原始完整版',
        ),
      ],
    ),
    // 召唤类
    SoundCategory(
      name: '召唤类',
      emoji: '📢',
      sounds: [
        SoundItem(
          name: '01_call.mp3',
          label: '唤崽',
          emoji: '🐱',
          description: '00:00 - 00:10',
        ),
        SoundItem(
          name: '07_where.mp3',
          label: '你在哪里',
          emoji: '🔍',
          description: '00:48 - 00:54',
        ),
      ],
    ),
    // 食物类
    SoundCategory(
      name: '食物类',
      emoji: '🍖',
      sounds: [
        SoundItem(
          name: '02_food.mp3',
          label: '快来吃饭吧',
          emoji: '🍖',
          description: '00:10 - 00:17',
        ),
      ],
    ),
    // 亲近类
    SoundCategory(
      name: '亲近类',
      emoji: '💕',
      sounds: [
        SoundItem(
          name: '03_贴贴.mp3',
          label: '贴贴',
          emoji: '💕',
          description: '00:17 - 00:28',
        ),
        SoundItem(
          name: '10_goodboy.mp3',
          label: '乖宝',
          emoji: '⭐',
          description: '01:10 - 01:17',
        ),
        SoundItem(
          name: '11_love.mp3',
          label: '我爱你',
          emoji: '❤️',
          description: '01:17 - 01:23',
        ),
        SoundItem(
          name: '12_hug.mp3',
          label: '快抱紧我',
          emoji: '🤗',
          description: '01:23 - 01:30',
        ),
      ],
    ),
    // 玩耍类
    SoundCategory(
      name: '玩耍类',
      emoji: '🎾',
      sounds: [
        SoundItem(
          name: '04_play.mp3',
          label: '跟我玩',
          emoji: '🎾',
          description: '00:28 - 00:35',
        ),
        SoundItem(
          name: '06_play2.mp3',
          label: '玩～',
          emoji: '🎮',
          description: '00:40 - 00:48',
        ),
        SoundItem(
          name: '09_play3.mp3',
          label: '玩～',
          emoji: '🎯',
          description: '01:00 - 01:10',
        ),
        SoundItem(
          name: '14_play4.mp3',
          label: '跟我玩',
          emoji: '🎪',
          description: '01:35 - 01:40',
        ),
      ],
    ),
    // 呼唤类
    SoundCategory(
      name: '呼唤类',
      emoji: '👋',
      sounds: [
        SoundItem(
          name: '05_here.mp3',
          label: '快来我这里',
          emoji: '👋',
          description: '00:35 - 00:40',
        ),
        SoundItem(
          name: '08_come.mp3',
          label: '快来～',
          emoji: '💨',
          description: '00:54 - 01:00',
        ),
        SoundItem(
          name: '13_comehere.mp3',
          label: '你过来啊',
          emoji: '😏',
          description: '01:30 - 01:35',
        ),
      ],
    ),
    // 撒娇类
    SoundCategory(
      name: '撒娇类',
      emoji: '😻',
      sounds: [
        SoundItem(
          name: '15_cute.mp3',
          label: '撒娇',
          emoji: '😻',
          description: '01:40 - 01:45',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _loadSound(_currentCategoryIndex, _currentIndex);
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
      if (state.processingState == ProcessingState.completed) {
        if (_isLooping) {
          _player.seek(Duration.zero);
          _player.play();
        }
      }
    });
  }

  Future<void> _loadSound(int catIndex, int soundIndex) async {
    final sound = _categories[catIndex].sounds[soundIndex];
    await _player.setAsset('assets/sounds/${sound.name}');
    await _player.setVolume(_volume);
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void _nextSound() async {
    final currentSounds = _categories[_currentCategoryIndex].sounds;
    if (_currentIndex < currentSounds.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    await _loadSound(_currentCategoryIndex, _currentIndex);
    if (_isPlaying) {
      await _player.play();
    }
    setState(() {});
  }

  void _prevSound() async {
    final currentSounds = _categories[_currentCategoryIndex].sounds;
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = currentSounds.length - 1;
    }
    await _loadSound(_currentCategoryIndex, _currentIndex);
    if (_isPlaying) {
      await _player.play();
    }
    setState(() {});
  }

  void _selectCategory(int index) async {
    _currentCategoryIndex = index;
    _currentIndex = 0;
    await _loadSound(_currentCategoryIndex, _currentIndex);
    setState(() {});
    if (_isPlaying) {
      await _player.play();
    }
  }

  void _selectSound(int index) async {
    _currentIndex = index;
    await _loadSound(_currentCategoryIndex, _currentIndex);
    setState(() {});
    if (_isPlaying) {
      await _player.play();
    }
  }

  void _setVolume(double value) async {
    _volume = value;
    await _player.setVolume(_volume);
    setState(() {});
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
    });
  }

  void _setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    setState(() {
      _sleepMinutes = minutes;
      _showSleepSelector = false;
    });
    if (minutes > 0) {
      _sleepTimer = Timer(Duration(minutes: minutes), () async {
        await _player.pause();
        if (mounted) {
          setState(() {
            _sleepMinutes = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎵 播放已停止'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    setState(() {
      _sleepMinutes = null;
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = _categories[_currentCategoryIndex];
    final currentSound = currentCategory.sounds[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐱 喵喵召唤术'),
        centerTitle: true,
        backgroundColor: Colors.orange.shade100,
      ),
      body: Column(
        children: [
          // 分类选择
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = index == _currentCategoryIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('${cat.emoji} ${cat.name}'),
                    selected: isSelected,
                    onSelected: (_) => _selectCategory(index),
                    selectedColor: Colors.orange.shade200,
                  ),
                );
              },
            ),
          ),
          // 主播放区域
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 猫猫图标
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Center(
                      child: Text(
                        currentSound.emoji,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 当前分类
                  Text(
                    currentCategory.emoji + ' ' + currentCategory.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 当前音频名称
                  Text(
                    currentSound.label,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentSound.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // 进度条
                  StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = _player.duration ?? Duration.zero;
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                            ),
                            child: Slider(
                              value: position.inMilliseconds.toDouble(),
                              min: 0,
                              max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                              onChanged: (value) {
                                _player.seek(Duration(milliseconds: value.toInt()));
                              },
                              activeColor: Colors.orange,
                              inactiveColor: Colors.orange.shade100,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 控制按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 40,
                        onPressed: _prevSound,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          iconSize: 48,
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 40,
                        onPressed: _nextSound,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 音量控制
                  Row(
                    children: [
                      const Icon(Icons.volume_down, size: 20),
                      Expanded(
                        child: Slider(
                          value: _volume,
                          onChanged: _setVolume,
                          activeColor: Colors.orange,
                          inactiveColor: Colors.orange.shade100,
                        ),
                      ),
                      const Icon(Icons.volume_up, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 音频列表
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 音频列表
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: currentCategory.sounds.length,
                    itemBuilder: (context, index) {
                      final sound = currentCategory.sounds[index];
                      final isSelected = index == _currentIndex;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => _selectSound(index),
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange.shade100 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.orange : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  sound.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sound.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.orange : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // 功能按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeatureButton(
                      icon: _isLooping ? Icons.repeat_one : Icons.repeat,
                      label: _isLooping ? '🔄 循环' : '➡️ 单次',
                      isActive: _isLooping,
                      onTap: _toggleLoop,
                    ),
                    _buildFeatureButton(
                      icon: Icons.timer,
                      label: _sleepMinutes != null
                          ? '⏱️ ${_sleepMinutes}分钟后停'
                          : '⏱️ 定时',
                      isActive: _sleepMinutes != null,
                      onTap: () {
                        setState(() {
                          _showSleepSelector = !_showSleepSelector;
                        });
                      },
                    ),
                  ],
                ),
                // 定时选择器
                if (_showSleepSelector) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildSleepChip(15),
                      _buildSleepChip(30),
                      _buildSleepChip(60),
                      _buildSleepChip(120),
                      if (_sleepMinutes != null)
                        ActionChip(
                          label: const Text('取消'),
                          onPressed: _cancelSleepTimer,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.orange : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isActive ? Colors.orange : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChip(int minutes) {
    return ChoiceChip(
      label: Text('$minutes分钟'),
      selected: _sleepMinutes == minutes,
      onSelected: (_) => _setSleepTimer(minutes),
      selectedColor: Colors.orange.shade200,
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
