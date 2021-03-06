import collections
import math
import numpy as np
from numpy import log, dot, e
import string
import re
class Logistic_Regression():
    def __init__(self):
        self.W = None
        self.b = None
    
        
    def fit(self, x, y, batch_size = 64, iteration = 2000, learning_rate = 1e-2):
        """
        
        Inputs:
        - X: A numpy array of shape (N, D) containing training data; there are N
          training samples each of dimension D.
        - y: A numpy array of shape (N,) containing training labels; y[i] = c
          means that X[i] has label 0 <= c < C for C classes.
        - learning_rate: (float) learning rate for optimization.
        - iteration: (integer) number of steps to take when optimizing
        - batch_size: (integer) number of training examples to use at each step.
        
      

        Returns:
        None
        """  
        dim = x.shape[1]
        num_train = x.shape[0]

        #initialize W
        if self.W == None:
            self.W = 0.001 * np.random.randn(dim, 1)
            self.b = 0


        for it in range(iteration):
            batch_ind = np.random.choice(num_train, batch_size)

            acc = 0
            x_batch = x[batch_ind]
            y_batch = y[batch_ind]


            z = x_batch.dot(self.W) + self.b
            y_hat = self.sigmoid(z)
            loss, gradients = self.loss(x_batch,y_hat,y_batch)
            self.b = self.b - (learning_rate * gradients.get('db'))
            self.W = self.W - (learning_rate * gradients.get('dW'))


            #y_actual = self.predict(x_batch)

            acc = np.mean(y_hat == y_batch)
            pass;


            if it % 50 == 0:
                print('iteration %d / %d: accuracy : %f: loss : %f' % (it, iteration, acc, loss))

    def predict(self, x):
        """
       

        Returns:
        - y_pred: Predicted labels for the data in X. y_pred is a 1-dimensional
          array of length N, and each element is an integer giving the predicted
          class.
        """

        z = x.dot(self.W) +self.b
        y_pred = self.sigmoid(z)

        for x in range(0,len(y_pred)):
            if (y_pred[x] > 0.5):
                y_pred[x] = 1
            else:
                y_pred[x] = 0
        pass;


        return y_pred

    
    def loss(self, x_batch, y_pred, y_batch):
        """
        Compute the loss function and its derivative. 
        Inputs:
        - X_batch: A numpy array of shape (N, D) containing a minibatch of N
          data points; each point has dimension D.
        - y_batch: A numpy array of shape (N,) containing labels for the minibatch.

        Returns: A tuple containing:
        - loss as a single float
        - gradient dictionary with two keys : 'dW' and 'db'
        """
        gradient = {'dW' : None, 'db' : None}
  
        n = x_batch.shape[0]
        loss = (-1 / len(x_batch) ) * sum((y_batch * np.log(y_pred + 1e-10)) + ((1 - y_batch) * np.log(1 - y_pred + 1e-10)))

        gradient['dW'] = (np.dot(x_batch.T,(y_pred- y_batch)) ) / n
        gradient['db'] = (np.sum(y_pred - y_batch)) / (n)
        pass;

        return loss, gradient

    
    def sigmoid(self, z):
        """
        sigmoid of z
        Inputs:
        z : A scalar or numpy array of any size.
        Return:
        s : sigmoid of input
        """ 
  
        s = 1 / (1 + np.exp(-z))
        pass;

        
        return s


class Spam_Naive_Bayes(object):
    """Implementation of Naive Bayes for Spam detection."""
    def clean(self, s):
        translator = str.maketrans("", "", string.punctuation)
        return s.translate(translator)
 
    def tokenize(self, text):
        text = self.clean(text).lower()
        return re.split("\W+", text)
 
    def get_word_counts(self, words):
        """
    

        Inputs:
            -words : list of words that is used in a data sample
        Output:
            -word_counts : contains each word as a key and number of that word is used from input words.
        """
        word_counts = {}
     

        for word in words:
            if word not in word_counts:
                word_counts[word] = 0
            word_counts[word] += 1

        pass

            
        return word_counts

    def fit(self, X_train, y_train):
        """
        compute likelihood of all words given a class

        Inputs:
            -X_train : list of emails
            -y_train : list of target label (spam : 1, non-spam : 0)
            
        Variables:
            -self.num_messages : dictionary contains number of data that is spam or not
            -self.word_counts : dictionary counts the number of certain word in class 'spam' and 'ham'.
            -self.class_priors : dictionary of prior probability of class 'spam' and 'ham'.
        Output:
            None
        """


        self.word_counts = {}
        self.class_priors = {}
        self.num_messages = {}

        self.num_messages["spam"] = 0
        self.num_messages["ham"] = 0
        self.word_counts['ham'] = {}
        self.word_counts['spam'] = {}
        for y in y_train:
            if(y == 1):
                self.num_messages["spam"] += 1
            else:
                self.num_messages["ham"] += 1
        self.class_priors["spam"] = self.num_messages["spam"] / len(X_train)
        self.class_priors["ham"] = self.num_messages["ham"] / len(X_train)


        for x, y in zip(X_train, y_train):
            if y == 0:
                e = 'ham'
            else:
                e ='spam'
            counts = self.get_word_counts(self.tokenize(x))
            for word, count in counts.items():
                if word not in self.word_counts[e]:
                    self.word_counts[e][word] = 0.0
                self.word_counts[e][word] += count
        print(self.word_counts)
        pass
     
                
    def predict(self, X):
        """
        predict that input X is spam of not. 
        Given a set of words {x_i}, for x_i in an email(x), if the likelihood 
        
        p(x_0|spam) * p(x_1|spam) * ... * p(x_n|spam) * y(spam) > p(x_0|ham) * p(x_1|ham) * ... * p(x_n|ham) * y(ham),
        
        then, the email would be spam.

        Inputs:
            -X : list of emails

        Output:
            -result : A numpy array of shape (N,). It should tell rather a mail is spam(1) or not(0).
        """
            
        result = []
        for x in X:


            counts = self.get_word_counts(self.tokenize(x))
            spam_score = 0
            ham_score = 0

            for word in counts.keys():
                if word not in self.word_counts['spam']:
                    self.word_counts['spam'][word] = 1

                log_spam = math.log(self.word_counts['spam'][word] / (self.num_messages['spam']))
                if word not in self.word_counts['ham']:
                     self.word_counts['ham'][word] = 1


                log_ham = math.log( self.word_counts['ham'][word]/ (self.num_messages['ham']))
                ham_score += log_ham
                spam_score += log_spam

            ham_score += math.log(self.class_priors['ham'])
            spam_score += math.log(self.class_priors['spam'])

            if spam_score < ham_score:
                result.append(0)
            else:
                result.append(1)
            pass

            
        result = np.array(result)
        return result

