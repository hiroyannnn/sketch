///|
test "hyperloglog/invalid precision" {
  inspect(try? HyperLogLog::new(precision=3), content="Err(InvalidPrecision)")
  inspect(try? HyperLogLog::new(precision=19), content="Err(InvalidPrecision)")
}

///|
test "hyperloglog/valid precision boundaries" {
  let _ = try! HyperLogLog::new(precision=4)
  let _ = try! HyperLogLog::new(precision=18)
}

///|
test "hyperloglog/empty count" {
  let hll = try! HyperLogLog::new()
  inspect(hll.count(), content="0")
}

///|
test "hyperloglog/single element" {
  let hll = try! HyperLogLog::new()
  hll.add("hello")
  let est = hll.count()
  assert_true(est > 0.5 && est < 1.5)
}

///|
test "hyperloglog/duplicates count as one" {
  let hll = try! HyperLogLog::new()
  for i = 0; i < 100; i = i + 1 {
    hll.add("same")
  }
  let est = hll.count()
  assert_true(est < 3.0)
}

///|
test "hyperloglog/cardinality estimate" {
  let hll = try! HyperLogLog::new()
  for i in 0..<1000 {
    hll.add("item-\{i}")
  }
  let est = hll.count()
  assert_true(est > 900.0 && est < 1100.0)
}

///|
test "hyperloglog/merge success" {
  let hll1 = try! HyperLogLog::new()
  let hll2 = try! HyperLogLog::new()
  for i in 0..<500 {
    hll1.add("a-\{i}")
  }
  for i in 0..<500 {
    hll2.add("b-\{i}")
  }
  let merged = try! hll1.merge(hll2)
  let est = merged.count()
  assert_true(est > 800.0 && est < 1200.0)
}

///|
test "hyperloglog/merge precision mismatch" {
  let hll1 = try! HyperLogLog::new(precision=8)
  let hll2 = try! HyperLogLog::new(precision=10)
  inspect(try? hll1.merge(hll2), content="Err(PrecisionMismatch)")
}

///|
test "hyperloglog/precision boundary min" {
  // precision=4 → 16 registers. Verify basic cardinality with minimal registers.
  let hll = try! HyperLogLog::new(precision=4)
  for i in 0..<100 {
    hll.add("p4-\{i}")
  }
  let est = hll.count()
  // precision=4 has ~26% standard error, so allow wide range
  assert_true(est > 50.0 && est < 200.0)
}

///|
test "hyperloglog/precision boundary max" {
  // precision=18 → 262144 registers. Should be very accurate.
  let hll = try! HyperLogLog::new(precision=18)
  for i in 0..<1000 {
    hll.add("p18-\{i}")
  }
  let est = hll.count()
  // precision=18 has ~0.4% standard error, so tight range
  assert_true(est > 980.0 && est < 1020.0)
}

///|
test "hyperloglog/different precisions consistent" {
  // The same elements added to different precisions should give
  // estimates in the same order of magnitude.
  let hll8 = try! HyperLogLog::new(precision=8)
  let hll12 = try! HyperLogLog::new(precision=12)
  for i in 0..<500 {
    hll8.add("shared-\{i}")
    hll12.add("shared-\{i}")
  }
  let est8 = hll8.count()
  let est12 = hll12.count()
  assert_true(est8 > 300.0 && est8 < 700.0)
  assert_true(est12 > 450.0 && est12 < 550.0)
}
