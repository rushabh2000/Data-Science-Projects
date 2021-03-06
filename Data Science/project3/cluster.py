from point import *

#Cluster class
class Cluster :
    
    def __init__(self, center = Point([0, 0])) :
        self.center = center
        self.points = set()
    
    @property    
    def coords(self) :
        return self.center.coords
        
    @property
    def dim(self) :
        return self.center.dim
        
    def addPoint(self, p) :
        self.points.add(p)
        
    def removePoint(self, p) :
        self.points.remove(p)
    
    #Returns the average distance from all of the points in self.points to
    #the current center
    @property
    def avgDistance(self) :
       
        total = 0
        for data in self.points:
            total = self.center.distFrom(data) + total
        mean = total / (len(self.points))
        return mean

        
    #Updates the Points that is self.center to be the average position of all
    #the points in self.points

    def updateCenter(self) :
       
        y_total = 0
        x_total = 0
        if len(self.points) == 0:
            return
        for data in self.points:
            y_total = y_total + data.coords[1]
            x_total = x_total + data.coords[0]
        yata = y_total / len(self.points)
        xata = x_total / len(self.points)
        self.center = Point([xata,yata])
    def printAllPoints(self) :
        print (str(self))
        for p in self.points :
            print ("   {}".format(p))
        
    def __str__(self) :
        return "Cluster: {} points and center = {}".format(len(self.points), self.center)
        
    def __repr__(self) :
        return self.__str__()


def createClusters(data) :
    centers = makePointList(data)
    return [Cluster(c) for c in centers]

if __name__ == '__main__' :
    
    p1 = Point([1.5, 2.5])
    p2 = Point([2.0, 3.0])
    c = Cluster(Point([0.5, 3.5]))
    print(c)
    
    c.addPoint(p1)
    c.addPoint(p2)
    print(c)
    print(c.avgDistance)
    c.updateCenter()
    print(c)
    print(c.avgDistance)
