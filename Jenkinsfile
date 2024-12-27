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
            def targetBranchName = env.CHANGE_TARGET?.toLowerCase() ?: env.BRANCH_NAME.toLowerCase()
            def commitHash = env.GIT_COMMIT.take(7)

            echo "Building image for target branch: ${targetBranchName}, commit: ${commitHash}"

            def commitTag = "${IMAGE_NAME}/${targetBranchName}:${commitHash}"
            def latestTag = "${IMAGE_NAME}/${targetBranchName}:latest"

            sh "docker build -t ${commitTag} ."
            sh "docker build -t ${latestTag} ."
            sh "docker images"
        }
    }
}

        stage('Test') {
            steps {
                script {
                    echo 'Running tests...'
                    sh "echo workspace ${WORKSPACE}"
                    if (fileExists('./run-tests.sh')) {
                        sh './run-tests.sh'
                        
                    } else {
                        error 'Test script not found!'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying...'
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
