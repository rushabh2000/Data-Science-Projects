import numpy as np
import pandas as pd
from sklearn.linear_model import Ridge
from sklearn.model_selection import train_test_split
from sklearn import linear_model
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
import matplotlib.pyplot as plt
from sklearn.metrics import r2_score
from	sklearn.naive_bayes	import MultinomialNB
from sklearn.linear_model import LogisticRegression
from	sklearn.naive_bayes	import	GaussianNB
from sklearn import	metrics
from	sklearn.naive_bayes	import	BernoulliNB
def main(datapath):
    file = open(datapath)
    buffer = [l.split() for l in file.readlines()]
    del buffer[0]



    tmp = []
    for x in buffer:
        tmp.append(x[11])
        del x[11]
        del x[0]
        del x[0]
    buffer = np.array(buffer).astype(float)
    tmp = np.array(tmp).astype(float)


    [X_train, X_test, y_train, y_test] = train_test_split(buffer, tmp, test_size=0.25, random_state=1)
    X_train = np.array(X_train).astype(np.float)
    # normalize



    gnb = BernoulliNB()
    gnb.fit(X_train, y_train)
    y_pred = gnb.predict(X_test)

    gnb = GaussianNB()
    gnb.fit(X_train, y_train)
    y_predg = gnb.predict(X_test)



    print(metrics.confusion_matrix(y_test,y_pred))
    print(metrics.accuracy_score(y_test, y_pred))


    print(metrics.confusion_matrix(y_test, y_predg))
    print(metrics.accuracy_score(y_test, y_predg))

    logreg = LogisticRegression()
    logreg.fit(X_train, y_train)
    y_predl = logreg.predict(X_test)
    print(metrics.confusion_matrix(y_test, y_predl))
    print(metrics.accuracy_score(y_test, y_predl))


    multi =MultinomialNB()
    multi.fit(X_train, y_train)
    y_predm = multi.predict(X_test)

    print(metrics.confusion_matrix(y_test, y_predm))
    print(metrics.accuracy_score(y_test, y_predm))




def normalize_train(X_train):

    #fill in
    mean = np.mean(X_train,axis = 0)
    std = np.std(X_train, axis=0)
    X = (X_train - mean) / std

    #for z in range(0,4):
     #   print(X[z])
    return X, mean, std
def normalize_test(X_test, trn_mean, trn_std):

        # fill in
        X = (X_test - trn_mean) / trn_std

        return X



if __name__ == '__main__':
    datapath = 'behavior-performance.txt'
    main(datapath)