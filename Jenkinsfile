pipeline {
    agent any

    environment {
        IMAGE_NAME = "skillbox_app"
        PROJECT_NAME = "ci-test"
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: '25d3ccab-69c9-47ee-92fe-56c0bb67756c', url: "git@github.com:miklashevich/${PROJECT_NAME}.git"
                sh 'ls -la'
            }
        } 

        stage('Build') {
            steps {
                script {
                    def branchName = env.BRANCH_NAME ?: 'master' // Default to 'master' if not set
                    def commitHash = env.GIT_COMMIT.take(7) 

                    echo "Building image for branch: ${branchName}, commit: ${commitHash}"

                    def imageTag = "${IMAGE_NAME}:${PROJECT_NAME}-${branchName}-${commitHash}"
                    def latestTag = "${IMAGE_NAME}/${branchName}:latest"

                    sh "docker build -t ${latestTag} ."
                    sh "docker images"
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    echo 'Running tests...'
                    sh "echo pwd $pwd"
                    sh "echo workspace ${WORKSPACE}"
                    if (fileExists('./run-tests.sh')) {
                        sh './run-tests.sh'
                        
                        
                        //sh "docker run -v \"${WORKSPACE}:/tests\" golang:1.16.6-alpine3.14 /tests/scripts/test_in_docker.sh"
                    } else {
                        error 'Test script not found!'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying...'
                // Uncomment the line below to run the deploy script
                // sh './deploy.sh'
            }
        }
    } 

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
