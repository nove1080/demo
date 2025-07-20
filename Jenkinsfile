pipeline {
    agent any
    environment {
        deploy_server = '54.180.120.45'
        user_name = 'ubuntu'
        project_name = 'demo'
        git_url='https://github.com/nove1080/demo.git'
        deploy_script='deploy.sh'
        branch='master'
        mattermost_url='https://meeting.ssafy.com/hooks/hraap7ebiige9qf15dk8k6jtwy'
        mattermost_channel='C204-Build-Result'
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Clone the Repository...'
                dir('./backend') {
                    git branch: branch, url: git_url
                }
            }
        }
        stage('Prepare Secret File') {
            steps {
                echo 'copy secret file...'
                dir('./backend') {
                    withCredentials([file(credentialsId: 'application-secret', variable: 'APPLICATION_SECRET')]) {
                        sh 'sudo cp $APPLICATION_SECRET ./src/main/resources/application-secret.yml'
                    }
                }
            }
        }
        stage('Build Project') {
            steps {
                echo 'build project...'
                dir('./backend') {
                    sh 'chmod +x ./gradlew'
                    sh './gradlew clean build'
                }
            }
        }
        stage('Test') {
            steps {
                echo 'Running tests...'
            }
        }
        stage('Send JAR File To Deploy Server') {
            steps {
                echo 'send jar file to deploy server...'
                sshagent(credentials: ['AWS_KEY']) {
                    sh '''#!/bin/bash
                        mkdir -p ~/.ssh
                        chmod 700 ~/.ssh

                        ssh-keyscan $deploy_server >> ~/.ssh/known_hosts
                        chmod 644 ~/.ssh/known_hosts

                        scp $WORKSPACE/backend/build/libs/*.jar $user_name@$deploy_server:/home/$user_name/demo/target
                        echo "send jar file complete!"

                        scp $WORKSPACE/backend/$deploy_script $user_name@$deploy_server:/home/$user_name/demo/target/
                        echo "send deploy_script complete!"
                    '''
                }
            }
        }
        stage('Deploy To AWS') {
            steps {
                echo 'deploy...'
                sshagent(credentials: ['AWS_KEY']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no $user_name@$deploy_server "cd demo/target && bash deploy.sh"
                    '''
                }
            }
        }
    }
post {
    success {
        script {
            def Author_ID = sh(script: "git show -s --pretty=%an", returnStdout: true).trim()
            def Author_Name = sh(script: "git show -s --pretty=%ae", returnStdout: true).trim()
            mattermostSend (
                color: 'good',
                message: "빌드 성공: ${env.JOB_NAME} #${env.BUILD_NUMBER} by ${Author_ID}(${Author_Name})\n(<${env.BUILD_URL}|Details>)",
                endpoint: "${mattermost_url}",
                channel: "${mattermost_channel}"
            )
        }
    }
    failure {
        script {
            def Author_ID = sh(script: "git show -s --pretty=%an", returnStdout: true).trim()
            def Author_Name = sh(script: "git show -s --pretty=%ae", returnStdout: true).trim()
            mattermostSend (
                color: 'danger',
                message: "빌드 실패: ${env.JOB_NAME} #${env.BUILD_NUMBER} by ${Author_ID}(${Author_Name})\n(<${env.BUILD_URL}|Details>)",
                endpoint: "${mattermost_url}",
                channel: "${mattermost_channel}"
            )
        }
    }
}
