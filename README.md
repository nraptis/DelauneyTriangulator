# Delauney-Triangulation
Delauney Triangulation in Swift. Also includes Delauney Triangulation with edge constraints. To this algorithm, I have added a signifigant speed improvement using buckets (EdgeGridBucket.swift) and (PolyPointBucket.swift).</br></br>

![alt text](https://github.com/nraptis/DelauneyTriangulator/blob/main/delauney.png)</br></br>

https://www.newcastle.edu.au/__data/assets/pdf_file/0017/22508/13_A-fast-algorithm-for-constructing-Delaunay-triangulations-in-the-plane.pdf

I started my triangulation journey over 15 years ago. Now that 15 years have passed, I am ready to share my code with the world. I have improved on existing algorithms by utilizing buckets to reduce the bottlenecks by up to 20,000%. (These only apply to constrained triangulation)</br></br>

Please note that the Constrained triangulation is technically no longer a "Delauney triangulation," as it is not a convex hull.</br></br>

Example of using Constrained Delauney with "hull" as the outer polygon:</br></br>
</br></br>

```
let hull = [
    SIMD2<Float>(-100.0, -100.0),
    SIMD2<Float>(100.0, -100.0),
    SIMD2<Float>(0.0, 100.0)
]

let points = [
    SIMD2<Float>(-25.0, -10.0),
    SIMD2<Float>(50.0, 10.0)
]

let triangulator = DelauneyTriangulator.shared
triangulator.triangulate(points: points,
                         hull: hull,
                         superTriangleSize: 8192.0)

var triangleIndex = 0
while triangleIndex < triangulator.triangles.count {
    let triangle = triangulator.triangles[triangleIndex]
    
    let point1 = triangle.point1
    let point2 = triangle.point2
    let point3 = triangle.point3
    
    print("Triangle[\(triangleIndex)].point1 = (\(point1.x), \(point1.y))")
    print("Triangle[\(triangleIndex)].point2 = (\(point2.x), \(point2.y))")
    print("Triangle[\(triangleIndex)].point3 = (\(point3.x), \(point3.y))")
    
    triangleIndex += 1
}
```

Example of using Standard Delauney:</br></br>
</br></br>

```
let points = [
    SIMD2<Float>(-100.0, -100.0),
    SIMD2<Float>(100.0, -100.0),
    SIMD2<Float>(0.0, 0.0),
    SIMD2<Float>(0.0, 100.0)
]

let triangulator = DelauneyTriangulator.shared
triangulator.triangulate(points: points,
                         superTriangleSize: 8192.0)

var triangleIndex = 0
while triangleIndex < triangulator.triangles.count {
    let triangle = triangulator.triangles[triangleIndex]
    
    let point1 = triangle.point1
    let point2 = triangle.point2
    let point3 = triangle.point3
    
    print("Triangle[\(triangleIndex)].point1 = (\(point1.x), \(point1.y))")
    print("Triangle[\(triangleIndex)].point2 = (\(point2.x), \(point2.y))")
    print("Triangle[\(triangleIndex)].point3 = (\(point3.x), \(point3.y))")
    
    triangleIndex += 1
}
```
