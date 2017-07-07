/****************************************************************************
			   In The Name of God								                  *
 ****************************************************************************/

`define MAX_ROW 10'd20
`define MAX_COL 10'd20
`define MAX_VALID_MOVES 203
`define empty 3'b000
`define nocolor 2'b11
`define plus 2'b01
`define slash 2'b10
`define bslash 2'b11
`define black 1
`define white 0

module Trax(output tx, input rx, clk, reset);
	
	reg auto_complete_sig;
	reg choose_move_sig;
	reg update_copy_map_sig;
	reg copy_to_map_sig;
	reg shift_right_sig;
	reg shift_down_sig;

	reg auto_complete_sig_done;
	reg choose_move_sig_done;
	reg update_copy_map_sig_done;
	reg copy_to_map_sig_done;
	reg shift_right_sig_done;
	reg shift_down_sig_done;


	reg is_table_changed;
	reg work_step_done;

	wire end_receive, color;
	wire [21:0] move_out;
	reg [21:0] move_in;
	reg [21:0] move;
	reg start_transmit;
	reg [2:0] game_table[`MAX_ROW - 1:0][`MAX_COL - 1:0];
	reg [2:0] game_table_copy[`MAX_ROW - 1:0][`MAX_COL - 1:0];
	reg [21:0] valid_moves [`MAX_VALID_MOVES - 1:0];
	wire [21:0] update_valid_move_0, update_valid_move_1, update_valid_move_2;
	integer i, j;
	integer shift_down_i, shift_down_j;
	integer shift_right_i, shift_right_j;
	reg[9:0] n, m; // number of rows, number of columns, number of valid moves 
	reg [9:0] k;
	wire [9:0] update_valid_move_k;
	integer round;
	integer r, c;
	integer step;
	reg a[1:0];
	wire auto_complete_is_table_changed;
	wire [2:0] auto_complete_out_cell;

	reg [2:0] auto_complete_up_cell, auto_complete_right_cell, auto_complete_down_cell, auto_complete_left_cell;
	reg [2:0] update_valid_move_up_cell, update_valid_move_right_cell, update_valid_move_down_cell, update_valid_move_left_cell;
	
	Tranceiver t(move_out, end_receive, color, tx, move_in, rx, start_transmit, clk, reset);
	AutoComplete ac(auto_complete_is_table_changed, auto_complete_out_cell, auto_complete_up_cell, auto_complete_right_cell, auto_complete_down_cell, auto_complete_left_cell, game_table_copy[i][j], i, j, n, m);
	UpdateValidMove uvm(update_valid_move_0, update_valid_move_1, update_valid_move_2, update_valid_move_k, update_valid_move_up_cell, update_valid_move_right_cell, update_valid_move_down_cell, update_valid_move_left_cell, r, c, k, n, m);  

	reg prev_end_receive;
	reg next_end_receive;

	reg flag1, flag2, flag3, flag4;

/*	generate
		for(i=0;i<`MAX_ROW;i=i+1) begin
			for(j=0;j<`MAX_COL;j=j+1) begin
		  		game_table[i][j] <= `empty;
				game_table_copy[i][j] <= `empty;
			end
	  	end
	endgenerate	

	generate
		for(i=0;i<`MAX_VALID_MOVES;i=i+1) begin
		  	valid_moves[i] <= 21'b0;
	  	end
	endgenerate
