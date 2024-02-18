# Delauney-Triangulation
Delauney Triangulation in Swift. Also includes Delauney Triangulation with edge constraints. To this algorithm, I have added a signifigant speed improvement using buckets (EdgeGridBucket.swift) and (PolyPointBucket.swift).</br></br>

![alt text](https://github.com/nraptis/DelauneyTriangulator/blob/main/delauney.png)</br></br>

https://www.newcastle.edu.au/__data/assets/pdf_file/0017/22508/13_A-fast-algorithm-for-constructing-Delaunay-triangulations-in-the-plane.pdf

I started my triangulation journey over 15 years ago. Now that 15 years have passed, I am ready to share my code with the world. I have improved on existing algorithms by utilizing buckets to reduce the bottlenecks by up to 20,000%. (These only apply to constrained triangulation)</br></br>

Please note that the Constrained triangulation is technically no longer a "Delauney triangulation," as it is not a convex hull.</br></br>

Example of using Constrained Delauney with "hull" as the outer polygon:</br>

```
struct MyPoint: PointProtocol {
    var x: Float
    var y: Float
}

let hull = [
    MyPoint(x: -100.0, y: -100.0),
    MyPoint(x: 100.0, y: -100.0),
    MyPoint(x: 0.0, y: 100.0)
]

let points = [
    MyPoint(x: -25.0, y: -10.0),
    MyPoint(x: 50.0, y: 10.0)
]

let triangulator = DelauneyTriangulator.shared
triangulator.triangulate(points: points,
                         pointCount: points.count,
                         hull: hull,
                         hullCount: hull.count,
                         superTriangleSize: 8192.0)

var triangleIndex = 0
while triangleIndex < triangulator.triangleCount {
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

Example of using Standard Delauney:</br>
```
struct MyPoint: PointProtocol {
    var x: Float
    var y: Float
}

let points = [
    MyPoint(x: -100.0, y: -100.0),
    MyPoint(x: 100.0, y: -100.0),
    MyPoint(x: 0.0, y: 0.0),
    MyPoint(x: 0.0, y: 100.0)
]

let triangulator = DelauneyTriangulator.shared
triangulator.triangulate(points: points,
                         pointCount: points.count)

var triangleIndex = 0
while triangleIndex < triangulator.triangleCount {
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

Note: There is a rare bug in this demo app where the polygon can have a point which is on a line. In this case, it will fail to triangulate. The triangulation still works, but in this rare case it has invalid input.

Note: This has gone through speed benchmarking. We are recycling memory in a klever way, so make sure that instead of using
"tringles.count" you are using "triangleCount" as they may not agree.
