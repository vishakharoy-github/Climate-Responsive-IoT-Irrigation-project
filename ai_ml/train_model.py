import joblib
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report

from preprocess_data import preprocess_data
from config import MODEL_PATH, TEST_SIZE, RANDOM_STATE

def train():

    X, y = preprocess_data()

    # Train test split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y,
        test_size=TEST_SIZE,
        random_state=RANDOM_STATE
    )

    # Random Forest model
    model = RandomForestClassifier(
        n_estimators=200,
        max_depth=10,
        random_state=RANDOM_STATE
    )

    model.fit(X_train, y_train)

    predictions = model.predict(X_test)

    print("\nModel Evaluation\n")

    print("Accuracy:", accuracy_score(y_test, predictions))
    print("\nClassification Report\n")
    print(classification_report(y_test, predictions))

    # Save model
    joblib.dump(model, MODEL_PATH)

    print("\nModel saved as:", MODEL_PATH)

if __name__ == "__main__":
    train()
