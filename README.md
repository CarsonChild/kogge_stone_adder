# Kogge-Stone Adder
This project is a SystemVerilog implementation of a parametric Kogge-Stone Adder. The module accepts two busses, A and B of N-bit length and Cin (carry-in), as input and outputs to bus S of N-bit length their sum and the carry-out to Cout. This module has been tested with N as 4, 8, 16, and 32 bits. The behaviour when log2(N) is not an integer is untested. 
