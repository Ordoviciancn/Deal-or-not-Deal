# Ticket Deal PC

Windows desktop GUI version of the Ticket Deal game.

## Run

```powershell
cd "C:\Users\felix\Documents\Codex project\ticket_deal_pc"
python main.py
```

No third-party packages are required. The GUI uses Python's built-in Tkinter.

## Build EXE

Optional:

```powershell
pip install pyinstaller
pyinstaller --onefile --windowed --name TicketDealPC main.py
```

The executable will be created under `dist\TicketDealPC.exe`.

## Structure

- `game/`: game rules and data models
- `simulation/`: automated long-run simulation
- `ui/`: desktop GUI screens and reusable widgets
- `tests/`: lightweight rule tests
