pipeline {
    agent any

    environment {
        IMAGE_NAME = "skillbox_app"
        PROJECT_NAME = "ci-test"
        DOCKER_HUB_REPO = "mik1979"
        DOCKER_REGISTRY_URL = "https://index.docker.io/v1/"
        DOCKER_REGISTRY_CREDENTIALS = "dockerhub-credentials-id"
        DOCKER_BUILDKIT = "1"
        GITHUB_TOKEN = credentials('github_token')
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github_token', url: "https://oauth2:${GITHUB_TOKEN}@github.com/miklashevich/${PROJECT_NAME}.git"
            }
        } 

        stage('Prepare Tags') {
            steps {
                script {
                    // Генерация тегов для образов
                    targetBranchName = env.CHANGE_TARGET?.toLowerCase() ?: env.BRANCH_NAME.toLowerCase().replaceAll("/", "-")
                    commitHash = env.GIT_COMMIT.take(7)

                    // Формируем теги
                    commitTag = "${DOCKER_HUB_REPO}/${IMAGE_NAME}:${targetBranchName}-${commitHash}"
                    branchTag = "${DOCKER_HUB_REPO}/${IMAGE_NAME}:${targetBranchName}"
                    latestTag = "${DOCKER_HUB_REPO}/${IMAGE_NAME}:latest"
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

        stage('Auto-Merge PR to Dev') {
            when {
                anyOf {
                         branch 'dev'
                         expression { env.CHANGE_TARGET == 'dev' }
    }
            }
            steps {
                script {
                    echo "Auto-merging branch ${env.CHANGE_BRANCH} into ${env.CHANGE_TARGET}."

                    sh """
                        git config user.name "Jenkins"
                        git config user.email "jenkins@yourdomain.com"
                        git checkout ${env.CHANGE_TARGET}
                        git pull https://oauth2:${GITHUB_TOKEN}@github.com/miklashevich/${PROJECT_NAME}.git ${env.CHANGE_TARGET}
                        git fetch origin ${env.CHANGE_BRANCH}:${env.CHANGE_BRANCH}
                        git merge ${env.CHANGE_BRANCH} --no-edit
                        git push https://oauth2:${GITHUB_TOKEN}@github.com/miklashevich/${PROJECT_NAME}.git ${env.CHANGE_TARGET}
                    """
                }
            }
        }

        stage('Build Image (Post-Merge)') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    echo "Building image with BuildKit for branch: ${targetBranchName}, commit: ${commitHash}"

                    sh """
                        docker build \
                        --progress=plain \
                        --cache-from=type=local,src=/cache \
                        --cache-to=type=local,dest=/cache \
                        -t ${commitTag} \
                        -t ${branchTag} \
                        -t ${latestTag} \
                        .
                    """
                }
            }
        }

        stage('Push to Registry') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    echo "Pushing images: ${commitTag}, ${branchTag}, and ${latestTag} to Docker Hub"

                    withDockerRegistry([credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}", url: "${DOCKER_REGISTRY_URL}"]) {
                        sh "docker push ${commitTag}"   
                        sh "docker push ${branchTag}"  
                        sh "docker push ${latestTag}"  
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Build succeeded!"
        }
        failure {
            echo "Build failed. No merge performed."
        }
    }
}
