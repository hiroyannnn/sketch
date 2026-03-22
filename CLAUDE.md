# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**sketch** is a MoonBit probabilistic data structures library providing HyperLogLog, Count-Min Sketch, and Cuckoo Filter.

## Build & Test Commands

```bash
moon check              # Type-check / lint
moon test               # Run all tests (default target)
moon test --target all  # Run tests on all targets (wasm, wasm-gc, js, native)
moon info               # Regenerate .mbti interface files (run after API changes)
moon fmt                # Format code
```

Before committing: `moon info && moon fmt && moon test --target all`

Makefile shortcuts:

```bash
make test               # moon test --target all
make check              # moon info + moon fmt + git diff --exit-code
make release v=0.2.0    # Test → bump version → commit → push → gh release create
```

Release triggers `release.yml` which runs `moon publish` to mooncakes.io.

## Architecture

- `lib/` — Core library package
  - `hash.mbt` — MurmurHash3 32-bit (UTF-8 byte-oriented)
  - `hyperloglog.mbt` — HyperLogLog cardinality estimator (precision 4-18)
  - `countmin.mbt` — Count-Min Sketch frequency estimator
  - `cuckoo.mbt` — Cuckoo Filter membership tester (xorshift32 kick-out)
  - `types.mbt` — `SketchError` suberror type
  - `*_test.mbt` — Blackbox tests for each data structure
- `top.mbt` — Re-exports public types via `pub using @lib { ... }`
- `moon.mod.json` — Module metadata (name: `hiroyannnn/sketch`)

All struct fields are `priv` — construction only via `::new()` factory methods.

## License

Apache License 2.0. Algorithm references are documented in NOTICE.
