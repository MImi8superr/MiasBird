import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MiasBirdApp());
}

class MiasBirdApp extends StatefulWidget {
  const MiasBirdApp({super.key});

  @override
  State<MiasBirdApp> createState() => _MiasBirdAppState();
}

class _MiasBirdAppState extends State<MiasBirdApp> {
  int totalCoins = 0;
  final Set<String> unlockedSkins = {'gray'};
  String selectedSkinId = 'gray';
  AppScreen currentScreen = AppScreen.menu;
  GameMode selectedMode = GameMode.normal;

  final List<SkinData> skins = const [
    SkinData(
      id: 'gray',
      name: 'Grauer Vogel',
      color: Color(0xFF9E9E9E),
      price: 0,
    ),
    SkinData(
      id: 'red',
      name: 'Roter Vogel',
      color: Color(0xFFE53935),
      price: 20,
    ),
    SkinData(
      id: 'blue',
      name: 'Blauer Vogel',
      color: Color(0xFF1E88E5),
      price: 40,
    ),
    SkinData(
      id: 'gold',
      name: 'Goldener Vogel',
      color: Color(0xFFFFC107),
      price: 80,
    ),
    SkinData(
      id: 'rainbow',
      name: 'Rainbow Vogel',
      color: Colors.white,
      price: 120,
      isRainbow: true,
    ),
  ];

  SkinData get selectedSkin =>
      skins.firstWhere((skin) => skin.id == selectedSkinId);

  void addCoins(int amount) {
    setState(() {
      totalCoins += amount;
    });
  }

  void handleSkinTap(SkinData skin) {
    setState(() {
      if (unlockedSkins.contains(skin.id)) {
        selectedSkinId = skin.id;
        return;
      }

      if (totalCoins >= skin.price) {
        totalCoins -= skin.price;
        unlockedSkins.add(skin.id);
        selectedSkinId = skin.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screen;

    switch (currentScreen) {
      case AppScreen.menu:
        screen = MenuScreen(
          coins: totalCoins,
          selectedSkin: selectedSkin,
          currentMode: selectedMode,
          onModeChanged: (mode) {
            setState(() {
              selectedMode = mode;
            });
          },
          onPlay: () {
            setState(() {
              currentScreen = AppScreen.game;
            });
          },
          onShop: () {
            setState(() {
              currentScreen = AppScreen.shop;
            });
          },
        );
        break;

      case AppScreen.shop:
        screen = ShopScreen(
          coins: totalCoins,
          skins: skins,
          unlockedSkins: unlockedSkins,
          selectedSkinId: selectedSkinId,
          onBack: () {
            setState(() {
              currentScreen = AppScreen.menu;
            });
          },
          onSkinTap: handleSkinTap,
        );
        break;

      case AppScreen.game:
        screen = GameScreen(
          birdSkin: selectedSkin,
          onCoinsEarned: addCoins,
          speedMultiplier: selectedMode == GameMode.doubleSpeedDoubleCoins
              ? 2.0
              : 1.0,
          coinsPerPoint: selectedMode == GameMode.doubleSpeedDoubleCoins
              ? 2
              : 1,
          onBack: () {
            setState(() {
              currentScreen = AppScreen.menu;
            });
          },
        );
        break;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MiasBird',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C853),
          brightness: Brightness.dark,
        ),
      ),
      home: screen,
    );
  }
}

enum AppScreen { menu, shop, game }

enum GameMode { normal, doubleSpeedDoubleCoins }

class SkinData {
  final String id;
  final String name;
  final Color color;
  final int price;
  final bool isRainbow;

  const SkinData({
    required this.id,
    required this.name,
    required this.color,
    required this.price,
    this.isRainbow = false,
  });
}

class MenuScreen extends StatelessWidget {
  final int coins;
  final SkinData selectedSkin;
  final GameMode currentMode;
  final ValueChanged<GameMode> onModeChanged;
  final VoidCallback onPlay;
  final VoidCallback onShop;

