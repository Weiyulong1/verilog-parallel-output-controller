`timescale 1ns / 1ps



module top(
input clk,
input CHANGE,
input RESET,
output [7:0] LED
    );
    wire addr,rw,irq,rdy,tr;
    wire [7:0] dout;
    wire [7:0] din;
    wire [7:0] pd;
    
    processor p1(.ADDR(addr),.Dout(dout),.Din(din),.RW(rw),.CLK(clk),.IRQ(irq));
    poc p2(.ADDR(addr),.Dout(dout),.Din(din),.RW(rw),.CLK(clk),.IRQ(irq),.RDY(rdy),.TR(tr),.PD(pd),.reset(RESET),.mode(CHANGE));
    printer p3(.TR(tr),.PD(pd),.CLK(clk),.RDY(rdy),.print(LED));    
endmodule
