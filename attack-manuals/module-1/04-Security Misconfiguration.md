# Objective

Identify the security misconfiguration and access sensitive information from the azure resource group.

# Solution


The most common practice for software development is by having a development and production environment setup. It is very important when organizations deal with very sensitive and private data, like client information, ID, and numbers Moreover, we want this for avoiding production data getting intermingled with test data.

However, in some cases, the development environment will be having same data with less security and with similar names and hence it leads to security misconfiguration.

### Open the web application and open the page source.

![](https://user-images.githubusercontent.com/65826354/183737053-17881055-f5d4-42b0-9a16-12142264aeef.png)

Now, right-click on the screen and click on "view page source".

![](https://user-images.githubusercontent.com/65826354/183737061-b3b278e2-4d8d-44b5-92a8-573fb7e8233e.png)

Copy the page source data.

![](https://user-images.githubusercontent.com/65826354/183737069-2e77fe5a-fbfa-441f-a941-36f75761f36b.png)
### Now beautify the copied code.

Visit the link- https://codebeautify.org/htmlviewer to beautify your code.

![](https://user-images.githubusercontent.com/65826354/183737091-922a2304-8dbd-4a6e-978a-fa129e97bbae.png)

![](https://user-images.githubusercontent.com/65826354/183737106-b79d88fd-d5a2-4f21-86a6-70383dbe3143.png)

### Copy the beautified code into the text editor and look for the app logo URL.

![](https://user-images.githubusercontent.com/65826354/183737123-04b6feaf-99df-41a9-ba54-e950c306ce4e.png)

Now, copy the URL and paste it into the browser.

```
https://appazgoatstoga.blob.core.windows.net/prod-appazgoat-storage-container/webfiles/build/favicon/Logo.png
```

Navigate to this URL. You will get an output like this.

![](https://user-images.githubusercontent.com/65826354/183737130-6d5a4df2-354c-4091-ada7-f37e9db75910.png)

Append the following text to the container URL to list the objects inside that container.

```
?restype=container&comp=list
```

It will result in an access denied message and hence we cannot list the objects present inside the production container.

Notice that the URL is having the container name in it and it is starting with `prod`. So there exists a possibility that there will be a dev container.

The development container URL is mentioned below. Here we changed prod to dev.

```
https://appazgoatstoga.blob.core.windows.net/dev-appazgoat-storage-container/webfiles/build/favicon/Logo.png
```
This URL will result in the same image as above and that means there exists a dev container.

### Now modify the URL to fetch the storage container's components list.
Append the following text to the container URL to list the objects inside that container.

```
?restype=container&comp=list
```

Change the request parameter in the URL, as shown in the image below.

![](https://user-images.githubusercontent.com/65826354/183737138-cd8b817b-5d31-48af-a2ba-ffb7a2e31d00.png)

Successfully listed all the data inside the dev container.

This means that the development container has list and read access.

### Search for ".ssh" in the XML response.

Then copy the URL of the config.txt file as shown in the below image.

![](https://user-images.githubusercontent.com/65826354/183737145-184f7906-4945-4e0c-bb72-b68c115211a9.png)

### Download the config.txt file from the terminal.

![](https://user-images.githubusercontent.com/65826354/183737152-9f10b663-fdd5-477e-9ee1-083b40addfb7.png)

### List the config.txt file content.

![](https://user-images.githubusercontent.com/65826354/183737161-12180bbc-8737-4ecf-a650-94958e5b6265.png)

### Now explore the network using nmap.

Copy the host IP address of the "alice" user and explore the network using the following nmap command.

```bash
nmap 40.85.170.40 -Pn
```
We can see the state is open.

![](https://user-images.githubusercontent.com/65826354/183737176-f0f26b23-70df-4a8f-9569-c134184aa457.png)

### Go to the XML response and search "justin.pem" and copy its URL

![](https://user-images.githubusercontent.com/65826354/183737185-a28c4fbf-f484-4cf5-a103-c674b673d30f.png)

### Using the copied URL download the ".pem" file

![](https://user-images.githubusercontent.com/65826354/183737195-aca59c38-f63c-467a-8859-8e2d30c8a4ee.png)

***Congrats! We successfully downloaded the SSH private key as a ".pem" file.***

