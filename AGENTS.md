# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

## Project Structure

- MoonBit packages are organized per directory; each directory has a `moon.pkg`
  file listing its dependencies. Each package has its source files and
  blackbox test files (ending in `_test.mbt`).

- In the top-level directory, `moon.mod.json` describes the module and its
  metadata.

## Coding convention

- MoonBit code is organized in block style; each block is preceded by `///|`.

- Error types are declared with `pub(all) suberror`, and functions that raise
  use `-> T raise ErrorType` in their signature.

## Tooling

- `moon fmt` — format code.
- `moon build` — build the project.
- `moon test` — run all tests.
- `moon check` — lint / type-check.
- `moon info` — regenerate `.mbti` interface files (run after API changes).

Run `moon info && moon fmt` as a final step after making changes, then
`moon test` to verify everything passes.
