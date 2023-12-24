# Manual-Spline
Cubic Spline where tangents are either manually or automatically computed.</br></br>

Created from math that I scribbled down on the inside of my trapper keeper in 6th grade. It was not until age 19 that I turned it into a functioning computer program. 20 years and 15 iterations later, all the kinks are worked out.</br></br>

![alt text](https://raw.githubusercontent.com/nraptis/Manual-Spline/main/spline_manual.png?raw=true)</br></br>

```
let spline = ManualSpline()

spline.addControlPoint(100.0, 200.0)
spline.addControlPoint(150.0, 300.0)
spline.addControlPoint(80.0, 420.0)

// use a manual tangent at index 1. (150.0, 300.0)
spline.enableManualControlTan(at: 1,
                              inTanX: -10.0, inTanY: 20.0,
                              outTanX: 10.0, outTanY: -20.0)

// "closed = true" will connect the last
// point to the first point smoothly
spline.solve(closed: true)

// walk through the spline
var pos = Float(0.0)
while pos <= spline.maxPos {
    
    let smoothX = spline.getX(pos)
    let smoothY = spline.getY(pos)
    
    print("spline pos @ \(String(format: "%.1f", pos)) = {\(String(format: "%.1f", smoothX)), \(String(format: "%.1f", smoothY))}")
    
    pos += 0.1
}
```
