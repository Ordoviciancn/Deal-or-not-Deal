def format_money(amount: int | float) -> str:
    rounded = int(round(amount))
    sign = "-" if rounded < 0 else ""
    return f"{sign}${abs(rounded):,}"
