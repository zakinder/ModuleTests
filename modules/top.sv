`include "uvm_macros.svh"
package socTest_pkg;
import uvm_pkg::*;
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- DEFINES
//------------------------------------------------------------------------------------
//====================================================================================
typedef struct packed {
   byte unsigned addr_width;
   byte unsigned data_width;
} width_confg1_t;
typedef struct packed {
   int unsigned payload_length;
} width_confg2_t;
typedef struct packed {
   width_confg1_t w_p1;
   width_confg2_t w_p2;
} set_config;
typedef enum { READ, WRITE } axiLite_txn_e;
parameter set_config par_1 = '{ '{ addr_width: 11, data_width: 8 }, '{ payload_length: 2 } };
parameter set_config par_2 = '{ '{ addr_width: 11, data_width: 8 }, '{ payload_length: 4 } };
parameter set_config par_3 = '{ '{ addr_width: 11, data_width: 8 }, '{ payload_length: 3 } };
typedef enum bit [5:0] {
	AX_FLOW_TYPE				= 6'h00,
	AX_WRITE_TYPE				= 6'h08,
	AX_MISC_WRITE_TYPE			= 6'h10,
	AX_POSTED_WRITE_TYPE		= 6'h18,
	AX_POSTED_MISC_WRITE_TYPE	= 6'h20,
	AX_MODE_READ_TYPE			= 6'h28,
	AX_READ_TYPE				= 6'h30,
	AX_RESPONSE_TYPE			= 6'h38
} ax_command_type;
typedef enum bit [5:0] {
    AX_NULL                = 6'h00,
    AX_PRET                = 6'h01,
    AX_TRET                = 6'h02,
    AX_IRTRY                = 6'h03,
    AX_WRITE_16            = 6'h08,
    AX_WRITE_32            = 6'h09,
    AX_WRITE_48            = 6'h0a,
    AX_WRITE_64            = 6'h0b,
    AX_WRITE_80            = 6'h0c,
    AX_WRITE_96            = 6'h0d,
    AX_WRITE_112            = 6'h0e,
    AX_WRITE_128            = 6'h0f,
    //-- misc write
    AX_MODE_WRITE            = 6'h10,
    AX_BIT_WRITE            = 6'h11,
    AX_DUAL_8B_ADDI        = 6'h12,
    AX_SINGLE_16B_ADDI        = 6'h13,
    AX_POSTED_WRITE_16        = 6'h18,
    AX_POSTED_WRITE_32        = 6'h19,
    AX_POSTED_WRITE_48        = 6'h1a,
    AX_POSTED_WRITE_64        = 6'h1b,
    AX_POSTED_WRITE_80        = 6'h1c,
    AX_POSTED_WRITE_96        = 6'h1d,
    AX_POSTED_WRITE_112    = 6'h1e,
    AX_POSTED_WRITE_128    = 6'h1f,
    AX_POSTED_BIT_WRIT            = 6'h21,
    AX_POSTED_DUAL_8B_ADDI        = 6'h22,
    AX_POSTED_SINGLE_16B_ADDI    = 6'h23,
    AX_MODE_READ            = 6'h28,
    AX_READ_16                = 6'h30,
    AX_READ_32                = 6'h31,
    AX_READ_48                = 6'h32,
    AX_READ_64                = 6'h33,
    AX_READ_80                = 6'h34,
    AX_READ_96                = 6'h35,
    AX_READ_112            = 6'h36,
    AX_READ_128            = 6'h37,
    AX_READ_RESPONSE        = 6'h38,
    AX_WRITE_RESPONSE        = 6'h39,
    AX_MODE_READ_RESPONSE    = 6'h3A,
    AX_MODE_WRITE_RESPONSE    = 6'h3B,
    AX_ERROR_RESPONSE        = 6'h3E
} ax_command_encoding;
`define AX_TYPE_MASK 6'h38
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_CONFIGURATIONS
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_OBJECT : TEMPLATE_CONFIGURATION [TEMPLATE]
class template_configuration extends uvm_object;
    `uvm_object_utils(template_configuration)
    function new(string name = "");
        super.new(name);
    endfunction: new
endclass: template_configuration
// UVM_OBJECT : AXILITE_CONFIGURATION [AXILITE]
class axiLite_configuration extends uvm_object;
    `uvm_object_utils(axiLite_configuration)
    function new(string name = "");
        super.new(name);
    endfunction: new
endclass: axiLite_configuration
// UVM_OBJECT : RGB_CONFIGURATION [RGB]
class rgb_configuration extends uvm_object;
    `uvm_object_utils(rgb_configuration)
    function new(string name = "");
        super.new(name);
    endfunction: new
    rand int count;
    constraint c_count    { count > 0; count < 128; }
endclass: rgb_configuration
class axi4_stream_config extends uvm_object;
	uvm_active_passive_enum master_active = UVM_ACTIVE;
	uvm_active_passive_enum slave_active  = UVM_ACTIVE;
	uvm_active_passive_enum open_rsp_mode = UVM_ACTIVE;
    virtual axi4_stream_if vif;
	`uvm_object_utils_begin(axi4_stream_config)
		`uvm_field_enum(uvm_active_passive_enum, master_active, UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, slave_active,  UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, open_rsp_mode,  UVM_DEFAULT)
	`uvm_object_utils_end
    function new(string name = "");
        super.new(name);
    endfunction: new
	virtual function void do_print (uvm_printer printer);
		super.do_print(printer);
	endfunction : do_print
