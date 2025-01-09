pipeline {
    agent any

    environment {
        PROJECT_NAME = "ci-test"
        DOCKER_HUB_REPO = "mik1979"
        DOCKER_REGISTRY_URL = "https://index.docker.io/v1/"
        DOCKER_REGISTRY_CREDENTIALS = "dockerhub-credentials-id"
        DOCKER_BUILDKIT = "1"
        GITHUB_TOKEN = credentials('github_token')
    }

    triggers {
    GenericTrigger(
        causeString: 'Triggered by Webhook',
        genericVariables: [
            [key: 'PR_NUMBER', value: '$.number'],  
            [key: 'TARGET_BRANCH', value: '$.repository.default_branch']  
        ],
        token: 'github_token',
        printPostContent: true,
        printContributedVariables: true,
        silentResponse: false
    )
}

    stages {

        stage('Validate Webhook Data') {
    steps {
        script {
            echo "PR_NUMBER: ${env.PR_NUMBER ?: 'Не задано'}"
            echo "TARGET_BRANCH: ${env.TARGET_BRANCH ?: 'Не задано'}"

            if (!env.PR_NUMBER || !env.TARGET_BRANCH) {
                error "Ошибка: данные Webhook некорректны или отсутствуют. Проверьте JSONPath в настройках GenericTrigger."
            }

            if (env.TARGET_BRANCH != 'develop') {
                error "PR #${env.PR_NUMBER} направлен в неправильную ветку: ${env.TARGET_BRANCH}. Мерж невозможен."
            }
        }
    }
}

        stage('Checkout PR') {
            steps {
                script {
                    // Клонируем PR-ветку
                    sh """
                    git fetch origin pull/${PR_NUMBER}/head:pr-${PR_NUMBER}
                    git checkout pr-${PR_NUMBER}
                    """
                }
            }
        }

        stage('Build Docker Images') {
    steps {
        script {
            
            sh "git fetch origin develop:develop"

            def changedServices = sh(script: """
                git diff --name-only develop...pr-${PR_NUMBER} | grep '^micro-services/' | cut -d '/' -f 2 | sort -u
            """, returnStdout: true).trim().split('\n')

            if (changedServices.isEmpty()) {
                echo "Нет изменённых микросервисов для сборки."
            } else {
                for (service in changedServices) {
                    sh """
                    docker build -t ${DOCKER_REGISTRY}/${service}:pr-${PR_NUMBER} ./micro-services/${service}
                    docker tag ${DOCKER_REGISTRY}/${service}:pr-${PR_NUMBER} ${DOCKER_REGISTRY}/${service}:latest
                    docker push ${DOCKER_REGISTRY}/${service}:pr-${PR_NUMBER}
                    docker push ${DOCKER_REGISTRY}/${service}:latest
                    """
                }
            }
        }
    }
}


        stage('Run Tests') {
            steps {
                script {
                    // Тестирование Docker-образов
                    def changedServices = sh(script: "git diff --name-only origin/develop...pr-${PR_NUMBER} | grep '^micro-services/' | cut -d '/' -f 2 | sort -u", returnStdout: true).trim().split('\n')

                    if (changedServices.isEmpty()) {
                        echo "Нет изменённых микросервисов для тестирования."
                    } else {
                        for (service in changedServices) {
                            sh """
                            docker run --rm ${DOCKER_REGISTRY}/${service}:pr-${PR_NUMBER} /bin/sh -c "run_tests.sh"
                            """
                        }
                    }
                }
            }
        }

        stage('Merge PR') {
            steps {
                script {
                    // Автоматический merge PR в develop
                    sh """
                    git checkout develop
                    git merge pr-${PR_NUMBER} --no-ff -m "Auto-merge PR #${PR_NUMBER} into develop"
                    git push origin develop
                    """
                }
            }
        }
    }
}