import collections
import math
import numpy as np
from numpy import linalg as LA

class Gaussian_Naive_Bayes():
    def fit(self, X_train, y_train):
     
        self.x = X_train
        self.y = y_train

        self.gen_by_class()

    def gen_by_class(self):
        
        self.x_by_class = dict()  # done
        self.mean_by_class = dict()
        self.std_by_class = dict()
        self.y_prior = None

      
        labels = np.unique(self.y)
        g = []
        f = []
        classes_index = {}

        cls, counts = np.unique(self.y, return_counts=True)

        e = []
        std_smooth = []
        std_smooth = (np.std(self.x,axis = 0))

        for class_type in labels:

            self.x_by_class[class_type] = (self.x[np.argwhere(self.y == class_type)])
            self.mean_by_class[class_type] = np.mean(self.x_by_class[class_type],axis =0)

            self.std_by_class[class_type] = self.std(self.x_by_class[class_type]) + (std_smooth.max() * 10**-4.5)



            e.append((len(self.x_by_class[class_type]) / len(self.x)))

           # print(x
            #print(y)

        #print(self.x_by_class)
        #print(self.std_by_class)
        # self.mean_by_class["1"] = np.mean(self.x_by_class['1'], axis=0)

        # self.std_by_class["0"] = self.std(self.x_by_class['0'])
        # self.std_by_class["1"] = self.std(self.x_by_class['1'])



        self.y_prior = np.array(e)

        # self.mean_by_class["0"] = np.mean(self.x_by_class["0"],axis=0)[0]

        # print(self.x_by_class)
        pass;

     

    def mean(self, x):
       


        pass;


        return mean

    def std(self, x):


        avg = np.mean(x, axis=0)

        x = np.transpose(x)

        # print(x[0][0])
        total = 0
        b, a,size = x.shape

        final = []
        i = 0


        for g in range(0, b):

            for h in range(0, size):
                    total = total  + ((x[g][0][h] - avg[0][i]) ** 2)

            total = total / (size - 1)

            total = np.sqrt(total)

            if(total == 0):
                total = 0.001

            final.append(total)
            i = i + 1
            total = 0

        # variance = sum((x-avg)**2) / float(len(x)-1)
        # print(variance)
        std = np.array(final)

        pass;

        return std

    def calc_gaussian_dist(self, x, mean, std):


        exponent = (-0.5 * (((x - mean) / std) ** 2))

        prob = np.exp(exponent)
        prob = prob / (((np.sqrt(2 * np.pi)) * std))

        return prob

        pass;

    def predict(self, x):
      
        n = len(x)
        num_class = len(np.unique(self.y))
        prediction = np.zeros((n, num_class))


        i = 0

        for data in x:

            for class_type in range(0,num_class):


               prediction[i][class_type] = (np.prod((self.calc_gaussian_dist(data, self.mean_by_class[class_type], self.std_by_class[class_type]))) * self.y_prior[class_type])
            i = i+1

            pass;

  
        return prediction


class Neural_Network():
    def __init__(self, hidden_size=64, output_size=1):
        self.W1 = None
        self.b1 = None
        self.W2 = None
        self.b2 = None

        self.hidden_size = hidden_size
        self.output_size = output_size

    def fit(self, x, y, batch_size=64, iteration=2000, learning_rate=1e-3):

        dim = x.shape[1]
        num_train = x.shape[0]

        # initialize W
        if self.W1 == None:
            self.W1 = 0.001 * np.random.randn(dim, self.hidden_size)
            self.b1 = 0

            self.W2 = 0.001 * np.random.randn(self.hidden_size, self.output_size)
            self.b2 = 0

        for it in range(iteration):
            batch_ind = np.random.choice(num_train, batch_size)

            x_batch = x[batch_ind]
            y_batch = y[batch_ind]

            loss, gradient = self.loss(x_batch, y_batch)

 
            self.b1 = self.b1 - (learning_rate * gradient.get('db1'))
            self.W1 = self.W1 - (learning_rate * gradient.get('dW1'))

            self.b2 = self.b2 - (learning_rate * gradient.get('db2'))
            self.W2 = self.W2 - (learning_rate * gradient.get('dW2'))
            pass;



            y_pred = self.predict(x_batch)
            acc = np.mean(y_pred == y_batch)

            if it % 50 == 0:
                print('iteration %d / %d: accuracy : %f: loss : %f' % (it, iteration, acc, loss))

    def loss(self, x_batch, y_batch, reg=1e-3):

        gradient = {'dW1': None, 'db1': None, 'dW2': None, 'db2': None}


        g_1 = x_batch.dot(self.W1) + self.b1
        h = self.activation(g_1)
        g_2 = h.dot(self.W2 )+ self.b2
        y_hat = self.sigmoid(g_2)

        h_dev = (g_1 > 0).astype(int)

        pass;



        n = x_batch.shape[0]
        loss = (-1 / len(x_batch)) * sum((y_batch * np.log(y_hat + 1e-10)) + ((1 - y_batch) * np.log(1 - y_hat + 1e-10)))
        loss = loss + reg*(LA.norm(self.W1)+LA.norm(self.W2)+LA.norm(self.b1)+LA.norm(self.b2))


        gradient['dW2'] = (np.dot(h.T,y_hat - y_batch) / len(x_batch)) + (2 * reg * self.W2)
        gradient['db2'] = np.mean(y_hat - y_batch) +(2* reg * self.b2)



        gradient['dW1'] = np.dot((y_batch - y_hat),self.W2.T)
        gradient["dW1"] *= h_dev
        gradient["dW1"] = ((np.dot(x_batch.T,gradient["dW1"])) / (-len(x_batch))) + (2 * reg * self.W1)

        gradient["db1"] = np.dot((y_batch - y_hat),self.W2.T)
        gradient["db1"] *= h_dev
        gradient["db1"] = np.mean(gradient["db1"]) + (2* reg * self.b1)

        pass;

   
        return loss, gradient

    def activation(self, z):
       

        s = np.maximum(0.0,z)
        pass;


        return s

    def sigmoid(self, z):
        

    
        s = 1 / (1 + np.exp(-z))
        pass;

   

        return s

    def predict(self, x):
     
     
    
        g_1 = x.dot(self.W1) + self.b1
        h = self.activation(g_1)
        g_2 = h.dot(self.W2) + self.b2
        y_hat = self.sigmoid(g_2)

        for x in range(0, len(y_hat)):
            if (y_hat[x] > 0.5):
                y_hat[x] = 1
            else:
                y_hat[x] = 0
        pass;

       
        return y_hat
    
