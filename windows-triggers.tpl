// write down hosts file for branch dev
add-content -path .\branches\dev\hosts -value @'
[server]
server ansible_host=${hostnameServer} ansible_connection=ssh ansible_port=22 ansible_python_interpreter='/usr/bin/env python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[dev]
dev ansible_host=${hostnameDev} ansible_connection=ssh ansible_port=22 ansible_python_interpreter='/usr/bin/env python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[allserver:children]
server
dev
'@

// write down hosts file for branch prod
add-content -path .\branches\prod\hosts -value @'
[server]
server ansible_host=${hostnameServer} ansible_connection=ssh ansible_port=22 ansible_python_interpreter='/usr/bin/env python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[prod]
prod ansible_host=${hostnameProd} ansible_connection=ssh ansible_port=22 ansible_python_interpreter='/usr/bin/env python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[allserver:children]
server
prod
'@

// write down hosts file for branch prod
add-content -path .\branches\master\hosts -value @'
[server]
server ansible_host=${hostnameServer} ansible_connection=ssh ansible_port=22 ansible_python_interpreter='/usr/bin/env python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[master]
master ansible_host=${hostnameMaster} ansible_connection=ssh ansible_port=22 ansible_python_interpreter='/usr/bin/env python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[allserver:children]
server
master
'@

// write down hostnameServer for github-webhook
add-content -path .\modules\module-github\variables.tf -value @'
variable "demo_1st_pipeline_webhook" {
  description = "Variable of mnikhoa demo 1st pipeline webhook"
  type        = string
  default     = "http://${hostnameServer}:8080/github-webhook/"
}
'@
