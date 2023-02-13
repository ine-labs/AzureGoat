# Objective

Perform SSRF attack and fetch the environment variables from */proc/self/environ* file.

# Solution

A Server-Side Request Forgery (SSRF) attack involves an attacker abusing server functionality to access or modify resources. 

While creating a new post from the web application, there exists a feature to upload an image from a URL. This input field supports file protocol that allows the user to read the local files from the function app which will lead to an SSRF attack.


### Step 1: Interact with the Web Application.

Open the web application put the login credentials, and start interacting with the web app.

![](https://user-images.githubusercontent.com/65826354/183736905-97acb94c-6d4f-43ee-b39b-afea123dfc13.png)

Successfully logged in to the dashboard.

![](https://user-images.githubusercontent.com/65826354/183736908-b99181cf-1a18-4c4d-8aa0-94745acc353e.png)


### Step 2: From the side navigation menu, select Newpost. Open the developer tools console and click on the upload button.

**Note:** If you are using Firefox, you have to reload the tab by clicking reload button.

In the "Enter URL of image" field, write down the below-mentioned payload.

**Payload:**

```
file:///etc/passwd
```

The /etc/passwd file is a critical file for the Linux operating system. This file stores essential information about the users on the system. Getting this file from the execution environment as a response will confirm the SSRF vulnerability.


First, right-click on the screen, and you will find the option of "inspect elements" click on that and open the "Network" tab. After that, click on the "Upload" button. 

![](https://user-images.githubusercontent.com/65826354/183736934-079d9148-2181-492f-bad0-0007ca8a794d.png)

At the bottom, you will get a notification that "URL File uploaded successfully". After that, open the response and copy the URL.

![](https://user-images.githubusercontent.com/65826354/183736943-a9739de9-4367-4762-bd08-4a17be6591c7.png)

### Step 3: Download the data and try to open it.

To download the data of the */etc/passwd* file, visit the copied URL (from Step 3). One file will get downloaded.

After the successful download of data, you will find that the data is in .png format.

![](https://user-images.githubusercontent.com/65826354/183736953-4c3ef73f-56c2-49a3-8ed8-210aba0d14b8.png)


### Step 4: Open the terminal to display the data.

Open the terminal and run the below-mentioned command to display the content of the */etc/passwd* file.

**Command:**

```bash
cat <File_Name>
```
Here we have the file name as `20220713101033144525.png`. So the command will be the following.

**Command:**

```bash
cat 20220713101033144525.png
```
![](https://user-images.githubusercontent.com/65826354/183736959-54984f43-ec62-4735-aa34-df78ff42459a.png)

### Step 5: Let's try to fetch */proc/self/environ* file.

<!-- 
![](https://user-images.githubusercontent.com/65826354/183736970-75aa3899-7caa-4e66-a435-c68c818356d8.png) -->

Go to the web application, and from the side navigation menu, select "Newpost".

Open the developer tools console and enter the URL of the image as mentioned below.

**Payload:**

```
file:///proc/self/environ
```

The file located under /proc/self/environ contains several environment variables such as function worker runtime, container image URL, and more. These are the environment variables that are attached to this function app to get this web application up and running.

Click on the upload button. At the bottom, you will get a notification that "URL File uploaded successfully". After that, open the response and copy the URL.



![](https://user-images.githubusercontent.com/65826354/183736980-abd1b03d-a100-440b-835b-b54bb41f79aa.png)

To download the data of the *proc/self/environ/* file, visit the copied URL (copied above). One file will get downloaded. After the successful download of data, you will find that the data is in .png format.

![](https://user-images.githubusercontent.com/65826354/183736988-e44f051c-3738-4333-a1fe-4bbc63ce17cf.png)

Open the terminal and run the below-mentioned command to display the content of the *proc/self/environ* file.

**Command:**

```bash
cat <File_Name>
```
Here we have the file name as `20220713112623309267.png`. So the command will be the following.

**Command:**

```bash
cat 20220713112623309267.png
```

![](https://user-images.githubusercontent.com/65826354/183736998-4b64976d-dc81-4c26-95c4-348ef5bd64e2.png)


***Congrats! We successfully performed the SSRF attack and fetched the data of the proc/self/environ file.***
