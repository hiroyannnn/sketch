///|
/// Error type for sketch operations.
///
/// * `PrecisionMismatch` — two sketches have incompatible parameters.
/// * `InvalidPrecision` — precision is outside the allowed range (4–18).
pub(all) suberror SketchError {
  PrecisionMismatch
  InvalidPrecision
}

///|
pub impl Show for SketchError with output(self, logger) {
  match self {
    PrecisionMismatch => logger.write_string("PrecisionMismatch")
    InvalidPrecision => logger.write_string("InvalidPrecision")
  }
}
