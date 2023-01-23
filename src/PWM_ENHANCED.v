`timescale 1ns / 1ps

module PWM_ENHANCED #(parameter R = 10)
(
input wire clk, 
input wire rst,
input wire[31:0] dvsr,
input wire[R:0] duty,
output wire pwm_out
);

reg[31:0] q_reg;
wire[31:0] q_next;

reg[R-1:0] d_reg;
wire[R-1:0] d_next;
wire[R:0] d_ext;

reg pwm_reg;
wire pwm_next;

wire tick;


always@(posedge clk or posedge rst) 
begin
    if(rst)
    begin
        q_reg <= 0;
        d_reg <= 0;
        pwm_reg <= 0;
    end
    
    else
    begin
        q_reg <= q_next;
        d_reg <= d_next;
        pwm_reg <= pwm_next;
    end
end


assign q_next = (q_reg == dvsr) ? 0 : (q_reg + 1'b1);
assign tick = (!q_reg) ? 1 : 0;
assign d_next = (tick) ? (d_reg + 1) : d_reg;
assign d_ext = {1'b0, d_reg};
assign pwm_next = (d_ext < duty) ? 1'b1 : 1'b0;
assign pwm_out = pwm_reg;

endmodule
