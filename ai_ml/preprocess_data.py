import pandas as pd
from config import DATASET_PATH, FEATURES, TARGET

def preprocess_data():

    data = pd.read_csv(DATASET_PATH)

    # Clean column names
    data.columns = data.columns.str.strip()

    # Rename columns to simple names
    data = data.rename(columns={
        "Temperature [_ C]": "temperature",
        "Humidity [%]": "humidity",
        "Soil moisture": "soil_moisture",
        "Solar Radiation ghi": "solar_radiation",
        "Wind Speed": "wind_speed",
        "Evapotranspiration": "evapotranspiration"
    })

    # Calculate crop evapotranspiration
    data["ETc"] = data["Reference evapotranspiration"] * data["Crop Coefficient"]

    # Smarter irrigation rule
    data[TARGET] = ((data["soil_moisture"] < 40) | (data["ETc"] > 4)).astype(int)


    # Convert features to numeric
    for col in FEATURES:
        data[col] = pd.to_numeric(data[col], errors="coerce")

    data = data.dropna()

    X = data[FEATURES]
    y = data[TARGET]

    return X, y
