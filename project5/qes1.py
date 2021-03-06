import matplotlib.pyplot as plt
import numpy as np
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score, silhouette_samples
import collections



def main(datapath):

    file = open(datapath)
    data = [l.split() for l in file.readlines()]
    del data[0]

    ids = []
    for item in data:
        ids.append(item[0])

    people = {}

    buffer = []
    for i in ids:
        if i not in people:
            people[i] = 1
        else:
            people[i] = people[i] + 1
    for id,watched in people.items():
        if watched >= 5:
            for x in data:
                if id == x[0]:
                    buffer.append(x)

    curr = []
    buffer = np.array(buffer)

    for x in range(2,11):
        tmp = np.column_stack((buffer[:, x],buffer[:,11]))
        curr.append(np.array(tmp, dtype=float))




    x_val = ["fracSpent", "fracComp", "fracPlayed", "fracPaused", "numPauses", "avgPBR", "stdPBR", "numRWs", "numFFs"]
    i =0
    for y in(curr):
        kmeans = KMeans(n_clusters = 2)
        kmeans.fit(y)
        print(kmeans.labels_)
        print(kmeans.cluster_centers_)
        tp = plt.gca()
        tp.scatter(kmeans.cluster_centers_[:,0],kmeans.cluster_centers_[:,1],marker = 'x',s= 100)
        tp.scatter(y[:,0],y[:,1],c= kmeans.labels_)
        plt.ylabel("the score")
        plt.xlabel(x_val[i])
        i = i + 1
        plt.show()


if __name__ == '__main__':
    datapath = 'behavior-performance.txt'
    main(datapath)