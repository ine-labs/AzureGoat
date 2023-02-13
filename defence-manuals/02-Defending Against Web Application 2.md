# Mitigating Server-Side Request Forgery Attack (SSRF) using Application Gateway

Server-Side Request Forgery (SSRF) is a type of cyber attack in which an attacker tricks a server into requesting a different server or resource on behalf of the attacker. This can be used to gain unauthorized access to internal systems, steal sensitive information, or launch other attacks.

The attack is typically carried out by injecting a malicious URL or another request into a vulnerable application, which then sends the request to the targeted server or resource. The attacker can use this technique to bypass firewalls and other security measures that are in place to protect internal systems and resources.

Azure Application Gateway is a web traffic load balancer and application delivery controller service provided by Microsoft through its Azure platform. It enables users to manage and scale their web applications by distributing incoming web traffic across multiple servers and resources.
Application Gateway provides several features, such as Load balancing: and distributing incoming web traffic across multiple servers based on various algorithms. SSL/TLS termination: offloads SSL/TLS encryption and decryption from the backend servers. Web Application Firewall (WAF): protects against common web-based attacks such as SSRF, SQL injection and cross-site scripting (XSS).

It can be used for various purposes, such as: Scaling web applications to handle large amounts of traffic. Offloading SSL/TLS encryption and decryption from the backend servers. Providing a layer of protection against common web-based attacks, etc.

# Solutions

**Step 1:** Navigate to the registration page where the User can create a new account.

![](images/2_defending_against_web_application_ii/2.png)

**Step 2:** Fill in the details and click the "Register" button.

![](images/2_defending_against_web_application_ii/3.png)

**Step 3:** Now log in using the new credentials.

![](images/2_defending_against_web_application_ii/4.png)

**Step 4:** Click on the Newpost tab from the navigation tab.

![](images/2_defending_against_web_application_ii/5.png)

**Step 5:** Open the inspect element and enter the below-given payload.
```
file:///etc/passwd
```

![](images/2_defending_against_web_application_ii/6.png)

**Step 6:** Click on Upload, and you will see a response; click it as shown in the image.

![](images/2_defending_against_web_application_ii/7.png)

Copy the URL from the Response tab.

![](images/2_defending_against_web_application_ii/8.png)

Open the copied URL, and you will get a downloadable png file. Download the png file.

![](images/2_defending_against_web_application_ii/9.png)

Now open the png file using the text editor.

![](images/2_defending_against_web_application_ii/10.png)

We can read the passwd file. So, this web app is vulnerable to SSRF attack.

**Step 7:** Let's prevent the SSRF attack. Open the portal and click on Create, as shown in the image.

![](images/2_defending_against_web_application_ii/11.png)

**Step 8:** Search for application gateway.

![](images/2_defending_against_web_application_ii/12.png)

Click on Create.

![](images/2_defending_against_web_application_ii/13.png)

**Step 9:** Enter the following and click on *create new* to create a virtual network as shown in the image.

![](images/2_defending_against_web_application_ii/14.png)

**Step 10:** Create the virtual network.

![](images/2_defending_against_web_application_ii/15.png)

Once everything is done as shown in the image, go to *Frontend*.

![](images/2_defending_against_web_application_ii/16.png)

**Step 11:** Frontend Ip type: *Public* and *add new* Public IP address as shown in image.

![](images/2_defending_against_web_application_ii/17.png)

Once everything is done as shown in the image, click on *Backend*.

![](images/2_defending_against_web_application_ii/18.png)

**Step 12** Click on Add *backend pool*.

![](images/2_defending_against_web_application_ii/19.png)

Choose Target Type: *App Services*

Target: xxxxxx-function

And click on Add.

![](images/2_defending_against_web_application_ii/20.png)

Next, click on Configuration.

![](images/2_defending_against_web_application_ii/21.png)

**Step 13:** Add a routing rule.

![](images/2_defending_against_web_application_ii/22.png)

Fill in the following as shown in the image.

![](images/2_defending_against_web_application_ii/23.png)

**Step 14:** Protocol: *HTTPS*, upload the certificate and click on Backend target.

**Note:** If you don't have a certificate, you can create a self-signed certificate; to do that, go to the *Appendix section* at the bottom.

![](images/2_defending_against_web_application_ii/24.png)

In the backend targets, click on *Add new*

![](images/2_defending_against_web_application_ii/25.png)

