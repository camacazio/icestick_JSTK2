`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineers: Ryan Kim
//				  Josh Sackos
// 
// Create Date:    14:10:08 06/13/2012 
// Module Name:    OledExample - Behavioral 
// Project Name: 	 PmodOLED Demo
// Tool versions:  ISE 14.1
// Description: Demo for the PmodOLED.  First displays the alphabet for ~4 seconds and then
//				Clears the display, waits for a ~1 second and then displays "This is Digilent's
//				PmodOLED"
//
// Revision: 1.2
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
module OledEX(
    CLK,
    RST,
    EN,
    CS,
    SDO,
    SCLK,
    DC,
    FIN,
    // Position on the screen
    xpos,
    ypos
    );

	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================
    input CLK;
    input RST;
    input EN;
    output CS;
    output SDO;
    output SCLK;
    output DC;
    output FIN;
    // Screen positions
    input [9:0] xpos;
    input [9:0] ypos;

	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
	wire CS, SDO, SCLK, DC, FIN;

   //Variable that contains what the screen will be after the next UpdateScreen state
   // - screen has 4 pages
   // - each page is 128 columns
   // - each column is one byte (8 rows) 
   reg [7:0] current_screen[0:3][0:127];
   
   //Current overall state of the state machine
   reg [95:0] current_state;
   //State to go to after the SPI transmission is finished
   reg [95:0] after_state;
   //State to go to after the set page sequence
   reg [95:0] after_page_state;
   //State to go to after sending the character sequence
   reg [95:0] after_char_state;

    // indeces for screen matrix
	integer i = 0;
	integer j = 0;

   //Contains the value to be output to DC
   reg temp_dc = 1'b1;
   
   //-------------- Variables used in the SPI controller block ----------------
   reg temp_spi_en;					//Enable signal for the SPI block
   reg [7:0] temp_spi_data;		    //Data to be sent out on SPI
   wire temp_spi_fin;				//Finish signal for the SPI block
   
   reg [1:0] temp_page;				//Current page
   reg [7:0] temp_char;             //Current Byte
   reg [6:0] temp_index;			//Current character on page

	// ===========================================================================
	// 										Implementation
	// ===========================================================================

   assign DC = temp_dc;
   //Example finish flag only high when in done state
   assign FIN = (current_state == "Done") ? 1'b1 : 1'b0;


   //Instantiate SPI Block
   SpiCtrl_OLED SPI_OledEX(
			.CLK(CLK),
			.RST(RST),
			.SPI_EN(temp_spi_en),
			.SPI_DATA(temp_spi_data),
			.CS(CS),
			.SDO(SDO),
			.SCLK(SCLK),
			.SPI_FIN(temp_spi_fin)
	);
	
	//  State Machine
	always @(posedge CLK) begin
			
		case(current_state)

			// Idle until EN pulled high than intialize Page to 0 and go to state Alphabet afterwards
			"Idle" : begin
					if(EN == 1'b1)
					begin
						current_state <= "ClearDC";
						after_page_state <= "SetScreen";
						temp_page <= 2'b00;
						temp_index <= 'd0;
					end
			end			
			
			// set current_screen to constant clear_screen and update the screen. Go to state Wait2 afterwards
			"SetScreen" : begin
					for(i = 0; i <= 3 ; i=i+1) begin
						for(j = 0; j <= 127 ; j=j+1) begin
						      if((i == ypos[9:8]) && (j == xpos[9:3])) begin
						          if(ypos[7:0] & 8'b10000000)
						              current_screen[i][j] <= 8'b01111111;
                                  else if(ypos[7:0] & 8'b01000000)
                                      current_screen[i][j] <= 8'b10111111;
                                  else if(ypos[7:0] & 8'b00100000)
                                      current_screen[i][j] <= 8'b11011111;
                                  else if(ypos[7:0] & 8'b00010000)
                                      current_screen[i][j] <= 8'b11101111;
                                  else if(ypos[7:0] & 8'b00001000)
                                      current_screen[i][j] <= 8'b11110111;
                                  else if(ypos[7:0] & 8'b00000100)
                                      current_screen[i][j] <= 8'b11111011;
                                  else if(ypos[7:0] & 8'b00000010)
                                      current_screen[i][j] <= 8'b11111101;
                                  else if(ypos[7:0] & 8'b00000001)
                                      current_screen[i][j] <= 8'b11111110;
//                                  else
//                                      current_screen[i][j] <= 8'b11111110;
						      end
                              else
                                  current_screen[i][j] <= 8'hFF;
						end
					end
					
					current_state <= "UpdateScreen";
			end
			
			// Do nothing until EN is deassertted and then current_state is Idle
			"Done" : begin
					if(EN == 1'b0) begin
						current_state <= "Idle";
					end
			end
			
			//UpdateScreen State
			//1. Gets ASCII value from current_screen at the current page and the current spot of the page
			//2. If on the last character of the page transition update the page number, if on the last page(3)
			//			then the UpdateScreen goes to "Done" after
			"UpdateScreen" : begin

					temp_char <= current_screen[temp_page][temp_index];

					if(temp_index == 'd127) begin

						temp_index <= 'd0;
						temp_page <= temp_page + 1'b1;
						after_char_state <= "ClearDC";

						if(temp_page == 2'b11)
						begin
							after_page_state <= "Done";
						end
						else
						begin
							after_page_state <= "UpdateScreen";
						end
					end
					
					else
					begin
						temp_index <= temp_index + 1'b1;
						after_char_state <= "UpdateScreen";
					end
					
					current_state <= "SendChar1";

			end
			
			//Update Page states
			//1. Sets DC to command mode
			//2. Sends the SetPage Command
			//3. Sends the Page to be set to
			//4. Sets the start pixel to the left column
			//5. Sets DC to data mode
			"ClearDC" : begin
					temp_dc <= 1'b0;
					current_state <= "SetPage";
			end
			
			"SetPage" : begin
					temp_spi_data <= 8'b00100010;
					after_state <= "PageNum";
					current_state <= "Transition1";
			end
			
			"PageNum" : begin
					temp_spi_data <= {6'b000000,temp_page};
					after_state <= "LeftColumn1";
					current_state <= "Transition1";
			end
			
			"LeftColumn1" : begin
					temp_spi_data <= 8'b00000000;
					after_state <= "LeftColumn2";
					current_state <= "Transition1";
			end
			
			"LeftColumn2" : begin
					temp_spi_data <= 8'b00010000;
					after_state <= "SetDC";
					current_state <= "Transition1";
			end
			
			"SetDC" : begin
					temp_dc <= 1'b1;
					current_state <= after_page_state;
			end
			
			//Send Character States
			//1. Sets the Address to ASCII value of char with the counter appended to the end
			//2. Waits a clock for the data to get ready by going to ReadMem and ReadMem2 states
			//3. Send the byte of data given by the block Ram
			//4. Repeat 7 more times for the rest of the character bytes
			"SendChar1" : begin
					temp_spi_data <= temp_char;
                    after_state <= after_char_state;
					current_state <= "Transition1";
			end
			//  End Send Character States

			// SPI transitions
			// 1. Set SPI_EN to 1
			// 2. Waits for SpiCtrl to finish
			// 3. Goes to clear state (Transition5)
			"Transition1" : begin
					temp_spi_en <= 1'b1;
					current_state <= "Transition2";
			end

			"Transition2" : begin
					if(temp_spi_fin == 1'b1) begin
						current_state <= "Transition3";
					end
			end

			// Clear transition
			// 1. Sets both DELAY_EN and SPI_EN to 0
			// 2. Go to after state
			"Transition3" : begin
					temp_spi_en <= 1'b0;
					current_state <= after_state;
			end
			//END SPI transitions
			//END Clear transition

			default : current_state <= "Idle";

		endcase
	end

endmodule
