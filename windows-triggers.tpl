// write down hosts file for branch dev
add-content -path .\branches\dev\hosts -value @'
[server]
server ansible_host=${hostnameServer} ansible_connection=ssh ansible_port=22 ansible_user=ubuntu ansible_python_interpreter='/usr/bin/${env} python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[dev]
dev ansible_host=${hostnameDev} ansible_connection=ssh ansible_port=22 ansible_user=ubuntu ansible_python_interpreter='/usr/bin/${env} python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[allserver:children]
server
dev
'@

// write down hosts file for branch prod
add-content -path .\branches\prod\hosts -value @'
[server]
server ansible_host=${hostnameServer} ansible_connection=ssh ansible_port=22 ansible_user=ubuntu ansible_python_interpreter='/usr/bin/${env} python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[prod]
prod ansible_host=${hostnameProd} ansible_connection=ssh ansible_port=22 ansible_user=ubuntu ansible_python_interpreter='/usr/bin/${env} python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[allserver:children]
server
prod
'@

// write down hosts file for branch prod
add-content -path .\branches\master\hosts -value @'
[server]
server ansible_host=${hostnameServer} ansible_connection=ssh ansible_port=22 ansible_user=ubuntu ansible_python_interpreter='/usr/bin/${env} python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

[master]
master ansible_host=${hostnameMaster} ansible_connection=ssh ansible_port=22 ansible_user=ubuntu ansible_python_interpreter='/usr/bin/${env} python3' ansible_ssh_extra_args='-o StrictHostKeyChecking=no' become_method=sudo

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

