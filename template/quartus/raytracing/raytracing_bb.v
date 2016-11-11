
module raytracing (
	altpll_0_areset_conduit_export,
	altpll_0_locked_conduit_export,
	clk_clk,
	ltm_vid_data,
	ltm_underflow,
	ltm_vid_datavalid,
	ltm_vid_v_sync,
	ltm_vid_h_sync,
	ltm_vid_f,
	ltm_vid_h,
	ltm_vid_v,
	ltm_clk_clk,
	reset_reset_n,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n,
	sdram_clk_clk);	

	input		altpll_0_areset_conduit_export;
	output		altpll_0_locked_conduit_export;
	input		clk_clk;
	output	[23:0]	ltm_vid_data;
	output		ltm_underflow;
	output		ltm_vid_datavalid;
	output		ltm_vid_v_sync;
	output		ltm_vid_h_sync;
	output		ltm_vid_f;
	output		ltm_vid_h;
	output		ltm_vid_v;
	output		ltm_clk_clk;
	input		reset_reset_n;
	output	[12:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[31:0]	sdram_dq;
	output	[3:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
	output		sdram_clk_clk;
endmodule
