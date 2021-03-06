
from helper import remove_punc
import string
import nltk
import numpy as np
nltk.download('punkt')
nltk.download('stopwords')
nltk.download('wordnet')
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk.stem import PorterStemmer
stop = stopwords.words('english')
import math

def
    f = open(doc,'r')
    corpus = f.read()

    
    doc_tokens = nltk.tokenize.word_tokenize(corpus)


   
    doc_tokens_no_punc = remove_punc(doc_tokens)

    doc_tokens_clean = [x.lower() for x in doc_tokens_no_punc if x.lower() not in stop]


    stemmer = PorterStemmer()
    words = [stemmer.stem(x) for x in doc_tokens_clean ]

    return words

def buildDocWordMatrix(doclist) :

    wordlist = []
    tokens = [readAndCleanDoc(x) for x in doclist]

    for x in tokens:
        for alpha in x:
            if (not (alpha in wordlist )):
                 wordlist.append(alpha)

    wordlist.sort()

 

    word_to_ind = {word: ind for ind, word in enumerate(wordlist)}
    docword = np.zeros((len(tokens), len(wordlist)))
    for doc, doc_vec in zip(tokens, docword):
        for word in doc:
             ind = word_to_ind[word]
             doc_vec[ind] += 1

    return docword, wordlist


def buildTFMatrix(docword) :
   
    tf = np.copy(docword)

    for x in range(len(tf)):
        for y in range(len(tf[x])):
            tf[x][y] = docword[x][y] / sum(docword[x])


    return tf


def buildIDFMatrix(docword) :

    idf = np.zeros((1,len(docword[0])))

    for x in range(len(docword[0])):
        count = 0
        for y in range(len(docword)):
            if(docword[y][x] > 0):
                count = count +1
        aaja = len(docword) / count
        idf[0][x] = math.log10(aaja)
    return idf


def buildTFIDFMatrix(docword) :

    tfidf = np.multiply(buildTFMatrix(docword),buildIDFMatrix(docword))

    return tfidf


def findDistinctiveWords(docword, wordlist, doclist) :
    distinctiveWords = {}
   

    for x,y in enumerate(buildTFIDFMatrix(docword)):
        sorted_tfidf = np.argsort(y)[::-1][:3]
        distinctiveWords[doclist[x]] = [wordlist[sorted_tfidf[0]],wordlist[sorted_tfidf[1]],wordlist[sorted_tfidf[2]]]

    return distinctiveWords


if __name__ == '__main__':
    from os import listdir
    from os.path import isfile, join, splitext

    
    directory='lecs'
    path1 = join(directory, '1_vidText.txt')
    path2 = join(directory, '2_vidText.txt')



    
    print(findDistinctiveWords(docword, wordlist, doclist))

