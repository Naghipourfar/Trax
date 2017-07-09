/*************** IN THE NAME OF ALLAH ***************/


module Uart(output reg tx, tx_done, rx_finish, output reg[7:0] rx_data, input[7:0] tx_data, input rx, clk, reset, start);
  parameter clk_rate = 9.6 * (10 ** 6);
  parameter baud_rate = 9600;
  localparam integer time_unit = (clk_rate / baud_rate);
  integer i, prev_rx, rec_clk_counter, rec_bit_counter, prev_start, send_clk_counter, send_bit_counter;
  //integer next_rx, next_rec_clk_counter, next_rec_bit_counter, next_start, next_send_clk_counter, next_send_bit_counter;
  // Reset
  /*always @(posedge reset)
  begin
    tx <= 1'b1;
    tx_done <= 1'b1;
    rx_finish <= 1'b1;
    rx_data <= 8'h00;
  end
  */
  
  // Recieving Data
  always @(posedge clk, posedge reset) 
  begin
    
    if ( reset )
    begin
      rx_finish <= 1'b1;
      rx_data <= 8'h00;
    end
    
    else if( rx_finish )
      if( prev_rx == 1'b1 && rx == 1'b0)
      begin
        rx_finish = 1'b0;
        rec_bit_counter = 0;
        rec_clk_counter = 1;
      end
      
      else
      begin
        // do nothing
      end
      
    else
    begin
      
      rec_clk_counter = rec_clk_counter + 1;
      
      if( (rec_bit_counter == 0 && rec_clk_counter == time_unit + (time_unit >> 1) ) || 
        (rec_bit_counter > 32'h0 && rec_bit_counter < 32'h8 && rec_clk_counter == time_unit) )
      begin
        rx_data[ rec_bit_counter ] = rx;
        rec_bit_counter = rec_bit_counter + 1;
        rec_clk_counter = 0;
      end
      
      if( rec_bit_counter == 8 && rec_clk_counter == time_unit )
      begin
        // read stop bit :D nothing to do !!
        rx_finish = 1'b1;
        rec_bit_counter = 0; //not necessary
        rec_clk_counter = 0; //not necessary
      end 
      
    end
    
    prev_rx = rx;
  end
  
  // Sending data 
  always @(posedge clk, posedge reset)
  begin
  
	if (reset)
	begin
	  tx <= 1'b1;
	  tx_done <= 1'b1;
	end
	
    else if( tx_done )
      if( prev_start == 1'b0 && start == 1'b1 )
      begin
        tx_done = 1'b0;
        tx = 1'b0;
        send_clk_counter = 0;
        send_bit_counter = 0;
      end
      else if (prev_start === 1'bx && start == 1'b1) begin
        tx_done = 1'b0;
        tx = 1'b0;
        send_clk_counter = 0;
        send_bit_counter = 0;
      end
      else 
      begin
        // do nothing
      end
      
    else
    begin
      send_clk_counter = send_clk_counter + 1;
      
      if( send_clk_counter == time_unit && send_bit_counter < 8)
      begin
        tx = tx_data[send_bit_counter];
        send_bit_counter = send_bit_counter + 1;
        send_clk_counter = 0;
      end
      
      if (send_clk_counter == time_unit && send_bit_counter == 8)
      begin  
        tx = 1'b1;
        send_bit_counter = 9;
        send_clk_counter = 0;
      end
      
      if (send_clk_counter == time_unit && send_bit_counter == 9)
      begin
        tx_done = 1'b1;
        send_clk_counter = 0; // not necessary
        send_bit_counter = 0; // not necessary
      end
    end
    
    prev_start = start; 
  end
  
endmodule

