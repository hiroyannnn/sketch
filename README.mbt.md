# hiroyannnn/sketch

MoonBit probabilistic data structures library — HyperLogLog, Count-Min Sketch,
and Cuckoo Filter.

## Installation

```
moon add hiroyannnn/sketch
```

Import in `moon.pkg`:

```
import {
  "hiroyannnn/sketch" @sketch,
}
```

## Usage

### HyperLogLog — cardinality estimation

```mbt nocheck
///|
test "HyperLogLog basic" {
  let hll = try! @sketch.HyperLogLog::new()
  for i in 0..<1000 {
    hll.add("item-\{i}")
  }
  let est = hll.count()
  // Estimate within ~2 % of 1000
  assert_true(est > 950.0 && est < 1050.0)
}

///|
test "HyperLogLog merge" {
  let a = try! @sketch.HyperLogLog::new()
  let b = try! @sketch.HyperLogLog::new()
  a.add("x")
  b.add("y")
  let merged = try! a.merge(b)
  assert_true(merged.count() >= 1.0)
}

///|
test "HyperLogLog invalid precision" {
  inspect(
    try? @sketch.HyperLogLog::new(precision=3),
    content="Err(InvalidPrecision)",
  )
}
```

### Count-Min Sketch — frequency estimation

```mbt nocheck
///|
test "CountMinSketch basic" {
  let cm = try! @sketch.CountMinSketch::new()
  cm.add("apple", count=5)
  cm.add("banana")
  assert_true(cm.estimate("apple") >= 5)
  assert_true(cm.estimate("banana") >= 1)
}

///|
test "CountMinSketch merge" {
  let cm1 = try! @sketch.CountMinSketch::new()
  let cm2 = try! @sketch.CountMinSketch::new()
  cm1.add("x", count=3)
  cm2.add("x", count=4)
  let merged = try! cm1.merge(cm2)
  assert_true(merged.estimate("x") >= 7)
}
```

### Cuckoo Filter — set membership

```mbt nocheck
///|
test "CuckooFilter basic" {
  let cf = @sketch.CuckooFilter::new()
  assert_true(cf.insert("hello"))
  assert_true(cf.contains("hello"))
  assert_true(!cf.contains("world"))
  assert_true(cf.remove("hello"))
  assert_true(!cf.contains("hello"))
}
```

## API reference

### SketchError

| Variant | Meaning |
|---|---|
| `InvalidPrecision` | HyperLogLog precision outside [4, 18] |
| `InvalidDimension` | width, depth, capacity, or bucket_size is not positive |
| `PrecisionMismatch` | Merging two sketches with different parameters |

### HyperLogLog

| Function | Signature | Description |
|---|---|---|
| `HyperLogLog::new` | `(precision? : Int) -> HyperLogLog raise SketchError` | Create (default precision 14) |
| `add` | `(HyperLogLog, String) -> Unit` | Add a value |
| `count` | `(HyperLogLog) -> Double` | Estimate cardinality |
| `merge` | `(HyperLogLog, HyperLogLog) -> HyperLogLog raise SketchError` | Merge two sketches |

### CountMinSketch

| Function | Signature | Description |
|---|---|---|
| `CountMinSketch::new` | `(width? : Int, depth? : Int) -> CountMinSketch raise SketchError` | Create (default width 1000, depth 5) |
| `add` | `(CountMinSketch, String, count? : Int) -> Unit` | Increment frequency |
| `estimate` | `(CountMinSketch, String) -> Int` | Query frequency |
| `merge` | `(CountMinSketch, CountMinSketch) -> CountMinSketch raise SketchError` | Merge two sketches |

### CuckooFilter

| Function | Signature | Description |
|---|---|---|
| `CuckooFilter::new` | `(capacity? : Int, bucket_size? : Int) -> CuckooFilter raise SketchError` | Create |
| `insert` | `(CuckooFilter, String) -> Bool` | Insert (false if full) |
| `contains` | `(CuckooFilter, String) -> Bool` | Membership query |
| `remove` | `(CuckooFilter, String) -> Bool` | Remove (false if not found) |
| `count` | `(CuckooFilter) -> Int` | Number of stored items |

## Acknowledgments

See [NOTICE](NOTICE) for algorithm citations and license information.

## License

Apache-2.0
