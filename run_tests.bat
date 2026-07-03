@echo off
:: Переключаем консоль в UTF-8
chcp 65001 > nul

:: ==========================================
:: ГЛОБАЛЬНАЯ НАСТРОЙКА: ПУТЬ К РЕЗУЛЬТАТАМ
set LOCAL_ALLURE_DIR=.\allure-results
set MINIKUBE_ALLURE_DIR=/data/allure-results
:: ==========================================

echo === 1. Проверяем и запускаем Minikube ===
minikube start

echo Ожидаем 10 секунд для запуска сети кластера...
timeout /t 10 > nul

echo === 2. Подготавливаем локальную папку на ПК ===
if exist %LOCAL_ALLURE_DIR% del /f /q %LOCAL_ALLURE_DIR%
if exist %LOCAL_ALLURE_DIR% rmdir /s /q %LOCAL_ALLURE_DIR%
mkdir %LOCAL_ALLURE_DIR%

echo === 3. Связываем папку Minikube с твоим ПК через Mount ===
:: Используем наши переменные среды для монтирования
start /b minikube mount %LOCAL_ALLURE_DIR%:%MINIKUBE_ALLURE_DIR%

echo Ожидаем 5 секунд для настройки связи папок...
timeout /t 5 > nul

echo === 4. Собираем Docker-образ внутри кластера ===
minikube image build -t api-tests:jenkins .

echo === 5. Запускаем тесты в Kubernetes ===
kubectl apply -f 01-namespace.yaml
kubectl delete job api-tests-job -n qa-tests --ignore-not-found=true
kubectl apply -f 02-job.yaml

echo === 6. Ожидаем готовности и смотрим логи тестов ===
kubectl wait --namespace=qa-tests --for=condition=Ready pod -l job-name=api-tests-job --timeout=60s
kubectl logs -n qa-tests -l job-name=api-tests-job -f

echo === 7. Запускаем Allure отчет в браузере ===
echo Файлы синхронизированы! Открываем отчет из переменной %LOCAL_ALLURE_DIR%...
allure serve %LOCAL_ALLURE_DIR%

pause
