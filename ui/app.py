import queue
import threading
import tkinter as tk
from tkinter import messagebox, ttk

from game import CaseStatus, GameConfig, GameResult, GameSession
from game.formatting import format_money
from simulation import (
    DEFAULT_PLAYER_MIX,
    AutoSimulator,
    PlayerType,
    SimulationResult,
    describe_mix,
)

from .widgets import AmountBoard, StatCard, configure_styles


class TicketDealApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Ticket Deal PC")
        self.geometry("1180x760")
        self.minsize(980, 680)
        configure_styles(self)

        self.config_data = GameConfig()
        self.session = GameSession(self.config_data)
        self.case_buttons: dict[int, ttk.Button] = {}
        self.sim_queue: queue.Queue[SimulationResult] = queue.Queue()

        self._build_layout()
        self._refresh()

    def _build_layout(self) -> None:
        self.columnconfigure(0, weight=1)
        self.rowconfigure(1, weight=1)

        header = ttk.Frame(self, padding=(20, 18, 20, 8))
        header.grid(row=0, column=0, sticky="ew")
        header.columnconfigure(0, weight=1)

        ttk.Label(header, text="Ticket Deal PC", style="Title.TLabel").grid(
            row=0, column=0, sticky="w"
        )
        ttk.Button(
            header,
            text="New Game",
            style="Primary.TButton",
            command=self._new_game,
        ).grid(row=0, column=1, sticky="e")

        main = ttk.Frame(self, padding=(20, 8, 20, 20))
        main.grid(row=1, column=0, sticky="nsew")
        main.columnconfigure(0, weight=0)
        main.columnconfigure(1, weight=1)
        main.columnconfigure(2, weight=0)
        main.rowconfigure(0, weight=1)

        self.left_panel = ttk.Frame(main, style="Card.TFrame", padding=14)
        self.left_panel.grid(row=0, column=0, sticky="nsw", padx=(0, 12))

        self.ticket_card = StatCard(
            self.left_panel,
            "Ticket Cost",
            format_money(self.config_data.ticket_cost),
        )
        self.ticket_card.pack(fill="x", pady=(0, 10))
        self.round_card = StatCard(self.left_panel, "Round", "1")
        self.round_card.pack(fill="x", pady=(0, 10))
        self.status_card = StatCard(self.left_panel, "Status", "Choose your case")
        self.status_card.pack(fill="x", pady=(0, 10))
        self.player_case_card = StatCard(self.left_panel, "Your Case", "-")
        self.player_case_card.pack(fill="x", pady=(0, 18))

        ttk.Label(
            self.left_panel,
            text="Simulation",
            style="Section.TLabel",
        ).pack(anchor="w", pady=(0, 10))
        for games in (1_000, 10_000, 100_000):
            ttk.Button(
                self.left_panel,
                text=f"Run {games:,} games",
                command=lambda value=games: self._run_simulation(value),
            ).pack(fill="x", pady=4)

        self.sim_result_label = ttk.Label(
            self.left_panel,
            text=f"Player mix: {describe_mix(DEFAULT_PLAYER_MIX)}",
            style="Muted.TLabel",
            wraplength=220,
            justify="left",
        )
        self.sim_result_label.pack(fill="x", pady=(12, 0))

        center = ttk.Frame(main, style="Card.TFrame", padding=16)
        center.grid(row=0, column=1, sticky="nsew", padx=12)
        for col in range(6):
            center.columnconfigure(col, weight=1)

        ttk.Label(
            center,
            text="Cases",
            style="Section.TLabel",
        ).grid(row=0, column=0, columnspan=6, sticky="w", pady=(0, 12))

        for index in range(self.config_data.case_count):
            number = index + 1
            button = ttk.Button(
                center,
                text=f"#{number}",
                command=lambda value=number: self._handle_case_click(value),
            )
            button.grid(
                row=index // 6 + 1,
                column=index % 6,
                sticky="nsew",
                padx=5,
                pady=5,
                ipady=12,
            )
            self.case_buttons[number] = button

        self.amount_board = AmountBoard(main, self.config_data.prize_pool)
        self.amount_board.grid(row=0, column=2, sticky="nse", padx=(12, 0))

    def _new_game(self) -> None:
        self.session = GameSession(self.config_data)
        self._refresh()

    def _handle_case_click(self, case_number: int) -> None:
        if self.session.phase.name == "CHOOSING_PLAYER_CASE":
            self.session.choose_player_case(case_number)
            self._refresh()
            return

        if self.session.phase.name != "OPENING_CASES":
            return

        selected_case = next(
            case for case in self.session.cases if case.number == case_number
        )
        if selected_case.status != CaseStatus.CLOSED:
            return

        amount = self.session.open_case(case_number)
        self._refresh()
        messagebox.showinfo("Case Opened", f"Case #{case_number}: {format_money(amount)}")

        if self.session.phase.name == "BANKER_OFFER":
            self._show_banker_offer()
        elif self.session.phase.name == "FINAL_CHOICE":
            self._show_final_choice()

    def _show_banker_offer(self) -> None:
        offer = self.session.current_offer or 0
        net = offer - self.config_data.ticket_cost
        answer = messagebox.askyesno(
            "Banker Offer",
            "Banker offer: "
            f"{format_money(offer)}\n"
            f"Net after ticket: {format_money(net)}\n\n"
            "Choose Yes for Deal, No for No Deal.",
        )
        if answer:
            self._finish(self.session.accept_offer(), reveal_all_cases=True)
        else:
            self.session.reject_offer()
            self._refresh()

    def _show_final_choice(self) -> None:
        other_case = self.session.final_unopened_non_player_cases[0]
        answer = messagebox.askyesno(
            "Final Choice",
            f"Your case #{self.session.player_case_number} and case "
            f"#{other_case.number} remain.\n\n"
            "Choose Yes to keep your case, No to swap.",
        )
        result = (
            self.session.keep_player_case()
            if answer
            else self.session.swap_player_case()
        )
        self._finish(result)

    def _finish(self, result: GameResult, reveal_all_cases: bool = False) -> None:
        self._refresh()
        if reveal_all_cases:
            self._reveal_case_buttons()
        messagebox.showinfo(
            "Game Result",
            f"{result.reason}\n\n"
            f"Awarded Amount: {format_money(result.awarded_amount)}\n"
            f"Ticket Cost: {format_money(result.ticket_cost)}\n"
            f"Player Net Profit: {format_money(result.player_net_profit)}\n"
            f"Host Profit: {format_money(result.host_profit)}",
        )
        if reveal_all_cases:
            self._show_all_cases_dialog()

    def _reveal_case_buttons(self) -> None:
        for case in self.session.cases:
            marker = " YOUR" if case.number == self.session.player_case_number else ""
            self.case_buttons[case.number].configure(
                text=f"#{case.number}{marker}\n{format_money(case.amount)}",
                state="disabled",
            )

    def _show_all_cases_dialog(self) -> None:
        dialog = tk.Toplevel(self)
        dialog.title("All Case Amounts")
        dialog.transient(self)
        dialog.grab_set()
        dialog.configure(bg=self["bg"])
        dialog.resizable(False, False)

        frame = ttk.Frame(dialog, style="Card.TFrame", padding=16)
        frame.grid(row=0, column=0, sticky="nsew")
        ttk.Label(
            frame,
            text="All Case Amounts",
            style="Section.TLabel",
        ).grid(row=0, column=0, columnspan=4, sticky="w", pady=(0, 12))

        sorted_cases = sorted(self.session.cases, key=lambda case: case.number)
        for index, case in enumerate(sorted_cases):
            label = f"#{case.number}: {format_money(case.amount)}"
            if case.number == self.session.player_case_number:
                label += "  (Your case)"
            ttk.Label(
                frame,
                text=label,
                style="Card.TLabel",
                padding=(8, 4),
            ).grid(
                row=index // 4 + 1,
                column=index % 4,
                sticky="w",
                padx=8,
                pady=3,
            )

        ttk.Button(
            frame,
            text="Close",
            style="Primary.TButton",
            command=dialog.destroy,
        ).grid(row=8, column=0, columnspan=4, pady=(14, 0))

        dialog.update_idletasks()
        x = self.winfo_rootx() + (self.winfo_width() - dialog.winfo_width()) // 2
        y = self.winfo_rooty() + (self.winfo_height() - dialog.winfo_height()) // 2
        dialog.geometry(f"+{max(x, 0)}+{max(y, 0)}")

    def _run_simulation(self, games: int) -> None:
        self.sim_result_label.configure(text=f"Running {games:,} games...")

        def worker() -> None:
            self.sim_queue.put(AutoSimulator().run(games))

        threading.Thread(target=worker, daemon=True).start()
        self.after(100, self._poll_simulation)

    def _poll_simulation(self) -> None:
        try:
            result = self.sim_queue.get_nowait()
        except queue.Empty:
            self.after(100, self._poll_simulation)
            return

        self.sim_result_label.configure(
            text=(
                f"Games: {result.games:,}\n"
                f"Player mix: {describe_mix(DEFAULT_PLAYER_MIX)}\n"
                f"Average host profit: {format_money(result.average_host_profit)}\n"
                "Host profit rate: "
                f"{result.average_host_profit / self.config_data.ticket_cost * 100:.2f}%\n"
                f"Average player award: {format_money(result.average_player_award)}\n"
                f"Deal rate: {result.deal_rate * 100:.1f}%\n"
                "By type:\n"
                f"Conservative: {format_money(result.average_host_profit_for(PlayerType.CONSERVATIVE))}\n"
                f"Loss cutter: {format_money(result.average_host_profit_for(PlayerType.LOSS_CUTTER))}\n"
                f"Break-even: {format_money(result.average_host_profit_for(PlayerType.BREAK_EVEN))}\n"
                f"Aggressive: {format_money(result.average_host_profit_for(PlayerType.AGGRESSIVE))}\n"
                f"Gambler: {format_money(result.average_host_profit_for(PlayerType.GAMBLER))}"
            )
        )

    def _refresh(self) -> None:
        self.round_card.set_value(str(self.session.round_number))
        self.player_case_card.set_value(
            "-"
            if self.session.player_case_number is None
            else f"#{self.session.player_case_number}"
        )
        self.status_card.set_value(self._status_text())
        self.amount_board.update_remaining(self.session.remaining_amounts)

        for case in self.session.cases:
            button = self.case_buttons[case.number]
            text = f"#{case.number}"
            state = "normal"
            if case.status == CaseStatus.SELECTED:
                text = f"#{case.number}\nYOUR"
            elif case.status == CaseStatus.OPENED:
                text = f"#{case.number}\n{format_money(case.amount)}"
                state = "disabled"
            button.configure(text=text, state=state)

    def _status_text(self) -> str:
        phase = self.session.phase.name
        if phase == "CHOOSING_PLAYER_CASE":
            return "Choose your case"
        if phase == "OPENING_CASES":
            return f"Open {self.session.boxes_remaining_this_round} case(s)"
        if phase == "BANKER_OFFER":
            return "Banker offer"
        if phase == "FINAL_CHOICE":
            return "Keep or swap"
        return "Finished"
