 /****************************************************************************
 * 							In The Name of God								*
 ****************************************************************************/


// Literals ASCII codes --> @ = 64 && Z = 90
// Numbers ASCII codes --> 0 = 48 && 9 = 57 (\n = 10)

module Tranceiver(output reg[21:0] move_out, output reg end_receive, color, output tx, input[21:0] move_in, input rx, start_transmit, clock, reset);
	wire tx_done, rx_finish;
	wire [7:0] rx_data;
	reg [7:0] tx_data;
	reg [15:0] col_data_rec, col_data_send;
	reg [23:0] row_data_rec, row_data_send;
	reg [7:0] move_type;
	reg start_send;
	reg prev_tx;
	reg next_tx;
	reg color_flag;
	reg row_flag;
	reg col_flag;
	reg type_flag;
	reg slash_flag;
	reg end_send;
	integer send_row_counter;
	integer send_col_counter;
	integer send_type_counter;
	reg calculated_data;
	reg[32:0] clk_counter;
	reg prev_rx_finish;
	reg start;
	parameter clk_rate = 9.6 * (10 ** 6);
	parameter baud_rate = 9600;
	parameter integer time_unit = (clk_rate / baud_rate);
	integer time_transmit = 10 * time_unit;
	defparam uart.clk_rate = clk_rate;
	defparam uart.baud_rate = baud_rate;
	Uart uart(tx, tx_done, rx_finish, rx_data, tx_data, rx, clock, reset, start_send);
	
	
	always @(posedge clock)  begin
		//clk_counter = clk_counter + 1; 
		next_tx = tx_done;
		prev_rx_finish = rx_finish;
		if (start_transmit && end_send) begin
			start = 1'b1;
		end
		else if (!start_transmit && end_send) begin
			start = 1'b0;
		end
		else if (reset) begin
			start = 1'b0;
		end

	end
	