  const MenuScreen({
    super.key,
    required this.coins,
    required this.selectedSkin,
    required this.currentMode,
    required this.onModeChanged,
    required this.onPlay,
    required this.onShop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B263B), Color(0xFF0D1B2A), Color(0xFF081018)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: CoinBadge(coins: coins),
                ),
                const Spacer(),
                const Text(
                  'MIASBIRD',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Flieg durch die Röhren, sammle Coins und kaufe neue Skins.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 28),
                BirdPreview(
                  color: selectedSkin.color,
                  size: 95,
                  isRainbow: selectedSkin.isRainbow,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aktiver Skin: ${selectedSkin.name}',
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<GameMode>(
                  value: currentMode,
                  dropdownColor: const Color(0xFF16212E),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Game Mode',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: GameMode.normal,
                      child: Text('Normal'),
                    ),
                    DropdownMenuItem(
                      value: GameMode.doubleSpeedDoubleCoins,
                      child: Text('Double Speed + Double Coins'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onModeChanged(value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  currentMode == GameMode.normal
                      ? 'Normale Geschwindigkeit, 1 Coin pro Punkt'
                      : 'Doppelte Röhren-Geschwindigkeit, 2 Coins pro Punkt',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Spielen', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onShop,
                    icon: const Icon(Icons.storefront_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Shop / Skins',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShopScreen extends StatelessWidget {
  final int coins;
  final List<SkinData> skins;
  final Set<String> unlockedSkins;
  final String selectedSkinId;
  final VoidCallback onBack;
  final ValueChanged<SkinData> onSkinTap;

  const ShopScreen({
    super.key,
    required this.coins,
    required this.skins,
    required this.unlockedSkins,
    required this.selectedSkinId,
    required this.onBack,
    required this.onSkinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop / Skins'),
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: CoinBadge(coins: coins)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: skins.length,
        itemBuilder: (context, index) {
          final skin = skins[index];
          final isUnlocked = unlockedSkins.contains(skin.id);
          final isSelected = selectedSkinId == skin.id;
          final canAfford = coins >= skin.price;

          String buttonText;
          if (isSelected) {
            buttonText = 'Ausgewählt';
          } else if (isUnlocked) {
            buttonText = 'Benutzen';
          } else {
            buttonText = '${skin.price} Coins';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  BirdPreview(
                    color: skin.color,
                    size: 62,
                    isRainbow: skin.isRainbow,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skin.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          skin.price == 0
                              ? 'Start-Skin'
                              : 'Preis: ${skin.price} Coins',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (isUnlocked || canAfford)
                        ? () => onSkinTap(skin)
                        : null,
                    child: Text(buttonText),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final SkinData birdSkin;
  final ValueChanged<int> onCoinsEarned;
  final double speedMultiplier;
  final int coinsPerPoint;
  final VoidCallback onBack;

  const GameScreen({
    super.key,
    required this.birdSkin,
    required this.onCoinsEarned,
    required this.speedMultiplier,
    required this.coinsPerPoint,
    required this.onBack,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random random = Random();

  Timer? timer;
  bool worldReady = false;
  bool gameStarted = false;
  bool gameOver = false;

  late Size screenSize;
  double birdY = 0;
  double velocity = 0;
  int score = 0;

  final double birdX = 90;
  final double birdSize = 42;
  final double pipeWidth = 78;

  final double gapHeight = 180;
  final double pipeSpacing = 430;
  final double gravity = 1100;
  final double jumpStrength = -390;
  final double pipeSpeed = 190;

  final List<PipePair> pipes = [];

  double get birdAngle {
    if (velocity < 0) {
      return -0.18;
    }
    return (velocity / 500).clamp(0.0, 0.85);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!worldReady) {
      initializeWorld(MediaQuery.of(context).size);
    }
  }

  void initializeWorld(Size size) {
    screenSize = size;
    birdY = size.height * 0.35;
    velocity = 0;
    score = 0;
    gameStarted = false;
    gameOver = false;
    pipes.clear();

    for (int i = 0; i < 3; i++) {
      pipes.add(
        PipePair(
          x: size.width + 140 + (i * pipeSpacing),
          gapY: randomGapY(size.height),
          passed: false,
        ),
      );
    }

    worldReady = true;
  }

  double randomGapY(double height) {
    const double margin = 90;
    final double maxGapTop = height - gapHeight - margin;

    if (maxGapTop <= margin) {
      return height * 0.3;
    }

    return margin + random.nextDouble() * (maxGapTop - margin);
  }

  void startGame() {
    if (!worldReady) return;

    timer?.cancel();

    setState(() {
      gameStarted = true;
      gameOver = false;
      velocity = jumpStrength;
    });

    timer = Timer.periodic(const Duration(milliseconds: 16), tick);
  }

  void tick(Timer timer) {
    const double dt = 0.016;
    bool shouldEnd = false;

    setState(() {
      velocity += gravity * dt;
      birdY += velocity * dt;

      for (final pipe in pipes) {
        pipe.x -= (pipeSpeed * widget.speedMultiplier) * dt;
      }

      for (final pipe in pipes) {
        if (!pipe.passed && pipe.x + pipeWidth < birdX) {
          pipe.passed = true;
          score++;
          widget.onCoinsEarned(widget.coinsPerPoint);
        }
      }

      double maxX = pipes.map((p) => p.x).reduce(max);

      for (final pipe in pipes) {
        if (pipe.x + pipeWidth < 0) {
          pipe.x = maxX + pipeSpacing;
          pipe.gapY = randomGapY(screenSize.height);
          pipe.passed = false;
          maxX = pipe.x;
        }
      }

      if (birdY < 0 || birdY + birdSize > screenSize.height || hitPipe()) {
        shouldEnd = true;
      }
    });

    if (shouldEnd) {
      endGame();
    }
  }

  bool hitPipe() {
    final Rect birdRect = Rect.fromCircle(
      center: Offset(birdX + birdSize / 2, birdY + birdSize / 2),
      radius: birdSize / 2 - 9,
    );

    for (final pipe in pipes) {
      final Rect topPipeRect = Rect.fromLTWH(pipe.x, 0, pipeWidth, pipe.gapY);

      final Rect bottomPipeRect = Rect.fromLTWH(
        pipe.x,
        pipe.gapY + gapHeight,
        pipeWidth,
        screenSize.height - (pipe.gapY + gapHeight),
      );

      if (birdRect.overlaps(topPipeRect) || birdRect.overlaps(bottomPipeRect)) {
        return true;
      }
    }

    return false;
  }

  void flap() {
    if (!gameStarted) {
      startGame();
      return;
    }

    if (gameOver) return;

    setState(() {
      velocity = jumpStrength;
    });
  }

  void endGame() {
    if (gameOver) return;

    timer?.cancel();

    setState(() {
      gameOver = true;
    });
  }

  void restartGame() {
    timer?.cancel();

    setState(() {
      initializeWorld(screenSize);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!worldReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: flap,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6EC6FF),
                      Color(0xFF2196F3),
                      Color(0xFF0D47A1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            ...pipes.map((pipe) {
              return Stack(
                children: [
                  Positioned(
                    left: pipe.x,
                    top: 0,
                    child: PipeWidget(
                      width: pipeWidth,
                      height: pipe.gapY,
                      upsideDown: true,
                    ),
                  ),
                  Positioned(
                    left: pipe.x,
                    top: pipe.gapY + gapHeight,
                    child: PipeWidget(
                      width: pipeWidth,
                      height: screenSize.height - (pipe.gapY + gapHeight),
                      upsideDown: false,
                    ),
                  ),
                ],
              );
            }),

            Positioned(
              left: birdX,
              top: birdY,
              child: Transform.rotate(
                angle: birdAngle,
                child: BirdPreview(
                  color: widget.birdSkin.color,
                  size: birdSize,
                  isRainbow: widget.birdSkin.isRainbow,
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.28),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Score: $score',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (!gameStarted) const Center(child: StartOverlay()),

            if (gameOver)
              Center(
                child: GameOverOverlay(
                  score: score,
                  coinsPerPoint: widget.coinsPerPoint,
                  onRestart: restartGame,
                  onBack: widget.onBack,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PipePair {
  double x;
  double gapY;
  bool passed;

  PipePair({required this.x, required this.gapY, required this.passed});
}

class PipeWidget extends StatelessWidget {
  final double width;
  final double height;
  final bool upsideDown;

  const PipeWidget({
    super.key,
    required this.width,
    required this.height,
    required this.upsideDown,
  });

  @override
  Widget build(BuildContext context) {
    if (height <= 0) return const SizedBox.shrink();

    return Transform.rotate(
      angle: upsideDown ? pi : 0,
      child: Column(
        children: [
          Container(
            width: width,
            height: max(0, height - 18),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              border: Border.all(color: const Color(0xFF1B5E20), width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Container(
            width: width + 10,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF43A047),
              border: Border.all(color: const Color(0xFF1B5E20), width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class BirdPreview extends StatelessWidget {
  final Color color;
  final double size;
  final bool isRainbow;

  const BirdPreview({
    super.key,
    required this.color,
    required this.size,
    this.isRainbow = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: CustomPaint(
        painter: BirdPainter(color: color, isRainbow: isRainbow),
      ),
    );
  }
}

class BirdPainter extends CustomPainter {
  final Color color;
  final bool isRainbow;

  BirdPainter({required this.color, required this.isRainbow});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bodyRect = Rect.fromLTWH(
      size.width * 0.12,
      size.height * 0.12,
      size.width * 0.65,
      size.height * 0.70,
    );

    final Paint bodyPaint = Paint();

    if (isRainbow) {
      bodyPaint.shader = const LinearGradient(
        colors: [
          Color(0xFFE53935),
          Color(0xFFFFA000),
          Color(0xFFFDD835),
          Color(0xFF43A047),
          Color(0xFF1E88E5),
          Color(0xFF8E24AA),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect);
    } else {
      bodyPaint.color = color;
    }

    final Paint wingPaint = Paint()..color = Colors.black.withOpacity(0.12);
    final Paint eyePaint = Paint()..color = Colors.white;
    final Paint pupilPaint = Paint()..color = Colors.black;
    final Paint beakPaint = Paint()..color = const Color(0xFFFFA000);

    final Rect wingRect = Rect.fromLTWH(
      size.width * 0.28,
      size.height * 0.34,
      size.width * 0.28,
      size.height * 0.22,
    );

    canvas.drawOval(bodyRect, bodyPaint);
    canvas.drawOval(wingRect, wingPaint);

    final Path beak = Path()
      ..moveTo(size.width * 0.74, size.height * 0.42)
      ..lineTo(size.width * 0.96, size.height * 0.50)
      ..lineTo(size.width * 0.74, size.height * 0.60)
      ..close();

    canvas.drawPath(beak, beakPaint);

    canvas.drawCircle(
      Offset(size.width * 0.57, size.height * 0.34),
      size.width * 0.07,
      eyePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.59, size.height * 0.34),
      size.width * 0.03,
      pupilPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BirdPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isRainbow != isRainbow;
  }
}

class CoinBadge extends StatelessWidget {
  final int coins;

  const CoinBadge({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            '$coins',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class StartOverlay extends StatelessWidget {
  const StartOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.30),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tippe zum Starten',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          Text(
            'Mit jedem Punkt bekommst du Coins.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final int score;
  final int coinsPerPoint;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.coinsPerPoint,
    required this.onRestart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final int earnedCoins = score * coinsPerPoint;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.40),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Game Over',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text('Dein Score: $score', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            'Coins in dieser Runde: $earnedCoins',
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: onRestart,
              child: const Text('Nochmal spielen'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 220,
            child: OutlinedButton(
              onPressed: onBack,
              child: const Text('Zurück zum Menü'),
            ),
          ),
        ],
      ),
    );
  }
}
