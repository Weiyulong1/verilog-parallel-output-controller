`timescale 1ns / 1ps


module sim(
    );
        reg clk;
        reg rst;
        reg mode;
        
        wire [7:0] led_o;
        top uut(
        .clk(clk),
        .RESET(rst),
        .CHANGE(mode),
        .LED(led_o)
        );
        
        initial begin
        clk = 0;
        rst = 0;
        mode = 0;
        #50;
        rst=1;
        #50;
        rst=0;
 
//        #10;      //切换中断模式
//        clk=1;
//        #10;
//        clk=0;
//        #10;
//        clk=1;
//        #10;
//        clk=0;       
        
//        #50;
//        mode=1;
//        #50;
//        mode=0;
        forever
        #10 clk=~clk;
        end
endmodule
