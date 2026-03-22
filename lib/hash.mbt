// MurmurHash3 32-bit — pure MoonBit port of the public-domain algorithm by
// Austin Appleby. https://github.com/aappleby/smhasher

///|
/// Logical (unsigned) right shift for Int via UInt reinterpretation.
fn lsr32(x : Int, n : Int) -> Int {
  (x.reinterpret_as_uint() >> n).reinterpret_as_int()
}

///|
fn rotl32(x : Int, r : Int) -> Int {
  (x << r).lor(lsr32(x, 32 - r))
}

///|
fn fmix32(h : Int) -> Int {
  let mut h = h
  h = h.lxor(lsr32(h, 16))
  h = h * -2048144789 // 0x85ebca6b
  h = h.lxor(lsr32(h, 13))
  h = h * -1028477387 // 0xc2b2ae35
  h = h.lxor(lsr32(h, 16))
  h
}

///|
/// Computes the MurmurHash3 32-bit hash of `key`.
///
/// `seed` allows generating multiple independent hash functions from the same
/// key — pass different seed values (e.g. 0, 1, 2 …) to obtain independent
/// hashes for structures like Count-Min Sketch.
pub fn murmurhash3(key : String, seed? : Int = 0) -> Int {
  let c1 = -862048943 // 0xcc9e2d51
  let c2 = 461845907 // 0x1b873593
  let chars = key.to_array()
  let len = chars.length()
  let nblocks = len / 4
  let mut h = seed
  for i in 0..<nblocks {
    let base = i * 4
    let mut k = chars[base]
      .to_int()
      .lor(chars[base + 1].to_int() << 8)
      .lor(chars[base + 2].to_int() << 16)
      .lor(chars[base + 3].to_int() << 24)
    k = k * c1
    k = rotl32(k, 15)
    k = k * c2
    h = h.lxor(k)
    h = rotl32(h, 13)
    h = h * 5 - 430675100 // + 0xe6546b64
  }
  let tail = nblocks * 4
  let rem = len - tail
  let mut k = 0
  if rem >= 3 {
    k = k.lxor(chars[tail + 2].to_int() << 16)
  }
  if rem >= 2 {
    k = k.lxor(chars[tail + 1].to_int() << 8)
  }
  if rem >= 1 {
    k = k.lxor(chars[tail].to_int())
    k = k * c1
    k = rotl32(k, 15)
    k = k * c2
    h = h.lxor(k)
  }
  h = h.lxor(len)
  fmix32(h)
}
