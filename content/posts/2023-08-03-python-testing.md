---
layout: post
draft: true
title: "Testing in Python"
slug: "python"
date: "2023-08-03 16:28:33+11:00"
lastmod: "2023-08-03 16:28:33+11:00"
comments: false
categories:
  - python
tags:
  - python
  - dev
  - code
---

There are many ways to write unit tests in Python. Here I want to focus on living off the land with the standard libraries [unittest](https://docs.python.org/3/library/unittest.html).

## unittest

`unittest` is both a framework and test runner, meaning it can execute your tests and return the results. In order to write `unittest` tests, you must:

1. Write your tests as methods within classes
1. These `TestCase` classes must subclass `unittest.TestCase`
1. Names of test functions must begin with `test_`
1. Import the code to be tested
1. Use a series of built-in assertion methods

### Basic example

```python
import unittest

class TestStringMethods(unittest.TestCase):

    def test_upper(self):
        self.assertEqual('foo'.upper(), 'FOO')

    def test_isupper(self):
        self.assertTrue('FOO'.isupper())
        self.assertFalse('Foo'.isupper())

    def test_split(self):
        s = 'hello world'
        self.assertEqual(s.split(), ['hello', 'world'])
        # check that s.split fails when the separator is not a string
        with self.assertRaises(TypeError):
            s.split(2)

if __name__ == '__main__':
    unittest.main()
```

### Assertions

The `TestCase` class provides several assert methods to check for and report failures. 

| Assertion                   | Checks                 |
| --------------------------- | ---------------------- |
| `assertEqual(a, b)`         | `a == b`               |
| `assertNotEqual(a, b)`      | `a != b`               |
| `assertTrue(x)`             | `bool(x) is True`      |
| `assertFalse(x)`            | `bool(x) is False`     |
| `assertIs(a, b)`            | `a is b`               |
| `assertIsNot(a, b)`         | `a is not b`           |
| `assertIsNone(x)`           | `x is None`            |
| `assertIsNotNone(x)`        | `x is not None`        |
| `assertIn(a, b)`            | `a in b`               |
| `assertNotIn(a, b)`         | `a not in b`           |
| `assertIsInstance(a, b)`    | `isinstance(a, b)`     |
| `assertNotIsInstance(a, b)` | `not isinstance(a, b)` |

### Running

A common way is to trigger `unittest.main()` like so:

```python
if __name__ == "__main__":
    unittest.main()
```

Alternatively it provides a first-class CLI, that supports simple module, class or individual test methods:

```bash
python3 -m unittest objects.test.test_parrot.MyTestCase.test_default_voltage
```

Test modules can also be specified by path:

```bash
python3 -m unittest objects/test/test_parrot.py
```

### Pro tips

- If you shuffle tests into a `test` directory in the source tree, you’ll need to make sure the code under test is available on the `PYTHONPATH`
-

## Topics

- `unittest`
- monkey patching
- `pytest`
- mocking
