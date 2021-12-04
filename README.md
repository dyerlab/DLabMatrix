![Dyerlab logo](https://live.staticflickr.com/65535/51722755557_2368c8fb01_o_d.jpg)

# DLMatrix

![](https://img.shields.io/badge/license-GPLv3-green) ![](https://img.shields.io/badge/maintained%3F-Yes-green) ![](https://img.shields.io/badge/swift-5.5-green) ![](https://img.shields.io/badge/iOS-14.0-green) ![](https://img.shields.io/badge/macOS-11-green)

This package is the foundation layer for all matrix algebra routines needed in software developed for the iOS and OSX platforms from the [DyerLab](https://dyerlab.org).  The motivation herenotion here is to provide an abstraction layer relying as much upon the Swift Accelerate framework to allow population genetic and spatial analytic routines to be easily added to any deliverable product.


<a name="Installation"></a>
## Installation

**Swift Package Manager** (XCode 13)

1. Select **File** > **Swift Packages** > **Add Package Dependency…** from the **File** menu.
2. Paste `https://github.com/dyerlab/DLMatrix.git` in the dialog box.
3. Follow the Xcode's instruction to complete the installation.

> Why not CocoaPods, or Carthage, or blank?

Supporting multiple dependency managers makes maintaining a library exponentially more complicated and time consuming.  Since, the **Swift Package Manager** is integrated with Xcode 11 (and greater), it's the easiest choice to support going further.

---

This package defines the following two objects:

- <a href="#Vector">Vector</a> A `Double` vector object representing a single numerical vector.
- <a href="#Matrix">Matrix</a> A 2-dimensional matrix object that holds `Double` types.

<a name="Vector"></a>
### Vector Objects

A Vector object is simple `[Double]` with the following extensions.


**Instance Variables**:

- `sum: Double`
- `magnitude:Vector` The vector length.
- `x:Double` & `y:Double` (for length >1 vectors)
- `normal:Vector` Normalize vector for length = 1.0
- `asCGPoint:CGPoint` Quick conversion to `CGPoint`
- `asSCNVector3:SCNVector3` Quick conversion to `SCNVector3`


**Static Constructors**

- `zeros(_ length: Int) -> Vector` Make a new vector with zeros.
- `random( length: Int, type: RangeEnum = .uniform_0_1) -> Vector` Make a 
 

**Instance Functions**

- `.smallest(other: Vector) -> Vector` Returns a `Vector` with minimal values from each.
- `.largest(other: Vector) -> Vector` Returns a `Vector` with maximal values from each. 
- `.constrain(minimum: Double, maximum: Double) -> Vector` Returns vector with values bound on the range `[minimum ... maximum]`
- `.limitAnnealingMagnitude( temp: Double) -> Vector` Limits movement vector distance for simulated annealing functions.



 
#### Operator Overloads

The following operators are defined for the `Vector` object `v`:

- `v + scalar` 
- `v - scalar`
- `v * scalar`
- `v / scalar` Scaling of a vector
- `v * v` Vector elementwise multiplication
- `v .* v` Vector Multiplication (scalar result)
- `v == v` Equality 

#### Protocols

The `Vector` object conforms to the following protocols:

-  

A protocol `asVector()` is defined for derivative objects to advertise that they can yield a 



<a name="Matrix"></a>
### Matrix Objects

A matrix object is a 2-dimensional `[Double]` object with the following additions.



The following operators are defined for the `Matrix` object `M`:

- `M + scalar`
- `M - scalar`
- `M * scalar` Scaling of a matrix
- `M / scalar` Scaling of a matrix
- `M * M` Matrix elementwise multiplication
- `M .* M` Matrix Multiplication 