*/

	always @(posedge clk) begin
		if (reset) begin
			auto_complete_sig <= 1'b0;
			choose_move_sig <= 1'b0;
			update_copy_map_sig <= 1'b0;
			copy_to_map_sig <= 1'b0;

			prev_end_receive <= 1'b0;
			next_end_receive <= 1'b0;

			auto_complete_sig_done <= 1'b0;
			choose_move_sig_done <= 1'b0;
			update_copy_map_sig_done <= 1'b0;
			copy_to_map_sig_done <= 1'b0;

			work_step_done <= 1'b0;
			is_table_changed <= 1'b0;

			move_in <= 22'b0;
			start_transmit <= 1'b0;
			for(i=0;i<`MAX_ROW;i=i+1) begin
				 for(j=0;j<`MAX_COL;j=j+1) begin
			  		game_table[i][j] <= `empty;
					game_table_copy[i][j] <= `empty;
				end
		  	end
		  	for(i=0;i<`MAX_VALID_MOVES;i=i+1) begin
			  	valid_moves[i] <= 21'b0;
		  	end
		  	step <= 0;
		  	m <= 1;
		  	k <= 0;
		  	round <= 0;
		  	n <= 1;
		end
		else if (auto_complete_sig) begin
			if (i <= n - 1 && j < m - 1) begin
				j = j + 1;
				auto_complete_up_cell = (i > 0) ? game_table_copy[i - 1][j] : 3'b000;
				auto_complete_right_cell = (j <= m - 2) ? game_table_copy[i][j + 1] : 3'b000;
				auto_complete_down_cell = (i <= n - 2) ? game_table_copy[i + 1][j] : 3'b000;
				auto_complete_left_cell = (j > 0) ? game_table_copy[i][j - 1] : 3'b000;
			end
			else if (i <= n - 1 && j >= m - 1) begin
				i = i + 1;
				j = 0;
				auto_complete_up_cell = (i > 0) ? game_table_copy[i - 1][j] : 3'b000;
				auto_complete_right_cell = (j <= m - 2) ? game_table_copy[i][j + 1] : 3'b000;
				auto_complete_down_cell = (i <= n - 2) ? game_table_copy[i + 1][j] : 3'b000;
				auto_complete_left_cell = (j > 0) ? game_table_copy[i][j - 1] : 3'b000;
			end
			else begin	// Auto Complete is Done!
				i = 0;
				j = -1;
				if (is_table_changed) begin
					auto_complete_sig = 1'b1;
					auto_complete_sig_done = 1'b0;
					update_copy_map_sig_done = 1'b0;
				end
				else begin
					auto_complete_sig_done = 1'b1;
					update_copy_map_sig_done = 1'b1;
					auto_complete_sig = 1'b0;
				end
			end
			if (auto_complete_is_table_changed == 1'b1) begin
				is_table_changed <= is_table_changed || auto_complete_is_table_changed;
				game_table_copy[i][j] = auto_complete_out_cell;
			end
		end
		else if (choose_move_sig) begin
			if (r <= n - 1 && c < m - 1) begin
				c = c + 1;
				update_valid_move_up_cell = (r > 0) ? game_table[r - 1][c] : 3'b000;
				update_valid_move_right_cell = (c <= m - 2) ? game_table[r][c + 1] : 3'b000;
				update_valid_move_down_cell = (r <= n - 2) ? game_table[r + 1][c] : 3'b000;
				update_valid_move_left_cell = (c > 0) ? game_table[r][c - 1] : 3'b000;
			end
			else if (r <= n - 1 && c >= m - 1) begin
				r = r + 1;
				c = 0;
				update_valid_move_up_cell = (r > 0) ? game_table[r - 1][c] : 3'b000;
				update_valid_move_right_cell = (c <= m - 2) ? game_table[r][c + 1] : 3'b000;
				update_valid_move_down_cell = (r <= n - 2) ? game_table[r + 1][c] : 3'b000;
				update_valid_move_left_cell = (c > 0) ? game_table[r][c - 1] : 3'b000;
			end
			else begin	// Choose Move is Done!
				r = 0;
				c = -1;
				choose_move_sig = 1'b0;
				choose_move_sig_done = 1'b1;
			end 
			if (k != update_valid_move_k) begin
				if (update_valid_move_0 !== 22'bx) begin
					valid_moves[k] = update_valid_move_0;
				end
				if (update_valid_move_1 !== 22'bx) begin
					valid_moves[k+1] = update_valid_move_1;
				end
				if (update_valid_move_2 !== 22'bx) begin
					valid_moves[k+2] = update_valid_move_2;
				end
				k = update_valid_move_k;
			end
		end
		else if (update_copy_map_sig) begin
			if (i <= n - 1 && j < m - 1) begin
				j = j + 1;
				game_table_copy[i][j] = game_table[i][j];
			end
			else if (i <= n - 1 && j >= m - 1) begin
				i = i + 1;
				j = 0;
				game_table_copy[i][j] = game_table[i][j];
			end
			else begin
				i = 0;
				j = -1;
				r = move[9:0];
				c = move[19:10];
				game_table_copy[r][c][2:1] = move[21:20];

				// update from up
				if (r > 0) begin
					if (game_table_copy[r-1][c] != `empty) begin
						if(game_table_copy[r-1][c][2:1] == `plus)
							game_table_copy[r][c][0] = game_table_copy[r-1][c][0]; 
						else
							game_table_copy[r][c][0] = ~game_table_copy[r-1][c][0];
					end
				end
				// update from down
				if(r < n-1 && r < `MAX_ROW-1) begin
					if(game_table_copy[r+1][c] != `empty) begin
						if(game_table_copy[r][c][2:1] == `plus)
							game_table_copy[r][c][0] = game_table_copy[r+1][c][0];
						else
							game_table_copy[r][c][0] = ~game_table_copy[r+1][c][0];
					end
				end
				
				// update from left
				if(c > 0) begin
					if(game_table_copy[r][c-1] != `empty) begin
						if( (game_table_copy[r][c-1][2:1] != `bslash && game_table_copy[r][c][2:1] != `slash) ||
							(game_table_copy[r][c-1][2:1] == `bslash && game_table_copy[r][c][2:1] == `slash) )
							game_table_copy[r][c][0] = game_table_copy[r][c-1][0];
						else
							game_table_copy[r][c][0] = ~game_table_copy[r][c-1][0];
					end
				end

				// update from right
				if(c < m-1 && c < `MAX_COL-1) begin
					if(game_table_copy[r][c+1] != `empty) begin
						if( (game_table_copy[r][c+1][2:1] != `slash && game_table_copy[r][c][2:1] != `bslash) ||
							(game_table_copy[r][c+1][2:1] == `slash && game_table_copy[r][c][2:1] == `bslash) )
							game_table_copy[r][c][0] = game_table_copy[r][c+1][0];
						else
							game_table_copy[r][c][0] = ~game_table_copy[r][c+1][0];
					end
				end
				
				// first move
				if(n == 1'b1 && m == 1'b1) begin
					game_table_copy[r][c][0] = `white;
				end

				update_copy_map_sig = 1'b0;
				auto_complete_sig = 1'b1;	// Call Auto Complete Function
			end
		end
		else if (copy_to_map_sig) begin
		  	if (i <= n - 1 && j < m - 1) begin
				j = j + 1;
				game_table[i][j] = game_table_copy[i][j];
				if (n < `MAX_ROW)
					if(game_table_copy[n-1][j] != `empty)
						flag1 = 1'b1;
				if (m < `MAX_COL)
					if(game_table_copy[i][m-1] != `empty)
						flag2 = 1'b1;	
				if(game_table_copy[0][j] != `empty)
					flag3 = 1'b1;
				if(game_table_copy[i][0] != `empty)
					flag4 = 1'b1;	
			end
			else if (i <= n - 1 && j >= m - 1) begin
				i = i + 1;
				j = 0;
				game_table[i][j] = game_table_copy[i][j];
				if (n < `MAX_ROW)
					if(game_table_copy[n-1][j] != `empty)
						flag1 = 1'b1;
				if (m < `MAX_COL)
					if(game_table_copy[i][m-1] != `empty)
						flag2 = 1'b1;	
				if(game_table_copy[0][j] != `empty)
					flag3 = 1'b1;	
				if(game_table_copy[i][0] != `empty)
					flag4 = 1'b1;	
			end
			else begin
				i = 0;
				j = -1;
				// All of this 4 functions for first move and one of them for other moves
				if(flag1 == 1'b1)
					n = n+1;
				
				if(flag2 == 1'b1)
					m = m+1; 
				
				if(flag3 == 1'b1) begin			// Shift Down
					shift_down_i = n - 2;
					shift_down_j = -1;
					shift_down_sig = 1'b1;
				end
				if(flag4 == 1'b1) begin			// Shift Right
					shift_right_i = 0;
					shift_right_j = m - 1;
					shift_right_sig = 1'b1;
				end
				if(n > `MAX_ROW)
					n = `MAX_ROW;
					
				if(m > `MAX_COL)
					m = `MAX_COL;
			end	
			copy_to_map_sig = 1'b0;
			copy_to_map_sig_done = 1'b1;
			// now game_table is updated and n & m are updated too. 					
		end
		else if (shift_down_sig) begin
			if (shift_down_i >= 0 && shift_down_j < m - 1) begin
				shift_down_j = shift_down_j + 1;
				if(shift_down_i < n && shift_down_j < m) begin
					game_table[shift_down_i+1][shift_down_j] = game_table[shift_down_i][shift_down_j];
				end
			end
			else if (shift_down_i >= 0 && shift_down_j >= m - 1) begin
				shift_down_i = shift_down_i - 1;
				shift_down_j = 0;
				if(shift_down_i < n && shift_down_j < m && shift_down_i >= 0) begin
					game_table[shift_down_i+1][shift_down_j] = game_table[shift_down_i][shift_down_j];
				end
				j = -1;
			end
			else begin
				if (j <= m - 1) begin
					j = j + 1;
					game_table[0][j] = `empty;
				end
				else begin
					n = n + 1'b1;
					shift_down_sig = 1'b0;
					shift_down_sig_done = 1'b1;
				end
			end
		end
		else if (shift_right_sig) begin
			if (shift_right_i <= n - 1 && shift_right_j >= 0) begin
				shift_right_j = shift_right_j - 1;
				if(shift_right_i < n && shift_right_j < m && shift_right_j >= 0) begin
					game_table[shift_right_i][shift_right_j+1] = game_table[shift_right_i][shift_right_j];
				end
			end
			else if (shift_right_i <= n - 1 && shift_right_j < 0) begin
				shift_right_i = shift_right_i + 1;
				shift_right_j = m - 1;
				if(shift_right_i < n && shift_right_j < m) begin
					game_table[shift_right_i][shift_right_j+1] = game_table[shift_right_i][shift_right_j];
				end
				i = -1;
			end
			else begin
				if (i <= n - 1) begin
					i = i + 1;
					game_table[i][0] <= `empty;
				end
				else begin 
					m = m + 1'b1;
					shift_right_sig = 1'b0;
					shift_right_sig_done = 1'b1;
				end
			end
		end
		else begin
			prev_end_receive <= next_end_receive;
			next_end_receive <= end_receive;
		
			if (start_transmit == 1'b1) begin
				start_transmit <= 1'b0;
			end
			if (prev_end_receive == 0 && next_end_receive == 1) begin
				round = round + 1;
				move <= move_out;
				if (round == 1'b1) begin
					if(color == `white) begin
						k = 2;
						valid_moves[0] = {`plus, 10'b0, 10'b0 };
						valid_moves[1] = {`slash, 10'b0, 10'b0 };
						move_in = valid_moves[0];
						move <= move_in;
					 	update_copy_map_sig <= 1'b1;
					 	copy_to_map_sig <= 1'b1;
					 	start_transmit <= 1'b1;
				 	end  
				end
				else begin
					work_step_done <= 1'b0;
				end
			end
			else if (~(prev_end_receive == 0 && next_end_receive == 1) && work_step_done == 1'b0) begin // Data Received!
				if (step == 0) begin
					move <= move_out;
					update_copy_map_sig <= 1'b1;
					step = step + 1;
				end
				else if (step == 1 && update_copy_map_sig_done) begin
					update_copy_map_sig_done <= 1'b0;
					copy_to_map_sig <= 1'b1;
					flag1 = 1'b0;
					flag2 = 1'b0;
		  			flag3 = 1'b0;
				  	flag4 = 1'b0;
					step = step + 1;
				end
				else if (step == 2 && copy_to_map_sig_done) begin
					copy_to_map_sig_done <= 1'b0;
					choose_move_sig <= 1'b1;
					step = step + 1;
				end
				else if (step == 3 && choose_move_sig_done) begin
					choose_move_sig_done <= 1'b0;
					move = valid_moves[0];
					update_copy_map_sig <= 1'b1;
					step = step + 1;
				end
				else if (step == 4 && update_copy_map_sig_done) begin
					update_copy_map_sig_done = 1'b0;
					copy_to_map_sig = 1'b1;
					flag1 = 1'b0;
					flag2 = 1'b0;
		  			flag3 = 1'b0;
				  	flag4 = 1'b0;
					step = step + 1;
				end
				else begin
					copy_to_map_sig_done <= 1'b0;
					start_transmit <= 1'b1;
					work_step_done <= 1'b1;
					step = 0;
				end
			end
			else begin

			end
		end
	end



endmodule
