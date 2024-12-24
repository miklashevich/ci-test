pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                
                git 'git@github.com:miklashevich/ci-test.git'
                echo 'Клонирование репозитория'
            } 
        } 

        stage('Build') {
            steps {
                // Сборка проекта
                //sh './build.sh' // Замените на вашу команду сборки
                echo 'stage build'
            }
        }

        stage('Test') {
            steps {
                
                //sh './run_tests.sh' // Замените на вашу команду для запуска тестов
                echo 'запуск тестов'
            }
        }

        stage('Deploy') {
            steps {
                
                //sh './deploy.sh' // Замените на вашу команду развертывания
                echo 'деплой'
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
