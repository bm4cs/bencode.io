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

- [Special methods (dunders)](#special-methods-dunders)
  - [Basics](#basics)
  - [Iterators](#iterators)
  - [Computed attributes](#computed-attributes)
  - [Callable classes](#callable-classes)

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

### Computed attributes

| You want                                      | So you write            | And Python calls                      |
| --------------------------------------------- | ----------------------- | ------------------------------------- |
| to get a computed attribute (unconditionally) | `x.my_property`         | `x.__getattribute__('my_property')`   |
| to get a computed attribute (fallback)        | `x.my_property`         | `x.__getattr__('my_property')`        |
| to set an attribute                           | `x.my_property = value` | `x.__setattr__('my_property', value)` |
| to delete an attribute                        | `del x.my_property`     | `x.__delattr__('my_property')`        |
| to list all attributes and methods            | `dir(x)`                | `x.__dir__()`                         |

Tips:

- If defined `__getattribute__()` will always be called for every reference to any attribute or method name (except for special dunders)
- `__getattr__()` on the other hand will only be called only after looking for the attribute in the normal places
- `__dir__()` is useful if you use either of the `__getattr*__()` traits, as `dir(x)` only lists regular attributes and methods, by overriding `__dir__()` can register dynamic attributes to the list of available attributes.

### Callable classes

| You want                              | So you write    | And Python calls         |
| ------------------------------------- | --------------- | ------------------------ |
| to “call” an instance like a function | `my_instance()` | `my_instance.__call__()` |






<https://web.archive.org/web/20110131211638/http://diveintopython3.org/special-method-names.html>
