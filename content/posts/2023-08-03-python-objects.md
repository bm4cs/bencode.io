---
layout: post
draft: false
title: "Objects in Python"
slug: "pythonobjects"
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

- [Special methods (dunders)](#special-methods-dunders)
  - [Foundational](#foundational)
  - [Iterators](#iterators)
  - [Compariable classes](#compariable-classes)
  - [Serializable classes](#serializable-classes)
  - [Classes with computed attributes](#classes-with-computed-attributes)
  - [Classes that are callable](#classes-that-are-callable)
  - [Classes that act like sets](#classes-that-act-like-sets)
  - [Classes that act like dictionaries](#classes-that-act-like-dictionaries)
  - [Classes that act like numbers](#classes-that-act-like-numbers)
  - [Classes that can be used in a with block](#classes-that-can-be-used-in-a-with-block)
  - [Esoteric behavior](#esoteric-behavior)

As I learn more about Pythons idioms reflect on its unique approach to object based programming. In combination with duck typing its approach to objects feels distrubingly flexible.

Everything in Python is an object.

## Special methods (dunders)

Filed under [Special Method Names](https://docs.python.org/3/reference/datamodel.html#special-method-names) in the docs, defines the special traits a class can implement that are invoked by special syntax, such as arithmetic operations.

Python will raise an exception (`AttributeError` or `TypeError`), if a class fails to provide appropriate method/s.

### Foundational

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

### Compariable classes

| You want                         | So you write | And Python calls |
| -------------------------------- | ------------ | ---------------- |
| equality                         | `x == y`     | `x.__eq__(y)`    |
| inequality                       | `x != y`     | `x.__ne__(y)`    |
| less than                        | `x < y`      | `x.__lt__(y)`    |
| less than or equal to            | `x <= y`     | `x.__le__(y)`    |
| greater than                     | `x > y`      | `x.__gt__(y)`    |
| greater than or equal to         | `x >= y`     | `x.__ge__(y)`    |
| truth value in a boolean context | `if x:`      | `x.__bool__()`   |

If you define a `__lt__()` method but no `__gt__()` method, Python will use the `__lt__()` method with operands swapped.

However, methods will not be combined. For example, if you define a `__lt__()` method and a `__eq__()` method and try to test whether `x <= y`, Python will not call `__lt__()`and `__eq__()` in sequence. It will only call the `__le__()` method.

### Serializable classes

With the [pickle](https://docs.python.org/3/library/pickle.html) module, Python supports serializing and deserializing objects. All of the native datatypes support pickling. If you create a custom class that you want to be able to pickle, checkout the [pickle protocol](https://docs.python.org/3/library/pickle.html#pickling-class-instances) to see when and how the following special methods are called.

| You want                                                | So you write                             | And Python calls                    |
| ------------------------------------------------------- | ---------------------------------------- | ----------------------------------- |
| a custom object copy                                    | `copy.copy(x)`                           | `x.__copy__()`                      |
| a custom object deepcopy                                | `copy.deepcopy(x)`                       | `x.__deepcopy__()`                  |
| to get an object’s state before pickling                | `pickle.dump(x, file)`                   | `x.__getstate__()`                  |
| to serialize an object                                  | `pickle.dump(x, file)`                   | `x.__reduce__()`                    |
| to serialize an object (new pickling protocol)          | `pickle.dump(x, file, protocol_version)` | `x.__reduce_ex__(protocol_version)` |
| control over how an object is created during unpickling | `x = pickle.load(file)`                  | `x.__getnewargs__()`                |
| to restore an object’s state after unpickling           | `x = pickle.load(file)`                  | `x.__setstate__()`                  |

To recreate a serialized object, Python first needs to create a new object that looks like the serialized object, and then set the values of all the attributes on the new object. The `__getnewargs__()` method controls how the object is created, then the `__setstate__()` method controls how the attribute values are restored.

### Classes with computed attributes

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

### Classes that are callable

| You want                              | So you write    | And Python calls         |
| ------------------------------------- | --------------- | ------------------------ |
| to “call” an instance like a function | `my_instance()` | `my_instance.__call__()` |

The `zipfile` module takes this approach to define a class that can decrypt an encrypted zip file with a given password. The zip decryption algorithm requires you to store state during decryption. Defining the decryptor as a class allows you to maintain this state within a single instance of the decryptor class. The state is initialized in the `__init__()` method and updated as the file is decrypted. But since the class is also callable like a normie function, you can pass the instance as the first argument of the `map()` function.

Stateful functions if you will.

```python
# excerpt from zipfile.py
class _ZipDecrypter:
    def __init__(self, pwd):
        self.key0 = 305419896
        self.key1 = 591751049
        self.key2 = 878082192
        for p in pwd:
            self._UpdateKeys(p)

    def __call__(self, c):
        assert isinstance(c, int)
        k = self.key2 | 2
        c = c ^ (((k * (k^1)) >> 8) & 255)
        self._UpdateKeys(c)
        return c

# sample usage
zd = _ZipDecrypter(pwd)
bytes = zef_file.read(12)
h = list(map(zd, bytes[0:12]))
```

### Classes that act like sets

If you have a class that is a container for values, it's may make sense to enquire if it "contains" a certain value and leverage Python's `x in s` syntax.

| You want                                     | So you write | And Python calls    |
| -------------------------------------------- | ------------ | ------------------- |
| the number of items                          | `len(s)`     | `s.__len__()`       |
| to know whether it contains a specific value | `x in s`     | `s.__contains__(x)` |

### Classes that act like dictionaries

Going beyond just the "in" operator, classes can also act as full blown dictionaries:

| You want                                    | So you write         | And Python calls                 |
| ------------------------------------------- | -------------------- | -------------------------------- |
| to get a value by its key                   | `x[key]`             | `x.__getitem__(key)`             |
| to set a value by its key                   | `x[key] = value`     | `x.__setitem__(key, value)`      |
| to delete a key-value pair                  | `del x[key]`         | `x.__delitem__(key)`             |
| to provide a default value for missing keys | `x[nonexistent_key]` | `x.__missing__(nonexistent_key)` |

### Classes that act like numbers

The classical operator overload example, most languages including Python provide syntax for working with numeric types, adding `+`, subtracting `-`, modulo `%`, bitwise XOR `^` and so on.

| You want                | So you write  | And Python calls    |
| ----------------------- | ------------- | ------------------- |
| addition                | `x + y`       | `x.__add__(y)`      |
| subtraction             | `x - y`       | `x.__sub__(y)`      |
| multiplication          | `x * y`       | `x.__mul__(y)`      |
| division                | `x / y`       | `x.__truediv__(y)`  |
| floor division          | `x // y`      | `x.__floordiv__(y)` |
| modulo (remainder)      | `x % y`       | `x.__mod__(y)`      |
| floor division & modulo | `divmod(x, y) | `x.__divmod__(y)`   |
| raise to power          | `x ** y`      | `x.__pow__(y)`      |
| left bit-shift          | `x << y`      | `x.__lshift__(y)`   |
| right bit-shift         | `x >> y`      | `x.__rshift__(y)`   |
| bitwise and             | `x & y`       | `x.__and__(y)`      |
| bitwise xor             | `x ^ y`       | `x.__xor__(y)`      |
| bitwise or              | `x  \| y`     | `x.__or__(y)`       |

These overloads handle a huge number of scenarios, but fails to provide comprehensive coverage of all scenarios.

```python
>>> from fractions import Fraction
>>> x = Fraction(1, 3)
>>> 1 / x
Fraction(3, 1)
```

In the above, the built-in integer has no concept of how to handle a `Fraction`, that is `1.__truediv__(x)`

There is a second set of arithmetic special methods with _reflected operands_. Given an arithmetic operation that takes two operands (`x / y`), there are two ways to go about it:

1. Tell `x` to divide itself by `y`, or
2. Tell `y` to divide itself into `x`

The set of special methods (such as `__truediv__(y)`) above take the first approach: given `x / y`, they provide a way for `x` to say "I know how to divide myself by y".

The following set of special methods tackle the second approach: they provide a way for `y` to say "I know how to be the denominator and divide myself into x".

| You want                | So you write  | And Python calls     |
| ----------------------- | ------------- | -------------------- |
| addition                | `x + y`       | `y.__radd__(x)`      |
| subtraction             | `x - y`       | `y.__rsub__(x)`      |
| multiplication          | `x * y`       | `y.__rmul__(x)`      |
| division                | `x / y`       | `y.__rtruediv__(x)`  |
| floor division          | `x // y`      | `y.__rfloordiv__(x)` |
| modulo (remainder)      | `x % y`       | `y.__rmod__(x)`      |
| floor division & modulo | `divmod(x, y) | `y.__rdivmod__(x)`   |
| raise to power          | `x ** y`      | `y.__rpow__(x)`      |
| left bit-shift          | `x << y`      | `y.__rlshift__(x)`   |
| right bit-shift         | `x >> y`      | `y.__rrshift__(x)`   |
| bitwise and             | `x & y`       | `y.__rand__(x)`      |
| bitwise xor             | `x ^ y`       | `y.__rxor__(x)`      |
| bitwise or              | `x \| y`      | `y.__ror__(x)`       |

Python also support numeric syntax for mutating values in-place (e.g. `x += y`), which depending on your class may need to be handled:

| You want                 | So you write | And Python calls     |
| ------------------------ | ------------ | -------------------- |
| in-place addition        | `x += y`     | `x.__iadd__(y)`      |
| in-place subtraction     | `x -= y`     | `x.__isub__(y)`      |
| in-place multiplication  | `x *= y`     | `x.__imul__(y)`      |
| in-place division        | `x /= y`     | `x.__itruediv__(y)`  |
| in-place floor division  | `x //= y`    | `x.__ifloordiv__(y)` |
| in-place modulo          | `x %= y`     | `x.__imod__(y)`      |
| in-place raise to power  | `x **= y`    | `x.__ipow__(y)`      |
| in-place left bit-shift  | `x <<= y`    | `x.__ilshift__(y)`   |
| in-place right bit-shift | `x >>= y`    | `x.__irshift__(y)`   |
| in-place bitwise and     | `x &= y`     | `x.__iand__(y)`      |
| in-place bitwise xor     | `x ^= y`     | `x.__ixor__(y)`      |
| in-place bitwise or      | `x \| = y`   | `x.__ior__(y)`       |

Finally there are several unary operations that number types can perform on themselves:

| You want                               | So you write    | And Python calls        |
| -------------------------------------- | --------------- | ----------------------- |
| negative number                        | `-x`            | `x.__neg__()`           |
| positive number                        | `+x`            | `x.__pos__()`           |
| absolute value                         | `abs(x)`        | `x.__abs__()`           |
| inverse                                | `~x`            | `x.__invert__()`        |
| complex number                         | `complex(x)`    | `x.__complex__()`       |
| integer                                | `int(x)`        | `x.__int__()`           |
| floating point number                  | `float(x)`      | `x.__float__()`         |
| number rounded to nearest integer      | `round(x)`      | `x.__round__()`         |
| number rounded to nearest n digits     | `round(x, n)`   | `x.__round__(n)`        |
| smallest integer >= x                  | `math.ceil(x)`  | `x.__ceil__()`          |
| largest integer <= x                   | `math.floor(x)` | `x.__floor__()`         |
| truncate x to nearest integer toward 0 | `math.trunc(x)` | `x.__trunc__()`         |
| number as a list index                 | `a_list[x]`     | `a_list[x.__index__()]` |

### Classes that can be used in a with block

A `with` block defines a runtime context; you enter the context when you execute the with statement, and you exit the context after you execute the last statement in the block.

| You want                                        | So you write | And Python calls                             |
| ----------------------------------------------- | ------------ | -------------------------------------------- |
| do something special when entering a with block | `with x:`    | `x.__enter__()`                              |
| do something special when leaving a with block  | `with x:`    | `x.__exit__(exc_type, exc_value, traceback)` |

This is exactly how the `file` idiom works:

```python
# excerpt from io.py:
def _checkClosed(self, msg=None):
    '''Internal: raise an ValueError if file is closed
    '''
    if self.closed:
        raise ValueError('I/O operation on closed file.'
                         if msg is None else msg)

def __enter__(self):
    '''Context management protocol.  Returns self.'''
    self._checkClosed()
    return self

def __exit__(self, *args):
    '''Context management protocol.  Calls close()'''
    self.close()
```

Context manager tips:

- The file object defines both an `__enter__()` and an `__exit__()` method. The `__enter__()` method checks that the file is open; if it’s not, the `_checkClosed()` method raises an exception.
- The `__enter__()` method should almost always return `self` — this is the object that the with block will use to dispatch properties and methods.
- After the with block, the file object automatically closes. How? In the `__exit__()` method, it calls `self.close()`.

### Esoteric behavior

| You want                                                             | So you write             | And Python calls                                     |
| -------------------------------------------------------------------- | ------------------------ | ---------------------------------------------------- |
| a class constructor                                                  | `x = MyClass()`          | `x.__new__()`                                        |
| a class destructor                                                   | `del x`                  | `x.__del__()`                                        |
| only a specific set of attributes to be defined                      |                          | `x.__slots__()`                                      |
| a custom hash value                                                  | `hash(x)`                | `x.__hash__()`                                       |
| to get a property’s value                                            | `x.color`                | `type(x).__dict__['color'].__get__(x, type(x))`      |
| to set a property’s value                                            | `x.color = 'PapayaWhip'` | `type(x).__dict__['color'].__set__(x, 'PapayaWhip')` |
| to delete a property                                                 | `del x.color`            | `type(x).__dict__['color'].__del__(x)`               |
| to control whether an object is an instance of your class            | `isinstance(x, MyClass)` | `MyClass.__instancecheck__(x)`                       |
| to control whether a class is a subclass of your class               | `issubclass(C, MyClass)` | `MyClass.__subclasscheck__(C)`                       |
| to control whether a class is a subclass of your abstract base class | `issubclass(C, MyABC)`   | `MyABC.__subclasshook__(C)`                          |

<!-- <https://web.archive.org/web/20110131211638/http://diveintopython3.org/special-method-names.html> -->
