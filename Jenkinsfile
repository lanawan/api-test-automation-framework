pipeline {
    agent any

    parameters {
        string(name: 'TEST_SUITE', defaultValue: '', description: 'SmokeTest')
    }

    environment {
        // Имя нашего Docker-образа
        IMAGE_NAME = "api-tests:${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Скачиваем актуальный код из Git
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '=== Сборка Docker-образа для автотестов ==='
                // Собираем образ и тегируем его номером текущей сборки Jenkins
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Run Infrastructure & Tests') {
            steps {
                echo '=== Запуск тестов внутри Docker контейнера ==='
                // Используем блок try-catch-finally, чтобы отчеты генерировались даже если тесты упадут
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    // Запускаем контейнер. Передаем параметр TEST_SUITE внутрь.
                    // Монтируем папку allure-results на хост-машину Jenkins, чтобы забрать результаты.
                    sh """
                        docker run --rm \
                        -e TEST_SUITE="${params.TEST_SUITE}" \
                        -v ${WORKSPACE}/allure-results:/automation/allure-results \
                        ${IMAGE_NAME}
                    """
                }
            }
        }
    }

    post {
        always {
            echo '=== Генерация отчета Allure ==='
            // Публикуем результаты тестов в интерфейс Jenkins
            allure includeProperties: false, jdk: '', results: [[path: 'allure-results']]

            echo '=== Очистка Docker-образов ==='
            // Удаляем собранный образ, чтобы не забивать место на Jenkins-агенте
            sh "docker rmi ${IMAGE_NAME} || true"
        }
    }
}
