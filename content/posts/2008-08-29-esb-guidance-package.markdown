---
layout: post
title: "ESB Guidance Package"
date: "2008-08-29 21:50:55"
comments: false
categories: BizTalk
---

Lately I've been having heaps of fun playing with what's known as the "[ESB Guidance](http://www.codeplex.com/esb)" (ESBG). A community/open source driven initiative as an attempt to fill the gap Microsoft currently have in the SOA/ESB space. At a high level it augments its existing messaging/integration engine, BizTalk Server, by adding extended functionality. The ESB guidance aims to:
 
- Demonstrate how to implement an ESB pattern using BizTalk 
- Outline best practices
- Reduce the amount of "plumbing" clients would have to implement themselves
- Reduce the total cost and effort of an ESB implementation


As of the November 2007 release it contains:
 
- Architectural Guidance
- Prebuilt Components
- Prebuilt Services
- Sample Applications
- Exception Management Framework and Administration Portal
- Available at [http://www.codeplex.com/esb](http://www.codeplex.com/esb)


In its current state it is not a formally supported "product" by Microsoft, and depending on your environment may not be appropriate for a production grade ESB implementation. It does however effectively demonstrate core ESB capabilities using the BizTalk Server product, facilitating exploratory/concept activities using the Microsoft platform.


### Prerequisite Software

- InfoPath and Excel 2003 (should be installed through BizTalk installation procedure). InfoPath plays a role in the repair and resume portal.
- A functional BizTalk Server 2006 R2 installation, including optional components BAM, BAM Alerts, and the Business Rule Engine.
- BizTalk Server 2006 R2 Hotfix KB943871, which adds support for new error reporting context properties.
- Enterprise Library 3.1
- DebugView. The ESBG is highly instrumented and this utility will render this information.
- Certificate Services (Windows Server component)
- UDDI Services (Windows Server component)
- Dundas Chart for ASP.NET Enterprise


### Gotchas

**Release and Development Assemblies**

If you've followed the installation guide and installed from source, your GAC assemblies will have a different public key from the release files, so you won't be able to install the sample rules from GlobalBank.ESB.Policies.msi. This particular problem will also prevent you from deploying particular examples (e.g. ScatterGather) into BizTalk, which performs a complete dependency check. Types are incompatible between assemblies (to the CLR TypeA from assembly X is completely different from TypeA in assembly Y).

The source for the samples uses the correct key, so you can build and deploy from VS to create the sample app and populate the BRE components. A few of the samples have inter-dependencies. To avoid sample dependency issues, the sequence of sample installation has been outlined below.


**UDDI Error 285014**

The ESB Guidance uses the Microsoft.Practices.ESB.UDDIPublisher.exe executable to deploy sample endpoint definitions to the UDDI catalogue. With a default IIS 6.0 configuration this tool will fail with the following:

> Error 285014: An unexpected error occurred retrieving the Category Key for the TModel name, 'System.ServiceModel.Security.MessageSecurityException: The HTTP request is unauthorized with client authentication scheme 'Negotiate'. The authentication header received from the server was 'NTLM,Basic realm="localhost"'.

The IIS metabase needs to be tweaked for IIS to support both the Kerberos and NTLM authentication protocols.
[http://support.microsoft.com/kb/215383](http://support.microsoft.com/kb/215383)

    cd c:\inetpub\adminscripts
    cscript adsutil.vbs set w3svc/WebSite/root/NTAuthenticationProviders "Negotiate,NTLM"
    cscript adsutil.vbs get w3svc/WebSite/root/NTAuthenticationProviders


**UDDI Error 285023**

Depending on how UDDI Services has been configured, you may encounter the following response when running the Microsoft.Practices.ESB.UDDIPublisher.exe executable:

    Creating entries...
     Adding Default Category for ESB Runtime Resolution
     Error creating UDDI entries... Error 285023: An unexpected error occurred creating the new Category, 'System.ServiceModel.FaultException`1[uddiorg.api_v2.dispositionReport]:  (Fault Detail is equal to uddiorg.api_v2.dispositionReport).', in Uddi.

Review your eventlog for UDDI diagnostics. If you have a UDDIRuntime error log of the UDDI_ERROR_FATALERROR_HTTPSREQUIREDFORPUBLISH category, this relates to an incorrect SSL configuration. A quick solution to this problem would be to disable UDDI’s use of SSL.


### Sequential Installation Procedure

- Install prerequisite software.
- Install `ESB Guidance November 2007.msi`.
- Extract `ESBSource.zip` to `C:\Projects\Microsoft.Practices.ESB\`. Some configuration files have dependencies on this absolute path location.
- Create the ESB exception management database. Execute `EsbExceptionDb_CREATE.sql` from `C:\Projects\Microsoft.Practices.ESB\Source\Exception Handling\SQL\ESB.ExceptionHandling.Database\Create Scripts`.


### Install ESB Core
 
- Navigate to `C:\Projects\Microsoft.Practices.ESB\Source\Core\Install\Scripts`.
- Update the `PreProcessingCORE.vbs` script with credentials that will work for your specific BizTalk installation.
- Run all the scripts in this directory, in sequential order.
- Update the `ALL.Exceptions` SQL send-port definition to point at the correct database server (i.e. the database created in step 4 above).
- Make the following changes to the standard `BTSNTSvc.exe.config` file. Add the following snippet below the opening `<configuration>` element.

        <configSections>
          <section name="xlangs" type="Microsoft.XLANGs.BizTalk.CrossProcess.XmlSerializationConfigurationSectionHandler, Microsoft.XLANGs.BizTalk.CrossProcess" />
        </configSections>


Add the following snippet above the closing `</configuration>` element.
 
    <xlangs>
      <Configuration>
        <AppDomains AssembliesPerDomain="10">
          <DefaultSpec SecondsIdleBeforeShutdown="1200" SecondsEmptyBeforeShutdown="1800" />
          <AppDomainSpecs>
            <AppDomainSpec Name="Microsoft.Practices.ESB">
              <BaseSetup>
                <ConfigurationFile>C:\Projects\Microsoft.Practices.ESB\Source\Core\Config\
    Microsoft.Practices.ESB.PipelineComponents.config</ConfigurationFile>
              </BaseSetup>
            </AppDomainSpec>
          </AppDomainSpecs>
          <PatternAssignmentRules>
            <PatternAssignmentRule AssemblyNamePattern="Microsoft.Practices.ESB.*" AppDomainName="Microsoft.    Practices.ESB" />
          </PatternAssignmentRules>
        </AppDomains>
      </Configuration>
    </xlangs>
 
- Restart the BizTalk windows service.
- Modify the `machine.config` for the 2.0 .NET runtime, at `%WINDIR%\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config`, by adding the following snippet directly below the opening `<configSections>` element.


        <sectionGroup name="ESBProcessor">
          <section name="Resolver" type="System.Configuration.DictionarySectionHandler, System,Version=2.0.0.0,    Culture=neutral, PublicKeyToken=b77a5c561934e089"/>
          <section name="AdapterProvider" type="System.Configuration.DictionarySectionHandler, System,Version=2.0.0.0    ,Culture=neutral, PublicKeyToken=b77a5c561934e089"/>
          <section name="ItineraryCache"  type="System.Configuration.DictionarySectionHandler, System,Version=2.0.0.0    ,Culture=neutral, PublicKeyToken=b77a5c561934e089"/>
          <section name="Cache" type="System.Configuration.DictionarySectionHandler, System,Version=2.0.0.0,    Culture=neutral, PublicKeyToken=b77a5c561934e089"/>
        </sectionGroup>


Add the following snippet immediately above the closing `</configuration>` element. Be careful in regard to which version of the ESB assemblies you are using, the ESB guidance ships with both development and release versions which have been strong named with different public keys.

To summarise, any assemblies installed through ESB installers (MSI’s) downloaded from Microsoft will GAC release level versions. Release versions are incompatible with development versions due to the difference in strong naming. Development versions (recommended) are only available through the manual procedure of building assemblies from source. That is, pre-built development binaries cannot be downloaded.

If you intend to use the pre-packaged sample source code that demonstrates various ESBG functionality, go with the development version of the assemblies, as all sample source code is bound to the development ESB assemblies and you get debugging symbols (pdb) which can make troubleshooting much easier.
 
**Warning**: If you attempt to mix both flavours of assemblies together (e.g. only GAC release quality assemblies but install and run the samples against development versions) this will result in nasty typing (e.g. casting) incompatible problems at runtime.
 
You can distinguish the flavours of assembly by examining the public key token:
Release: 31bf3856ad364e35
Development (Recommended): c2c8b2b87f54180a
 
    <ESBProcessor>
      <Resolver>
        <add key="UDDI" value="Microsoft.Practices.ESB.Resolver.UDDI,  Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" />
        <add key="WSMEX" value="Microsoft.Practices.ESB.Resolver.WSMEX,  Version=1.0.0.0, Culture=neutral,  PublicKeyToken=31bf3856ad364e35" />
        <add key="XPATH" value="Microsoft.Practices.ESB.Resolver.XPATH, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" />
        <add key="STATIC" value="Microsoft.Practices.ESB.Resolver.STATIC, Version=1.0.0.0, Culture=neutral,  PublicKeyToken=31bf3856ad364e35" />
        <add key="BRE" value="Microsoft.Practices.ESB.Resolver.BRE, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" />
      </Resolver>
      <AdapterProvider>
        <add key="WCF-WSHttp" value="Microsoft.Practices.ESB.Adapter.WcfWSHttp, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" />
        <add key="WCF-BasicHttp" value="Microsoft.Practices.ESB.Adapter.WcfBasicHttp, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" />
        <add key="FTP" value="Microsoft.Practices.ESB.Adapter.FTP, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" />
        <add key="FILE" value="Microsoft.Practices.ESB.Adapter.FILE, ersion=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" />
        <add key="MQSeries" value="Microsoft.Practices.ESB.Adapter.MQSeries, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" />
      </AdapterProvider>
      <ItineraryCache>
        <add key="timeout" value="120" />
      </ItineraryCache>
      <Cache>
        <add key="UDDI" value="600" />
        <add key="WSMEX" value="600" />
      </Cache>
    </ESBProcessor>


### Install ESB Exception Handling
 
1. Navigate to `C:\Projects\Microsoft.Practices.ESB\Source\Exception Handling\Install\Scripts`.
2. Update the `PreProcessingCORE.vbs` script with credentials that will work for your specific BizTalk installation.
3. Run all the scripts in this directory, in sequential order.
Install the ESB UDDI Publishing Windows Service
1. Open the solution `C:\Projects\Microsoft.Practices.ESB\Source\Samples\Management Portal\ESB.UDDI.PublisherService\ESB.UDDI.PublisherService.sln`.
2. Edit the `App.config`, and verify connection strings are correct for the `EsbExceptionDb` and `ESBAdmin` databases.
3. Release mode build the solution—two projects, a windows service project and an installer project.
4. Run the MSI generated by the installer project.
5. Start the newly registered windows service (using `services.msc`).

If you have made it this far you should now have a healthy ESB Guidance rig up & running. I hope to follow up with a series of articles, decomposing how the ESBG can be used/augmented to provide common ESB capabilities.

