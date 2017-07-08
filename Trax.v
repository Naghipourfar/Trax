/****************************************************************************
			   				In The Name of God								                  
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
	wire end_receive, color;
	wire [21:0] move_out;
	reg [21:0] move_in;
	reg start_transmit;
	reg [2:0] game_table[`MAX_ROW - 1:0][`MAX_COL - 1:0];
	reg [2:0] game_table_copy[`MAX_ROW - 1:0][`MAX_COL - 1:0];
	reg [21:0] valid_moves [`MAX_VALID_MOVES - 1:0];
	integer i, j;
	integer n, m, k; // number of rows, number of columns, number of valid moves 
	integer round; 
	reg a[1:0];
	
	Tranceiver t(move_out, end_receive, color, tx, move_in, rx, start_transmit, clk, reset);
	  
	reg prev_end_receive;
	reg next_end_receive;


	  
	always @(posedge clk) begin
		if(reset) begin
		  prev_end_receive = 1'b1;
		  next_end_receive = 1'b1;
		  move_in = 22'b0;
		  start_transmit = 1'b0;
		  for(i=0;i<`MAX_ROW;i=i+1) begin
			for(j=0;j<`MAX_COL;j=j+1) begin
			  game_table[i][j] = `empty;
			  game_table_copy[i][j] = `empty;
			end
		  end
		  for(i=0;i<`MAX_VALID_MOVES;i=i+1) begin
			  valid_moves[i] = 21'b0;
		  end
		  m = 1; n = 1; k = 0;
		  round = 0;
		end
	
		prev_end_receive = next_end_receive;
		next_end_receive = end_receive;
	
		if(start_transmit == 1'b1)
		  start_transmit = 1'b0;
	
		if (prev_end_receive == 0 && next_end_receive == 1) begin // Start Receiving
		  round = round + 1;
	
		  if (round == 1'b1) begin
			 if(color == `white)
			 begin
				  if (a[0] === 1'bx) a[0] = 1'bx;
				  chooseFirstMove(move_in);
				  updateCopyMap(move_in);
				  copyToMap();
				  start_transmit = 1'b1;
			 end  
		  end	 
		  else begin
			updateCopyMap(move_out);
			if (a[0] === 1'bx) a[0] = 1'bx;
			copyToMap();
			if (a[0] === 1'bx) a[0] = 1'bx;
			chooseMove(move_in);
			if (a[0] === 1'bx) a[0] = 1'bx;
			updateCopyMap(move_in);
			if (a[0] === 1'bx) a[0] = 1'bx;
			copyToMap();
			if (a[0] === 1'bx) a[0] = 1'bx;
			start_transmit = 1'b1;
		  end
		end
	end
	






	task copyToMap();
	integer i, j;
	reg flag1, flag2, flag3, flag4;
	begin
	  flag1 = 1'b0;
	  flag2 = 1'b0;
	  flag3 = 1'b0;
	  flag4 = 1'b0;
		for(i=0; i<n && i<`MAX_ROW; i=i+1)
			for(j=0; j<m && j<`MAX_COL; j=j+1)
				game_table[i][j] = game_table_copy[i][j];
				
		for(j=0; j<m && j<`MAX_COL; j=j+1)
			if(n < `MAX_ROW)
			if(game_table[n-1][j] != `empty)
				flag1 = 1'b1;
				
		for(i=0; i<n && i<`MAX_ROW; i=i+1)
			if(m < `MAX_COL)
			if(game_table[i][m-1] != `empty)
				flag2 = 1'b1;	
				
		for(j=0; j<m && j<`MAX_COL; j=j+1)
			if(game_table[0][j] != `empty)
				flag3 = 1'b1;	
				
		for(i=0; i<n && i<`MAX_ROW; i=i+1)
			if(game_table[i][0] != `empty)
				flag4 = 1'b1;	
				
		// All of this 4 functions for first move and one of them for other moves
		if(flag1 == 1'b1)
			n = n+1;
		
		if(flag2 == 1'b1)
			m = m+1; 
		
		if(flag3 == 1'b1)
			shift_down();
			
		if(flag4 == 1'b1)
			shift_right();	
		
		if(n > `MAX_ROW)
			n = `MAX_ROW;
			
		if(m > `MAX_COL)
			m = `MAX_COL;
			
		// now game_table is updated and n & m are updated too. 					
	end
	endtask
	
	task shift_down();
	integer i, j;
	begin
		for(i=`MAX_ROW-2; i>=0; i=i-1)
			for(j=0; j<m && j<`MAX_COL; j=j+1)
				if(i < `MAX_ROW && j < `MAX_COL)
					game_table[i+1][j] = game_table[i][j]; 
				
		for(j=0; j<m && j<`MAX_COL; j=j+1)
			game_table[0][j] = `empty;
			
		n = n+1;
	end
	endtask
	
	task shift_right();
	integer i, j;
	begin
		for(i=0; i<n && i<`MAX_ROW; i=i+1)
			for(j=`MAX_COL-2; j>=0; j=j-1)
				if(i < `MAX_ROW && j < `MAX_COL)
					game_table[i][j+1] = game_table[i][j];
				
		for(i=0; i<n && i<`MAX_ROW; i=i+1)
			game_table[i][0] = `empty; 
			
		m = m+1;
	end
	endtask	
	
	task updateCopyMap(input[21:0] move);
	integer r, c;
	integer i, j;
	begin
		
	
		for(i=0; i<n && i<`MAX_ROW; i=i+1)
			for(j=0; j<m && j<`MAX_COL; j=j+1)
				game_table_copy[i][j] = game_table[i][j];
				
					
		r = move[9:0];
		c = move[19:10];
		game_table_copy[r][c][2:1] = move[21:20];
		
		
		// update from up
		if(r > 0)
		if(game_table_copy[r-1][c] != `empty)
		begin
			if(game_table_copy[r-1][c][2:1] == `plus)
				game_table_copy[r][c][0] = game_table_copy[r-1][c][0]; 
			else
				game_table_copy[r][c][0] = ~game_table_copy[r-1][c][0];
		end
		
		// update from down
		if(r < n-1 && r < `MAX_ROW-1)
		if(game_table_copy[r+1][c] != `empty)
		begin
			if(game_table_copy[r][c][2:1] == `plus)
				game_table_copy[r][c][0] = game_table_copy[r+1][c][0];
			else
				game_table_copy[r][c][0] = ~game_table_copy[r+1][c][0];
		end
		
		// update from left
		if(c > 0)
		if(game_table_copy[r][c-1] != `empty)
		begin
			if( (game_table_copy[r][c-1][2:1] != `bslash && game_table_copy[r][c][2:1] != `slash) ||
				(game_table_copy[r][c-1][2:1] == `bslash && game_table_copy[r][c][2:1] == `slash) )
				game_table_copy[r][c][0] = game_table_copy[r][c-1][0];
			else
				game_table_copy[r][c][0] = ~game_table_copy[r][c-1][0];
		end

		// update from right
		if(c < m-1 && c < `MAX_COL-1)
		if(game_table_copy[r][c+1] != `empty)
		begin
			if( (game_table_copy[r][c+1][2:1] != `slash && game_table_copy[r][c][2:1] != `bslash) ||
				(game_table_copy[r][c+1][2:1] == `slash && game_table_copy[r][c][2:1] == `bslash) )
				game_table_copy[r][c][0] = game_table_copy[r][c+1][0];
			else
				game_table_copy[r][c][0] = ~game_table_copy[r][c+1][0];
		end
		
		// first move
		if(n == 1'b1 && m == 1'b1)
		begin
			game_table_copy[r][c][0] = `white;
		end
		
		
		auto_complete();
		
		

	end
	endtask
	
	task auto_complete();
	integer i, j, cnt;
	reg[1:0] upcolor, downcolor, rightcolor, leftcolor;
	reg is_table_changed;
	begin
		is_table_changed = 1'b1;
		
		while(is_table_changed == 1'b1)
		begin
			if (a[0] === 1'bx) a[0] = 1'bx;
			is_table_changed = 1'b0;
			for(i=0; i<n && i<`MAX_ROW; i=i+1)
			begin
				for(j=0; j<m && j<`MAX_COL; j=j+1)
				begin
					if(game_table_copy[i][j] == `empty)
					begin
						
						cnt = 3'b0;
						upcolor = `nocolor;
						downcolor = `nocolor;
						rightcolor = `nocolor;
						leftcolor = `nocolor;
					
						if(i > 0) 
						if(game_table_copy[i-1][j] != `empty)
						begin
							cnt = cnt + 1;
							if(game_table_copy[i-1][j][2:1] == `plus)
								upcolor = {1'b0, game_table_copy[i-1][j][0]};
							else
								upcolor = {1'b0, ~game_table_copy[i-1][j][0]};
						end	
							
					
						if(i < n-1 && i<`MAX_ROW-1)
						if(game_table_copy[i+1][j] != `empty)
						begin
							cnt = cnt + 1;
							downcolor = {1'b0, game_table_copy[i+1][j][0]};
						end	
					
						if(j > 0)
						if(game_table_copy[i][j-1] != `empty)
						begin
							cnt = cnt + 1;
							if(game_table_copy[i][j-1][2:1] == `bslash)
								leftcolor = {1'b0, game_table_copy[i][j-1][0]};
							else
								leftcolor = {1'b0, ~game_table_copy[i][j-1][0]};
						end				
						
						if(j < m-1 && j < `MAX_COL-1)
						if(game_table_copy[i][j+1] != `empty)
						begin
							cnt = cnt + 1;
							if(game_table_copy[i][j+1][2:1] == `slash)
								rightcolor = {1'b0, game_table_copy[i][j+1][0]};
							else
								rightcolor = {1'b0, ~game_table_copy[i][j+1][0]};
						end		
						
						// now cnt is the number of non empty adjacent cells
						
						if(cnt == 3'd2)
						begin
							if(upcolor != `nocolor)
							begin
								if(upcolor == rightcolor)
								begin
									game_table_copy[i][j] = {`bslash, upcolor[0]};
									is_table_changed = 1'b1;
								end
								
								if(upcolor == downcolor)
								begin
									game_table_copy[i][j] = {`plus, upcolor[0]};
									is_table_changed = 1'b1;
								end	
								
								if(upcolor == leftcolor)
								begin
									game_table_copy[i][j] = {`slash, upcolor[0]};
									is_table_changed = 1'b1;
								end
							end
							else if(rightcolor != `nocolor)
							begin
								if(rightcolor == downcolor)
								begin
									game_table_copy[i][j] = {`slash, ~rightcolor[0]};
									is_table_changed = 1'b1;
								end
								
								if(rightcolor == leftcolor)
								begin
									game_table_copy[i][j] = {`plus, ~rightcolor[0]};
									is_table_changed = 1'b1;
								end	
							end
							else
							begin
								if(downcolor == leftcolor)
								begin
									game_table_copy[i][j] = {`bslash, ~downcolor[0]};
									is_table_changed = 1'b1;
								end	
							end
						end
					end
				end	
			end
		end
					
	end
	endtask
	
	task chooseFirstMove(output[21:0] move); 
	begin
		k = 2;
		valid_moves[0] = {`plus, 10'b0, 10'b0 };
		valid_moves[1] = {`slash, 10'b0, 10'b0 };
		move = valid_moves[0];
	end
	endtask
	
	task chooseMove(output[21:0] move);
	integer i, j, l;
	reg wc, wp, bc, bp;
	reg pri1, pri2, pri3;
	begin
		k = 0;
		for(i=0; i<n && i<`MAX_ROW; i=i+1)
			for(j=0; j<m && j<`MAX_COL; j=j+1)
				
				if(game_table[i][j] != `empty)
					update_valid_moves(i, j);
				
		// now valid_moves is updated
	/*	
		pri1 = 1'b0;
		pri2 = 1'b0;
		pri3 = 1'b0;
		
		for(l=0; l<k; l=l+1)
		begin
			updateCopyMap(valid_moves[l]);
			white_cycle(wc);
			white_path(wp);
			black_cycle(bc);
			black_path(bp);
			if( (color == `white) && (wc == 1'b1 || wp == 1'b1) )
				pri1 = 1'b1;
			if( (color == `black) && (bc == 1'b1 || bp == 1'b1) )
				pri1 = 1'b1;	
			if( (color == `white) && (bc == 1'b1 || bp == 1'b1) )
				pri2 = 1'b1;
			if( (color == `black) && (wc == 1'b1 || wp == 1'b1) )
				pri2 = 1'b1;
				
			// priority 3 must be completed !!
		end
	*/	
		
		// choosing move based on priority in phase3 !!
		
		// in phase2 :
		move = valid_moves[0];
				
	end
	endtask
	
	task white_cycle(output yes);
	  begin
	    end
	endtask
	
	task black_cycle(output yes);
	  begin
	    end
	endtask
	
	task white_path(output yes);
	  begin
	    end
	endtask
	
	task black_path(output yes);
	  begin
	    end
	endtask
	
	task update_valid_moves(input r, c);
	integer cnt;
	reg up, down, left, right;
	reg[10-1:0] mraw, mcol; 
	begin
		cnt = 3'b0;
		up = 1'b0;
		down = 1'b0;
		left = 1'b0;
		right = 1'b0;

		mraw = r;
		mcol = c;
		
		if(r > 0) 
		if(game_table[r-1][c] != `empty)
		begin
			cnt = cnt + 1;
			up = 1'b1;				
		end	
							
					
		if(r < n-1 && r < `MAX_ROW-1)
		if(game_table[r+1][c] != `empty)
		begin
			cnt = cnt + 1;
			down = 1'b1;
		end	
					
		if(c > 0)
		if(game_table[r][c-1] != `empty)
		begin
			cnt = cnt + 1;
			left = 1'b1;
		end				
						
		if(c < m-1 && c<`MAX_COL-1)
		if(game_table[r][c+1] != `empty)
		begin
			cnt = cnt + 1;
			right = 1'b1;
		end
		
		// now cnt is the number of non empty adjacent cells
		
		if(cnt == 3'd1)
		begin
			valid_moves[k] = {`plus, mcol, mraw}; 
			valid_moves[k+1] = {`slash, mcol, mraw};
			valid_moves[k+2] = {`bslash, mcol, mraw};
			k = k+3;
		end
		
		if(cnt == 3'd2)
		begin
			if(up == 1'b1)
			begin
				if(right == 1'b1)
				begin
					valid_moves[k] = {`plus, mcol, mraw}; 
					valid_moves[k+1] = {`slash, mcol, mraw};
					k = k+2;
				end
				else if(down == 1'b1)
				begin
					valid_moves[k] = {`bslash, mcol, mraw}; 
					valid_moves[k+1] = {`slash, mcol, mraw};
					k = k+2;
				end
				else if(left == 1'b1)
				begin
					valid_moves[k] = {`plus, mcol, mraw}; 
					valid_moves[k+1] = {`bslash, mcol, mraw};
					k = k+2;
				end
			end
			else if(right == 1'b1)
			begin
				if(down == 1'b1)
				begin
					valid_moves[k] = {`plus, mcol, mraw}; 
					valid_moves[k+1] = {`bslash, mcol, mraw};
					k = k+2;
				end
				else if(left == 1'b1)
				begin
					valid_moves[k] = {`bslash, mcol, mraw}; 
					valid_moves[k+1] = {`slash, mcol, mraw};
					k = k+2;
				end
			end
			else
			begin
				valid_moves[k] = {`plus, mcol, mraw}; 
				valid_moves[k+1] = {`slash, mcol, mraw};
				k = k+2;
			end
		end
		
	end
	endtask
	
	  
endmodule
