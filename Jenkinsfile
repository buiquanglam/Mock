pipeline {
	agent any 
	stages {
        stage('SCM') {
            steps {
            	git branch: 'main', url: 'https://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@github.com/thanh-vt/python-redis-web.git'
            }
        }
        stage('Scan Sonar') {
            environment {
                scannerHome = tool name: 'thanhvt27-sonarqube-scanner'
            }
            steps {
                withSonarQubeEnv('thanhvt27-sonarqube') {
            	    sh '${scannerHome}/bin/sonar-scanner'
                }
            }
        }
        stage('Quality Gate') {
            steps {
                retry(5) {
                    timeout(time: 10, unit: 'SECONDS') {
                        waitForQualityGate abortPipeline: true
                    }
                }
        	}
        }
        stage('Await Approval') {
            steps {
                mail to: "pysga1996@gmail.com", subject: "APPROVAL REQUIRED FOR $JOB_NAME" , body: """Build $BUILD_NUMBER required an approval. Go to ${BUILD_URL}input/ for more info."""
                input 'Do you want to process deploy?'
            }
        }
        stage('Docker Build') {
            steps {
            	sh 'docker build -t python-redis-web .'
            	sh 'docker tag python-redis-web pysga1996/python-redis-web'
            	sh 'docker push pysga1996/python-redis-web'
        	}
        }
        stage('Ansible Deploy') {
			steps {
				withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
					ansiblePlaybook(
						credentialsId: 'server-app', 
						inventory: 'inventory', 
						playbook: 'playbook.yml',
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
	post{
        success {
            echo 'Project build successfully!'
        }
        failure {
            echo 'Project build failed!'
        }
  }  
}