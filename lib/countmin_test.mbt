///|
test "countmin/invalid dimensions" {
  try @lib.CountMinSketch::new(width=0, depth=5) catch {
    e => inspect(e, content="InvalidDimension")
  } noraise {
    _ => fail("expected InvalidDimension")
  }
  try @lib.CountMinSketch::new(width=100, depth=0) catch {
    e => inspect(e, content="InvalidDimension")
  } noraise {
    _ => fail("expected InvalidDimension")
  }
  try @lib.CountMinSketch::new(width=-1, depth=5) catch {
    e => inspect(e, content="InvalidDimension")
  } noraise {
    _ => fail("expected InvalidDimension")
  }
  try @lib.CountMinSketch::new(width=100, depth=-1) catch {
    e => inspect(e, content="InvalidDimension")
  } noraise {
    _ => fail("expected InvalidDimension")
  }
}

///|
test "countmin/new and estimate empty" {
  let cm = try! @lib.CountMinSketch::new()
  inspect(cm.estimate("hello"), content="0")
}

///|
test "countmin/add and estimate" {
  let cm = try! @lib.CountMinSketch::new()
  cm.add("hello")
  cm.add("hello")
  cm.add("hello")
  inspect(cm.estimate("hello"), content="3")
}

///|
test "countmin/add with count" {
  let cm = try! @lib.CountMinSketch::new()
  cm.add("world", count=5)
  let est = cm.estimate("world")
  assert_true(est >= 5)
}

///|
test "countmin/distinct keys" {
  let cm = try! @lib.CountMinSketch::new()
  cm.add("apple", count=3)
  cm.add("banana", count=7)
  assert_true(cm.estimate("apple") >= 3)
  assert_true(cm.estimate("banana") >= 7)
}

///|
test "countmin/merge success" {
  let cm1 = try! @lib.CountMinSketch::new()
  let cm2 = try! @lib.CountMinSketch::new()
  cm1.add("x", count=4)
  cm2.add("x", count=6)
  let merged = try! cm1.merge(cm2)
  inspect(merged.estimate("x"), content="10")
}

///|
test "countmin/merge dimension mismatch" {
  let cm1 = try! @lib.CountMinSketch::new(width=100, depth=3)
  let cm2 = try! @lib.CountMinSketch::new(width=200, depth=3)
  try cm1.merge(cm2) catch {
    e => inspect(e, content="PrecisionMismatch")
  } noraise {
    _ => fail("expected PrecisionMismatch")
  }
}
