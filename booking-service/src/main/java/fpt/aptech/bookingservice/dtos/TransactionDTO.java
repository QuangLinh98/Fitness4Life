package fpt.aptech.bookingservice.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class TransactionDTO {
    @JsonProperty("amount")
    private AmountDTO amount;
}

@Data
class AmountDTO {
    @JsonProperty("total")
    private Double total;
}
