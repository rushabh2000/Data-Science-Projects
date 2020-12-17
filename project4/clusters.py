
import matplotlib.pyplot as plt

from sklearn.cluster import KMeans


pic = plt.imread('eye.PNG')

pic_reshape = pic.reshape(pic.shape[0]*pic.shape[1], pic.shape[2])

kmeans = KMeans(n_clusters=6, random_state=0).fit(pic_reshape)
pic2show = kmeans.cluster_centers_[kmeans.labels_]

cluster_pic = pic2show.reshape(pic.shape[0], pic.shape[1], pic.shape[2])
plt.imshow(cluster_pic)
plt.show()