// write down hostnameProd for Jenkinsfile
add-content -path .\Jenkinsfile -value @'
pipeline {
  agent {
      label 'master'
  }
  // environment{
  //   DOCKER_IMAGE = "mnikhoa/nginx"
  // }
  stages {
    stage ("Deploy-prod") {
      when {
        branch 'prod'
      }
      options {
        timeout(time: 5, unit: 'MINUTES')
      }
      // input {
      //   message "Have you done your review yet?"
      // }
      steps {
        script {
          if (${env_BRANCH_NAME_PLAIN} == 'prod') {
            dir ('branches/prod/') {
              withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                ansiblePlaybook(
                  credentialsId: 'private-key',
                  playbook: 'playbook.yml',
                  inventory: 'hosts',
                  become: 'yes',
                  extraVars: [
                    DOCKER_USERNAME: "${DOCKER_USERNAME}",
                    DOCKER_PASSWORD: "${DOCKER_PASSWORD}"
                  ]
                )
              }
            }
          } else {sh "echo 'This is ${env_BRANCH_NAME} branch'"}
        }
      }
    }

    stage ("Build-dev") {
      when {
        branch 'dev'
      }
      options {
        timeout(time: 5, unit: 'MINUTES')
      }
      environment {
        DOCKER_IMAGE_DEV = "mnikhoa/nginx-dev"
        DOCKER_TAG = "${GIT_BRANCH}-${GIT_COMMIT}"
      }
      steps {
        script {
          if (${env_BRANCH_NAME_PLAIN} == 'dev') {
            dir ('branches/dev/') {
              // sh "cd branches/dev/"
              sh '''
                docker build -t ${DOCKER_IMAGE_DEV}:${DOCKER_TAG} . 
                docker tag ${DOCKER_IMAGE_DEV}:${DOCKER_TAG} ${DOCKER_IMAGE_DEV}:latest
                docker images | grep ${DOCKER_IMAGE_DEV}
              '''

              withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh "echo ${DOCKER_PASSWORD_PLAIN} | docker login --username ${DOCKER_USERNAME_PLAIN} --password-stdin"
                sh "docker push ${DOCKER_IMAGE_DEV}:${DOCKER_TAG}"
                sh "docker push ${DOCKER_IMAGE_DEV}:latest"
              }

              //clean to save disk
              sh "docker image rm ${DOCKER_IMAGE_DEV}:${DOCKER_TAG}"
              sh "docker image rm ${DOCKER_IMAGE_DEV}:latest"
              // sh "cd ../../"
            }
          } else {sh "echo 'This is ${env_BRANCH_NAME} branch'"}
        }
      }
    }

    stage ("Deploy-dev") {
      when {
        branch 'dev'
      }
      options {
        timeout(time: 5, unit: 'MINUTES')
      }
      // input {
      //   message "Have you done your review yet?"
      // }
      steps {
        script {
          if (${env_BRANCH_NAME_PLAIN} == 'dev') {
            dir ('branches/dev/') {
              withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                ansiblePlaybook(
                  credentialsId: 'private-key',
                  playbook: 'playbook.yml',
                  inventory: 'hosts',
                  become: 'yes',
                  extraVars: [
                    DOCKER_USERNAME: "${DOCKER_USERNAME}",
                    DOCKER_PASSWORD: "${DOCKER_PASSWORD}"
                  ]
                )
              }
            }
          } else {sh "echo 'This is ${env_BRANCH_NAME} branch'"}
        }
      }
    }

    stage ("Build-master") {
      when {
        branch 'master'
      }
      options {
        timeout(time: 5, unit: 'MINUTES')
      }
      environment {
        DOCKER_IMAGE_MASTER = "mnikhoa/nginx-master"
        DOCKER_TAG = "${GIT_BRANCH}-${GIT_COMMIT}"
      }
      steps {
        script {
          if (${env_BRANCH_NAME_PLAIN} == 'master') {
            dir ('branches/master/') {
              // sh "cd branches/master/"
              sh '''
                docker build -t ${DOCKER_IMAGE_MASTER}:${DOCKER_TAG} . 
                docker tag ${DOCKER_IMAGE_MASTER}:${DOCKER_TAG} ${DOCKER_IMAGE_MASTER}:latest
                docker images | grep ${DOCKER_IMAGE_MASTER}
              '''

              withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh "echo ${DOCKER_PASSWORD_PLAIN} | docker login --username ${DOCKER_USERNAME_PLAIN} --password-stdin"
                sh "docker push ${DOCKER_IMAGE_MASTER}:${DOCKER_TAG}"
                sh "docker push ${DOCKER_IMAGE_MASTER}:latest"
              }

              //clean to save disk
              sh "docker image rm ${DOCKER_IMAGE_MASTER}:${DOCKER_TAG}"
              sh "docker image rm ${DOCKER_IMAGE_MASTER}:latest"
              // sh "cd ../../"
            }
          } else {sh "echo 'This is ${env_BRANCH_NAME} branch'"}
        }
      }
    }

    stage ("Deploy-master") {
      when {
        branch 'master'
      }
      options {
        timeout(time: 5, unit: 'MINUTES')
      }
      // input {
      //   message "Have you done your review yet?"
      // }
      steps {
        script {
          if (${env_BRANCH_NAME_PLAIN} == 'master') {
            dir ('branches/master/') {
              withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                ansiblePlaybook(
                  credentialsId: 'private-key',
                  playbook: 'playbook.yml',
                  inventory: 'hosts',
                  become: 'yes',
                  extraVars: [
                    DOCKER_USERNAME: "${DOCKER_USERNAME}",
                    DOCKER_PASSWORD: "${DOCKER_PASSWORD}"
                  ]
                )
              }
            }
          } else {sh "echo 'This is ${env_BRANCH_NAME} branch'"}
        }
      }
    }

    stage ("SSH to Prod Node") {
      options {
        timeout(time: 5, unit: 'MINUTES')
      }
      steps {
        script {
          if (${env_BRANCH_NAME_PLAIN} == 'prod') {
            sshagent (credentials: ['private-key']) {
              sh "ssh -o StrictHostKeyChecking=no -l ubuntu ${hostnameProd} 'touch test-ssh'"
              sh "ssh -o StrictHostKeyChecking=no -l ubuntu ${hostnameProd} 'echo abcd >> test-ssh'"
            }
          } else {sh "echo 'Nothing will be happening here'"}
        }
      }
    }
  }
  post {
    success {
      echo "SUCCESSFULL"
    }
    failure {
      echo "FAILED"
    }
  }
}
'@