endclass : axi4_stream_config
class axi4_stream_agents_config extends uvm_object;
    `uvm_object_utils(axi4_stream_agents_config)
    bit has_axi4_agent1 = 1; //switch to instantiate an agent #1
    bit has_axi4_agent2 = 1; //switch to instantiate an agent #2
    axi4_stream_config axi4_agent_handler1;
    axi4_stream_config axi4_agent_handler2;
    function new(string name = "");
        super.new(name);
    endfunction: new
endclass: axi4_stream_agents_config
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_SEQUENCE_ITEMES
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_SEQUENCE_ITEM : RGB_TRANSACTION [RGB]
class rgb_transaction#(parameter set_config cfg = par_1) extends uvm_sequence_item;
    rand bit[cfg.w_p1.data_width-1:0]       iRed;
    rand bit[cfg.w_p1.data_width-1:0]       iGreen;
    rand bit[cfg.w_p1.data_width-1:0]       iBlue;
    rand bit            iPixelEn;
    rand bit            iValid;
    rand bit            iEof;
    rand bit [cfg.w_p1.addr_width-1:0]      iX;
    rand bit [cfg.w_p1.addr_width-1:0]      iY;
    function new(string name = "");
        super.new(name);
    endfunction: new
    `uvm_object_utils_begin(rgb_transaction#(cfg))
        `uvm_field_int(iRed,         UVM_ALL_ON)
        `uvm_field_int(iGreen,       UVM_ALL_ON)
        `uvm_field_int(iBlue,        UVM_ALL_ON)
        `uvm_field_int(iPixelEn,     UVM_ALL_ON)
        `uvm_field_int(iEof,         UVM_ALL_ON)
        `uvm_field_int(iValid,       UVM_ALL_ON)
        `uvm_field_int(iX,           UVM_ALL_ON)
        `uvm_field_int(iY,           UVM_ALL_ON)
    `uvm_object_utils_end
endclass: rgb_transaction
// UVM_SEQUENCE_ITEM : AXILITE_TXN [AXILITE]
class axiLite_transaction extends uvm_sequence_item;
    rand bit [15:0]     addr;
    rand bit [31:0]     data;
    rand bit [31:0]     WDATA;
    rand bit [31:0]     RDATA;
    rand axiLite_txn_e  reqWriteRead;
    rand int unsigned   cycles;
    constraint c_cycles { 
    cycles <= 20; }
    function new (string name = "");
        super.new(name);
    endfunction
    function string convert2string();
        return $sformatf("addr='h%h, data='h%0h, cycles='d%0d",addr, data, cycles);
    endfunction
    `uvm_object_utils_begin(axiLite_transaction)
        `uvm_field_int  (addr,                          UVM_DEFAULT)
        `uvm_field_int  (data,                          UVM_DEFAULT)
        `uvm_field_int  (WDATA,                         UVM_DEFAULT)
        `uvm_field_int  (RDATA,                         UVM_DEFAULT)
        `uvm_field_enum (axiLite_txn_e, reqWriteRead,   UVM_DEFAULT)    
        `uvm_field_int  (cycles,                        UVM_DEFAULT)
    `uvm_object_utils_end
endclass: axiLite_transaction
// UVM_SEQUENCE_ITEM : TEMPLATE_TRANSACTION [TEMPLATE]
class template_transaction extends uvm_sequence_item;
    rand bit[1:0] ina;
    rand bit[1:0] inb;
    bit[2:0]      out;
    function new(string name = "");
        super.new(name);
    endfunction: new
    `uvm_object_utils_begin(template_transaction)
        `uvm_field_int(ina, UVM_ALL_ON)
        `uvm_field_int(inb, UVM_ALL_ON)
        `uvm_field_int(out, UVM_ALL_ON)
    `uvm_object_utils_end
endclass: template_transaction
class axi4_stream_valid_cycle  extends uvm_sequence_item;
    rand bit [15:0]    tdata;
    rand bit               tuser;
    rand int unsigned      delay = 0;
    constraint c_packet_delay {
        delay < 20 ;
    }
    function new(string name = "");
        super.new(name);
    endfunction: new
    `uvm_object_utils_begin(axi4_stream_valid_cycle)
        `uvm_field_int(tdata, UVM_ALL_ON | UVM_NOPACK | UVM_HEX)
        `uvm_field_int(tuser, UVM_ALL_ON | UVM_NOPACK | UVM_HEX)
        `uvm_field_int(delay, UVM_DEFAULT | UVM_DEC| UVM_NOPACK)
    `uvm_object_utils_end
endclass : axi4_stream_valid_cycle
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_SEQUENCERS
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_SEQUENCE : TEMPLATE_SEQUENCER [TEMPLATE]
class template_sequencer extends uvm_sequencer #(template_transaction);
    `uvm_component_utils(template_sequencer)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass: template_sequencer
// UVM_SEQUENCE : AXILITE_SQR [AXILITE]
class axiLite_sequencer extends uvm_sequencer #(axiLite_transaction);
    int id;
    `uvm_component_utils_begin(axiLite_sequencer)
        `uvm_field_int(id, UVM_DEFAULT)
    `uvm_component_utils_end
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass: axiLite_sequencer
// UVM_SEQUENCE : RGB_SEQUENCER [RGB]
class rgb_sequencer#(parameter set_config cfg = par_1) extends uvm_sequencer#(rgb_transaction#(cfg));
    `uvm_component_param_utils(rgb_sequencer#(cfg))
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass: rgb_sequencer
class axi4_stream_master_sequencer extends uvm_sequencer #(axi4_stream_valid_cycle);
    `uvm_component_utils(axi4_stream_master_sequencer)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : axi4_stream_master_sequencer
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_SEQUENCES
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_SEQUENCE : RGB_RANDOM_SEQUENCE [RGB]
class rgb_random_sequence#(parameter set_config cfg = par_1) extends uvm_sequence#(rgb_transaction#(cfg));
    `uvm_object_param_utils(rgb_random_sequence#(cfg));
    function new(string name = "rgb_random_sequence");
        super.new(name);
    endfunction : new
    task body();
    rgb_transaction#(cfg) frame_tx = rgb_transaction#(cfg)::type_id::create("frame_tx");
        repeat (100000) begin : random_loop
            start_item(frame_tx);
            assert(frame_tx.randomize());
            finish_item(frame_tx);
        end : random_loop
    endtask : body
endclass : rgb_random_sequence
// UVM_SEQUENCE : RANDOM_SEQUENCE_R1 [RGB]
class random_sequence_r1#(parameter set_config cfg = par_1) extends uvm_sequence#(rgb_transaction#(cfg));
    `uvm_object_param_utils(random_sequence_r1#(cfg));
    function new(string name = "random_sequence_r1");
        super.new(name);
    endfunction : new
    task body();
    rgb_transaction#(cfg) frame_tx = rgb_transaction#(cfg)::type_id::create("frame_tx");
    `uvm_info("random_sequence_r1", "executing...", UVM_LOW)
        repeat (100) begin : random_loop
            start_item(frame_tx);
            assert(frame_tx.randomize());
            finish_item(frame_tx);
        end : random_loop
    endtask : body
endclass : random_sequence_r1
// UVM_SEQUENCE : RANDOM_SEQUENCE_R2 [RGB]
class random_sequence_r2 extends random_sequence_r1;
    `uvm_object_utils(random_sequence_r2);
    function new(string name = "random_sequence_r2");
        super.new(name);
    endfunction : new
    task body();
    rgb_transaction#(cfg) frame_tx = rgb_transaction#(cfg)::type_id::create("frame_tx");
    `uvm_info("random_sequence_r2", "executing...", UVM_LOW)
        repeat (1) begin : random_loop
            start_item(frame_tx);
            assert(frame_tx.randomize());
            finish_item(frame_tx);
        end : random_loop
    endtask : body
endclass : random_sequence_r2
// UVM_SEQUENCE : TOP_SEQUENCE [RGB]
class top_sequence extends uvm_sequence #(rgb_transaction);
    `uvm_object_utils(top_sequence)
    `uvm_declare_p_sequencer(rgb_sequencer)
    function new (string name = "");
        super.new(name);
    endfunction
    task body;
        rgb_configuration cfg;
        int count;
        if ( uvm_config_db #(rgb_configuration)::get(p_sequencer, "", "config", cfg) ) begin
            count    = cfg.count;
        end
        else begin
            count    = 1;
        end
        if (starting_phase != null)
            starting_phase.raise_objection(this);
        repeat(count) begin
            random_sequence_r1#(par_1) seq;
            seq = random_sequence_r1#(par_1)::type_id::create("seq");
            seq.start(p_sequencer, this);
        end
        if (starting_phase != null)
            starting_phase.drop_objection(this);
    endtask: body
endclass: top_sequence
// UVM_SEQUENCE : AXILITE_BASE_SEQ [AXILITE]
virtual class axiLite_base_seq extends uvm_sequence #(axiLite_transaction);
    function new (string name="axiLite_base_seq");
        super.new(name);
    endfunction
endclass: axiLite_base_seq
// UVM_SEQUENCE : AXILITE_NO_ACTIVITY_SEQ [AXILITE]
class axiLite_no_activity_sequence extends axiLite_base_seq;
    `uvm_object_utils(axiLite_no_activity_sequence)
    function new(string name="axiLite_no_activity_sequence");
        super.new(name);
    endfunction
    virtual task body();
        `uvm_info("SEQ", "executing", UVM_LOW)
    endtask: body
endclass: axiLite_no_activity_sequence
// UVM_SEQUENCE : AXILITE_RANDOM_SEQ [AXILITE]
class axiLite_random_sequence extends axiLite_base_seq;
    `uvm_object_utils(axiLite_random_sequence)
    function new(string name="axiLite_random_sequence");
        super.new(name);
    endfunction
    virtual task body();
        axiLite_transaction item;
        int num_txn;
        bit typ_txn;
        `uvm_info("SEQ", "executing...", UVM_LOW)
        num_txn = $urandom_range(5,20);
        repeat(num_txn) begin    
        `uvm_create(item)
        item.cycles         = $urandom_range(1,5);
        item.addr           = $urandom();
        item.data           = $urandom();
        typ_txn             = $random();
        item.reqWriteRead   = typ_txn ? WRITE : READ; 
        `uvm_send(item);
        end    
    endtask: body
endclass: axiLite_random_sequence
// UVM_SEQUENCE : AXILITE_DIRECTED_SEQ [AXILITE]
class axiLite_directed_sequence extends axiLite_base_seq;
    `uvm_object_utils(axiLite_directed_sequence)
    function new(string name="axiLite_directed_sequence");
        super.new(name);
    endfunction
    virtual task body();
        axiLite_transaction item;
        bit [8:0] addr;
        `uvm_info("SEQ", "executing...WR->RD->WR->RD", UVM_LOW)
        for(addr = 0; addr < 256; addr ++) begin
            `uvm_create(item)
            item.addr           = {14'h0,addr[7:0]};
            item.reqWriteRead   = addr[0] ? READ : WRITE;
            item.cycles         = 0;
            item.data           = addr;
            `uvm_send(item);
        end
        `uvm_info("SEQ", "executing...WR->WR->RD->RD", UVM_LOW)
        for(addr = 0; addr < 255; addr ++) begin
            `uvm_create(item)
            item.addr           = {14'h0,addr[7:0]};
            item.reqWriteRead   = addr[8] ? READ : WRITE;
            item.cycles         = 5;
            item.data           = addr;
            `uvm_send(item);
        end
    endtask: body
endclass: axiLite_directed_sequence
// UVM_SEQUENCE : AXILITE_USEVAR_SEQ [AXILITE]
class axiLite_usevar_sequence extends axiLite_base_seq;
    `uvm_object_utils(axiLite_usevar_sequence)
    `uvm_declare_p_sequencer(axiLite_sequencer)
    function new(string name="axiLite_usevar_sequence");
        super.new(name);
    endfunction
    virtual task body();
    axiLite_transaction item;
    int id;
    `uvm_info("SEQ", "executing...", UVM_LOW)
    id = p_sequencer.id;
    `uvm_info("SEQ", $sformatf("using id=%0hh from sequencer", id), UVM_LOW)
    `uvm_create(item)
    item.cycles = $urandom_range(1,5);
    item.data = id;
    `uvm_send(item);
    endtask
endclass:axiLite_usevar_sequence
// UVM_SEQUENCE : TEMPLATE_BASE_SEQ [TEMPLATE]
virtual class template_base_sequence extends uvm_sequence #(template_transaction);
    function new (string name="template_base_sequence");
        super.new(name);
    endfunction
endclass: template_base_sequence
// UVM_SEQUENCE : TEMPLATE_SEQUENCE [TEMPLATE]
class template_sequence extends uvm_sequence#(template_transaction);
    `uvm_object_utils(template_sequence)
    function new(string name = "");
        super.new(name);
    endfunction: new
    task body();
        template_transaction tx;
        repeat(10000) begin
        tx = template_transaction::type_id::create(.name("tx"), .contxt(get_full_name()));
        start_item(tx);
            assert(tx.randomize());
            //`uvm_info("sa_sequence", tx.sprint(), UVM_LOW);
        finish_item(tx);
        end
    endtask: body
endclass: template_sequence
class ax_packet extends uvm_sequence_item;
parameter AX_TYPE_MASK = 6'h38;
	// request header fields
	rand bit [2:0]			cube_ID;				// CUB
	rand bit [33:0]		    address;				// ADRS
	rand bit [8:0]			tag;					// TAG
	rand bit [3:0]			packet_length;			// LNG 128-bit (16-byte) flits
	rand bit [3:0]			duplicate_length;		// DLN
	rand ax_command_encoding 	command;			// CMD
	bit [127:0]				payload[$];				// 16-byte granularity
	// request tail fields
	rand bit [4:0]			return_token_count;		// RTC
	rand bit [2:0]			source_link_ID;			// SLID
	rand bit [2:0]			sequence_number;		// SEQ
	rand bit [7:0]			forward_retry_pointer;	// FRP
	rand bit [7:0]			return_retry_pointer;	// RRP
	rand bit [31:0]		packet_crc;				// CRC
	// response header fields not used before
	rand bit [8:0]			return_tag;				// TGA (Optional)
	// response tail fields not used before
	rand bit [6:0]			error_status;			// ERRSTAT
	rand bit				data_invalid;			// DINV
	// special bits for IRTRY
	rand bit				start_retry;
	rand bit				clear_error_abort;
	// CRC status fields
	rand bit				poisoned;				// Inverted CRC
	rand bit				crc_error;
	// helper fields
	rand int				flit_delay;
	int						timestamp;
	`uvm_object_utils_begin(ax_packet)
		`uvm_field_int(flit_delay, UVM_ALL_ON | UVM_NOPACK | UVM_DEC | UVM_NOCOMPARE | UVM_DEC)
		`uvm_field_int(cube_ID, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(address, UVM_ALL_ON | UVM_NOPACK | UVM_HEX)
		`uvm_field_int(tag, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(packet_length, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(duplicate_length, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_enum(ax_command_encoding, command, UVM_ALL_ON | UVM_NOPACK )
		`uvm_field_queue_int(payload, UVM_ALL_ON | UVM_NOPACK)
		`uvm_field_int(return_token_count, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(source_link_ID, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(sequence_number, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(forward_retry_pointer, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(return_retry_pointer, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(packet_crc, UVM_ALL_ON | UVM_NOPACK | UVM_HEX)
		`uvm_field_int(return_tag, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(error_status, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(data_invalid, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(poisoned, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
		`uvm_field_int(crc_error, UVM_ALL_ON | UVM_NOPACK | UVM_DEC)
	`uvm_object_utils_end
	constraint c_poisoned { poisoned == 0; }
	constraint c_cube_id {cube_ID ==0;}
	constraint c_address {
		soft address < 80000000;
		((command & AX_TYPE_MASK) == AX_FLOW_TYPE) -> address == 0;	
		soft address[3:0]==4'h0;
	}
	constraint c_source_link_ID {source_link_ID ==0;}
	constraint c_crc_error { crc_error == 0; }
	constraint c_matching_length { packet_length == duplicate_length; }
	constraint c_return_tag { return_tag == 0; }
	constraint c_packet_length { (
						(packet_length == 2 && command == AX_POSTED_WRITE_16) ||
						(packet_length == 3 && command == AX_POSTED_WRITE_32) ||
						(packet_length == 4 && command == AX_POSTED_WRITE_48) ||
						(packet_length == 5 && command == AX_POSTED_WRITE_64) ||
						(packet_length == 6 && command == AX_POSTED_WRITE_80) ||
						(packet_length == 7 && command == AX_POSTED_WRITE_96) ||
						(packet_length == 8 && command == AX_POSTED_WRITE_112) ||
						(packet_length == 9 && command == AX_POSTED_WRITE_128) ||
						(packet_length == 2 && command == AX_WRITE_16) ||
						(packet_length == 3 && command == AX_WRITE_32) ||
						(packet_length == 4 && command == AX_WRITE_48) ||
						(packet_length == 5 && command == AX_WRITE_64) ||
						(packet_length == 6 && command == AX_WRITE_80) ||
						(packet_length == 7 && command == AX_WRITE_96) ||
						(packet_length == 8 && command == AX_WRITE_112) ||
						(packet_length == 9 && command == AX_WRITE_128) ||
						(packet_length > 1 && packet_length <= 9 && command == AX_READ_RESPONSE) ||
						(packet_length == 1 && command == AX_WRITE_RESPONSE) ||
						(packet_length == 1 && command == AX_MODE_WRITE_RESPONSE) ||
						(packet_length == 1 && command == AX_ERROR_RESPONSE) ||
						(packet_length == 2 && (command & AX_TYPE_MASK) == AX_MISC_WRITE_TYPE) ||
						(packet_length == 2 && (command & AX_TYPE_MASK) == AX_POSTED_MISC_WRITE_TYPE) ||
						(packet_length == 1 && (command & AX_TYPE_MASK) == AX_MODE_READ_TYPE) ||
						(packet_length == 1 && (command & AX_TYPE_MASK) == AX_READ_TYPE) ||
						(packet_length == 1 && (command & AX_TYPE_MASK) == AX_FLOW_TYPE)
		); }
	constraint c_flit_delay {
		soft flit_delay dist{0:/90, [1:8]:/8, [8:200]:/2  };
	}
	constraint c_error_status {
		soft error_status == 0;
	}
	constraint c_data_invalid {
		soft data_invalid == 0;
	}
	constraint c_pret {
		(command == AX_PRET)-> forward_retry_pointer	==0;
		(command == AX_PRET)-> sequence_number			==0;
	}
	constraint c_irtry{
		(command == AX_IRTRY) 							-> start_retry 			!= clear_error_abort;
		((command == AX_IRTRY)&&(start_retry)) 		->forward_retry_pointer == 1;
		((command == AX_IRTRY)&&(clear_error_abort))	->forward_retry_pointer == 2;
		(command == AX_IRTRY)							-> sequence_number		== 0;
	}
	constraint c_flow {
		((command & AX_TYPE_MASK) == AX_FLOW_TYPE) -> tag == 0;
		((command & AX_TYPE_MASK) == AX_FLOW_TYPE) -> cube_ID == 0;
	}
	function new (string name = "ax_packet");
		super.new(name);
	endfunction : new
    function void post_randomize();
		bit [127:0] rand_flit;
        super.post_randomize();
		if (packet_length > 9)
			`uvm_fatal(get_type_name(),$psprintf("post_randomize packet_length = %0d",packet_length))
		`uvm_info("AXI Packet queued",$psprintf("%0s packet_length = %0d",command.name(), packet_length), UVM_HIGH)
		if (packet_length < 2)
			return;
		for (int i=0; i<packet_length-1; i++) begin
			randomize_flit_successful : assert (std::randomize(rand_flit));
			payload.push_back(rand_flit);
		end
		if ((command == AX_POSTED_DUAL_8B_ADDI)||
			(command == AX_DUAL_8B_ADDI)) begin
			payload[0] [63:32] = 32'b0;
			payload[0][127:96] = 32'b0;
		end
		if ((command == AX_MODE_WRITE)|| (command == AX_MODE_READ)) begin
			payload[0][127:32] = 96'b0;
		end
    endfunction
	function ax_command_type get_command_type();
		case(command & AX_TYPE_MASK)
			AX_FLOW_TYPE:				return AX_FLOW_TYPE;
			AX_READ_TYPE:				return AX_READ_TYPE;
			AX_MODE_READ_TYPE:			return AX_MODE_READ_TYPE;
			AX_POSTED_WRITE_TYPE:		return AX_POSTED_WRITE_TYPE;
			AX_POSTED_MISC_WRITE_TYPE:	return AX_POSTED_MISC_WRITE_TYPE;
			AX_WRITE_TYPE:				return AX_WRITE_TYPE;
			AX_MISC_WRITE_TYPE:		return AX_MISC_WRITE_TYPE;
			AX_RESPONSE_TYPE:			return AX_RESPONSE_TYPE;
			default: uvm_report_fatal(get_type_name(), $psprintf("command with an illegal command type='h%0h!", command));
		endcase
	endfunction : get_command_type
/*
		The CRC algorithm used on the AX is the Koopman CRC-32K. This algorithm was
		chosen for the AX because of its balance of coverage and ease of implementation. The
		polynomial for this algorithm is:
		x32 + x30 + x29 + x28 + x26 + x20 + x19 + x17 + x16 + x15 + x11 + x10 + x7 + x6 + x4 + x2 + x + 1
		bit [31:0] polynomial = 33'b1_0111_0100_0001_1011_1000_1100_1101_0111;	// Normal
		The CRC calculation operates on the LSB of the packet first. The packet CRC calculation
		must insert 0s in place of the 32-bits representing the CRC field before generating or
		checking the CRC. For example, when generating CRC for a packet, bits [63: 32] of the
		Tail presented to the CRC generator should be all zeros. The output of the CRC generator
		will have a 32-bit CRC value that will then be inserted in bits [63:32] of the Tail before
		forwarding that FLIT of the packet. When checking CRC for a packet, the CRC field
		should be removed from bits [63:32] of the Tail and replaced with 32-bits of zeros, then
		presented to the CRC checker. The output of the CRC checker will have a 32-bit CRC
		value that can be compared with the CRC value that was removed from the tail. If the two
		compare, the CRC check indicates no bit failures within the packet.
*/
	function bit [31:0] calculate_crc();
		bit bitstream[];
		packer_succeeded : assert (pack(bitstream) > 0);
		return calc_crc(bitstream);
	endfunction : calculate_crc
	function bit [31:0] calc_crc(bit bitstream[]);
		bit [32:0] polynomial = 33'h1741B8CD7; // Normal
		bit [32:0] remainder = 33'h0;
		for( int i=0; i < bitstream.size()-32; i++ ) begin	// without the CRC
			remainder = {remainder[31:0], bitstream[i]};
			if( remainder[32] ) begin
				remainder = remainder ^ polynomial;
			end
		end
		for( int i=0; i < 64; i++ ) begin	// zeroes for CRC and remainder
			remainder = {remainder[31:0], 1'b0};
			if( remainder[32] ) begin
				remainder = remainder ^ polynomial;
			end
		end
		return remainder[31:0];
	endfunction : calc_crc
	virtual function void do_pack(uvm_packer packer);
		super.do_pack(packer);
		packer.big_endian = 0;
		// pack header half flit
		case(command & AX_TYPE_MASK)
			AX_FLOW_TYPE:
				case (command)
					AX_NULL:		packer.pack_field( {64'h0}, 64);
					AX_PRET:		packer.pack_field ( {3'h0, 3'h0, 34'h0, 9'h0, duplicate_length[3:0], packet_length[3:0], 1'b0, command[5:0]}, 64);
					AX_TRET:		packer.pack_field ( {3'h0, 3'h0, 34'h0, 9'h0, duplicate_length[3:0], packet_length[3:0], 1'b0, command[5:0]}, 64);
					AX_IRTRY:		packer.pack_field ( {3'h0, 3'h0, 34'h0, 9'h0, duplicate_length[3:0], packet_length[3:0], 1'b0, command[5:0]}, 64);
					default: uvm_report_fatal(get_type_name(), $psprintf("pack function called for a ax_packet with an illegal FLOW type='h%0h!", command));
				endcase
			AX_READ_TYPE:			packer.pack_field ( {cube_ID[2:0], 3'h0, address[33:0], tag[8:0], duplicate_length[3:0], packet_length[3:0], 1'b0, command[5:0]}, 64);
			AX_MODE_READ_TYPE:		packer.pack_field ( {cube_ID[2:0], 3'h0, 34'h0, tag[8:0], duplicate_length[3:0], packet_length[3:0], 1'b0, command[5:0]}, 64);
			AX_POSTED_WRITE_TYPE:	packer.pack_field ( {cube_ID[2:0], 3'h0, address[33:0], tag[8:0], duplicate_length[3:0], packet_length[3:0], 1'b0, command[5:0]}, 64);
			AX_WRITE_TYPE:			packer.pack_field ( {cube_ID[2:0], 3'h0, address[33:0], tag[8:0], duplicate_length[3:0], packet_length[3:0], 1'b0, command[5:0]}, 64);
			AX_POSTED_MISC_WRITE_TYPE:	packer.pack_field ( {cube_ID[2:0], 3'h0, address[33:0], tag[8:0], duplicate_length[3:0], packet_length[3:0], 1'b0, command[5:0]}, 64);
			AX_MISC_WRITE_TYPE:	packer.pack_field ( {cube_ID[2:0], 3'h0, address[33:0], tag[8:0], duplicate_length[3:0], packet_length[3:0], 1'b0, command[5:0]}, 64);
			AX_RESPONSE_TYPE:		packer.pack_field ( {22'h0, source_link_ID[2:0], 6'h0, return_tag[8:0], tag[8:0], duplicate_length[3:0], packet_length[3:0], 1'b0, command[5:0]}, 64);
			default: uvm_report_fatal(get_type_name(), $psprintf("pack function called for a ax_packet with an illegal command type='h%0h!", command));
		endcase
		// Allow for errors when packet_length != duplicate_length
		if ((packet_length == duplicate_length) && payload.size() + 1 != packet_length && command != AX_NULL)
			uvm_report_fatal(get_type_name(), $psprintf("pack function size mismatch payload.size=%0d packet_length=%0d!", payload.size(), packet_length));
		// pack payload
		for( int i=0; i<payload.size(); i++ ) packer.pack_field ( payload[i], 128);
		// pack tail half flit
		case(command & AX_TYPE_MASK)
			AX_FLOW_TYPE:
				case (command)
					AX_NULL:		packer.pack_field( {64'h0}, 64);
					AX_PRET:		packer.pack_field ( {packet_crc[31:0], 5'h0, 3'h0, 5'h0, 3'h0, 8'h0, return_retry_pointer[7:0]}, 64);
					AX_TRET:		packer.pack_field ( {packet_crc[31:0], return_token_count[4:0], 3'h0, 5'h0, sequence_number[2:0], forward_retry_pointer[7:0], return_retry_pointer[7:0]}, 64);
					AX_IRTRY:		packer.pack_field ( {packet_crc[31:0], 5'h0, 3'h0, 5'h0, 3'h0, 6'h0, clear_error_abort, start_retry, return_retry_pointer[7:0]}, 64);
					default: uvm_report_fatal(get_type_name(), $psprintf("pack function (tail) called for a ax_packet with an illegal FLOW type='h%0h!", command));
				endcase
			AX_READ_TYPE:			packer.pack_field ( {packet_crc[31:0], return_token_count[4:0], source_link_ID[2:0], 5'h0, sequence_number[2:0], forward_retry_pointer[7:0], return_retry_pointer[7:0]}, 64);
			AX_POSTED_WRITE_TYPE:	packer.pack_field ( {packet_crc[31:0], return_token_count[4:0], source_link_ID[2:0], 5'h0, sequence_number[2:0], forward_retry_pointer[7:0], return_retry_pointer[7:0]}, 64);
			AX_WRITE_TYPE:			packer.pack_field ( {packet_crc[31:0], return_token_count[4:0], source_link_ID[2:0], 5'h0, sequence_number[2:0], forward_retry_pointer[7:0], return_retry_pointer[7:0]}, 64);
			AX_MODE_READ_TYPE:		packer.pack_field ( {packet_crc[31:0], return_token_count[4:0], source_link_ID[2:0], 5'h0, sequence_number[2:0], forward_retry_pointer[7:0], return_retry_pointer[7:0]}, 64);
			AX_POSTED_MISC_WRITE_TYPE:	packer.pack_field ( {packet_crc[31:0], return_token_count[4:0], source_link_ID[2:0], 5'h0, sequence_number[2:0], forward_retry_pointer[7:0], return_retry_pointer[7:0]}, 64);
			AX_MISC_WRITE_TYPE:	packer.pack_field ( {packet_crc[31:0], return_token_count[4:0], source_link_ID[2:0], 5'h0, sequence_number[2:0], forward_retry_pointer[7:0], return_retry_pointer[7:0]}, 64);
			AX_RESPONSE_TYPE:		packer.pack_field ( {packet_crc[31:0], return_token_count[4:0], error_status[6:0], data_invalid, sequence_number[2:0], forward_retry_pointer[7:0], return_retry_pointer[7:0]}, 64);
			default: uvm_report_fatal(get_type_name(), $psprintf("pack function (tail) called for a ax_packet with an illegal command type='h%0h!", command));
		endcase
	endfunction : do_pack
	virtual function void do_unpack(uvm_packer packer);
		bit [63:0]	header;
		bit [63:0]	tail;
		bit [31:0]	calculated_crc;
		bit [21:0]	rsvd22;
		bit [5:0]	rsvd6;
		bit [4:0]	rsvd5;
		bit [2:0]	rsvd3;
		bit 		rsvd1;
		bit bitstream[];
		super.do_unpack(packer);
		packer.big_endian = 0;
		packer.get_bits(bitstream);
		for (int i = 0; i <32; i++)begin
			packet_crc[i] = bitstream[bitstream.size()-32 +i];
		end
		calculated_crc = calc_crc(bitstream);
		// header
		header = packer.unpack_field(64);
		command[5:0] = header[5:0];//-- doppelt?
		if (get_command_type != AX_RESPONSE_TYPE)
			{cube_ID[2:0], rsvd3, address[33:0], tag[8:0], duplicate_length[3:0], packet_length[3:0], rsvd1, command[5:0]}	= header;
		else
			{rsvd22[21:0], source_link_ID[2:0], rsvd6[5:0], return_tag[8:0], tag[8:0], duplicate_length[3:0], packet_length[3:0], rsvd1, command[5:0]}	= header;
		// Unpack should not be called with length errors
		if (duplicate_length != packet_length || packet_length == 0)
			`uvm_fatal(get_type_name(), $psprintf("do_unpack: length mismatch dln=%0d len=%0d cmd=%0d!", duplicate_length, packet_length, command));
		// payload
		for (int i = 0; i < packet_length-1; i++)
			payload.push_back(packer.unpack_field(128));
		// tail
		tail = packer.unpack_field(64);
		if (get_command_type != AX_RESPONSE_TYPE) 
			{packet_crc[31:0], return_token_count[4:0], source_link_ID[2:0], rsvd5, sequence_number[2:0], forward_retry_pointer[7:0], return_retry_pointer[7:0]}	= tail;
		else
			{packet_crc[31:0], return_token_count[4:0], error_status[6:0], data_invalid, sequence_number[2:0], forward_retry_pointer[7:0], return_retry_pointer[7:0]}	= tail;
		start_retry			= (command == AX_IRTRY ? forward_retry_pointer[0] : 1'b0);
		clear_error_abort	= (command == AX_IRTRY ? forward_retry_pointer[1] : 1'b0);
		crc_error = 0;
		poisoned = (packet_crc == ~calculated_crc) ? 1'b1 : 1'b0;
		if (packet_crc != calculated_crc &&  !poisoned )
		begin
			crc_error = 1;
		end
	endfunction : do_unpack
	virtual function bit compare_adaptive_packet(ax_packet rhs, uvm_comparer comparer);
		string name_string;
		compare_adaptive_packet &= comparer.compare_field("packet_length", packet_length, rhs.packet_length, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("payload.size()", payload.size(), rhs.payload.size(), 64, UVM_DEC);
		for (int i=0; i<packet_length; i++)
		begin
			if (!compare_adaptive_packet)
				return 0;
			$sformat(name_string, "payload[%0d]", i);
			compare_adaptive_packet &= comparer.compare_field(name_string, payload[i], rhs.payload[i], 128, UVM_HEX);
		end
		compare_adaptive_packet &= comparer.compare_field("cube_ID", cube_ID, rhs.cube_ID, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("address", address, rhs.address, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("tag", tag, rhs.tag, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("packet_length", packet_length, rhs.packet_length, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("duplicate_length", duplicate_length, rhs.duplicate_length, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("command", command, rhs.command, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("return_token_count", return_token_count, rhs.return_token_count, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("source_link_ID", source_link_ID, rhs.source_link_ID, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("sequence_number", sequence_number, rhs.sequence_number, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("forward_retry_pointer", forward_retry_pointer, rhs.forward_retry_pointer, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("return_tag", return_tag, rhs.return_tag, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("error_status", error_status, rhs.error_status, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("data_invalid", data_invalid, rhs.data_invalid, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("start_retry", start_retry, rhs.start_retry, 64, UVM_DEC);
		compare_adaptive_packet &= comparer.compare_field("clear_error_abort", clear_error_abort, rhs.clear_error_abort, 64, UVM_DEC);
	endfunction : compare_adaptive_packet
endclass : ax_packet
class axi4_stream_master_sequence extends uvm_sequence#(axi4_stream_valid_cycle);
	`uvm_object_utils(axi4_stream_master_sequence)
	rand int delay;
	rand ax_packet response;
	rand bit error_response;
    event item_available;
	constraint delay_c {
		delay dist {0:=4, [0:9]:=8, [10:30]:=2, [31:100]:=1};
	}
    function new(string name = "");
        super.new(name);
    endfunction: new
    task body();
        axi4_stream_valid_cycle vc;
        repeat(100) begin
        vc = axi4_stream_valid_cycle::type_id::create(.name("vc"), .contxt(get_full_name()));
        start_item(vc);
            assert(vc.randomize());
        finish_item(vc);
        end
    endtask : body
endclass : axi4_stream_master_sequence
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_DRIVERS
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_DRIVER : AXILITE_DRV [AXILITE]
class axiLite_driver extends uvm_driver #(axiLite_transaction);
    protected virtual axiLite_if axiLiteVif;
    protected int     id;
    `uvm_component_utils_begin(axiLite_driver)
        `uvm_field_int(id, UVM_DEFAULT)
    `uvm_component_utils_end
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axiLite_if)::get(this, "", "axiLiteVif", axiLiteVif))
        `uvm_fatal("NOVIF", {"virtual interface must be set for: ",
        get_full_name(), ".axiLiteVif"});
    endfunction
    virtual task run_phase (uvm_phase phase);
        fork
            get_and_drive();
            reset_signals();
        join
    endtask: run_phase
    virtual protected task get_and_drive();
        forever begin
            @(posedge axiLiteVif.ACLK);
            if (axiLiteVif.ARESETN == 1'b0) begin
                @(posedge axiLiteVif.ARESETN);
                @(posedge axiLiteVif.ACLK);
            end
            seq_item_port.get_next_item(req);
            //`uvm_info("DRV", req.convert2string(), UVM_LOW)
            repeat(req.cycles) begin
                @(posedge axiLiteVif.ACLK);
            end
            drive_transfer(req);
            seq_item_port.item_done();
        end
    endtask: get_and_drive
    virtual protected task reset_signals();
        forever begin
            @(negedge axiLiteVif.ARESETN);
            axiLiteVif.AWADDR  <=  8'h0;
            axiLiteVif.AWPROT  <=  3'h0;
            axiLiteVif.AWVALID <=  1'b0;
            axiLiteVif.WDATA   <= 32'h0;
            axiLiteVif.WSTRB   <=  4'h0;
            axiLiteVif.WVALID  <=  1'b0;
            axiLiteVif.BREADY  <=  1'b1;
            axiLiteVif.ARADDR  <=  8'h0;
            axiLiteVif.ARPROT  <=  3'h0;
            axiLiteVif.ARVALID <=  1'b0;
            axiLiteVif.RREADY  <=  1'b1;
        end
    endtask: reset_signals
    virtual protected task drive_transfer (axiLite_transaction aL_txn);
        drive_address_phase(aL_txn);
        drive_data_phase(aL_txn);
    endtask: drive_transfer
    virtual protected task drive_address_phase (axiLite_transaction aL_txn);
        //`uvm_info("axiLite_master_driver", "drive_address_phase",UVM_HIGH)
        case (aL_txn.reqWriteRead)
            READ : drive_read_address_channel(aL_txn);
            WRITE: drive_write_address_channel(aL_txn);
        endcase
    endtask: drive_address_phase
    virtual protected task drive_data_phase (axiLite_transaction aL_txn);
        bit[31:0] rw_data;
        bit err;
        rw_data = aL_txn.data;
        case (aL_txn.reqWriteRead)
        READ : drive_read_data_channel(rw_data, err);
        WRITE: drive_write_data_channel(rw_data, err);
        endcase    
    endtask: drive_data_phase
    virtual protected task drive_write_address_channel (axiLite_transaction aL_txn);
        int axiLite_ctr;
        axiLiteVif.AWADDR  <= {8'h0, aL_txn.addr};
        axiLiteVif.AWPROT  <= 3'h0;
        axiLiteVif.AWVALID <= 1'b1;
        for(axiLite_ctr = 0; axiLite_ctr <= 31; axiLite_ctr ++) begin
            @(posedge axiLiteVif.ACLK);
            if (axiLiteVif.AWREADY) break;
        end
        if (axiLite_ctr == 31) begin
            `uvm_error("axiLite_master_driver","AWVALID timeout");
        end    
        @(posedge axiLiteVif.ACLK);
        // axiLiteVif.AWADDR  <= 8'h0;
        // axiLiteVif.AWPROT  <= 3'h0;
        // axiLiteVif.AWVALID <= 1'b0;    
    endtask: drive_write_address_channel
    virtual protected task drive_read_address_channel (axiLite_transaction aL_txn);
        int axiLite_ctr;
        axiLiteVif.ARADDR  <= {8'h0, aL_txn.addr};
        axiLiteVif.ARPROT  <= 3'h0;
        axiLiteVif.ARVALID <= 1'b1;
        for(axiLite_ctr = 0; axiLite_ctr <= 31; axiLite_ctr ++) begin
            @(posedge axiLiteVif.ACLK);
            if (axiLiteVif.ARREADY) break;
        end
        if (axiLite_ctr == 31) begin
            `uvm_error("axiLite_master_driver","ARVALID timeout");
        end
        @(posedge axiLiteVif.ACLK);
        axiLiteVif.ARADDR  <= 8'h0;
        axiLiteVif.ARPROT  <= 3'h0;
        axiLiteVif.ARVALID <= 1'b0;    
    endtask: drive_read_address_channel
    virtual protected task drive_write_data_channel (bit[31:0] data, output bit error);
        int axiLite_ctr;
        axiLiteVif.WDATA  <= data;
        axiLiteVif.WSTRB  <= 4'hf;
        axiLiteVif.WVALID <= 1'b1;
        @(posedge axiLiteVif.ACLK);
            for(axiLite_ctr = 0; axiLite_ctr <= 31; axiLite_ctr ++) begin
            @(posedge axiLiteVif.ACLK);
            if (axiLiteVif.WREADY) 
                    axiLiteVif.AWADDR  <= 8'h0;
        axiLiteVif.AWPROT  <= 3'h0;
        axiLiteVif.AWVALID <= 1'b0; 
            break;
        end
        if (axiLite_ctr == 31) begin
            `uvm_error("axiLite_master_driver","AWVALID timeout");
        end
        @(posedge axiLiteVif.ACLK);
        axiLiteVif.WDATA  <= 32'h0;
        axiLiteVif.WSTRB  <= 4'h0;
        axiLiteVif.WVALID <= 1'b0;
        //wait for write response
        for(axiLite_ctr = 0; axiLite_ctr <= 31; axiLite_ctr ++) begin
            @(posedge axiLiteVif.ACLK);
            if (axiLiteVif.BVALID) break;
        end
        if (axiLite_ctr == 31) begin
            `uvm_error("axiLite_master_driver","BVALID timeout");
        end
        else begin
            if (axiLiteVif.BVALID == 1'b1 && axiLiteVif.BRESP != 2'h0)
            `uvm_error("axiLite_master_driver","Received ERROR Write Response");
            axiLiteVif.BREADY <= axiLiteVif.BVALID;
         @(posedge axiLiteVif.ACLK);
        end
    endtask: drive_write_data_channel
    // drive read data channel
    virtual protected task drive_read_data_channel (output bit [31:0] data, output bit error);
        int axiLite_ctr;
        for(axiLite_ctr = 0; axiLite_ctr <= 31; axiLite_ctr ++) begin
            @(posedge axiLiteVif.ACLK);
            if (axiLiteVif.RVALID) break;
        end
        data = axiLiteVif.RDATA;
        if (axiLite_ctr == 31) begin
            `uvm_error("axiLite_master_driver","RVALID timeout");
        end
        else begin
        if (axiLiteVif.RVALID == 1'b1 && axiLiteVif.RRESP != 2'h0)
            `uvm_error("axiLite_master_driver","Received ERROR Read Response");
            axiLiteVif.RREADY <= axiLiteVif.RVALID;
            @(posedge axiLiteVif.ACLK);
        end
    endtask: drive_read_data_channel
endclass: axiLite_driver
// UVM_DRIVER : TEMPLATE_DRIVER [TEMPLATE]
class template_driver extends uvm_driver#(template_transaction);
    `uvm_component_utils(template_driver)
    virtual template_if templateVif;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual template_if)::read_by_name(.scope("ifs"), .name("template_if"), .val(templateVif)));
    endfunction: build_phase
    task run_phase(uvm_phase phase);
        drive();
    endtask: run_phase
    virtual task drive();
        template_transaction tx;
        integer counter = 0, state = 0;
        templateVif.sig_ina = 0'b0;
        templateVif.sig_inb = 0'b0;
        templateVif.sig_en_i = 1'b0;
        forever begin
            if(counter==0)
            begin
                seq_item_port.get_next_item(tx);
            end
            @(posedge templateVif.sig_clock)
            begin
                if(counter==0)
                begin
                    templateVif.sig_en_i = 1'b1;
                    state = 1;
                end
                if(counter==1)
                begin
                    templateVif.sig_en_i = 1'b0;
                end
                case(state)
                    1: begin
                        templateVif.sig_ina = tx.ina[1];
                        templateVif.sig_inb = tx.inb[1];
                        tx.ina = tx.ina << 1;
                        tx.inb = tx.inb << 1;
                        counter = counter + 1;
                        if(counter==2) state = 2;
                    end
                    2: begin
                        templateVif.sig_ina = 1'b0;
                        templateVif.sig_inb = 1'b0;
                        counter = counter + 1;
                        if(counter==6)
                        begin
                            counter = 0;
                            state = 0;
                            seq_item_port.item_done();
                        end
                    end
                endcase
            end
        end
    endtask: drive
endclass: template_driver
// UVM_DRIVER : RGB_DRIVER [RGB]
class rgb_driver#(parameter set_config cfg = par_1) extends uvm_driver#(rgb_transaction#(cfg));
    `uvm_component_param_utils(rgb_driver#(cfg))
    virtual rgb_if#(cfg) frame_vi;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual rgb_if#(cfg))::read_by_name(.scope("ifs"),.name("rgb_if"),.val(frame_vi)));
    endfunction: build_phase
    task run_phase(uvm_phase phase);
        rgb_transaction#(cfg) frame_tx;
        forever begin
            @frame_vi.master_cb;
            seq_item_port.get_next_item(frame_tx);
            @frame_vi.master_cb;
            frame_vi.master_cb.iRed        <= frame_tx.iRed;
            frame_vi.master_cb.iGreen      <= frame_tx.iGreen;
            frame_vi.master_cb.iBlue       <= frame_tx.iBlue;
            frame_vi.master_cb.iX          <= frame_tx.iX;
            frame_vi.master_cb.iY          <= frame_tx.iY;
            frame_vi.master_cb.iPixelEn    <= frame_tx.iPixelEn;
            frame_vi.master_cb.iValid      <= frame_tx.iValid;
            frame_vi.master_cb.iEof        <= frame_tx.iEof;
            seq_item_port.item_done();
        end
    endtask: run_phase
endclass: rgb_driver
class axi4_stream_master_driver  extends uvm_driver #(axi4_stream_valid_cycle);
    `uvm_component_utils(axi4_stream_master_driver)
    	axi4_stream_config axi4_stream_cfg;
    virtual interface axi4_stream_if  vif;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			if(vif.ARESET_N !== 1) begin
				vif.TVALID <= 0;
				//`uvm_info(get_type_name(),$psprintf("reset"), UVM_HIGH)
				@(posedge vif.ARESET_N);
			//	`uvm_info(get_type_name(),$psprintf("coming out of reset"), UVM_HIGH)
			end
			fork
				begin //-- Asynchronous reset
					@(negedge vif.ARESET_N);
				end
				begin
					drive_valid_cycles();
				end
			join_any
			disable fork;
		end
	endtask : run_phase
	task drive_valid_cycles();
		@(posedge vif.ACLK);
		forever begin
			axi4_stream_valid_cycle  vc;
			//-- Try next AXI4 item
			seq_item_port.try_next_item(vc);
			if( vc != null) begin
				//`uvm_info(get_type_name(),$psprintf("There is an item to sent"), UVM_MEDIUM)
				//`uvm_info(get_type_name(),$psprintf("send %0x %0x", vc.tuser, vc.tdata), UVM_MEDIUM)
				//-- Wait until delay
				repeat(vc.delay)
					@(posedge vif.ACLK);
				//-- Send AXI4 cycle
				vif.TDATA  <= vc.tdata;
				vif.TUSER  <= vc.tuser;
				vif.TVALID <= 1;
				@(posedge vif.ACLK)
				while(vif.TREADY == 0)
					@(posedge vif.ACLK);
				vif.TUSER  <= 0;
				vif.TDATA  <= 0;
				vif.TVALID <= 0;
				//`uvm_info(get_type_name(),$psprintf("send done: %0x %0x", vc.tuser, vc.tdata), UVM_MEDIUM)
				seq_item_port.item_done();
			end else //-- Else wait 1 cycle
				@(posedge vif.ACLK);
		end
	endtask : drive_valid_cycles
endclass : axi4_stream_master_driver
class axi4_stream_slave_driver  extends uvm_driver #(ax_packet);
    `uvm_component_utils(axi4_stream_slave_driver)
	virtual interface axi4_stream_if vif;
	rand int block_cycles;
	constraint c_block_cycles {
		soft block_cycles dist{0:/30,[1:5]:/41, [6:15]:/25, [16:10000]:/4};
	}
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
			if(vif.ARESET_N !== 1) begin
				vif.TVALID <= 0;
				@(posedge vif.ARESET_N);
			end
			begin //-- Asynchronous reset
				@(negedge vif.ARESET_N);
			end
			begin
			@(posedge vif.ACLK);
			forever begin
                if (vif.TVALID)
                    randcase
                        3 : vif.TREADY <= 1;
                        1 : vif.TREADY <= 0;
                    endcase
                else 
                    randcase
                        1 : vif.TREADY <= 1;
                        1 : vif.TREADY <= 0;
                        1 : begin		//-- hold tready at least until tvalid is set
                        vif.TREADY <= 0;
                        void'(this.randomize());
                        while (vif.TVALID == 0)
                        @(posedge vif.ACLK);
                        repeat(block_cycles) @(posedge vif.ACLK); //-- wait 2 additional cycles
                        end
                    endcase
			end
			end
        end
    endtask : run_phase
endclass : axi4_stream_slave_driver
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_MONITORS
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_MONITOR : AXILITE_MON [AXILITE]
class axiLite_monitor extends uvm_monitor;
    protected virtual   axiLite_if axiLiteVif;
    protected int       id;
    uvm_analysis_port #(axiLite_transaction) item_collected_port;
    uvm_analysis_port #(axiLite_transaction) dut_inputs_port; // analysis port for DUT inputs
    uvm_analysis_port #(axiLite_transaction) dut_outputs_port; // analysis port for DUT outputs
    protected axiLite_transaction aL_txn;
    `uvm_component_utils_begin(axiLite_monitor)
        `uvm_field_int(id, UVM_DEFAULT)
    `uvm_component_utils_end
    function new (string name, uvm_component parent);
        super.new(name, parent);
        aL_txn = new();
        item_collected_port = new("item_collected_port", this);
       // dut_inputs_port = new("dut_inputs_port", this); // construct the analysis port
        //dut_outputs_port = new("dut_outputs_port", this); // construct the analysis port
    endfunction
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axiLite_if)::get(this, "", "axiLiteVif", axiLiteVif))
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(), ".axiLiteVif"});
        dut_inputs_port = new(.name("dut_inputs_port"),.parent(this));
        dut_outputs_port = new(.name("dut_outputs_port"),.parent(this));
    endfunction // build_phase
    virtual task run_phase (uvm_phase phase);
        fork
            collect_transactions();
        join
    endtask: run_phase
    virtual protected task collect_transactions();
        bit valid_txn = 0;
        forever begin
            axiLite_transaction tx_in,tx_out,tx_copy;
            tx_in       = axiLite_transaction::type_id::create("tx_in"); 
            tx_out      = axiLite_transaction::type_id::create("tx_out");
            aL_txn      = new();
            if (axiLiteVif.ARESETN == 'b0)
            @(posedge axiLiteVif.ARESETN);
                if (axiLiteVif.AWVALID == 'b1) begin
                    tx_in.WDATA = axiLiteVif.WDATA; 
                    aL_txn.reqWriteRead = WRITE;    
                    aL_txn.addr  = axiLiteVif.AWADDR[7:0];
                    @(posedge axiLiteVif.WVALID);
                    aL_txn.data  = axiLiteVif.WDATA;
                    @(negedge axiLiteVif.WVALID);
                    valid_txn = 1;
                end
            else if (axiLiteVif.ARVALID == 'b1) begin
                tx_out.RDATA = axiLiteVif.RDATA; 
                aL_txn.reqWriteRead = READ;    
                aL_txn.addr  = axiLiteVif.ARADDR[7:0];
                @(posedge axiLiteVif.RVALID);
                aL_txn.data  = axiLiteVif.RDATA;
                @(negedge axiLiteVif.RVALID);
                valid_txn = 1;
            end
            @(posedge axiLiteVif.ACLK);
            //aL_txn.data = axiLiteVif.data;
            //while (axiLiteVif.valid == 'b1) begin
            //@(posedge axiLiteVif.ACLK);
            //aL_txn.cycles++;
            //end
            //aL_txn.cycles--;
             //`uvm_info("axiLiteVif data", aL_txn.sprint(), UVM_LOW);
                if (valid_txn == 'b1 ) begin
                    //`uvm_info("MON", aL_txn.convert2string(), UVM_LOW) 
                    item_collected_port.write(aL_txn);
                    //item_collected_port.write(aL_txn);
                end
            dut_inputs_port.write(tx_in);  
            $cast(tx_copy, tx_out.clone());
            dut_outputs_port.write(tx_copy);             
            valid_txn = 0;
        end
    endtask: collect_transactions
endclass: axiLite_monitor
// UVM_MONITOR : TEMPLATE_MONITOR_AFTERTODUT [TEMPLATE]
//The second axi4_monitor, monitor_afterToDut, will get both inputs 
//and make a prediction of the expected result. 
//The scoreboard will get this predicted result as well and make a comparison between the two values.
class template_monitor_afterToDut extends uvm_monitor;
    `uvm_component_utils(template_monitor_afterToDut)
    uvm_analysis_port#(template_transaction) mon_ap_afterToDut;
    virtual template_if templateVif;
    template_transaction tx;
    //For coverage
    template_transaction sa_tx_cg;
    //Define coverpoints
    covergroup template_cg;
              ina_cp:     coverpoint sa_tx_cg.ina;
              inb_cp:     coverpoint sa_tx_cg.inb;
        cross ina_cp, inb_cp;
    endgroup: template_cg
    function new(string name, uvm_component parent);
        super.new(name, parent);
        template_cg = new;
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual template_if)::read_by_name(.scope("ifs"), .name("template_if"), .val(templateVif)));
        mon_ap_afterToDut= new(.name("mon_ap_afterToDut"), .parent(this));
    endfunction: build_phase
    task run_phase(uvm_phase phase);
        integer counter_mon = 0, state = 0;
        tx = template_transaction::type_id::create
            (.name("tx"), .contxt(get_full_name()));
        forever begin
            @(posedge templateVif.sig_clock)
            begin
                if(templateVif.sig_en_i==1'b1)
                begin
                    state  = 1;
                    tx.ina = 2'b00;
                    tx.inb = 2'b00;
                    tx.out = 3'b000;
                end
                if(state==1)
                begin
                    tx.ina    = tx.ina << 1;
                    tx.inb    = tx.inb << 1;
                    tx.ina[0] = templateVif.sig_ina;
                    tx.inb[0] = templateVif.sig_inb;
                    counter_mon = counter_mon + 1;
                    if(counter_mon==2)
                    begin
                        state = 0;
                        counter_mon = 0;
                        //Predict the result
                        predictor();
                        sa_tx_cg = tx;
                        //Coverage
                        template_cg.sample();
                        //Send the transaction to the analysis port
                        mon_ap_afterToDut.write(tx);
                    end
                end
            end
        end
    endtask: run_phase
    virtual function void predictor();
        tx.out = tx.ina + tx.inb;//Predict out value
    endfunction: predictor
endclass: template_monitor_afterToDut
// UVM_MONITOR : TEMPLATE_MONITOR_BEFOREFROMDUT [TEMPLATE]
//monitor_beforeFromDut, will look solely for the output of the device 
//and it will pass the result to the scoreboard.
class template_monitor_beforeFromDut extends uvm_monitor;
    `uvm_component_utils(template_monitor_beforeFromDut)
    uvm_analysis_port#(template_transaction) mon_ap_beforeFromDut;
    virtual template_if templateVif;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual template_if)::read_by_name
            (.scope("ifs"), .name("template_if"), .val(templateVif)));
        mon_ap_beforeFromDut = new(.name("mon_ap_beforeFromDut"), .parent(this));
    endfunction: build_phase
    task run_phase(uvm_phase phase);
        integer counter_mon = 0, state = 0;
        template_transaction tx;
        tx = template_transaction::type_id::create
            (.name("tx"), .contxt(get_full_name()));
        forever begin
            @(posedge templateVif.sig_clock)
            begin
                if(templateVif.sig_en_o==1'b1)begin
                    state = 3;
                end
                if(state==3)begin
                    tx.out = tx.out << 1;
                    counter_mon = counter_mon + 1;
                    if (counter_mon==3)begin
                        tx.out[0]=templateVif.sig_out;
                    end
                    if(counter_mon==4)begin
                        state       = 0;
                        counter_mon = 0;
                        //Send the transaction to the analysis port
                        mon_ap_beforeFromDut.write(tx);
                    end
                end
            end
        end
    endtask: run_phase
endclass: template_monitor_beforeFromDut
// UVM_MONITOR : RGB_MONITOR [RGB]
class rgb_monitor#(parameter set_config cfg = par_1) extends uvm_monitor;
    `uvm_component_param_utils(rgb_monitor#(cfg))
    uvm_analysis_port#(rgb_transaction#(cfg)) frame_ap;
    int unsigned agent_id = 1;
    virtual rgb_if#(cfg) frame_vi;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual rgb_if#(cfg))::read_by_name
        (.scope("ifs"),.name("rgb_if"),.val(frame_vi)));
        frame_ap = new(.name("frame_ap"),.parent(this));
    endfunction: build_phase
    task run_phase(uvm_phase phase);
    $display("Detected new frame_tx on interface #%d\n", agent_id);
        forever begin
            rgb_transaction#(cfg) frame_tx;
            @frame_vi.slave_cb;
            frame_tx               = rgb_transaction#(cfg)::type_id::create(.name("frame_tx"));
            frame_tx.iRed          = frame_vi.slave_cb.iRed;
            frame_tx.iGreen        = frame_vi.slave_cb.iGreen;
            frame_tx.iBlue         = frame_vi.slave_cb.iBlue;
            frame_tx.iPixelEn      = frame_vi.slave_cb.iPixelEn;
            frame_tx.iValid        = frame_vi.slave_cb.iValid;
            frame_tx.iEof          = frame_vi.slave_cb.iEof;
            frame_tx.iX            = frame_vi.slave_cb.iX;
            frame_tx.iY            = frame_vi.slave_cb.iY;
            frame_ap.write(frame_tx);
        end
    endtask: run_phase
endclass: rgb_monitor
    parameter DATA_BYTES = 16;
class ax_module_mon extends uvm_monitor;
	//-- Basic Module monitor
	ax_packet packet;
	covergroup ax_pkt_cg;
		option.per_instance = 1;
		AX_PACKET_LENGTH : coverpoint packet.packet_length{
			illegal_bins zero_flit_pkt = {0};
			bins pkt_length[] = {[1:9]};
		}
		AX_COMMAND: coverpoint packet.command {
			bins requests[] = {
				AX_WRITE_16,
				AX_WRITE_32,
				AX_WRITE_48,
				AX_WRITE_64,
				AX_WRITE_80,
				AX_WRITE_96,
				AX_WRITE_112,
				AX_WRITE_128,
				AX_MODE_WRITE,
				AX_BIT_WRITE,
				AX_DUAL_8B_ADDI,
				AX_SINGLE_16B_ADDI,
				AX_POSTED_WRITE_16,
				AX_POSTED_WRITE_32,
				AX_POSTED_WRITE_48,
				AX_POSTED_WRITE_64,
				AX_POSTED_WRITE_80,
				AX_POSTED_WRITE_96,
				AX_POSTED_WRITE_112,
				AX_POSTED_WRITE_128,
				AX_POSTED_BIT_WRIT,
				AX_POSTED_BIT_WRIT,
				AX_POSTED_DUAL_8B_ADDI,
				AX_POSTED_SINGLE_16B_ADDI,
				AX_MODE_READ,
				AX_READ_16,
				AX_READ_32,
				AX_READ_48,
				AX_READ_64,
				AX_READ_80,
				AX_READ_96,
				AX_READ_112, 
				AX_READ_128};
			bins response[] = {
				AX_READ_RESPONSE,
				AX_WRITE_RESPONSE,
				AX_MODE_READ_RESPONSE,
				AX_MODE_WRITE_RESPONSE,
				AX_ERROR_RESPONSE
			};
			illegal_bins n_used = default;
		}
		FLIT_DELAY: coverpoint packet.flit_delay{
			bins zero_delay = {0};
			bins small_delay = {[1:3]};
			bins big_delay = {[4:20]};
			bins huge_delay = {[21:$]};
		}
		FLIT_DELAY_COMMAND : cross AX_COMMAND, FLIT_DELAY;
	endgroup
	uvm_analysis_port #(ax_packet) item_collected_port;
	int req_rcvd = 0;
	int rsp_rcvd = 0;
	`uvm_component_utils(ax_module_mon)
	function new ( string name = "ax_module_mon", uvm_component parent );
		super.new(name, parent);
		item_collected_port = new("item_collected_port", this);
	endfunction : new
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase
endclass
class axi4_stream_monitor extends uvm_monitor;
    `uvm_component_utils(axi4_stream_monitor)
    virtual interface axi4_stream_if vif;
    uvm_analysis_port #(axi4_stream_valid_cycle)    item_collected_port;
    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase
    task run();
        axi4_stream_valid_cycle  vc;
        forever begin
            if (vif.ARESET_N !== 1)
            begin
                @(posedge vif.ARESET_N);
                `uvm_info(get_type_name(),$psprintf("coming out of reset"), UVM_LOW)
            end
            //fork
                begin //-- Asynchronous reset
                    @(negedge vif.ARESET_N);
                end
                forever begin
                    //-- At the positive edge of ACLK
                    @(posedge vif.ACLK);
                    //-- Capture valid bus cycles
                    vc = new();
                    if (vif.TVALID == 1 && vif.TREADY == 1) begin
                        vc.tuser     = vif.TUSER;
                        vc.tdata     = vif.TDATA;
                        item_collected_port.write(vc);
                        `uvm_info(get_type_name(),$psprintf("valid cycle tuser %0x tdata %0x", vc.tuser, vc.tdata), UVM_HIGH)
                    end
                    //-- used to detect the ax_pkt_delay between packets
                    if (vif.TVALID == 0) begin
                        vc.tuser    = 0;
                        vc.tdata    = {DATA_BYTES{16'b0}};;
                        item_collected_port.write(vc);
                    end
                end
            //join_any
            //disable fork;
        end
    endtask : run
endclass : axi4_stream_monitor
class axi4_stream_ax_monitor extends  ax_module_mon ;
    `uvm_component_utils(axi4_stream_ax_monitor)
	int FPW ;
	int HEADERS ;
	int TAILS ;
	int VALIDS ;
	int valids_per_cycle 		= 0;
	int current_packet_length 	= 0;
	bit request = 1;
	int flit_delay [$];
	uvm_analysis_port #(ax_packet) item_collected_port;
	uvm_analysis_imp #(axi4_stream_valid_cycle,axi4_stream_ax_monitor) axi4_port;
	int n_valids 				= 0;
	int headers_seen 	= 0;
	int tails_seen 	 	= 0;
	typedef bit [127:0] flit_t;
	flit_t flit_queue[$];
	int packets_per_cycle = 0;
	ax_packet packet_queue[$];
	//-- covergroup definition
    function new(string name, uvm_component parent);
        super.new(name, parent);
        axi4_port = new("axi4_port",this);
    endfunction: new
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		FPW 	= DATA_BYTES/16;//-- convert to variables!
		HEADERS = FPW;
		TAILS 	= 2*FPW;
		VALIDS 	= 0;
	endfunction : build_phase
	//-- Stuff FLITs into a FIFO, separate control signals
	function void collect_flits(input axi4_stream_valid_cycle vc);
		//-- read tuser flags for valid flags
		flit_t tmp_flit;
		flit_t current_flit;
		packets_per_cycle = 0;
		valids_per_cycle =0;
		for (int i = 0; i<FPW; i++) begin //-- Check bitvector
		//-- Check if valid
			if (vc.tuser == 1) begin
				valids_per_cycle ++;
				//-- Write 2 flit queue
				for (int b=0; b<16; b++)
					tmp_flit[b] = vc.tdata[16*i+b];
				flit_queue.push_back(tmp_flit);
				if (vc.tuser == 1'b1) begin
					headers_seen++; //-- Complete ax_packets to assemble
					packets_per_cycle++;
					flit_delay.push_back(n_valids);
					n_valids = 0;
				end
				//-- Check if tail for complete ax packet
				if (vc.tuser == 1'b1) begin
					tails_seen++; //-- Complete ax_packets to assemble
					assert (n_valids == 0)
					else `uvm_fatal(get_type_name(), $psprintf("Non valid flits in pkt detected!"))
				end
				//-- Check complete ax packets
				assert (tails_seen<= headers_seen) 
				else  `uvm_fatal(get_type_name(), $psprintf("packet is null"))
				assert (headers_seen <= tails_seen+1)
				else  `uvm_fatal(get_type_name(), $psprintf("Packet without Tail detected"))
			end
			else begin
				n_valids ++;
			end
		end
		if(|vc.tuser)
			`uvm_info(get_type_name(),$psprintf("%d header and %d tails available", headers_seen, tails_seen)  ,UVM_HIGH)
	endfunction : collect_flits
	//-- Use FLITs to form packets
	function void collect_packet();
		flit_t current_flit;
		bit bitstream[];
		//-- Assemble 1 ax packet
		flit_queue_underflow : assert (flit_queue.size() > 0);
		//-- First flit is always header
		current_flit = flit_queue.pop_front();
		no_length_mismatches_allowed : assert (current_flit[14:11] == current_flit[10:7]); 	//--check internal ax_packet length
		current_packet_length = current_flit[10:7];
		`uvm_info(get_type_name(),$psprintf("packet length %0d ", current_packet_length), UVM_HIGH)
		`uvm_info(get_type_name(),$psprintf("queue size %0d ", flit_queue.size()), UVM_HIGH)
		flit_queue_underflow2 : assert (flit_queue.size() >= current_packet_length - 1);		//--check check ax_packet complete received
		//-- pack flits 2 bitstream
		bitstream = new[current_packet_length*16];
		//-- Pack first flit
		for (int i=0; i<16; i=i+1)
			bitstream[i] = current_flit[i];
		//-- Get and pack the remaining flits
		for (int flit=1; flit < current_packet_length; flit ++) begin
			current_flit = flit_queue.pop_front();
			`uvm_info(get_type_name(),$psprintf("pop flit %0d (%0x)", flit, current_flit), UVM_HIGH)
			for (int i=0; i<16; i=i+1) begin
				bitstream[flit*16+i] = current_flit[i];
			end
		end
		packet = ax_packet::type_id::create("packet", this);
		void'(packet.unpack(bitstream));
		packet.flit_delay = flit_delay.pop_front();
		ax_pkt_cg.sample(); 
		//-- assembled a packet
		headers_seen--;
		tails_seen--; 
		if (packet == null) begin
		  `uvm_fatal(get_type_name(), $psprintf("packet is null"))
		end
		packet_queue.push_back(packet);
		if(packet.get_command_type() == AX_RESPONSE_TYPE)begin
		`uvm_info("RESPONSE collected",$psprintf("Rsp %0d : %s",rsp_rcvd, packet.command.name()), UVM_LOW)
		rsp_rcvd++;
		end else begin
		`uvm_info("REQUEST collected",$psprintf("Req %0d : %s",req_rcvd, packet.command.name()), UVM_LOW)
		req_rcvd++;
		end
		`uvm_info("AXI4 to AX Monitor",$psprintf("\n%s", packet.sprint()), UVM_HIGH)
	endfunction : collect_packet
	function void write(input axi4_stream_valid_cycle vc);
		ax_packet packet;
		collect_flits(vc);
		//`uvm_info(get_type_name(),$psprintf("got %0d tails and %0d flits",tails_seen, flit_queue.size() ), UVM_HIGH)
		//-- Convert flit_queue to ax_packets
		while (tails_seen >0) begin
			collect_packet();		
		end
		//-- If flit queue is not empty -> ax packet striped over 2 axi cycles
		while (packet_queue.size()>0) begin
			packet = packet_queue.pop_front();
			//if (packet.command != AX_ERROR_RESPONSE)
				item_collected_port.write(packet);
		end
	endfunction
	function void check_phase(uvm_phase phase);
		if (flit_queue.size() >0)
			`uvm_fatal(get_type_name(),$psprintf("flit_queue is not empty: %0d", flit_queue.size()))
	endfunction : check_phase
endclass : axi4_stream_ax_monitor
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_AGENTS
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_AGENT : AXILITE_AGT [AXILITE]
class axiLite_agent extends uvm_agent;
    `uvm_component_utils(axiLite_agent)
    uvm_analysis_port#(axiLite_transaction) item_collected_port;
    axiLite_sequencer       aL_sqr;
    axiLite_driver          aL_drv;
    axiLite_monitor         aL_mon;
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_port    = new(.name("item_collected_port"),.parent(this));
        aL_mon                 = axiLite_monitor::type_id::create("aL_mon", this);
        if (get_is_active() == UVM_ACTIVE) begin
            aL_sqr = axiLite_sequencer::type_id::create("aL_sqr", this);
            aL_drv = axiLite_driver::type_id::create("aL_drv", this);
        end
    endfunction
    function void connect_phase(uvm_phase phase);
        if (get_is_active() == UVM_ACTIVE) begin
            aL_drv.seq_item_port.connect(aL_sqr.seq_item_export);
            aL_mon.item_collected_port.connect(item_collected_port);
        end
    endfunction
endclass: axiLite_agent
// UVM_AGENT : RGB_AGENT [RGB]
class rgb_agent#(parameter set_config cfg = par_1) extends uvm_agent;
    `uvm_component_param_utils(rgb_agent#(cfg))
    uvm_analysis_port#(rgb_transaction#(cfg)) frame_ap;
    rgb_sequencer   #(cfg)               frame_seqr;
    rgb_driver      #(cfg)               frame_drvr;
    rgb_monitor     #(cfg)               frame_mon;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        frame_ap    = new(.name("frame_ap"),.parent(this));
        frame_seqr = rgb_sequencer#(cfg)  ::type_id::create(.name("frame_seqr"),.parent(this));
        frame_drvr = rgb_driver   #(cfg)  ::type_id::create(.name("frame_drvr"),.parent(this));
        frame_mon  = rgb_monitor  #(cfg)  ::type_id::create(.name("frame_mon"),.parent(this));
    endfunction: build_phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        frame_drvr.seq_item_port.connect(frame_seqr.seq_item_export);
        frame_mon.frame_ap.connect(frame_ap);
    endfunction: connect_phase
endclass: rgb_agent
// UVM_AGENT : TEMPLATE_AGENT [TEMPLATE]
class template_agent extends uvm_agent;
    `uvm_component_utils(template_agent)
    uvm_analysis_port#(template_transaction) agent_ap_beforeFromDut;
    uvm_analysis_port#(template_transaction) agent_ap_afterToDut;
    template_sequencer                       sa_seqr;
    template_driver                          sa_drvr;
    template_monitor_beforeFromDut           sa_mon_beforeFromDut;
    template_monitor_afterToDut              sa_mon_afterToDut;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent_ap_beforeFromDut      = new(.name("agent_ap_beforeFromDut"), .parent(this));
        agent_ap_afterToDut         = new(.name("agent_ap_afterToDut"), .parent(this));
        sa_seqr                     = template_sequencer::type_id::create(.name("sa_seqr"), .parent(this));
        sa_drvr                     = template_driver::type_id::create(.name("sa_drvr"), .parent(this));
        sa_mon_beforeFromDut        = template_monitor_beforeFromDut::type_id::create(.name("sa_mon_beforeFromDut"), .parent(this));
        sa_mon_afterToDut           = template_monitor_afterToDut::type_id::create(.name("sa_mon_afterToDut"), .parent(this));
    endfunction: build_phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        sa_drvr.seq_item_port.connect(sa_seqr.seq_item_export);
        sa_mon_beforeFromDut.mon_ap_beforeFromDut.connect(agent_ap_beforeFromDut);
        sa_mon_afterToDut.mon_ap_afterToDut.connect(agent_ap_afterToDut);
    endfunction: connect_phase
endclass: template_agent
class axi4_stream_master_agent extends uvm_agent;
    `uvm_component_utils(axi4_stream_master_agent)
    axi4_stream_config                  axi4_stream_master_cfg;
    axi4_stream_master_driver           axi4_master_driver;
    axi4_stream_master_sequencer        axi_sequencer;
    //axi4_stream_monitor                 axi4_monitor;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (! uvm_config_db#(axi4_stream_config)::get(
        .cntxt(this),.inst_name (""),.field_name("axi4_stream_master_cfg"),.value(axi4_stream_master_cfg))) begin
        `uvm_error("axi4_stream_master_agent", "axi4_stream_master_cfg not found")
        end
        if (axi4_stream_master_cfg.master_active == UVM_ACTIVE) begin
            axi_sequencer = axi4_stream_master_sequencer    ::type_id::create(.name("axi_sequencer"),.parent(this));
            axi4_master_driver = axi4_stream_master_driver  ::type_id::create(.name("axi4_master_driver"),.parent(this));
        end
        //axi4_monitor = axi4_stream_monitor::type_id::create(.name("axi4_monitor"),.parent(this));
            endfunction: build_phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //axi4_monitor.vif    = axi4_stream_master_cfg.vif;
        if (axi4_stream_master_cfg.master_active == UVM_ACTIVE) begin
            axi4_master_driver.seq_item_port.connect(axi_sequencer.seq_item_export);
            axi4_master_driver.vif = axi4_stream_master_cfg.vif;
        end
    endfunction: connect_phase
endclass : axi4_stream_master_agent
class axi4_stream_slave_agent extends uvm_agent;
    `uvm_component_utils(axi4_stream_slave_agent)
    axi4_stream_config                  axi4_stream_slave_cfg;
    axi4_stream_slave_driver            axi4_slave_driver;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (! uvm_config_db#(axi4_stream_config)::get(.cntxt(this),.inst_name (""),.field_name("axi4_stream_slave_cfg"),.value(axi4_stream_slave_cfg))) begin
        `uvm_error("axi4_stream_slave_agent", "axi4_stream_slave_cfg not found")
        end
        if (axi4_stream_slave_cfg.slave_active == UVM_ACTIVE) begin
            axi4_slave_driver = axi4_stream_slave_driver         ::type_id::create(.name("axi4_slave_driver"),.parent(this));
        end
    endfunction: build_phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (axi4_stream_slave_cfg.slave_active == UVM_ACTIVE) begin
            axi4_slave_driver.vif = axi4_stream_slave_cfg.vif;
        end
    endfunction: connect_phase
endclass : axi4_stream_slave_agent
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_SUBSCRIBERS
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_SUBSCRIBER : AXILITE_FC_SUBSCRIBER [AXILITE]
class axiLite_fc_subscriber extends uvm_subscriber#(axiLite_transaction);
    `uvm_component_utils(axiLite_fc_subscriber)
    axiLite_transaction aL_txn;
    covergroup aL_cg;
        WDATA_cp:            coverpoint aL_txn.WDATA;
        AWADDR_cp:           coverpoint aL_txn.RDATA;
        // cross WDATA_cp, AWADDR_cp;
    endgroup: aL_cg
    function new(string name, uvm_component parent);
        super.new(name, parent);
        aL_cg = new;
    endfunction: new
    function void write(axiLite_transaction t);
        aL_txn = t;
        aL_cg.sample();
    endfunction: write
endclass: axiLite_fc_subscriber
// UVM_SUBSCRIBER : RGB_FC_SUBSCRIBER [RGB]
//The functional coverage subscriber (fc_sucbscriber) identifies 
//the generated frame_tx. 
//The rgb_transaction sent from the axi4_monitor is sampled by the write function.
class rgb_fc_subscriber extends uvm_subscriber#(rgb_transaction);
    `uvm_component_utils(rgb_fc_subscriber)
    rgb_transaction frame_tx;
    covergroup rgb_cg;
        iRed_cp:            coverpoint frame_tx.iRed;
        iGreen_cp:          coverpoint frame_tx.iGreen;
        iBlue_cp:           coverpoint frame_tx.iBlue;
        iPixelEn_cp:        coverpoint frame_tx.iPixelEn;
        iValid_cp:          coverpoint frame_tx.iValid;
        iEof_cp:            coverpoint frame_tx.iEof;
        iX_cp:              coverpoint frame_tx.iX;
        iY_cp:              coverpoint frame_tx.iY;
        cross iRed_cp, iEof_cp;
    endgroup: rgb_cg
    function new(string name, uvm_component parent);
        super.new(name, parent);
        rgb_cg = new;
    endfunction: new
    function void write(rgb_transaction t);
        frame_tx = t;
        rgb_cg.sample();
    endfunction: write
endclass: rgb_fc_subscriber
typedef class rgb_scoreboard;
// UVM_SUBSCRIBER : RGB_SB_SUBSCRIBER [RGB]
class rgb_sb_subscriber extends uvm_subscriber#(rgb_transaction);
    `uvm_component_utils(rgb_sb_subscriber)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void write(rgb_transaction t);
        rgb_scoreboard frame_sb;
        $cast(frame_sb, m_parent);
        frame_sb.check_rgb_taste(t);
    endfunction: write
endclass: rgb_sb_subscriber
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_SCORECARDS
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_SCORECARD : RGB_SCOREBOARD [RGB]
class rgb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(rgb_scoreboard)
    uvm_analysis_export#(rgb_transaction)    frame_analysis_export;
    local rgb_sb_subscriber                  frame_sb_sub;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        frame_analysis_export = new(.name("frame_analysis_export"),.parent(this));
        frame_sb_sub = rgb_sb_subscriber::type_id::create(.name("frame_sb_sub"),.parent(this));
    endfunction: build_phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        frame_analysis_export.connect(frame_sb_sub.analysis_export);
    endfunction: connect_phase
    virtual function void check_rgb_taste(rgb_transaction frame_tx);
        uvm_table_printer p = new;
    endfunction: check_rgb_taste
endclass: rgb_scoreboard
// UVM_SCORECARD : TEMPLATE_SCOREBOARD [TEMPLATE]
class template_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(template_scoreboard)
    uvm_analysis_export #(template_transaction)     sb_export_beforeFromDut;
    uvm_analysis_export #(template_transaction)     sb_export_afterToDut;
    uvm_tlm_analysis_fifo #(template_transaction)   before_fifo;
    uvm_tlm_analysis_fifo #(template_transaction)   after_fifo;
    template_transaction transaction_beforeFromDut;
    template_transaction transaction_afterToDut;
    function new(string name, uvm_component parent);
        super.new(name, parent);
        transaction_beforeFromDut       = new("transaction_beforeFromDut");
        transaction_afterToDut          = new("transaction_afterToDut");
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export_beforeFromDut         = new("sb_export_beforeFromDut", this);
        sb_export_afterToDut            = new("sb_export_afterToDut", this);
           before_fifo                  = new("before_fifo", this);
        after_fifo                      = new("after_fifo", this);
    endfunction: build_phase
    function void connect_phase(uvm_phase phase);
        sb_export_beforeFromDut.connect(before_fifo.analysis_export);
        sb_export_afterToDut.connect(after_fifo.analysis_export);
    endfunction: connect_phase
    task run();
        forever begin
            before_fifo.get(transaction_beforeFromDut);
            after_fifo.get(transaction_afterToDut);
            compare();
        end
    endtask: run
    // function string convert2string();
        // return $sformatf("addr");
    // endfunction
    virtual function void compare();
    //`uvm_info("FROMDUT", transaction_beforeFromDut.sprint(), UVM_LOW);
    //`uvm_info("TODUT", transaction_afterToDut.sprint(), UVM_LOW);
        if(transaction_beforeFromDut.out == transaction_afterToDut.out) begin
            `uvm_info("compare", {"Test: OK!"}, UVM_LOW);
        end else begin
            `uvm_info("compare", {"Test: Fail!"}, UVM_LOW);
        end
    endfunction: compare
endclass: template_scoreboard
`uvm_analysis_imp_decl(_beforeFromDut)
`uvm_analysis_imp_decl(_afterToDut)
parameter OPEN_RSP_MODE = 1;
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_ENVS
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_ENV : TEMPLATE_ENV
class template_env extends uvm_env;
    `uvm_component_utils(template_env)
    protected virtual interface axiLite_if axiLiteVif;
    template_agent              sa_agent;       //[TEMPLATE]
    template_scoreboard         sa_sb;          //[TEMPLATE]
    axiLite_agent               aL_agt;         //[AXILITE]
    axiLite_fc_subscriber       aL_fc_sub;      //[AXILITE]
    rgb_agent#(par_1)           frame_agent;
    rgb_fc_subscriber           frame_fc_sub;   //[RGB]
    rgb_scoreboard              frame_sb;       //[RGB]
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sa_agent        = template_agent            ::type_id::create(.name("sa_agent"), .parent(this));
        sa_sb           = template_scoreboard       ::type_id::create(.name("sa_sb"), .parent(this));
        frame_agent     = rgb_agent#(par_1)         ::type_id::create(.name("frame_agent"),.parent(this));
        frame_fc_sub    = rgb_fc_subscriber         ::type_id::create(.name("frame_fc_sub"),.parent(this));
        frame_sb        = rgb_scoreboard            ::type_id::create(.name("frame_sb"),.parent(this));
        if (!uvm_config_db#(virtual axiLite_if)::get(this, "", "axiLiteVif", axiLiteVif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".axiLiteVif"});
        aL_agt          = axiLite_agent::type_id::create("aL_agt", this);
        if (!uvm_config_db#(virtual axiLite_if)::get(this, "", "axiLiteVif", axiLiteVif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".axiLiteVif"});
        aL_fc_sub       = axiLite_fc_subscriber::type_id::create("aL_fc_sub", this);
    endfunction: build_phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        sa_agent.agent_ap_beforeFromDut.connect(sa_sb.sb_export_beforeFromDut);
        sa_agent.agent_ap_afterToDut.connect(sa_sb.sb_export_afterToDut);
        aL_agt.item_collected_port.connect(aL_fc_sub.analysis_export);
        frame_agent.frame_ap.connect(frame_fc_sub.analysis_export);
        frame_agent.frame_ap.connect(frame_sb.frame_analysis_export);
    endfunction: connect_phase
endclass: template_env
class axi4_stream_env extends uvm_env;
    axi4_stream_agents_config   axi4_stream_cfg;
	axi4_stream_config          axi4_stream_slave_cfg;
    axi4_stream_config          axi4_stream_master_cfg;
    axi4_stream_config          axi4_stream_monitor_cfg;
    axi4_stream_master_agent    axi4_stream_master_agt;
    axi4_stream_slave_agent     axi4_stream_slave_agt;
	axi4_stream_monitor 		monitor;
	axi4_stream_ax_monitor 		axi4_req;
    int id;
    `uvm_component_utils_begin(axi4_stream_env)
        `uvm_field_int(id, UVM_DEFAULT)
		`uvm_field_object(axi4_stream_cfg, UVM_DEFAULT)
		`uvm_field_object(axi4_stream_master_agt, UVM_DEFAULT)
		`uvm_field_object(axi4_stream_slave_agt, UVM_DEFAULT)
		`uvm_field_object(monitor, UVM_DEFAULT)
		`uvm_field_object(axi4_req, UVM_DEFAULT)
    `uvm_component_utils_end
        uvm_analysis_port#(axi4_stream_ax_monitor) item_collected_port;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
                item_collected_port    = new(.name("item_collected_port"),.parent(this));
        if (!uvm_config_db#(axi4_stream_agents_config)::get(.cntxt(this),.inst_name(""),.field_name("axi4_stream_cfg"),.value(axi4_stream_cfg)))begin
            `uvm_error("axi4_stream_agents_config", "axi4_stream_cfg not found")
        end
        if (axi4_stream_cfg.has_axi4_agent1) begin
            uvm_config_db#(axi4_stream_config)::set(.cntxt(this),.inst_name("axi4_stream_master_agt"),.field_name("axi4_stream_master_cfg"),.value(axi4_stream_cfg.axi4_agent_handler1));
            axi4_stream_master_agt=axi4_stream_master_agent::type_id::create(.name("axi4_stream_master_agt"),.parent(this));
            uvm_config_db#(axi4_stream_config)::set(.cntxt(this),.inst_name("axi4_stream_slave_agt"),.field_name("axi4_stream_slave_cfg"),.value(axi4_stream_cfg.axi4_agent_handler1));
            axi4_stream_slave_agt=axi4_stream_slave_agent::type_id::create(.name("axi4_stream_slave_agt"),.parent(this));
            uvm_config_db#(axi4_stream_config)::set(.cntxt(this),.inst_name("monitor"),.field_name("axi4_stream_cfg"),.value(axi4_stream_cfg.axi4_agent_handler1));
            monitor=axi4_stream_monitor::type_id::create(.name("monitor"),.parent(this));
            uvm_config_db#(axi4_stream_config)::set(.cntxt(this),.inst_name("axi4_req"),.field_name("axi4_stream_cfg"),.value(axi4_stream_cfg.axi4_agent_handler1));
            axi4_req=axi4_stream_ax_monitor::type_id::create(.name("axi4_req"),.parent(this));
            //uvm_config_db#(axi4_stream_config)::set(.cntxt(this),.inst_name("monitor"),.field_name("axi4_stream_slave_cfg"),.value(axi4_stream_cfg.axi4_agent_handler1));
            //monitor=axi4_stream_slave_agent::type_id::create(.name("monitor"),.parent(this));
           // uvm_config_db#(axi4_stream_config)::set(.cntxt(this),.inst_name("monitor"),.field_name("axi4_stream_slave_cfg"),.value(axi4_stream_cfg.axi4_agent_handler1));
            //monitor=axi4_stream_monitor::type_id::create(.name("monitor"),.parent(this));
           // uvm_config_db#(axi4_stream_config)::set(this, "monitor",.field_name("axi4_stream_slave_cfg"),.value(axi4_stream_cfg.axi4_agent_handler1));
        end
    endfunction: build_phase
    function void connect_phase(uvm_phase phase);
       // axi4_stream_ax_monitor	 axi4_ax_req_mon;
        super.connect_phase(phase);
        monitor.vif    = axi4_stream_cfg.axi4_agent_handler1.vif;
        //axi4_req    = axi4_stream_cfg.axi4_agent_handler1.vif;
        //monitor.item_collected_port.connect(item_collected_port);
        //axi4_req.item_collected_port.connect(axi4_ax_req_mon.axi4_port);	
        //axi4_req.item_collected_port.connect(axi4_stream_cfg.axi4_agent_handler1.vif);
        //monitor.vif    = axi4_stream_master_agt.vif;
    endfunction: connect_phase
endclass: axi4_stream_env
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- UVM_TESTS
//------------------------------------------------------------------------------------
//====================================================================================
// UVM_TEST : TEMPLATE_TEST [TEMPLATE]
class template_test extends uvm_test;
    `uvm_component_utils(template_test)
    template_env sa_env;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sa_env = template_env::type_id::create(.name("sa_env"), .parent(this));
    endfunction: build_phase
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        this.print();
        factory.print();
    endfunction
    task run_phase(uvm_phase phase);
        template_sequence sa_seq;
        phase.raise_objection(.obj(this));
            sa_seq = template_sequence::type_id::create(.name("sa_seq"), .contxt(get_full_name()));
            assert(sa_seq.randomize());
        sa_seq.start(sa_env.sa_agent.sa_seqr);
        phase.drop_objection(.obj(this));
    endtask: run_phase
endclass: template_test
// UVM_TEST : AXILITE_TEST [AXILITE]
class axiLite_test extends uvm_test;
    `uvm_component_utils(axiLite_test)
    template_env aL_env;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        begin
            axiLite_configuration axiLite_cfg;
            axiLite_cfg = new;
            assert(axiLite_cfg.randomize());
            uvm_config_db#(axiLite_configuration)::set(.cntxt(this),.inst_name("*"),.field_name("config"),.value(axiLite_cfg));
            aL_env = template_env::type_id::create(.name("aL_env"),.parent(this));
        end
    endfunction: build_phase
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        this.print();
        factory.print();
    endfunction
    task run_phase(uvm_phase phase);
        axiLite_directed_sequence    axiLite_seq;
        phase.raise_objection(.obj(this));
        axiLite_seq = axiLite_directed_sequence::type_id::create(.name("axiLite_seq"));
        assert(axiLite_seq.randomize());
        `uvm_info("aL_env", { "\n", axiLite_seq.sprint() }, UVM_LOW)
        axiLite_seq.start(aL_env.aL_agt.aL_sqr);
        phase.drop_objection(.obj(this));
    endtask: run_phase
endclass: axiLite_test
// UVM_TEST : RGB_TEST1 [RGB]
class rgb_test1 extends uvm_test;
    `uvm_component_utils(rgb_test1)
    template_env frame_env;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        begin
            rgb_configuration frame_cfg;
            frame_cfg = new;
            assert(frame_cfg.randomize());
            uvm_config_db#(rgb_configuration)::set(.cntxt(this),.inst_name("*"),.field_name("config"),.value(frame_cfg));
            frame_env = template_env::type_id::create(.name("frame_env"),.parent(this));
        end
    endfunction: build_phase
    task run_phase(uvm_phase phase);
        top_sequence        random_sqr;
        uvm_component       component;
        rgb_sequencer       sequencer;
        random_sqr = top_sequence::type_id::create("random_sqr");
        if( !random_sqr.randomize() ) 
            `uvm_error("", "Randomize failed")
        random_sqr.starting_phase = phase;
        component = uvm_top.find("*.frame_seqr");
        if ($cast(sequencer, component))
            random_sqr.start(sequencer);
    endtask: run_phase
endclass: rgb_test1
// UVM_TEST : RGB_TEST2 [RGB]
class rgb_test2 extends rgb_test1;
    `uvm_component_utils(rgb_test2)
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        random_sequence_r1#(par_1)::type_id::set_type_override(random_sequence_r2::get_type());
    endfunction : start_of_simulation_phase
endclass: rgb_test2
class rgb_test extends uvm_test;
    `uvm_component_utils(rgb_test)
    template_env frame_env;
    rgb_agent#(par_1) frame_agent;
    rgb_agent#(par_2) frame_agent_b;
    rgb_agent#(par_3) frame_agent_cs[4];
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        begin
            rgb_configuration frame_cfg;
            frame_cfg = new;
            assert(frame_cfg.randomize());
            uvm_config_db#(rgb_configuration)::set(.cntxt(this),.inst_name("*"),.field_name("config"),.value(frame_cfg));
            frame_env       = template_env::type_id::create(.name("frame_env"),.parent(this));
            frame_agent     = rgb_agent#(par_1)::type_id::create("frame_agent", this);
            frame_agent_b   = rgb_agent#(par_2)::type_id::create("frame_agent_b", this);
            foreach (frame_agent_cs[i])
                frame_agent_cs[i] = rgb_agent#(par_3)::type_id::create($sformatf("frame_agent_cs_%0d", i), this);
        end
    endfunction: build_phase
   function void end_of_elaboration_phase(uvm_phase phase);
      uvm_phase run_phase = uvm_run_phase::get();
      run_phase.phase_done.set_drain_time(this, 100us);
      frame_agent.frame_mon.agent_id = 0;
      frame_agent_b.frame_mon.agent_id = 1;
      foreach (frame_agent_cs[i])
        frame_agent_cs[i].frame_mon.agent_id = i + 2;
        this.print();
        factory.print();
   endfunction
   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      fork
         repeat (3) begin
            rgb_random_sequence#(par_1) rgb_seq_a = rgb_random_sequence#(par_1)::type_id::create("rgb_seq_a");
            rgb_seq_a.start(frame_env.frame_agent.frame_seqr);
         end
         repeat (3) begin
            rgb_random_sequence#(par_2) rgb_seq_b = rgb_random_sequence#(par_2)::type_id::create("rgb_seq_b");
            rgb_seq_b.start(frame_agent_b.frame_seqr);
         end
         begin
            foreach (frame_agent_cs[i])
               fork
                  automatic int unsigned agent_id = i;
                  repeat (3) begin
                     rgb_random_sequence#(par_3) rgb_seq_c = rgb_random_sequence#(par_3)::type_id::create("rgb_seq_c");
                     rgb_seq_c.start(frame_agent_cs[agent_id].frame_seqr);
                  end
               join_none
            wait fork;
         end
      join
      phase.drop_objection(this);
   endtask
// task run_phase(uvm_phase phase);
    // rgb_random_sequence#(par_1)    random_sqr;
    // phase.raise_objection(.obj(this));
    // random_sqr = rgb_random_sequence#(par_1)::type_id::create(.name("random_sqr"));
    // assert(random_sqr.randomize());
    // `uvm_info("aL_env", { "\n", random_sqr.sprint() }, UVM_LOW)
    // random_sqr.start(frame_env.frame_agent.frame_seqr);
    // phase.drop_objection(.obj(this));
// endtask: run_phase
endclass: rgb_test
class axi4_stream_test extends uvm_test;
    `uvm_component_utils(axi4_stream_test)
    axi4_stream_env             axi4_env;
    axi4_stream_agents_config   axi4_stream_cfg;
    axi4_stream_config          axi4_agent_handler1;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi4_env        = axi4_stream_env            ::type_id::create(.name("axi4_env"), .parent(this));
        axi4_stream_cfg        = axi4_stream_agents_config  ::type_id::create("axi4_stream_cfg");
        axi4_agent_handler1 = axi4_stream_config         ::type_id::create("axi4_agent_handler1");
        if (! uvm_config_db#(virtual axi4_stream_if) ::get(.cntxt(this),.inst_name(""),.field_name("vif"),.value(axi4_agent_handler1.vif))) begin
            `uvm_error("axi4_stream_if", "vif not found")
        end
        axi4_stream_cfg.axi4_agent_handler1 = axi4_agent_handler1;
        uvm_config_db#(axi4_stream_agents_config)::set(.cntxt(this),.inst_name("*"),.field_name("axi4_stream_cfg"),.value(axi4_stream_cfg));
    endfunction: build_phase
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        this.print();
        factory.print();
    endfunction
    task run_phase(uvm_phase phase);
        axi4_stream_master_sequence axi4_sequencer;
        phase.raise_objection(.obj(this));
            axi4_sequencer = axi4_stream_master_sequence::type_id::create(.name("axi4_sequencer"), .contxt(get_full_name()));
            assert(axi4_sequencer.randomize());
        axi4_sequencer.start(axi4_env.axi4_stream_master_agt.axi_sequencer);
        phase.drop_objection(.obj(this));
    endtask: run_phase
endclass: axi4_stream_test
endpackage: socTest_pkg
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- INTERFACES
//------------------------------------------------------------------------------------
//====================================================================================
// INTERFACE : TEMPLATE_IF [TEMPLATE]
interface template_if;
    logic        sig_clock;
    logic        sig_ina;
    logic        sig_inb;
    logic        sig_en_i;
    logic        sig_en_o;
    logic        sig_out;
    modport      templateSlave (input sig_clock,sig_ina,sig_inb,sig_en_i,output sig_en_o,sig_out);
endinterface: template_if
// INTERFACE : AXILITE_IF [AXILITE]
interface axiLite_if(input bit ACLK,ARESETN);
    logic [7:0]     AWADDR;
    logic [ 2:0]    AWPROT;
    logic           AWVALID;
    logic           AWREADY;
    logic [31:0]    WDATA;
    logic [ 3:0]    WSTRB;
    logic           WVALID;
    logic           WREADY;
    logic [1:0]     BRESP;
    logic           BVALID;
    logic           BREADY;
    logic [7:0]     ARADDR;
    logic [ 2:0]    ARPROT;
    logic           ARVALID;
    logic           ARREADY;
    logic [31:0]    RDATA;
    logic [ 1:0]    RRESP;
    logic           RVALID;
    logic           RREADY;
    modport         ConfigMaster(input ACLK,ARESETN,AWADDR,AWPROT,AWVALID,WDATA,WSTRB,WVALID,BREADY,ARADDR,ARPROT,ARVALID,RREADY, output  AWREADY,ARREADY,RDATA,RRESP,RVALID,WREADY,BRESP,BVALID);
endinterface: axiLite_if
// INTERFACE : RGB_IF [RGB]
interface rgb_if(input bit clk);
    logic [7:0]  iRed;
    logic [7:0]  iGreen;
    logic [7:0]  iBlue;
    logic        iValid;
    logic        iPixelEn;
    logic        iEof;
    int unsigned iX;
    int unsigned iY;
    logic [7:0]  oRed;
    logic [7:0]  oGreen;
    logic [7:0]  oBlue;
    logic        oValid;
    clocking master_cb @ (posedge clk);
        default input #1step output #1ns;
        output iPixelEn,iX,iY,iRed,iGreen,iBlue,iValid,iEof;
        input  oRed;
    endclocking: master_cb
    clocking slave_cb @ (posedge clk);
        default input #1step output #1ns;
        input  iX,iY,iRed,iGreen,iBlue,iPixelEn,iValid,iEof;
        output oRed;
    endclocking: slave_cb
    modport master_mp(input clk, output  oRed,oGreen,oBlue,oValid);
    modport slave_mp (input clk,iRed,iGreen,iBlue,iValid,iPixelEn,iEof,iX,iY,output oRed,oGreen,oBlue,oValid);
    modport master_sync_mp(clocking master_cb);
    modport slave_sync_mp (clocking slave_cb);
endinterface: rgb_if
interface axi4_stream_if(input bit ACLK,ARESET_N);
    parameter DATA_BYTES = 16;
	logic TVALID;	// Master valid
	logic TLAST;	// Master TLAST
    
	logic TREADY;	// Slave ready
	logic [DATA_BYTES-1:0] TDATA;	//-- Master data
	logic TUSER;	//-- Master sideband signals
	//--
    //--DEBUG signals
    //--
	//logic [DATA_BYTES/16-1:0] DEBUG_VALIDS;		//-- contains the AX-VALID Flags
	//logic [DATA_BYTES/16-1:0] DEBUG_HEADERS;	//-- contains the AX-HEADER Flags
	//logic [DATA_BYTES/16-1:0] DEBUG_TAILS;		//-- contains the AX-TAIL Flags
	////-- assigning the debug signals to TUSER
	//assign DEBUG_VALIDS     = (DATA_BYTES /16)-1: (DATA_BYTES /16);
	//assign DEBUG_HEADERS    = (DATA_BYTES /16)-1: (DATA_BYTES /16);
	//assign DEBUG_TAILS      = (DATA_BYTES /16)-1: (DATA_BYTES /16);
	//--
	//-- Interface Coverage
	//--
	covergroup axi4_cg @ (posedge ACLK);
		option.per_instance = 1;
		T_VALID : coverpoint TVALID;
		T_READY : coverpoint TREADY;
		//-- cover the amount of consecutive AXI4 transactions
		CONSECUTIVE_TRANSACTIONS: coverpoint {TVALID , TREADY}{
			bins transactions_single	= (0,1,2 =>3			=> 0,1,2);
			bins transactions_1_5[] 	= (0,1,2 =>3[*2:10] 	=> 0,1,2);
			bins transactions_11_50[] 	= (0,1,2 =>3[*11:50]	=> 0,1,2);
			bins transactions_huge 		= (0,1,2 =>3[*51:100000]=> 0,1,2);
		}
		//-- cover the waiting time after TVALID is set until TREADY in clock cycles
		TRANSACTION_WAITING: coverpoint {TVALID , TREADY}{
			bins zero_waiting_time		= (0,1				=> 3);
			bins low_waiting_time[]		= (2[*1:5]			=> 3);
			bins medium_waiting_time[]	= (2[*6:15] 		=> 3);
			bins high_waiting_time		= (2[*16:100000] 	=> 3);
			illegal_bins illegal		= (2				=> 0);
		}
		//-- Pause between Transactions
		TRANSACTION_PAUSE: coverpoint {TVALID , TREADY}{
			bins low_waiting_time[]		= (3 => 0[*1:5]		=> 2,3);
			bins medium_waiting_time[]	= (3 => 0[*6:15] 	=> 2,3);
			bins high_waiting_time		= (3 => 0[*16:100] 	=> 2,3);
		}
		//-- cover the time TREADY is active until deassertion or TVALID in clock cycles
		READY_WITHOUT_VALID: coverpoint {TVALID , TREADY}{
			bins short_ready_time[]		= (1[*1:5]  	=> 3,0);
			bins medium_ready_time[]	= (1[*6:15] 	=> 3,0);
			bins high_ready_time		= (1[*16:100000]=> 3,0);
		}
		//--cover all available transitions of TVALID/TREADY
		CASES_VALID_READY : cross T_VALID, T_READY;
		TRANSITIONS: coverpoint {TVALID, TREADY}{
			bins transition[] = ( 0,1,3 => [0:3]), (2 => 2,3) ;
		}
		//-- cover active VALID Flags
		//VALID_FLAGS : coverpoint DEBUG_VALIDS;
		//VALID_TRANSITIONS : coverpoint DEBUG_VALIDS {
		//	bins transition [] = ( [1:(1<<($size(DEBUG_VALIDS))) -1] => [1:(1<<($size(DEBUG_VALIDS))) -1] );
		//}
		//-- cover active HEADER Flags
		//HDR_FLAGS   : coverpoint DEBUG_HEADERS;
		//HDR_TRANSITIONS : coverpoint DEBUG_HEADERS {
		//	bins transition [] = ( [1:1<<($size(DEBUG_HEADERS)) -1] => [1:1<<($size(DEBUG_HEADERS)) -1] );
		//}
		////-- cover active TAIL Flags
		//TAIL_FLAGS  : coverpoint DEBUG_TAILS;
		//TAIL_TRANSITIONS : coverpoint DEBUG_TAILS {
		//	bins transition [] = ( [1:1<<($size(DEBUG_TAILS)) -1] => [1:1<<($size(DEBUG_TAILS)) -1] );
		//}
		//CROSS_HDR_TAILS : cross HDR_FLAGS, TAIL_FLAGS;
		//HDR_TAILS : coverpoint { DEBUG_HEADERS != {$size(DEBUG_HEADERS){1'b0}} ,DEBUG_TAILS != {$size(DEBUG_TAILS){1'b0}}   };
	endgroup
	//-- creating an instance of the covergroup
	axi4_cg axi4 = new();

	property reset_synchronous_deassert_p;
		@(edge ACLK)
		!ARESET_N |-> ARESET_N[->1];
	endproperty
	// chk_reset_tvalid	: assert property (
//	 	//-- TVALID must be inactive during Reset
//	 	@(posedge ACLK)
//	 	!ARESET_N |-> TVALID == 1'b0
//	 );
	chk_valid_hold 		: assert property (
		//-- if TVALID is set it must be active until TREADY
		@(posedge ACLK) disable iff(!ARESET_N)
		(TVALID == 1 && TREADY == 0) |=> (TVALID==1)
	);
	//chk_valid_headers 	: assert property (
	//	//-- check if HEADER Flags are a subset of VALID Flags
	//	@(posedge ACLK) disable iff (!ARESET_N)
	//	(TVALID == 1'b1)    |-> (DEBUG_VALIDS | DEBUG_HEADERS
	//						  == DEBUG_VALIDS)
	//);
	//chk_valid_tails 	: assert property (
	//	//-- check if TAIL Flags are a subset of VALID Flags
	//	@(posedge ACLK) disable iff (!ARESET_N)
	//	(TVALID == 1'b1)    |-> (DEBUG_VALIDS | DEBUG_TAILS
	//						  == DEBUG_VALIDS)
	//);
	//check_spanning_ax_pkts	: assert property (
	//	//-- check that TVALID stays high if a ax_packet ranges over multiple axi cycles
	//	//-- starts if more header than tails
	//	//-- completes if more tails than header
	//	@(posedge ACLK  )  disable iff (!ARESET_N)
	//		(TVALID &&						( $countones(DEBUG_HEADERS) > $countones(DEBUG_TAILS) ))
	//		|=>	(TVALID == 1) throughout 	( $countones(DEBUG_HEADERS) < $countones(DEBUG_TAILS) )[->1]
	//);
	time clk_rise;
	time reset_rise;
	always @(posedge ACLK) begin	
		if(ARESET_N == 0)
			clk_rise <= $time();
	end
	always @(posedge ARESET_N) begin
		reset_rise <= $time();
	end
	//TODO TODO ADD
	// check_sync_reset : assert property (
	// 	@(posedge ACLK)
	// 	$rose(ARESET_N) |=> (reset_rise == clk_rise)
	// 	);
	property data_hold_p;
		//-- if TVALID is set TDATA must not be changed until TREADY
		logic [DATA_BYTES-1:0] m_data;
		@(posedge ACLK) disable iff(!ARESET_N)
			(TVALID == 1 && TREADY == 0,m_data = TDATA) |=> (TDATA == m_data);
	endproperty : data_hold_p
	property user_hold_p;
		//-- if TVALID is set TUSER must not be changed until TREADY
		logic  m_user;
		@(posedge ACLK) disable iff(!ARESET_N)
			(TVALID == 1 && TREADY == 0,m_user = TUSER) |=> (TUSER == m_user);
	endproperty : user_hold_p
	chk_data_hold 		: assert property(   data_hold_p);
	chk_user_hold		: assert property(   user_hold_p);
    modport      rx_channel (input ACLK,ARESET_N,TVALID,TUSER,TLAST,TDATA,output TREADY);
endinterface : axi4_stream_if
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- MODULES
//------------------------------------------------------------------------------------
//====================================================================================
// MODULE : ADDER [TEMPLATE]
module adder(template_if.templateSlave templateVif);
    import socTest_pkg::*;
    template dut (
   .clk         (templateVif.sig_clock),
   .en_i        (templateVif.sig_en_i),
   .ina         (templateVif.sig_ina),
   .inb         (templateVif.sig_inb),
   .en_o        (templateVif.sig_en_o),
   .out         (templateVif.sig_out));
endmodule: adder
// MODULE : VFPCONFIGDUT [AXILITE] 
module vfpConfigDut(axiLite_if.ConfigMaster axiLiteVif,axi4_stream_if.rx_channel vif);
    import socTest_pkg::*;
    VFP_v1_0 dutVFP_v1Inst (
    //d5m input
    .pixclk                (),//(axiLiteVif.ACLK   ),
    .ifval                 (),//(axiLiteVif.ARESETN),
    .ilval                 (),//(axiLiteVif.AWADDR ),
    .idata                 (),//(axiLiteVif.AWPROT ),
    //tx channel           (),//
    .rgb_m_axis_aclk       (),//(axiLiteVif.ACLK   ),
    .rgb_m_axis_aresetn    (),//(axiLiteVif.ARESETN),
    .rgb_m_axis_tready     (),//(axiLiteVif.AWADDR ),
    .rgb_m_axis_tvalid     (),//(axiLiteVif.AWPROT ),
    .rgb_m_axis_tlast      (),//(axiLiteVif.AWVALID),
    .rgb_m_axis_tuser      (),//(axiLiteVif.AWREADY),
    .rgb_m_axis_tdata      (),//(axiLiteVif.WDATA  ),
    //rx channel
    .rgb_s_axis_aclk       (vif.ACLK     ),
    .rgb_s_axis_aresetn    (vif.ARESET_N ),
    .rgb_s_axis_tready     (vif.TREADY   ),
    .rgb_s_axis_tvalid     (vif.TVALID   ),
    .rgb_s_axis_tlast      (vif.TLAST    ),
    .rgb_s_axis_tuser      (vif.TUSER    ),
    .rgb_s_axis_tdata      (vif.TDATA    ),
    //destination channel  (),//
    .m_axis_mm2s_aclk      (),//(axiLiteVif.ACLK   ),
    .m_axis_mm2s_aresetn   (),//(axiLiteVif.ARESETN),
    .m_axis_mm2s_tready    (),//(axiLiteVif.AWADDR ),
    .m_axis_mm2s_tvalid    (),//(axiLiteVif.AWPROT ),
    .m_axis_mm2s_tuser     (),//(axiLiteVif.AWVALID),
    .m_axis_mm2s_tlast     (),//(axiLiteVif.AWREADY),
    .m_axis_mm2s_tdata     (),//(axiLiteVif.WDATA  ),
    .m_axis_mm2s_tkeep     (),//(axiLiteVif.AWPROT ),
    .m_axis_mm2s_tstrb     (),//(axiLiteVif.AWVALID),
    .m_axis_mm2s_tid       (),//(axiLiteVif.AWREADY),
    .m_axis_mm2s_tdest     (),//(axiLiteVif.WDATA  ),
    //video configuration  
    .vfpconfig_aclk        (axiLiteVif.ACLK   ),
    .vfpconfig_aresetn     (axiLiteVif.ARESETN),
    .vfpconfig_awaddr      (axiLiteVif.AWADDR ),
    .vfpconfig_awprot      (axiLiteVif.AWPROT ),
    .vfpconfig_awvalid     (axiLiteVif.AWVALID),
    .vfpconfig_awready     (axiLiteVif.AWREADY),
    .vfpconfig_wdata       (axiLiteVif.WDATA  ),
    .vfpconfig_wstrb       (axiLiteVif.WSTRB  ),
    .vfpconfig_wvalid      (axiLiteVif.WVALID ),
    .vfpconfig_wready      (axiLiteVif.WREADY ),
    .vfpconfig_bresp       (axiLiteVif.BRESP  ),
    .vfpconfig_bvalid      (axiLiteVif.BVALID ),
    .vfpconfig_bready      (axiLiteVif.BREADY ),
    .vfpconfig_araddr      (axiLiteVif.ARADDR ),
    .vfpconfig_arprot      (axiLiteVif.ARPROT ),
    .vfpconfig_arvalid     (axiLiteVif.ARVALID),
    .vfpconfig_arready     (axiLiteVif.ARREADY),
    .vfpconfig_rdata       (axiLiteVif.RDATA  ),
    .vfpconfig_rresp       (axiLiteVif.RRESP  ),
    .vfpconfig_rvalid      (axiLiteVif.RVALID ),
    .vfpconfig_rready      (axiLiteVif.RREADY ));
endmodule: vfpConfigDut

// MODULE : RGB_COLOR [RGB]
module rgb_color(rgb_if.slave_mp frame_slave_if);
    import socTest_pkg::*;
    pixelCord dutModule2Inst (
   .clk         (frame_slave_if.clk),
   .iRed        (frame_slave_if.iRed),
   .iGreen      (frame_slave_if.iGreen),
   .iBlue       (frame_slave_if.iBlue),
   .iValid      (frame_slave_if.iValid),
   .iPixelEn    (frame_slave_if.iPixelEn),
   .iEof        (frame_slave_if.iEof),
   .iX          (frame_slave_if.iX),
   .iY          (frame_slave_if.iY),
   .oRed        (frame_slave_if.oRed),
   .oGreen      (frame_slave_if.oGreen),
   .oBlue       (frame_slave_if.oBlue),
   .oValid      (frame_slave_if.oValid));
endmodule: rgb_color
//====================================================================================
//------------------------------------------------------------------------------------
//--------------------------------- TOP
//------------------------------------------------------------------------------------
//====================================================================================
module top;
    import uvm_pkg::*;
    import socTest_pkg::*;
    reg ACLK;
    reg ARESETN;
    reg ARESET_N;
    reg clk;
    //INTERFACE
    axiLite_if          axiLiteVif(ACLK,ARESETN);   // AXILITE-INTERFACE
    axi4_stream_if      vif(ACLK,ARESET_N);    
    rgb_if              frame_slave_if(clk);        // RGB-INTERFACE
    template_if         templateVif();              // TEMPLATE-INTERFACE
    //MODULE
    adder               templateDut(templateVif);   // [TEMPLATE]
    vfpConfigDut        vfpConfig_test(axiLiteVif,vif); // [AXILITE]
    rgb_color           frame_color(frame_slave_if);// [RGB]
    
    initial begin
        ARESETN  = 1'b0;
        ARESET_N = 1'b0;
    #1000;
        ARESETN  = 1'b1;
        ARESET_N = 1'b1;
    end
    initial begin
        ACLK = 0;
    #5ns ;
    forever #5ns ACLK = ! ACLK;
    end
    initial begin
        templateVif.sig_clock = 0;
    #5ns ;
    forever #5ns templateVif.sig_clock = ! templateVif.sig_clock;
    end
    initial begin
        clk = 0;
        #5ns ;
        forever #5ns clk = ! clk;
    end
    initial begin
    uvm_config_db #(virtual axiLite_if)::set(null, "*", "axiLiteVif", axiLiteVif);
    uvm_resource_db#(virtual template_if)::set(.scope("ifs"), .name("template_if"), .val(templateVif));
    uvm_resource_db#(virtual rgb_if)::set(.scope("ifs"),.name("rgb_if"),.val(frame_slave_if));
    uvm_config_db#(virtual axi4_stream_if)::set(.cntxt(null),.inst_name("uvm_test_top"),.field_name("vif"),.value(vif));
    run_test();
    end
endmodule: top
//====================================================================================
//------------------------------------------------------------------------------------
//---------------------------------
//------------------------------------------------------------------------------------
//====================================================================================