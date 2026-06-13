from dataclasses import dataclass
from enum import Enum, auto


class CaseStatus(Enum):
    CLOSED = auto()
    SELECTED = auto()
    OPENED = auto()


class GamePhase(Enum):
    CHOOSING_PLAYER_CASE = auto()
    OPENING_CASES = auto()
    BANKER_OFFER = auto()
    FINAL_CHOICE = auto()
    FINISHED = auto()


@dataclass(frozen=True)
class GameCase:
    number: int
    amount: int
    status: CaseStatus = CaseStatus.CLOSED


@dataclass(frozen=True)
class GameResult:
    awarded_amount: int
    ticket_cost: int
    reason: str

    @property
    def player_net_profit(self) -> int:
        return self.awarded_amount - self.ticket_cost

    @property
    def host_profit(self) -> int:
        return self.ticket_cost - self.awarded_amount
