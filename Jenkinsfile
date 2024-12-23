pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Клонирование репозитория
                //git 'git@github.com:miklashevich/ci-test.git'
                echo 'проверка'
        }

        stage('Build') {
            steps {
                // Сборка проекта
                //sh './build.sh' // Замените на вашу команду сборки
                echo 'stage biuld'
            }
        }

        stage('Test') {
            steps {
                // Запуск тестов
                //sh './run_tests.sh' // Замените на вашу команду для запуска тестов
                echo 'запуск тестов'
            }
        }

        stage('Deploy') {
            steps {
                // Развертывание приложения
                //sh './deploy.sh' // Замените на вашу команду развертывания
                echo 'деплой'
                
            }
        }
    }

    post {
        success {
            // Действия при успешном завершении
            echo 'Pipeline completed successfully!'
        }
        failure {
            // Действия при неудаче
            echo 'Pipeline failed.'
        }
    }
}

