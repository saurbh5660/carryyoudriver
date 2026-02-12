import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_colors.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final List<ChatMessage> messages = [
    ChatMessage(
      text:
          'Lorem ipsum is simply dummy text of the printing and type setting industry',
      isMe: false,
      image: 'https://i.pravatar.cc/150?img=1',
    ),
    ChatMessage(
      text:
          'Lorem ipsum is simply dummy text of the printing and type setting industry',
      isMe: true,
      image: 'https://i.pravatar.cc/150?img=3',
    ),
    ChatMessage(
      text:
          'Lorem ipsum is simply dummy text of the printing and type setting industry',
      isMe: false,
      image: 'https://i.pravatar.cc/150?img=1',
    ),
    ChatMessage(
      text:
          'Lorem ipsum is simply dummy text of the printing and type setting industry',
      isMe: true,
      image: 'https://i.pravatar.cc/150?img=3',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
            ),
            const SizedBox(width: 8),
            Text(
              'John Smith',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
            color: Colors.white,
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'clear') {
                debugPrint('Clear Chat');
              } else {
                debugPrint('Block User');
              }
            },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear',
                  height: 36,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clear Chat',
                        style: GoogleFonts.montserrat(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: Colors.grey.shade300),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'block',
                  height: 32,
                  child: Text(
                    'Block',
                    style: GoogleFonts.montserrat(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.black),

                  ),
                ),
              ]
          ),
        ],

      ),

      /// ================= BODY =================
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _chatBubble(messages[index]);
                },
              ),
            ),

            /// ================= INPUT =================
            _chatInput(),
          ],
        ),
      ),
    );
  }

  /// ================= CHAT BUBBLE =================
  Widget _chatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isMe)
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(message.image),
            ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: message.isMe ?  Colors.grey.shade200 : AppColor.yellowColor ,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  textAlign: message.isMe ? TextAlign.end : TextAlign.start,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: message.isMe ? Colors.black : Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '10:26am',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: message.isMe ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          if (message.isMe)
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(message.image),
            ),
        ],
      ),
    );
  }

  /// ================= INPUT BAR =================
  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type...',
                  hintStyle: GoogleFonts.montserrat(fontSize: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

/// ================= MODEL =================
class ChatMessage {
  final String text;
  final bool isMe;
  final String image;

  ChatMessage({required this.text, required this.isMe, required this.image});
}
