# Ticket Deal

Ticket Deal is a game simulator inspired by Deal or No Deal. It adds a fixed ticket cost, banker offers, mixed player-behavior simulation, and long-run host-profit statistics.

This repository contains two playable versions:

- **Windows PC version**: a Python Tkinter desktop GUI app.
- **Android version**: a Flutter APK built by GitHub Actions.

中文和 English 完整介绍：

- [GAME_INTRO.md](GAME_INTRO.md)

## 快速下载 / Quick Download

- **Windows PC**: download or run `release/TicketDealPC.exe`.
- **Android APK**: open the latest successful [Build Flutter APK](https://github.com/Ordoviciancn/Deal-or-not-Deal/actions/workflows/build-flutter-apk.yml) run and download the `ticket-deal-release-apk` artifact.

## 版本总览 / Versions

| Version | Platform | Location | How to use |
| --- | --- | --- | --- |
| PC desktop | Windows | `release/TicketDealPC.exe` / `main.py` | Run the EXE or run `python main.py` |
| Android APK | Android phones | GitHub Actions artifact | Download `ticket-deal-release-apk` and install `app-release.apk` |

## Windows 桌面版 / Windows Desktop Version

PC 版适合在 Windows 上测试完整图形界面和模拟统计功能。

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

安卓版适合安装到安卓手机上试玩。项目源码位于 Flutter 子目录：

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

如果 artifact 过期，可以打开 `Actions` 页面重新运行 `Build Flutter APK` workflow。

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
