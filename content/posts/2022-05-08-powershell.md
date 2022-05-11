---
layout: post
draft: false
title: "PowerShell cheat sheet"
slug: "powershell"
date: "2022-05-08 16:35:04+11:00"
lastmod: "2022-05-08 16:35:04+11:00"
comments: false
categories:
  - powershell
tags:
  - scripting
  - windows
  - winnt
  - ps1
  - powershell
---

- [Help and context](#help-and-context)
- [Execution policy](#execution-policy)
- [Operators](#operators)
- [Regex](#regex)
- [Flow Control](#flow-control)
- [Variables](#variables)
- [Functions](#functions)
- [Modules](#modules)
- [Module Management](#module-management)
    - [Good modules to run](#good-modules-to-run)
- [Filesystem](#filesystem)
- [Hashtables (Dictionary)](#hashtables-dictionary)
- [Windows Management Instrumentation (WMI)](#windows-management-instrumentation-wmi)
- [Async](#async)
    - [Filesystem events](#filesystem-events)
    - [Timers](#timers)
- [PowerShell drives](#powershell-drives)
- [Data (CRUD) management](#data-crud-management)
- [Damn handy](#damn-handy)

A work in progress.

Credits:

- <https://gitlab.com/JamesHedges/notes/-/wikis/Powershell/PowerShell-Cheat-Sheet>
- <https://gist.github.com/pcgeek86/336e08d1a09e3dd1a8f0a30a9fe61c8a>

## Help and context

```powershell
$PSVersionTable.PSVersion         # what version

Get-Command                       # list commands available
Get-Command -Module Microsoft*    # list commands exported from modules named Microsoft*
Get-Command -Name *item           # wildcard search commands

Get-Help
Get-Help -Name about_Variables
Get-Help -Name Get-Command
Get-Help -Name Get-Command -Parameter Module
```

## Execution policy

Levels = {Restricted,Remote Signed,All Signed,Unrestricted}

```powershell
Get-ExecutionPolicy -List                                               # list available policies
Set-ExecutionPolicy -ExecutionPolicy RemoteSinged -Scope LocalMachine   # set policy for local computer
```

## Operators

```powershell
$a = 2
$a += 1
$a -= 1

$a -eq 0
$a -ne 5
$a -gt 2
$a -lt 3

$FirstName = 'Trevor'
$FirstName -like 'T*'

$KaleIsYummy = $true
$FoodToEat = $KaleIsYummy ? 'kale' : 'mushrooms'
```

## Regex

```powershell
'Trevor' -match '^T\w\*'
$matches[0]                                 # returns 'Trevor'

@('Trevor', 'Billy', 'Bobby') -match '^B'   # returns Billy, Bobby

$regex = [regex]'(\w{3,8})'
$regex.Matches('Trevor Bobby Joe').Value    # multiple matches against a single string
```

## Flow Control

```powershell
if (1 -eq 1) { }

do { 'hi' } while ($false)

while ($false) { 'hi' }
while ($true) { }
while ($true) { if (1 -eq 1) { break } }

for ($i = 0; $i -le 10; $i++) { Write-Host $i }
foreach ($item in (Get-Process)) { }

switch ('test') { 'test' { 'matched'; break } }      # returns 'matched'

switch -regex (@('Trevor', 'Daniel', 'Bobby')) {
  'o' { $PSItem; break }                               # $PSItem or $_ refers to the current matched item
}

switch -regex (@('Trevor', 'Daniel', 'Bobby')) {     # switch fallthrough
  'e' { $PSItem }
  'r' { $PSItem }
}
```

## Variables

```powershell
$a = 0
[int] $a = 'Trevor'         # type exception
[string] $a = 'Trevor'      # fine
Get-Command -Name *varia*   # commands for variables

Get-Variable                                                 # array with in-scope variables
Get-Variable | ? { $PSItem.Options -contains 'constant' }    # filter constants
Get-Variable | ? { $PSItem.Options -contains 'readonly' }    # filter readonly

New-Variable -Name FirstName -Value Trevor
New-Variable FirstName -Value Trevor -Option Constant        # global constant, removal requires PowerShell restart
New-Variable FirstName -Value Trevor -Option ReadOnly        # removal requires Remove-Variable -Force

Remove-Variable -Name firstname
Remove-Variable -Name firstname -Force
```

## Functions

```powershell
function add ($a, $b) { $a + $b }   # simple

function Do-Something {             # explicit param block and {begin,process,end} hooks
  [CmdletBinding]()]
  param ()
  begin { }
  process { }
  end { }
}
```

## Modules

```powershell
Get-Command -Name _module_ -Module mic\*core     # module related commands

Get-Module -ListAvailable                        # dump available modules ($env:PSModulePath)
Get-Module                                       # currently imported modules

$PSModuleAutoLoadingPreference = 0               # disable auto-loading
Import-Module -Name NameIT                       # explicitly import a module (must exist in $env:PSModulePath)
Remove-Module -Name NameIT                       # remove module from the scope of session

New-ModuleManifest                               # boilerplate new module manifest

New-Module -Name trevor -ScriptBlock {           # in-memory module
  function Add($a,$b) { $a + $b } }

New-Module -Name trevor -ScriptBlock {           # in-memory module, available to Get-Module
  function Add($a,$b) { $a + $b } } | Import-Module
```

## Module Management

```powershell
Get-Command -Module PowerShellGet # Explore commands to manage PowerShell modules

Find-Module -Tag cloud # Find modules in the PowerShell Gallery with a "cloud" tag
Find-Module -Name ps\* # Find modules in the PowerShell Gallery whose name starts with "PS"

Install-Module -Name NameIT -Scope CurrentUser -Force # Install a module to your personal directory (non-admin)
Install-Module -Name NameIT -Force # Install a module to your personal directory (admin / root)
Install-Module -Name NameIT -RequiredVersion 1.9.0 # Install a specific version of a module

Uninstall-Module -Name NameIT # Uninstall module called "NameIT", only if it was installed via Install-Module

Register-PSRepository -Name <repo> -SourceLocation <uri> # Configure a private PowerShell module registry
Unregister-PSRepository -Name <repo> # Deregister a PowerShell Repository
```

#### Good modules to run

- [git-aliases](https://www.powershellgallery.com/packages/git-aliases/0.3.5)

## Filesystem

```powershell
New-Item -Path c:\test -ItemType Directory # Create a directory
mkdir c:\test2 # Create a directory (short-hand)

New-Item -Path c:\test\myrecipes.txt # Create an empty file
Set-Content -Path c:\test.txt -Value '' # Create an empty file
[System.IO.File]::WriteAllText('testing.txt', '') # Create an empty file using .NET Base Class Library

Remove-Item -Path testing.txt # Delete a file
[System.IO.File]::Delete('testing.txt') # Delete a file using .NET Base Class Library
```

## Hashtables (Dictionary)

```powershell
$Person = @{
  FirstName = 'Trevor'
  LastName = 'Sullivan'
  Likes = @(
    'Bacon',
    'Beer',
    'Software'
  )
}                                                           # Create a PowerShell HashTable

$Person.FirstName                                           # Retrieve an item from a HashTable
$Person.Likes[-1] # Returns the last item in the "Likes" array, in the $Person HashTable (software)
$Person.Age = 50 # Add a new property to a HashTable
```

## Windows Management Instrumentation (WMI)

```powershell
Get-CimInstance -ClassName Win32_BIOS # Retrieve BIOS information
Get-CimInstance -ClassName Win32_DiskDrive # Retrieve information about locally connected physical disk devices
Get-CimInstance -ClassName Win32_PhysicalMemory # Retrieve information about install physical memory (RAM)
Get-CimInstance -ClassName Win32_NetworkAdapter # Retrieve information about installed network adapters (physical + virtual)
Get-CimInstance -ClassName Win32_VideoController # Retrieve information about installed graphics / video card (GPU)

Get-CimClass -Namespace root\cimv2 # Explore the various WMI classes available in the root\cimv2 namespace
Get-CimInstance -Namespace root -ClassName \_\_NAMESPACE # Explore the child WMI namespaces underneath the root\cimv2 namespace
```

## Async

#### Filesystem events

```powershell
$Watcher = [System.IO.FileSystemWatcher]::new('c:\tmp')
Register-ObjectEvent -InputObject $Watcher -EventName Created -Action {
  Write-Host -Object 'New file created!!!'
}
```

#### Timers

```powershell
$Timer = [System.Timers.Timer]::new(5000)
Register-ObjectEvent -InputObject $Timer -EventName Elapsed -Action {
  Write-Host -ForegroundColor Blue -Object 'Timer elapsed! Doing some work.'
}
$Timer.Start()
```

## PowerShell drives

```powershell
Get-PSDrive                                                                # list all
New-PSDrive -Name videos -PSProvider Filesystem -Root x:\data\videos       # create
New-PSDrive -Name h -PSProvider FileSystem -Root '\\box\h$\data' -Persist  # persistent mount
Set-Location -Path videos:                                                 # change context
Remove-PSDrive -Name xyz                                                   # delete
```

## Data (CRUD) management

```powershell
Get-Process | Group-Object -Property Name                              # group
Get-Process | Sort-Object -Property Id                                 # sort
Get-Process | Where-Object -FilterScript { $PSItem.Name -match '^c' }  # filter
gps | where Name -match '^c'                                           # shorthand of above using aliases
```

## Damn handy

```powershell
# remote or local invocation
Invoke-Command -ScriptBlock {Get-EventLog system -Newest 50}                        # run locally
Invoke-Command -ScriptBlock {Get-EventLog system -Newest 50} -ComputerName Box123   # run remote on box123

# local invocation using text command
$cmd = Get-Process
Invoke-Expression $cmd

# cURL for winnt
(Invoke-WebRequest -Uri "https://docs.microsoft.com").Links.Href

# fork
Start-Process -FilePath "notepad" -Verb runAs

# kill
Stop-Process -Id 1337          # by pid
Stop-Process -Name "notepad"   # by name

# web output
Get-Service | ConvertTo-HTML -Property Name, Status > C:\services.htm
```
