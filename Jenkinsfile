pipeline {
    agent any
    tools {
        maven 'M3'
        sonar 'SonarQube8.4'
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
                script {
                    bat 'mvn sonar:sonar'
                }
            }
        }
    }
}