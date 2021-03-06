import 'package:camerawesome/models/capture_modes.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:blue_anura/views/camera/widgets/option_button.dart';
import 'package:blue_anura/views/camera/widgets/take_photo_button.dart';
import 'package:flutter/material.dart';

class BottomBarWidget extends StatelessWidget {
  final AnimationController rotationController;
  final ValueNotifier<CameraOrientations> orientation;
  final ValueNotifier<CaptureModes> captureMode;
  final Function onZoomInTap;
  final Function onZoomOutTap;
  final Function onCaptureTap;

  const BottomBarWidget({
    Key key,
    @required this.rotationController,
    @required this.orientation,
    @required this.captureMode,
    @required this.onZoomOutTap,
    @required this.onZoomInTap,
    @required this.onCaptureTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 125,
        child: Stack(
          children: [
            Container(
              color: Colors.black12,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    OptionButton(
                      icon: Icons.zoom_out,
                      rotationController: rotationController,
                      orientation: orientation,
                      onTapCallback: () => onZoomOutTap?.call(),
                    ),
                    CameraButton(
                      key: ValueKey('cameraButton'),
                      captureMode: captureMode.value,
                      isRecording: false,
                      onTap: () => onCaptureTap?.call(),
                      // orientation: orientation,
                      // rotationController: rotationController,
                    ),
                    OptionButton(
                      icon: Icons.zoom_in,
                      rotationController: rotationController,
                      orientation: orientation,
                      onTapCallback: () => onZoomInTap?.call(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
