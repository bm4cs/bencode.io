---
layout: post
draft: true
title: "Objects in Python"
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

As I learn more about Pythons idioms reflect on its unique approach to object based programming. In combination with duck typing its approach to objects feels distrubingly flexible.

Everything in Python is an object.

## Special methods (dunders)

Filed under [Special Method Names](https://docs.python.org/3/reference/datamodel.html#special-method-names) in the docs, defines the special traits a class can implement that are invoked by special syntax, such as arithmetic operations.

Python will raise an exception (`AttributeError` or `TypeError`), if the class failed to provide the appropriate method/s.

### Basics

| You want                                   | So you write             | And Python calls            |
| ------------------------------------------ | ------------------------ | --------------------------- |
| to initialise an instance                  | `x = MyClass()`          | `x.__init__()`              |
| representation string that can be `eval()` | `repr(x)`                | `x.__repr__()`              |
| the "informal" value as a string           | `str(x)`                 | `x.__str__()`               |
| the "informal" value as a byte array       | `bytes(x)`               | `x.__bytes__()`             |
| the value as a formatted string            | `format(x, format_spec)` | `x.__format__(format_spec)` |

### Iterators

| You want                               | So you write    | And Python calls     |
| -------------------------------------- | --------------- | -------------------- |
| to iterate through a sequence          | `iter(seq)`     | `seq.__iter__()`     |
| to get the next value from an iterator | `next(seq)`     | `seq.__next__()`     |
| to create an iterator in reverse order | `reversed(seq)` | `seq.__reversed__()` |

```python
for x in seq:
    print(x)
```

Python will call `seq.__iter__()` to create an iterator, then call the `__next__()` method on that iterator to get each value of x. When the `__next__()` method raises a `StopIteration` exception, the for loop ends gracefully.
