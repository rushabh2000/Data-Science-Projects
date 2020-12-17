from cluster import *
from point import *

def kmeans(pointdata, clusterdata) :
     


    list_points  = makePointList(pointdata)
    var = len(list_points)
    list_cluster = createClusters(clusterdata)


    while var > 0:
        for data in list_points:
            see = data.moveToCluster(data.closest(list_cluster))
            if see == False:
                var -= 1
        if var == 0:
            break
        for aaja in list_cluster:
            aaja.updateCenter()

    clusters = list_cluster
    return clusters
    
    
    
if __name__ == '__main__' :
    data = np.array([[0.5, 2.5], [0.3, 4.5], [-0.5, 3], [0, 1.2], [10, -5], [11, -4.5], [8, -3]], dtype=float)
    centers = np.array([[0, 0], [1, 1]], dtype=float)
    
    clusters = kmeans(data, centers)
    for c in clusters :
        c.printAllPoints()
