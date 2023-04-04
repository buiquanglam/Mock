pipeline {
  agent any
  environment{
    DOCKER_IMAGE = "mnikhoa/nginx"
  }
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
        DOCKER_TAG = "${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
      }
      steps {
        dir ('branches/dev/') {
          // sh "cd branches/dev/"
          sh '''
            docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} . 
            docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
            docker images | grep ${DOCKER_IMAGE}
          '''

          withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
            sh "echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin"
            sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
            sh "docker push ${DOCKER_IMAGE}:latest"
          }

          //clean to save disk
          sh "docker image rm ${DOCKER_IMAGE}:${DOCKER_TAG}"
          sh "docker image rm ${DOCKER_IMAGE}:latest"
          // sh "cd ../../"
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
      }
    }

    // stage ("Build-master") {
    //   when {
    //     branch 'master'
    //   }
    //   options {
    //     timeout(time: 5, unit: 'MINUTES')
    //   }
    //   environment {
    //     DOCKER_TAG = "${GIT_BRANCH.tokenize('/').pop()}-${GIT_COMMIT.substring(0,7)}"
    //   }
    //   steps {
    //     dir ('branches/master/') {
    //       // sh "cd branches/master/"
    //       sh '''
    //         docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} . 
    //         docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
    //         docker images | grep ${DOCKER_IMAGE}
    //       '''

    //       withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
    //         sh "echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin"
    //         sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
    //         sh "docker push ${DOCKER_IMAGE}:latest"
    //       }

    //       //clean to save disk
    //       sh "docker image rm ${DOCKER_IMAGE}:${DOCKER_TAG}"
    //       sh "docker image rm ${DOCKER_IMAGE}:latest"
    //       // sh "cd ../../"
    //     }
    //   }
    // }

    // stage ("Deploy-master") {
    //   when {
    //     branch 'master'
    //   }
    //   options {
    //     timeout(time: 5, unit: 'MINUTES')
    //   }
    //   // input {
    //   //   message "Have you done your review yet?"
    //   // }
    //   steps {
    //     dir ('branches/master/') {
    //       withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
    //         ansiblePlaybook(
    //           credentialsId: 'private-key',
    //           playbook: 'playbook.yml',
    //           inventory: 'hosts',
    //           become: 'yes',
    //           extraVars: [
    //             DOCKER_USERNAME: "${DOCKER_USERNAME}",
    //             DOCKER_PASSWORD: "${DOCKER_PASSWORD}"
    //           ]
    //         )
    //       }
    //     }
    //   }
    // }
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
