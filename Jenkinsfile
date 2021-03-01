pipeline {
    agent any
    tools {
        maven 'M3'
    }
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr: '10'))
    }

    stages {
        stage ('Checkout') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage ('Build') {
            steps {
                script {
                    bat 'mvn clean install'
                }
            }
        }

        stage ('Unit Test') {
            steps {
                script {
                    bat 'mvn test'
                }
            }
        }

        stage ('Sonar Analysis') {
            steps {
                withSonarQubeEnv('SonarQube 8.4') {
                    bat 'mvn sonar:sonar'
                }
            }
        }

        stage ('Upload to Artifactory') {
            steps {
                rtMavenDeployer(
                    id: 'dev-deployer',
                    serverId: 'artifactory 6.20',
                    snapshotRepo: 'nagp-devops-exam-try-1',
                    releaseRepo: 'nagp-devops-exam-try-1'
                )

                rtMavenRun(
                    pom: 'pom.xml',
                    goals: 'clean install',
                    deployerId: 'dev-deployer'
                )

                rtPublishBuildInfo(
                    serverId: 'artifactory 6.20'
                )
            }
        }

        stage ('Docker build') {
            steps {
                script {
                    bat 'docker build  --network=host  -t nimit07/nagp-devops-exam-prod:%BUILD_NUMBER% --no-cache -f Dockerfile .'
                }
            }
        }

        stage ('Push To DTR') {
            steps {
                bat 'docker login -u nimit07 -p Human@123'
                bat 'docker push nimit07/nagp-devops-exam-prod:%BUILD_NUMBER%'
            }
        }

        stage ('Stop Running Contaiers') {
            steps {
                script {
                    bat '''
                    for /f %%i in ('docker ps -aqf "name=^nagp-devops-exam-prod"') do set containerId=%%i
                    echo %containerId%
                    If "%containerId%" == "" (
                        echo "No running container"
                    ) else (
                        docker stop %containerId%
                        docker rm -f %containerId%
                    )
                    '''
                }
            }
        }

        stage ('Docker Deployment') {
            steps {
                script {
                    bat 'docker run --name nagp-devops-exam -d -p 6400:8080 nimit07/nagp-devops-exam-prod:%BUILD_NUMBER%'
                }
            }
        }

    }
}