//	always @(negedge clock)
//	 prev_tx = tx_done;
	
	//always @(posedge reset) begin
	  
	//end
	 
    
	// When User Wants to Send Packet
	always @(negedge clock) begin
		prev_tx = tx_done;
		clk_counter = clk_counter + 1;
		if (reset) begin
			clk_counter <= 0;
			row_flag <= 1'b0;
			col_flag <= 1'b0;
			type_flag <= 1'b0;
			slash_flag <= 1'b0;
			send_row_counter <= 0;
			send_col_counter <= 0;
			send_type_counter <= 0;
			calculated_data <= 1'b0;
			end_send <= 1'b1;
			prev_tx <= 1'b1;
			start_send <= 1'b0;
		end
	  	else if (end_send && !start) begin
	    	clk_counter = 0;
	  	end
	  	else if (!calculated_data && start) begin
		  	row_data_send <= calculate_row_vector(move_in[0+:10]);
		  	col_data_send <= calculate_col_vector(move_in[10+:10]);
		  	case(move_in[20+:2])
				2'b00: move_type <= 43;
				2'b01: move_type <= 92;
				2'b10: move_type <= 47;
		  	endcase
		  	calculated_data = 1'b1;
		  	end_send <= 1'b0;
		end
		// Sending Data
		// Sending Column Data
		else if (!col_flag && col_data_send[8] !==1'bx && start) begin
		  	if(send_col_counter == 0) begin
				tx_data <= col_data_send[8+:8];
				send_col_counter <= send_col_counter + 1;
				start_send <= 1'b1;
				clk_counter <= 0;
			end
			else if (clk_counter >= 100 + 5 && send_col_counter == 1) begin
				tx_data <= col_data_send[0+:8];
				start_send <= 1'b1;
				send_col_counter <= send_col_counter + 1;
				clk_counter <= 0; 
			end
			if ( prev_tx && !next_tx) begin  //Means @(posedge tx_done)
				start_send <= 1'b0;
			end
			if (send_col_counter == 2 && prev_tx && !next_tx) begin
				col_flag <= 1'b1;
			end
		end
		else if(!col_flag && start) begin
			if(send_col_counter == 0) begin
				tx_data <= col_data_send[0+:8];	
				start_send <= 1'b1;
				send_col_counter <= send_col_counter + 1;
				clk_counter <= 0;
			end	
			if (prev_tx && !next_tx) begin  //Means @(posedge tx_done)
				start_send <= 1'b0;
			end
			if (send_col_counter == 1 && prev_tx && !next_tx) begin
				col_flag <= 1'b1;
			end
		end
		// Sending Column Data Finished
		// Sending Row Data
	  	else if (col_flag && !row_flag && row_data_send[16] !== 1'bx && start) begin
		  	if (send_row_counter == 0) begin
				tx_data <= row_data_send[16+:8];
				start_send <= 1'b1;
				send_row_counter <= send_row_counter + 1;
			end
			else if (clk_counter >= time_transmit && send_row_counter == 1) begin
				tx_data <= row_data_send[8+:8];
				start_send = 1'b1;
				send_row_counter <= send_row_counter + 1;
				clk_counter <= 0;
			end
			else if (clk_counter >= time_transmit && send_row_counter == 2) begin
				tx_data <= row_data_send[0+:8];
				start_send <= 1'b1;
				send_row_counter <= send_row_counter + 1;
				clk_counter <= 0;
			end
			if ( prev_tx && !next_tx) begin  //Means @(posedge tx_done)
				start_send <= 1'b0;
			end
			if (send_row_counter == 3 && prev_tx && !next_tx) begin
					row_flag <= 1'b1;
			end
		end
		else if(col_flag && !row_flag && row_data_send[8] !== 1'bx && start) begin
		  	if (send_row_counter == 0) begin
				tx_data <= row_data_send[8+:8];
				start_send <= 1'b1;
				send_row_counter <= send_row_counter + 1;
				clk_counter <= 0;
			end
			else if ((clk_counter >= time_transmit) && (send_row_counter == 1)) begin
				tx_data <= row_data_send[0+:8];
				start_send <= 1'b1;
				send_row_counter <= send_row_counter + 1;
				clk_counter <= 0;
			end
			if ( prev_tx && !next_tx) begin  //Means @(posedge tx_done)
				start_send <= 1'b0;
			end
			if (send_row_counter == 2 && prev_tx && !next_tx) begin
				row_flag <= 1'b1;
			end
		end
		else if(col_flag && !row_flag && start) begin
		  	if (send_row_counter == 0) begin
				tx_data <= row_data_send[0+:8];
				start_send <= 1'b1;
				send_row_counter <= send_row_counter + 1;
				clk_counter <= 0;
			end
			if (prev_tx && !next_tx) begin  //Means @(posedge tx_done)
				start_send <= 1'b0;
			end
			if (send_row_counter == 1 && prev_tx && !next_tx) begin
				row_flag <= 1'b1;
			end
		end
		// Sending Row Data Finished!
		// Sending Move Type
		else if (row_flag && col_flag && !type_flag && start) begin
			if(send_type_counter == 0) begin
				tx_data <= move_type;
				start_send <= 1'b1;
				send_type_counter <= send_type_counter + 1;
			end
			if (prev_tx && !next_tx) begin
				start_send <= 1'b0;
			end
			if ( send_type_counter == 1 && prev_tx && !next_tx) begin
				type_flag <= 1'b1;
				send_type_counter <= 0;
			end
		end
		// Sending Move Type Finished
		// Start Sending \n
		else if(row_flag && col_flag && type_flag && !slash_flag && start) begin
		  	if (send_type_counter == 0) begin
			    tx_data <= 10;		// (\n) ASCII Code is 10
			    start_send <= 1'b1;
			    send_type_counter <= 1;
		  	end
		  	if (prev_tx && !next_tx) begin
		    	start_send <= 1'b0;
		  	end
		  	if ( send_type_counter == 1 && prev_tx && !next_tx) begin
		    	slash_flag <= 1'b1;
		  	end
		end
		// Sending \n Finished!
		// Sending Data Finished!
		else if(row_flag && col_flag && type_flag && slash_flag && start) begin
			calculated_data <= 1'b0;
			end_send <= 1'b1;
			row_flag <= 1'b0;
			col_flag <= 1'b0;
			type_flag <= 1'b0;
			slash_flag <= 1'b0;
			clk_counter <= 0;
			send_row_counter <= 0;
			send_col_counter <= 0;
			send_type_counter <= 0;
		end
		
		//--------------------------------------------------------------------
		/*// When a data Packet Received!
	    else if (rx_finish) begin
			if (!color_flag) begin // 45 = '-' ASCII Code (Means that the color is sending)
				if (rx_data == 87) begin // 87 is 'W'
			 		color <= 1'b0;
			 		color_flag <= 1'b1;
				end
			else if(rx_data == 66) begin // 66 is 'B'
			 	color <= 1'b1;
			 	color_flag <= 1'b1;
			end
	 	end
		else if (rx_data > 63 & rx_data < 91) begin // if rx_data is an English Literal --> Column Data
			if(col_data[0] == 1'bx) begin
				end_receive <= 1'b0;
				col_data[7:0] <= rx_data;
			end
			else begin
				col_data[8+:8] <= col_data[0+:8];
				col_data[0+:8] <= rx_data;
			end
			move_out[10+:10] <= calculate_col_number(col_data);
		end
		else if (rx_data > 47 & rx_data < 58) begin // if rx_data is a number --> Row Data
			if(row_data[0] == 1'bx) 
				row_data[0+:8] <= rx_data;
			else if (row_data[8] == 1'bx) begin
				row_data[8+:8] <= row_data[0+:8];
				row_data[0+:8] <= rx_data;
			end
			else begin
				row_data[16+:8] <= row_data[8+:8];
				row_data[8+:8] <= row_data[0+:8];
				row_data[0+:8] <= rx_data;
			end
			move_out[0+:10] <= calculate_row_number(row_data);
		end		
		else if(rx_data == 43) // plus is received
			move_out[20+:2] <= 2'b00;
		else if(rx_data == 92) // back slash is received
			move_out[20+:2] <= 2'b01;
		else if(rx_data == 47) // slash is received
			move_out[20+:2] <= 2'b10;
		else // Means That \n is received
			end_receive <= 1'b1;
		end*/
		//end Receiving Data Packet
	end

	always @(negedge clock) begin
		if (reset) begin
			color_flag <= 1'b0;
			end_receive <= 1'b1;
		end
		else if (rx_finish && !start) begin
			if (!color_flag) begin // 45 = '-' ASCII Code (Means that the color is sending)
				if (rx_data == 87) begin // 87 is 'W'
			 		color <= 1'b0;
			 		color_flag <= 1'b1;
			 		end_receive = 1'b0;
				end
				else if(rx_data == 66) begin // 66 is 'B'
			 		color <= 1'b1;
			 		color_flag <= 1'b1;
			 		end_receive <= 1'b0;
				end
	 		end
			else if (color_flag && rx_data > 63 & rx_data < 91) begin // if rx_data is an English Literal --> Column Data
				if(col_data_rec[0] == 1'bx) begin
					end_receive <= 1'b0;
					col_data_rec[7:0] <= rx_data;
				end
				else begin
					col_data_rec[8+:8] <= col_data_rec[0+:8];
					col_data_rec[0+:8] <= rx_data;
				end
				move_out[0+:10] <= calculate_col_number(col_data_rec);
			end
			else if (rx_data > 47 & rx_data < 58) begin // if rx_data is a number --> Row Data
				if(row_data_rec[0] == 1'bx) 
					row_data_rec[0+:8] <= rx_data;
				else if (row_data_rec[8] == 1'bx) begin
					row_data_rec[8+:8] <= row_data_rec[0+:8];
					row_data_rec[0+:8] <= rx_data;
				end
				else begin
					row_data_rec[16+:8] <= row_data_rec[8+:8];
					row_data_rec[8+:8] <= row_data_rec[0+:8];
					row_data_rec[0+:8] <= rx_data;
				end
				move_out[10+:10] <= calculate_row_number(row_data_rec);
			end		
			else if(rx_data == 43) // plus is received
				move_out[20+:2] <= 2'b00;
			else if(rx_data == 92) // back slash is received
				move_out[20+:2] <= 2'b01;
			else if(rx_data == 47) // slash is received
				move_out[20+:2] <= 2'b10;
			else // Means That \n is received
				end_receive <= 1'b1;
		end
	end

	// When A Data Packet Received  	
/*	always @(posedge rx_finish) begin
	  if (!color_flag) begin // 45 = '-' ASCII Code (Means that the color is sending)
	   if (rx_data == 87) begin // 87 is 'W'
	     color = 1'b0;
	     color_flag = 1'b1;
	   end
	   else if(rx_data == 66) begin // 66 is 'B'
	     color = 1'b1;
	     color_flag <= 1'b1;
	   end
	  end
		else if (rx_data > 63 & rx_data < 91) begin // if rx_data is an English Literal --> Column Data
			if(col_data[0] == 1'bx) begin
				end_receive <= 1'b0;
				col_data[7:0] <= rx_data;
			end
			else begin
				col_data[8+:8] <= col_data[0+:8];
				col_data[0+:8] <= rx_data;
			end
			move_out[10+:10] <= calculate_col_number(col_data);
		end
		else if (rx_data > 47 & rx_data < 58) begin // if rx_data is a number --> Row Data
			if(row_data[0] == 1'bx) 
				row_data[0+:8] <= rx_data;
			else if (row_data[8] == 1'bx) begin
				row_data[8+:8] <= row_data[0+:8];
				row_data[0+:8] <= rx_data;
			end
			else begin
				row_data[16+:8] <= row_data[8+:8];
				row_data[8+:8] <= row_data[0+:8];
				row_data[0+:8] <= rx_data;
			end
			move_out[0+:10] <= calculate_row_number(row_data);
		end		
		else if(rx_data == 43) // plus is received
			move_out[20+:2] = 2'b00;
		else if(rx_data == 92) // back slash is received
			move_out[20+:2] = 2'b01;
		else if(rx_data == 47) // slash is received
			move_out[20+:2] = 2'b10;
		else // Means That \n is received
			end_receive = 1'b1;
	end
	*/
	
	//Function which generate decimal number of row
	function [31:0]calculate_row_number(input[23:0] row_data);
	  integer row_num;
		begin
		  row_num = 0;
			if(row_data[0] !== 1'bx)
				row_num = row_num + (row_data[0+:8] - 48);
			if(row_data[8] !== 1'bx)
				row_num = row_num + (10 * (row_data[8+:8] - 48));
			if(row_data[16] !== 1'bx)
				row_num = row_num + (100 * (row_data[16+:8] - 48));			
			calculate_row_number = row_num;
		end
	endfunction
	
	//Function which generate decimal number of column 
	function [31:0]calculate_col_number(input[15:0] col_data);
	  integer col_num;
		begin
		  col_num = 0;
			if(col_data[8] !== 1'bx) begin
				col_num = col_num + (27 * (col_data[8+:8] - 64)) + (col_data[0+:8] - 64);
			end
			else
				col_num = col_data[0+:8] - 64;
			calculate_col_number = col_num;
		end
	endfunction
	
	//Function Which generate column vector For Sending Column Data
	function [15:0]calculate_col_vector(input [10:0] col_number);
		integer divide, mod, number;
		begin
			number = col_number;
			if (number % 26 == 0)
			  divide = (number / 26) - 1;
			else
			  divide = number / 26;
			mod = number - (divide * 26);
			calculate_col_vector[0+:8] = mod + 64;
			if (divide != 0)
				calculate_col_vector[8+:8] = divide + 64;
			else
				calculate_col_vector[8+:8] = 8'bx;
		end
	endfunction
	
	//Function Which generate row vector For Sending Row Data
	function [23:0]calculate_row_vector(input [10:0] row_number);
		integer digit, number;
		begin
			number = row_number;
			if (number >= 100) begin
				digit = number / 100;
				calculate_row_vector[16+:8] = digit + 48;
				number = number % 100;
				digit = number / 10;
				calculate_row_vector[8+:8] = digit + 48;
				number = number % 10;
				digit = number;
				calculate_row_vector[0+:8] = digit + 48;
			end
			else if (number >= 10) begin
				calculate_row_vector[16+:8] = 8'bx;
				digit = number / 10;
				calculate_row_vector[8+:8] = digit + 48;
				number = number % 10;
				digit = number;
				calculate_row_vector[0+:8] = digit + 48;
			end
			else begin
				calculate_row_vector[8+:16] = 16'bx;
				digit = number;
				calculate_row_vector[0+:8] = digit + 48;
			end
			
		end
	endfunction	
		
endmodule



