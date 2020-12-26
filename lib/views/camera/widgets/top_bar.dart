import 'package:camerawesome/models/capture_modes.dart';
import 'package:camerawesome/models/flashmodes.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:blue_anura/views/widgets/option_button.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

class TopBarWidget extends StatelessWidget {
  final bool isFullscreen;
  final ValueNotifier<Size> photoSize;
  final AnimationController rotationController;
  final ValueNotifier<CameraOrientations> orientation;
  final ValueNotifier<CaptureModes> captureMode;
  final ValueNotifier<CameraFlashes> switchFlash;
  final Function onFullscreenTap;
  final Function onResolutionTap;
  final Function onFlashTap;

  const TopBarWidget({
    Key key,
    @required this.isFullscreen,
    @required this.captureMode,
    @required this.photoSize,
    @required this.orientation,
    @required this.rotationController,
    @required this.switchFlash,
    @required this.onFullscreenTap,
    @required this.onFlashTap,
    @required this.onResolutionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: <Widget>[
              //     Padding(
              //       padding: const EdgeInsets.only(right: 24.0),
              //       child: Opacity(
              //         // opacity: isRecording ? 0.3 : 1.0,
              //         opacity: 1.0,
              //         child: IconButton(
              //           icon: Icon(
              //             isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              //             color: Colors.white,
              //           ),
              //           // onPressed:
              //           // isRecording ? null : () => onFullscreenTap?.call(),
              //           onPressed:
              //            () => onFullscreenTap?.call(),
              //         ),
              //       ),
              //     ),
              //     // Padding(
              //     //   padding: const EdgeInsets.only(right: 24),
              //     //   child: Row(
              //     //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     //     children: <Widget>[
              //     //       IgnorePointer(
              //     //         ignoring: isRecording,
              //     //         child: Opacity(
              //     //           opacity: isRecording ? 0.3 : 1.0,
              //     //           child: ValueListenableBuilder(
              //     //             valueListenable: photoSize,
              //     //             builder: (context, value, child) => FlatButton(
              //     //               key: ValueKey("resolutionButton"),
              //     //               onPressed: () {
              //     //                 HapticFeedback.selectionClick();
              //     //
              //     //                 onResolutionTap?.call();
              //     //               },
              //     //               child: Text(
              //     //                 '${value?.width?.toInt()} / ${value?.height?.toInt()}',
              //     //                 key: ValueKey("resolutionTxt"),
              //     //                 style: TextStyle(color: Colors.white),
              //     //               ),
              //     //             ),
              //     //           ),
              //     //         ),
              //     //       ),
              //     //     ],
              //     //   ),
              //     // ),
              //     // OptionButton(
              //     //   icon: Icons.switch_camera,
              //     //   rotationController: rotationController,
              //     //   orientation: orientation,
              //     //   onTapCallback: () => onChangeSensorTap?.call(),
              //     // ),
              //     // SizedBox(width: 20.0),
              //     // OptionButton(
              //     //   rotationController: rotationController,
              //     //   icon: _getFlashIcon(),
              //     //   orientation: orientation,
              //     //   onTapCallback: () => onFlashTap?.call(),
              //     // ),
              //   ],
              // ),
              // SizedBox(height: 20.0),
              OptionButton(
                rotationController: rotationController,
                icon: _getFlashIcon(),
                orientation: orientation,
                onTapCallback: () => onFlashTap?.call(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (switchFlash.value) {
      case CameraFlashes.NONE:
        return Icons.flash_off;
      case CameraFlashes.ON:
        return Icons.flash_on;
      case CameraFlashes.AUTO:
        return Icons.flash_auto;
      case CameraFlashes.ALWAYS:
        return Icons.highlight;
      default:
        return Icons.flash_off;
    }
  }
}
