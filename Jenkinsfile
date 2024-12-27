pipeline {
    agent any

    environment {
        IMAGE_NAME = "skillbox_app"
        PROJECT_NAME = "ci-test"
        DOCKER_HUB_REPO = "mik1979"
        DOCKER_REGISTRY_URL = "https://index.docker.io/v1/"
        DOCKER_REGISTRY_CREDENTIALS = "dockerhub-credentials-id"
        GITHUB_TOKEN = credentials('github_token')
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: '25d3ccab-69c9-47ee-92fe-56c0bb67756c', url: "git@github.com:miklashevich/${PROJECT_NAME}.git"
            }
        } 


    stage('Prepare tags') {
            steps {
                script {
                    
                    targetBranchName = env.CHANGE_TARGET?.toLowerCase() ?: env.BRANCH_NAME.toLowerCase().replaceAll("/", "-")
                    commitHash = env.GIT_COMMIT.take(7)
                    
                    commitTag = "${DOCKER_HUB_REPO}/${IMAGE_NAME}:${targetBranchName}-${commitHash}"
                    branchTag = "${DOCKER_HUB_REPO}/${IMAGE_NAME}:${targetBranchName}"
                    latestTag = "${DOCKER_HUB_REPO}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    echo "Building image for target branch: ${targetBranchName}, commit: ${commitHash}"

                    sh "docker build -t ${commitTag} ."
                    sh "docker tag ${commitTag} ${branchTag}" 
                    sh "docker tag ${commitTag} ${latestTag}" 
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


        stage('Push to Registry') {
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
            script {
                if (env.CHANGE_TARGET) {
                    echo "All checks passed. Merging branch ${env.CHANGE_BRANCH} into ${env.CHANGE_TARGET}."

                    sh """
                        git config user.name "Jenkins"
                        git config user.email "jenkins@yourdomain.com"
                        git checkout ${env.CHANGE_TARGET}
                        git pull origin ${env.CHANGE_TARGET}
                        git merge ${env.CHANGE_BRANCH} --no-edit
                        git push origin ${env.CHANGE_TARGET}
                    """
                } else {
                    echo "This is not a Pull Request, merge step is skipped."
                }
            }
        }
        failure {
            echo "Build or tests failed. Merge will not be performed."
        }
    }
}
