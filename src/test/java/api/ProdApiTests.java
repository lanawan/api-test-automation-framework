package api;


import api.model.ProdRequest;
import api.model.ProdResponse;
import com.github.tomakehurst.wiremock.junit5.WireMockExtension;
import io.qameta.allure.*;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.filter.log.LogDetail;
import io.restassured.http.ContentType;
import io.restassured.specification.RequestSpecification;
import io.restassured.specification.ResponseSpecification;
import io.qameta.allure.restassured.AllureRestAssured;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.RegisterExtension;

import static com.github.tomakehurst.wiremock.client.WireMock.*;
import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.wireMockConfig;
import static io.restassured.RestAssured.given;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@Epic("Управление товарами")
@Feature("API Продуктов")
public class ProdApiTests {
    // 1. Автоматически запускаем локальный WireMock на случайном свободном порту
    @RegisterExtension
    static WireMockExtension wireMockServer = WireMockExtension.newInstance()
            .options(wireMockConfig().dynamicPort())
            .build();

    private static RequestSpecification requestSpec;
    private static ResponseSpecification response201Spec;

    @BeforeAll
    public static void setupSpecs() {
        // 2. Динамически подставляем порт, на котором поднялся WireMock
        String baseUri = "http://localhost:" + wireMockServer.getPort();

        requestSpec = new RequestSpecBuilder()
                .setBaseUri(baseUri)
                .setBasePath("/api")
                .setContentType(ContentType.JSON)
                .addFilter(new AllureRestAssured()) // Логирование для Allure отчетов
                .log(LogDetail.ALL)
                .build();

        response201Spec = new ResponseSpecBuilder()
                .expectStatusCode(201)
                .log(LogDetail.BODY)
                .build();
    }


    @Test
    @Story("Успешное создание товара")
    @Severity(SeverityLevel.BLOCKER)
    @DisplayName("Проверка создания товара с валидными данными")
    public void successCreateProdTest() {
        String testProdId = "testingId";
        String testProdStatus = "testingStatus";


        ProdRequest requestBody = new ProdRequest(
                testProdId,
                testProdStatus
                );


        // 3. Описываем заглушку (Stub) через WireMock Java API
        wireMockServer.stubFor(post(urlEqualTo("/api/prod"))
                .withHeader("Authorization", containing("Bearer"))
                .withRequestBody(matchingJsonPath("$.prodId"))
                .willReturn(aResponse()
                        .withStatus(201)
                        .withHeader("Content-Type", "application/json")
                        .withBody("{\n" +
                                "  \"id\": \"generated-uuid-12345\",\n" +
                                "  \"prodId\": \"" + testProdId + "\",\n" +
                                "  \"status\": \"" + testProdStatus + "\",\n" +
                                "  \"createdAt\": \"2026-06-18T22:40:00Z\"\n" +
                                "}")));

        // 5. Отправляем запрос через Rest Assured и десериализуем ответ в POJO
        ProdResponse response = given()
                .spec(requestSpec)
                .header("Authorization", "Bearer QpwL5tke4Pnpja7X4")
                .body(requestBody)
                .when()
                .post("/prod")
                .then()
                .spec(response201Spec)
                .extract()
                .as(ProdResponse.class);

        // 6. Проверяем результат
        assertNotNull(response.getId());
        assertEquals(testProdId, response.getProdId());
        assertEquals(testProdStatus, response.getStatus());
    }
}
