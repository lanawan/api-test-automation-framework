package api.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProdResponse {
    private String id;
    private String prodId;
    private String status;
    private String createdAt;
}
