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
          if (env.BRANCH_NAME == 'prod') {
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
          } else {sh "echo 'This is ${env.BRANCH_NAME} branch'"}
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
        DOCKER_TAG = "${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
      }
      steps {
        script {
          if (env.BRANCH_NAME == 'dev') {
            dir ('branches/dev/') {
              // sh "cd branches/dev/"
              sh '''
                docker build -t ${DOCKER_IMAGE_DEV}:${DOCKER_TAG} . 
                docker tag ${DOCKER_IMAGE_DEV}:${DOCKER_TAG} ${DOCKER_IMAGE_DEV}:latest
                docker images | grep ${DOCKER_IMAGE_DEV}
              '''

              withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh "echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin"
                sh "docker push ${DOCKER_IMAGE_DEV}:${DOCKER_TAG}"
                sh "docker push ${DOCKER_IMAGE_DEV}:latest"
              }

              //clean to save disk
              sh "docker image rm ${DOCKER_IMAGE_DEV}:${DOCKER_TAG}"
              sh "docker image rm ${DOCKER_IMAGE_DEV}:latest"
              // sh "cd ../../"
            }
          } else {sh "echo 'This is ${env.BRANCH_NAME} branch'"}
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
          if (env.BRANCH_NAME == 'dev') {
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
          } else {sh "echo 'This is ${env.BRANCH_NAME} branch'"}
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
        DOCKER_TAG = "${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
      }
      steps {
        script {
          if (env.BRANCH_NAME == 'master') {
            dir ('branches/master/') {
              // sh "cd branches/master/"
              sh '''
                docker build -t ${DOCKER_IMAGE_MASTER}:${DOCKER_TAG} . 
                docker tag ${DOCKER_IMAGE_MASTER}:${DOCKER_TAG} ${DOCKER_IMAGE_MASTER}:latest
                docker images | grep ${DOCKER_IMAGE_MASTER}
              '''

              withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh "echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin"
                sh "docker push ${DOCKER_IMAGE_MASTER}:${DOCKER_TAG}"
                sh "docker push ${DOCKER_IMAGE_MASTER}:latest"
              }

              //clean to save disk
              sh "docker image rm ${DOCKER_IMAGE_MASTER}:${DOCKER_TAG}"
              sh "docker image rm ${DOCKER_IMAGE_MASTER}:latest"
              // sh "cd ../../"
            }
          } else {sh "echo 'This is ${env.BRANCH_NAME} branch'"}
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
          if (env.BRANCH_NAME == 'master') {
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
          } else {sh "echo 'This is ${env.BRANCH_NAME} branch'"}
        }
      }
    }

    stage ("SSH to Prod Node") {
      options {
        timeout(time: 5, unit: 'MINUTES')
      }
      steps {
        script {
          if (env.BRANCH_NAME == 'prod') {
            sshagent (credentials: ['private-key']) {
              sh "ssh -o StrictHostKeyChecking=no -l ubuntu 3.86.162.104 'touch test-ssh'"
              sh "ssh -o StrictHostKeyChecking=no -l ubuntu 3.86.162.104 'echo abcd >> test-ssh'"
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
