---
layout: post
title: "Validating with XSD stored as Embedded Resource"
date: "2008-01-13 16:16:42"
comments: false
categories:
- biztalk
---

Last week I was involved with the maintenance of a class library responsible for validating a message against its schema. This was being invoked from an orchestration. As an older utility library, was based on .NET 1.1 base classes (e.g. `XmlValidatingReader`) and took in an `XLANGMessage` parameter to extract both the message content and the associated schema (as per the BizTalk message definition).


For various [reasons](http://support.microsoft.com/kb/917841) the `XLANGMessage` dependency was to be broken, and some 2.0 optimisation put in place. In my experience, I have never had the need to do XSD validation straight from an orchestration — so the real need for this still escapes me.

The [XML Validator pipeline component](http://msdn2.microsoft.com/en-us/library/aa578187.aspx) already offers this functionality. Anyway, this was the first opportunity I've had to spend some quality time with the new 2.0 `XmlSchemaSet` class. I was amazed to see that all the plumbing for dealing with complex multi namespace/include/import schema "networks" just seemed to work. The particular schema set I was working with for example, was spread over 8 xsd files, through a nested graph of imports and includes.

The `XmlSchemaSet` sports a number of resolution methods, with URL resolvers, which will inspect a schema for its dependencies and "reach out" to pull in any imports and/or includes. In my case, each of the individual pieces of the schema set were loaded from embedded resources and added to the `XmlSchemaSet` manually by setting the `XmlResolver` property to null. Once the dependences have been resolved, a compile is required, which from that point on will expose the entire schema set as if it were one big xml schema in the first place.

    private XmlSchema LoadSchema(string tag)
    {
      string resource = String.Format("Net.Bencode.{0}.xsd", tag);
      using (Stream stream = Assembly.GetCallingAssembly().GetManifestResourceStream(resource))
      {
        return XmlSchema.Read(stream, HandleValidation);
      }
    }
    
    private XmlSchemaSet LoadSchemaSet()
    {
      XmlSchemaSet set = new XmlSchemaSet();
      set.XmlResolver = null;// new XmlUrlResolver();
      set.Add(LoadSchema("schemaA"));
      set.Add(LoadSchema("schemaB"));
      set.Add(LoadSchema("schemaC"));
      set.Add(LoadSchema("schemaD"));
      set.Add(LoadSchema("schemaE"));
      set.Compile();
      return set;
    }
