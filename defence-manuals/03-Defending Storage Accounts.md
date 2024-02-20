# Defending Storage Account with ScoutSuite & Azure Alerts

An Azure storage account contains all your Azure Storage data objects, including blobs, file shares, queues, tables, and disks. The storage account provides a unique namespace for your Azure Storage data that's accessible from anywhere in the world over HTTP or HTTPS. Your storage account's data is durable, highly available, secure, and massively scalable.

Azure Storage provides different types of storage accounts. Each type supports unique features and has its pricing model. Consider these differences before creating a storage account to find the best application account. The types of storage accounts are: *General-purpose v2 accounts*, *General-purpose v1 accounts*, *Block Blob Storage accounts*, *File Storage accounts* and *Blob Storage accounts*.

Misconfigured storage can leak the company's or an organization's sensitive data, leading to a huge loss.

ScoutSuite is an open-source security tool that helps security professionals assess the security of their Microsoft Azure environments, Amazon Web Services (AWS) and Google Cloud. The tool is designed to automate auditing cloud infrastructure for security risks and vulnerabilities. It analyzes various security configurations, such as Storage Accounts, Azure RBAC, Virtual Machines etc.., and identifies any misconfigurations that could leave the environment vulnerable to attack.

# Solutions

**Step 1:** Open the web application.

![](images/3_defending_storage_accounts/1.png)

**Step 2:** Now, right-click on the screen and click on "view page source".

![](images/3_defending_storage_accounts/2.png)

**Step 3:**  Copy the visible URL and paste it into the browser.

![](images/3_defending_storage_accounts/4.png)

Navigate to this URL. You will get an output like this.

![](images/3_defending_storage_accounts/5.png)

Notice that the URL has the container name in it, and it starts with prod. So there exists a possibility that there will be a dev container.

![](images/3_defending_storage_accounts/6.png) 

The development container URL is mentioned below. Here we changed prod to dev by guessing.
```
https://appazgoat9458436storage.blob.core.windows.net/dev-appazgoat9458436-storage-container/webfiles/build/favicon/logo.png
```
![](images/3_defending_storage_accounts/7.png) 

**Step 4:** Navigate to this modified URL. You will get an output like this.

![](images/3_defending_storage_accounts/8.png)

**Step 5:** We will try modifying the URL to fetch all the components from the storage container. Remove the following from the URL as shown below

![](images/3_defending_storage_accounts/9.png)

Append the following text to the container URL to list the objects.
```
?restype=container&comp=list
```
Change the request parameter in the URL, as shown in the image below.

![](images/3_defending_storage_accounts/10.png)

Navigate with the modified URL.

![](images/3_defending_storage_accounts/11.png)

The container listing is successful, which means the storage container is misconfigured. We need to reconfigure it from container-level access to blob-level access.

*Don't close the Window.*

**Step 6:** Open any of those highlighted links and check.

![](images/3_defending_storage_accounts/12.png)

The output of the first link is shown below:

![](images/3_defending_storage_accounts/13.png)

We will use the Scoutsuite to detect misconfigurations in our storage account. To use the ScoutSuite, we need to clone the ScoutSuite repository.

**Step 7:** Open the terminal and Clone the ScoutSuite GitHub repository.
```
git clone https://github.com/nccgroup/ScoutSuite
```

![](images/3_defending_storage_accounts/14.png)

Change the directory to ScoutSuite.
```
cd ScoutSuite
```

![](images/3_defending_storage_accounts/15.png)

**Step 8:** Run the following command to install the requirements.
```
pip install -r requirements.txt
```

![](images/3_defending_storage_accounts/16.png)

**Step 9:** Run the following command to log into your Azure account.
```
az login
```

![](images/3_defending_storage_accounts/17.png)

**Step 10:** Launch the scout using the given command:
```
python3 scout.py Azure --cli
```

![](images/3_defending_storage_accounts/18.png)

It takes time, depending on the number of resources that you have.

![](images/3_defending_storage_accounts/19.png)

After fetching information from all resources, it opens the following report page on your default browser.

![](images/3_defending_storage_accounts/20.png)

The red coloured warning symbol indicates Danger, the Yellow coloured warning symbol indicates Warning and the Green coloured warning symbol indicates Good.

**Step 11:** Click on the Service Storage Accounts.

![](images/3_defending_storage_accounts/21.png)

**Step 12:** Click on the *Blob Container Allowing Public Access*.

![](images/3_defending_storage_accounts/22.png)


**Step 13:** Open the *appazgoatxxxxxxxstorage* storage account.

![](images/3_defending_storage_accounts/23.png)

You can see these are the following containers with public access enabled. Public access is both *Blob* level and *Container* level.

With Blob level access, a user can READ/DOWNLOAD a blob from the container if they know the name of the blob which is inside the container.

With Container level access, a user can READ/DOWNLOAD even without knowing the names of the blob which is inside the container because the user has the privilege to LIST all the blobs from the container.

![](images/3_defending_storage_accounts/24.png)

**Step 14:** Open the portal and click on appazgoatxxxxxxxstorage Storage account.

![](images/3_defending_storage_accounts/25.png)

You can see these are storage containers that have public access enabled.

![](images/3_defending_storage_accounts/26.png)

**Step 15:** We choose only containers with Container level access. And we will make those to Blob level access.

![](images/3_defending_storage_accounts/27.png)

**Step 16:** Click on ellipsis button and choose *Change access level*.

![](images/3_defending_storage_accounts/28.png)

Change to *Blob* access level

![](images/3_defending_storage_accounts/29.png)

**Step 17:** Similarly, perform the same action on another container.

