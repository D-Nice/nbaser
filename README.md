# nbaser

Library allowing for consistent and reversible encode/decode
operations between arbitrary unicode character bases.
Supports bases from 2 to 256.

<!-- vim-markdown-toc GFM -->

* [Install](#install)
* [Docs](#docs)
* [Benchmark](#benchmark)
* [Notes](#notes)

<!-- vim-markdown-toc -->

## Install

`$ nimble install nbaser`

import in your project and use

```nim
import nbaser

const bs58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
echo bs58.decode("1Q2TWHE3GMdB6BZKafqwxXtWAWgFt5Jvm3")
# @[0, 252, 145, 111, 33, 58, 61, 127, 19, 105, 49, 61, 95, 163, 15, 97, 104, 249, 68, 106, 45, 17, 33, 166, 54]
```

## Docs

Check *nimble.directory hosted docs*.

Includes examples.

## Benchmark

Check the [benchmarker CI task](https://github.com/D-Nice/nbaser/actions?query=workflow%3Abenchmarker+branch%3Amaster)
for current benchmark numbers.

or to test locally

`$ nimble benchmark`

## Notes

This library does not support padding, such as that found in "standard"
base32 and base64.

It utilizes the leading zero compression found in base58, thereby supports it
and its variants, and does not require padding.

Due to the unicode support, there is quite some performance
overhead realatively to just supporting ASCII. It results
in up to an order of magnitude slowdown, but should still
be fast enough. Check [benchmarks](#benchmark).
