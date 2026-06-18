package api.spec;

import io.qameta.allure.restassured.AllureRestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.filter.log.LogDetail;
import io.restassured.specification.RequestSpecification;
import io.restassured.specification.ResponseSpecification;

public class ProdClient {
    private static final String BASE_URL = System.getProperty("base.url", "http://localhost:8080");

    public static RequestSpecification requestSpec = new RequestSpecBuilder()
            .setBaseUri(BASE_URL)
            .setBasePath("/api")
            .setContentType("application/json; charset=UTF-8")
            .addHeader("Authorization", "Bearer QpwL5tke4Pnpja7X4")
            .addHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
            .addFilter(new AllureRestAssured())
            .log(LogDetail.ALL)
            .build();

    public static ResponseSpecification response200Spec = new ResponseSpecBuilder()
            .expectStatusCode(200)
            .log(LogDetail.BODY)
            .build();

    public static ResponseSpecification response201Spec = new ResponseSpecBuilder()
            .expectStatusCode(201)
            .log(LogDetail.BODY)
            .build();
}
