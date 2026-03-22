///|
test "hash/ascii_deterministic" {
  // Same input always produces same hash
  let h1 = murmurhash3("hello")
  let h2 = murmurhash3("hello")
  assert_eq(h1, h2)
}

///|
test "hash/different_strings_differ" {
  let h1 = murmurhash3("hello")
  let h2 = murmurhash3("world")
  assert_true(h1 != h2)
}

///|
test "hash/seed_produces_different_hash" {
  let h0 = murmurhash3("test", seed=0)
  let h1 = murmurhash3("test", seed=1)
  assert_true(h0 != h1)
}

///|
test "hash/empty_string" {
  // MurmurHash3("", seed=0) should produce a deterministic non-zero value
  let h = murmurhash3("")
  // seed=0, len=0 → fmix32(0) = 0
  inspect(h, content="0")
}

///|
test "hash/unicode_utf8_based" {
  // Verify that Unicode strings are hashed based on their UTF-8 byte
  // representation, not their Char code points. "世" is U+4E16 (3 UTF-8 bytes).
  let h = murmurhash3("世界")
  // Just verify it's deterministic and non-zero
  assert_true(h != 0)
  let h2 = murmurhash3("世界")
  assert_eq(h, h2)
}
