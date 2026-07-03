# Используем минимальный готовый образ с Maven и Java 17
FROM maven:3.9.6-eclipse-temurin-17-alpine

WORKDIR /automation

# Создаем non-root пользователя и настраиваем домашнюю папку для Maven
RUN addgroup -S qa && adduser -S qa -G qa && \
    mkdir -p /home/qa/.m2 && chown -R qa:qa /home/qa

# Переключаемся на пользователя ДО копирования файлов
USER qa

# Шаг 1: Кэшируем зависимости (теперь они скачиваются в /home/qa/.m2)
COPY --chown=qa:qa pom.xml .
RUN mvn dependency:go-offline -B

# Шаг 2: Копируем исходный код
COPY --chown=qa:qa src ./src

# Шаг 3: Компилируем тесты заранее
RUN mvn test-compile -B

ENV TEST_SUITE=""

# Указываем путь к результатам Allure внутри рабочей директории
ENTRYPOINT ["sh", "-c", "mvn test -Dsuite=${TEST_SUITE} -Dallure.results.directory=/automation/allure-results"]
