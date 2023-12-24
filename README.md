# Delauney-Triangulation
Delauney Triangulation in Swift. Also includes constraints from the Sloan technique.</br></br>

I started my triangulation journey over 15 years ago. Now that 15 years have passed, I finally have an upgrade to share. This is a very fast and accurate triangulation system. Please reach out to me if you find test cases that do not work.</br></br>

![alt text](https://github.com/nraptis/DelauneyTriangulator/blob/main/delauney.png)</br></br>

https://www.newcastle.edu.au/__data/assets/pdf_file/0017/22508/13_A-fast-algorithm-for-constructing-Delaunay-triangulations-in-the-plane.pdf

I started my triangulation journey over 15 years ago. Now that 15 years have passed, I am ready to share my code with the world. I have improved on existing algorithms by utilizing buckets to reduce the bottlenecks by up to 20,000%. (These only apply to constrained triangulation)</br></br>

Exaple of using Constrained Delauney:</br></br>

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

for triangle in triangulator.triangles {
    print("Triangle: [(\(triangle.point1.x), \(triangle.point1.y)), (\(triangle.point2.x), \(triangle.point2.y)), (\(triangle.point3.x), \(triangle.point3.y))]")
    
}
```

Exaple of using Standard Delauney:</br></br>

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

for triangle in triangulator.triangles {
    print("Triangle: [(\(triangle.point1.x), \(triangle.point1.y)), (\(triangle.point2.x), \(triangle.point2.y)), (\(triangle.point3.x), \(triangle.point3.y))]")
    
}
```
