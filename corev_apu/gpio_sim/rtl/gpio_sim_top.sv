// This module can not handle writes right now

module gpio_sim_top #(
    parameter int unsigned DATA_WIDTH   = 8,
    parameter int unsigned ID_SLV_WIDTH   = 8,
    parameter int unsigned USER_WIDTH   = 8,

    // AXI request/response
    parameter type         axi_req_t      = logic,
    parameter type         axi_rsp_t      = logic
) (
    input   logic clk_i,
    input   logic rst_ni,

    // // AXI Config Slave port
    input  axi_req_t    slv_req_i,
    output axi_rsp_t    slv_rsp_o
);

    enum logic [1:0] {
        IDLE,
        R_RESP
    } axi_state_q, axi_state_d;

    axi_pkg::len_t burst_len_d, burst_len_q;
    logic [ID_SLV_WIDTH-1:0] id_d, id_q;
    logic [1:0] read_counter_d, read_counter_q; // Every four reads we send a correct digit
    logic [USER_WIDTH - 1 : 0] user_d, user_q;

    always_comb begin
        axi_state_d = axi_state_q;
        burst_len_d = burst_len_q;
        id_d = id_q;
        user_d = user_q;
        read_counter_d = read_counter_q;
        slv_rsp_o   = '{default: '0};

        case (axi_state_q)
            IDLE: begin
                slv_rsp_o.ar_ready = 1'b1;
                if (slv_req_i.ar_valid) begin
                    read_counter_d = read_counter_q + 1;
                    axi_state_d = R_RESP;
                    burst_len_d = slv_req_i.ar.len;
                    id_d = slv_req_i.ar.id;
                    user_d = slv_req_i.ar.nsaid;
                end
            end
            R_RESP: begin
                slv_rsp_o.r_valid = 1'b1;
                slv_rsp_o.r.data  = {{DATA_WIDTH-USER_WIDTH{1'b0}}, user_q};//read_counter_q == 2'h0 ? 64'h87 : 64'h0;
                slv_rsp_o.r.resp  = axi_pkg::RESP_OKAY;
                slv_rsp_o.r.id    = id_q;
                slv_rsp_o.r.last = (burst_len_q == 0);

                if (slv_req_i.r_ready) begin
                    burst_len_d = burst_len_q - 1;

                    if (burst_len_q == 0) begin
                        axi_state_d = IDLE;
                    end
                end
            end
        endcase
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            axi_state_q <= IDLE;
            burst_len_q <= '0;
            read_counter_q <= '0;
            id_q <= '0;
            user_q <= '0;
        end else begin
            axi_state_q <= axi_state_d;
            burst_len_q <= burst_len_d;
            read_counter_q <= read_counter_d;
            id_q <= id_d;
            user_q <= user_d;
        end
    end
endmodule