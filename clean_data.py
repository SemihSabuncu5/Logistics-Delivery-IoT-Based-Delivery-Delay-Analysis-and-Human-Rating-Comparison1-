"""
Rebuild data/processed/deliveries_cleaned.csv from the untouched raw CSV.
Run from the project root: python src/clean_data.py
"""
from pathlib import Path
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / "data/raw/Zomato Dataset.csv"
target = ROOT / "data/processed/deliveries_cleaned.csv"

df = pd.read_csv(source, low_memory=False)
df = df.rename(columns={
    "ID":"delivery_id","Delivery_person_ID":"delivery_person_id",
    "Delivery_person_Age":"delivery_person_age","Delivery_person_Ratings":"delivery_person_rating",
    "Restaurant_latitude":"restaurant_latitude","Restaurant_longitude":"restaurant_longitude",
    "Delivery_location_latitude":"delivery_latitude","Delivery_location_longitude":"delivery_longitude",
    "Order_Date":"order_date","Time_Orderd":"time_ordered","Time_Order_picked":"time_order_picked",
    "Weather_conditions":"weather_conditions","Road_traffic_density":"road_traffic_density",
    "Vehicle_condition":"vehicle_condition","Type_of_order":"type_of_order",
    "Type_of_vehicle":"type_of_vehicle","Festival":"festival","City":"city",
    "Time_taken (min)":"time_taken_min"
})
for col in df.select_dtypes(include="object").columns:
    df[col] = df[col].astype("string").str.strip().replace(
        {"":pd.NA,"NaN":pd.NA,"nan":pd.NA,"NULL":pd.NA}
    )

df["order_date_parsed"] = pd.to_datetime(df["order_date"], format="%d-%m-%Y", errors="coerce")

def parse_clock(value):
    if pd.isna(value):
        return pd.NaT
    value = str(value).strip()
    try:
        number = float(value)
        if 0 <= number < 1:
            minutes = int(round(number * 1440)) % 1440
            return pd.Timestamp("2000-01-01") + pd.Timedelta(minutes=minutes)
    except ValueError:
        pass
    return pd.to_datetime(value, format="%H:%M", errors="coerce")

ordered = df["time_ordered"].map(parse_clock)
picked = df["time_order_picked"].map(parse_clock)
date_text = df["order_date_parsed"].dt.strftime("%Y-%m-%d")
df["order_datetime"] = pd.to_datetime(
    date_text + " " + ordered.map(lambda x: x.strftime("%H:%M") if pd.notna(x) else ""),
    errors="coerce"
)
df["pickup_datetime"] = pd.to_datetime(
    date_text + " " + picked.map(lambda x: x.strftime("%H:%M") if pd.notna(x) else ""),
    errors="coerce"
)
overnight = df["pickup_datetime"].notna() & df["order_datetime"].notna() & (
    df["pickup_datetime"] < df["order_datetime"]
)
df.loc[overnight, "pickup_datetime"] += pd.Timedelta(days=1)
df["order_to_pickup_min"] = (
    df["pickup_datetime"] - df["order_datetime"]
).dt.total_seconds() / 60

for col in ["delivery_person_age","delivery_person_rating","restaurant_latitude",
            "restaurant_longitude","delivery_latitude","delivery_longitude",
            "vehicle_condition","multiple_deliveries","time_taken_min"]:
    df[col] = pd.to_numeric(df[col], errors="coerce")

df.loc[~df["delivery_person_rating"].between(1, 5), "delivery_person_rating"] = np.nan
df.loc[~df["order_to_pickup_min"].between(0, 1440), "order_to_pickup_min"] = np.nan

lat1 = np.radians(df["restaurant_latitude"].astype(float))
lat2 = np.radians(df["delivery_latitude"].astype(float))
dlat = lat2 - lat1
dlon = np.radians(df["delivery_longitude"].astype(float) - df["restaurant_longitude"].astype(float))
a = np.sin(dlat/2)**2 + np.cos(lat1)*np.cos(lat2)*np.sin(dlon/2)**2
df["straight_line_distance_km"] = 6371 * 2 * np.arcsin(np.sqrt(a.clip(0, 1)))
df.loc[(df["straight_line_distance_km"] <= 0) |
       (df["straight_line_distance_km"] > 100), "straight_line_distance_km"] = np.nan

df = df.drop(columns=["order_date_parsed"])
df.to_csv(target, index=False, encoding="utf-8")
print(f"Saved {len(df):,} rows to {target}")
