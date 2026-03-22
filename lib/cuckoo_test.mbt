///|
test "cuckoo/insert and contains" {
  let cf = CuckooFilter::new()
  assert_true(cf.insert("hello"))
  assert_true(cf.contains("hello"))
}

///|
test "cuckoo/not contains" {
  let cf = CuckooFilter::new()
  cf.insert("hello") |> ignore
  assert_true(!cf.contains("world"))
}

///|
test "cuckoo/remove" {
  let cf = CuckooFilter::new()
  cf.insert("hello") |> ignore
  assert_true(cf.contains("hello"))
  assert_true(cf.remove("hello"))
  assert_true(!cf.contains("hello"))
}

///|
test "cuckoo/remove non-existent" {
  let cf = CuckooFilter::new()
  assert_true(!cf.remove("nothing"))
}

///|
test "cuckoo/count" {
  let cf = CuckooFilter::new()
  inspect(cf.count(), content="0")
  cf.insert("a") |> ignore
  cf.insert("b") |> ignore
  cf.insert("c") |> ignore
  inspect(cf.count(), content="3")
}

///|
test "cuckoo/count after remove" {
  let cf = CuckooFilter::new()
  cf.insert("x") |> ignore
  cf.insert("y") |> ignore
  cf.remove("x") |> ignore
  inspect(cf.count(), content="1")
}

///|
test "cuckoo/many inserts" {
  let cf = CuckooFilter::new(capacity=2048)
  let mut inserted = 0
  for i in 0..<500 {
    if cf.insert("key-\{i}") {
      inserted = inserted + 1
    }
  }
  assert_true(inserted > 490)
  // All inserted items should be found
  let mut found = 0
  for i in 0..<500 {
    if cf.contains("key-\{i}") {
      found = found + 1
    }
  }
  assert_true(found >= inserted)
}

///|
test "cuckoo/high load insert success rate" {
  // With randomized kick-out, high-load inserts should succeed more often.
  // Fill to ~85% capacity — deterministic slot selection tends to fail earlier.
  let capacity = 512
  let cf = CuckooFilter::new(capacity~)
  let target = (capacity.to_double() * 0.85).to_int()
  let mut inserted = 0
  for i in 0..<target {
    if cf.insert("load-\{i}") {
      inserted = inserted + 1
    }
  }
  // Expect at least 90% of target inserts to succeed
  assert_true(inserted > (target.to_double() * 0.9).to_int())
}
