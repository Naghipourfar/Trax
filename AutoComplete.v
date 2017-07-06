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


module AutoComplete(output reg is_table_changed, output reg[2:0] out_cell, input[2:0] up_cell, right_cell, down_cell, left_cell, curr_cell, input[9:0] i, j, n, m);

	reg [1:0] upcolor, rightcolor, downcolor, leftcolor;
	integer cnt;


	always @(*) begin
		out_cell = curr_cell;
		cnt = 3'b0;
		upcolor <= `nocolor;
		downcolor <= `nocolor;
		rightcolor <= `nocolor;
		leftcolor <= `nocolor;
		is_table_changed <= 1'b0;
		if(out_cell == `empty) begin
			cnt = 3'b0;
			upcolor <= `nocolor;
			downcolor <= `nocolor;
			rightcolor <= `nocolor;
			leftcolor <= `nocolor;
			is_table_changed <= 1'b0;
			if(i > 0) begin
				if(down_cell != `empty) begin
					cnt = cnt + 1'b1;
					if (down_cell[2:1] == `plus)
						upcolor <= {1'b0, down_cell[0]};
					else
						upcolor <= {1'b0, ~down_cell[0]};
				end
				else begin
					cnt = cnt + 1'b0;
					upcolor <= `nocolor;
				end
			end
			else begin
				cnt = cnt + 1'b0;
				upcolor <= `nocolor;
			end
				
		
			if(i < n-1 && i<`MAX_ROW-1) begin
				if(up_cell != `empty) begin
					cnt = cnt + 1'b1;
					downcolor <= {1'b0, up_cell[0]};
				end
				else begin
					cnt = cnt + 1'b0;
					downcolor <= `nocolor;
				end
			end
			else begin
				cnt = cnt + 1'b0;
				downcolor <= `nocolor;
			end
		
			if(j > 0) begin
				if(left_cell != `empty) begin
					cnt = cnt + 1'b1;
					if(left_cell[2:1] == `bslash)
						leftcolor <= {1'b0, left_cell[0]};
					else
						leftcolor <= {1'b0, ~left_cell[0]};
				end
				else begin
					cnt = cnt + 1'b0;
					leftcolor <= `nocolor;
				end
			end
			begin
				cnt = cnt + 1'b0;
				leftcolor <= `nocolor;
			end		
			
			if(j < m-1 && j < `MAX_COL-1) begin
				if(right_cell != `empty) begin
					cnt = cnt + 1'b1;
					if(right_cell[2:1] == `slash)
						rightcolor <= {1'b0, right_cell[0]};
					else
						rightcolor <= {1'b0, ~right_cell[0]};
				end	
				else begin
					cnt = cnt + 1'b0;
					rightcolor <= `nocolor;
				end
			end	
			else begin
				cnt = cnt + 1'b0;
				rightcolor <= `nocolor;
			end
			
			// now cnt is the number of non empty adjacent cells
			
			if(cnt == 3'd2) begin
				if(upcolor != `nocolor) begin
					if(upcolor == rightcolor) begin
						out_cell <= {`bslash, upcolor[0]};
						is_table_changed <= 1'b1;
					end

					else if(upcolor == downcolor) begin
						out_cell <= {`plus, upcolor[0]};
						is_table_changed <= 1'b1;
					end

					else if(upcolor == leftcolor) begin
						out_cell <= {`slash, upcolor[0]};
						is_table_changed <= 1'b1;
					end
					else begin
						out_cell <= curr_cell;
						is_table_changed <= 1'b0;
					end
				end
				else if(rightcolor != `nocolor) begin
					if(rightcolor == downcolor) begin
						out_cell <= {`slash, ~rightcolor[0]};
						is_table_changed <= 1'b1;
					end
					
					else if(rightcolor == leftcolor) begin
						out_cell <= {`plus, ~rightcolor[0]};
						is_table_changed <= 1'b1;
					end	
					else begin
						out_cell <= curr_cell;
						is_table_changed <= 1'b0;
					end
				end
				else begin
					if(downcolor == leftcolor) begin
						out_cell <= {`bslash, ~downcolor[0]};
						is_table_changed <= 1'b1;
					end	
					else begin
						out_cell <= curr_cell;
						is_table_changed <= 1'b0;
					end
				end
			end
			else begin
				out_cell <= curr_cell;
				is_table_changed <= 1'b0;
			end
		end
		else begin
			cnt = 3'b0;
			upcolor <= `nocolor;
			downcolor <= `nocolor;
			rightcolor <= `nocolor;
			leftcolor <= `nocolor;
			is_table_changed <= 1'b0;
			// The Current Cell is not Empty So we have nothing to do
		end
	end
endmodule
