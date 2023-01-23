`timescale 1ns / 1ps

module TOP_PWM
(
input wire clk,
input wire rst,
output wire[2:0] rgb,
input wire [3:0] sw
);

localparam resolution = 8;
wire[31:0] dvsr = 4882; //precalculated value
wire pwm_out1;
reg clk_50hz;
integer counter;
reg[resolution : 0] duty_reg;
wire[resolution: 0] duty;


always@(posedge clk)
begin
    if(rst)
    begin
        counter <= 0;
        clk_50hz <= 0;
    end
    
    else
    begin
        if(counter < 1249999)
        begin
            counter <= counter + 1;                       
        end       
        
        else
        begin
            counter <= 0;
            clk_50hz <= ~ clk_50hz;
        end
    end
    
end

always@(posedge clk_50hz)
begin
    if(rst)
    begin
        duty_reg <= 0;
    end
    
    else
    begin
        duty_reg <= duty_reg + 1;
    end        
end


PWM_ENHANCED #(.R(resolution)) R1(.clk(clk), .rst(rst), .dvsr(dvsr), .duty(duty), .pwm_out(pwm_out1));


assign rgb[0] = (sw == 4'b0000) ? pwm_out1 : 0;
assign rgb[1] = 0;
assign rgb[2] = 0;

assign duty = duty_reg;


endmodule
