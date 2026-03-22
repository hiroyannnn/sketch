// Count-Min Sketch frequency estimator.
//
// Reference: Cormode & Muthukrishnan, "An improved data stream summary:
// The Count-Min Sketch and its applications", J. Algorithms, 2005.

///|
/// A Count-Min Sketch frequency estimator.
pub struct CountMinSketch {
  table : Array[Array[Int]]
  width : Int
  depth : Int
} derive(Show)

///|
/// Creates a new `CountMinSketch`.
///
/// * `width` — number of counters per row (default 1000).
/// * `depth` — number of hash functions / rows (default 5).
///
/// Returns `Err(InvalidDimension)` when `width` or `depth` is not positive.
pub fn CountMinSketch::new(
  width~ : Int = 1000,
  depth~ : Int = 5
) -> CountMinSketch raise SketchError {
  if width <= 0 || depth <= 0 {
    raise InvalidDimension
  }
  let table : Array[Array[Int]] = Array::new()
  for i = 0; i < depth; i = i + 1 {
    table.push(Array::make(width, 0))
  }
  { table, width, depth }
}

///|
fn cms_col(hash : Int, width : Int) -> Int {
  lsr32(hash, 1) % width
}

///|
/// Increments the frequency of `value` by `count` (default 1).
pub fn CountMinSketch::add(
  self : CountMinSketch,
  value : String,
  count~ : Int = 1
) -> Unit {
  for i in 0..<self.depth {
    let h = cms_col(murmurhash3(value, seed=i), self.width)
    self.table[i][h] = self.table[i][h] + count
  }
}

///|
/// Returns the estimated frequency of `value`.
pub fn CountMinSketch::estimate(
  self : CountMinSketch,
  value : String
) -> Int {
  let mut result = 2147483647
  for i in 0..<self.depth {
    let h = cms_col(murmurhash3(value, seed=i), self.width)
    let c = self.table[i][h]
    if c < result {
      result = c
    }
  }
  result
}

///|
/// Merges `other` into `self` and returns a new `CountMinSketch`.
///
/// Both sketches must have the same `width` and `depth`; otherwise
/// `Err(PrecisionMismatch)` is returned.
pub fn CountMinSketch::merge(
  self : CountMinSketch,
  other : CountMinSketch
) -> CountMinSketch raise SketchError {
  if self.width != other.width || self.depth != other.depth {
    raise PrecisionMismatch
  }
  // width and depth are already validated, so this cannot fail.
  let result = try! CountMinSketch::new(width=self.width, depth=self.depth)
  for i in 0..<self.depth {
    for j in 0..<self.width {
      result.table[i][j] = self.table[i][j] + other.table[i][j]
    }
  }
  result
}
