/*
 ----------------------------------------------------------------------------
Company:    UFABC - Engenharia de Informação - CECS
Engineer:   João Garrido
  
Design Name:    Eletrônica Digital (ESTI002-17)
Module Name:    tb_edo_fsmd.v
Language:       Verilog
  
Descrição: This is the code for the last project of the laboratory subject.
-----------------------------------------------------------------------------
*/

module edo_fsmd
  (  
	input reset,clk,
	input stop, 
	input go,
	input signed [15:0] Yin, Xin,
	input signed [15:0] Kmul, Kdiv,
	output reg done,
	output reg busy, 
	output reg signed [15:0] Yres
  );


	reg signed [15:0] X,Y;
	
	reg signed [31:0] op0,op1,op2,op3,op4,op5,op6; // arithmetic ops.
	reg signed [15:0] IM1,IM2,IM3,IM4; // wires (multiplication correction)

  integer loop;
  reg [4:0] estado;
  parameter Sreset=0, 
  Sloop=1, 
  stateops1=2, 
  stateops2=3, 
  stateops3=4, 
  stateops4=5, 
  stateops5 = 6,
  Steste=7, 
  Sf=8; 

  // fsm
  
	always@(posedge clk or posedge reset)
		begin 
			if(reset)
				estado <= Sreset;
			else
				case(estado)	
					Sreset:
						estado <= Sloop;
					Sloop:
						if(go) 
						estado <= stateops1;
						else 
						estado <= Sloop;
					stateops1:
						estado <=stateops2;
					stateops2:
						estado <=stateops3;
					stateops3:
						estado <=stateops4;
					stateops4:
						estado <=Steste;
					Steste:
					 if(stop) 
						estado <= Sf;
					 else 
						estado <= Sloop;
					Sf:
						estado <= Sf;
			endcase
		end
		
	always@(estado)
		begin 
			case(estado)
				Sreset:
					begin
						busy = 0;
						done = 0;
					end
				Sloop:
					begin 
						busy = 0;
						done = 0;
					end
				stateops1:
					begin 
						busy = 1;
						done = 0;
					end
				stateops2:
					begin 
						busy = 1;
						done = 0;
					end
				stateops3:
					begin 
						busy = 1;
						done = 0;
					end
				stateops4:
					begin 
						busy = 1;
						done = 0;
					end
				Steste:
					begin 
						busy = 0;
						done = 0;
					end
				Sf:
					begin 
						busy = 0;
						done = 1;
					end
			endcase
		end

		

// circuit

reg signed [15:0] Km, Kd;
	always @(posedge clk or posedge reset)
		begin 
			case(estado)
				Sreset:
					begin
						Kd <= Kdiv;
						Km <= Kmul;
						Yres <= Yin;
						loop <= 0;
					end
				Sloop:
					begin 
						X <= Xin; 
					end
				stateops1:
					begin
						op0 <= Yres * Yres >>> 8; 
						op1 <= X * X >>> 8;
					end
				stateops2:
					begin 
						op3 <= (Km * op0 >>> 8);
						op4 <= op1 * Kd;
						 
					end
				stateops3:
					begin 
						op5 <= op3 + X;
						op6 <= Yres;
					end
				stateops4:
					begin
						if (loop != 0)
						  Yres <= op6 + op5 - op4;
						else
							Yres <= Yres;
						loop <= 1+loop; // iter through 
					end
			endcase
		end
endmodule
