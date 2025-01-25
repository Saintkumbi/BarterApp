import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// Data models extended with persistence capabilities
class TradeRequestDTO {
  final String id;
  final List<String> offeredItemIds;
  final String requestedItemId;
  final String status;
  final String fromUserId;
  final String toUserId;
  final DateTime timestamp;
  final DateTime? lastUpdated;

  TradeRequestDTO({
    required this.id,
    required this.offeredItemIds,
    required this.requestedItemId,
    required this.status,
    required this.fromUserId,
    required this.toUserId,
    required this.timestamp,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'requestId': id,
    'offeredItemIds': offeredItemIds,
    'requestedItemId': requestedItemId,
    'status': status,
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    'timestamp': timestamp.toIso8601String(),
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  factory TradeRequestDTO.fromJson(Map<String, dynamic> json) {
    return TradeRequestDTO(
      id: json['requestId'],
      offeredItemIds: List<String>.from(json['offeredItemIds']),
      requestedItemId: json['requestedItemId'],
      status: json['status'],
      fromUserId: json['fromUserId'],
      toUserId: json['toUserId'],
      timestamp: DateTime.parse(json['timestamp']),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }
}

class TradePersistenceService {
  static const String _tradeRequestsKey = 'trade_requests';
  static const String _tradeLocksKey = 'trade_locks';
  late SharedPreferences _prefs;
  final _lockTimeout = const Duration(seconds: 30);

  // Singleton pattern
  static final TradePersistenceService _instance = TradePersistenceService._internal();
  factory TradePersistenceService() => _instance;
  TradePersistenceService._internal();

  // Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _cleanupStaleLocks();
  }

  // Create a new trade request with optimistic locking
  Future<bool> createTradeRequest(TradeRequestDTO request) async {
    try {
      if (await _acquireLock(request.id)) {
        final requests = await _loadTradeRequests();
        requests[request.id] = request;
        await _saveTradeRequests(requests);
        await _releaseLock(request.id);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating trade request: $e');
      await _releaseLock(request.id);
      return false;
    }
  }

  // Update an existing trade request
  Future<bool> updateTradeRequest(String id, String newStatus) async {
    try {
      if (await _acquireLock(id)) {
        final requests = await _loadTradeRequests();
        if (requests.containsKey(id)) {
          final updatedRequest = TradeRequestDTO(
            id: requests[id]!.id,
            offeredItemIds: requests[id]!.offeredItemIds,
            requestedItemId: requests[id]!.requestedItemId,
            status: newStatus,
            fromUserId: requests[id]!.fromUserId,
            toUserId: requests[id]!.toUserId,
            timestamp: requests[id]!.timestamp,
            lastUpdated: DateTime.now(),
          );
          requests[id] = updatedRequest;
          await _saveTradeRequests(requests);
          await _releaseLock(id);
          return true;
        }
        await _releaseLock(id);
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating trade request: $e');
      await _releaseLock(id);
      return false;
    }
  }

  // Get trade request by ID
  Future<TradeRequestDTO?> getTradeRequest(String id) async {
    try {
      final requests = await _loadTradeRequests();
      return requests[id];
    } catch (e) {
      debugPrint('Error getting trade request: $e');
      return null;
    }
  }

  // Get all trade requests for a user
  Future<List<TradeRequestDTO>> getTradeRequestsForUser(String userId) async {
    try {
      final requests = await _loadTradeRequests();
      return requests.values
          .where((req) => req.fromUserId == userId || req.toUserId == userId)
          .toList();
    } catch (e) {
      debugPrint('Error getting user trade requests: $e');
      return [];
    }
  }

  // Load all trade requests from storage
  Future<Map<String, TradeRequestDTO>> _loadTradeRequests() async {
    final String? jsonStr = _prefs.getString(_tradeRequestsKey);
    if (jsonStr == null) return {};

    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap.map((key, value) => MapEntry(
        key,
        TradeRequestDTO.fromJson(value as Map<String, dynamic>),
      ));
    } catch (e) {
      debugPrint('Error loading trade requests: $e');
      return {};
    }
  }

  // Save all trade requests to storage
  Future<void> _saveTradeRequests(Map<String, TradeRequestDTO> requests) async {
    final jsonMap = requests.map((key, value) => MapEntry(key, value.toJson()));
    await _prefs.setString(_tradeRequestsKey, json.encode(jsonMap));
  }

  // Implement optimistic locking
  Future<bool> _acquireLock(String id) async {
    final now = DateTime.now();
    final locks = await _getLocks();
    
    if (locks.containsKey(id)) {
      final lockTime = DateTime.parse(locks[id]!);
      if (now.difference(lockTime) < _lockTimeout) {
        return false;
      }
    }
    
    locks[id] = now.toIso8601String();
    await _prefs.setString(_tradeLocksKey, json.encode(locks));
    return true;
  }

  Future<void> _releaseLock(String id) async {
    final locks = await _getLocks();
    locks.remove(id);
    await _prefs.setString(_tradeLocksKey, json.encode(locks));
  }

  Future<Map<String, String>> _getLocks() async {
    final String? jsonStr = _prefs.getString(_tradeLocksKey);
    if (jsonStr == null) return {};
    return Map<String, String>.from(json.decode(jsonStr));
  }

  Future<void> _cleanupStaleLocks() async {
    final now = DateTime.now();
    final locks = await _getLocks();
    locks.removeWhere((_, timestamp) {
      final lockTime = DateTime.parse(timestamp);
      return now.difference(lockTime) >= _lockTimeout;
    });
    await _prefs.setString(_tradeLocksKey, json.encode(locks));
  }

  // Recover from app restart
  Future<void> recoverPendingTrades() async {
    try {
      final requests = await _loadTradeRequests();
      final pendingRequests = requests.values
          .where((req) => req.status == 'pending')
          .toList();
      
      // Clean up any stale locks
      await _cleanupStaleLocks();
      
      // Process pending requests if needed
      for (var request in pendingRequests) {
        debugPrint('Recovered pending trade request: ${request.id}');
      }
    } catch (e) {
      debugPrint('Error recovering pending trades: $e');
    }
  }
}


