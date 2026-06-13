from dataclasses import dataclass

from .player_strategy import PlayerType


@dataclass(frozen=True)
class SimulationResult:
    games: int
    total_host_profit: int
    total_player_award: int
    deal_count: int
    final_choice_count: int
    player_type_counts: dict[PlayerType, int]
    player_type_host_profit: dict[PlayerType, int]

    @property
    def average_host_profit(self) -> float:
        return self.total_host_profit / self.games

    @property
    def average_player_award(self) -> float:
        return self.total_player_award / self.games

    @property
    def deal_rate(self) -> float:
        return self.deal_count / self.games

    def average_host_profit_for(self, player_type: PlayerType) -> float:
        count = self.player_type_counts.get(player_type, 0)
        if count == 0:
            return 0.0
        return self.player_type_host_profit.get(player_type, 0) / count
