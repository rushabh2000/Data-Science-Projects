import numpy as np
import pandas as pd
from sklearn.linear_model import Ridge
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
from sklearn.linear_model import LogisticRegression
from sklearn import	metrics
from	sklearn.naive_bayes	import	GaussianNB
from	sklearn.naive_bayes	import	BernoulliNB
def main(datapath):
    file = open(datapath)
    data = [l.split() for l in file.readlines()]
    del data[0]

    ids = []
    for item in data:
        ids.append(item[0])

    people = {}

    buffer = []
    y = []
    for i in ids:
        if i not in people:
            people[i] = 1
        else:
            people[i] = people[i] + 1

    for id, watched in people.items():
        if watched >= 47:
            for x in data:
                if id == x[0]:
                    buffer.append(x)


    tmp = []
    for x in buffer:
        tmp.append(x[11])
        del x[11]
        del x[0]
        del x[0]


    buffer = np.array(buffer).astype(float)
    tmp = np.array(tmp).astype(float)


    [X_train, X_test, y_train, y_test] = train_test_split(buffer, tmp, test_size=0.25, random_state=101)

    X_train = np.array(X_train).astype(np.float)
    #normalize

    [X_train, trn_mean, trn_std] = normalize_train(X_train)
    X_test = normalize_test(X_test, trn_mean, trn_std)

    logreg = LogisticRegression()
    logreg.fit(X_train, y_train)
    y_pred = logreg.predict(X_test)

    print(logreg.coef_)
    print(logreg.intercept_)
    print(metrics.confusion_matrix(y_test, y_pred))
    print(metrics.accuracy_score(y_test, y_pred))
    print(metrics.average_precision_score(y_test, y_pred))


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