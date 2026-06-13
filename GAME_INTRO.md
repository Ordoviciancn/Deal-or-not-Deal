# Ticket Deal PC / 门票版开箱交易游戏

## 中文介绍

**Ticket Deal PC** 是一个受《Deal or No Deal》启发的桌面图形化模拟游戏。玩家每局先支付固定门票 `$100,000`，然后从 26 个箱子中选择自己的箱子，并按照轮次逐步打开其他箱子。每一轮结束后，银行家会根据剩余未打开金额给出报价，玩家可以选择接受报价立即结束游戏，也可以继续开箱。

这个版本的核心特点是加入了门票成本和主办方收益模型，因此它不仅是一个小游戏，也可以用来观察不同玩家心理策略下的长期收益率。

### 游戏规则

- 每局有 26 个箱子，编号 `1-26`。
- 每局开始时玩家支付门票 `$100,000`。
- 门票不进入奖池，也不会返还。
- 金额池包含 `$1` 到 `$1,000,000` 的 26 个金额。
- 每局开始时，系统会随机把金额分配到 26 个箱子。
- 玩家先选择一个自己的箱子，该箱子暂不打开。
- 开箱节奏为：`6, 5, 4, 3, 2, 1, 1, 1, 1`。
- 每轮开完指定数量箱子后，银行家给出报价。
- 玩家可以选择 `Deal`，立即获得报价并结束游戏。
- 玩家也可以选择 `No Deal`，继续开箱。
- 当只剩玩家自己的箱子和最后一个未打开箱子时，玩家可以选择保留或交换。

### 结算公式

```text
玩家净收益 = 玩家获得金额 - 100,000
主办方收益 = 100,000 - 玩家获得金额
```

### 当前报价逻辑

```text
银行家报价 = 剩余未打开金额平均值 × 1.19
```

这个系数是为了让长期主办方收益率接近 5% 左右而设置的。由于玩家策略、随机分配和开箱过程都会影响结果，实际模拟收益率会围绕目标值波动。

### 玩家类型模拟

模拟器支持按比例混合不同玩家心理：

```text
保守型 Conservative: 20%
止损型 Loss cutter: 35%
回本型 Break-even: 25%
激进型 Aggressive: 15%
赌徒型 Gambler: 5%
```

这些类型分别代表不同 Deal 心态：

- **保守型**：报价能回收较大部分门票时就容易接受。
- **止损型**：亏损时会在报价还不错时及时止损。
- **回本型**：报价超过门票才接受。
- **激进型**：需要明显盈利或高性价比报价才接受。
- **赌徒型**：倾向继续开到后期，只有很高报价才接受。

### 图形界面功能

- 桌面图形化界面，基于 Python Tkinter。
- 显示 26 个箱子按钮。
- 显示剩余金额列表。
- 显示当前轮次、门票成本、玩家选择箱子。
- Deal 后展示最终收益。
- Deal 后揭晓所有箱子的内部金额。
- 支持运行 `1,000` / `10,000` / `100,000` 局自动模拟。
- 显示主办方长期平均收益、收益率、Deal 率和分类型玩家收益。

### 运行方式

```powershell
python main.py
```

### 打包为 Windows EXE

```powershell
pip install pyinstaller
pyinstaller --onefile --windowed --name TicketDealPC main.py
```

生成文件位于：

```text
dist\TicketDealPC.exe
```

---

## English Introduction

**Ticket Deal PC** is a desktop GUI game simulator inspired by *Deal or No Deal*. At the beginning of each game, the player pays a fixed ticket cost of `$100,000`, chooses one personal case, and then opens the remaining cases round by round. After each round, the banker makes an offer based on the remaining unopened prize amounts. The player can accept the offer and end the game, or reject it and continue.

This version adds a ticket-cost mechanism and host-profit model, making it useful not only as a game but also as a long-run profitability simulator under different player behaviors.

### Game Rules

- Each game has 26 cases, numbered `1-26`.
- The player pays a `$100,000` ticket cost at the start of each game.
- The ticket cost does not enter the prize pool and is not refunded.
- The prize pool contains 26 amounts from `$1` to `$1,000,000`.
- At the start of each game, prize amounts are randomly assigned to the 26 cases.
- The player first chooses a personal case, which remains unopened.
- The opening schedule is: `6, 5, 4, 3, 2, 1, 1, 1, 1`.
- After each round, the banker makes an offer.
- The player may choose `Deal` to accept the offer and end the game.
- The player may choose `No Deal` to continue opening cases.
- When only the player's case and one other unopened case remain, the player may keep or swap.

### Settlement Formula

```text
Player net profit = Player award - 100,000
Host profit = 100,000 - Player award
```

### Current Banker Offer Logic

```text
Banker offer = Average of remaining unopened amounts × 1.19
```

The multiplier is tuned so that the host's long-run profit rate is around 5%, depending on player behavior and random game outcomes.

### Mixed Player Simulation

The simulator supports a mixed player population:

```text
Conservative: 20%
Loss cutter: 35%
Break-even: 25%
Aggressive: 15%
Gambler: 5%
```

Player behavior types:

- **Conservative**: likely to accept once the offer recovers a large portion of the ticket cost.
- **Loss cutter**: accepts reasonable loss-cutting offers when the board gets worse.
- **Break-even**: accepts only when the offer is above the ticket cost.
- **Aggressive**: requires clear upside or a strong value offer.
- **Gambler**: tends to continue unless the offer is very high.

### GUI Features

- Desktop GUI built with Python Tkinter.
- 26 interactive case buttons.
- Remaining prize amount board.
- Current round, ticket cost, and selected player case display.
- Final result display after Deal or final choice.
- Reveals all case amounts after a Deal.
- Supports `1,000` / `10,000` / `100,000` game simulations.
- Shows long-run host profit, host profit rate, Deal rate, and per-player-type profitability.

### Run

```powershell
python main.py
```

### Build Windows EXE

```powershell
pip install pyinstaller
pyinstaller --onefile --windowed --name TicketDealPC main.py
```

The generated executable will be located at:

```text
dist\TicketDealPC.exe
```
