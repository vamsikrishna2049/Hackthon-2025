# ATM Cash Demand Forecast with UK Holiday API + Advanced Models + Prometheus Export

import pandas as pd
import numpy as np
import requests
from datetime import datetime, timedelta
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from prometheus_client import Gauge, CollectorRegistry, push_to_gateway
import xgboost as xgb

# --- Step 1: Load ATM Cash Data ---
df = pd.read_csv("uk_atm_cash_dispensed.csv")
df["date"] = pd.to_datetime(df["date"])
df = df.sort_values(by=["atm_id", "date"]).reset_index(drop=True)

# --- Step 2: Fetch UK Holidays (last year + this year) ---
def get_uk_holidays(years):
    holidays = []
    for year in years:
        url = f"https://date.nager.at/api/v3/PublicHolidays/{year}/GB"
        response = requests.get(url)
        if response.status_code == 200:
            holidays += [h["date"] for h in response.json()]
    return pd.to_datetime(holidays)

years_to_fetch = [df.date.min().year, df.date.max().year, datetime.today().year]
uk_holidays = get_uk_holidays(years_to_fetch)

# --- Step 3: Feature Engineering ---
df["day"] = df["date"].dt.day
df["month"] = df["date"].dt.month
df["weekday"] = df["date"].dt.weekday
df["is_festival_day"] = df["date"].isin(uk_holidays)

# One-hot encode atm_id
df = pd.get_dummies(df, columns=["atm_id"])

features = [
    "is_salary_day", "is_month_start", "is_month_end", "is_weekend", "is_festival_day",
    "day", "month", "weekday"
] + [col for col in df.columns if col.startswith("atm_id_")]

X = df[features]
y = df["cash_dispensed"]

# --- Step 4: Train/Test Split ---
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# --- Step 5: Train XGBoost Model ---
xgb_model = xgb.XGBRegressor(objective='reg:squarederror', n_estimators=100, seed=42)
xgb_model.fit(X_train, y_train)

# --- Step 6: Predict for Next 7 Days ---
atm_list = sorted([col for col in df.columns if col.startswith('atm_id_')])
future_dates = pd.date_range(start=df["date"].max() + pd.Timedelta(days=1), periods=7)

pred_rows = []
for atm in atm_list:
    for d in future_dates:
        row = {
            "is_salary_day": d.day == 1,
            "is_month_start": d.day <= 2,
            "is_month_end": d.day >= 28,
            "is_weekend": d.weekday() >= 5,
            "is_festival_day": d in uk_holidays,
            "day": d.day,
            "month": d.month,
            "weekday": d.weekday()
        }
        for a in atm_list:
            row[a] = 1 if a == atm else 0
        pred_rows.append(row)

future_df = pd.DataFrame(pred_rows)
future_df["exact_cash_demand"] = xgb_model.predict(future_df)

# Round up to nearest 500 for refill prediction
future_df["predicted_cash_demand"] = (
    np.ceil(future_df["exact_cash_demand"] / 500) * 500
)

# Attach ATM and Date fields
future_df["atm_id"] = [atm.replace("atm_id_", "") for atm in atm_list for _ in range(7)]
future_df["date"] = list(future_dates) * len(atm_list)

forecast_df = future_df[["date", "atm_id", "exact_cash_demand", "predicted_cash_demand"]]
forecast_df = forecast_df.sort_values(by=["date", "atm_id"])
forecast_df.to_csv("atm_cash_forecast_next_7_days.csv", index=False)

print("\n✅ Forecast file saved: atm_cash_forecast_next_7_days.csv")


# Download the csv file
from google.colab import files
files.download('atm_cash_forecast_next_7_days.csv')
