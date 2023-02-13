# Defending SQL Injection Attacks with Azure Web Application Firewall (WAF)
SQL injection is a technique used to exploit user data through web page inputs by injecting SQL commands as statements. These statements can be used to manipulate the application's web server by malicious users.

Azure Web Application Firewall (WAF) on Azure Front Door provides centralized protection of your web applications from common exploits and vulnerabilities. Web applications are increasingly targeted by malicious attacks that exploit commonly known vulnerabilities. SQL injection and cross-site scripting are among the most common attacks.

Preventing such attacks in application code is challenging. It can require rigorous maintenance, patching, and monitoring at multiple layers of the application topology. A centralized web application firewall helps make security management much more straightforward. A WAF also gives application administrators better assurance of protection against threats and intrusions.

WAF on Front Door is a global and centralized solution. It's deployed on Azure network edge locations around the globe. WAF-enabled web applications inspect every incoming request delivered by Front Door at the network edge. All of the WAF features exist inside of a WAF policy. You can create multiple policies, and they can be associated with an Azure Front Door.

WAF prevents malicious attacks before they enter your server. You get global protection at scale without sacrificing performance. A WAF policy easily links to any Front Door profile in your subscription. New rules can be deployed within minutes, so you can respond quickly to changing threat patterns.

# Solutions

**Step 1:** Navigate to the registration page where the User can create a new account.

![](images/1_defending_against_web_application_i/0.0.png)

**Step 2:** Fill in the details and click the "Register" button.

![](images/1_defending_against_web_application_i/0.1.png)

**Step 3:** Now log in using the new credentials.

![](images/1_defending_against_web_application_i/0.2.png)

**Step 4:** Click on the User's tab from the navigation tab.

![](images/1_defending_against_web_application_i/1.png)

**Step 5:** Search for a user as shown below:

![](images/1_defending_against_web_application_i/2.png)

**Step 6:** Search the newly created user name.

![](images/1_defending_against_web_application_i/3.png)

Well, it is working correctly.

**Step 7:** Type hello(any random text) and check for results.

![](images/1_defending_against_web_application_i/4.png)

No, results were found.

**Step 8:** Now, give SQL injection as shown below:
```
hello' or '1'='1
```

![](images/1_defending_against_web_application_i/5.png)

It lists all the user names. It is vulnerable to SQL injection.

**Step 9:** Refresh the page. Open the inspection element and go to the *Network* tab.

![](images/1_defending_against_web_application_i/6.png)

**Step 10:** Give the SQL injection once again.

![](images/1_defending_against_web_application_i/7.png)

**Step 11:** Select the *search-author*.

![](images/1_defending_against_web_application_i/8.png)

**Step 12:** Click on *Headers* tab.

![](images/1_defending_against_web_application_i/9.png)

**Step 13:** Note down the *Request URL*. The Request URL is the Backend server URL.

![](images/1_defending_against_web_application_i/10.png)

Now search for the source file.

**Step 14:** We will search for some js files and click on JS tab as shown in the image.

![](images/1_defending_against_web_application_i/11.png)

We have a file below.

![](images/1_defending_against_web_application_i/12.png)

**Step 15:** Select the file and click on *Headers* tab.

![](images/1_defending_against_web_application_i/13.png)

The *main.adc6b28e.js* is in our Storage Account.

![](images/1_defending_against_web_application_i/14.png)

**Step 16:** To view the content inside the *main.adc6b28e.js* file, click on *Sources* tab.

![](images/1_defending_against_web_application_i/15.png)

**Step 17:** Select the Storage Account folder and expand it.

![](images/1_defending_against_web_application_i/16.png)

**Step 18:** Open the *main.adc6b28e.js* file.

![](images/1_defending_against_web_application_i/17.png)

**Step 19:** *CTRL+F* to search the noted down *Request URL*.

![](images/1_defending_against_web_application_i/18.png)

Remove the */search-author* from the end of the URL.

![](images/1_defending_against_web_application_i/19.png)

We found it.

![](images/1_defending_against_web_application_i/20.png)

Before sending the Request to the URL, we need to sanitize the payload. We will use the Web Application Firewall (WAF) tool for Sanitization. To use this tool, we need to create the Front Door URL and associate the Front Door URL with the WAF tool for Sanitization.

Instead of directly calling our Backend server URL, we will call the Front Door URL, and after proper Sanitization, it will send the payload to the Backend server then we will receive the result.

Now, we will create the Front door URL and assign the backend server URL.

**Step 20:** Go to resource group and click on *+ Create*.

![](images/1_defending_against_web_application_i/21.png)

**Step 21:** Search for *Front door and CDN profiles*.

![](images/1_defending_against_web_application_i/22.png)

Click on Create.

![](images/1_defending_against_web_application_i/23.png)

**Step 22:** Choose *Explore other offerings* and then choose *Azure Front Door(Classic)* and click on *Continue* button.

![](images/1_defending_against_web_application_i/24.png)

**Step 23:** Fill the following details and click on *Next: Configration* button.

![](images/1_defending_against_web_application_i/25.png)

**Step 24:** Click on Add button to create *Host name*.

![](images/1_defending_against_web_application_i/26.png)

As shown in the image, a blade is opened on the right of the screen.

