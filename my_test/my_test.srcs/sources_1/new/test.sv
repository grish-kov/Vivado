`timescale 1ns / 1ps
module test
   (
    input	[3:0]	x, // Вход
	input	[1:0]	a, // Управление
	output		f // Выход
    );
         
    assign f = x[a];
endmodule