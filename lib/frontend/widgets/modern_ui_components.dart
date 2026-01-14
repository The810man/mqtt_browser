import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hacker-style app bar with navigation
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSettingsPressed;

  const ModernAppBar({
    super.key,
    required this.title,
    this.onSettingsPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        title: Row(
          children: [
            Icon(Icons.router, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Tooltip(
            message: 'Settings',
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: onSettingsPressed ?? () => context.go('/settings'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// Modern card widget for message displays
class MessageCard extends StatelessWidget {
  final String topic;
  final String message;
  final VoidCallback? onDelete;
  final bool isError;
  final DateTime timestamp;

  const MessageCard({
    super.key,
    required this.topic,
    required this.message,
    this.onDelete,
    this.isError = false,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: isError ? 4 : 2,
      color: isError
          ? Colors.red.withOpacity(0.1)
          : Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isError ? Icons.error_outline : Icons.topic_outlined,
                        color: isError ? Colors.red : Colors.blue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          topic,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${timestamp.hour}:${timestamp.minute}:${timestamp.second}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: onDelete,
                    constraints:
                        const BoxConstraints(maxHeight: 24, maxWidth: 24),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isError
                    ? Colors.red.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isError
                      ? Colors.red.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: isError ? Colors.red : null,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status indicator widget
class StatusIndicator extends StatelessWidget {
  final bool isConnected;
  final String? clientId;
  final VoidCallback? onReconnect;

  const StatusIndicator({
    super.key,
    required this.isConnected,
    this.clientId,
    this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: isConnected
          ? Colors.green.withOpacity(0.1)
          : Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isConnected ? Colors.green : Colors.orange,
                boxShadow: isConnected
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'Connected' : 'Disconnected',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isConnected ? Colors.green : Colors.orange,
                        ),
                  ),
                  if (clientId != null)
                    Text(
                      clientId!,
                      style: Theme.of(context).textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (!isConnected && onReconnect != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reconnect', style: TextStyle(fontSize: 12)),
                onPressed: onReconnect,
              ),
          ],
        ),
      ),
    );
  }
}