![](images/1_defending_against_web_application_i/27.png)

Give a hostname and click on the *Add* button.

Host Name: *inefront*.

![](images/1_defending_against_web_application_i/28.png)

**Step 25:** Now click on *Backend pools*.

![](images/1_defending_against_web_application_i/29.png)

**Step 26:** Fill the following:

*Name:* inebackend

Click on *Add a backend*.

![](images/1_defending_against_web_application_i/30.png)

You will see the following:

![](images/1_defending_against_web_application_i/31.png)

Fill in the following:

Backend host type: *App service*

Backend hostname: *SELECT THE BACKEND URL*

Backend host header: *SELECT THE BACKEND URL*

Click on the *Add* button.

![](images/1_defending_against_web_application_i/32.png)

Again click on the *Add* button.

![](images/1_defending_against_web_application_i/33.png)

**Step 27:** Click on Add button.

![](images/1_defending_against_web_application_i/34.png)

Fill in the following:

*Name:* inerouting

Use */** for the path

And click on the *Add* button.

![](images/1_defending_against_web_application_i/35.png)

**Step 28:** Once, everything done click on **Review + Create** button.

![](images/1_defending_against_web_application_i/36.png)

**Step 29:** Click on *Create* button.

![](images/1_defending_against_web_application_i/37.png)

**Step 30:** You will see the following page on successful deployment. And click on Microsoft Azure to create a WAF resource.

![](images/1_defending_against_web_application_i/38.png)

**Step 31:** Click on *Create a Resource*.

![](images/1_defending_against_web_application_i/39.png)

**Step 32:** Search for the *web applicaiton firewall (waf)*.

![](images/1_defending_against_web_application_i/40.png)

**Step 33:** Click on *Create*.

![](images/1_defending_against_web_application_i/41.png)

**Step 34:** Fill the following:

Policy for: *Global WAF (Front Door)*

Front door tier: *Classic*

Policy name: *azuregoatwaf*

Prevention mode: *Prevention*.

![](images/1_defending_against_web_application_i/42.png)

**Step 35:** Click on *Custom rules*.
![](images/1_defending_against_web_application_i/43.png)

Click on *+ Add custom rule*. Once a rule is matched, the corresponding action defined in the rule is applied to the request. Once such a match is processed, rules with lower priorities are not processed further. A smaller integer value for a rule denotes a higher priority.

![](images/1_defending_against_web_application_i/44.png)

Custom rule name: *blocksql*

Priority: *1*

*Conditions:*

Match type: *String*

Match variable: *RequestBody*

![](images/1_defending_against_web_application_i/45.png)

Operation: *is*

Operator: *contains*

Match values: ' and '1'

Finally, click on the *Add* button.

![](images/1_defending_against_web_application_i/46.png)

**Step 36:** Click on *Association*.

![](images/1_defending_against_web_application_i/47.png)

Click on *+ Add frontend host*.

![](images/1_defending_against_web_application_i/48.png)

Fill in the following:

Frontdoor: *inefront*

Frontend host: *inefront-azurefd-net*

Click on the *Add* button.

![](images/1_defending_against_web_application_i/49.png)

**Step 37:** Click on *Review + Create*.

![](images/1_defending_against_web_application_i/50.png)

**Step 38:** Click on *Create* button.

![](images/1_defending_against_web_application_i/51.png)

**Step 39:** If deployment is finished, click on Resource group as shown below:

![](images/1_defending_against_web_application_i/52.png)

**Step 40:** Open *inefront* resource.

![](images/1_defending_against_web_application_i/53.png)

Copy the frontend host URL.

![](images/1_defending_against_web_application_i/54.png)

**Step 41:** We already know where *main.adc6b28e.js* file is present(refer step 15 and 18). Open the storage account and click on the highlighted container, as shown in the image.

![](images/1_defending_against_web_application_i/55.png)

Now open the *main.adc6b28e.js* using the following path, as shown in the image.

![](images/1_defending_against_web_application_i/56.png)

**Step 42:** We cannot read the file, so click the Download button to download it.

![](images/1_defending_against_web_application_i/57.png)

Please wait until it gets downloaded.

![](images/1_defending_against_web_application_i/58.png)

**Step 43:** Open the .js file in the text editor and remove the Backend server URL.

![](images/1_defending_against_web_application_i/59.png)

**Step 44:** Now, add the *Front door URL* as shown in image.

![](images/1_defending_against_web_application_i/60.png)

**Step 45:** Save the *.js* file, click on the Upload button, click the browse button, and upload the saved *.js* file.

![](images/1_defending_against_web_application_i/61.png)

Click on the *Overwrite* and *Upload* buttons.

![](images/1_defending_against_web_application_i/62.png)

**Step 46:** Open the web application and navigate to the *Users* as shown in image.

**Note:** *Re-login using the Private window, so there wouldn't be any cookie issues*.

![](images/1_defending_against_web_application_i/64.png)

**Step 47:** Check whether working correctly or not. Input a name as shown in the image.

![](images/1_defending_against_web_application_i/65.png)

It is working fine.

**Step 48:** Now input the SQL injection.

![](images/1_defending_against_web_application_i/66.png)

Well, you can see SQL injection is not working on the Web application; we successfully prevented it.