Give it a name, Override backend path: */*, choose *Yes* for Override with hostname and click on pick hostname from backend target.
And click on Add button as shown in the image.

![](images/2_defending_against_web_application_ii/26.png)

Again click on Add.

![](images/2_defending_against_web_application_ii/27.png)

**Step 15:** Now, goto *Review+Create*.

![](images/2_defending_against_web_application_ii/28.png)

Click on *Create*.

![](images/2_defending_against_web_application_ii/29.png)

The creation takes approx 20minutes-25minutes.

![](images/2_defending_against_web_application_ii/30.png)

Once the resource is deployed then, click on *Go to Resource Group*.

![](images/2_defending_against_web_application_ii/31.png)

**Step 16:** Open created gateway resource.

![](images/2_defending_against_web_application_ii/32.png)

Copy the IP address.

![](images/2_defending_against_web_application_ii/33.1.png)

Open the text editor and paste it. Separate them and add *https://* in the front and / at the back to the both IP address and DNS name, as shown in the image.

![](images/2_defending_against_web_application_ii/33.2.png)

**Step 17:** Copy the DNS URL

![](images/2_defending_against_web_application_ii/33.6.png)

Open DNS name URL in the Browser and click on Continue, as shown in the image.

**Note:** The connection is not secured because the certificate is self-signed and not recognized by Microsoft.

![](images/2_defending_against_web_application_ii/33.7.png)

Now you will get the following as shown in the image.

![](images/2_defending_against_web_application_ii/33.8.png)

**Step 18:** Click on Web application firewall and click on Rules
![](images/2_defending_against_web_application_ii/33.png)

Click on *Enabled* for Advanced rule configuration. The Gateway will block all the enabled rules.

![](images/2_defending_against_web_application_ii/34.png)

Search for the header, disable them and Click on Save, as shown in the image.

![](images/2_defending_against_web_application_ii/35.png)

It takes 5-7 minutes to update the settings.

![](images/2_defending_against_web_application_ii/36.png)

![](images/2_defending_against_web_application_ii/37.png)

**Note:** If we don't disable the header rules, we cannot input https-related urls in our web application. We are inputting the image URL in our web application.

**Step 19:** Go to the Storage account and click on the prod-appxxxxxx container.

![](images/2_defending_against_web_application_ii/38.png)

**Step 20:** Follow the path to open the .js file as shown in the image.

![](images/2_defending_against_web_application_ii/39.png)

**Step 21:** Download the file.

![](images/2_defending_against_web_application_ii/40.png)

**Step 22:** Now open the function app: *appazgoatxxxxxxx-function*.

![](images/2_defending_against_web_application_ii/41.png)

Copy the URL.

![](images/2_defending_against_web_application_ii/42.png)

**Step 23:** Open the downloaded file and search for the copied URL.

![](images/2_defending_against_web_application_ii/43.png)

Remove the copied URL and paste the DNS URL in place of it. You can refer to *Step 17*.

![](images/2_defending_against_web_application_ii/44.png)

Save the file.

**Step 24:** We will update the .js file with the edited .js file. Click on Override and upload.

![](images/2_defending_against_web_application_ii/45.1.png)

**Step 25:** Back to our Web app and refresh the page.

![](images/2_defending_against_web_application_ii/45.png)

**Step 26:** Enter the payload as shown in the image.
```
file:///etc/passwd
```

![](images/2_defending_against_web_application_ii/46.png)

**Step 27:** Click on *Upload* button. And now you will see both responses are errors.

![](images/2_defending_against_web_application_ii/47.png)

Double-click on the first response.

![](images/2_defending_against_web_application_ii/48.png)

You will see an Access denied error.

![](images/2_defending_against_web_application_ii/49.png)

mitigated the ssrf attack using application gateway.

## Appendix

**Step 1:** If you have windows server 2016, you may skip till Step 6. Open the marketplace and search for a Virtual machine.

![](images/2_defending_against_web_application_ii/50.png)

**Step 2:** Fill the following:

Image: *Windows Server 2016*,

Choose your Username and Password,

Click on *Review+Create*.

![](images/2_defending_against_web_application_ii/51.png)

**Step 3:** Click on Create .

![](images/2_defending_against_web_application_ii/52.png)

**Step 4:** Creation takes 3-4 minutes.

![](images/2_defending_against_web_application_ii/53.png)

**Step 5:** Click on Connect and Download the RDF file.

![](images/2_defending_against_web_application_ii/54.png)

**Step 6:** Enter the credentials to log in.

![](images/2_defending_against_web_application_ii/55.png)

**Step 7:** Open the powershell.

![](images/2_defending_against_web_application_ii/56.png)

Execute the following command.
```
New-SelfSignedCertificate `
  -certstorelocation cert:\localmachine\my `
  -dnsname www.contoso.com
```

![](images/2_defending_against_web_application_ii/57.png)

**Step 8:** Copy the Thumbprint.

![](images/2_defending_against_web_application_ii/58.png)

**Step 9:** Paste the Thumbprint in the below given command:
```
$pwd = ConvertTo-SecureString -String "Azure123456!" -Force -AsPlainText
Export-PfxCertificate `
  -cert cert:\localMachine\my\PASTE_YOUR_THUMBPRINT `
  -FilePath c:\appgwcert.pfx `
  -Password $pwd
```

![](images/2_defending_against_web_application_ii/59.png)

Run the command.

![](images/2_defending_against_web_application_ii/60.png)

And you will see the following output.

![](images/2_defending_against_web_application_ii/61.1.png)

The .pfx certificate is found in C:\ drive

![](images/2_defending_against_web_application_ii/61.png)
