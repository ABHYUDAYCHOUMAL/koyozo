# Architecture Documentation

## Overview
The Koyozo iOS app follows **MVVM + Clean Architecture** pattern.

## Architecture Layers

### Presentation Layer
- **Views**: SwiftUI views for UI
- **ViewModels**: Business logic and state management
- **Components**: Reusable UI components

### Domain Layer
- **Models**: Domain entities
- **Use Cases**: Business logic operations

### Data Layer
- **Repositories**: Data abstraction layer
- **Data Sources**: Remote (API) and Local (Cache/Storage)
- **DTOs**: Data Transfer Objects for API responses
- **Mappers**: DTO to Domain model conversion

## Dependency Flow
```
View → ViewModel → UseCase → Repository → DataSource
```

## Key Principles
1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Dependency Injection**: Dependencies injected via initializers
3. **Protocol-Oriented**: Use protocols for testability
4. **Single Responsibility**: Each class/struct has one purpose

