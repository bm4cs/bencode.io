---
layout: post
title: "BizTalk Servers Slow First Hit"
date: "2010-08-02 23:10:10"
comments: false
categories: "BizTalk"
---

Lately I been thinking about BizTalk Server, and a particular behavior that it consistently demonstrates without fail. It takes a dreadful amount of time to service a “cold” request, however once “warmed”, it hums.

Its challenging at best to justify this behavior to a technology ignorant client. Without getting too deep into BizTalk Servers internals (I would love to spend some time with windbg and the SOS extension digging around), I wanted a way to have partial control over how BizTalk Server manages the actual processes that invoke the code we make. All mainstream BizTalk artefacts (orchestrations, maps, pipelines) boil down to managed code (IL). BizTalk consumes our crafted “business” assemblies (dll’s) by loaded them into its address space through one or more AppDomain’s, at which time the messaging engine can call out to them when it sees fit.

This spawns a number of related questions; how many dll’s per appdomain? Under what conditions does an appdomain’s get “garbage collected” by the messaging engine? And so on. So I digged a little deeper.

Thanks to [Tomas Restrepo](http://www.winterdom.com/weblog/) for posting the excellent MSDN link to [Orchestration Engine Configuration](http://msdn.microsoft.com/en-us/library/aa578610.aspx), which in essence sums up everything I wished for. Basically it involves hacking the `BTSNTSvc.exe.config`, which host instances take into account when started. While you can do cool things like control dehydration behaviour, and more, I was more interested in this:

> Assemblies are assigned to named domains using assignment rules (see more below). If no rule is specified for some assembly, the assembly will be assigned to an ad hoc domain. The number of such assigned assemblies per ad hoc domain is determined by the value of AssembliesPerDomain.

Which translates to this in btsntsvc.exe.config:

{% highlight xml %}
<AppDomains AssembliesPerDomain=<span class="str">"10"</span>>
   <AppDomainSpecs>
      <AppDomainSpec Name=<span class="str">"FooDomain"</span> SecondsIdleBeforeShutdown=<span class="str">"-1"</span> SecondsEmptyBeforeShutdown=<span class="str">"-1"</span> />
   </AppDomainSpecs>
   <ExactAssignmentRules>
      <ExactAssignmentRule AssemblyName=<span class="str">"Foo.Orchestration, Version=1.0.0.0, Culture=neutral, PublicKeyToken=9f3a0f87e62e465c"</span> AppDomainName=<span class="str">"FooDomain"</span> />
   </ExactAssignmentRules>
</AppDomains>
{% endhighlight %}


The interesting properties *SecondsEmptyBeforeShutdown* and *SecondsIdleBeforeShutdown*, are defined as follows:

- SecondsEmptyBeforeShutdown is the number of seconds that an app domain is empty (that is, it does not contain any orchestrations) before being unloaded. Specify -1 to signal that an app domain should never unload, even when empty. 
- SecondsIdleBeforeShutdown is the number of seconds that an app domain is idle (that is, it contains only dehydratable orchestrations) before being unloaded. Specify -1 to signal that an app domain should never unload when idle but not empty. When an idle but non-empty domain is shut down, all of the contained instances are dehydrated first.


Thanks to Mick Badran, who has posted a handy [BTSNTSvc.exe.config template](http://blogs.breezetraining.com.au/mickb/2006/08/10/BTSNTSvcexeConfigSettingsMoreCompleteAndHandy.aspx), which includes the AppDomain configuration section discussed above.

Here’s a copy of my own *no frills* template:

{% highlight xml %}
<?xml version="1.0" ?>
<configuration>
  <configSections>
    <section name="xlangs" type="Microsoft.XLANGs.BizTalk.CrossProcess.XmlSerializationConfigurationSectionHandler, Microsoft.XLANGs.BizTalk.CrossProcess" />
  </configSections>
  <system.net>
    <connectionManagement>
      <add address="*" maxconnection="48"/>
    </connectionManagement>
  </system.net>
  <runtime>
    <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
      <probing privatePath="BizTalk Assemblies;Developer Tools;Tracking;Tracking\interop" />
    </assemblyBinding>
  </runtime>
  <system.runtime.remoting>
    <channelSinkProviders>
      <serverProviders>
        <provider id="sspi" type="Microsoft.BizTalk.XLANGs.BTXEngine.SecurityServerChannelSinkProvider,Microsoft.XLANGs.BizTalk.Engine" securityPackage="ntlm" authenticationLevel="packetPrivacy" />
      </serverProviders>
    </channelSinkProviders>
    <application>
      <channels>
        <channel ref="tcp" port="0" name="">
          <serverProviders>
            <provider ref="sspi" />
            <formatter ref="binary" typeFilterLevel="Full"/>
          </serverProviders>
        </channel>
      </channels>
    </application>
  </system.runtime.remoting>
  <xlangs>
    <Configuration>
      <AppDomains AssembliesPerDomain="10">
        <AppDomainSpecs>
          <AppDomainSpec Name="FooDomain" SecondsIdleBeforeShutdown="-1" SecondsEmptyBeforeShutdown="-1" />
          <AppDomainSpec Name="BarDomain" SecondsIdleBeforeShutdown="-1" SecondsEmptyBeforeShutdown="-1" />
        </AppDomainSpecs>
        <PatternAssignmentRules>
          <PatternAssignmentRule AssemblyNamePattern="Net.benCode.Foo.*, Version=\d.\d.\d.\d, Culture=neutral, PublicKeyToken=.{16}" AppDomainName="FooDomain" />
          <PatternAssignmentRule AssemblyNamePattern="Net.benCode.Bar.*, Version=\d.\d.\d.\d, Culture=neutral, PublicKeyToken=.{16}" AppDomainName="BarDomain" />
        </PatternAssignmentRules>
      </AppDomains>
    </Configuration>
  </xlangs>
</configuration>
{% endhighlight %}