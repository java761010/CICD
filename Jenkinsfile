pipeline {
    agent { label 'windows' }
    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
        timestamps()
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                bat 'git log -1 --oneline'
            }
        }
        stage('Build') {
            steps {
                bat 'mvn -B clean package'
                bat 'if not exist target\\hello-ci.war exit /b 1'
                archiveArtifacts artifacts: 'target/hello-ci.war', fingerprint: true
            }
        }
        stage('Upload and Deploy') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'linux-vm-ssh',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    bat 'call windows\\deploy-vm.bat'
                }
            }
        }
    }
    post {
        success { echo 'Build, upload and deployment completed.' }
        failure { echo 'Check console log, Linux journalctl and Tomcat logs.' }
    }
}
