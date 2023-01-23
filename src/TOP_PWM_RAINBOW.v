`timescale 1ns / 1ps

module TOP_PWM_RAINBOW
(
input wire clk,
input wire rst,
output wire[2:0] rgb,
input wire [3:0] sw
);

localparam resolution = 8;
wire[31:0] dvsr = 4882; //precalculated value
wire pwm_out1, pwm_out2;
reg clk_50hz;
integer counter;
reg[resolution : 0] duty_reg = 2**resolution;
reg[resolution : 0] duty_reg2, duty_reg3;
wire[resolution: 0] duty, duty2, duty3;
integer main_count = 0;


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
        main_count <= 0;
    else
    begin
        if(main_count <= 256)
            main_count<=main_count + 1;
        else
            main_count <= 0;
    end
end

always@(posedge clk_50hz)
begin
    if(rst)
    begin
        duty_reg <= 2**resolution;
        duty_reg2 <= 0;
        duty_reg3 <= 0;
    end
    
    else
    begin
        if(main_count >= 0 && main_count <= 45)
        begin
            duty_reg2 <= duty_reg2 + 1; //increase green
        end
        
        else if(main_count >45 && main_count <= 90)
        begin
            duty_reg <= duty_reg - 1;   //decrease red                
        end
        
        else if(main_count > 90 && main_count <= 135)
        begin
            duty_reg3 <= duty_reg3 + 1;
        end
        
        else if(main_count > 135 && main_count <= 180)
        begin
            duty_reg2 <= duty_reg2 -1;
        end
        
        else if(main_count > 180 && main_count <= 225)
        begin
            duty_reg <= duty_reg + 1;
        end
        
        else if(main_count > 225 && main_count <= 255)
        begin
            duty_reg3 <= duty_reg3 - 1;
        end
        
        else
        begin
            duty_reg <= 2**resolution;
            duty_reg2 <= 0;
            duty_reg3 <= 0;
        end
    end
end




PWM_ENHANCED #(.R(resolution)) R1(.clk(clk), .rst(rst), .dvsr(dvsr), .duty(duty), .pwm_out(pwm_out1));
PWM_ENHANCED #(.R(resolution)) R2(.clk(clk), .rst(rst), .dvsr(dvsr), .duty(duty2), .pwm_out(pwm_out2));
PWM_ENHANCED #(.R(resolution)) R3(.clk(clk), .rst(rst), .dvsr(dvsr), .duty(duty3), .pwm_out(pwm_out3));


assign rgb[0] = pwm_out1;
assign rgb[1] = pwm_out2;
assign rgb[2] = pwm_out3;


assign duty = duty_reg;
assign duty2 = duty_reg2;
assign duty3 = duty_reg3;



endmodule
