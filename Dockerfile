# Используем минимальный готовый образ с Maven и Java 17
FROM maven:3.9.6-eclipse-temurin-17-alpine

WORKDIR /automation

# Безопасность: создаем non-root пользователя
RUN addgroup -S qa && adduser -S qa -G qa

# Шаг 1: Кэшируем зависимости
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Шаг 2: Копируем исходный код
COPY src ./src

# Шаг 3: Компилируем тесты заранее и ОЧИЩАЕМ кэш плагинов Maven,
# который больше не нужен для запуска
RUN mvn test-compile && \
    rm -rf /root/.m2/repository/org/apache/maven/plugins

# Настраиваем права для пользователя
RUN chown -R qa:qa /automation
USER qa

ENV TEST_SUITE=""

# Передаем параметр allure.results.directory, чтобы отчеты складывались строго в корень /automation/allure-results
ENTRYPOINT ["mvn", "test", "-Dallure.results.directory=/automation/allure-results"]
CMD ["-Dsuite=${TEST_SUITE}"]
