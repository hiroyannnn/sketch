// HyperLogLog cardinality estimator.
//
// Reference: Flajolet et al., "HyperLogLog: the analysis of a near-optimal
// cardinality estimation algorithm", DMTCS 2007.

///|
/// A HyperLogLog cardinality estimator.
pub struct HyperLogLog {
  priv registers : Array[Int]
  priv precision : Int
} derive(Show)

///|
/// Creates a new `HyperLogLog` with the given `precision` (4–18).
///
/// The number of registers is `2^precision`; higher precision gives lower
/// relative error at the cost of more memory.
///
/// Returns `Err(InvalidPrecision)` when `precision` is outside [4, 18].
pub fn HyperLogLog::new(precision? : Int = 14) -> HyperLogLog raise SketchError {
  if precision < 4 || precision > 18 {
    raise InvalidPrecision
  }
  let m = 1 << precision
  { registers: Array::make(m, 0), precision }
}

///|
/// Computes the rank (position of the first 1-bit) in the upper (32 - precision)
/// bits of `hash`. The lower `precision` bits are used as the register index.
///
/// `w = hash >>> precision` places the relevant bits in [0, 32-precision).
/// `w.clz()` counts leading zeros over the full 32-bit width, which includes
/// `precision` extra zero positions — hence we subtract `precision` and add 1.
/// When `w == 0` all (32 - precision) bits are zero, giving rank = 32 - precision + 1.
fn hll_rank(hash : Int, precision : Int) -> Int {
  let w = lsr32(hash, precision)
  if w == 0 {
    32 - precision + 1
  } else {
    w.clz() - precision + 1
  }
}

///|
/// Adds `value` to the sketch.
pub fn HyperLogLog::add(self : HyperLogLog, value : String) -> Unit {
  let h = murmurhash3(value)
  let m = self.registers.length()
  let j = h.land(m - 1)
  let r = hll_rank(h, self.precision)
  if r > self.registers[j] {
    self.registers[j] = r
  }
}

///|
/// Estimates the number of distinct values added so far.
pub fn HyperLogLog::count(self : HyperLogLog) -> Double {
  let m = self.registers.length()
  let m_f = m.to_double()
  let mut sum = 0.0
  for i in 0..<m {
    sum += 1.0 / (1 << self.registers[i]).to_double()
  }
  let alpha = match m {
    16 => 0.673
    32 => 0.697
    64 => 0.709
    _ => 0.7213 / (1.0 + 1.079 / m_f)
  }
  let e = alpha * m_f * m_f / sum
  // Small range correction: Linear Counting
  if e < 2.5 * m_f {
    let mut v = 0
    for i in 0..<m {
      if self.registers[i] == 0 {
        v = v + 1
      }
    }
    if v > 0 {
      return m_f * @math.ln(m_f / v.to_double())
    }
  }
  // Large range correction
  let two32 = 4294967296.0
  if e > two32 / 30.0 {
    return -(two32 * @math.ln(1.0 - e / two32))
  }
  e
}

///|
/// Merges `other` into `self` and returns a new `HyperLogLog`.
///
/// Both sketches must have the same `precision`; otherwise
/// `Err(PrecisionMismatch)` is returned.
pub fn HyperLogLog::merge(
  self : HyperLogLog,
  other : HyperLogLog,
) -> HyperLogLog raise SketchError {
  if self.precision != other.precision {
    raise PrecisionMismatch
  }
  let m = self.registers.length()
  let result = { registers: Array::make(m, 0), precision: self.precision }
  for i in 0..<m {
    let a = self.registers[i]
    let b = other.registers[i]
    result.registers[i] = if a > b { a } else { b }
  }
  result
}
