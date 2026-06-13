import tkinter as tk
from tkinter import ttk

from game.formatting import format_money

from . import theme


class StatCard(ttk.Frame):
    def __init__(self, parent: tk.Widget, label: str, value: str = "") -> None:
        super().__init__(parent, style="Card.TFrame", padding=14)
        self.label_var = tk.StringVar(value=label)
        self.value_var = tk.StringVar(value=value)

        ttk.Label(self, textvariable=self.label_var, style="Muted.TLabel").pack(
            anchor="w"
        )
        ttk.Label(self, textvariable=self.value_var, style="Stat.TLabel").pack(
            anchor="w", pady=(5, 0)
        )

    def set_value(self, value: str) -> None:
        self.value_var.set(value)


class AmountBoard(ttk.Frame):
    def __init__(self, parent: tk.Widget, prize_pool: tuple[int, ...]) -> None:
        super().__init__(parent, style="Card.TFrame", padding=14)
        self._labels: dict[int, ttk.Label] = {}
        self._prize_pool = prize_pool

        ttk.Label(self, text="Remaining Amounts", style="Section.TLabel").grid(
            row=0, column=0, columnspan=2, sticky="w", pady=(0, 10)
        )
        for index, amount in enumerate(prize_pool):
            label = ttk.Label(
                self,
                text=format_money(amount),
                style="AmountLive.TLabel",
                anchor="center",
                padding=(6, 4),
            )
            label.grid(
                row=index // 2 + 1,
                column=index % 2,
                sticky="ew",
                padx=4,
                pady=3,
            )
            self._labels[amount] = label

        self.columnconfigure(0, weight=1)
        self.columnconfigure(1, weight=1)

    def update_remaining(self, remaining_amounts: list[int]) -> None:
        remaining = set(remaining_amounts)
        for amount in self._prize_pool:
            self._labels[amount].configure(
                style="AmountLive.TLabel"
                if amount in remaining
                else "AmountGone.TLabel"
            )


def configure_styles(root: tk.Tk) -> None:
    style = ttk.Style(root)
    style.theme_use("clam")
    root.configure(bg=theme.BG)

    style.configure("TFrame", background=theme.BG)
    style.configure("Card.TFrame", background=theme.PANEL, relief="solid", borderwidth=1)
    style.configure("TLabel", background=theme.BG, foreground=theme.TEXT)
    style.configure("Card.TLabel", background=theme.PANEL, foreground=theme.TEXT)
    style.configure(
        "Title.TLabel",
        background=theme.BG,
        foreground=theme.TEXT,
        font=("Segoe UI", 24, "bold"),
    )
    style.configure(
        "Section.TLabel",
        background=theme.PANEL,
        foreground=theme.TEXT,
        font=("Segoe UI", 12, "bold"),
    )
    style.configure(
        "Muted.TLabel",
        background=theme.PANEL,
        foreground=theme.MUTED,
        font=("Segoe UI", 9),
    )
    style.configure(
        "Stat.TLabel",
        background=theme.PANEL,
        foreground=theme.TEXT,
        font=("Segoe UI", 16, "bold"),
    )
    style.configure(
        "AmountLive.TLabel",
        background="#f2fbf7",
        foreground=theme.TEXT,
        font=("Segoe UI", 10, "bold"),
    )
    style.configure(
        "AmountGone.TLabel",
        background="#eeeeee",
        foreground="#9aa3a0",
        font=("Segoe UI", 10, "overstrike"),
    )
    style.configure(
        "Primary.TButton",
        background=theme.PRIMARY,
        foreground="white",
        font=("Segoe UI", 11, "bold"),
        padding=(12, 8),
    )
    style.map(
        "Primary.TButton",
        background=[("active", theme.PRIMARY_DARK), ("disabled", "#9bb8b0")],
    )
    style.configure("TButton", font=("Segoe UI", 10), padding=(10, 7))
