
# Read Secrets

Reads values from Key Vault to allow sharing data between task phases, releases and applications.

## Getting Started

This extension solves a problem common to environments deployed through VSTS.  Often, one task or release creates unique values that need to be consumed by other, independent tasks.  These subsequent tasks are not part of the same phase, or even the same release, but they need access to the unique values that were created during the original deployment.

An example of this is the creation of an Azure Service Bus.  The deployment via ARM template can output the connection strings that are needed by applications or web services that use the Service Bus.  However, the deployment of the Service Bus is often independent of the deployment of the applications.  As a result, the VSTS task can't feed the values to the application without manual intervention (i.e. copy and paste).

This extension uses Azure's Key Vault as a conduit to connect these two, disparate events.  This extension retrieves Key Vault secrets (which may have been uploaded by the Write Secrets extionsion), and stores the secrets as VSTS variables that be used in subsequent VSTS tasks.  

### Limitations with VSTS's native Key Vault integration
Some could argue that VSTS already offers integration with Azure's Key Vault.  However, this integration requires secrets to be added manually to a linked variable library in advance of any deployment.  This limits the usefulness in a dynamic environment where resource creation feeds information to higher layers of the stack.  Secondly, VSTS's integration with Key Vault is limited to reading secrets.  No native VSTS ability exists to write secrets to Key Vault from VSTS.

### Prerequisites
This extension requires an existing Key Vault in an accessible Azure subscription.

## Configuration
The script can run in one of two modes:

### Sinlge secret retrieval
This will retrieve a single secret from the selected Key Vault by name.  It stores the secret in a VSTS variable with a name matching the name of the secret.

### Multiple secret retrieval
This mode will retrieve all Key Vault secrets matching the specified tag values.  This is useful for situations where several secrets are needed by subsequent tasks.  Setting tag values in a format similar to "Environment=Production" enables the retrieval of all Key Vault secrets with a tag named `Environment` evaluating to `Production`.

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* Craig Boroson 

See also the list of [contributors](https://github.com/cboroson/ReadSecrets/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Pascal Naber at Xpirit for VSTS code samples
