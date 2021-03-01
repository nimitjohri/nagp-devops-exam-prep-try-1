def scmVars
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
                    scmVars = checkout scm
                }
            }
        }

        stage ('Build') {
            steps {
                script {
                    echo scmVars.GIT_Branch
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
                    if (scmVars.GIT_Branch == "origin/dev") {
                        bat 'docker build  --network=host  -t nimit07/nagp-devops-exam:%BUILD_NUMBER% --no-cache -f Dockerfile .'
                    } else if  (scmVars.GIT_Branch == "origin/prod") {
                        bat 'docker build  --network=host  -t nimit07/nagp-devops-exam-prod:%BUILD_NUMBER% --no-cache -f Dockerfile .'
                    }
                }
            }
        }

        stage ('Push To DTR') {
            steps {
                script{
                    bat 'docker login -u nimit07 -p Human@123'
                    if (scmVars.GIT_Branch == "origin/dev") {
                        bat 'docker push nimit07/nagp-devops-exam:%BUILD_NUMBER%'
                    } else if  (scmVars.GIT_Branch == "origin/prod") {
                        bat 'docker push nimit07/nagp-devops-exam-prod:%BUILD_NUMBER%'
                    }
                }
            }
        }

        stage ('Stop Running Contaiers') {
            steps {
                script {
                    if (scmVars.GIT_Branch == "origin/dev") {
                        tagname = 'nagp-devops-exam'
                    } else if  (scmVars.GIT_Branch == "origin/prod") {
                        tagname = 'nagp-devops-exam-prod'
                    }

                    bat '''
                    for /f %%i in ('docker ps -aqf "name=^${tagname}"') do set containerId=%%i
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
                    if (scmVars.GIT_Branch == "origin/dev") {
                        tagname = 'nagp-devops-exam'
                    } else if  (scmVars.GIT_Branch == "origin/prod") {
                        tagname = 'nagp-devops-exam-prod'
                    }
                    bat 'docker run --name ${tagname} -d -p 6300:8080 nimit07/${tagname}:%BUILD_NUMBER%'
                }
            }
        }

    }
}