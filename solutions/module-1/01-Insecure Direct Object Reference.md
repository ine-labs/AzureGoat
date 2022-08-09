# Objective

Leverage the insecure direct object reference vulnerability to access another user's account and change its password.

# Solution

### Open the web application, click on "Get Started" and create a new account.

![](https://user-images.githubusercontent.com/65826354/183736614-788630c2-4a4e-4f11-b1fc-6429a0b807e4.png)

Fill in the details and create a new account.

![](https://user-images.githubusercontent.com/65826354/183736625-3c1f0f69-4d0a-4da9-885a-be7168ee7dfa.png)

![](https://user-images.githubusercontent.com/65826354/183736630-56788231-0810-45e7-a0de-3f22e75d7bac.png)

Now, click on the "Register" and log in using the new credentials.

![](https://user-images.githubusercontent.com/65826354/183736635-7c33ec2d-094e-4b72-9155-3186108b5021.png)

![](https://user-images.githubusercontent.com/65826354/183736639-ce32b4f1-c2be-4009-bc0e-3899b0eaa34c.png)

Now, you got access to the web application.

### Visit the "Profile" section of the web application, click on "Change Password" and observe the response.

After clicking on the "Change Password", right-click on the screen, open inspect elements and observe the response header.

![](https://user-images.githubusercontent.com/65826354/183736649-bcaded1b-d533-4b4c-ab3f-4746ba8f14a6.png)

### Now, Open the burp suite and configure it with the browser.

![](https://user-images.githubusercontent.com/65826354/183736711-5cc1b6ed-7352-4218-98fe-be86d1553283.png)

Click on "Open browser" and turn off the intercept.

![](https://user-images.githubusercontent.com/65826354/183736722-131c2c79-8772-4a92-ac0e-72aa4e089bf1.png)

### Using the browser (configured with burp suite) visit the app URL and login again.

![](https://user-images.githubusercontent.com/65826354/183736734-019b58e9-b192-41be-b2cc-71a2ff202d24.png)

After accessing the web application, visit the "Profile" section.

![](https://user-images.githubusercontent.com/65826354/183736753-3dabb27a-9529-4ec4-b1f2-41a7956b119e.png)

### Navigate to the Burp suite, turn on the intercept, fill in the "Change Password" fields, and click on the "Change Password" button.

![](https://user-images.githubusercontent.com/65826354/183736766-ae9c1b31-629d-4473-826f-e3b1b2bed8cf.png)

Open the burp suite and forward the captured request.

![](https://user-images.githubusercontent.com/65826354/183736791-7d2040ff-f350-47e4-9bda-d3c88fec8d15.png)

After forwarding the request, you will see some extra parameters in the response, such as "id", "newPassword", "confirmNewPassword".

![](https://user-images.githubusercontent.com/65826354/183736791-7d2040ff-f350-47e4-9bda-d3c88fec8d15.png)

Now, right-click on the screen and send the request to the repeater.

![](https://user-images.githubusercontent.com/65826354/183736802-2b3c90b3-bd4e-4fd0-9b74-c3bd314cd613.png)

### Try changing the "id" parameter to other values.

Replace the id parameter value with "0" and send the request.

![](https://user-images.githubusercontent.com/65826354/183736811-2fab83ea-eed7-42a9-9c1a-734d72b095a8.png)

We got the Internal Server Error. That means no user with an id equal to 0 exists.

Let's try id = 1

Replace the id parameter value with a value equal to 1 and send the request.

![](https://user-images.githubusercontent.com/65826354/183736817-92148556-9b01-40fd-8861-3c93d5ab7f44.png)

Voila! We successfully change the password of the John Doe user, who is having id equal to 1.

### Copy the email id of John Doe and try to log in to the web application using the newly changed credentials.

First, log out as a current user, then visit the login page, enter the email id of user "John Doe" and give the password we just changed above.

![](https://user-images.githubusercontent.com/65826354/183736828-8f59e9a3-5569-4962-9ea9-8e4db9388b06.png)

Click on login

![](https://user-images.githubusercontent.com/65826354/183736838-17b40b0c-d32f-4731-be83-19e88e3824e7.png)

**Bingo! We successfully changed the password and logged in as a "John Doe" user.**
