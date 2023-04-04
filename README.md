# Demo Terraform-Git-Jenkins-Ansible Pipeline
*khoamd*  

===  

## 1. Lab workflows:
![This is an image about lab workflow](./pictures/demo-1st-jenkins.png)  

<!-- <img src="./pictures/demo-1st-jenkins.png" width=600 height=312>   -->

===  

## 2. Prepare local environment:
### *(I'm running this project on Windows 10 / 64-bit os)*
- Install terraform library by downloading package from this link below:  
https://developer.hashicorp.com/terraform/downloads

	* *Extract the zip file depending on you windows operation*
	* *Open Properties from "This PC" directory => choose "Advanced system settings" => click on "Environment Variables…"*
  * *Once dialog box opened, add the folder directory leading to that extract terraform binary file to User variable and System variable of PATH ==> Apply ==> OK*

- Install git from this link below and perform configuration for git in local (including running **`"git init"`** command inside code directory):  
https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

- Create a public GitHub repsitory and push the *`server_config.sh`* to that. Then copy this repository link and replace it to the link that's been declared by default *`config_file_link`* variable in file *`./modules/ec2_server/variables.tf`* just like the picture below:  
<img src="./pictures/config-file-link.jpg" width=643 height=129>

- Already have AWS acount with access_key and secret_key

- Open Poweshell in Administrator privilege => run this command below:
```ps
set-executionpolicy remotesigned
```
or
```ps
Set-ExecutionPolicy Bypass
Set-ExecutionPolicy unrestricted
```
or
```ps
powershell "Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force"
powershell "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force"
powershell "Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force"
```  

===  

## 3. Run pipeline in the 1st time:
### *This will need you open Powershell*
- Change directory > **`"cd"`** to folder containing this **README.md** file

- Run command on Powershell with Administrator privilege:
```ps
./cicd.ps1
```

- Type **`"apply apply"`** to Powershell => press ***Enter***  
  * *`apply` mode will creat all Terraform resoures on AWS cloud. It's similar to run `terraform init` & `terraform plan --out tfplan` & `terraform apply tfplan` at once.*  
  * *Typing `apply` twice because we want to run triggers timestamp in null-resource that would be connected to Jenkins server. This can be done to configure changing usermode of Jenkins as privilege one each time we run Docker command with it.*

- Create GitHub repository

- Config Jenkins server in AWS to connect to other platforms such as GitHub (github-webhook...) or Docker...

- Run command on Powershell with Administrator privilege:
```ps
./cicd.ps1
```

- Type **`"gitpush"`** to Powershell => press ***Enter***  
*This mode will execute Add and Commit and Push all source code to GitHub repository.*  

> ***NOTE:***  

> If your Jenkins does not trigger GitHub for an automation to run it's job, press *`"Build Now"`* for the first running time. Then run command **`"./cicd.ps1"`** in your Powershell and fill again **`"gitpush"`** action to check if Jenkins trigger webhook to GitHub happened.  

===  

## 4. Run pipeline to refresh resources status after restarting or rebooting AWS Servers (then update code, etc):
### *This will need you open Powershell*
- Replace Jenkins server public IP to the older in Jenkins Dashboard url. Delete older github-webhook and add a new one

- Change directory > **`"cd"`** to folder containing this **README.md** file

- Run command on Powershell with Administrator privilege:
```ps
./cicd.ps1
```

- Type **`"refresh apply gitpush"`** to Powershell => press ***Enter***  
*`refresh` mode will run as command `terraform plan -refresh-only`*  

> ***NOTE:***  

> **DO NOT RUN `apply` MODE OF THE `cicd.ps1` FILE WHILE SERVERS ARE IN `Stopped` STATE**  
> **IT'LL LEAD TO SERVERS TERMINATED ACTION**  
> **AND YOU'LL REGRET FOR THAT**  

===  

## 5. Run pipeline to refresh resources status without restarting or rebooting AWS Servers and update code, etc:
### *This will need you open Powershell*
- Change directory > **`"cd"`** to folder containing this **README.md** file

- Run command on Powershell with Administrator privilege:
```ps
./cicd.ps1
```

- Type **`"refresh apply gitpush"`** to Powershell => press ***Enter***  
*(You may need to update `version` file to new version first)*  

===  

## 6. To destroy all Terraform resources:
### *This will need you open Powershell*
- Change directory > **`"cd"`** to folder containing this **README.md** file

- Run command on Powershell with Administrator privilege:
```ps
./cicd.ps1
```

- Type **`"destroy"`** to Powershell => press ***Enter***  
*`destroy` mode will destroy every terraform resources you have built to AWS.*  

===  

## 7. You can also mix these actions `apply`, `refresh`, `destroy`, `gitpush` of the `cicd.ps1` file:
### *This will need you open Powershell*
- Change directory > **`"cd"`** to folder containing this **README.md** file

- Run command on Powershell with Administrator privilege:
```ps
./cicd.ps1
```

- Type `"apply destroy"`, `"destroy apply apply"`, `"refresh destroy"`, `"apply gitpush destroy"`... or whatever you think to Powershell => Press ***Enter***, then check the output.  

> * *You may custom the `cicd.ps1` as it's open Powershell source code file to find out your own pipeline.*  
> * *Or you can write the `config.py` to run configurations on web browser automatically.*  
> * *May you feel exciter to write another `linux-ssh-config.tpl` file to execute some Linux commands if you want to challenge running Terraform with Jenkins, etc.*  
