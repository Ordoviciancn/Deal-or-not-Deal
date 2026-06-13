import random
from dataclasses import replace

from .banker import Banker
from .config import GameConfig
from .models import CaseStatus, GameCase, GamePhase, GameResult


class GameSession:
    def __init__(
        self,
        config: GameConfig | None = None,
        rng: random.Random | None = None,
        banker: Banker | None = None,
    ) -> None:
        self.config = config or GameConfig()
        self._rng = rng or random.Random()
        self._banker = banker or Banker(self.config)
        self.reset()

    def reset(self) -> None:
        amounts = list(self.config.prize_pool)
        self._rng.shuffle(amounts)
        self.cases = [
            GameCase(number=index + 1, amount=amount)
            for index, amount in enumerate(amounts)
        ]
        self.player_case_number: int | None = None
        self.round_index = 0
        self.opened_this_round = 0
        self.offer_rounds_completed = 0
        self.current_offer: int | None = None
        self.phase = GamePhase.CHOOSING_PLAYER_CASE
        self.result: GameResult | None = None

    @property
    def round_number(self) -> int:
        return self.round_index + 1

    @property
    def boxes_to_open_this_round(self) -> int:
        if self.round_index >= len(self.config.opening_schedule):
            return self.config.opening_schedule[-1]
        return self.config.opening_schedule[self.round_index]

    @property
    def boxes_remaining_this_round(self) -> int:
        return max(0, self.boxes_to_open_this_round - self.opened_this_round)

    @property
    def remaining_amounts(self) -> list[int]:
        return sorted(
            case.amount for case in self.cases if case.status != CaseStatus.OPENED
        )

    @property
    def final_unopened_non_player_cases(self) -> list[GameCase]:
        return [
            case
            for case in self.cases
            if case.status == CaseStatus.CLOSED
            and case.number != self.player_case_number
        ]

    def choose_player_case(self, case_number: int) -> None:
        self._ensure_phase(GamePhase.CHOOSING_PLAYER_CASE)
        self._set_case_status(case_number, CaseStatus.SELECTED)
        self.player_case_number = case_number
        self.phase = GamePhase.OPENING_CASES

    def open_case(self, case_number: int) -> int:
        self._ensure_phase(GamePhase.OPENING_CASES)
        selected_case = self._case_by_number(case_number)
        if selected_case.status != CaseStatus.CLOSED:
            raise ValueError("Only closed non-player cases can be opened.")

        self._set_case_status(case_number, CaseStatus.OPENED)
        self.opened_this_round += 1

        if self._should_enter_final_choice():
            self.phase = GamePhase.FINAL_CHOICE
            return selected_case.amount

        if self.opened_this_round >= self.boxes_to_open_this_round:
            self.current_offer = self._banker.make_offer(
                self.remaining_amounts,
                self.offer_rounds_completed,
            )
            self.offer_rounds_completed += 1
            self.phase = GamePhase.BANKER_OFFER

        return selected_case.amount

    def reject_offer(self) -> None:
        self._ensure_phase(GamePhase.BANKER_OFFER)
        self.current_offer = None
        self.round_index += 1
        self.opened_this_round = 0
        self.phase = (
            GamePhase.FINAL_CHOICE
            if self._should_enter_final_choice()
            else GamePhase.OPENING_CASES
        )

    def accept_offer(self) -> GameResult:
        self._ensure_phase(GamePhase.BANKER_OFFER)
        return self._finish(self.current_offer or 0, "Deal accepted")

    def keep_player_case(self) -> GameResult:
        self._ensure_phase(GamePhase.FINAL_CHOICE)
        player_case = self._case_by_number(self.player_case_number or -1)
        return self._finish(player_case.amount, "Kept original case")

    def swap_player_case(self) -> GameResult:
        self._ensure_phase(GamePhase.FINAL_CHOICE)
        other_cases = self.final_unopened_non_player_cases
        if len(other_cases) != 1:
            raise ValueError("Swap requires exactly one other closed case.")
        return self._finish(other_cases[0].amount, "Swapped final case")

    def _finish(self, awarded_amount: int, reason: str) -> GameResult:
        self.phase = GamePhase.FINISHED
        self.result = GameResult(
            awarded_amount=awarded_amount,
            ticket_cost=self.config.ticket_cost,
            reason=reason,
        )
        return self.result

    def _should_enter_final_choice(self) -> bool:
        unopened_count = sum(
            1 for case in self.cases if case.status != CaseStatus.OPENED
        )
        return self.player_case_number is not None and unopened_count == 2

    def _case_by_number(self, case_number: int) -> GameCase:
        for case in self.cases:
            if case.number == case_number:
                return case
        raise ValueError(f"Case {case_number} does not exist.")

    def _set_case_status(self, case_number: int, status: CaseStatus) -> None:
        self.cases = [
            replace(case, status=status) if case.number == case_number else case
            for case in self.cases
        ]

    def _ensure_phase(self, expected: GamePhase) -> None:
        if self.phase != expected:
            raise RuntimeError(f"Expected phase {expected}, found {self.phase}.")
