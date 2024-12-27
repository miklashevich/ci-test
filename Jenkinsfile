pipeline {
    agent any

    environment {
        IMAGE_NAME = "mik1979/skillbox_app"
        PROJECT_NAME = "ci-test"
        DOCKER_REGISTRY_URL = "https://index.docker.io/v1/"
        DOCKER_REGISTRY_CREDENTIALS = "dockerhub-credentials-id"
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
            
            def targetBranchName = env.CHANGE_TARGET?.toLowerCase() ?: env.BRANCH_NAME.toLowerCase().replaceAll("/", "-")
            def commitHash = env.GIT_COMMIT.take(7)
            
            echo "Building image for target branch: ${targetBranchName}, commit: ${commitHash}"

            // Формируем корректные теги
            def commitTag = "mik1979/${IMAGE_NAME}:${targetBranchName}-${commitHash}"
            def branchTag = "mik1979/${IMAGE_NAME}:${targetBranchName}"
            def latestTag = "mik1979/${IMAGE_NAME}:latest"

            // Собираем образы с нужными тегами
            sh "docker build -t ${commitTag} ."
            sh "docker build -t ${branchTag} ."
            sh "docker build -t ${latestTag} ."
            sh "docker images"
        }
    }
}

        stage('Push to Registry') {
            steps {
                script {
            // Получаем имя ветки
            def targetBranchName = env.CHANGE_TARGET?.toLowerCase() ?: env.BRANCH_NAME.toLowerCase().replaceAll("/", "-")
            def commitHash = env.GIT_COMMIT.take(7)

            // Формируем теги образов
            def branchTag = "${IMAGE_NAME}:${targetBranchName}"
            def commitTag = "${IMAGE_NAME}:${targetBranchName}-${commitHash}"
            def latestTag = "${IMAGE_NAME}:latest"

            echo "Building and pushing image: ${branchTag}, ${commitTag}, and ${latestTag} to Docker Hub"

            // Логин в Docker Registry
            withDockerRegistry([credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}", url: "${DOCKER_REGISTRY_URL}"]) {
                // Пушим образы с разными тегами
                sh "docker push ${branchTag}"   // Тег с именем ветки
                sh "docker push ${commitTag}"  // Тег с именем ветки и хэшем коммита
                sh "docker push ${latestTag}"  // Тег latest
            }
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
