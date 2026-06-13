# Ticket Deal Simulator

A Flutter Android game simulator inspired by Deal or No Deal, with a fixed ticket cost and long-run host-profit simulation.

## Run

```bash
flutter pub get
flutter run
```

The app is organized for maintenance:

- `lib/game/`: core game rules and data models
- `lib/simulation/`: automated simulation logic
- `lib/screens/`: app pages
- `lib/widgets/`: reusable UI widgets

If Android platform files need to be refreshed for your installed Flutter version, run:

```bash
flutter create --platforms=android .
```
