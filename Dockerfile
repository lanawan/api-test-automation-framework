FROM maven:3.9.6-eclipse-temurin-17-alpine

WORKDIR /automation

# Копируем pom.xml для кэширования зависимостей
COPY pom.xml .
# Загружаем зависимости заранее
RUN mvn dependency:go-offline -B

# Копируем исходный код
COPY src ./src

# Запуск тестов при старте контейнера
CMD ["mvn", "clean", "test"]