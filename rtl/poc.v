`timescale 1ns / 1ps



module poc(
input ADDR,                                 // the address of BR and SR ,BR=0,SR=1
output [7:0] Dout,
input [7:0] Din,
input RW,                                   // R=1,W=0
input CLK,
output reg IRQ = 0,                         //interrupt request
input RDY,
output reg TR = 0,       
output reg [7:0]PD = 0,
input reset,
input mode
    );

    `define free 0
    `define BR 1
    `define SR 2
    `define print 3
    
    reg [1:0] state = 0;
    
    reg [7:0] SR_reg = 8'b10000001;       
    reg [7:0] BR_reg = 0;
    assign Dout =SR_reg;
    reg flag_BR=0;
    reg flag_SR=0;
    reg flag_SR0=0;

    always@( posedge(CLK) or posedge(reset) or posedge(mode))begin
            if(reset==1)begin
                state<=`free;
                SR_reg<=8'b10000000;
                BR_reg<=0;
                flag_BR<=0;
                flag_SR<=0;
                TR<=0;
                IRQ<=0;
            end
            else begin
                if(mode==1&&flag_SR0==1)begin
                    SR_reg[0]<=SR_reg[0]+1;
                    flag_SR0<=0;
                end
                else if(mode==0)begin
                    flag_SR0<=1;
                end
                case(state)
                    `free:begin
                        
                        SR_reg[7]<=1'b1;
                        TR<=0;
                        if(SR_reg[0]==1'b1)                    //中断方式，发送中断请求信号
                            IRQ<=1;
                        if(ADDR==0&&RW==0)                  //选择BR,进行写入
                            state<=`BR;
                        else
                            state<=`free;
                    end
                    `BR:begin
                        if(flag_BR==0)begin
                            BR_reg<=Din;                        //将CPU中的数据写入BR
                            flag_BR<=1;
                        end                  
                        if(ADDR==1&&RW==0)begin                  //选择SR，进行写入
                            state<=`SR;
                            IRQ<=0;
                        end
                        else
                            state<=`BR;
                    end
                    `SR:begin
                        if(flag_SR==0)begin
                            SR_reg[7]<=Din[7];                  //CPU将SR7置为0
                            flag_SR<=1;
                        end
                        state<=`print;
                    end
                    `print:begin
                        if(SR_reg[7]==1'b0&&RDY==1)begin  //SR7为0且printer准备好
                            flag_SR<=0;
                            flag_BR<=0;
                            TR<=1;
                            PD<=BR_reg;                     //将数据传给printer
                            SR_reg[7]<=1'b1;               
                            state<=`free;
                        end
                        else
                            state<=`print;
                    end
                endcase
            end
        end
    
endmodule
