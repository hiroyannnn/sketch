// Cuckoo Filter membership tester.
//
// Reference: Fan et al., "Cuckoo filter: Practically better than Bloom",
// CoNEXT 2014.

///|
/// A Cuckoo Filter for approximate set membership testing.
pub struct CuckooFilter {
  buckets : Array[Array[Int]]
  bucket_size : Int
  num_buckets : Int
  mut size : Int
}

///|
fn next_power_of_two(n : Int) -> Int {
  if n <= 1 {
    return 1
  }
  let mut p = 1
  while p < n {
    p = p * 2
  }
  p
}

///|
fn cf_fingerprint(value : String) -> Int {
  let raw = murmurhash3(value).land(255)
  if raw == 0 { 1 } else { raw }
}

///|
fn cf_alt_bucket(idx : Int, fp : Int, num_buckets : Int) -> Int {
  // Mix the fingerprint with a constant and XOR with the current index.
  // num_buckets is always a power of two so AND-masking is safe.
  idx.lxor((fp * 1540483477).lsr(1).land(num_buckets - 1))
}

///|
fn CuckooFilter::bucket_add(
  self : CuckooFilter,
  bucket : Int,
  fp : Int
) -> Bool {
  for j in 0..<self.bucket_size {
    if self.buckets[bucket][j] == 0 {
      self.buckets[bucket][j] = fp
      return true
    }
  }
  false
}

///|
fn CuckooFilter::bucket_has(
  self : CuckooFilter,
  bucket : Int,
  fp : Int
) -> Bool {
  for j in 0..<self.bucket_size {
    if self.buckets[bucket][j] == fp {
      return true
    }
  }
  false
}

///|
fn CuckooFilter::bucket_del(
  self : CuckooFilter,
  bucket : Int,
  fp : Int
) -> Bool {
  for j in 0..<self.bucket_size {
    if self.buckets[bucket][j] == fp {
      self.buckets[bucket][j] = 0
      return true
    }
  }
  false
}

///|
/// Creates a new `CuckooFilter`.
///
/// * `capacity` — approximate maximum number of items (default 1024).
/// * `bucket_size` — fingerprints per bucket (default 4).
pub fn CuckooFilter::new(
  capacity~ : Int = 1024,
  bucket_size~ : Int = 4
) -> CuckooFilter {
  let nb = if capacity / bucket_size > 0 { capacity / bucket_size } else { 1 }
  let num_buckets = next_power_of_two(nb)
  let buckets : Array[Array[Int]] = []
  for i = 0; i < num_buckets; i = i + 1 {
    buckets.push(Array::make(bucket_size, 0))
  }
  { buckets, bucket_size, num_buckets, size: 0 }
}

///|
/// Inserts `value` into the filter. Returns `true` on success, `false` when
/// the filter is too full to relocate fingerprints.
pub fn CuckooFilter::insert(self : CuckooFilter, value : String) -> Bool {
  let fp = cf_fingerprint(value)
  let h = murmurhash3(value).lsr(1).land(self.num_buckets - 1)
  let i1 = h
  let i2 = cf_alt_bucket(i1, fp, self.num_buckets)
  if self.bucket_add(i1, fp) {
    self.size = self.size + 1
    return true
  }
  if self.bucket_add(i2, fp) {
    self.size = self.size + 1
    return true
  }
  // Kick-out relocation (up to 500 iterations)
  let mut cur_idx = i1
  let mut cur_fp = fp
  for kick = 0; kick < 500; kick = kick + 1 {
    let slot = kick % self.bucket_size
    let evicted = self.buckets[cur_idx][slot]
    self.buckets[cur_idx][slot] = cur_fp
    if evicted == 0 {
      self.size = self.size + 1
      return true
    }
    cur_fp = evicted
    cur_idx = cf_alt_bucket(cur_idx, cur_fp, self.num_buckets)
    if self.bucket_add(cur_idx, cur_fp) {
      self.size = self.size + 1
      return true
    }
  }
  false
}

///|
/// Returns `true` if `value` may be in the filter (with possible false
/// positives).
pub fn CuckooFilter::contains(self : CuckooFilter, value : String) -> Bool {
  let fp = cf_fingerprint(value)
  let h = murmurhash3(value).lsr(1).land(self.num_buckets - 1)
  let i1 = h
  let i2 = cf_alt_bucket(i1, fp, self.num_buckets)
  self.bucket_has(i1, fp) || self.bucket_has(i2, fp)
}

///|
/// Removes one occurrence of `value` from the filter. Returns `true` if the
/// fingerprint was found and removed.
///
/// Only remove items that were actually inserted to avoid corrupting the
/// filter state.
pub fn CuckooFilter::remove(self : CuckooFilter, value : String) -> Bool {
  let fp = cf_fingerprint(value)
  let h = murmurhash3(value).lsr(1).land(self.num_buckets - 1)
  let i1 = h
  let i2 = cf_alt_bucket(i1, fp, self.num_buckets)
  if self.bucket_del(i1, fp) {
    self.size = self.size - 1
    return true
  }
  if self.bucket_del(i2, fp) {
    self.size = self.size - 1
    return true
  }
  false
}

///|
/// Returns the number of items currently in the filter.
pub fn CuckooFilter::count(self : CuckooFilter) -> Int {
  self.size
}
