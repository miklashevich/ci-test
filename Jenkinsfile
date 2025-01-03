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
            [key: 'PR_NUMBER', value: '$pull_request.number'], // номер PR из Webhook
            [key: 'TARGET_BRANCH', value: '$pull_request.base.ref'] // Ветка назначения из Webhook
        ],
            token: env.GITHUB_TOKEN, 
            printContributedVariables: true,
            printPostContent: true
        )
    }

    stages {


       stage('Print Environment Variables') {
            steps {
                script {
                    // Вывод всех переменных окружения
                    echo "Доступные переменные окружения:"
                    env.each { key, value ->
                        echo "${key} = ${value}"
                    }
                }
            }
        }

        stage('Validate Webhook Data') {
            steps {
                script {
                    
                    echo "PR_NUMBER: ${env.PR_NUMBER}"
                    echo "TARGET_BRANCH: ${env.TARGET_BRANCH}"

                    if (!env.PR_NUMBER || !env.TARGET_BRANCH) {
                        error "Отсутствует необходимая информация из Webhook. Проверьте передаваемые данные."
                    }

                    if (env.TARGET_BRANCH != "develop") {
                        error "PR #${PR_NUMBER} направлен не в develop. Мерж невозможен."
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
                    // Определяем изменённые микросервисы
                    def changedServices = sh(script: "git diff --name-only origin/develop...pr-${PR_NUMBER} | grep '^services/' | cut -d '/' -f 2 | sort -u", returnStdout: true).trim().split('\n')

                    if (changedServices.isEmpty()) {
                        echo "Нет изменённых микросервисов для сборки."
                    } else {
                        for (service in changedServices) {
                            sh """
                            docker build -t ${DOCKER_REGISTRY}/${service}:pr-${PR_NUMBER} ./services/${service}
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
                    def changedServices = sh(script: "git diff --name-only origin/develop...pr-${PR_NUMBER} | grep '^services/' | cut -d '/' -f 2 | sort -u", returnStdout: true).trim().split('\n')

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