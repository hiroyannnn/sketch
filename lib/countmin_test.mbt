///|
test "countmin/invalid dimensions" {
  inspect(
    try? CountMinSketch::new(width=0, depth=5),
    content="Err(InvalidDimension)",
  )
  inspect(
    try? CountMinSketch::new(width=100, depth=0),
    content="Err(InvalidDimension)",
  )
  inspect(
    try? CountMinSketch::new(width=-1, depth=5),
    content="Err(InvalidDimension)",
  )
  inspect(
    try? CountMinSketch::new(width=100, depth=-1),
    content="Err(InvalidDimension)",
  )
}

///|
test "countmin/new and estimate empty" {
  let cm = try! CountMinSketch::new()
  inspect(cm.estimate("hello"), content="0")
}

///|
test "countmin/add and estimate" {
  let cm = try! CountMinSketch::new()
  cm.add("hello")
  cm.add("hello")
  cm.add("hello")
  inspect(cm.estimate("hello"), content="3")
}

///|
test "countmin/add with count" {
  let cm = try! CountMinSketch::new()
  cm.add("world", count=5)
  let est = cm.estimate("world")
  assert_true(est >= 5)
}

///|
test "countmin/distinct keys" {
  let cm = try! CountMinSketch::new()
  cm.add("apple", count=3)
  cm.add("banana", count=7)
  assert_true(cm.estimate("apple") >= 3)
  assert_true(cm.estimate("banana") >= 7)
}

///|
test "countmin/merge success" {
  let cm1 = try! CountMinSketch::new()
  let cm2 = try! CountMinSketch::new()
  cm1.add("x", count=4)
  cm2.add("x", count=6)
  let merged = try! cm1.merge(cm2)
  inspect(merged.estimate("x"), content="10")
}

///|
test "countmin/merge dimension mismatch" {
  let cm1 = try! CountMinSketch::new(width=100, depth=3)
  let cm2 = try! CountMinSketch::new(width=200, depth=3)
  inspect(try? cm1.merge(cm2), content="Err(PrecisionMismatch)")
}
