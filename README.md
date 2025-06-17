# 💳 XPay - Modern Flutter Payment App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-2.17+-blue.svg)](https://dart.dev/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**A modern, feature-rich Flutter payment application with Material 3 design and glassmorphism effects**

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

## ✨ Features

### 💰 **Core Payment Features**
- 🏦 **Multi-Wallet Management** - Support for multiple currencies and payment methods
- 💸 **Money Transfer** - Send money to other users instantly
- 💳 **Add Money** - Top up wallet balance with credit/debit cards
- 🏧 **Money Out** - Withdraw funds through agent network
- 💱 **Currency Exchange** - Real-time currency conversion
- 📱 **QR Code Payments** - Scan and pay with QR codes
- 🧾 **Invoice Generation** - Create and manage invoices
- 🎫 **Voucher System** - Create and redeem vouchers

### 🎨 **Modern UI/UX**
- 🌟 **Material 3 Design** - Latest Material Design guidelines
- ✨ **Glassmorphism Effects** - Modern transparent card designs
- 🎭 **Smooth Animations** - 60fps animations with fade-in effects
- 🌙 **Dark Theme** - Professional dark theme with neon accents
- 📱 **Responsive Design** - Optimized for all screen sizes
- 🎯 **Intuitive Navigation** - Clean and user-friendly interface

### 🔧 **Technical Features**
- 🔥 **Firebase Integration** - Real-time database and authentication
- 🔄 **GetX State Management** - Reactive state management
- 🌐 **Multi-language Support** - Arabic and English localization
- 🔐 **Secure Authentication** - PIN-based and biometric authentication
- 📊 **Transaction History** - Comprehensive transaction tracking
- 🔔 **Push Notifications** - Real-time payment notifications

## 🏗️ Architecture

### **State Management**
- **GetX** - Reactive state management with dependency injection
- **Provider** - User data and wallet management
- **Observable Controllers** - Real-time UI updates

### **Project Structure**
```
lib/
├── 📁 controller/          # Business logic controllers
├── 📁 data/               # Data models and entities
├── 📁 routes/             # App routing configuration
├── 📁 utils/              # Utilities and constants
│   ├── custom_color.dart  # App color scheme
│   ├── custom_style.dart  # Typography and styles
│   └── dimensions.dart    # Responsive dimensions
├── 📁 views/              # UI screens and pages
│   ├── 📁 auth/          # Authentication screens
│   ├── 📁 dashboard/     # Dashboard and home
│   ├── 📁 add_money/     # Add money functionality
│   ├── 📁 transfer_money/ # Money transfer
│   └── 📁 settings/      # App settings
└── 📁 widgets/            # Reusable UI components
    ├── 📁 buttons/       # Custom buttons
    ├── 📁 inputs/        # Form inputs
    └── 📁 cards/         # Card components
```

## 🚀 Installation

### **Prerequisites**
- Flutter SDK (3.0+)
- Dart SDK (2.17+)
- Android Studio / VS Code
- Firebase account

### **Setup Steps**

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/xpay-flutter.git
   cd xpay-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a new Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Authentication and Firestore

4. **Run the application**
   ```bash
   flutter run
   ```

## 🎨 Design System

### **Color Palette**
- **Primary**: `#0854F8` - Modern blue for primary actions
- **Secondary**: `#465ACA` - Sidebar and secondary elements
- **Success**: `#00E676` - Success states and confirmations
- **Background**: `#000E19` - Deep dark background
- **Surface**: `#001A2E` - Card and surface backgrounds

### **Typography**
- **Headings**: Roboto Bold (18-24px)
- **Body**: Roboto Medium (14-16px)
- **Captions**: Roboto Regular (12px)

## 📱 Key Screens

### **Dashboard**
- Modern glassmorphism design with gradient overlays
- Quick action cards with color-coded themes
- Real-time balance display with growth indicators
- Featured services carousel

### **Payment Screens**
- Clean form layouts with modern text fields
- Real-time validation and feedback
- Smooth transitions and animations
- Secure payment processing

### **Settings & Profile**
- Comprehensive user management
- Security settings and preferences
- Multi-language support
- Theme customization

## 🔒 Security Features

- 🔐 **PIN Authentication** - Secure 6-digit PIN system
- 👆 **Biometric Support** - Fingerprint and face recognition
- 🔒 **Data Encryption** - End-to-end encryption for sensitive data
- 🛡️ **Secure Storage** - Encrypted local storage for credentials
- 🔍 **Transaction Verification** - Multi-step verification process

## 🌍 Localization

Currently supported languages:
- 🇺🇸 **English** - Primary language
- 🇸🇦 **Arabic** - RTL support included

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

## 📦 Dependencies

### **Core Dependencies**
- `flutter` - UI framework
- `get` - State management and routing
- `provider` - State management
- `firebase_core` - Firebase integration
- `firebase_auth` - Authentication
- `cloud_firestore` - Database

### **UI Dependencies**
- `ionicons` - Modern icon set
- `form_field_validator` - Form validation
- `flutter_localizations` - Internationalization

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### **Development Workflow**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Code Style**
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex business logic
- Maintain consistent formatting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Firebase team for backend services
- Community contributors and testers

## 📞 Support

- 📧 Email: support@xpay.com
- 💬 Discord: [Join our community](https://discord.gg/xpay)
- 📖 Documentation: [docs.xpay.com](https://docs.xpay.com)
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/xpay-flutter/issues)

---

<div align="center">

**⭐ Star this repository if you found it helpful!**

Made with ❤️ by the XPay Team

</div>
