	raytracing u0 (
		.clk_clk                        (<connected-to-clk_clk>),                        //                     clk.clk
		.ltm_vid_data                   (<connected-to-ltm_vid_data>),                   //                     ltm.vid_data
		.ltm_underflow                  (<connected-to-ltm_underflow>),                  //                        .underflow
		.ltm_vid_datavalid              (<connected-to-ltm_vid_datavalid>),              //                        .vid_datavalid
		.ltm_vid_v_sync                 (<connected-to-ltm_vid_v_sync>),                 //                        .vid_v_sync
		.ltm_vid_h_sync                 (<connected-to-ltm_vid_h_sync>),                 //                        .vid_h_sync
		.ltm_vid_f                      (<connected-to-ltm_vid_f>),                      //                        .vid_f
		.ltm_vid_h                      (<connected-to-ltm_vid_h>),                      //                        .vid_h
		.ltm_vid_v                      (<connected-to-ltm_vid_v>),                      //                        .vid_v
		.ltm_clk_clk                    (<connected-to-ltm_clk_clk>),                    //                 ltm_clk.clk
		.reset_reset_n                  (<connected-to-reset_reset_n>),                  //                   reset.reset_n
		.sdram_addr                     (<connected-to-sdram_addr>),                     //                   sdram.addr
		.sdram_ba                       (<connected-to-sdram_ba>),                       //                        .ba
		.sdram_cas_n                    (<connected-to-sdram_cas_n>),                    //                        .cas_n
		.sdram_cke                      (<connected-to-sdram_cke>),                      //                        .cke
		.sdram_cs_n                     (<connected-to-sdram_cs_n>),                     //                        .cs_n
		.sdram_dq                       (<connected-to-sdram_dq>),                       //                        .dq
		.sdram_dqm                      (<connected-to-sdram_dqm>),                      //                        .dqm
		.sdram_ras_n                    (<connected-to-sdram_ras_n>),                    //                        .ras_n
		.sdram_we_n                     (<connected-to-sdram_we_n>),                     //                        .we_n
		.altpll_0_locked_conduit_export (<connected-to-altpll_0_locked_conduit_export>), // altpll_0_locked_conduit.export
		.altpll_0_areset_conduit_export (<connected-to-altpll_0_areset_conduit_export>), // altpll_0_areset_conduit.export
		.sdram_clk_clk                  (<connected-to-sdram_clk_clk>),                  //               sdram_clk.clk
		.altpll_c4_conduit_export       (<connected-to-altpll_c4_conduit_export>)        //       altpll_c4_conduit.export
	);

