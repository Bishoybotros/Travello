from sklearn.neighbors import KNeighborsClassifier
import pandas as pd
from sklearn.model_selection import train_test_split


# Load and train the model when the module is loaded
data = pd.read_csv("points_train.csv")
y = data[['x', 'y']]
x = data.drop(['x', 'y'], axis=1)
X_train, X_test, y_train, y_test = train_test_split(x, y, test_size=0.2, random_state=42)
model = KNeighborsClassifier(n_neighbors=3)
model.fit(X_train, y_train)

def predict_points(values):
    inputlist = [float(value) for value in values.split(",")]
    results = model.predict([inputlist])
    return results[0][0], results[0][1]

