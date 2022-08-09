# Objective

Perform SSRF attack and fetch the environment variables from */proc/self/environ* file.

# Solution

### Step 1: Interact with the Web Application.

Open the web application put the login credentials, and start interacting with the web app.

![](https://user-images.githubusercontent.com/65826354/183736905-97acb94c-6d4f-43ee-b39b-afea123dfc13.png)

![](https://user-images.githubusercontent.com/65826354/183736908-b99181cf-1a18-4c4d-8aa0-94745acc353e.png)

### Step 2: From the side navigation menu, select Newpost

![](https://user-images.githubusercontent.com/65826354/183736922-58d59a85-89c7-4e14-9921-06276101466c.png)

Enter any demo headline for the post like, "Sample post check for SSRF" and also fill in the Author Name.

In the "Enter URL of image" field, write down the below-mentioned payload.

Payload:

```
file:///etc/passwd/
```

![](https://user-images.githubusercontent.com/65826354/183736928-4228e040-4d22-4004-81c4-50b6c1b4dd9b.png)

### Step 3: Go to inspect elements and click on the upload button.

First, right-click on the screen, and you will find the option of "inspect elements" click on that and open the "Network" tab. After that, click on the "Upload" button. 

![](https://user-images.githubusercontent.com/65826354/183736934-079d9148-2181-492f-bad0-0007ca8a794d.png)

At the bottom, you will get a notification that "URL File uploaded successfully". After that, open the response and copy the URL.

![](https://user-images.githubusercontent.com/65826354/183736943-a9739de9-4367-4762-bd08-4a17be6591c7.png)

### Step 4: Download the data and try to open it.

To download the data of the */etc/passwd/* file, visit the copied URL (from Step 3). One file will get downloaded.

After the successful download of data, you will find that the data is in .png format.

![](https://user-images.githubusercontent.com/65826354/183736953-4c3ef73f-56c2-49a3-8ed8-210aba0d14b8.png)


### Step 5: Open the terminal to display the data.

Open the terminal and run the below-mentioned command to display the content of the */etc/passwd/* file.

Command:

```bash
cat <File_Name>

```
eg. 

```bash
cat 20220713101033144525.png

```
![](https://user-images.githubusercontent.com/65826354/183736959-54984f43-ec62-4735-aa34-df78ff42459a.png)

### Step 6: Let's try to fetch */proc/self/environ/* file.

Go to the web application, and from the side navigation menu, select "Newpost". Enter any demo headline for the post like, "Sample post check for SSRF". Also, fill in the Author's Name.

In the "Enter URL of image" field, write down the below-mentioned payload.

Payload:

```
file:///proc/self/environ/
```

![](https://user-images.githubusercontent.com/65826354/183736970-75aa3899-7caa-4e66-a435-c68c818356d8.png)

Go to inspect elements and click on the upload button. At the bottom, you will get a notification that "URL File uploaded successfully". After that, open the response and copy the URL.

![](https://user-images.githubusercontent.com/65826354/183736980-abd1b03d-a100-440b-835b-b54bb41f79aa.png)

To download the data of the *proc/self/environ/* file, visit the copied URL (copied above). One file will get downloaded. After the successful download of data, you will find that the data is in .png format.

![](https://user-images.githubusercontent.com/65826354/183736988-e44f051c-3738-4333-a1fe-4bbc63ce17cf.png)

Open the terminal and run the below-mentioned command to display the content of the *proc/self/environ/* file.

```bash
cat <File_Name>

```
eg. 

```bash
cat 20220713112623309267.png

```

![](https://user-images.githubusercontent.com/65826354/183736998-4b64976d-dc81-4c26-95c4-348ef5bd64e2.png)


***Congrats! We successfully performed the SSRF attack and fetched the data of the proc/self/environ/ file.***
