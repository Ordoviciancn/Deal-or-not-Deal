from dataclasses import dataclass


@dataclass(frozen=True)
class GameConfig:
    case_count: int = 26
    ticket_cost: int = 100_000
    prize_pool: tuple[int, ...] = (
        1,
        5,
        10,
        25,
        50,
        75,
        100,
        200,
        300,
        500,
        750,
        1_000,
        2_000,
        3_000,
        5_000,
        7_500,
        10_000,
        15_000,
        20_000,
        30_000,
        50_000,
        75_000,
        100_000,
        250_000,
        500_000,
        1_000_000,
    )
    opening_schedule: tuple[int, ...] = (6, 5, 4, 3, 2, 1, 1, 1, 1)
    offer_discounts: tuple[float, ...] = (
        1.19,
        1.19,
        1.19,
        1.19,
        1.19,
        1.19,
        1.19,
        1.19,
    )

    @property
    def max_prize(self) -> int:
        return self.prize_pool[-1]
