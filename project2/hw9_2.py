
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
#Clean and stem the contents of a document
#Takes in a file name to read in and clean
#Return a list of words, without stopwords and punctuation, and with all words stemmed
# NOTE: Do not append any directory names to doc -- assume we will give you
# a string representing a file name that will open correctly
def readAndCleanDoc(doc) :
    #1. Open document, read text into *single* string
    f = open(doc,'r')
    corpus = f.read()

    #2. Tokenize string using nltk.tokenize.word_tokenize
    doc_tokens = nltk.tokenize.word_tokenize(corpus)


    #3. Filter out punctuation from list of words (use remove_punc)
    doc_tokens_no_punc = remove_punc(doc_tokens)

    doc_tokens_clean = [x.lower() for x in doc_tokens_no_punc if x.lower() not in stop]


    stemmer = PorterStemmer()
    words = [stemmer.stem(x) for x in doc_tokens_clean ]
    #4. Make the words lower case

    #5. Filter out stopwords

    #6. Stem words

    return words

#Builds a doc-word matrix for a set of documents
#Takes in a *list of filenames*
#
#Returns 1) a doc-word matrix for the cleaned documents
#This should be a 2-dimensional numpy array, with one row per document and one
#column per word (there should be as many columns as unique words that appear
#across *all* documents. Also, Before constructing the doc-word matrix,
#you should sort the wordlist output and construct the doc-word matrix based on the sorted list
#
#Also returns 2) a list of words that should correspond to the columns in
#docword
def buildDocWordMatrix(doclist) :
    #1. Create word lists for each cleaned doc (use readAndCleanDoc)
    wordlist = []
    tokens = [readAndCleanDoc(x) for x in doclist]

    for x in tokens:
        for alpha in x:
            if (not (alpha in wordlist )):
                 wordlist.append(alpha)

    wordlist.sort()

    #2. Use these word lists to build the doc word matrix

    word_to_ind = {word: ind for ind, word in enumerate(wordlist)}
    docword = np.zeros((len(tokens), len(wordlist)))
    for doc, doc_vec in zip(tokens, docword):
        for word in doc:
             ind = word_to_ind[word]
             doc_vec[ind] += 1

    return docword, wordlist

#Builds a term-frequency matrix
#Takes in a doc word matrix (as buil t in buildDocWordMatrix)
#Returns a term-frequency matrix, which should be a 2-dimensional numpy array
#with the same shape as docword
def buildTFMatrix(docword) :
    #fill in
    tf = np.copy(docword)

    for x in range(len(tf)):
        for y in range(len(tf[x])):
            tf[x][y] = docword[x][y] / sum(docword[x])


    return tf

#Builds an inverse document frequency matrix
#Takes in a doc word matrix (as built in buildDocWordMatrix)
#Returns an inverse document frequency matrix (should be a 1xW numpy array where
#W is the number of words in the doc word matrix)
#Don't forget the log factor!
def buildIDFMatrix(docword) :
    #fill in
    idf = np.zeros((1,len(docword[0])))

    for x in range(len(docword[0])):
        count = 0
        for y in range(len(docword)):
            if(docword[y][x] > 0):
                count = count +1
        aaja = len(docword) / count
        idf[0][x] = math.log10(aaja)
    return idf

#Builds a tf-idf matrix given a doc word matrix
def buildTFIDFMatrix(docword) :
    #fill in

    tfidf = np.multiply(buildTFMatrix(docword),buildIDFMatrix(docword))

    return tfidf

#Find the three most distinctive words, according to TFIDF, in each document
#Input: a docword matrix, a wordlist (corresponding to columns) and a doclist
# (corresponding to rows)
#Output: a dictionary, mapping each document name from doclist to an (ordered
# list of the three most common words in each document
def findDistinctiveWords(docword, wordlist, doclist) :
    distinctiveWords = {}
    #fill in
    #you might find numpy.argsort helpful for solving this problem:
    #https://docs.scipy.org/doc/numpy/reference/generated/numpy.argsort.html

    for x,y in enumerate(buildTFIDFMatrix(docword)):
        sorted_tfidf = np.argsort(y)[::-1][:3]
        distinctiveWords[doclist[x]] = [wordlist[sorted_tfidf[0]],wordlist[sorted_tfidf[1]],wordlist[sorted_tfidf[2]]]

    return distinctiveWords


if __name__ == '__main__':
    from os import listdir
    from os.path import isfile, join, splitext

    ### Test Cases ###
    directory='lecs'
    path1 = join(directory, '1_vidText.txt')
    path2 = join(directory, '2_vidText.txt')

    # Uncomment and recomment ths part where you see fit for testing purposes

    print("*** Testing readAndCleanDoc ***")
    print(readAndCleanDoc(path1)[0:5])

    print("*** Testing buildDocWordMatrix ***")
    doclist =[path1, path2]
    docword, wordlist = buildDocWordMatrix(doclist)
    print(docword.shape)
    print(len(wordlist))
    print(docword[0][0:10])
    print(wordlist[0:10])
    print(docword[1][0:10])

    print("*** Testing buildTFMatrix ***") 
    tf = buildTFMatrix(docword)
    print(tf[0][0:10])
    print(tf[1][0:10])
    print(tf.sum(axis =1))

    print("*** Testing buildIDFMatrix ***") 
    idf = buildIDFMatrix(docword)
    print(idf[0][0:10])

    print("*** Testing buildTFIDFMatrix ***") 
    tfidf = buildTFIDFMatrix(docword)
    print(tfidf.shape)
    print(tfidf[0][0:10])
    print(tfidf[1][0:10])

    print("*** Testing findDistinctiveWords ***")
    print(findDistinctiveWords(docword, wordlist, doclist))

