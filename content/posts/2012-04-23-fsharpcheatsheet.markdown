---
layout: post
title: "F# Cheatsheet"
date: "2012-04-23 07:00:00"
comments: false
categories: "F#"
---

The VS11 beta includes a really slick cheatsheet style F# language reference. A gem for groking F# syntax.

The samples are grouped into modules. A module is just a collection of value, function and type definitions.

To execute the code in F# Interactive, highlight a line of code and then either type Alt-Enter, or right-click and choose "Send to Interactive".  To start F# Interactive, see the "View" menu.

For more about F#, see:
  <http://fsharp.net>

For templates to use with F#, see the 'Online Templates' in Visual Studio, 'New Project' > 'Online Templates'

For specific F# topics, see:

- [F# Development Portal](http://go.microsoft.com/fwlink/?LinkID=234174)
- [Code Gallery](http://go.microsoft.com/fwlink/?LinkID=124614)
- [Math/Stats Programming](http://go.microsoft.com/fwlink/?LinkId=235173)
- [Charting](http://go.microsoft.com/fwlink/?LinkId=235176)


Contents

[Primitives](#basicprimitives)
[Lists](#basiclists)
[Basic Functions](#basicfunctions)
[Tuples](#tuples)
[Booleans](#bools)
[Strings](#strings)
[Lists](#basiclists)
[Dictionaries](#dictionaries)
[Object Oriented](#oop)
[Parameter Lists](#parameterlists)
[Arrays](#arrays)
[Sequences](#sequences)
[Generics](#generics)
[Recursion](#recursion)
[Record Types](#recordtypes)
[Unions](#unions)
[Option Values](#optionvalues)
[Pattern Matching](#patternmatching)
[Active Patterns](#activepatterns)
[Interfaces](#interfaces)
[.NET Libraries](#dotnetlibs)
[.NET Regular Expressions](#dotnetregex)
[Recursive Trees](#recursivetrees)
[Inlined Generic Arithmetic](#inlinedgenericarithmetic)
[Units Of Measure](#unitsofmeasure)
[Events](#events)
[Lightweight Async Agent](#lightweightasyncagent)
[Parallel Array Computations I](#parallelarraycomputations1)
[Parallel Array Computations II](#parallelasynccomputations2)
[Database Access](#dbaccess)
[OData Access](#odata)
[Boilerplate WinForm](#boilerplateform)



### <a id="basicprimitives" />Primitives ###

    module Integers = 
        /// A very simple constant integer.
        let sampleInteger = 176
    
        /// This is the result of doing some arithmetic starting with the first integer
        let sampleInteger2 = (sampleInteger/4 + 5 - 7) * 4


### <a id="basiclists" />Lists ###

    module ListsOfIntegers = 
    
        /// A list of the numbers from 0 to 99
        let sampleNumbers = [ 0 .. 99 ]
    
        /// A list of all tuples containing all the numbers from 0 to 99 and their squares
        let sampleTableOfSquares = [ for i in 0 .. 99 -> (i, i*i) ]
    
        // The next line prints a result using %A for generic printing
        printfn "The numbers from 0 to 99 are:\n%A" sampleNumbers
    
        // The next line prints a list that includes tuples, using %A for generic printing
        printfn "The table of squares from 0 to 99 is:\n%A" sampleTableOfSquares


### <a id="basicfunctions" />Basic Functions ###
	
    /// This first module some basic function definitions in F#.
    module SomeBasicFunctionsAndTypeInference = 
    
    
        /// This shows how to use 'let' to define a function that accepts an integer
        /// as an argument and returns an integer. The type of the argument is inferred to 
        /// be an integer.
        let sampleFunction1 x = x*x + 3             
    
        // The next line applies the function and gives the result a name using 'let'. The result type 
        // is inferred from the type of the function.
        let sampleResult1 = sampleFunction1 4573
    
        // The next line prints the result of applying the function
        printfn "The result of squaring the integer 4573 and adding 3 is %d" sampleResult1
    
        /// Where needed, you can annotate the type of a parameter name using "(argument:type)", 
        /// as shown in the sample below.
        let sampleFunction2 (x:int) = 2*x*x - x/5 + 3
    
        // Again the next line applies the function and gives the result a name using 'let'. 
        let sampleResult2 = sampleFunction2 (7 + 4)
    
        printfn "The result of applying the 1st sample function to (7 + 4) is %d" sampleResult2
    
        /// This shows a similar function that accepts and returns floating-point numbers.
        /// In this example, the argument and return types of the function are inferred to
        /// have type 'float' (also called 'double') based on the implementation code.
        let sampleFunction3 x = 
            if x < 100.0 then 
                2.0*x*x - x/5.0 + 3.0
            else 
                2.0*x*x + x/5.0 - 37.0
    
        /// The result of applying 'sampleFunction3' over double-precision floating point numbers 
        let sampleResult3 = sampleFunction3 (6.5 + 4.5)
    
        printfn "The result of applying the 2nd sample function to (6.5 + 4.5) is %f" sampleResult3


### <a id="tuples" />Tuples ###

    /// This sample defines and prints some basic tuple values in F#.
    module SomeBasicTuples = 
    
        /// A simple tuple of integers
        let sampleTuple1 = (1, 2, 3)
    
        /// A function that swaps the order of two values in a tuple. If you hover
        /// the mouse over the function you will see its inferred type is generic.
        let swapElementsOfTuple (a, b) = (b, a)
    
        printfn "The result of swapping (1, 2) is %A" (swapElementsOfTuple (1,2))
    
        /// A simple tuple of an integer, a string and a double-precision floating point number
        let sampleTuple2 = (1, "fred", 3.1415)
    
        printfn "The first sample tuple is %A" sampleTuple1
    
        printfn "The second sample tuple is %A" sampleTuple2

	
### <a id="bools" />Boolean Values ###

    /// This sample defines and prints some basic boolean values in F#.
    module SomeBooleanValues = 
    
        /// A simple boolean value
        let boolean1 = true
    
        /// A second simple boolean value
        let boolean2 = false
    
        /// Compute a new boolean using ands, ors, and nots
        let boolean3 = not boolean1 && (boolean2 || false)
    
        printfn "The expression 'not boolean1 && (boolean2 || false)' is %A" boolean3


### <a id="strings" />String Values ###

    /// This sample defines and prints some basic string values in F#.
    module SomeStringValues = 
    
        /// A simple string
        let sampleString1  = "Hello"
    
        /// A second simple string
        let sampleString2  = "world"
    
        /// A third string, using a verbatim string literal
        let sampleString3  = @"c:\Program Files\"
    
        /// A fourth string, using a triple-quote string literal
        let sampleString4 = """He said "hello world" after you did"""
    
        /// "Hello world" computed using string concatenation
        let resultString1  = sampleString1 + " " + sampleString2
    
        printfn "The first result string is '%s'" resultString1
    
        /// "Hello world" computed using a .NET library function
        let resultString2 = System.String.Join(" ",[| sampleString1; sampleString2 |])
          // Try re-typing the above line to see intellisense in action
          // Note, ctrl-J on (partial) identifiers re-activates it
    
        printfn "The second result string is '%s'" resultString2
    
        /// A string formed by taking the first 7 characters of one of the result strings
        let resultString3  = resultString1.[0..6]
    
        printfn "The third result string is '%s'" resultString1


### <a id="basiclists" />Basic Lists ###

    /// This sample shows some more basic list values in F# and how to 
    /// processes lists using functions such as 'map' and pipelining
    module WorkingWithLists = 
    
        /// The empty list
        let sampleList1 = [ ]           
    
        /// A list with 3 integers
        let sampleList2 = [ 1; 2; 3 ]     
    
        /// A sample list, containing numbers from 1 to 1000
        let sampleList3 = [ 1 .. 1000 ]
    
        /// Create another list, containing the days which are Monday in the current year
        let sampleList4 = 
            [ for month in 1 .. 12 do
                  for day in 1 .. System.DateTime.DaysInMonth(2011, month) do 
                      yield System.DateTime(2011, month, day) ]
    
        /// Create a list containing the tuples which are the coordinates of the black squares on
        /// a chess board.
        let sampleList5 = 
            [ for i in 0 .. 7 do
                  for j in 0 .. 7 do 
                     if (i+j) % 2 = 1 then 
                         yield (i, j) ]
    
    
        /// Sum of a list
        let sumOfSampleList3 = List.sum sampleList3
    
        /// A new list with the squares of the numbers from 10 to 20. The function
        /// is defined using the pipeline operator.
        let resultList2 = 
            sampleList3 |> List.map (fun x -> x*x) 
    
        /// A function that computes the sum of the squares of the numbers divisible by 3.
        let sumOfSquaresUpTo n = 
            sampleList3
              |> List.filter (fun x -> x % 3 = 0)
              |> List.sumBy (fun x -> x * x)
    
        // Many more functions are in the 'List' module. You can also use functions in 
        // the 'Seq' module to process lists.


### <a id="dictionaries" />Dictionaries ###

    /// This sample defines and use some dictionary and lookup table values in F#.
    module SomeDictionaryValues = 
        
        /// The 'open' declaration is used to open a namespace.
        /// They are usually placed at the start of a file or module.
        open System.Collections.Generic
    
        /// This creates an immutable dictionary with integer keys and string values.
        /// Lookup is based on hashing the keys, which are the first elements of the tuples.
        let sampleLookupTable1 = dict [ (1, "ElementOne"); (2, "ElementTwo") ]
    
        /// This creates a much large immutable dictionary with integer keys and string values.
        let sampleLookupTable2 = dict [ for i in 0 .. 10000 -> (i, "Element" + string i) ]
    
        /// This looks up one entry in the dictionary. Its result is "ElementOne".
        let sampleLookupResult1 = sampleLookupTable1.[1]
    
        /// This looks up one entry in the dictionary. Its result is "Element100".
        let sampleLookupResult2 = sampleLookupTable2.[100]
    
        /// This function creates a mutable dictionary with integer keys and string values
        let createAndPopulateDictionary() = 
            let sampleDictionary = Dictionary<int,string>()
            for key,value in [ (1, "One"); (2, "Two") ] do 
                sampleDictionary.Add (key,value)
            sampleDictionary
    
        /// A mutable dictionary created using createAndPopulateDictionary.
        let sampleLookupTable3 = createAndPopulateDictionary()
    
        /// This looks up one entry in the dictionary
        let sampleLookupResult3 = sampleLookupTable2.[2]
    
        /// This creates an immutable map, based on a balanced binary tree, with integer keys and string values.
        /// Keys are compared using an ordering.
        let sampleLookupTable4 = Map.ofList [ for i in 0 .. 1000 -> (i, string (i*i)) ]
    
        /// This looks up one entry in the dictionary
        let sampleLookupResult4 = sampleLookupTable4.[465]


### <a id="oop" />OOP / Classes ###

    /// This sample shows how to define a simple class type.
    module DefiningClasses = 
    
        /// A sample class defining a 2-dimensional vector type. The constructor
        /// for the type takes two arguments: dx and dy, both of type 'float'. This
        /// is the type of double-precision floating-point numbers and is a synonym 
        /// for 'double'.
        type SampleObject(dx:float, dy:float) = 
            /// The length of the vector, computed when the object is constructed
            let length = sqrt (dx*dx + dy*dy)
    
            /// The first parameter of the object
            member v.DX = dx
    
            /// The second parameter of the object
            member v.DY = dy
    
            /// The length of the object
            member v.Length = length
    
            // Return a new the vector where both parameters are scaled by a constant 
            member v.Scale(k) = SampleObject(k*dx, k*dy)
        
        /// An instance of the SampleObject class
        let sampleObject1 = SampleObject(3.0, 4.0)
    
        // Call a method on the sample object which returns a new object modifies its state.
        let sampleObject2 = sampleObject1.Scale(10.0)
    
        printfn "The length of sampleObject2 is %f" sampleObject2.Length
    
        printfn "The length of sampleObject2 is %f" sampleObject2.Length


### <a id="parameterlists" />Parameter Lists ###
	
    /// This sample shows some parameter lists in F#.
    module ParameterLists = 
        // Parameters supplied to functions and methods are, in general, patterns separated by spaces. 
        // 
        // Methods usually use the tupled form of passing arguments. This achieves a clearer result from 
        // other .NET languages.
        //
        // The curried form is most often used with functions created by using let bindings. 
        //
        // Tupled form:
        //    member this.SomeMethod(param1, param2) = ...
        //
        // Curried form:
        //   let function1 param1 param2 = ...
    
        /// This is an example of a function taking three arguments in curried form
        let addUpTheNumbers x y z = x + y + z
    
        printfn "The result of adding up the numbers is '%d'" (addUpTheNumbers 9 32 12)
    
        /// This is an example of a function taking three arguments in tupled form. 
        let addUpTheNumbersInTheTuple (x, y, z) = x + y + z
    
        printfn "The result of adding up the numbers is '%d'" (addUpTheNumbersInTheTuple (9, 32, 12))
    
        type Slice = Slice of int * int * string
    
        /// You can use other patterns within arguments. This sample shows how to match a single case
        /// union type using the name of the tag for the union case.
        let getSlice (Slice(p0, p1, text)) = 
            printfn "Data begins at %d and ends at %d in string %s" p0 p1 text
            text.[p0..p1]
    
        let substring = getSlice (Slice(0, 4, "Et tu, Brute?"))
        printfn "Substring: %s" substring
    
    
        /// Arguments for methods can be specified by position in a comma-separated argument list, or they can be passed 
        /// to a method explicitly by providing the name, followed by an equal sign and the value to be passed in. 
        /// If specified by providing the name, they can appear in a different order from that used in the declaration.
        /// 
        /// Named arguments are allowed only for methods, not for let-bound functions, function values, or lambda expressions.
    
        type SpeedingTicket(speed: int, limit: int) =
            member this.GetSpeedOver() = speed - limit
    
        let calculateFine (ticket : SpeedingTicket) =
            let delta = ticket.GetSpeedOver()
            if delta < 20 then 50.0 else 100.0
    
        let ticket1 = SpeedingTicket(limit = 55, speed = 70)
        printfn "The speeding fine is %f" (calculateFine ticket1)
     
        /// You can specify an optional parameter for a method by using a question mark in front of the parameter name. 
        /// Optional parameters are interpreted as the F# option type, so you can query them in the regular way that 
        /// option types are queried, by using a match expression with Some and None. Optional parameters are 
        /// permitted only on members, not on functions created by using let bindings.
        type DuplexType =
            | Full
            | Half
    
        type Connection(?rate0 : int, ?duplex0 : DuplexType, ?parity0 : bool) =
            let duplex = defaultArg duplex0 Full
            let parity = defaultArg parity0 false
            let rate = defaultArg rate0 (match duplex with Full -> 9600 | Half -> 4800)
            do printfn "Baud Rate: %d Duplex: %A Parity: %b" rate duplex parity
    
        let conn1 = Connection(duplex0 = Full)
        let conn2 = Connection(duplex0 = Half)
        let conn3 = Connection(300, Half, true)


### <a id="arrays" />Arrays ###
	
    /// This sample defines and uses some array values in F#.
    module WorkingWithArrays = 
    
        /// The empty array
        let sampleArray1 = [| |]
    
        /// Create a sample array, containing the five strings
        let sampleArray2 = [| "hello"; "world"; "and"; "hello"; "world"; "again" |]
    
        /// Create another array, containing the numbers from 1 to 1000
        let sampleArray3 = [| 1 .. 1000 |]
    
        /// Create another array, containing only the words "hello" and "world"
        let sampleArray4 = [| for word in sampleArray2 do
                                 if word.Contains("l") then 
                                     yield word |]
    
        // Create an array initialized by index, containing the even numbers from 0 to 2000.
        let evenNumbersUpTo1000 = Array.init 1001 (fun n -> n * 2) 
    
        // Extract a sub-array using slicing notation
        let evenNumbersUpTo500 = evenNumbersUpTo1000.[0..500]
    
    
        /// This function prints one of the sample arrays using a loop.
        let printSampleArray4() = 
            for word in sampleArray4 do 
                System.Console.WriteLine("word: {0}",word)
    
        /// Execute the function 
        printSampleArray4()
        
        // Set two elements of the first sample array
        sampleArray2.[1] <- "world"
        sampleArray2.[3] <- "world"
    
        /// Get the length of the array 
        let arrLength = sampleArray4.Length        
    
        /// A function that computes the sum of the lengths of the words the start with 'h'
        let sumOfLengthsOfWords = 
            sampleArray2 
              |> Array.filter (fun x -> x.StartsWith "h")
              |> Array.sumBy (fun x -> x.Length)
    
        // Many more functions are in the 'Array' module. You can also use functions in 
        // the 'Seq' module to process arrays.

	
### <a id="sequences" />Sequences ###
	
    /// This sample defines and uses some sequence (IEnumerable) objects in F#. Sequences
    /// are evaluated on-demand, and re-evaluated each time they are iterated. Lists, arrays
    /// and other collections can also be used as sequences.
    module WorkingWithSequences = 
    
        /// The empty sequence
        let sampleSequence1 = Seq.empty
    
        /// Create a sample sequence, yield five strings
        let sampleSequence2 = seq {  yield "hello"; yield "world"; yield "and"; yield "hello"; yield "world"; yield "again" }
    
        /// Create another array, containing the numbers from 1 to 1000
        let sampleSequence3 = seq { 1 .. 1000 }
    
        /// Create another array, containing only the words "hello" and "world"
        let sampleSequence4 = 
            seq { for word in sampleSequence2 do
                    if word.Contains("l") then 
                        yield word }
    
        // Create a sequence using one of the library functions in the Seq module.
        let evenNumbersUpTo1000 = Seq.init 1001 (fun n -> n * 2) 
    
    
        /// This function prints one of the sample arrays using a loop.
        let printSampleSequence3() = 
            for word in sampleSequence4 do 
                System.Console.WriteLine("word: {0}",word)
    
        /// Execute the function 
        printSampleSequence3()
        
        /// Create an infinite sequence which is a random walk.
        let rnd = System.Random()
        let rec randomWalk x =
            seq { yield x
                  yield! randomWalk (x + rnd.NextDouble() - 0.5) }
        
        let first100ValuesOfRandomWalk = 
            randomWalk 5.0 
               |> Seq.truncate 100
               |> Seq.toList
    
        // Many more functions are in the 'Seq' module. You can convert sequences to lists,
        // arrays and dictionaries using Seq.toList, Seq.toArray and dict.


### <a id="generics" />Generics ###
	
    /// This sample shows how to define a generic class type.
    module DefiningGenericClass = 
    
        /// A class which contains one item of mutable state and which implements the given interface.
        type HistoricalStateTracker<'T>(initialElement: 'T) = 
            /// The internal state of the class, recording the historical states in reverse order
            let mutable historicalStates = [ initialElement ]
    
            /// Add a new element to the list of states
            member x.UpdateState newState = 
                historicalStates <- newState :: historicalStates
    
            /// Get the entire list of historical states
            member x.History = historicalStates
    
            /// Get the latest state
            member x.CurrentState = historicalStates.Head
    
        /// A sample instance of the HistoricalStateTracker class, stogin integers
        let sampleStateTracker = HistoricalStateTracker 10
    
        // Add a state
        sampleStateTracker.UpdateState 17
    
        // Get the history
        sampleStateTracker.History


### <a id="recursion" />Recursion ###
	
    /// This sample shows how to define recursive functions.
    module DefiningRecursiveFunctions  = 
                  
        /// Compute the factorial of an integer. The function is recursive and is thus defined using
        /// 'let rec'.
        let rec factorial n = if n = 0 then 1 else n * factorial (n-1)
    
        /// Compute the highest-common-factor of two integers. The function is recursive and is thus defined using
        /// 'let rec'. The recursive calls are tailcalls and the function is turned into a loop.
        /// Also, note that in F#, a function may take two arguments separated by spaces. This is called 
        /// 'currying'.
        let rec highestCommonFactor a b =                       
            if a=0 then b
            elif a<b then highestCommonFactor a (b-a)           
            else highestCommonFactor (a-b) b
    
        /// Compute the sum of a list of integers using a recursive function. The function is recursive and is thus defined using
        /// 'let rec'.
        let rec sumList xs =
            match xs with
            | []    -> 0
            | y::ys -> y + sumList ys
    
        /// Sometimes functions need to be made 'tail recursive'. This can mean using a helper
        /// function which carries an accumulator which builds up the result. This function 
        /// shows an example of such a helper function.
        let rec private sumListTailRecursiveHelper accumulator xs =
            match xs with
            | []    -> accumulator
            | y::ys -> sumListTailRecursiveHelper (accumulator+y) ys
    
        /// This function calls the helper function to process the elements of the list in a 
        /// tail-recursive way.
        let sumListTailRecursive xs = sumListTailRecursiveHelper 0 xs


### <a id="recordtypes" />Record Types ###
	
    /// This sample defines a record type representing some simple user data.
    module DefiningRecordTypes = 
    
        /// This defines a record type, which is a .NET reference type with the given properties.
        type ContactCard = 
            { Name  : string;
              Phone : string;
              Ok    : bool }
                  
        /// An example ContectCard object
        let sampleRecordObject1 = { Name = "Alf" ; Phone = "(206) 555-0157" ; Ok = false }
    
        /// A second example ContectCard object
        let sampleRecordObject2 = { sampleRecordObject1 with Phone = "(206) 555-0112"; Ok = true }
    
        /// A function to convert a 'ContactCard' object to a string
        let showCard c = 
            c.Name + " Phone: " + c.Phone + (if not c.Ok then " (unchecked)" else "")


### <a id="unions" />Unions ###

    /// This sample defines a and use some dictionary and lookup table values in F#.
    module DefiningUnionTypes = 
    
        /// Represents the suit of a playing card
        type Suit = 
            | Hearts 
            | Clubs 
            | Diamonds 
            | Spades
    
        /// Represents the rank of a playing card
        type Rank = 
            /// Represents the rank of cards 2 .. 10
            | Value of int
            | Ace
            | King
            | Queen
            | Jack
            static member GetAllRanks() = 
                [ yield Ace
                  for i in 2 .. 10 do yield Value i
                  yield Jack
                  yield Queen
                  yield King ]
                                       
        type Card =  { Suit: Suit; Rank: Rank }
                  
        /// Return a list representing all the cards in the deck
        let fullDeck = 
            [ for suit in [ Hearts; Diamonds; Clubs; Spades] do
                 for rank in Rank.GetAllRanks() do 
                     yield { Suit=suit; Rank=rank } ]
    
        /// A function to convert a 'Card' object to a string
        let showCard c = 
            let rankString = 
                match c.Rank with 
                | Ace -> "Ace"
                | King -> "King"
                | Queen -> "Queen"
                | Jack -> "Jack"
                | Value n -> string n
            let suitString = 
                match c.Suit with 
                | Clubs -> "clubs"
                | Diamonds -> "diamonds"
                | Spades -> "spades"
                | Hearts -> "hearts"
            rankString  + " of " + suitString
    
        let printAllCards() = 
            for card in fullDeck do 
                printfn "%s" (showCard card)


### <a id="optionvalues" />Option Values ###

    /// Option values are any kind of value tagged with either 'Some' or 'None'.
    /// They are used extensively in F# code to represent the cases where many other
    /// languages would use null references.
    module Options = 
        open System
    
        let data = Some(1,3)
        printfn "data = %A" data;
        printfn "data.IsSome = %b" data.IsSome
        printfn "data.IsNone = %b" data.IsNone
        printfn "data.Value = %A" data.Value
    
        let data2 = None
        printfn "data2.IsSome = %b" data2.IsSome
        printfn "data2.IsNone = %b" data2.IsNone
    
    
        let openingHours day = 
            match day with 
            | DayOfWeek.Monday 
            | DayOfWeek.Tuesday 
            | DayOfWeek.Thursday 
            | DayOfWeek.Friday    -> Some(9,17)
            | DayOfWeek.Wednesday -> Some(9,19) // extended hours on Wednesday
            | _ -> None 
    
        let today = DateTime.Now.DayOfWeek 
    
        match openingHours today with 
        | None -> printfn "The shop's not open today"
        | Some(s,f) -> printfn "The shop's open today from %02d:00-%d:00" s f


### <a id="patternmatching" />Pattern Matching ###

    /// Pattern matching is used throughout F# code. This sample shows some simple
    /// examples of pattern matching. Many of the other samples in this file also
    /// use pattern matching.
    module PatternMatching = 
    
    
        /// The following example shows how to match on an option value.
        let printOption data =
            match data with
            | Some var1  -> printfn "The value %d was given" var1
            | None -> ()
    
        // Call the function
        printOption (Some 17)
        
        /// In the following example, the PersonName discriminated union contains a mixture of strings 
        /// and characters that represent possible forms of names. The cases of the discriminated 
        /// union are FirstOnly, LastOnly, and FirstLast.
        type PersonName =
            | FirstOnly of string
            | LastOnly of string
            | FirstLast of string * string
    
        let constructQuery personName = 
            match personName with
            | FirstOnly firstName -> printf "May I call you %s?" firstName
            | LastOnly lastName -> printf "Are you Mr. or Ms. %s?" lastName
            | FirstLast(firstName, lastName) -> printf "Are you %s %s?" firstName lastName
    
        
    
        /// This samples shows how to use a 'when' clause to add an extra check to a pattern matching rule.
        let function1 x =
            match x with
            | (var1, var2) when var1 > var2 -> printfn "%d is greater than %d" var1 var2 
            | (var1, var2) when var1 < var2 -> printfn "%d is less than %d" var1 var2
            | (var1, var2) -> printfn "%d equals %d" var1 var2
    
        // Call the function with some input values
        function1 (1, 2)
        function1 (2, 1)
        function1 (0, 0)
    
        /// The following sample shows how to use 'or' patterns when input data can match 
        /// multiple patterns, and you want to execute the same code as a result. The types 
        /// of both sides of the OR pattern must be compatible.
        let detectZeroOR point =
            match point with
            | (0, _) | (_, 0) -> printfn "Zero found."
            | _ -> printfn "Both nonzero."
    
        // Call the function with some input values
        detectZeroOR (0, 0)
        detectZeroOR (1, 0)
        detectZeroOR (0, 10)
        detectZeroOR (10, 15)
    
    
        /// The list pattern enables lists to be decomposed into a number of elements. The list 
        /// pattern itself can match only lists of a specific number of elements. 
        let listLength list =
            match list with
            | [] -> 0
            | [ _ ] -> 1
            | [ _; _ ] -> 2
            | [ _; _; _ ] -> 3
            | _ -> List.length list
    
        // Call the function with some input values
        printfn "%d" (listLength [ 1 ])
        printfn "%d" (listLength [ 1; 1 ])
        printfn "%d" (listLength [ 1; 1; 1; ])
        printfn "%d" (listLength [ ] )
    
    
        open System.Windows.Forms
    
        /// The type test pattern is used to match the input against a type. If the input type 
        /// is a match to or a derived type of the type specified in the pattern, the match succeeds.
        ///
        /// The following example demonstrates the type test pattern.
        let textOfControl (control:Control) =
            match control with
            | :? Button as button -> "Button " + button.Text 
            | :? CheckBox -> "CheckBox"
            | _ -> control.Text
    
        /// The null pattern matches the null value that can appear when you are working with types that 
        /// allow a null value. Null patterns are frequently used when interoperating with .NET Framework 
        /// code. For example, the return value of a .NET API might be the input to a match expression. You 
        /// can control program flow based on whether the return value is null, and also on other characteristics 
        /// of the returned value. You can use the null pattern to prevent null values from propagating to 
        /// the rest of your program.
        let readFromFile (reader : System.IO.StreamReader) =
            match reader.ReadLine() with
            | null -> None 
            | line -> Some line


### <a id="activepatterns" />Active Patterns ###

    /// F# supports extensible pattern matching through 'active patterns'.
    /// This sample shows how to define a set of partial active patterns and use 
    /// them in pattern matching. 
    module ActivePatterns = 
    
        /// This is a partial active pattern which will match strings that can be converted to integers
        let (|Integer|_|) (str: string) =
           let mutable intvalue = 0
           if System.Int32.TryParse(str, &intvalue) then Some(intvalue)
           else None
    
        /// This is a partial active pattern which will match strings that can be converted to floating point numbers
        let (|Float|_|) (str: string) =
           let mutable floatvalue = 0.0
           if System.Double.TryParse(str, &floatvalue) then Some(floatvalue)
           else None
    
        /// This is a function which uses the two active patterns
        let parseNumeric str =
             match str with 
             | Integer i -> printfn "%d : Integer" i
             | Float f -> printfn "%f : Floating point" f
             | _ -> printfn "%s : Not matched." str
    
        // Now call the function with a variety of inputs
        let result1 = parseNumeric "1.1"
        let result2 = parseNumeric "0"
        let result3 = parseNumeric "0.0"
        let result4 = parseNumeric "10"
        let result5 = parseNumeric "Something else"


### <a id="interfaces" />Interfaces ###

    /// This sample shows how to define an interface type and a class that implements it.
    module DefiningClassesAndInterfaces = 
    
        /// A sample interface type with two methods.  
        type IPeekPoke = 
            /// A method on the interface type. It takes no arguments. The type 'unit' is the F# name for both
            /// 'no arguments' and 'no results', called 'void' in languages such as C#.
            abstract Peek: unit -> int
    
            /// A second method on the interface type. It takes one argument and returns no result.
            abstract Poke: int -> unit
    
                  
        /// A class which contains one item of mutable state and which implements the given interface.
        type ClassImplementingPeekPoke(initialState:int) = 
            /// The internal state of the ClassImplementingPeekPoke
            let mutable state = initialState
    
            // Implement the IPeekPoke interface
            interface IPeekPoke with 
                member x.Poke n = state <- state + n
                member x.Peek() = state 
            
            /// Has the ClassImplementingPeekPoke been poked?
            member x.HasBeenPoked = (state <> 0)
    
    
        /// A sample instance of the ClassImplementingPeekPoke class, viewed through the IPeekPoke interface.
        let sampleObject = ClassImplementingPeekPoke(12) :> IPeekPoke
    
        // Call a method on the sample widget which modifies its state.
        sampleObject.Poke(4)
    
        // Get the result of calling a method on the sample widget.
        let peekResult = sampleObject.Peek()
    
        // A list of two objects, each implementing the interface, but sharing state. 
        // The implementations each use an F# object expression, which is a convenient
        // way of implementing objects without needing to write a new class.
        let alternativeImplementations() = 
    
            // Use a F# reference cell as the shared state
            let sharedState = ref 0
    
            [ { new IPeekPoke with 
                   member x.Peek() = !sharedState / 2
                   member x.Poke n = sharedState := n }
    
              { new IPeekPoke with 
                   member x.Peek() = !sharedState * 2
                   member x.Poke n = sharedState := n } ]


### <a id="dotnetlibs" />.NET Libraries ###

    /// This sample shows working with the .NET times for decimals and dates.
    module WorkingWithDotNetLibraryTypes = 
    
        open System
    
        /// The current time
        let sampleTime = DateTime.Now 
    
        /// A list with 2 dates - the start and end of the year 2011
        let sampleListOfDates = [ DateTime(2011,1,1); DateTime(2011,12,31) ]     
    
        /// Create another list, containing the days which are Saturday or Sunday in the current year
        let sampleListOfDates4 = 
            [ for month in 1 .. 12 do
    
                  let thisYear = DateTime.Now.Year
    
                  for day in 1 .. DateTime.DaysInMonth(thisYear, month) do 
    
                      let date = DateTime(year=thisYear, month=month, day=day)
    
                      match date.DayOfWeek with
                      | DayOfWeek.Saturday 
                      | DayOfWeek.Sunday -> yield date 
                      | _  -> () ]
    
        /// Decimal literals use the 'M' suffix
        let sampleDecimalConstant = 103.62M
    
        /// A function to increment a decimal
        let incrementMoney (x:System.Decimal) = x + 1.0M
    
        /// Some data representing account values
        let accounts = [ 23.6M; 101.62M; 13.62M ]
    
        /// The result of adding up some decimal constants
        let addingUpDecimalNumbers = accounts |> List.map incrementMoney |> List.sum
    
    
        // Many more types, properties and methods are in the 'Sys

		
### <a id="dotnetregex" />.NET Regular Expressions ###

    /// This sample shows how to use the .NET regular expression libraries from F#
    module WorkingWithRegularExpressions = 
    
        open System.Text.RegularExpressions
    
        let names = ["Mr. Henry Hunt"; "Ms. Sara Samuels"; "Abraham Adams"; "Ms. Nicole Norris"]
    
        /// This example shows how to check if a string matches a regular expression.
        /// The regular expression pattern  matches any occurrence of "Mr ", "Mr. ", "Mrs ", 
        /// "Mrs. ", "Miss ", "Ms " or "Ms. "
        let namesWithTitle = 
            names |> List.filter (fun name -> Regex.IsMatch(name, @"(Mr\.? |Mrs\.? |Miss |Ms\.? )"))
    
        /// This example shows how to remove all titles by replacing with the empty string.
        let namesWithTitlesRemoved = 
            names |> List.map (fun name -> Regex.Replace(name, @"(Mr\.? |Mrs\.? |Miss |Ms\.? )", ""))
    
        /// A function to identify duplicate words in some input text.
        ///  \b    - Start at a word boundary.
        ///  (\w+) - Match one or more word characters. Together, they form a group that can be referred to as \1.
        ///  \s    - Match a white-space character.
        ///  \1    - Match the substring that is equal to the group named \1.
        ///  \b    - Match a word boundary.
        let identifyDuplicateWords input = 
            for m in Regex.Matches(input, @"\b(\w+?)\s\1\b", RegexOptions.IgnoreCase) do
                printfn "\"%s\" duplicates '%s' at position %d" m.Value m.Groups.[1].Value m.Index
    
        /// Run the sample
        identifyDuplicateWords "This this is a nice day. What about this? This tastes good. I saw a a dog."
    
        // More information on using regular expressions with F# is available on MSDN.


### <a id="recursivetrees" />Recursive Trees ###

    /// This sample shows how to use union types to define a type of recursive trees 
    /// for an embedded language of expressions.
    module RecursiveTrees  = 
                  
        open System.Collections.Generic
    
        /// This type is an example of a discriminated union representing an expression tree
        /// in an embedded domain specific language.
        type Expr = 
            /// Represents a constant node in the expression tree
            | Number of int
            /// Represents an addition node in the expression tree
            | Add of Expr * Expr
            /// Represents a multiplication node in the expression tree
            | Multiply of Expr * Expr
            /// Represents a variable node in the expression tree
            | Var of string
      
        /// This function traverses an expression and evaluates it.  
        /// 
        /// If a variable node is encountered we look up the value of the variable in 
        /// the given environment. Here the environment is an F# map, which is an immutable
        /// dictionary collection, stored as a binary tree.
        let rec evaluateExpression (env:IDictionary<string,int>) expr = 
            match expr with
            | Number n -> n
            | Add (x,y) -> evaluateExpression env x + evaluateExpression env y
            | Multiply (x,y) -> evaluateExpression env x * evaluateExpression env y
            | Var id    -> env.[id]
      
        /// This is a sample initial environment which gives values to the variables a, b and c.
        let sampleEnvironment = dict [ ("a", 1) ; ("b", 2) ; ("c", 3) ]
                 
        /// This is a sample initial expression in the embedded domain specific language
        let sampleExpression = Add(Var "a", Multiply(Number 2, Var "b"))
    
        /// This evaluates the expression.
        let evaluationResult = evaluateExpression sampleEnvironment sampleExpression


### <a id="inlinedgenericarithmetic" />Inlined Generic Arithmetic ###

    /// This sample shows how to use inlined functions to create functions that are
    /// generic over arithmetic type.
    module InlinedGenericArithmetic = 
                  
        open System.Collections.Generic
    
        /// Return a square around a point, using any numeric type that supports addition and subtraction.
        /// The use of 'inline' means that the function becomes generic over arithmetic type.
        /// The square is represented as a tuple of points, where the points are also represented
        /// as tuples.
        let inline squareAroundPoint dx (x, y) = ( (x-dx, y-dx), (x+dx, y-dx), (x+dx, y+dx), (x-dx, y+dx))
    
        // A square, using 32-bit integer coordinates
        let square1 = squareAroundPoint 3 (10, 20)
    
        // A square, using floating point coordinates
        let square2 = squareAroundPoint 3.0 (10.0, 20.0)
    
        // A square, using big-integer coordinates
        let square3 = squareAroundPoint 3I (10I, 20I)


### <a id="unitsofmeasure" />Units Of Measure ###

    /// This sample shows how you can annotate your code with units of measure when using
    /// F# arithmetic over numeric types.
    module UnitsOfMeasure = 
                  
        open Microsoft.FSharp.Data.UnitSystems.SI.UnitNames
        open Microsoft.FSharp.Data.UnitSystems.SI.UnitSymbols
    
        /// Return two points 10 meters either side of the value.
        let leftAndRightByTenMeters (x: float<meter>) = (x - 10.0<m>,  x + 10.0<m>) 
    
        /// Check if a range contains a point
        let contains ((x1: float<m>, x2:float<meter>)) p = (x1 <= p && p <= x2)
    
        /// Check if two ranges overlap
        let overlap (x1, x2) p2 =  contains p2 x1 || contains p2 x2
    
        let area1 = leftAndRightByTenMeters 116.0<m>
        let area2 = leftAndRightByTenMeters 107.3<m>
    
        printfn "Do the areas overlap? - %s" (if overlap area1 area2 then "yes" else "no")
    
        /// Define a new unit-of-measure
        [<Measure>]
        type centimeter
    
        /// Define a conversion function for the new unit-of-measure based on a conversion constant
        let convertToMeters (x: float<centimeter>) = x / 100.0<centimeter/meter>
    
        convertToMeters 250.0<centimeter>


### <a id="events" />Events ###

    /// This sample shows how you can react to events in F# code.
    module Events = 
                  
        open System.Drawing
        open System.Windows.Forms
        
        /// Create a form
        let form = new Form(Text = "Sample Form For Events", TopMost=true, Size=Size(300,300), Visible=true)
        let button1 = new Button(Text = "Press Button 1", Location=Point(100,100), AutoSize=true)
        let button2 = new Button(Text = "Launch", Location=Point(100,160), AutoSize=true)
        let text = new Label (Text = "This form is a part of the 'Events' sample for showing how F# programs can react to events such as mouse clicks", 
                              Location=Point(20,50), Size=Size(260,40))
        form.Controls.Add button1
        form.Controls.Add button2
        form.Controls.Add text
    
        // This shows how to react to an event using a standard synchronous handler. You can also use
        // AddHandler and RemoveHandler to detach specific handler objects.
        button1.MouseClick.Add (fun args -> 
             text.Text <- sprintf "Button #1 was clicked. The mouse position (%d, %d)" args.X args.Y
        )
        
    
        // This shows how to react to an event using a pipeline of handlers. 
        form.MouseMove
           |> Event.filter (fun args -> args.X < 10 && args.Y < 10)
           |> Event.add (fun args -> 
               text.Text <- sprintf "The mouse moved over the secret area at position (%d, %d)" args.X args.Y
        )
    
        // This shows how to react to an event using an asynchronous handler that starts a co-routine. See the 
        // later samples for more information on asynchronous programming.
        button2.MouseClick.Add (fun args -> 
         async {
             for i in 5.0 .. -0.1 .. 0.0 do 
                text.Text <- sprintf "Countdown: %0.2f" i
                do! Async.Sleep 100
             text.Text <- "Blast off!" 
         } |> Async.StartImmediate)


### <a id="lightweightasyncagent" />Lightweight Asynchronous Agent ###

    /// This sample shows how you to create a lightweight asynchronous agent in F# code.
    module Agents = 
                  
        /// This is a common type alias used for the F# mailbox processor type
        type Agent<'T> = MailboxProcessor<'T>
        
        /// A simple agent that reacts to messsages, which are strings
        let agent1 = 
            Agent.Start (fun inbox -> async { 
                while true do 
                    let! message = inbox.Receive()
                    printfn "[Agents] Agent #1 received message <<<%s>>>"  message
             })
    
        // Send 10 messages to the agent
        for i in 1 .. 10 do 
            agent1.Post (sprintf "message %d to agent" i)
    
        
     
        /// A message type used by the second agent 
        type Message = 
            | Message1 of int
            | Message2 of AsyncReplyChannel<int>
    
        /// The second agent. The body is a series of asynchronous recursive functions.
        let agent2 = 
            Agent.Start (fun inbox -> 
                let rec state1 total = 
                    async { printfn "[Agents] now in state #1, total = %d" total
                            let! message = inbox.Receive()
                            match message with 
                            | Message1 n -> 
                                // Increment and go to state #2 
                                return! state2 (total + n)
                            | Message2 reply -> 
                                // Reply to the message and stay in state #1
                                reply.Reply total; 
                                return! state1 total }
    
                and state2 total = 
                    async { printfn "[Agents] now in state #2, total = %d" total
                            let! message = inbox.Receive()
                            match message with 
                            | Message1 n -> 
                                // Increment and go to state #1 
                                return! state1 (total + n)
                            | Message2 reply -> 
                                // Reply to the message and stay in state #2
                                reply.Reply total; 
                                return! state2 total }
                
                // Start in state one
                state1 0
             )
    
        for i in 1 .. 10 do 
            agent2.Post (Message1 i)
    
        let total = agent2.PostAndReply Message2



### <a id="parallelarraycomputations1" />Parallel Array Computations I ###

    /// This sample shows how to do some simple parallel array programming with F#
    module ParallelArrayComputations = 
                  
        // This is a smaller input array
        let oneSmallArray = [| 0 .. 100 |]
    
        // This is a bigger input array
        let oneBigArray = [| 0 .. 100000 |]
        
        // This does some CPU intensive computation 
        let rec computeSomeFunction x = 
            if x <= 2 then 1 
            else computeSomeFunction (x-1) + computeSomeFunction (x-2)
           
        // This shows how to do a parallel map over a small input array
        let computeResults1() = oneSmallArray |> Array.Parallel.map (fun x -> computeSomeFunction (x % 38))
    
        // We can use the same formula to do a parallel map over a large input array
        let computeResults2() = oneBigArray |> Array.Parallel.map (fun x -> computeSomeFunction (x % 20))
    
        // This shows how to do a slightly different parallel operation over a large input array.
        // The operation chooses results where the answer is even.
        let computeResults3() = 
            oneBigArray |> Array.Parallel.choose (fun x -> 
                let v = computeSomeFunction (x % 20) 
                if v % 2 = 0 then Some (x,v) else None)
    
        let results1 = computeResults1()
        let results2 = computeResults2()
        let results3 = computeResults3()
    
        printfn "[ParallelArrayComputations] results1 = %A" results1
        printfn "[ParallelArrayComputations] results2 = %A" results2
        printfn "[ParallelArrayComputations] results3 = %A" results3 

		
### <a id="parallelasynccomputations2" />Parallel Async Computations II ###

    /// This sample shows how to do some simple parallel async programming with F#.
    /// Parallel async programming usually involves a mixture of CPU and I/O intensive 
    /// computations.
    module ParallelAsyncComputations = 
                  
        /// A set of web pages to fetch in parallel
        let webPages = [ "http://www.microsoft.com"; 
                         "http://www.msdn.com"; 
                         "http://research.microsoft.com" ]
        
        /// Do an asynchronous fetch of a web page
        let asyncGetWebPage (url:string) = 
            async { use req = new System.Net.WebClient()
                    let! html = req.AsyncDownloadString(System.Uri(url))
                    return (url, html) }
    
        /// Get the results of a parallel fork-join composition and start as a background process
        let pages = 
            async { printfn "[ParallelAsyncComputations] The sample is starting..."
                    let! pages = Async.Parallel [ for page in webPages -> asyncGetWebPage page ]  
                    printfn "[ParallelAsyncComputations] The results are now ready"
                    /// Print the results
                    for (url, html) in pages do 
                        printfn "[ParallelAsyncComputations] The HTML for %s has %d characters"  url html.Length
            } |> Async.Start


### <a id="dbaccess" />Database Access ###

    /// This sample indicates how to access a database from F#.
    module DatabaseAccess = 
                  
        // The easiest way to access a SQL database from F# is to use F# type providers. To do this in 
        // a project, add a reference to System.Data, System.Data.Linq, FSharp.Data.TypeProviders.dll.
        // You can use Server Explorer to build your ConnectionString. 
    
        (*
        #if INTERACTIVE
        #r "System.Data"
        #r "System.Data.Linq"
        #r "FSharp.Data.TypeProviders"
        #endif
    
        open Microsoft.FSharp.Data.TypeProviders
        
        type SqlConnection = SqlDataConnection<ConnectionString = @"Data Source=.\sqlexpress;Initial Catalog=tempdb;Integrated Security=True">
        let db = SqlConnection.GetDataContext()
    
        let table = 
            query { for r in db.Table do
                    select r }
        *)
    
    
        // You can also use SqlEntityConnection instead of SqlDataConnection, which accesses the database using Entity Framework.
        //
        // Alternatively, use the ADO.NET library to access database connections in a dynamically typed way.
    
        let placeHolder = 1


### <a id="odata" />OData Access ###

    module ODataAccess = 
                  
        // The easiest way to access an OData service from F# is to use F# type providers. To do this in 
        // a project, add a reference to System.Data, System.Data.Linq, FSharp.Data.TypeProviders.dll.
        //
        // For more about OData see www.odata.org. You can use a search engine to find suitable service URLs.
        // One good source of OData sources is the Azure Data Market.
    
        (*
        #if INTERACTIVE
        #r "System.Data.Services.Client"
        #r "FSharp.Data.TypeProviders"
        #endif
    
        // open System.Data.Services.Client
        // open Microsoft.FSharp.Data.TypeProviders
    
        // Consume demographics population and income OData service from Azure Marketplace. For more information, Please go to https://datamarket.azure.com/dataset/c7154924-7cab-47ac-97fb-7671376ff656
        type Demographics = ODataService<ServiceUri = "https://api.datamarket.azure.com/Esri/KeyUSDemographicsTrial/">
        let ctx = Demographics.GetDataContext()
        
        //To sign up for a Azure Marketplace account at https://datamarket.azure.com/account/info
        ctx.Credentials <- System.Net.NetworkCredential ("<your liveID>", "<your Azure Marketplace Key>")
         
        let cities = 
            query { for c in ctx.demog1 do
                    where (c.StateName = "Washington")
                    select c } 
        
        for c in cities do
            printfn "%A - %A" c.GeographyId c.PerCapitaIncome2010.Value
    
        *)
    
        let placeHolder = 1


### <a id="boilerplateform" />Boilerplate WinForm ###

    #if COMPILED
    module BoilerPlateForForm = 
        [<System.STAThread>]
        do ()
        do System.Windows.Forms.Application.Run()
    
    #endif

