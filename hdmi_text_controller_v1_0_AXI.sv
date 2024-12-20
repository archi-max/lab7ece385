`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE-Illinois
// Engineer: Zuofu Cheng
// 
// Create Date: 06/08/2023 12:21:05 PM
// Design Name: 
// Module Name: hdmi_text_controller_v1_0_AXI
// Project Name: ECE 385 - hdmi_text_controller
// Target Devices: 
// Tool Versions: 
// Description: 
// This is a modified version of the Vivado template for an AXI4-Lite peripheral,
// rewritten into SystemVerilog for use with ECE 385.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - File modified to be more consistent with generated template
// Revision 11/18 - Made comments less confusing
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1 ns / 1 ps

module hdmi_text_controller_v1_0_AXI #
(

    // Parameters of Axi Slave Bus Interface S_AXI
    // Modify parameters as necessary for access of full VRAM range

    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH	= 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH	= 16
)
(
    // Users to add ports here
    input  logic [9:0] drawX, drawY,
    output logic [3:0] red, green, blue,
    // User ports ends

    // Global Clock Signal
    input logic  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input logic  S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
    input logic [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
    input logic  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
    output logic  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.    
    input logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
        // data and strobes are available.
    input logic  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
        // can accept the write data.
    output logic  S_AXI_WREADY,
    // Write response. This signal indicates the status
        // of the write transaction.
    output logic [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
    output logic  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
        // can accept a write response.
    input logic  S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
    input logic [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
    input logic  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
    output logic  S_AXI_ARREADY,
    // Read data (issued by slave)
    output logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
        // read transfer.
    output logic [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
        // signaling the required read data.
    output logic  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
        // accept the read data and response information.
    input logic  S_AXI_RREADY
);

// AXI4LITE signals
logic  [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
logic  axi_awready;
logic  axi_wready;
logic  [1 : 0] 	axi_bresp;
logic  axi_bvalid;
logic  [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
logic  axi_arready;
logic  [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
logic  [1 : 0] 	axi_rresp;
logic  	axi_rvalid;

// Example-specific design signals
// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
// ADDR_LSB is used for addressing 32/64 bit registers/memories
// ADDR_LSB = 2 for 32 bits (n downto 2)
// ADDR_LSB = 3 for 64 bits (n downto 3)
localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
localparam integer OPT_MEM_ADDR_BITS = 10;
//----------------------------------------------
//-- Signals for user logic register space example
//------------------------------------------------
//-- Number of Slave Registers 4
//logic [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
//logic [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
//logic [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
//logic [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
//
//Note: the provided Verilog template had the registered declared as above, but in order to give 
//students a hint we have replaced the 4 individual registers with an unpacked array of packed logic. 
//Note that you as the student will still need to extend this to the full register set needed for the lab.


//logic [C_S_AXI_DATA_WIDTH-1:0] slv_regs[601];

logic	 slv_reg_rden;
logic	 slv_reg_wren;
logic [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
integer	 byte_index;
logic	 aw_en;


logic  [C_S_AXI_ADDR_WIDTH-1 : 0]     addra, addrb;
logic  [C_S_AXI_DATA_WIDTH-1 : 0]     dina, douta, doutb;
logic  [3 : 0]  wea;

// I/O Connections assignments

assign S_AXI_AWREADY = axi_awready;
assign S_AXI_WREADY	= axi_wready;
assign S_AXI_BRESP	= axi_bresp;
assign S_AXI_BVALID	= axi_bvalid;
assign S_AXI_ARREADY = axi_arready;
assign S_AXI_RDATA	= axi_rdata;
assign S_AXI_RRESP	= axi_rresp;
assign S_AXI_RVALID	= axi_rvalid;
// Implement axi_awready generation
// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
// de-asserted when reset is low.

always_ff @( posedge S_AXI_ACLK ) // WRITE STEP 2. UNCHANGED
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_awready <= 1'b0;
      aw_en <= 1'b1;
    end 
  else
    begin    
      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
        begin
          // slave is ready to accept write address when 
          // there is a valid write address and write data
          // on the write address and data bus. This design 
          // expects no outstanding transactions. 
          axi_awready <= 1'b1;
          aw_en <= 1'b0;
        end
        else if (S_AXI_BREADY && axi_bvalid)
            begin
              aw_en <= 1'b1;
              axi_awready <= 1'b0;
            end
      else           
        begin
          axi_awready <= 1'b0;
        end
    end 
end       

// Implement axi_awaddr latching
// This process is used to latch the address when both 
// S_AXI_AWVALID and S_AXI_WVALID are valid. 

always_ff @( posedge S_AXI_ACLK ) // UNCHANGED
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_awaddr <= 0;
    end 
  else
    begin    
      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
        begin
          // Write Address latching 
          axi_awaddr <= S_AXI_AWADDR;
        end
    end 
end       

// Implement axi_wready generation
// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
// de-asserted when reset is low. 

always_ff @( posedge S_AXI_ACLK ) // WRITE STEP 2. UNCHANGED
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_wready <= 1'b0;
    end 
  else
    begin    
      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
        begin
          // slave is ready to accept write data when 
          // there is a valid write address and write data
          // on the write address and data bus. This design 
          // expects no outstanding transactions. 
          axi_wready <= 1'b1;
        end
      else
        begin
          axi_wready <= 1'b0;
        end
    end 
end       

// Implement memory mapped register select and write logic generation
// The write data is accepted and written to memory mapped registers when
// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
// select byte enables of slave registers while writing.
// These registers are cleared when reset (active low) is applied.
// Slave register write enable is asserted when valid address and data are available
// and the slave is ready to accept the write address and write data.
logic   [31:0] palette_regs [12];
assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID; // Write Process
// CHANGE
//assign wea = S_AXI_WSTRB; 
//assign wea = {4{slv_reg_wren}}; 

always_ff @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
        begin
             wea <= 4'd0;
        end 
    end
  else begin
    if (slv_reg_wren)
      begin
      if (axi_awaddr[13] == 1'b1) begin
//         for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1) begin
//                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        // Write data to local register for color palette
//                        palette_regs[axi_awaddr[4:2]+axi_awaddr[4:2]] <= S_AXI_WDATA[12 : 1];
//                        palette[axi_awaddr[4:2]+axi_awaddr[4:2]+1] <= S_AXI_WDATA[24 : 13];
//                    end
//        end

        for (byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1) begin
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        // Write data to local register for color palette
                         
                        palette_regs[axi_awaddr[4:2]][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                end
        end else begin
        wea <= S_AXI_WSTRB;
        dina <= S_AXI_WDATA;
//        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
//          if ( S_AXI_WSTRB[byte_index] == 1 ) begin
//            // Respective byte enables are asserted as per write strobes, note the use of the index part select operator
//            // '+:', you will need to understand how this operator works
////              slv_regs[axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
//            dina[(byte_index*8) +: 8]  <= S_AXI_WDATA[(byte_index*8) +: 8]; 
//          end
      end      
      end
    else
    begin
        wea <= 4'b0000;
    end
  end
end    

// Implement write response logic generation
// The write response and response valid signals are asserted by the slave 
// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
// This marks the acceptance of address and indicates the status of 
// write transaction.

always_ff @( posedge S_AXI_ACLK ) // WRITE STEP 4
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_bvalid  <= 0;
      axi_bresp   <= 2'b0;
    end 
  else
    begin    
      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
        begin
          // indicates a valid write response is available
          axi_bvalid <= 1'b1;
          axi_bresp  <= 2'b0; // 'OKAY' response 
        end                   // work error responses in future
      else
        begin
          if (S_AXI_BREADY && axi_bvalid) 
            //check if bready is asserted while bvalid is high) 
            //(there is a possibility that bready is always asserted high)   
            begin
              axi_bvalid <= 1'b0; 
            end  
        end
    end
end   

// Implement axi_arready generation
// axi_arready is asserted for one S_AXI_ACLK clock cycle when
// S_AXI_ARVALID is asserted. axi_awready is 
// de-asserted when reset (active low) is asserted. 
// The read address is also latched when S_AXI_ARVALID is 
// asserted. axi_araddr is reset to zero on reset assertion.

always_ff @( posedge S_AXI_ACLK ) // READ STEP 2. UNCHANGED
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_arready <= 1'b0;
      axi_araddr  <= 32'b0;
    end 
  else
    begin    
      if (~axi_arready && S_AXI_ARVALID)
        begin
          // indicates that the slave has acceped the valid read address
          axi_arready <= 1'b1;
          // Read address latching
          axi_araddr  <= S_AXI_ARADDR;
        end
      else
        begin
          axi_arready <= 1'b0;
        end
    end 
end       

// Implement axi_arvalid generation
// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
// data are available on the axi_rdata bus at this instance. The 
// assertion of axi_rvalid marks the validity of read data on the 
// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
// is deasserted on reset (active low). axi_rresp and axi_rdata are 
// cleared to zero on reset (active low).  
logic [1:0] count;
logic delay_signal;

always_ff @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
        count <= 2'b00;
        delay_signal <= 1'b1;
    end
    else if (slv_reg_rden || (count > 1'b00)) begin
        if (count == 2'b11) begin
            delay_signal <= 1'b1;
            count <= 2'b00;
        end 
        else begin
            count <= count + 1;
            delay_signal <= 1'b0;
        end
    end
end

always_ff @( posedge S_AXI_ACLK ) // READ STEP 4. CHANGE TO ADD DELAY.
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_rvalid <= 0;
      axi_rresp  <= 0;
    end 
  else
    begin    
      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid && delay_signal)
        begin
          // Valid read data is available at the read data bus
          axi_rvalid <= 1'b1;
          axi_rresp  <= 2'b0; // 'OKAY' response
        end   
      else if (axi_rvalid && S_AXI_RREADY)
        begin
          // Read data is accepted by the master
          axi_rvalid <= 1'b0;
        end                
    end
end    

// Implement memory mapped register select and read logic generation
// Slave register read enable is asserted when valid address is available
// and the slave is ready to accept the read address.
assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid; // Read Process. CHANGE
//always_comb
//begin
//      // Address decoding for reading registers
//      reg_data_out = slv_regs[axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]];
//end

// Output register or memory read data
always_ff @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_rdata  <= 0;
    end 
  else
    begin    
      // When there is a valid read address (S_AXI_ARVALID) with 
      // acceptance of read address by the slave (axi_arready), 
      // output the read dada 
      if (slv_reg_rden)
        begin
//          axi_rdata <= reg_data_out;     // register read data
        if (addra[13] == 1)
        begin
          axi_rdata <= palette_regs[addra[4:2]];
        end else
            axi_rdata <= douta;     // register read data
        end   
    end
end    

// Add user logic here

always_ff @(posedge S_AXI_ACLK) begin
    if (slv_reg_rden) begin
        addra <= axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];
    end 
    else if (slv_reg_wren) begin
        addra <= axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];
    end
end


blk_mem_gen_0 mem(
    .addra(addra),
    .clka(S_AXI_ACLK),
    .dina(dina),
    .douta(douta),
    .ena(1'b1),
    .wea(wea),
    .addrb(addrb),
    .clkb(S_AXI_ACLK),
    .dinb(32'b0),
    .doutb(doutb),
    .enb(1'b1),
    .web(4'b0)
);


logic [10:0] rom_addr;
logic [8:0] rom_data;
logic [8:0] rom_data_i;

logic [31:0] curr_reg_data;
logic [6:0] glyph_code;

logic [6:0] col;
logic [1:0] char_in_reg;      // Which character within a register (0-3)
logic [31:0] vram_register;
logic [3:0] pixel_y;          // Y position within character (0-15)
 logic [2:0] pixel_x; 
logic [3:0] fgd_idx, bkg_idx;
logic [7:0] bitmap_row;       // Bitmap row from font ROM (8 bits)
logic [11:0] fgd_color, bkg_color;  // 12-bit RGB colors
logic inverted;               // Inversion flag from VRAM data

always_comb 
begin
//    curr_reg_data = slv_regs[(drawX[9:5] + drawY[9:4] * 20)];
    addrb = (drawX[9:4] + drawY[9:4] * 40);
    vram_register = doutb;
    col = drawX >> 3;
    char_in_reg = col % 2;  // Determine which character in the word
    pixel_x = drawX % 8;
    pixel_y = drawY % 16;
    
//    case (char_in_reg)
//            2'b00: begin
//                glyph_code = vram_register[30:24];     // Character 1 glyph code
//                fgd_idx = vram_register[23:20];        // Character 1 foreground index
//                bkg_idx = vram_register[19:16];        // Character 1 background index
//                inverted = vram_register[31];          // Character 1 inversion flag
//            end
//            default: begin
//                glyph_code = vram_register[14:8];       // Character 0 glyph code
//                fgd_idx = vram_register[7:4];          // Character 0 foreground index
//                bkg_idx = vram_register[3:0];          // Character 0 background index
//                inverted = vram_register[15];          // Character 0 inversion flag
//            end
//        endcase

    case (char_in_reg)
            2'b00: begin
                glyph_code = vram_register[14:8];       // Character 0 glyph code
                fgd_idx = vram_register[7:4];          // Character 0 foreground index
                bkg_idx = vram_register[3:0];          // Character 0 background index
                inverted = vram_register[15];          // Character 0 inversion flag
                
            end
            default: begin
                glyph_code = vram_register[30:24];     // Character 1 glyph code
                fgd_idx = vram_register[23:20];        // Character 1 foreground index
                bkg_idx = vram_register[19:16];        // Character 1 background index
                inverted = vram_register[31];          // Character 1 inversion flag
            end
        endcase
    
    rom_addr = {glyph_code,pixel_y};
end


font_rom rom (
    .addr(rom_addr),
    .data(bitmap_row)
);

logic temp;
logic pixel_value;            // Current pixel value (foreground or background)

always_comb
    begin
         // Fetch colors from palette using indicesx
         
         fgd_color = palette_regs[fgd_idx >> 1][(fgd_idx % 2) * 16 +:11]; //  [((fgd_idx % 2) * 16) :+ 11];
         bkg_color = palette_regs[bkg_idx >> 1][(bkg_idx % 2) * 16 +:11]; // [(bkg_idx % 2) * 16 :+ 11];
         
//         if (fgd_idx % 2 == 0)
//         begin
//            fgd_color = palette_regs[fgd_idx >> 1][24:13]; // Extract lower 12 bits for even index
//    end 
//    else
//    begin
//            fgd_color = palette_regs[fgd_idx >> 1][12:1]; // Extract upper 12 bits for odd index
//    end
    
//    if (bkg_idx % 2 == 0)
//         begin
//            bkg_color = palette_regs[bkg_idx >> 1][24:13]; // Extract lower 12 bits for even index
//    end 
//    else
//    begin
//            bkg_color = palette_regs[bkg_idx >> 1][12:1]; // Extract upper 12 bits for odd index
//    end
         

        if (inverted) begin
            pixel_value = ~bitmap_row[7 - pixel_x];
            {red, green, blue} = pixel_value ? bkg_color : fgd_color;
        end else begin
            pixel_value = bitmap_row[7 - pixel_x];
            {red, green, blue} = pixel_value ? fgd_color : bkg_color;
        end
end

    
// User logic ends

endmodule