```python
# 📦 Importing necessary Python libraries
import pandas as pd          # For working with table-like data
import numpy as np           # For handling numbers and random values
from datetime import datetime, timedelta  # For working with dates
import random                # For choosing random values (like agency names)

# 📅 Define how many years of data we want
# We're taking data from today, and going back 3 years (approximately 1095 days)
end_date = datetime.today()  # Today's date
start_date = end_date - timedelta(days=3*365)  # Start date is 3 years ago

# 🏧 Create a list of 50 ATM machines with unique IDs (ATM001 to ATM050)
atm_ids = [f'ATM{str(i).zfill(3)}' for i in range(1, 51)]

# List of companies that handle cash refills for the ATMs
cms_agencies = [
    "RADIANT CASH MANAGEMENT SERVICES LTD",
    "Cash Management Services LTD (CMS)",
    "SIS Limited",
    "AGS Transact Technologies Limited"
]

# Create an empty list to store each refill record
refill_data = []

# For every ATM, create refill records
for atm in atm_ids:
    # Randomly select refill dates between every 10 to 15 days
    refill_dates = pd.date_range(start=start_date, end=end_date, freq=f'{random.randint(10, 15)}D')

    # For each selected date, create a refill record
    for date in refill_dates:
        agency = random.choice(cms_agencies)  # Randomly pick a cash handling agency

        # Random number of 500 and 100 rupee notes added during the refill
        count_500 = np.random.randint(200, 1000)   # e.g., 200 to 1000 notes of ₹500
        count_100 = np.random.randint(300, 1200)   # e.g., 300 to 1200 notes of ₹100

        # Total amount refilled = number of notes × value of each note
        total_amount = count_500 * 500 + count_100 * 100

        # Add this record to the refill data list
        refill_data.append([
            date.date(), atm, agency, count_500, count_100, total_amount
        ])

#Convert the list of refill records into a table (DataFrame)
refill_df = pd.DataFrame(refill_data, columns=[
    "refill_date",           # Date of refill
    "atm_id",                # ATM machine ID
    "refilled_by",           # Cash refill agency name
    "count_500_notes",       # Number of ₹500 notes filled
    "count_100_notes",       # Number of ₹100 notes filled
    "total_refilled_amt"     # Total amount of cash refilled
])

#Sort the records by date (to keep the data in timeline order)
refill_df = refill_df.sort_values(by="refill_date")

#Save the data to a CSV file which can be opened in Excel
refill_df.to_csv("atm_refill_log.csv", index=False)
print("atm_refill_log.csv generated successfully.")

#Automatically download the file to your computer (works in Google Colab)
from google.colab import files
files.download('atm_refill_log.csv')
```

---

* This code generates **realistic ATM refill data** for 50 machines over the last 3 years.
