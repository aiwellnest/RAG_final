import 'package:ai_wellnest_frontend/provider/chat_provider.dart';
import 'package:ai_wellnest_frontend/theme/color_pallete.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageChat extends StatefulWidget {
  final String message;
  final bool isSentByUser;
  final String username;
  final bool animate;
  final Key id;

  const MessageChat({
    super.key,
    required this.message,
    required this.isSentByUser,
    required this.username,
    this.animate = false,
    required this.id,
  });

  @override
  State<MessageChat> createState() => _MessageChatState();
}

class _MessageChatState extends State<MessageChat> {
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final isCurrentlySpeaking =
        chatProvider.currentlySpeakingMessageId == widget.id.toString();
    final isAnotherSpeaking =
        chatProvider.currentlySpeakingMessageId != null && !isCurrentlySpeaking;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: widget.isSentByUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!widget.isSentByUser) ...[
            Column(
              children: [
                CircleAvatar(
                  backgroundColor: ColorPallete.darkGreenColor,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/white_logo.png',
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (!isAnotherSpeaking) ...[
                  const SizedBox(height: 10),
                  IconButton(
                    icon: Icon(
                      isCurrentlySpeaking
                          ? Icons.stop_rounded
                          : Icons.volume_up_rounded,
                      color: ColorPallete.whiteShadeColor,
                    ),
                    onPressed: isCurrentlySpeaking
                        ? () => chatProvider.stop()
                        : () => chatProvider.speak(
                            widget.message, widget.id.toString()),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 10)
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: widget.isSentByUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.isSentByUser
                        ? ColorPallete.darkGreenColor
                        : ColorPallete.lightBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(widget.isSentByUser ? 10 : 1),
                      topRight: Radius.circular(widget.isSentByUser ? 1 : 10),
                      bottomLeft: const Radius.circular(10),
                      bottomRight: const Radius.circular(10),
                    ),
                  ),
                  child: widget.animate
                      ? AnimatedTextKit(
                          key: widget.id,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              widget.message,
                              textStyle: const TextStyle(
                                  color: ColorPallete.whiteColor, fontSize: 16),
                              speed: const Duration(milliseconds: 25),
                            ),
                          ],
                          isRepeatingAnimation: false,
                        )
                      : Text(
                          widget.message,
                          key: widget.id,
                          style: const TextStyle(
                              color: ColorPallete.whiteColor, fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
