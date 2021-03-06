import math
import numpy as np

#Point class for an n-dimensional point
class Point :
    
  
    def __init__(self, coords) :
        self.coords = coords
        self.currCluster = None
        

    @property
    def dim(self) :
        return len(self.coords)
        
   

    def distFrom(self, other) :
   
        if self.dim != other.dim :
            raise Exception("dimension mismatch: self has dim {} and other has dim {}".format(self.dim, other.dim))
       
        x = 0
        total = 0
        while x < self.dim:
            total += (self.coords[x] - other.coords[x]) * (self.coords[x] - other.coords[x])
            x += 1

        dist = math.sqrt(total)
        return dist
        

    def moveToCluster(self, dest) :
        if (self.currCluster is dest) :
            return False
        else :
            if (self.currCluster) :
                self.currCluster.removePoint(self)                
            dest.addPoint(self)
            self.currCluster = dest
            return True
            

    def closest(self, listOfPoints) :
        minDist = self.distFrom(listOfPoints[0])
        minPt = listOfPoints[0]
        for p in listOfPoints :
            if (self.distFrom(p) < minDist) :
                minDist = self.distFrom(p)
                minPt = p
        return minPt
        
    def __getitem__(self, i) :
        return self.coords[i]
        
    def __str__(self) :
        return str(self.coords)
        
    def __repr__(self) :
        return "Point: " + self.__str__()
        

def makePointList(data) :

    coordinates = []
    for x in data:
        coordinates.append(Point(x))

    return coordinates


if __name__ == '__main__' :
    data = np.array([[0.5, 2.5], [0.3, 4.5], [-0.5, 3], [0, 1.2], [10, -5], [11, -4.5], [8, -3]])
    
    points = makePointList(data)
    print(points)
    
    print(points[0].distFrom(points[1]))
