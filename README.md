# Datum.Collector

> NOTE: This is a Work in Progress and documents the Intent as of time of writin not necessarily what is or will be implemented!

Gather data and cache them serialized in a structure.


## Problem it aims to solve

When managing infrastructure, it is always needed to gather information about different systems:
 - Services configured to start automatically but in a stopped state
 - Certificates installed and their expiration date
 - System information such as serial number, model, RAM, Disk space and so on

Some of those information can be about a system (a server, appliance, physical or virtual), or more and more often against a service: Active Directory, a service's API and so on.

The data is often used to monitor a state, or to give context to a situation:
 - Monitor: This is the data the last time the system polled
 - Alert: if data 'x' is of value 'y', the state is 'z', we should take action 'xyz'
 - Context: There's an outage, lets look at the System infos for clues

Traditionally, those systems are polled centrally by a tool commonly known as a CMDB (Configuration Management Database). Some CMDB try to offer other capabilities, such as a GUI, alerts, or configuration and remediation.

Datum.Collector instead focuses on collecting the data and defining what to collect, how and when. How this data is consumed, stored, or exposed is left to other systems to implement.

The assumption is that the data will be used in several ways, without the need to be queried each time by different systems, and the testing of systems should be decoupled from the gathering of the system's data.

## Intentions

### Requirements

The key characteristics of the envisaged solution are:
- declarativeness: manage the configuration of Datum.Collectors from human readable files.
- segregation of concerns: Collect the data based on a configuration, don't manage deployment, updates of the configuration...
- Object tree representation: Data should be stored in an object's properties, so it's easy to access data by a 'path' following the dot notation (`$collectedData.propertyContainer.PropertyDatum`).
- Definition tree represents collected data structure: Folders are containers, files either data return by a single container or reprensent a map of the sub properties made available.

### Intended Usage

The first use case I have in mind is the ability to run infrastructure tests against the data structure to ensure compliance of an expected state, but also make that data available to other systems, such as exporting to a file.

Presenting the Data in a tree of properties makes it structured in a familiar way.
Validation of systems can be written against that tree, decoupling the data collection from the testing of values: `$collectedData.computerSystem.TotalPhysicalMemory | Should -be 68406890496`.

At the same time, the data can be sent to a central storage system: `$collectedData.ToJSon() | Out-File \\myFileShare\dataCollected.json`.

### Defining what to collect

The data is to be collected by pieces of code, declared in a definition document (Yaml/JSON), named  Datum Collectors.
A Datum.Collector definition is a Yaml document that has all the properties required to implement the Datum Collector it desires.

The Built-in collectors are:
 - ScriptBlock: Allow the execution of the provided scriptblock, embedded in the definition.
 - Command: Execute the Command, function, alias with the provided Parameters.
 - DscResource: Invoke the DSC Resource with provided properties, and the Get or Test method.

The user creates a definition tree under which he adds the Yaml (or JSON) definitions of the collectors.

```
.\ROOT
│   property2.yml
│
└───property1
        subProperty11.yml
        subproperty12.yml
```

from there, the structure is created so that the properties exist:

```PowerShell
$rootObject.property2
# should return the result of the collector defined in property2.yml

$rootObject.property1.subProperty11
# should return the result of the collector defined in property11.yml

# and so on...

$rootObject.property1.subProperty12
```
