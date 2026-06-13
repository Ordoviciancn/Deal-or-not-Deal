from .config import GameConfig


class Banker:
    def __init__(self, config: GameConfig | None = None) -> None:
        self._config = config or GameConfig()

    def make_offer(
        self,
        unopened_amounts: list[int],
        completed_offer_rounds: int,
    ) -> int:
        if not unopened_amounts:
            return 0

        discount_index = min(
            completed_offer_rounds,
            len(self._config.offer_discounts) - 1,
        )
        average = sum(unopened_amounts) / len(unopened_amounts)
        return max(0, round(average * self._config.offer_discounts[discount_index]))
