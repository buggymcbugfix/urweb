The compile family
==================

`urweb -stop checknest PROJECT` runs every phase up to and including C generation and prints the C without invoking the C compiler. So here we are testing the final product.

We do strip out the JS though to avoid bloat. We have separate tests for that.
