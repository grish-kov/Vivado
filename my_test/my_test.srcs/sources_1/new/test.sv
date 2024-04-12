`timescale 1ns / 1ps
module test
   (
    input	[3:0]	i_x, // Вход
	input	[1:0]	i_a, // Управление
	output		o_f // Выход
    );
         
    assign o_f = i_x[i_a];
endmodule