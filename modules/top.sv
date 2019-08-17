`include "uvm_macros.svh"
package socTest_pkg;
import uvm_pkg::*;
//------------------------------------------------------------------------------------
// Defines
//------------------------------------------------------------------------------------
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


//------------------------------------------------------------------------------------
// UVM_CONFIGURATION
//------------------------------------------------------------------------------------

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


//------------------------------------------------------------------------------------
// UVM_SEQUENCE_ITEM
//------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------
// UVM_SEQUENCE
//------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------
// UVM_SEQUENCE
//------------------------------------------------------------------------------------
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




//------------------------------------------------------------------------------------
// UVM_DRIVER
//------------------------------------------------------------------------------------
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
        void'(uvm_resource_db#(virtual template_if)::read_by_name
            (.scope("ifs"), .name("template_if"), .val(templateVif)));
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



//------------------------------------------------------------------------------------
// UVM_MONITOR
//------------------------------------------------------------------------------------
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
//The second monitor, monitor_afterToDut, will get both inputs 
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



//------------------------------------------------------------------------------------
// UVM_AGENT
//------------------------------------------------------------------------------------
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




//------------------------------------------------------------------------------------
// UVM_SUBSCRIBER
//------------------------------------------------------------------------------------
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
//The rgb_transaction sent from the monitor is sampled by the write function.
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




//------------------------------------------------------------------------------------
// UVM_SCORECARD
//------------------------------------------------------------------------------------
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


//------------------------------------------------------------------------------------
// UVM_ENV
//------------------------------------------------------------------------------------
// UVM_ENV : TEMPLATE_ENV
class template_env extends uvm_env;
    `uvm_component_utils(template_env)
    protected virtual interface axiLite_if axiLiteVif;
    template_agent              sa_agent;       //[TEMPLATE]
    template_scoreboard         sa_sb;          //[TEMPLATE]
    axiLite_agent               aL_agt;         //[AXILITE]
    axiLite_fc_subscriber       aL_fc_sub;      //[AXILITE]
  //rgb_agent                   frame_agent;    //[RGB]
    rgb_agent#(par_1)           frame_agent;
    rgb_fc_subscriber           frame_fc_sub;   //[RGB]
    rgb_scoreboard              frame_sb;       //[RGB]

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sa_agent        = template_agent     ::type_id::create(.name("sa_agent"), .parent(this));
        sa_sb           = template_scoreboard::type_id::create(.name("sa_sb"), .parent(this));
        frame_agent     = rgb_agent#(par_1)  ::type_id::create(.name("frame_agent"),.parent(this));
        frame_fc_sub    = rgb_fc_subscriber  ::type_id::create(.name("frame_fc_sub"),.parent(this));
        frame_sb        = rgb_scoreboard     ::type_id::create(.name("frame_sb"),.parent(this));
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



//------------------------------------------------------------------------------------
// UVM_TEST
//------------------------------------------------------------------------------------
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
endpackage: socTest_pkg

//------------------------------------------------------------------------------------
// INTERFACE
//------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------
// MODULE
//------------------------------------------------------------------------------------
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
module vfpConfigDut(axiLite_if.ConfigMaster axiLiteVif);
    import socTest_pkg::*;
    vfpConfig dutModuleInst (
    .ACLK       (axiLiteVif.ACLK   ),
    .ARESETN    (axiLiteVif.ARESETN),
    .AWADDR     (axiLiteVif.AWADDR ),
    .AWPROT     (axiLiteVif.AWPROT ),
    .AWVALID    (axiLiteVif.AWVALID),
    .AWREADY    (axiLiteVif.AWREADY),
    .WDATA      (axiLiteVif.WDATA  ),
    .WSTRB      (axiLiteVif.WSTRB  ),
    .WVALID     (axiLiteVif.WVALID ),
    .WREADY     (axiLiteVif.WREADY ),
    .BRESP      (axiLiteVif.BRESP  ),
    .BVALID     (axiLiteVif.BVALID ),
    .BREADY     (axiLiteVif.BREADY ),
    .ARADDR     (axiLiteVif.ARADDR ),
    .ARPROT     (axiLiteVif.ARPROT ),
    .ARVALID    (axiLiteVif.ARVALID),
    .ARREADY    (axiLiteVif.ARREADY),
    .RDATA      (axiLiteVif.RDATA  ),
    .RRESP      (axiLiteVif.RRESP  ),
    .RVALID     (axiLiteVif.RVALID ),
    .RREADY     (axiLiteVif.RREADY ));
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


//------------------------------------------------------------------------------------
// MODULE TOP
//------------------------------------------------------------------------------------
module top;
    import uvm_pkg::*;
    import socTest_pkg::*;
    reg ACLK;
    reg ARESETN;
    reg clk;
    axiLite_if          axiLiteVif(ACLK,ARESETN);
    vfpConfigDut        vfpConfig_test(axiLiteVif); // [AXILITE]
    template_if         templateVif();
    adder               templateDut(templateVif);   // [TEMPLATE]
    rgb_if              frame_slave_if(clk);
    rgb_color           frame_color(frame_slave_if);// [RGB]
    initial begin
        ARESETN = 1'b0;
    #1000;
        ARESETN = 1'b1;
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
    run_test();
    end
endmodule: top
//------------------------------------------------------------------------------------