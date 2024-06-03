---
layout: post
title: "C# 3.0 Language Extensions"
date: "2008-12-25 18:50:26"
comments: false
categories:
- biztalk
---

Put together a little snippet to remind myself of the some of the beautiful language extensions that shipped with the C# language.

{% highlight csharp %}
namespace CSharpLanguageExperiment
{
  using System;
  using System.Collections.Generic;
  using System.Linq; 

  class Program
  {
    static void Main(string[] args)
    {
      // Object Initialiser
      Person bill = new Person { FirstName = "Bill", LastName = "Gates", Age = 40 }; 

      // Type Inference
      var ben = new Person { FirstName = "Ben", LastName = "Simmonds", Age = 25 }; 

      // Anonymous Types
      var john = new { FirstName = "John", LastName = "Smith", Age = 18 }; 

      // Anonymous Delegate
      Func<string, bool> filter1 = delegate(string name)
      {
        return name.Length > 4;
      };
      filter1("hel"); 

      // Lambda Expression
      Func<string, bool> filter2 = x => x.Length > 4;
      filter2("foobar"); 

      // Extension Method
      ben.GetData(); 

      // Queries
      List<Person> people = new List<Person>();
      people.Add(bill);
      people.Add(ben);
      Func<Person, bool> filter = x => x.Age > 30;
      IEnumerable<Person> exp = people.Where(filter); 

      foreach (Person person in exp)
      {
        Console.WriteLine(person.GetData());
      }
    }
  } 


  public class Person
  {
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public int Age { get; set; } 

    public override string ToString()
    {
      return String.Format("{0} {1}",
        FirstName,
        LastName);
    }
  } 


  // Extension Method
  public static class PersonExtension
  {
    public static string GetData(this Person person)
    {
      return String.Format("Name: {0} {1} Age: {2}",
        person.FirstName,
        person.LastName,
        person.Age);
    }
  }
}
{% endhighlight %}
