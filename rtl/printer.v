`timescale 1ns / 1ps



module printer(
input TR,
input [7:0]PD,
input CLK,
output reg RDY=1,
output [7:0] print
    );
        reg [7:0]PD_reg=0;
        reg w=0;
        assign print=PD_reg;
        
        always@(posedge(CLK) or posedge(TR))begin
            if(w==1)begin
                    RDY<=1;
                    w<=0;
            end
            else begin
                if(TR==1)begin
                    PD_reg <= PD;
                    RDY<=0;
                    w<=1;
                end
            end
        end
endmodule
