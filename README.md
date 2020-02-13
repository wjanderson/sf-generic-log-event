# Salesforce Generic Event Logger  

This is a work in progress!

Goal is to use a generic platform event that can handle any type of information of the users choosing. This way you can listen for one event and dispatch based on the **method** or **action**.

![Generic flow](https://github.com/bjanderson70/sf-generic-log-event/blob/master/img/generic-logger.jpg)

|Parts                         |  Concrete Class
|------------------------------|-------------------------------------|
|Read Salesforce Custom Metadata |	accc_LogEventMetadataModel |
|Read the Metadata that describes the Data pulled from the Sobject list.|	accc_MetadataDefaultReader |
|Output (Json) Generator|	accc_PayLoadGeneratorJSON |
|Data Handler, processes the collection of SObjects using both the  |accc_MetadataDefaultReader and accc_ PayLoadGeneratorJSON	| accc_MetaDataHandler|
|Builder, accc_MetadataBuilder builds the above parts using the Salesforce Custom Metatdata |	accc_MetadataBuilder|
|Metadata Manager, accc_MetaDataManager, orchestrates all the above parts |	accc_MetaDataManager|
|Metadata Service, accc_MetaDataService, uses the metadata Manager to bring all the components together, and processes the incoming Sobject collection ( asynchronously or synchronously via accc_MetadataLogEventChunked  ). It is considered the service/business layer.|	accc_ MetaDataLogEntryService|
|Chunking of Sobject collections for handling. The underlying function allows a larger number of SObjects to be processed (i.e. creating and sending Log Events). However, it is not without additional limitations as well.| 	accc_MetadataLogEventChunked |
|The processor, accc_MetadataEventProcessor, performs work synchronously. The behavior is controlled by the custom metadata and used by the Chunker and Service. If data is NOT chunked, the Chunker invokes the processor; otherwise, it utilizes a queueable object passing in the processor along with the chunk SObjects,|	accc_MetadataEventProcessor|


## Part 1: Choosing a Development Model

There are two types of developer processes or models supported in Salesforce Extensions for VS Code and Salesforce CLI. These models are explained below. Each model offers pros and cons and is fully supported.

### Package Development Model

The package development model allows you to create self-contained applications or libraries that are deployed to your org as a single package. These packages are typically developed against source-tracked orgs called scratch orgs. This development model is geared toward a more modern type of software development process that uses org source tracking, source control, and continuous integration and deployment.

If you are starting a new project, we recommend that you consider the package development model. To start developing with this model in Visual Studio Code, see [Package Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/package-development-model). For details about the model, see the [Package Development Model](https://trailhead.salesforce.com/en/content/learn/modules/sfdx_dev_model) Trailhead module.

If you are developing against scratch orgs, use the command `SFDX: Create Project` (VS Code) or `sfdx force:project:create` (Salesforce CLI)  to create your project. If you used another command, you might want to start over with that command.

When working with source-tracked orgs, use the commands `SFDX: Push Source to Org` (VS Code) or `sfdx force:source:push` (Salesforce CLI) and `SFDX: Pull Source from Org` (VS Code) or `sfdx force:source:pull` (Salesforce CLI). Do not use the `Retrieve` and `Deploy` commands with scratch orgs.

### Org Development Model

The org development model allows you to connect directly to a non-source-tracked org (sandbox, Developer Edition (DE) org, Trailhead Playground, or even a production org) to retrieve and deploy code directly. This model is similar to the type of development you have done in the past using tools such as Force.com IDE or MavensMate.

To start developing with this model in Visual Studio Code, see [Org Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/org-development-model). For details about the model, see the [Org Development Model](https://trailhead.salesforce.com/content/learn/modules/org-development-model) Trailhead module.

If you are developing against non-source-tracked orgs, use the command `SFDX: Create Project with Manifest` (VS Code) or `sfdx force:project:create --manifest` (Salesforce CLI) to create your project. If you used another command, you might want to start over with this command to create a Salesforce DX project.

When working with non-source-tracked orgs, use the commands `SFDX: Deploy Source to Org` (VS Code) or `sfdx force:source:deploy` (Salesforce CLI) and `SFDX: Retrieve Source from Org` (VS Code) or `sfdx force:source:retrieve` (Salesforce CLI). The `Push` and `Pull` commands work only on orgs with source tracking (scratch orgs).

## The `sfdx-project.json` File

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

The most important parts of this file for getting started are the `sfdcLoginUrl` and `packageDirectories` properties.

The `sfdcLoginUrl` specifies the default login URL to use when authorizing an org.

The `packageDirectories` filepath tells VS Code and Salesforce CLI where the metadata files for your project are stored. You need at least one package directory set in your file. The default setting is shown below. If you set the value of the `packageDirectories` property called `path` to `force-app`, by default your metadata goes in the `force-app` directory. If you want to change that directory to something like `src`, simply change the `path` value and make sure the directory you’re pointing to exists.

```json
"packageDirectories" : [
    {
      "path": "force-app",
      "default": true
    }
]
```
