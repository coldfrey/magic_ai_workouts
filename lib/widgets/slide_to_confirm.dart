import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlideToConfirm extends StatefulWidget {
  final Function onConfirmed;
  final String message;

  const SlideToConfirm({
    super.key,
    required this.onConfirmed,
    this.message = "Slide to Confirm",
  });

  @override
  SlideToConfirmState createState() => SlideToConfirmState();
}

class SlideToConfirmState extends State<SlideToConfirm> {
  double dragPosition = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: dragPosition,
              child: GestureDetector(
                onHorizontalDragUpdate: (dragDetails) {
                  setState(() {
                    dragPosition += dragDetails.delta.dx;
                    if (dragPosition < 0) dragPosition = 0;
                    if (dragPosition > constraints.maxWidth - 80) {
                      dragPosition = constraints.maxWidth - 80;
                    }
                  });
                },
                onHorizontalDragEnd: (dragDetails) {
                  if (dragPosition >= constraints.maxWidth - 80) {
                    HapticFeedback.heavyImpact();
                    widget.onConfirmed();
                  }
                  setState(() {
                    dragPosition = 0;
                  });
                },
                child: Opacity(
                  opacity: 0.7,
                  child: Container(
                    height: 50.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              child: Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
