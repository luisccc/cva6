// AXI4 slave backed by a single tc_sram_wrapper port.
//
// One AXI transaction is serviced at a time.  This matches the single-port
// FPGA implementation of tc_sram_wrapper while still supporting FIXED, INCR,
// and WRAP bursts, narrow writes, response backpressure, and arbitrary SRAM
// read latency.
module axi_memory #(
    parameter int unsigned NumWords    = 32'd1024,
    parameter int unsigned DataWidth   = 32'd128,
    parameter int unsigned ByteWidth   = 32'd8,
    parameter int unsigned NumPorts    = 32'd2,
    parameter int unsigned Latency     = 32'd1,
    parameter              SimInit     = "none",
    parameter bit          PrintSimCfg = 1'b0,

    parameter type axi_req_t = logic,
    parameter type axi_rsp_t = logic,

    // Dependent parameters; do not override.
    parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
    parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth,
    parameter type         addr_t    = logic [AddrWidth-1:0],
    parameter type         data_t    = logic [DataWidth-1:0],
    parameter type         be_t      = logic [BeWidth-1:0]
) (
    input  logic     clk_i,
    input  logic     rst_ni,

    input  axi_req_t slv_req_i,
    output axi_rsp_t slv_rsp_o
);

    localparam int unsigned ByteOffsetWidth = (BeWidth > 1) ? $clog2(BeWidth) : 0;
    localparam int unsigned WaitWidth = (Latency > 1) ? $clog2(Latency) : 1;

    typedef enum logic [2:0] {
        IDLE,
        READ_WAIT,
        READ_RESP,
        WRITE_DATA,
        WRITE_RESP
    } state_t;

    state_t   state_q, state_d;
    axi_req_t req_q, req_d;

    // Index of the read beat being returned or the write beat expected next.
    axi_pkg::len_t beat_q, beat_d;
    logic [WaitWidth-1:0] read_wait_q, read_wait_d;

    logic  [NumPorts-1:0] mem_req;
    logic  [NumPorts-1:0] mem_we;
    addr_t [NumPorts-1:0] mem_addr;
    data_t [NumPorts-1:0] mem_wdata;
    be_t   [NumPorts-1:0] mem_be;
    data_t [NumPorts-1:0] mem_rdata;

    function automatic addr_t to_word_addr(input axi_pkg::largest_addr_t byte_addr);
        return addr_t'(byte_addr >> ByteOffsetWidth);
    endfunction

    function automatic axi_pkg::largest_addr_t read_beat_addr(
        input axi_pkg::len_t beat
    );
        return axi_pkg::beat_addr(
            axi_pkg::largest_addr_t'(req_q.ar.addr),
            req_q.ar.size,
            req_q.ar.len,
            req_q.ar.burst,
            shortint'(beat)
        );
    endfunction

    function automatic axi_pkg::largest_addr_t write_beat_addr(
        input axi_pkg::len_t beat
    );
        return axi_pkg::beat_addr(
            axi_pkg::largest_addr_t'(req_q.aw.addr),
            req_q.aw.size,
            req_q.aw.len,
            req_q.aw.burst,
            shortint'(beat)
        );
    endfunction

    always_comb begin
        state_d     = state_q;
        req_d       = req_q;
        beat_d      = beat_q;
        read_wait_d = read_wait_q;

        slv_rsp_o = '0;
        mem_req   = '0;
        mem_we    = '0;
        mem_addr  = '0;
        mem_wdata = '0;
        mem_be    = '0;

        unique case (state_q)
            IDLE: begin
                // Reads have priority if AR and AW arrive in the same cycle.
                if (slv_req_i.ar_valid) begin
                    slv_rsp_o.ar_ready = 1'b1;

                    req_d  = slv_req_i;
                    beat_d = '0;

                    mem_req[0]  = 1'b1;
                    mem_addr[0] = to_word_addr(
                        axi_pkg::largest_addr_t'(slv_req_i.ar.addr)
                    );

                    if (Latency <= 1) begin
                        state_d = READ_RESP;
                    end else begin
                        state_d     = READ_WAIT;
                        read_wait_d = WaitWidth'(Latency - 1);
                    end
                end else begin
                    slv_rsp_o.aw_ready = 1'b1;

                    if (slv_req_i.aw_valid) begin
                        req_d  = slv_req_i;
                        beat_d = '0;

                        // AXI permits AW and the first W beat to handshake together.
                        slv_rsp_o.w_ready = 1'b1;
                        if (slv_req_i.w_valid) begin
                            mem_req[0]   = 1'b1;
                            mem_we[0]    = 1'b1;
                            mem_addr[0]  = to_word_addr(
                                axi_pkg::largest_addr_t'(slv_req_i.aw.addr)
                            );
                            mem_wdata[0] = data_t'(slv_req_i.w.data);
                            mem_be[0]    = be_t'(slv_req_i.w.strb);

                            if (slv_req_i.aw.len == '0) begin
                                state_d = WRITE_RESP;
                            end else begin
                                state_d = WRITE_DATA;
                                beat_d  = axi_pkg::len_t'(1);
                            end
                        end else begin
                            state_d = WRITE_DATA;
                        end
                    end
                end
            end

            READ_WAIT: begin
                if (read_wait_q == WaitWidth'(1)) begin
                    state_d = READ_RESP;
                end else begin
                    read_wait_d = read_wait_q - WaitWidth'(1);
                end
            end

            READ_RESP: begin
                slv_rsp_o.r_valid = 1'b1;
                slv_rsp_o.r.data  = mem_rdata[0];
                slv_rsp_o.r.resp  = axi_pkg::RESP_OKAY;
                slv_rsp_o.r.id    = req_q.ar.id;
                slv_rsp_o.r.user  = req_q.ar.user;
                slv_rsp_o.r.last  = (beat_q == req_q.ar.len);

                if (slv_req_i.r_ready) begin
                    if (beat_q == req_q.ar.len) begin
                        state_d = IDLE;
                    end else begin
                        beat_d      = beat_q + axi_pkg::len_t'(1);
                        mem_req[0]  = 1'b1;
                        mem_addr[0] = to_word_addr(
                            read_beat_addr(beat_q + axi_pkg::len_t'(1))
                        );

                        if (Latency > 1) begin
                            state_d     = READ_WAIT;
                            read_wait_d = WaitWidth'(Latency - 1);
                        end
                    end
                end
            end

            WRITE_DATA: begin
                slv_rsp_o.w_ready = 1'b1;

                if (slv_req_i.w_valid) begin
                    mem_req[0]   = 1'b1;
                    mem_we[0]    = 1'b1;
                    mem_addr[0]  = to_word_addr(write_beat_addr(beat_q));
                    mem_wdata[0] = data_t'(slv_req_i.w.data);
                    mem_be[0]    = be_t'(slv_req_i.w.strb);

                    if (beat_q == req_q.aw.len) begin
                        state_d = WRITE_RESP;
                    end else begin
                        beat_d = beat_q + axi_pkg::len_t'(1);
                    end
                end
            end

            WRITE_RESP: begin
                slv_rsp_o.b_valid = 1'b1;
                slv_rsp_o.b.resp  = axi_pkg::RESP_OKAY;
                slv_rsp_o.b.id    = req_q.aw.id;
                slv_rsp_o.b.user  = '0;

                if (slv_req_i.b_ready) begin
                    state_d = IDLE;
                end
            end

            default: state_d = IDLE;
        endcase
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_q     <= IDLE;
            req_q       <= '0;
            beat_q      <= '0;
            read_wait_q <= '0;
        end else begin
            state_q     <= state_d;
            req_q       <= req_d;
            beat_q      <= beat_d;
            read_wait_q <= read_wait_d;
        end
    end

    tc_sram_wrapper #(
        .NumWords    (NumWords),
        .DataWidth   (DataWidth),
        .ByteWidth   (ByteWidth),
        .NumPorts    (NumPorts),
        .Latency     (Latency),
        .SimInit     (SimInit),
        .PrintSimCfg (PrintSimCfg),
        .AddrWidth   (AddrWidth),
        .BeWidth     (BeWidth),
        .addr_t      (addr_t),
        .data_t      (data_t),
        .be_t        (be_t)
    ) i_tc_sram_wrapper (
        .clk_i,
        .rst_ni,
        .req_i   (mem_req),
        .we_i    (mem_we),
        .addr_i  (mem_addr),
        .wdata_i (mem_wdata),
        .be_i    (mem_be),
        .rdata_o (mem_rdata)
    );

    // pragma translate_off
    initial begin : p_parameter_checks
        assert (NumPorts >= 1)
            else $fatal(1, "axi_memory requires at least one SRAM port");
        assert (ByteWidth == 8)
            else $fatal(1, "AXI WSTRB requires ByteWidth to be 8");
        assert (DataWidth == BeWidth * ByteWidth)
            else $fatal(1, "DataWidth must be an integer number of bytes");
        assert (BeWidth == 1 || (BeWidth & (BeWidth - 1)) == 0)
            else $fatal(1, "AXI data width must contain a power-of-two number of bytes");
        assert ($bits(slv_req_i.w.data) == DataWidth)
            else $fatal(1, "AXI and SRAM data widths do not match");
        assert ($bits(slv_req_i.w.strb) == BeWidth)
            else $fatal(1, "AXI strobe and SRAM byte-enable widths do not match");
    end

    assert property (@(posedge clk_i) disable iff (!rst_ni)
        state_q == WRITE_DATA && slv_req_i.w_valid && slv_rsp_o.w_ready
        |-> slv_req_i.w.last == (beat_q == req_q.aw.len))
        else $error("AXI WLAST does not match AWLEN");

    assert property (@(posedge clk_i) disable iff (!rst_ni)
        state_q == IDLE && !slv_req_i.ar_valid && slv_req_i.aw_valid &&
        slv_req_i.w_valid && slv_rsp_o.w_ready
        |-> slv_req_i.w.last == (slv_req_i.aw.len == '0))
        else $error("AXI WLAST does not match AWLEN");
    // pragma translate_on

endmodule
