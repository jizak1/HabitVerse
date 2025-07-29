import 'package:flutter/material.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';

class AvatarWidget extends StatelessWidget {
  final User? user;
  final double size;
  final bool showLevel;

  const AvatarWidget({
    super.key,
    this.user,
    this.size = 60,
    this.showLevel = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Avatar Circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: user?.avatarUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(size / 2),
                  child: Image.network(
                    user!.avatarUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar(theme);
                    },
                  ),
                )
              : _buildDefaultAvatar(theme),
        ),
        
        // Level Badge
        if (showLevel && user != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Text(
                '${user!.level}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Center(
      child: Text(
        _getInitials(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials() {
    if (user?.name == null || user!.name.isEmpty) {
      return '?';
    }
    
    final nameParts = user!.name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return user!.name[0].toUpperCase();
    }
  }
}

class AnimatedAvatarWidget extends StatefulWidget {
  final User? user;
  final double size;
  final bool showLevel;
  final bool animate;

  const AnimatedAvatarWidget({
    super.key,
    this.user,
    this.size = 60,
    this.showLevel = false,
    this.animate = true,
  });

  @override
  State<AnimatedAvatarWidget> createState() => _AnimatedAvatarWidgetState();
}

class _AnimatedAvatarWidgetState extends State<AnimatedAvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void triggerAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return AvatarWidget(
        user: widget.user,
        size: widget.size,
        showLevel: widget.showLevel,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 0.1,
            child: AvatarWidget(
              user: widget.user,
              size: widget.size,
              showLevel: widget.showLevel,
            ),
          ),
        );
      },
    );
  }
}

class LevelUpAvatarWidget extends StatefulWidget {
  final User? user;
  final double size;
  final VoidCallback? onAnimationComplete;

  const LevelUpAvatarWidget({
    super.key,
    this.user,
    this.size = 100,
    this.onAnimationComplete,
  });

  @override
  State<LevelUpAvatarWidget> createState() => _LevelUpAvatarWidgetState();
}

class _LevelUpAvatarWidgetState extends State<LevelUpAvatarWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await _controller.forward();
    _particleController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    await _controller.reverse();
    
    if (widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: widget.size * 1.5,
              height: widget.size * 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.75),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: _glowAnimation.value * 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            
            // Avatar
            Transform.scale(
              scale: _scaleAnimation.value,
              child: AvatarWidget(
                user: widget.user,
                size: widget.size,
                showLevel: true,
              ),
            ),
            
            // Level up text
            Positioned(
              top: widget.size * 0.2,
              child: FadeTransition(
                opacity: _glowAnimation,
                child: Text(
                  'LEVEL UP!',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
