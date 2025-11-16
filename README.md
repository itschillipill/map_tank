# Tank RenderObject Demo

- A high-performance Flutter demo showcasing custom animation and rendering using a custom RenderObject.
The project implements a simple tank scene with:

- Direct RenderObject-based drawing for maximum performance

- Tap-to-shoot mechanics

- Bullet spawning

- Smooth animations without widgets

- Performance profiling via Flutter DevTools

This project is intended as an experiment in writing low-level, optimized graphics in Flutter.

## Features

1. Custom RenderBox for tanks and bullets

2. No widgets for rendering — everything drawn with Canvas

3. Frame-accurate movement updates

4. Handles thousands of objects with minimal lag

5. Suitable for studying Flutter’s rendering pipeline

Getting Started
```bash
flutter run
```