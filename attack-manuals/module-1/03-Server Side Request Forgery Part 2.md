# Objective

Access CosmosDB and Storage Accounts by leveraging the SSRF Vulnerability.

# Solution

A Server-Side Request Forgery (SSRF) attack involves an attacker abusing server functionality to access or modify resources. 

While creating a new post from the web application, there exists a feature to upload an image from a URL. This input field supports file protocol that allows the user to read the local files from the function app which will lead to an SSRF attack.

For accessing cosmos DB and storage accounts, we need to have connection strings. In this attack, we will export all the data from the `local.settings.json` file.

local.settings.json is for testing Azure Function locally on your machine. When deployed to Azure, you will set the environment variables in  Application Settings under the function app. So when a developer publishes the function app from the local environment, local.settings.json is also uploaded to the deployed app which has all the credentials for the working application and hence it will be accessible through the SSRF attack.



### Open the web application, click on "Get Started" and create a new account.

![](https://user-images.githubusercontent.com/65826354/183737518-9636cd66-8f8b-4b02-8895-fb2ef6a28ba9.png)

Fill in the details and create a new account.


![](https://user-images.githubusercontent.com/65826354/183737533-7db7a3fa-8d6b-4c59-9237-10c1bc1322b5.png)

Now, click on the "Register" and log in using the new credentials.


![](https://user-images.githubusercontent.com/65826354/183737538-de9cad78-853f-47ce-b085-e79718c5e98a.png)

![](https://user-images.githubusercontent.com/65826354/183737548-8e227a83-1180-43cf-92d0-b1a18d2382c0.png)


Now, you have access to the web application.

### From the side navigation bar, select Newpost.

Go to the web application, and from the side navigation menu, select "Newpost".

![](https://user-images.githubusercontent.com/65826354/183737555-61b21043-d83d-438d-943f-fec0bb50b4e0.png)


Open the developer tools console and enter the URL of the image as mentioned below and click on upload.

**Note:** If you are using Firefox, you have to reload the tab by clicking reload button.


**Payload:**

```
file:///etc/passwd
```

The /etc/passwd file is the most important file in Linux operating system. This file stores essential information about the users on the system. Getting this file as a response will confirm the SSRF vulnerability.

<!-- ![](https://user-images.githubusercontent.com/65826354/183737555-61b21043-d83d-438d-943f-fec0bb50b4e0.png) -->

![](https://user-images.githubusercontent.com/65826354/183737572-13c80a32-48f8-4237-bfc2-f52e441dda52.png)

You will get a pop-up saying, "URL File uploaded successfully". After that, open the response and copy the URL.

![](https://user-images.githubusercontent.com/65826354/183737585-9897592d-7f2c-4305-b0e3-90106f5a7c8d.png)

### Download the file and try to open it.

After the successful download of file, you will find that the file is in .png format.

![](https://user-images.githubusercontent.com/65826354/183737592-914855aa-4e42-4b6b-8b45-8af70c1f219c.png)


### Open the terminal to display the data.

Open the terminal and view the content of the ``/etc/passwd`` file.

**Command:**

```bash
cat <File_Name>
```

Here we have the file name as `20220808114951907112.png`. So the command will be the following.

**Command:**

```bash
cat 20220808114951907112.png
```

![](https://user-images.githubusercontent.com/65826354/183737600-a5c3f93e-6304-4286-b1a7-93b6fb32e1c2.png)

We successfully got the ``/etc/passwd`` file.

### Now, we will try to fetch the */local.settings.json* file.

The local.settings.json file contains the environment variable referenced by the app function environment. This can have extremely sensitive data like access credentials and connection strings.

Enter the payload into the "Enter URL of the image" section, and hit upload.

The location `/home/site/wwwroot/` contains all the function app files. So to access the local.settings.json the path will be the following.

Payload:
```
file:///home/site/wwwroot/local.settings.json
```


Now, copy the URL from the response and download the ``local.settings.json`` file.

![](https://user-images.githubusercontent.com/65826354/183737610-84831db5-5e1d-4eeb-aa3f-3346b45371f3.png)

![](https://user-images.githubusercontent.com/65826354/183737620-b9092b44-fcad-4d4b-b5a5-08307fa6f648.png)

### List the content of the *local.settings.json* file.

Open the terminal and use the "cat" command to list the file's content.

**Command:**

```bash
cat <File_Name>
```
Here we have the file name as `20220808115206011087.png`. So the command will be the following.

**Command:**

```bash
cat 20220808115206011087.png
```

![](https://user-images.githubusercontent.com/65826354/183737643-5e66caaf-7d99-4a7e-9591-6cd5cadb9af6.png)

### Open the VSCode text editor and install the Azure Databases extension.

Azure databases extension in vscode is used to browse and query your Azure databases both locally and in the cloud. Through this method, we can attach azure cosmosdb in the workspace and perform operations on it.

![](https://user-images.githubusercontent.com/65826354/183737654-f8550a24-513d-4742-8f4a-35bc3e56fdf9.png)

### Configure the Azure database account with your local machine.

Click on "Attach Database Account" and enter the "AccountEndpoint" and "AccountKey" from the ``local.settings.json`` file.

![](https://user-images.githubusercontent.com/65826354/183737669-dc444bb8-1a78-45cf-aa39-217f2c271709.png)

From the ``local.settings.json`` file, copy the "AccountEndpoint" and "AccountKey" values.

![](https://user-images.githubusercontent.com/65826354/183737675-6ba5dabc-3765-4bcc-8835-fc176e5eaebe.png)

Now, make a connection string with the format: 

```
AccountEndpoint=<AZ_DB_ENDPOINT>;AccountKey=<AZ_DB_PRIMARYKEY>
```

![](https://user-images.githubusercontent.com/65826354/183737683-d867a786-5378-4e74-a3bc-9957b5b2e225.png)

Use this string to connect the Azure Database Account with the local machine.

Paste that string into VSCode as shown below and hit "Enter".

![](https://user-images.githubusercontent.com/65826354/183737690-2cc78369-448f-4e5a-a3f7-3b5f768319de.png)

Now, create a new password for a keyring if you're on a Kali Linux distribution and click on "Continue"

![](https://user-images.githubusercontent.com/65826354/183737701-85179921-b21f-4c90-a93d-4453bafe10ba.png)

We successfully configured the Azure Database Account with our local machine.

### Now open the database files and manipulate them to gain admin privileges.

Open the "Davis M" file.

![](https://user-images.githubusercontent.com/65826354/183737710-b280e475-24fe-4b40-97e5-1ba1da2553af.png)

Change the "authLevel" to "0" and click on "Upload" when prompted.

![](https://user-images.githubusercontent.com/65826354/183737719-e5d0db41-c4cd-4a3f-854c-55c8f6265e33.png)

You can also change the name from "Davis M" to "Davis Mike" the same way and see the changes.

![](https://user-images.githubusercontent.com/65826354/183737724-5165a1e2-3edd-4669-bb07-295345e496e0.png)

### Login again to see the changes.

Inside the web application, click on "Logout".

![](https://user-images.githubusercontent.com/65826354/183737732-30460217-a4d6-477c-9d1c-c7f53781505e.png)

Now, log in with the same credentials as the "Davis" user.

![](https://user-images.githubusercontent.com/65826354/183737737-3d963462-6a67-4d10-b344-82922410b9d2.png)

You can see the user name is changed from "Davis M" to "Davis Mike" and we also got admin privileges.

![](https://user-images.githubusercontent.com/65826354/183737746-91caec63-e3b8-4b0c-972b-b0d81c7caa06.png)

We successfully accessed the database and escalated our privileges.

## Now, let's try to access the Azure Storage account.

### Open VSCode and install the Azure Storage extension.

Azure Storage extension is used to perform the following operations.

-   Explore/Create/Delete Blob Containers, File Shares, Queues, Tables, and Storage Accounts

-   Create, Edit, and Delete Block Blobs and Files

-   Upload and Download Blobs, Files, and Folders

![](https://user-images.githubusercontent.com/65826354/183737753-a716f0f2-e80c-43dd-8280-0e95c641b22b.png)

### Configure the Azure Storage Account with your local machine.


Click on the "Attached Storage Accounts" and enter the connection string.

![](https://user-images.githubusercontent.com/65826354/183737764-0828cabd-3575-439f-80eb-ac95f77daa99.png)

Copy the connection string from the ``local.settings.json`` file.

![](https://user-images.githubusercontent.com/65826354/183737776-59eacefb-307a-4a7f-95f7-9b7463253568.png)

Now, paste this string into the VSCode and hit "Enter".

![](https://user-images.githubusercontent.com/65826354/183737783-9f3003ca-e7f1-4d35-a200-f024bb3489b0.png)

We successfully have configured the Azure Storage Account with our local machine.

### Exploit the Web Application.

You can download the source code by exploring the file system as shown in the images below.

![](https://user-images.githubusercontent.com/65826354/183737793-fc277da3-ecee-4fa2-b153-938575cf43e8.png)

![](https://user-images.githubusercontent.com/65826354/183737801-1f2a1467-f6e6-4cfa-8bda-ccd1668042a9.png)

![](https://user-images.githubusercontent.com/65826354/183737811-30390897-fbc3-44b2-97a5-4ffd258df8ac.png)

![](https://user-images.githubusercontent.com/65826354/183737821-8b27eb65-fab9-4ca5-af8f-5f1d245df848.png)


**Voila! We successfully interacted with CosmosDB and fetched the application code from the Storage Account.**