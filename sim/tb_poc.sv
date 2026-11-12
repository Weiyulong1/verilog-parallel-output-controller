`timescale 1ns / 1ps

module tb_poc;
    reg clk = 0;
    reg reset = 0;
    reg mode = 0;
    reg addr = 1;
    reg rw = 1;
    reg rdy = 0;
    reg [7:0] din = 0;
    wire [7:0] status;
    wire irq;
    wire tr;
    wire [7:0] pd;

    poc dut (
        .ADDR(addr), .Dout(status), .Din(din), .RW(rw), .CLK(clk),
        .IRQ(irq), .RDY(rdy), .TR(tr), .PD(pd), .reset(reset), .mode(mode)
    );
    always #5 clk = ~clk;

    task check_transfer(input [7:0] expected, input bit interrupt_mode);
        begin
            @(negedge clk);
            addr = 0;
            rw = 0;
            din = expected;
            repeat (2) @(posedge clk);

            @(negedge clk);
            addr = 1;
            din = 0;
            repeat (2) @(posedge clk);
            #1;
            if (irq !== 1'b0 || status[7] !== 1'b0)
                $fatal(1, "CPU service must clear IRQ and SR7");

            @(negedge clk);
            rw = 1;
            repeat (2) begin
                @(posedge clk);
                #1;
                if (tr !== 1'b0)
                    $fatal(1, "Transfer asserted while the peripheral was busy");
            end

            @(negedge clk);
            rdy = 1;
            @(posedge clk);
            #1;
            if (tr !== 1'b1 || pd !== expected)
                $fatal(1, "Transfer mismatch: expected %02h, got %02h", expected, pd);

            @(negedge clk);
            rdy = 0;
            @(posedge clk);
            #1;
            if (tr !== 1'b0 || status[7] !== 1'b1 || irq !== interrupt_mode)
                $fatal(1, "Controller failed to return to ready state");
        end
    endtask

    initial begin
        #1 reset = 1;
        @(negedge clk);
        reset = 0;
        @(posedge clk);
        #1;
        if (status !== 8'h80 || irq !== 1'b0)
            $fatal(1, "Polling reset status mismatch");
        check_transfer(8'hf4, 0);

        @(negedge clk);
        mode = 1;
        repeat (2) @(posedge clk);
        #1;
        if (status[0] !== 1'b1 || irq !== 1'b1)
            $fatal(1, "Interrupt mode did not raise IRQ");
        check_transfer(8'hf5, 1);

        $display("PASS: polling, IRQ, busy peripheral, and byte transfer");
        $finish;
    end
endmodule
