from dataclasses import dataclass
from enum import Enum
from random import Random

from game import GameConfig, GameSession


class PlayerType(Enum):
    CONSERVATIVE = "Conservative"
    LOSS_CUTTER = "Loss cutter"
    BREAK_EVEN = "Break-even"
    AGGRESSIVE = "Aggressive"
    GAMBLER = "Gambler"


@dataclass(frozen=True)
class PlayerMix:
    player_type: PlayerType
    weight: float


DEFAULT_PLAYER_MIX: tuple[PlayerMix, ...] = (
    PlayerMix(PlayerType.CONSERVATIVE, 0.20),
    PlayerMix(PlayerType.LOSS_CUTTER, 0.35),
    PlayerMix(PlayerType.BREAK_EVEN, 0.25),
    PlayerMix(PlayerType.AGGRESSIVE, 0.15),
    PlayerMix(PlayerType.GAMBLER, 0.05),
)


def choose_player_type(rng: Random, mix: tuple[PlayerMix, ...]) -> PlayerType:
    total_weight = sum(item.weight for item in mix)
    roll = rng.random() * total_weight
    cumulative = 0.0

    for item in mix:
        cumulative += item.weight
        if roll <= cumulative:
            return item.player_type

    return mix[-1].player_type


def should_accept_offer(
    session: GameSession,
    player_type: PlayerType,
    config: GameConfig | None = None,
) -> bool:
    config = config or GameConfig()
    offer = session.current_offer or 0
    ticket = config.ticket_cost
    remaining = session.remaining_amounts
    expected_value = sum(remaining) / len(remaining)
    max_remaining = max(remaining)
    recovery_ratio = offer / ticket
    value_ratio = offer / expected_value
    high_prizes_left = sum(
        1
        for amount in (100_000, 250_000, 500_000, 1_000_000)
        if amount in remaining
    )

    if player_type == PlayerType.CONSERVATIVE:
        return (
            recovery_ratio >= 0.85
            or (recovery_ratio >= 0.65 and value_ratio >= 0.85)
            or (len(remaining) <= 8 and recovery_ratio >= 0.55)
        )

    if player_type == PlayerType.LOSS_CUTTER:
        return (
            offer >= ticket
            or (recovery_ratio >= 0.70 and value_ratio >= 0.85)
            or (recovery_ratio >= 0.60 and high_prizes_left <= 1)
            or (len(remaining) <= 5 and recovery_ratio >= 0.50)
            or (recovery_ratio >= 0.65 and max_remaining <= ticket * 2.5)
        )

    if player_type == PlayerType.BREAK_EVEN:
        return offer > ticket

    if player_type == PlayerType.AGGRESSIVE:
        return (
            offer >= ticket * 1.25
            or (value_ratio >= 1.05 and recovery_ratio >= 0.95)
            or (len(remaining) <= 3 and recovery_ratio >= 0.80)
        )

    if player_type == PlayerType.GAMBLER:
        return offer >= ticket * 1.75 or (
            len(remaining) <= 2 and recovery_ratio >= 1.10
        )

    return False


def describe_mix(mix: tuple[PlayerMix, ...]) -> str:
    total_weight = sum(item.weight for item in mix)
    return ", ".join(
        f"{item.player_type.value} {item.weight / total_weight * 100:.0f}%"
        for item in mix
    )
