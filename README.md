# Mesh-Processing

## Tasks:

1. Calculate the axis-aligned bounding box of the mesh.
2. Find all boundary edges of the mesh. 
3. Calculate the following face traits:
  a. surface area of the triangular face, 
  b. centroid = arithmetic mean of the corner vertices, 
  c. face normal. 
4. Calculate the vertex normals based on the area heuristic. This means that the vertex normal is parallel to the weighted sum of the face normals around the 1-ring of the vertex, where the weight equals the surface area of the face. 
5. Calculate the vertex normals based on the angle heuristic.
  a. As an intermediate step, calculate the halfedge trait ‘angle’, which stores the angle between a halfedge and its previous halfedge in radians. 
  b. Calculate the vertex normal as a weighted sum of the face normals around the 1-ring of the vertex, where the weight equals the angle of the face at the vertex in question.
6. Compare the vertex normals from Tasks 4 and 5b in your documentation. Document cases in which the two solutions differ significantly by describing them and providing screenshots. Are there cases in which one solution makes more sense than the other? (2 points) Hint: Analyze the behavior of the vertex normals for different triangulations of a cube (models cube_*.obj).

## Solutions

###  Task 1:
Calculating bounding box of a mesh, is to determine the minimum and maximum of all the vertices involved in the mesh along the three axis (x, y, z). To do this, we get all the vertices of the mesh and calculate the minimum and maximum of their position trait to find the coordinates of the smallest box which contains the whole mesh.

###  Task 2:
Boundary edges of a mesh are the ones which correspond to only one neighboring face. In half-edge structure, this means the half-edges that do not have any incident face. To find these half-edges (if any) after extracting all the half-edges of the mesh, we store the indices of the half-edges face index of which is 0 (no incident face) in a variable temp. If such half-edges exist, we store all the starting vertices of them in V_start and all the ending vertices in V_end.

###  Task 3:
To calculate the face traits, we first get all the faces of the mesh. In half-edge structure, each face points to only one of its half-edges and each half-edge is pointed by one face. So we get the incident half-edge of each face in order to find the coordinates of the three points that belong to each triangular face. After having the three vertices, we can get two consecutive vectors of each face (v_2-v_1 and v_3-v_1). These two vectors both start from the same point (v_1) since we want the normal to point outwards of the mesh. The traits are calculated and set:
	Area: Since the area of a parallelogram spanned by two vectors is equal to the magnitude of the cross product of those vectors, we can get the area of the triangle after dividing this value by 2.
	Centroid: The mean position of the three vertices of each face.
	Normal: We get the cross product of the all the two vectors of each face and normalize the rows of the result to get the corresponding normal vector for each face.

###  Task 4:
To calculate the vertex normals based on face area heuristic, we need to get all the half-edges of the mesh to find the ones that are not boundary half-edges (since they don’t have any incident face). Then we get the already calculated areas and normals of the corresponding faces of those half-edges and multiply them element-wise. Now that we have the weighted normals, we should add up all the weighted normals corresponding to each vertex which can be of different numbers. So we use accumarary to add these values based on the index of each vertex. At the end, we normalize the value to have a vector of unit length.

###  Task 5:
To calculate the vertex normals based on angle heuristic, first we should calculate the angle of between the half-edge starting from the vertex and the half-edge pointing to the vertex (previous half-edge).
	To calculate the angles, first we get all the half-edges of the mesh and find the three points of each face as we did in task 3. Then we calculate the angle in radians using arc-tangent of the normalized cross-product and the dot-product of the two vectors of each vertex.
	For calculating the vertex normals using angles as weights we can do as we did in task 4; only this time we multiply each face normal by the angle of its corresponding half-edge (from the two edges that intersect at the vertex). At the end, we normalize the value to have a vector of unit length.

###  Task 6:
In general, the vertex normals calculated based on area and angle heuristics are similar in the direction. As an example for comparison, in the fan2 and cube meshes, we can see the difference between the two cases in some vertices (like the corners). In case of these vertices, the difference comes from the fact that the angle of the triangles surrounding the vertex is uniformly distributed, but the area is not or wise versa. The size of vertex normals are increased for better visibility.

![image](https://user-images.githubusercontent.com/24352869/189729104-b764b82e-6853-4e0d-a38d-8dea10e7434f.png)


We can conclude that in cases when the vertices of the mesh are surrounded by faces with similar or uniformly distributed angles (e.g. fan2 and cube3) it is better to use angle as the heuristic; however, for cases where the areas are similar (e.g. cube1 and cube2) the difference is not significant. In general we can conclude that weighting the face normals by their angle is better than weighting them by their areas. One reason is using area as the heuristic can have a large influence in the vertex normal in case of large polygons (since the area of one side can be considerably more than another side of the vertex, like cube3). Another reason is the problem of considering the normal of one face more than once. Especially for triangular meshes such as cube1, cube2, and cube3, one face normal can influence the vertex normal multiple times. For example, in case of cube1 there are four faces that influence the corner vertex. Even though both faces 3 and 4 belong to the same face, the face normal of that face contributes twice in the calculation of the vertex normal and causes it to point slightly to our left. This problem is more obvious in case of cube3 where the two indicated vertex normals diverge while they should be parallel to each other.
Even if on one side of the vertex, there are more triangles than the opposite side, the higher number of triangles with smaller angles is going to compensate the smallness of their angles. Therefore, the vertex normal which is calculated by the average sum of these angles does not point towards the triangle with larger angle. However, in case of area, the cumulative area on one side of the vertex can be less or greater than the cumulative area on another side while the number of triangles on both sides is similar (or the same). This causes the vertex normal to point in favor of the side with higher average area.

