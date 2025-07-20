pipeline {
    agent any
    environment {
        deploy_server = '54.180.120.45'
        deploy_dir = '/home/ubuntu/demo/target'
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
        stage('Test') {
            steps {
                echo 'Running tests...'
                dir('./backend') {
                    sh 'chmod +x ./gradlew'
                    sh './gradlew test'
                }
            }
        }
        stage('Build Project') {
            steps {
                echo 'build project...'
                dir('./backend') {
                    sh 'chmod +x ./gradlew'
                    sh './gradlew clean build -x test'
                }
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

                        scp $WORKSPACE/backend/build/libs/*.jar $user_name@$deploy_server:$deploy_dir
                        scp $WORKSPACE/backend/$deploy_script $user_name@$deploy_server:$deploy_dir
                    '''
                }
            }
        }
        stage('Deploy To AWS') {
            steps {
                echo 'deploy...'
                sshagent(credentials: ['AWS_KEY']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no $user_name@$deploy_server "cd demo/target && bash $deploy_script"
                    '''
                }
            }
        }
    }
    post {
        success {
            script {
                dir('./backend') {
                    def author = sh(script: "git show -s --pretty=%an", returnStdout: true).trim()
                    def commitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    def msg = "✅ [Build Success] <${env.BUILD_URL}|${env.JOB_NAME} #${env.BUILD_NUMBER}>\n" +
                              "👨‍💻 Author: ${author}\n" +
                              "📝 Commit: ${commitMsg}\n" +
                              "📦 Branch: $branch"
                    mattermostSend (
                        color: 'good',
                        message: msg,
                        endpoint: "${mattermost_url}",
                        channel: "${mattermost_channel}"
                    )
                }
            }
        }
        failure {
            script {
                dir('./backend') {
                    def author = sh(script: "git show -s --pretty=%an", returnStdout: true).trim()
                    def commitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    def msg = "❌ [Build Failure] <${env.BUILD_URL}|${env.JOB_NAME} #${env.BUILD_NUMBER}>\n" +
                              "👨‍💻 Author: ${author}\n" +
                              "📝 Commit: ${commitMsg}\n" +
                              "📦 Branch: $branch"
                    mattermostSend (
                        color: 'danger',
                        message: msg,
                        endpoint: "${mattermost_url}",
                        channel: "${mattermost_channel}"
                    )
                }
            }
        }
    }
}