![](images/3_defending_storage_accounts/30.png)

You can see that now both containers are changed to Blob access level, and none of the containers has a Container access level.

![](images/3_defending_storage_accounts/31.png)

**Step 18:** Go back to the blobs Listed window and click on the Refresh button.

![](images/3_defending_storage_accounts/32.png)

You will see an error message because the container no longer has access to the Container level; it has only Blob level access.

![](images/3_defending_storage_accounts/33.png)

We properly re-configured our storage account.

**Step 19:** Go back to the Home page and click on *Login*.

![](images/3_defending_storage_accounts/34.png)

**Step 20:** If you don't have an account, click here to create one and log in as a user.

![](images/3_defending_storage_accounts/35.png)

Fill in the following and click on *Register*.

![](images/3_defending_storage_accounts/36.png)

**Step 21:** log in with the newly created user account.

![](images/3_defending_storage_accounts/37.png)

After login in as a user, you will see the following page, and if you see 0 posts on the page, then Refresh the page.

![](images/3_defending_storage_accounts/38.png)

We will go to the Newpost tab, try uploading a high-resolution picture(big-size file), and check whether it accepts.

**Step 22:** Click on the Newpost tab, and we will upload a 17MB image file.

![](images/3_defending_storage_accounts/39.png)

The upload is successful, which means the user can upload any big image file, and neither action is taken on the user, nor the admin is notified. For the demo purpose, we will create an alert where the admin will be notified if any user tries uploading a big-size file.

**Note:** Any image link can be used.

**Step 23:** Login to the azure portal as an admin; you can see the uploaded images in the following container.

![](images/3_defending_storage_accounts/40.png)

Open the container and navigate with the path; you will see the user uploaded a 17MB image file.

![](images/3_defending_storage_accounts/41.png)

For the demo purpose, we will create an alert for the admin; if any user uploads a file of more than 6MB, the admin will be notified via Email.

**Step 24:** We need to check metrics before creating an alert. Metrics will help us understand which type of signal we need to send to trigger an alert. Click on Metrics.

![](images/3_defending_storage_accounts/42.png)

We need to change the below highlighted:

![](images/3_defending_storage_accounts/43.png)

Make changes as shown in the below image:

Metric Namespace: *Blob*,

Metric: *Ingress*,

Aggregation: *Sum*,

Set Local time 30 mins.

![](images/3_defending_storage_accounts/44.png)

You can see the Recent upload is a 17.4MB image file.

![](images/3_defending_storage_accounts/45.png)

Now, we understand which type of signals to be sent to trigger an Alert.

**Step 25:** Click on *Alerts*.

![](images/3_defending_storage_accounts/46.png)

**Step 26:** Choose *Alert rules*.

![](images/3_defending_storage_accounts/47.png)

Click on *+ Create*.

![](images/3_defending_storage_accounts/48.png)

Choose Signal type *Metrics*,

Signal Name: Ingress.

![](images/3_defending_storage_accounts/49.png)

Fill in the following as given below:

Threshold: *Static*,

Aggregation type: *Total*,

Operator: *Greater than*,

Unit: *MiB*,

Threshold value: 6.

And Click on *Next:Action* button.

![](images/3_defending_storage_accounts/50.png)

**Step 27:** Click on *+ Create action group* 

![](images/3_defending_storage_accounts/51.png)

Fill in the following and Click on Next.

![](images/3_defending_storage_accounts/52.png)

Choose Notification type: Email/SMS

Check the Email: give your email ID, enable the common Alert schema, and click OK.

![](images/3_defending_storage_accounts/53.png)

Give a name and click on the Next button.

![](images/3_defending_storage_accounts/54.png)

These are the Action types that we can perform apart from notifying.

![](images/3_defending_storage_accounts/55.png)

For this demo, we are just notifying the admin and not performing any action, so click on *Review + Create*.

![](images/3_defending_storage_accounts/56.png)

Click on *Create*.

![](images/3_defending_storage_accounts/57.png)

We created our Action Group, and now Click on the Next button.

![](images/3_defending_storage_accounts/58.png)

**Step 28:** Fill the following details and click on *Review + Create*.

![](images/3_defending_storage_accounts/59.png)

**Step 29:** Click on Create button.

![](images/3_defending_storage_accounts/60.png)

Once after creation, within a few minutes, you will receive an email to the registered mail id as shown below:

![](images/3_defending_storage_accounts/61.png)

**Step 30:** Check the Alerts by adding an image file of more than 6MB. I am adding the same 17MB image file.

![](images/3_defending_storage_accounts/62.png)

After some time, I received an email from Microsoft Azure with a Subject **Fired: Sev3 Azure Monitor Alert ....**

![](images/3_defending_storage_accounts/64.png)

**Note:** A metric alert in a "Fired" state will not trigger again until it's resolved. This is done to reduce noise.

Now, you may upload an image file which is *less than 6MB* or else *don't upload* any image file. After some time, you will receive another email from Microsoft Azure with a Subject **Resolved: Sev3 Azure Monitor Alert ....**

![](images/3_defending_storage_accounts/67.png)

The alert is resolved automatically when the alert condition isn't met for three consecutive evaluations. Now, it is in a resolved state; again, if any user uploads beyond the threshold, it will go to the "Fired" state, and the admin will be notified.

Instead of notification alerts, you may perform actions with the help of Alert rules; for creating actions, you may refer to *Step 27*.

We have learnt how to use ScoutSuite, and also we have learnt how to create alerts when a specific condition is met.


# References

ScoutSuite: https://github.com/nccgroup/ScoutSuite