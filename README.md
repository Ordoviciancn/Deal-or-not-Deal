# Ticket Deal PC

Ticket Deal PC is a desktop GUI game simulator inspired by Deal or No Deal. It adds a fixed ticket cost, banker offers, mixed player-behavior simulation, and long-run host-profit statistics.

中文和 English 完整介绍：

- [GAME_INTRO.md](GAME_INTRO.md)

## Windows 桌面版 / Windows Desktop Version

运行源码：

```powershell
python main.py
```

无需第三方运行时依赖，图形界面基于 Python 内置 Tkinter。

已打包的 Windows 可执行文件：

```text
release/TicketDealPC.exe
```

## 安卓 APK / Android APK

Flutter 安卓版本位于：

```text
flutter_android/
```

当前不需要本地安装 Flutter。APK 通过 GitHub Actions 云端构建。

下载 APK：

1. 打开 [Build Flutter APK Actions](https://github.com/Ordoviciancn/Deal-or-not-Deal/actions/workflows/build-flutter-apk.yml)
2. 选择最新成功的 workflow run
3. 在页面底部找到 `Artifacts`
4. 下载 `ticket-deal-release-apk`
5. 解压后得到 `app-release.apk`

最近一次成功构建：

- [Build Flutter APK run #6](https://github.com/Ordoviciancn/Deal-or-not-Deal/actions/runs/27470685384)

## 本地打包 EXE / Build EXE Locally

```powershell
pip install pyinstaller
pyinstaller --onefile --windowed --name TicketDealPC main.py
```

生成文件：

```text
dist/TicketDealPC.exe
```

## Project Structure

- `game/`: core game rules and data models
- `simulation/`: automated long-run simulation and player strategy models
- `ui/`: desktop GUI screens and reusable widgets
- `tests/`: lightweight rule tests
- `release/`: packaged Windows executable
- `flutter_android/`: Flutter Android APK project
- `.github/workflows/`: GitHub Actions APK build workflow
