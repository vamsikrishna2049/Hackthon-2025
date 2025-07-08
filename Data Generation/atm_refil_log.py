import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# Timeframe: 3 years
end_date = datetime.today()
# 3 Years
start_date = end_date - timedelta(days=3*365)

# ATM IDs
atm_ids = [f'ATM{str(i).zfill(3)}' for i in range(1, 51)]

# Refill agencies
cms_agencies = [
    "RADIANT CASH MANAGEMENT SERVICES LTD",
    "Cash Management Services LTD (CMS)",
    "SIS Limited",
    "AGS Transact Technologies Limited"
]

# Generate refill log data
refill_data = []

for atm in atm_ids:
    refill_dates = pd.date_range(start=start_date, end=end_date, freq=f'{random.randint(10, 15)}D')
    for date in refill_dates:
        agency = random.choice(cms_agencies)
        count_500 = np.random.randint(200, 1000)
        count_100 = np.random.randint(300, 1200)
        total_amount = count_500 * 500 + count_100 * 100
        refill_data.append([
            date.date(), atm, agency, count_500, count_100, total_amount
        ])

refill_df = pd.DataFrame(refill_data, columns=[
    "refill_date", "atm_id", "refilled_by", "count_500_notes",
    "count_100_notes", "total_refilled_amt"
])

# Sort and Save
refill_df = refill_df.sort_values(by="refill_date")
refill_df.to_csv("atm_refill_log.csv", index=False)
print("atm_refill_log.csv generated.")


from google.colab import files
files.download('atm_refill_log.csv')
