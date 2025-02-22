import numpy as np
import pandas as pd
from sklearn.linear_model import Ridge
from sklearn.model_selection import train_test_split
from sklearn import linear_model
from sklearn.metrics import mean_squared_error
import matplotlib.pyplot as plt


def main():
    #Importing dataset
    diamonds = pd.read_csv('diamonds.csv')

    #Feature and target matrices
    X = diamonds[['carat', 'depth', 'table', 'x', 'y', 'z', 'clarity', 'cut', 'color']]
    y = diamonds[['price']]

    print(X)
    #Training and testing split, with 25% of the data reserved as the test set
    X = X.to_numpy()
    y = y.to_numpy()
    print(X)
    [X_train, X_test, y_train, y_test] = train_test_split(X, y, test_size=0.25, random_state=101)
    print(X_train)
    #Normalizing training and testing data
    [X_train, trn_mean, trn_std] = normalize_train(X_train)
    X_test = normalize_test(X_test, trn_mean, trn_std)

    
    lmbda = np.logspace(-1.00,2.00,101)

    #lmbda = [1,100]

    MODEL = []
    MSE = []
    for l in lmbda:
        #Train the regression model using a regularization parameter of l
        model = train_model(X_train,y_train,l)

        #Evaluate the MSE on the test set
        mse = error(X_test,y_test,model)

        #Store the model and mse in lists for further processing
        MODEL.append(model)
        MSE.append(mse)


    #Plot the MSE as a function of lmbda
   
    #plt.plot(lmbda,MSE,label = 'lamda =' + str(lmbda))
    #plt.title('relationship between mean squared error and lambda values')
    #plt.ylabel(" MSE values")
    #plt.xlabel("lambda values")
    #plt.show()

    #Find best value of lmbda in terms of MSE
    ind = MSE.index(min(MSE))

    [lmda_best,MSE_best,model_best] = [lmbda[ind],MSE[ind],MODEL[ind]]

    print('Best lambda tested is ' + str(lmda_best) + ', which yields an MSE of ' + str(MSE_best))
    x_vals = np.array([[0.25, 60, 55, 4, 3, 2, 5, 3, 3]])
    x_vals = (x_vals - trn_mean) / trn_std
    y_result = model_best.predict(x_vals)
    print(y_result)
    return model_best

def normalize_train(X_train):

   
    mean = np.mean(X_train,axis = 0)
    std = np.std(X_train, axis=0)
    X = (X_train - mean) / std

    #for z in range(0,4):
     #   print(X[z])
    return X, mean, std


def normalize_test(X_test, trn_mean, trn_std):

  =
    X = (X_test - trn_mean) / trn_std


    return X

def train_model(X,y,l):

    model = linear_model.Ridge(alpha =l,fit_intercept = True)
    model.fit(X,y)
    return model


def error(X,y,model):

    
    yn = model.predict(X)
    mse = mean_squared_error(y,yn)
    return mse

if __name__ == '__main__':
    model_best = main()
   
    diamonds = pd.read_csv('diamonds.csv')

    # Feature and target matrices
    X = diamonds[['carat', 'depth', 'table', 'x', 'y', 'z', 'clarity', 'cut', 'color']]
    y = diamonds[['price']]

    # Training and testing split, with 25% of the data reserved as the test set
    X = X.to_numpy()
    y = y.to_numpy()
    yn = model_best.predict(X)
    plt.plot(X,yn)
    plt.show()
    print(model_best.coef_)
    print(model_best.intercept_)

