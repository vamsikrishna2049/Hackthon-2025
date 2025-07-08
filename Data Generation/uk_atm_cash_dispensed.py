import pandas as pd
import requests
from datetime import datetime, timedelta
import numpy as np

# --- Step 1: Fetch UK Public Holidays from Nager.Date API ---
def get_uk_holidays(start_year, end_year):
    holidays = []
    for year in range(start_year, end_year + 1):
        url = f"https://date.nager.at/api/v3/PublicHolidays/{year}/GB"
        resp = requests.get(url)
        if resp.status_code == 200:
            holidays += [d['date'] for d in resp.json()]
    return pd.to_datetime(holidays)

# --- Step 2: Create Date Range for Last 3 Years ---
end_date = datetime.today().date()
start_date = end_date - timedelta(days=3*365)
dates = pd.date_range(start=start_date, end=end_date)

# --- Step 3: Get UK Holiday Dates ---
uk_holidays = get_uk_holidays(start_date.year, end_date.year)

# --- Step 4: Generate Data for 50 ATMs ---
atm_ids = [f'ATM{str(i).zfill(3)}' for i in range(1, 51)]
records = []

for atm in atm_ids:
    for date in dates:
        is_salary_day = date.day == 1
        is_month_start = date.day <= 2
        is_month_end = date.day >= 28
        is_weekend = date.weekday() >= 5
        is_festival_day = pd.to_datetime(date) in uk_holidays

        # Base average cash dispensed
        base = 40000

        # Apply boosts based on events
        if is_salary_day or is_month_start or is_month_end:
            base *= 1.5
        if is_festival_day:
            base *= 1.8
        if is_weekend:
            base *= 0.9

        # Add randomness and clamp values
        cash_dispensed = int(np.clip(np.random.normal(loc=base, scale=base * 0.2), 10000, 250000))

        # Record this transaction
        records.append({
            "date": date,
            "atm_id": atm,
            "cash_dispensed": cash_dispensed,
            "is_salary_day": is_salary_day,
            "is_month_start": is_month_start,
            "is_month_end": is_month_end,
            "is_weekend": is_weekend,
            "is_festival_day": is_festival_day
        })

# --- Step 5: Convert to DataFrame, Sort, Save ---
df = pd.DataFrame(records)
df = df.sort_values(by=["date", "atm_id"]).reset_index(drop=True)

# Save to CSV
df.to_csv("uk_atm_cash_dispensed.csv", index=False)
print("Data generated uk_atm_cash_dispensed.csv")

# Download the csv file
from google.colab import files
files.download('uk_atm_cash_dispensed.csv')
