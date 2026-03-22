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

```moonbit
let hll = try! @sketch.HyperLogLog::new()
for i in 0..<1000 {
  hll.add("item-\{i}")
}
let est = hll.count()
// est ≈ 1000 (standard error ~0.8% at default precision=14)
```

### Count-Min Sketch — frequency estimation

```moonbit
let cm = try! @sketch.CountMinSketch::new()
cm.add("apple", count=5)
cm.add("banana")
cm.estimate("apple")  // >= 5
cm.estimate("banana") // >= 1
```

### Cuckoo Filter — set membership

```moonbit
let cf = try! @sketch.CuckooFilter::new()
cf.insert("hello")   // true
cf.contains("hello")  // true
cf.contains("world")  // false
cf.remove("hello")    // true
cf.contains("hello")  // false
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
