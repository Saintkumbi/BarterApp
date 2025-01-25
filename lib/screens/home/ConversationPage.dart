import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'item.dart';
import 'trade.dart';
import 'ItemView.dart';
import 'dart:ui';
import 'ExplorePage.dart';
import 'home_page.dart';
import 'InboxPage.dart';
import 'trade.dart';

class Message {
  final String content;
  final bool isSent;
  final DateTime timestamp;
  final MessageType type;
  final TradeRequest? tradeRequest;

  Message({
    required this.content,
    required this.isSent,
    required this.timestamp,
    this.type = MessageType.text,
    this.tradeRequest,
  });
}

enum MessageType { text, image, tradeRequest }

class TradeRequest {
  final String id;
  final List<Item> offeredItem;
  final Item requestedItem;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime timestamp;

  TradeRequest({
    required this.id,
    required this.offeredItem,
    required this.requestedItem,
    required this.status,
    required this.timestamp,
  });
}

class ChatItem {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String imagePath;
  final bool isRead;
  final List<Message> messages;
  final TradeRequest? activeTradeRequest;

  ChatItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.imagePath,
    this.isRead = false,
    List<Message>? messages,
    this.activeTradeRequest,
  }) : messages = messages ?? [];
}

class ConversationPage extends StatefulWidget {
  final ChatItem chatItem;

  ConversationPage({required this.chatItem});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TradePersistenceService _tradePersistenceService = TradePersistenceService();

  List<Message> messages = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    messages = widget.chatItem.messages;
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleTradeRequest(TradeRequest request) {
    setState(() {
      messages.add(Message(
        content: 'Trade Request',
        isSent: false,
        timestamp: DateTime.now(),
        type: MessageType.tradeRequest,
        tradeRequest: TradeRequest(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          offeredItem: request.offeredItem, // Already a list
          requestedItem: request.requestedItem,
          status: 'pending',
          timestamp: DateTime.now(),
        ),
      ));
    });
    _scrollToBottom();
  }

  void _respondToTradeRequest(bool accepted, TradeRequest request) {
    setState(() {
      messages.add(Message(
        content:
            accepted ? 'Trade request accepted!' : 'Trade request declined.',
        isSent: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(Message(
        content: _messageController.text,
        isSent: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      isTyping = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(widget.chatItem.imagePath),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chatItem.name,
                      style: TextStyle(color: Colors.white)),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text('Online',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.local_offer, color: Colors.white),
              onPressed: () {
                // Show active trade requests
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // Show chat options
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (widget.chatItem.activeTradeRequest != null)
            _buildActiveTradeRequest(widget.chatItem.activeTradeRequest!),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                if (index == 0 || _shouldShowDate(index)) {
                  return Column(
                    children: [
                      _buildDateDivider(message.timestamp),
                      _buildMessage(message),
                    ],
                  );
                }
                return _buildMessage(message);
              },
            ),
          ),
          if (isTyping)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.chatItem.name} is typing...',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildActiveTradeRequest(TradeRequest request) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.yellow.shade50,
      child: Row(
        children: [
          Icon(Icons.local_offer, color: Colors.amber),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Trade Request',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Offering: ${request.offeredItem.map((item) => item.name).join(", ")}',
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // View trade request details
            },
            child: Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Message message) {
    switch (message.type) {
      case MessageType.image:
        return _buildImageMessage(message);
      default:
        return _buildTextMessage(message);
    }
  }


  Widget _buildTextMessage(Message message) {
    return Align(
      alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: message.isSent
              ? const Color.fromARGB(255, 239, 192, 67)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: message.isSent
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(message.content),
            SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _formatDate(date),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file),
              onPressed: () {
                // Show attachment options
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onChanged: (text) {
                  setState(() {
                    isTyping = text.isNotEmpty;
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              color: Colors.blue,
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(Message message) {
    return Align(
      alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: message.isSent
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(message.content)),
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDate(int index) {
    if (index == 0) return true;
    final currentDate = messages[index].timestamp;
    final previousDate = messages[index - 1].timestamp;
    return !_isSameDay(currentDate, previousDate);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    if (_isToday(date)) return 'Today';
    if (_isYesterday(date)) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return _isSameDay(date, yesterday);
  }
}



  