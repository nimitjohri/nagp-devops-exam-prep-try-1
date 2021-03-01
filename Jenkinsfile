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
                rtMavenDeployer {
                    id: 'deployer',
                    serverId: 'artifactory6.20'
                    snapshotRepo: 'nagp-devops-exam-try-1'
                    releaseRepo: 'nagp-devops-exam-try-1'
                }

                rtMavenRun {
                    pom: 'pom.xml'
                    goals: 'clean install'
                    deployerId: 'deployer'
                }

                rtPublishBuildInfo {
                    serverId: 'artifactory6.20'
                }
            }
        }
    }
}