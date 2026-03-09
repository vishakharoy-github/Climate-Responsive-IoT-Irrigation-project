import joblib
import numpy as np
from config import MODEL_PATH

model = joblib.load(MODEL_PATH)

def predict_irrigation(
        soil_moisture,
        temperature,
        humidity,
        solar_radiation,
        wind_speed,
        evapotranspiration):

    features = np.array([[

        soil_moisture,
        temperature,
        humidity,
        solar_radiation,
        wind_speed,
        evapotranspiration

    ]])

    prediction = model.predict(features)[0]

    if prediction == 1:
        return "Irrigation Required"
    else:
        return "No Irrigation Needed"


if __name__ == "__main__":

    result = predict_irrigation(
        22, 34, 40, 20, 2.3, 5.1
    )

    print(result)
