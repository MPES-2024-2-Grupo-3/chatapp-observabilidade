import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSender;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSender) CustomPaint(painter: Triangle(Colors.grey[300]!)),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSender ? Colors.grey[900] : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isSender ? 18 : 0),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  topRight: Radius.circular(isSender ? 0 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.split('\n')[0],
                    style: TextStyle(
                      color: isSender ? Colors.white : Colors.black,
                    ),
                  ),
                  if (message.split('\n').length > 1) ...[  
                    const SizedBox(height: 4),
                    Text(
                      message.split('\n').sublist(1).join('\n'),
                      style: TextStyle(
                        color: isSender ? Colors.white70 : Colors.black54,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isSender) CustomPaint(painter: Triangle(Color(0xFF1A172A))),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        right: isSender ? 18.0 : 50.0,
        left: isSender ? 50.0 : 18.0,
        top: 5,
        bottom: 5,
      ),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          messageTextGroup,
        ],
      ),
    );
  }
}

class Triangle extends CustomPainter {
  final Color bgColor;

  Triangle(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}