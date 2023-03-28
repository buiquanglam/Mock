1 - Install Server Jenkins + Docker
2 - Setup AWS credentials on Jenkins
3 - Create 2 Job (create image + infra deployment)

Create image job 1

- Github
- Build agent Docker container
- Terraform infra (temp) on AWS
- Packer + Ansible create instance on infra (temp)
- Build image
- Remove infra (temp)

Create image job 2

- Terraform create EC2 from image job 1 (filter name)
- Ansible config EC2
- Result 3 server (web, app, bastion)
