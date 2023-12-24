# Delauney-Triangulation
Delauney Triangulation in Swift. Also includes constraints from the Sloan technique.</br></br>

I started my triangulation journey over 15 years ago. Now that 15 years have passed, I finally have an upgrade to share. This is a very fast and accurate triangulation system. It will always work if it's used correctly.</br></br>

![alt text](https://github.com/nraptis/DelauneyTriangulator/blob/main/delauney.png)</br></br>

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

DelauneyTriangulator.shared.delauneyConstrainedTriangulation(points: points,
                                                             hull: hull)

for triangle in DelauneyTriangulator.shared.triangles {
    print("Triangle: [(\(triangle.point1.x), \(triangle.point1.y)), (\(triangle.point2.x), \(triangle.point2.y)), (\(triangle.point3.x), \(triangle.point3.y))]")
}
```
