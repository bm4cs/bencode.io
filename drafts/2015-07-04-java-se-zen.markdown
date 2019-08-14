

## Class Design

#### Static
- Since static methods cannot access instance variables (non-static variables), they are most suited for utility functions. For example, all methods in the java.util.math library are static.
- Calling a static method is considered to be slightly more efficient compared to calling an instance method. This is because the complier need not pass the implicit this object reference while calling a static method, unlike an instance method.

#### Using the “final” Keyword
- A final class is a non-inheritable class (i.e., you cannot inherit from a final class).
- A final method is a non-overridable method (i.e., subclasses cannot override a final method).
- All methods of a final class are implicitly final (i.e., non-overridable).
- A final variable can be assigned only once.

#### Enums
- You cannot use new with enums, even inside the enum definition.
- Enum classes are by default final classes.
- All enum classes are implicitly derived from java.lang.Enum.

#### Flavors of Nested Classes
- Java supports four types of nested classes: static nested classes, inner classes, local inner classes, and anonymous inner classes.
- Static nested classes may have static members, whereas the other flavors of nested classes can’t.
- Static nested classes and inner classes can access members of an outer class (even private members). However, static nested classes can access only static members of outer class.
- Local classes (both local inner classes and anonymous inner classes) can access all variables declared in the outer scope (whether a method, constructor, or a statement block).


##### Static Nested Classes
- The accessibility (public, protected, etc.) of the static nested class is defined by the outer class.
- The name of the static nested class is expressed with OuterClassName.NestedClassName syntax.
- When you define an inner nested class (or interface) inside an interface, the nested class is declared implicitly public and static. This point is easy to remember: any field in an interface is implicitly declared public and static, and static nested classes have this same behavior.
- Static nested classes can be declared `abstract` or `final`.
- Static nested classes can extend another class or it can be used as a base class.
- Static nested classes can have static members. (As you’ll see shortly, this statement does not apply to other kinds of nested classes.)
- Static nested classes can access the members of the outer class (only static members, obviously).
- The outer class can also access the members (even private members) of the nested class through an object of nested class. If you don’t declare an instance of the nested class, the outer class cannot access nested class elements directly.

##### Inner Classes
- Just like top-level classes, an inner class can extend a class or can implement interfaces. Similarly, an inner class can be extended by other classes, and an inner interface can be implemented or extended by other classes or interfaces.
- An inner class can be declared final or abstract.
- Inner classes can have inner classes, but you’ll have a hard time reading or understanding such complex nesting of classes.

##### Local Inner Classes
- You can create a non-static local class inside a body of code. Interfaces cannot have local classes, and you cannot create local interfaces.
- Local classes are accessible only from the body of the code in which the class is defined. The local classes are completely inaccessible outside the body of the code in which the class is defined.
- You can extend a class or implement interfaces while defining a local class.
- A local class can access all the variables available in the body of the code in which it is defined. You can pass only final variables to a local inner class.
