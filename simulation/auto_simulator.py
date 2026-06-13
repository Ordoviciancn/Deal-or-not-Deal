import random

from game import CaseStatus, GameConfig, GamePhase, GameSession

from .models import SimulationResult
from .player_strategy import (
    DEFAULT_PLAYER_MIX,
    PlayerMix,
    PlayerType,
    choose_player_type,
    should_accept_offer,
)


class AutoSimulator:
    def __init__(self, rng: random.Random | None = None) -> None:
        self._rng = rng or random.Random()

    def run(
        self,
        games: int,
        player_mix: tuple[PlayerMix, ...] = DEFAULT_PLAYER_MIX,
    ) -> SimulationResult:
        config = GameConfig()
        total_host_profit = 0
        total_player_award = 0
        deal_count = 0
        final_choice_count = 0
        player_type_counts = {player_type: 0 for player_type in PlayerType}
        player_type_host_profit = {player_type: 0 for player_type in PlayerType}

        for _ in range(games):
            player_type = choose_player_type(self._rng, player_mix)
            player_type_counts[player_type] += 1
            session = GameSession(config=config, rng=self._rng)
            player_pick = self._rng.randint(1, config.case_count)
            session.choose_player_case(player_pick)

            while session.phase == GamePhase.OPENING_CASES:
                candidates = [
                    case
                    for case in session.cases
                    if case.status == CaseStatus.CLOSED
                ]
                pick = self._rng.choice(candidates)
                session.open_case(pick.number)

                if session.phase == GamePhase.BANKER_OFFER:
                    if should_accept_offer(session, player_type, config):
                        result = session.accept_offer()
                        total_host_profit += result.host_profit
                        total_player_award += result.awarded_amount
                        player_type_host_profit[player_type] += result.host_profit
                        deal_count += 1
                        break
                    session.reject_offer()

            if session.phase == GamePhase.FINAL_CHOICE:
                result = (
                    session.keep_player_case()
                    if self._rng.choice((True, False))
                    else session.swap_player_case()
                )
                total_host_profit += result.host_profit
                total_player_award += result.awarded_amount
                player_type_host_profit[player_type] += result.host_profit
                final_choice_count += 1

        return SimulationResult(
            games=games,
            total_host_profit=total_host_profit,
            total_player_award=total_player_award,
            deal_count=deal_count,
            final_choice_count=final_choice_count,
            player_type_counts=player_type_counts,
            player_type_host_profit=player_type_host_profit,
        )
