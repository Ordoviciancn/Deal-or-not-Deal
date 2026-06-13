from game import GameConfig, GamePhase, GameSession
from game.banker import Banker
from game.formatting import format_money
from game.models import GameResult


def test_money_formatting() -> None:
    assert format_money(100000) == "$100,000"
    assert format_money(-25000) == "-$25,000"


def test_banker_offer_uses_average_and_discount() -> None:
    offer = Banker().make_offer([100, 300], completed_offer_rounds=0)
    assert offer == 238


def test_new_session_has_full_pool() -> None:
    session = GameSession()
    assert len(session.cases) == GameConfig().case_count
    assert session.remaining_amounts == list(GameConfig().prize_pool)
    assert session.phase == GamePhase.CHOOSING_PLAYER_CASE


def test_ticket_economics() -> None:
    result = GameResult(
        awarded_amount=250_000,
        ticket_cost=100_000,
        reason="test",
    )
    assert result.player_net_profit == 150_000
    assert result.host_profit == -150_000
