`timescale 1ns / 1ps

module precomputation(input a, b,
    output p,g);

    assign p = a ^ b;
    assign g = a & b;

endmodule

module black_block(input logic p_ik, p_kj, g_ik, g_kj,
    output logic p_ij, g_ij);

    assign p_ij = p_ik & p_kj;
    assign g_ij = g_ik | (p_ik & g_kj);

endmodule

module gray_block(input logic p_ik, g_ik, g_kj,
    output logic g_ij);

    assign g_ij = g_ik | (p_ik & g_kj);

endmodule

module sum(input logic p, g_prev,
    output logic s);

    assign s = p ^ g_prev;

endmodule

module ksa #(parameter N = 4)
(input logic [N-1:0] a, b,
    input logic cin,
    output logic [N-1:0] s,
    output logic cout);
    
    logic [$clog2(N) + 1:0][N-1:0] p, g;
    
    generate
        for(genvar r = 0; r < $clog2(N) + 2; r++) begin: row_ops 
            for(genvar i = N - 1; i >= 0; i--) begin: block_ops
                if(r == 0) begin //precomputations for p and g
                    precomputation pre(
                        .a (a[i]),
                        .b (b[i]),
                        .p (p[r][i]),
                        .g (g[r][i])
                    );
                end
                else if(r != $clog2(N) + 1) begin //block logic
                    if(i >= (2 * (2**(r-1))) - 1) begin //black boxes
                        black_block bb(
                            .p_ik (p[r-1][i]),
                            .p_kj (p[r-1][i-2**(r-1)]),
                            .g_ik (g[r-1][i]),
                            .g_kj (g[r-1][i-2**(r-1)]),
                            .p_ij (p[r][i]),
                            .g_ij (g[r][i])
                        );
                    end
                    else if(i >= 2**(r-1) - 1) begin //gray boxes
                        gray_block gb(
                            .p_ik (p[r-1][i]),
                            .g_ik (g[r-1][i]),
                            .g_kj (i == 2**(r-1) - 1 ? cin : g[r-1][i-2**(r-1)]), //the g it connects to is Cin
                            .g_ij (g[r][i])
                        );
                        assign p[r][i] = p[r-1][i];
                    end
                    else begin //connect wire to itself for simplicity
                        assign g[r][i] = g[r-1][i];
                        assign p[r][i] = p[r-1][i];
                    end 
                end
                else begin //sum logic
                    sum s(
                        .p (p[0][i]),
                        .g_prev (i == 0 ? cin : g[r-1][i-1]),
                        .s (s[i])
                    );
                end
            end
        end
    endgenerate
    assign cout = g[$clog2(N)][N-1] | (p[$clog2(N)][N-1] & cin);
endmodule

