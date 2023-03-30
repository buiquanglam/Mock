# Mock
Jenkins:
Ansible: on Managed Node
	Use dynamic inventory concepts of Ansible to retrieve the IP Address of the EC2 instance
	3 Roles:
	- Lauching AWS EC2 instances for master and worker node
	- Configuring Kubernetes Master node
	- Configuring Kubernetes Workers node
Docker:
Kubernetes:

////////////////////////////////////////////////////////////////////////
Requirements

Option1: Build K8s cluster on EC2 instance by Ansible (with Ansible role)
Option2: 
	Deploy strategy
	Hashicorp Vault
	Option: Manifest
