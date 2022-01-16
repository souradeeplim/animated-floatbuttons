import 'package:animated_floating_buttons/widgets/transform_float_button.dart';
import 'package:flutter/material.dart';

class AnimatedFloatingActionButton extends StatefulWidget {
  ///
  /// list of Floating Action Buttons.
  final List<Widget> fabButtons;

  final AnimatedIconData animatedIconData;
  final Color iconColor;
  final int durationAnimation;
  final Color colorStartAnimation;
  final Color colorEndAnimation;
  final String? tooltip;
  final Curve curve;
  final double spaceBetween;
  final bool reverse;

  /// The [fabButtons] and [animatedIconData] arguments must not be null.
  /// The [durationAnimation], [colorStartAnimation], [colorEndAnimation],
  /// [curve] and [spaceBetween] default to the value given by the library
  /// but also the should not be null.
  const AnimatedFloatingActionButton({
    Key? key,
    required this.fabButtons,
    required this.animatedIconData,
    this.iconColor = Colors.white,
    this.durationAnimation = 500,
    this.colorStartAnimation = Colors.blue,
    this.colorEndAnimation = Colors.red,
    this.curve = Curves.easeOut,
    this.spaceBetween = -5.0,
    this.tooltip = 'toggle',
    this.reverse = false,
  })  : assert(
          durationAnimation > 150 && durationAnimation < 1250,
          'The duration of the animation should be '
          'greater than 150 and smaller than 12500.',
        ),
        assert(
          fabButtons.length > 1,
          'The number of FABs should be more than 1 FAB.',
        ),
        assert(
          spaceBetween <= -5,
          'This is a space between the FABs when they are expanded, '
          'and the value should be lower than or '
          'equal to -5 to have a reasonable space between them.',
        ),
        super(key: key);

  @override
  AnimatedFloatingActionButtonState createState() =>
      AnimatedFloatingActionButtonState();
}

class AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  /// AnimationController object to control over the whole animation.
  late AnimationController _animationController;
  late Animation<Color?> _buttonColor;
  late Animation<double> _animateIcon;
  late Animation<double> _translateButton;
  double _fabHeight = 56.0;
  bool _isOpened = false;

  bool get isOpened => _isOpened;

  @override
  initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.durationAnimation,
      ),
    )..addListener(
        () {
          /// We here changing the state of the widget
          /// upon any changes from animation controller.
          setState(() {});
        },
      );

    /// This Tween is to animate the icon of the main FAB.
    _animateIcon = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      _animationController,
    );

    /// This ColorTween is to animate the background Color of main FAB.
    _buttonColor = ColorTween(
      begin: widget.colorStartAnimation,
      end: widget.colorEndAnimation,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.00,
          1.00,
          curve: Curves.linear,
        ),
      ),
    );

    /// This Tween is to animate position of the current fab
    /// according to its position in the list.
    _translateButton = Tween<double>(
      begin: widget.reverse ? widget.spaceBetween : _fabHeight,
      end: widget.reverse ? _fabHeight : widget.spaceBetween,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          0.75,
          curve: widget.curve,
        ),
      ),
    );
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _buildFABs(),
    );
  }

  Widget _buildMainFAB() {
    return FloatingActionButton(
      backgroundColor: _buttonColor.value,
      onPressed: _animateFABs,
      tooltip: widget.tooltip,
      child: AnimatedIcon(
        icon: widget.animatedIconData,
        progress: _animateIcon,
        color: widget.iconColor,
      ),
    );
  }

  List<Widget> _buildFABs() {
    final List<Widget> processButtons = [];
    for (int i = 0; i < widget.fabButtons.length; i++) {
      processButtons.add(
        Opacity(
          opacity: _animateIcon.value,
          child: TransformFloatActionButton(
            floatButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.fabButtons[i],
              ],
            ),
            translateValue: widget.reverse
                ? (_translateButton.value * i)
                : (_translateButton.value * (widget.fabButtons.length - i)),
          ),
        ),
      );
    }

    if (widget.reverse) {
      processButtons.insert(0, _buildMainFAB());
    } else {
      processButtons.add(_buildMainFAB());
    }
    return processButtons;
  }

  void _animateFABs() {
    if (!_isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    _isOpened = !_isOpened;
  }

  /// This method is visible from outside of this state widget throw
  /// GlobalKey<AnimatedFloatingActionButtonState>() object which is created
  /// and assign as a key object to [AnimatedFloatingActionButton] by user
  /// to close the [fabButtons] list.
  void closeFABs() {
    _animateFABs();
  }
}
