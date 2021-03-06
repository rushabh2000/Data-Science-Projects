import numpy as np
import matplotlib.pyplot as plt
import math

def main(datapath, degrees):
    paramFits = []
    result = []
    X =[]
    Y  = []

    myfile = open(datapath).read().splitlines();

    for line in myfile:
        result.append( line.split('\t',maxsplit = 1))


    for x in range(0,len(result)):
        X.append(float(result[x][0]))
        Y.append(float(result[x][1]))
    i = 0;
    print(X)
    for d in degrees:
        feat_matrix = (feature_matrix(X,d))
        print(feat_matrix)
        paramFits.append( least_squares(feat_matrix,Y))


    return paramFits



def feature_matrix(x, d):

   
    X  = [];
    for a in x:
        z = []
        for y in range(0,d + 1):
            z.append(a ** (d - y))
        X.append(z)



    return X


def least_squares(X, y):
    X = np.array(X)
    y = np.array(y)


    
    z = (np.linalg.inv((X.T @ X)) @ X.T @ y)


    B = z.tolist()

    for i in range(0,len(B)):
        B[i] = round(B[i],6 - int(math.floor(math.log10(abs(B[i])))) - 1)
    return B

if __name__ == '__main__':
    datapath = 'poly.txt'
    degrees = [1,2,3,4,5]
    paramFits = main(datapath, degrees)
    data = np.loadtxt(datapath, usecols=(0, 1))
    X = data[:, 0]
    y = data[:, 1]
    plt.scatter(X, y, label='actual data')
    X.sort()

    for i in paramFits:
        x1 = feature_matrix(X, len(i) - 1)
        x1 = np.array(x1)

        y = np.dot(x1, i)
        label = 'd = ' + str(len(i) - 1)
        plt.plot(X, y, label=label)
        plt.title('relationship between actual y and predicted y')
        plt.legend()
        plt.ylabel("y values")
        plt.xlabel("x values")
    plt.show()

    print(paramFits)

    #y3 = [0.820138, 0.261767 , -0.0103277]
    #x = [2,2,2]
    #coeff  = -175.277

    #result = np.dot(y3,x)
    #result = result + coeff
    #print(result)


