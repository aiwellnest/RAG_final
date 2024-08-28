import 'package:ai_wellnest_frontend/provider/auth_provider.dart';
import 'package:ai_wellnest_frontend/provider/chat_provider.dart';
import 'package:ai_wellnest_frontend/screen/main_screen/widgets/chat_field.dart';
import 'package:ai_wellnest_frontend/theme/color_pallete.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Map<String, bool> _hoveredListTiles = {};

  bool _isDrawerOpen = true;

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    if (authProvider.currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: ColorPallete.backgroundColor,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: _isDrawerOpen ? 0 : -280,
            top: 0,
            bottom: 0,
            child: Container(
              width: 280,
              color: ColorPallete.lightBackgroundColor,
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(authProvider.currentUser!.uid)
                          .collection('history')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final sessionHistory = snapshot.data!.docs;

                        return ListView(
                          padding: const EdgeInsets.only(top: 80.0),
                          children: sessionHistory.map((doc) {
                            final sessionId = doc.id;

                            if (!_hoveredListTiles.containsKey(sessionId)) {
                              _hoveredListTiles[sessionId] = false;
                            }

                            final isSelected =
                                chatProvider.selectedSessionId == sessionId;

                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: MouseRegion(
                                onEnter: (_) => setState(
                                    () => _hoveredListTiles[sessionId] = true),
                                onExit: (_) => setState(
                                    () => _hoveredListTiles[sessionId] = false),
                                child: AnimatedContainer(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSelected
                                        ? ColorPallete.darkGreenColor
                                        : _hoveredListTiles[sessionId]!
                                            ? ColorPallete.darkGreenColor
                                            : ColorPallete.lightBackgroundColor,
                                  ),
                                  duration: const Duration(milliseconds: 200),
                                  child: ListTile(
                                    title: Text(
                                      'Session: $sessionId',
                                      style: const TextStyle(
                                          color: ColorPallete.whiteColor),
                                    ),
                                    onTap: () => chatProvider.loadSession(
                                        sessionId, authProvider),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  const Divider(
                    color: ColorPallete.borderColor,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 10, 20, 25),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: ColorPallete.darkGreenColor,
                          child: Icon(
                            Icons.person_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authProvider.currentUser!.username,
                            style:
                                const TextStyle(color: ColorPallete.whiteColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.logout_rounded,
                            color: Colors.red[600],
                          ),
                          onPressed: () {
                            authProvider.signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: _isDrawerOpen ? 280 : 0,
            top: 0,
            bottom: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    const SizedBox(height: 55),
                    Flexible(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        reverse: true,
                        itemBuilder: (_, int index) =>
                            chatProvider.messages[index],
                        itemCount: chatProvider.messages.length,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ChatField(
                                hintText: 'Send a message to AI Wellnest',
                                controller: chatProvider.messageController,
                                onSubmitted: () async {
                                  chatProvider.sendMessage(authProvider);
                                }),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: const BoxDecoration(
                              color: ColorPallete.darkGreenColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                chatProvider.isListening
                                    ? Icons.stop
                                    : Icons.mic,
                                color: ColorPallete.backgroundColor,
                              ),
                              onPressed: chatProvider.listen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedOpacity(
                            opacity: chatProvider.isListening ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: chatProvider.isListening ? 0 : 48,
                              child: chatProvider.isListening
                                  ? const SizedBox.shrink()
                                  : Container(
                                      decoration: const BoxDecoration(
                                        color: ColorPallete.darkGreenColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                          icon: const Icon(
                                            Icons.arrow_upward_rounded,
                                            color: ColorPallete.backgroundColor,
                                          ),
                                          onPressed: () async {
                                            chatProvider
                                                .sendMessage(authProvider);
                                          }),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'AI Wellnest can make mistakes. Check important information.',
                        style: TextStyle(color: ColorPallete.whiteShadeColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 25,
            left: 16,
            child: ElevatedButton(
              onPressed: _toggleDrawer,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                backgroundColor: _isDrawerOpen
                    ? ColorPallete.lightBackgroundColor
                    : ColorPallete.backgroundColor,
              ),
              child: Icon(
                _isDrawerOpen ? Icons.menu_open_rounded : Icons.menu_rounded,
                color: ColorPallete.whiteColor,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 25,
            left: _isDrawerOpen ? 200 : 70,
            child: ElevatedButton(
              onPressed: chatProvider.startNewSession,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                backgroundColor: _isDrawerOpen
                    ? ColorPallete.lightBackgroundColor
                    : ColorPallete.backgroundColor,
              ),
              child: const Icon(
                Icons.add_comment_rounded,
                color: ColorPallete.whiteColor,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 13,
            left: _isDrawerOpen ? 300 : 150,
            child: Row(
              children: [
                Image.asset(
                  'assets/white_logo.png',
                  alignment: Alignment.center,
                  height: 50,
                ),
                const SizedBox(width: 10),
                const Text(
                  'AI Wellnest',
                  style: TextStyle(
                    color: ColorPallete.whiteColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
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
