pipeline {
    agent any

    parameters {
        string(name: 'TEST_SUITE', defaultValue: 'Smoke', description: 'Сценарий запуска')
    }

    environment {
        // ==========================================
        // ГЛОБАЛЬНЫЕ НАСТРОЙКИ ИНФРАСТРУКТУРЫ (IaC)
        IMAGE_NAME         = "api-tests:jenkins"
        JOB_NAME           = "api-tests-job"
        NAMESPACE          = "qa-tests"
        ALLURE_RESULTS_DIR = "/automation/allure-results"
        // ==========================================
    }

    stages {
        stage('Checkout') {
            steps {
                // Скачиваем актуальный код из Git
                checkout scm
            }
        }

        stage('Deploy to Minikube') {
            steps {
                echo '=== Запуск тестов внутри Kubernetes (Minikube) ==='

                // Удаляем старый Job, если он остался от прошлых запусков
                sh "kubectl delete job ${JOB_NAME} -n ${NAMESPACE} --ignore-not-found=true"

                // Динамически подставляем переменные среды в файл манифеста перед деплоем
                sh """
                    sed -i 's|value: "Smoke"|value: "${params.TEST_SUITE}"|g' 02-job.yaml
                    sed -i 's|value: "/automation/allure-results"|value: "${ALLURE_RESULTS_DIR}"|g' 02-job.yaml
                    sed -i 's|mountPath: "/automation/allure-results"|mountPath: "${ALLURE_RESULTS_DIR}"|g' 02-job.yaml

                    kubectl apply -f 01-namespace.yaml
                    kubectl apply -f 02-job.yaml
                """
            }
        }

        stage('Wait & Watch Logs') {
            steps {
                echo '=== Ожидание завершения тестов и вывод логов ==='
                script {
                    // Ждем, пока создастся и запустится Под
                    sh "kubectl wait --namespace=${NAMESPACE} --for=condition=Ready pod -l job-name=${JOB_NAME} --timeout=60s"

                    // Стримим логи тестов прямо в консоль Jenkins в реальном времени
                    sh "kubectl logs -n ${NAMESPACE} -l job-name=${JOB_NAME} -f --pod-running-timeout=5m"

                    // Ждем официального завершения объекта Job (Succeeded или Failed)
                    sh "kubectl wait --for=condition=complete job/${JOB_NAME} -n ${NAMESPACE} --timeout=300s"
                }
            }
        }

        stage('Collect Allure Results') {
            steps {
                echo '=== Выкачивание Allure-результатов из кластера ==='
                // Очищаем локальную рабочую папку в Jenkins перед копированием
                sh "rm -rf allure-results && mkdir allure-results"

                // Находим имя случайно сгенерированного Пода через jsonpath и копируем результаты на хост Jenkins
                sh """
                    POD_NAME=\$(kubectl get pods -n ${NAMESPACE} -l job-name=${JOB_NAME} -o jsonpath='{.items.metadata.name}')
                    kubectl cp ${NAMESPACE}/\$POD_NAME:${ALLURE_RESULTS_DIR} ./allure-results
                """
            }
        }
    }

    post {
        always {
            echo '=== Генерация отчета Allure ==='
            // Публикуем результаты тестов в интерфейс Jenkins из локальной папки allure-results
            allure includeProperties: false, jdk: '', results: [[path: 'allure-results']]

            echo '=== Очистка ресурсов в кластере ==='
            // Удаляем Job, чтобы не занимать ресурсы кластера, но сохраняем namespace
            sh "kubectl delete job ${JOB_NAME} -n ${NAMESPACE} --ignore-not-found=true"
        }
    }
}
