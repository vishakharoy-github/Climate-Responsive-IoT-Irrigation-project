# Dataset configuration

DATASET_PATH = "dataset/tomato_irrigation_dataset_final.csv"
MODEL_PATH = "irrigation_model.pkl"

FEATURES = [
    "soil_moisture",
    "temperature",
    "humidity",
    "solar_radiation",
    "wind_speed",
    "evapotranspiration"
]



# We will generate irrigation labels automatically
TARGET = "irrigation"

TEST_SIZE = 0.2
RANDOM_STATE = 42
