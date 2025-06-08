# AI Edge Gallery - iOS

This is the iOS implementation of the Google AI Edge Gallery, a native SwiftUI app that demonstrates on-device AI capabilities. The app allows users to run various AI models locally on their iPhone or iPad without requiring an internet connection after the initial model download.

## Features

📱 **Fully Native iOS App**
- Built with SwiftUI and modern iOS architecture patterns
- Optimized for both iPhone and iPad
- Dark/Light mode support
- Responsive design across different screen sizes

🤖 **AI Capabilities**
- **AI Chat**: Multi-turn conversations with language models
- **Ask Image**: Upload images and ask questions about them
- **Prompt Lab**: Single-turn text tasks and prompt engineering
- **Image Classification**: Identify objects and scenes in photos
- **Image Generation**: Create images from text descriptions
- **Text Classification**: Analyze sentiment and categorize text

🔧 **Model Management**
- Download and manage AI models
- Import local .task files
- Real-time download progress
- Background downloads with notifications
- Secure HuggingFace authentication for gated models

📊 **Performance Monitoring**
- Real-time inference metrics (TTFT, tokens/sec, latency)
- Model configuration and parameter tuning
- Performance benchmarking tools

## Architecture

The iOS app follows modern iOS development best practices:

### MVVM Architecture
- **Views**: SwiftUI views for the user interface
- **ViewModels**: ObservableObject classes handling business logic
- **Models**: Data models and business entities

### Dependency Injection
- `AppContainer`: Centralized dependency injection container
- Protocol-based architecture for testability
- Repository pattern for data access

### Navigation
- SwiftUI NavigationStack for type-safe navigation
- Custom NavigationManager for complex navigation flows
- Modal presentations for model management

### Data Layer
- Repository pattern for model and download management
- DataStore for persistent storage using UserDefaults and Keychain
- Network layer with URLSession for model downloads

### Security
- Keychain integration for secure token storage
- AES encryption for sensitive data
- Privacy-first design with on-device processing

## Project Structure

```
iOS/
├── GalleryApp.xcodeproj/          # Xcode project file
└── GalleryApp/
    ├── GalleryApp.swift           # Main app entry point
    ├── ContentView.swift          # Root content view
    ├── Info.plist                 # App configuration
    ├── Assets.xcassets/           # App icons and assets
    ├── Core/                      # Core app infrastructure
    │   ├── AppContainer.swift     # Dependency injection
    │   ├── NavigationManager.swift # Navigation coordination
    │   └── ThemeManager.swift     # Theme and appearance
    ├── Data/                      # Data layer
    │   ├── Model.swift            # Core data models
    │   ├── Config.swift           # Configuration system
    │   ├── Task.swift             # Task definitions
    │   ├── ModelStatus.swift      # Model status tracking
    │   ├── Constants.swift        # App constants
    │   ├── Repositories/          # Data repositories
    │   └── Services/              # Network and file services
    ├── Features/                  # Feature modules
    │   ├── Home/                  # Home screen
    │   ├── Chat/                  # AI Chat functionality
    │   ├── AskImage/              # Image Q&A functionality
    │   ├── PromptLab/             # Single-turn prompts
    │   ├── ImageClassification/   # Image classification
    │   ├── ImageGeneration/       # Image generation
    │   ├── TextClassification/    # Text classification
    │   ├── ModelManager/          # Model management
    │   └── Settings/              # App settings
    ├── UI/                        # Reusable UI components
    │   └── Components/
    ├── Utils/                     # Utility classes
    └── Preview Content/           # SwiftUI preview assets
```

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later
- iPhone or iPad with A12 Bionic chip or newer (recommended)

## Getting Started

### 1. Prerequisites

- Install Xcode 15.0 or later from the Mac App Store
- Ensure you have a valid Apple Developer account for device testing

### 2. Building the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/google-ai-edge/ai-edge-gallery.git
   cd ai-edge-gallery/iOS
   ```

2. Open the project in Xcode:
   ```bash
   open GalleryApp.xcodeproj
   ```

3. Select your development team in the project settings
4. Choose a target device or simulator
5. Build and run the project (⌘+R)

### 3. Configuration

The app uses a model allowlist file (`model_allowlist.json`) that defines available models. You can:

- Use the included sample models
- Add your own models to the allowlist
- Import local .task files through the app

### 4. Running on Device

For on-device AI inference, it's recommended to test on a physical device rather than the simulator for accurate performance metrics.

## Key Components

### AppContainer
Centralized dependency injection container that manages:
- Data repositories
- Network services
- File management
- App lifecycle

### NavigationManager
Handles navigation between screens and modal presentations:
- Type-safe navigation with NavigationPath
- Model manager overlay coordination
- Deep linking support

### Model Repository
Manages model lifecycle:
- Loading models from allowlist
- Tracking download and initialization status
- Importing local models
- Model configuration management

### Download Repository
Handles model downloads:
- Progress tracking
- Background downloads
- Retry logic
- HuggingFace authentication

## Performance Considerations

The app is optimized for on-device AI inference:

- **Memory Management**: Automatic model cleanup and memory monitoring
- **Background Processing**: Models can be downloaded while app is backgrounded
- **Progressive Loading**: UI remains responsive during model operations
- **Caching**: Intelligent caching of model assets and responses

## Testing

The app includes comprehensive previews for SwiftUI components:

```bash
# Run in Xcode
# Each View file includes #Preview blocks for SwiftUI previews
# Use the preview canvas to test UI components
```

## Contributing

This is a reference implementation demonstrating iOS AI capabilities. Key areas for contribution:

1. **Model Integration**: Add support for new model types
2. **Performance Optimization**: Improve inference speed and memory usage
3. **UI/UX Enhancements**: Improve user experience and accessibility
4. **Platform Features**: Leverage iOS-specific capabilities

## Troubleshooting

### Common Issues

1. **Build Errors**: Ensure you're using Xcode 15.0+ and iOS 17.0+ deployment target
2. **Model Loading**: Check internet connection for initial model downloads
3. **Performance**: Test on physical devices for accurate performance metrics
4. **Storage**: Monitor device storage for large model files

### Debug Mode

The app includes comprehensive logging for debugging:
- Model loading and initialization
- Download progress and errors
- Inference performance metrics

## License

This project is licensed under the Apache License 2.0. See the main repository LICENSE file for details.

## Related Projects

- [Android Implementation](../Android/README.md)
- [Model Allowlist](../model_allowlist.json)
- [AI Edge LiteRT Documentation](https://ai.google.dev/edge/litert)

## Support

For issues and questions:
- Check the [main repository issues](https://github.com/google-ai-edge/ai-edge-gallery/issues)
- Review the [AI Edge documentation](https://ai.google.dev/edge)
- Join the [AI Edge community](https://developers.google.com/community)