# ATM Cash Demand Forecast with UK Holiday API + Category Priority Logic + Note-wise Breakdown + Visualization

import pandas as pd
import numpy as np
import requests
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime, timedelta
from sklearn.model_selection import train_test_split
from prometheus_client import Gauge, CollectorRegistry, push_to_gateway
import xgboost as xgb

# --- Step 1: Load ATM Cash Data ---
df = pd.read_csv("uk_atm_cash_dispensed.csv")
df["date"] = pd.to_datetime(df["date"])
df = df.sort_values(by=["atm_id", "date"]).reset_index(drop=True)

# --- Step 2: Fetch UK Holidays ---
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

# ATM Category assignment based on total cash dispensed
total_by_atm = df.groupby("atm_id")["cash_dispensed"].sum().reset_index()
total_by_atm.columns = ["atm_id", "total_cash_dispensed"]
total_by_atm["atm_category"] = pd.qcut(
    total_by_atm["total_cash_dispensed"], q=5, labels=["E", "D", "C", "B", "A"]
)
total_by_atm["atm_category"] = total_by_atm["atm_category"].astype(str)
df = df.merge(total_by_atm[["atm_id", "atm_category"]], on="atm_id", how="left")

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

# Round to nearest 500 for predicted demand
future_df["predicted_cash_demand"] = (
    np.ceil(future_df["exact_cash_demand"] / 500) * 500
)

# Breakdown into ₹500 and ₹100 denominations
future_df["count_500_notes"] = (future_df["predicted_cash_demand"] * 0.7) // 500
future_df["count_100_notes"] = (future_df["predicted_cash_demand"] * 0.3) // 100

# Attach ATM and Date
future_df["atm_id"] = [atm.replace("atm_id_", "") for atm in atm_list for _ in range(7)]
future_df["date"] = list(future_dates) * len(atm_list)

# --- Add category and priority score ---
future_df = future_df.merge(total_by_atm[["atm_id", "atm_category"]], on="atm_id", how="left")
category_weight = {"A": 5, "B": 4, "C": 3, "D": 2, "E": 1}
future_df["category_weight"] = future_df["atm_category"].map(category_weight).astype(float)
future_df["refill_priority_score"] = future_df["predicted_cash_demand"] * future_df["category_weight"]

# --- Final Forecast Output ---
forecast_df = future_df[[
    "date", "atm_id", "atm_category", "predicted_cash_demand", "exact_cash_demand",
    "count_500_notes", "count_100_notes", "refill_priority_score"
]]
forecast_df = forecast_df.sort_values(by="refill_priority_score", ascending=False)
forecast_df.to_csv("atm_cash_forecast_with_priority.csv", index=False)

print("\n✅ Forecast with category-based priority saved as atm_cash_forecast_with_priority.csv")

# --- Visualization ---
sns.set(style="whitegrid")
plt.figure(figsize=(12, 6))
sns.barplot(
    data=forecast_df.groupby("atm_category")["predicted_cash_demand"].mean().reset_index(),
    x="atm_category", y="predicted_cash_demand", palette="viridis"
)
plt.title("Average Predicted Cash Demand by ATM Category")
plt.xlabel("ATM Category")
plt.ylabel("Avg. Predicted Cash Demand")
plt.tight_layout()
plt.savefig("cash_demand_by_category.png")
plt.show()

# --- Optional: Export to Prometheus (requires Prometheus + Pushgateway running) ---
# registry = CollectorRegistry()
# gauge = Gauge('atm_cash_forecast', 'Predicted ATM cash demand', ['atm_id'], registry=registry)
# for i, row in forecast_df.iterrows():
#     gauge.labels(atm_id=row['atm_id']).set(row['predicted_cash_demand'])
# push_to_gateway('localhost:9091', job='atm_cash_forecast_job', registry=registry)
# print("✅ Pushed forecast data to Prometheus Pushgateway")
