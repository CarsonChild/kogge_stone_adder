module testbench8 ();
    localparam N = 8;
    logic clk, reset;
    logic [N-1:0] a, b, s, sexp;
    logic cin, cout, coutexp;
    logic [100:0] vectornum, errors;
    logic [(N*3)+1:0] testvectors[100:0];
    // instantiate device under test
    ksa #(.N(N)) dut (
        .a(a[N-1:0]), 
        .b(b[N-1:0]), 
        .cin(cin), 
        .s(s[N-1:0]), 
        .cout(cout)
    );
    // generate clock
    always
    begin
        clk = 1; #5; clk = 0; #5;
    end
    // at start of test, load vectors
    // and pulse reset
    initial
    begin
        $display("8 Bit KSA test beginning"); 
        $readmemb("testvectors8.tv", testvectors);
        reset = 1; #27; reset = 0;
        vectornum = 0; errors= 0;
    end
    // apply test vectors on rising edge of clk
    always @(posedge clk)
    begin
        #1; {a[N-1:0], b[N-1:0], cin, sexp[N-1:0], coutexp} = testvectors[vectornum];
    end
    // check results on falling edge of clk
    always @(negedge clk)
    if (~reset) begin // skip during reset
        if ({{s[N-1:0]}, cout} !== {{sexp[N-1:0]}, coutexp}) begin // check result
            $display("Error: inputs = %b", {{a[N-1:0]}, {b[N-1:0]}, cin});
            $display(" outputs = %b (%b expected)", {{s[N-1:0]}, cout}, {{sexp[N-1:0]}, coutexp});
            errors = errors + 1;
        end
            vectornum = vectornum + 1;
        if (testvectors[vectornum] === 26'bx) begin
            $display("%d tests completed with %d errors",
            vectornum, errors);
            $finish;
        end
    end
endmodule
