`define MAX_ROW 10'd50
`define MAX_COL 10'd50
`define MAX_VALID_MOVES 203
`define empty 3'b000
`define nocolor 2'b11
`define plus 2'b01
`define slash 2'b10
`define bslash 2'b11
`define black 1
`define white 0



module UpdateValidMove(output reg[21:0] valid_moves_0, valid_moves_1, valid_moves_2, output reg [8-1:0] k, input[2:0] up_cell, right_cell, down_cell, left_cell, input[9:0] r, c, input [8-1:0] k_in, input [9:0] m, n);
	parameter integer MAX_K_BITS = 8;
	integer cnt;
	reg up, down, left, right;
	reg [9:0] mraw, mcol;

	always @(*) begin
		cnt = 3'b0;
		up = 1'b0;
		down = 1'b0;
		left = 1'b0;
		right = 1'b0;
		valid_moves_0 = 22'bx;
		valid_moves_1 = 22'bx;
		valid_moves_2 = 22'bx;

		mraw = r;
		mcol = c;
		k = k_in;
		
		if(r > 0) begin
			if(up_cell != `empty) begin
				cnt = cnt + 1'b1;
				up = 1'b1;
			end	
			else begin
				cnt = cnt + 1'b0;
				up = 1'b0;
			end
		end
							
					
		if(r < n-1 && r < `MAX_ROW-1) begin
			if(down_cell != `empty) begin
				cnt = cnt + 1'b1;
				down = 1'b1;
			end	
			else begin
				cnt = cnt + 1'b0;
				down = 1'b0;
			end
		end
					
		if(c > 0) begin
			if(left_cell != `empty) begin
				cnt = cnt + 1'b1;
				left = 1'b1;
			end
			else begin
				cnt = cnt + 1'b0;
				left = 1'b0;
			end
		end		
						
		if(c < m-1 && c<`MAX_COL-1) begin
			if(right_cell != `empty) begin
				cnt = cnt + 1'b1;
				right = 1'b1;
			end
			else begin
				cnt = cnt + 1'b0;
				right = 1'b0;
			end
		end

		// now cnt is the number of non empty adjacent cells

		if(cnt == 3'd1) begin
			valid_moves_0 = {`plus, mcol, mraw}; 
			valid_moves_1 = {`slash, mcol, mraw};
			valid_moves_2 = {`bslash, mcol, mraw};
			k = k + 2'b11;
		end

		else if(cnt == 3'd2) begin
			if(up == 1'b1) begin
				if(right == 1'b1) begin
					valid_moves_0 = {`plus, mcol, mraw}; 
					valid_moves_1 = {`slash, mcol, mraw};
					k = k + 2'b11;
				end
				else if(down == 1'b1) begin
					valid_moves_0 = {`bslash, mcol, mraw}; 
					valid_moves_1 = {`slash, mcol, mraw};
					k = k + 2'b10;
				end
				else if(left == 1'b1) begin
					valid_moves_0 = {`plus, mcol, mraw}; 
					valid_moves_1 = {`bslash, mcol, mraw};
					k = k + 2'b10;
				end
				else begin
					valid_moves_0 = 22'bx;
					valid_moves_1 = 22'bx;
					k = k + 2'b00;
				end
			end
			else if(right == 1'b1) begin
				if(down == 1'b1) begin
					valid_moves_0 = {`plus, mcol, mraw}; 
					valid_moves_1 = {`bslash, mcol, mraw};
					k = k + 2'b10;
				end
				else if(left == 1'b1) begin
					valid_moves_0 = {`bslash, mcol, mraw}; 
					valid_moves_1 = {`slash, mcol, mraw};
					k = k + 2'b11;
				end
				else begin
					valid_moves_0 = 22'bx;
					valid_moves_1 = 22'bx;
					k = k + 2'b00;
				end
			end
			else begin
				valid_moves_0 = {`plus, mcol, mraw}; 
				valid_moves_1 = {`slash, mcol, mraw};
				k = k + 2'b10;
			end
		end
		else begin
			valid_moves_0 = 22'bx;
			valid_moves_1 = 22'bx;
			valid_moves_2 = 22'bx;
			k = k + 2'b00;
		end
	end

endmodule