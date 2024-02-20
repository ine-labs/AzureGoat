# AzureGoat : A Damn Vulnerable Azure Infrastructure

![1](https://user-images.githubusercontent.com/25884689/183740998-da6f7ae7-2df0-4557-a6f5-2f0040ebe0dc.png)

Compromising an organization's cloud infrastructure is like sitting on a gold mine for attackers. And sometimes, a simple misconfiguration or a vulnerability in web applications, is all an attacker needs to compromise the entire infrastructure. Since the cloud is relatively new, many developers are not fully aware of the threatscape and they end up deploying a vulnerable cloud infrastructure. Microsoft Azure cloud has become the second-largest vendor by market share in the cloud infrastructure providers (as per multiple reports), just behind AWS. There are numerous tools and vulnerable applications available for AWS for the security professional to perform attack/defense practices, but it is not the case with Azure. There are far fewer options available to the community.

AzureGoat is a vulnerable by design infrastructure on Azure featuring the latest released OWASP Top 10 web application security risks (2021) and other misconfiguration based on services such as App Functions, CosmosDB, Storage Accounts, Automation and Identities. AzureGoat mimics real-world infrastructure but with added vulnerabilities. It features multiple escalation paths and is focused on a black-box approach.

AzureGoat uses IaC (Terraform) to deploy the vulnerable cloud infrastructure on the user's Azure account. This gives the user complete control over code, infrastructure, and environment. Using AzureGoat, the user can learn/practice:
- Cloud Pentesting/Red-teaming
- Auditing IaC
- Secure Coding
- Detection and mitigation

The project is divided into modules and each module is a separate web application, powered by varied tech stacks and development practices. 

**Presented at**

- [BlackHat USA 2022](https://www.blackhat.com/us-22/arsenal/schedule/index.html#azuregoat--a-damn-vulnerable-azure-infrastructure-28000)
- [DC 30: Demo Labs](https://forum.defcon.org/node/242061)

### Developed with :heart: by [INE](https://ine.com/) 

[<img src="https://user-images.githubusercontent.com/25884689/184508144-f0196d79-5843-4ea6-ad39-0c14cd0da54c.png" alt="drawing" width="200"/>](https://discord.gg/TG7bpETgbg)

## Built With

* Azure
* React
* Python 3
* Terraform

## Vulnerabilities

The project is scheduled to encompass all significant vulnerabilities including the OWASP TOP 10 2021, and popular cloud misconfigurations.
Currently, the project  contains the following vulnerabilities/misconfigurations.

* XSS
* SQL Injection
* Insecure Direct Object reference
* Server Side Request Forgery on App Function Environment
* Sensitive Data Exposure and Password Reset
* Storage Account Misconfigurations
* Identity Misconfigurations

# Getting Started

### Prerequisites
* An Azure Account


### Installation

To ease the deployment process the user just needs to clone this repo, login to azure cli then initialize and apply the Terraform file. This workflow will deploy the whole infrastructure and output the hosted application's URL. 

Here are the steps to follow:

**Step 1.** Clone the repo

```sh
git clone https://github.com/ine-labs/AzureGoat
```

**Step 2.** Login to Azure CLI

```sh
az login
```

And follow the steps to sign in.

**Step 3.** Create a resource group with the name "azuregoat_app".

**Step 4.** Use terraform to deploy AzureGoat

```sh
terraform init
terraform apply --auto-approve
```

# Modules

## Module 1

The first module features a serverless blog application utilizing Azure App Functions, Storage Accounts, CosmosDB, and Azure Automation. It consists of various web application vulnerabilities and facilitates exploitation of misconfigured Azure resources.

Overview of escalation paths for module-1

![6](https://user-images.githubusercontent.com/25884689/183740988-9fa75f39-8c85-4db7-a5a9-c0f4acdb2783.png)

# Contributors

Nishant Sharma, Director, Lab Platform, INE <nsharma@ine.com>

Jeswin Mathai, Chief Architect, Lab Platform, INE  <jmathai@ine.com>

Rachna Umaraniya, Cloud Developer, INE <rumaraniya@ine.com>

Sherin Stephen, Software Engineer (Cloud), INE <sstephen@ine.com>

Shantanu Kale, Cloud Developer, INE <skale@ine.com>

Sanjeev Mahunta, Software Engineer (Cloud), INE <smahunta@ine.com>

D Yashwanth Babu, Software Engineer (Cloud), INE <dbabu@ine.com>

# Solutions

The offensive manuals are available in the [attack-manuals](attack-manuals/) directory, and the defensive manuals are available in the [defence-manuals](defence-manuals/) directory. 

Module 1 Exploitation Videos: https://www.youtube.com/playlist?list=PLcIpBb4raSZGdYHKpqIu5Boc2ziga4oGY 

# Documentation

For more details refer to the "AzureGoat.pdf" PDF file. This file contains the slide deck used for presentations.

# Screenshots

Blog Application HomePage

![1](https://user-images.githubusercontent.com/25884689/183741003-04609eaa-63fd-43c3-9851-d1e10b5763a9.png)

Blog Application Login Portal

![2](https://user-images.githubusercontent.com/65826354/183737940-b1fa7b71-82cb-4744-af6a-22386c22a934.png)

Blog Application Register Page

![3](https://user-images.githubusercontent.com/65826354/183737954-2ede9a5b-0797-4eef-8329-9871c14327fd.png)

Blog Application Logged in Dashboard

![4](https://user-images.githubusercontent.com/65826354/183737967-a2af9d1e-9805-4658-8055-f3f7ee982b63.png)

Blog Application User Profile

![5](https://user-images.githubusercontent.com/65826354/183737979-20c60ca1-14e0-4da9-a3c7-161ef9a62591.png)

## Contribution Guidelines

* Contributions in the form of code improvements, module updates, feature improvements, and any general suggestions are welcome. 
* Improvements to the functionalities of the current modules are also welcome. 
* The source code for each module can be found in ``modules/module-<Number>/src`` this can be used to modify the existing application code.

# License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License v2 as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

# Sister Projects

- [AWSGoat](https://github.com/ine-labs/AWSGoat)
- [GCPGoat](https://github.com/ine-labs/GCPGoat)
- [PA Toolkit (Pentester Academy Wireshark Toolkit)](https://github.com/pentesteracademy/patoolkit)
- [ReconPal: Leveraging NLP for Infosec](https://github.com/pentesteracademy/reconpal) 
- [VoIPShark: Open Source VoIP Analysis Platform](https://github.com/pentesteracademy/voipshark)
- [BLEMystique](https://github.com/pentesteracademy/blemystique)
