FROM maven:3.9.6-eclipse-temurin-17-alpine

WORKDIR /automation

# Создаем пользователя qa и даем права на рабочую директорию
RUN addgroup -S qa && adduser -S qa -G qa && \
    mkdir -p /home/qa/.m2 && \
    chown -R qa:qa /home/qa && \
    chown -R qa:qa /automation

USER qa

# Кэшируем зависимости
COPY --chown=qa:qa pom.xml .
RUN mvn dependency:go-offline -B

# Копируем исходный код
COPY --chown=qa:qa src ./src

# Компилируем тесты
RUN mvn test-compile -B

# ГЛОБАЛЬНАЯ ПЕРЕМЕННАЯ: Путь к результатам по умолчанию
ENV ALLURE_RESULTS_DIR="/automation/allure-results"
ENV TEST_SUITE=""

# Передаем переменную среды внутрь флага Maven
ENTRYPOINT ["sh", "-c", "mvn test -Dsuite=${TEST_SUITE} -Dallure.results.directory=${ALLURE_RESULTS_DIR}"]
