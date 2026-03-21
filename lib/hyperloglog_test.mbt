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
