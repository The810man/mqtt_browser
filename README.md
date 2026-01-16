# MQTT Browser

A modern, standalone Flutter application for browsing and interacting with MQTT topic trees.

## Features

- **MQTT Connection Management**: Connect to MQTT brokers with advanced settings (TLS, authentication, keep-alive, etc.)
- **Topic Tree Visualization**: Interactive tree view of MQTT topics with expand/collapse functionality
- **Real-time Data Display**: View live MQTT messages in tabbed interface
- **Publishing**: Send MQTT messages with JSON support, QoS levels, and retain options
- **Subscription Management**: Auto-subscribe to topics on connect, manual subscribe/unsubscribe
- **Saved Connections**: Save and load connection presets with custom icons
- **Charts & Analytics**: Visualize numeric data with interactive charts
- **Theme Support**: Dark/light mode with customizable themes
- **Data Export**: Export topic tree data to JSON/CSV for analysis

## Installation

### Building from Source

1. Ensure you have Flutter installed: <https://flutter.dev/docs/get-started/install>
2. Clone the repository:

   ```bash
   git clone https://github.com/your-repo/mqtt_browser.git
   cd mqtt_browser
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app:

   ```bash
   flutter run
   ```

5. Build for your platform:

   ```bash
   flutter build linux  # or windows, macos, etc.
   ```

### Pre-built Binaries

Download the latest release from the releases page.

## Usage

### Getting Started

1. Launch the app
2. On the setup page, enter your MQTT broker details (host, port)
3. Configure advanced settings if needed (TLS, authentication, subscriptions)
4. Click "Connect"

### Connection Settings

- **Basic**: Host, port, client ID
- **Authentication**: Username/password
- **Security**: TLS/SSL options
- **Advanced**: Keep-alive, connection timeout, clean session
- **Subscriptions**: Auto-subscribe topics with QoS levels

### Saved Connections

- Save connection presets for quick access
- Customize connection icons
- Edit/delete saved connections

### Topic Tree

- Browse MQTT topics in a hierarchical tree
- Expand/collapse nodes
- Open topics in tabs for detailed viewing
- Search topics
- Export tree data to JSON file

### Publishing Messages

- Enter topic and payload (supports JSON)
- Set QoS level (0, 1, 2)
- Retain message option
- Send button

### Charts

- View numeric data as line charts
- Interactive zooming and panning
- Multiple chart types supported

### Settings

- Theme selection (dark/light)
- Tree view preferences
- Connection defaults

## Troubleshooting

### Connection Issues

- Verify broker host and port
- Check network connectivity
- Ensure MQTT broker allows connections from your IP
- For TLS, verify certificates are properly configured

### Performance

- Large topic trees may impact performance
- Use search to filter topics
- Close unused tabs

### Common Errors

- "Connection refused": Check broker is running and accessible
- "Authentication failed": Verify username/password
- "TLS handshake failed": Check certificate configuration

## Development

### Prerequisites

- Flutter 3.0+
- Dart 3.0+

### Project Structure

- `lib/backend/`: MQTT connection logic
- `lib/frontend/`: UI components and pages
- `lib/services/`: Data persistence and settings
- `lib/providers/`: State management

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

Built with Flutter and MQTT5 client library.
