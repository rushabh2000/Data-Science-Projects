
def getFormattedText(filename) :
    #fill in
    lines = []

    gets_list =[]

    f = open(filename,'r')
    corpus = f.read()
    gets_list = corpus.splitlines()

    for sub in gets_list: # remove newlines
        lines.append(sub.replace("\n", " "))

    lines = [item.lower() for item in lines] # lowercase
    lines = [str(i).rjust(len(i) + 2, '_') for i in lines]#padding right
    lines = [str(i).ljust(len(i) + 2, '_') for i in lines]#paddingleft


    return lines
        
        


def getNgrams(line) :
   
    nGrams = []


    for x in range(0,len(line)-2):

       get_gram = line[x] + line[x+1] + line[x+2]

       nGrams.append(get_gram)

    return nGrams

def getDict(filename):
    #fill in
    nGramDict = {}
    gram_list = []
    get_lines = getFormattedText(filename)
    for line in get_lines:
        n_grams = getNgrams(line)
        for gram in n_grams:
            gram_list.append(gram)


    nGramDict = dict.fromkeys(gram_list, 0)
    for line in get_lines:
        n_gram = getNgrams(line)
        for x in n_gram:
            if x in nGramDict.keys():
                nGramDict[x] +=1
    return nGramDict


def topNCommon(filename,N):
    commonN = []
    dict = getDict(filename)
    for key in sorted(dict, key=dict.get, reverse=True)[:N]:
        create_tup = ((key,dict[key]))
        commonN.append(create_tup)
    return commonN


def getAllDicts(fileNamesList):
    langDicts = []
    for x in fileNamesList:
        dict = getDict(x)
        langDicts.append(dict)
    
    return langDicts


def dictUnion(listOfDicts):
    unionNGrams = []
    union_set = set()

    for x in listOfDicts:

         union_set  = union_set.union(set(x.keys()))

    unionNGrams = ((list(union_set)))

            #if(x.isnumeric() == True):
            #unionNGrams.remove(x)
    unionNGrams.sort()


    return unionNGrams



def getAllNGrams(langFiles):
    allNGrams = []
    
    get_dict = getAllDicts(langFiles)
    allNGrams = dictUnion(get_dict)

    return allNGrams

########################################## Checkpoint, can test code above before proceeding #############################################


def compareLang(testFile,langFiles,N):
    langMatch = ''
    similar_list = []
    top_ten =[]
    for d in topNCommon(testFile, N):
        top_ten.append(d[0])

    for x in langFiles:
        similar = 0
        top = []
        for z in topNCommon(x,N):
            top.append(z[0])

        for a,b in enumerate(top):
            if(b == top_ten):
                similar += 1
        similar_list.append(similar)

    langMatch = langFiles[similar_list.index(max(similar_list))]

    return langMatch




if __name__ == '__main__':
    from os import listdir
    from os.path import isfile, join, splitext
    

    path = join('ngrams','english.txt')
    print(topNCommon(path,10))

    #Compile ngrams across all 6 languages and determine a mystery language
    path='ngrams'
    fileList = [f for f in listdir(path) if isfile(join(path, f))]
    pathList = [join(path, f) for f in fileList if 'mystery' not in f]
    print(getAllNGrams(pathList))#list of all n-grams spanning all languages

    testFile = join(path,'mystery.txt')
    print(compareLang(testFile, pathList, 20))#determine language of mystery file

