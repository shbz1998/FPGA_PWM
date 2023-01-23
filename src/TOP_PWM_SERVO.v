`timescale 1ns / 1ps

module TOP_PWM_SERVO
(
input wire clk,
input wire rst,
output wire servo,
input wire[3:0] sw
);

localparam resolution = 8;
wire[31:0] dvsr = 4882; //precalculated value
wire pwm_out_sine;

reg clk_50hz;
integer counter;
reg[resolution : 0] duty_reg2;
reg[resolution-1:0] addr;
wire[resolution: 0] duty;

reg[resolution-1:0] mem[0:(2**resolution)-1];
integer signed angle, sin_scaled;
reg signed[11:0] MATH_PI = 12'b0011_00100011;
integer i;

reg[resolution-1:0] sine_data;
wire[resolution:0] duty_linear;
wire[resolution:0] duty_sine;

always@*
begin
    for(i = 0; i<(2**resolution -1); i=i+1)
    begin
        angle = (i)*((2*MATH_PI)/(2**resolution));
        sin_scaled = (1 + $sin(angle)) * (2**resolution - 1) / 2;
        mem[i] = $floor(sin_scaled);
    end
end

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


//sine
always@(posedge clk_50hz)
begin
    if(rst)
    begin
        duty_reg2 <= 0;
    end
    
    else
    begin
        if(duty_reg2 <= 2**resolution)
        begin
            addr <= addr + 1;
            sine_data <= mem[addr];
            duty_reg2 <= {1'b0, sine_data};
        end      
         
        else
        begin
            duty_reg2 <= 0;
        end        
    end        
end


PWM_ENHANCED #(.R(resolution)) R2(.clk(clk), .rst(rst), .dvsr(dvsr), .duty(duty_sine), .pwm_out(pwm_out_sine));


assign servo = (sw == 4'b0001) ? pwm_out_sine : 0;

assign duty_sine = duty_reg2;


endmodule
