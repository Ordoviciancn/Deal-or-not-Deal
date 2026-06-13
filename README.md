# Ticket Deal PC

Windows desktop GUI game simulator inspired by Deal or No Deal, with a fixed ticket cost, banker offers, mixed player behavior simulation, and long-run host-profit statistics.

中文完整介绍和 English introduction:

- [GAME_INTRO.md](GAME_INTRO.md)

## Run

```powershell
python main.py
```

No third-party runtime packages are required. The GUI uses Python's built-in Tkinter.

## Downloadable EXE

The packaged Windows executable is included at:

```text
release/TicketDealPC.exe
```

## Build EXE

```powershell
pip install pyinstaller
pyinstaller --onefile --windowed --name TicketDealPC main.py
```

The executable will be created under:

```text
dist/TicketDealPC.exe
```

## Project Structure

- `game/`: core game rules and data models
- `simulation/`: automated long-run simulation and player strategy models
- `ui/`: desktop GUI screens and reusable widgets
- `tests/`: lightweight rule tests
- `release/`: packaged Windows executable
