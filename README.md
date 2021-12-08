![Dyerlab logo](https://live.staticflickr.com/65535/51722755557_2368c8fb01_o_d.jpg)

# DLabMatrix

![](https://img.shields.io/badge/license-GPLv3-green) ![](https://img.shields.io/badge/maintained%3F-Yes-green) ![](https://img.shields.io/badge/swift-5.5-green) ![](https://img.shields.io/badge/iOS-14.0-green) ![](https://img.shields.io/badge/macOS-11-green)

Current Version: 1.0.1

This package is the foundation layer for all matrix algebra routines needed in software developed for the iOS and OSX platforms from the [DyerLab](https://dyerlab.org).  The motivation herenotion here is to provide an abstraction layer relying as much upon the Swift `Accelerate` framework to allow population genetic and spatial analytic routines to be easily added to any deliverable product.


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
- <a href="#RangeEnum">Random Range Enumerator</a> A quick enumerator to define the range of random numbers to estimate.

This packages defines the following general functions:

- <a href="#GINV">GeneralizedInverse()</a> A generalized matrix inverse.
- <a href="#PCA">PCRotation()</a> A principal component analysis function.
- <a href="#SVD">SingularValueDecomposition()</a> An implementation of a Singular Value Decomposition.
 

<a name="Vector"></a>
### Vector Objects

A Vector object is simple `[Double]` useable for normal algebraic operations.  The 


**Instance Variables**:

- `sum: Double`
- `magnitude:Vector` The vector length.
- `x:Double` & `y:Double` (for length >1 vectors)
- `normal:Vector` Normalize vector for length = 1.0
- `asCGPoint:CGPoint` Quick conversion to `CGPoint`
- `asSCNVector3:SCNVector3` Quick conversion to `SCNVector3`
- `asCovariance: Matrix` Converts (presumably) instance of distance to covariance.
- `asDistance: Matrix` Converts (presumably) instance of covariance matrix to distance.

**Static Constructors**

- `zeros(_ length: Int) -> Vector` Make a new vector with zeros.
- `random( length: Int, type: RangeEnum = .uniform_0_1) -> Vector` Make a 
 

**Instance Functions**

- `.distance(other: Vector) -> Double` Distance separating two vectors. 
- `.smallest(other: Vector) -> Vector` Returns a `Vector` with minimal values from each.
- `.largest(other: Vector) -> Vector` Returns a `Vector` with maximal values from each. 
- `.constrain(minimum: Double, maximum: Double) -> Vector` Returns vector with values bound on the range `[minimum ... maximum]`
- `.limitAnnealingMagnitude( temp: Double) -> Vector` Limits movement vector distance for simulated annealing functions.

**Static Functions**
- `.designMatrix( strata: [String] ) -> Matrix` Returns (N x K) design matrix.
- `.idempotentHatMatrix( strata: [String] ) -> Matrix` Returns N x N idempotent Hat matrix, **H**.
 
#### Operator Overloads

The following operators are defined for the `Vector` object `v`:

- `v + scalar` 
- `v - scalar`
- `v * scalar`
- `v / scalar` Scaling of a vector
- `v + v` Vector elementwise addition
- `v - v` Vector elementwise subtraction
- `v * v` Vector elementwise multiplication
- `v .* v` Vector Multiplication (scalar result)
- `v == v` Equality 

#### Protocols

The `Vector` object defines the protocol `VectorConvertable` which defined the required function `asVector() -> Vector` to advertise that they can yield a `Vector` object. 



<a name="Matrix"></a>
### Matrix Objects

A matrix object is a class that represents a 2-dimensional representation of type `Double`'s.  A `Matrix` has the following instance variables:

- `.rows: Int` The number of rows in the matrix.
- `.cols: Int` The number of columns in the matrix.
- `rowNames:[String]` Labels for rows in the matrix.
- `colNames:[String]` Labels for columns in the matrix.
- `diagonal:Vector` The diagonal of the matrix (get, set)
- `trace:Double` The trace of the matrix.
- `sum:Double` The sum of the values in the Matrix.
- `transpose:Matrix` Return the transposed version of this matrix.
- `description:String` Conforms to `CustomStringConvertible`

Constructors
- `Matrix(r,c,Vector)` Creates a new `Matrix` with `r` rows and `c` columns with values from `Vector`.
- `Matrix(r,c,ClosedRange)` Creates a new `Matrix` with `r` rows and `c` whose falues are equally spaced along a `ClosedRange<Double>`.
- `Matrix(r,c,rowNames,colNames)` Creates a new `Matrix` with `r` rows and `c` columns with values set to `0.0` but with the row and column names set by the vectors `rowNames` and `colNames` of length `r` and `c` (respectively).


The following operators are overloaded for an object of type `Matrix`:

- `[row,col]: Double` Overload of the subscript operator to access elements withing the `Matrix`.  Asking for values outside the size of the `Matrix` return `Double.nan` and setting those outside the size do nothing.
- `==` Conforms to `Equatable`
- `M + scalar` Shift values of a matrix
- `M - scalar` Shift values of a matrix
- `M * scalar` Scaling of a matrix
- `M / scalar` Scaling of a matrix
- `M + M` Matrix elementwise addition
- `M - M` Matrix elementwise addition
- `M * M` Matrix elementwise multiplication
- `M .* M` Matrix Multiplication 
- `M / M` Matrix elementwise division

The following functions are available for `Matrix` objects:
- `.center()` Centers the values of the matrix to `0.0`
- `.submatrix([rows],[cols]) -> Matrix` Returns submatrix defined by the integer arrays `[rows]` and `[cols`].
-  

#### Protocols

The `Matrix` object defines the protocol `MatrixConvertable` that defines a required function `asMatrix() -> Matrix` is to advertise that they can yield a `Matrix` object. 

<a name="RangeEnum"></a>
### RangeEnum

A simple enum defining the following values:
- `uniform_0_1` A uniform distribution bound to `[0.0 ... 1.0]`.
- `uniform_neg1_1` A uniform distribution bound on `[-1.0 ... 1.0]`.
- `normal_0_1` A value from the normal probability density function bound on `[0 ... 1]`.

This enum conforms to the following protocols:
- `Int`
- `CaseIterable`
- `Comoparable` Defines `<` operator.


### Algebraic Functions

<a name="GINV"></a> 

`GeneralizedInverse( X: Matrix ) -> Matrix` 

This returns a generalized inverse of the original matrix.

<a name="PCA"></a>

`PCRotation(X: Matrix) -> (d: Vector, V: Matrix, X: Matrix)?`

Performs a principal component rotation on the original data matrix `X` returning the eigenvalues in `d`, the loadings in `V` and the predicted projections of the original data in `X`.  If the original matrix was not factorable, no values are returned.

<a name="SVD"></a>

`SingularValueDecomposition(A: Matrix) -> (U: Matrix, d: Vector, V: Matrix)?` 

Performs a singular value spectral decomposition on the matrix `A` resulting in left and right eigenvalues (`U` and `V`) as well as eigenvalues in `d`. If the original matrix was not factorable, no values are returned.


