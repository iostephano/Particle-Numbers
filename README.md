# Particle-Numbers
## Description

ParticleNumbers is an interactive iOS app that uses GPU-accelerated particles to form any number between 0 and 99 on screen. Tiny colored dots float randomly and, on command, smoothly regroup into the chosen number before dispersing again. The entire interface is built programmatically in UIKit, with Metal powering the real-time animations.

## Key Features

- Real-Time Particle Animation at 60 FPS
- Dynamic Number Formation from 0–99
- Multi-Phase State Machine (idle → forming → holding → dispersing)
- Customizable point size via [[point_size]] in Metal shaders
- Pure programmatic UIKit layout (no storyboards)

## Installation

1. Clone this repository:
    
    ```bash
    git clone https://github.com/your-username/ParticleNumbers.git
    
    ```
    
2. Open **ParticleNumbers.xcodeproj** in Xcode 14 or later
3. Select a Metal-compatible device or simulator (e.g., iPhone 11+)
4. Build and run (⌘ R)

## Code Structure

```
ParticleNumbers/
├── Controllers/
│   └── ViewController.swift
├── Views/
│   └── ParticleMetalView.swift
├── Shaders/
│   └── ParticleShader.metal
├── AppDelegate.swift
└── SceneDelegate.swift

```

## Technologies Used

- Swift
- UIKit (programmatic)
- MetalKit & Metal (GPU-accelerated rendering)
- Core Graphics / Core Text (text rasterization for particle targets)

## Project Goal

To showcase advanced graphics techniques on iOS by combining Metal’s raw GPU power with UIKit’s flexibility, resulting in a clean, code-driven demo of real-time particle animations forming dynamic numbers.
