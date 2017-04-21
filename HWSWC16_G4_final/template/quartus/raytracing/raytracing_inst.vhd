	component raytracing is
		port (
			clk_clk                        : in    std_logic                     := 'X';             -- clk
			ltm_vid_data                   : out   std_logic_vector(23 downto 0);                    -- vid_data
			ltm_underflow                  : out   std_logic;                                        -- underflow
			ltm_vid_datavalid              : out   std_logic;                                        -- vid_datavalid
			ltm_vid_v_sync                 : out   std_logic;                                        -- vid_v_sync
			ltm_vid_h_sync                 : out   std_logic;                                        -- vid_h_sync
			ltm_vid_f                      : out   std_logic;                                        -- vid_f
			ltm_vid_h                      : out   std_logic;                                        -- vid_h
			ltm_vid_v                      : out   std_logic;                                        -- vid_v
			ltm_clk_clk                    : out   std_logic;                                        -- clk
			reset_reset_n                  : in    std_logic                     := 'X';             -- reset_n
			sdram_addr                     : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_ba                       : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_cas_n                    : out   std_logic;                                        -- cas_n
			sdram_cke                      : out   std_logic;                                        -- cke
			sdram_cs_n                     : out   std_logic;                                        -- cs_n
			sdram_dq                       : inout std_logic_vector(31 downto 0) := (others => 'X'); -- dq
			sdram_dqm                      : out   std_logic_vector(3 downto 0);                     -- dqm
			sdram_ras_n                    : out   std_logic;                                        -- ras_n
			sdram_we_n                     : out   std_logic;                                        -- we_n
			altpll_0_locked_conduit_export : out   std_logic;                                        -- export
			altpll_0_areset_conduit_export : in    std_logic                     := 'X';             -- export
			sdram_clk_clk                  : out   std_logic;                                        -- clk
			altpll_c4_conduit_export       : out   std_logic                                         -- export
		);
	end component raytracing;

	u0 : component raytracing
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --                     clk.clk
			ltm_vid_data                   => CONNECTED_TO_ltm_vid_data,                   --                     ltm.vid_data
			ltm_underflow                  => CONNECTED_TO_ltm_underflow,                  --                        .underflow
			ltm_vid_datavalid              => CONNECTED_TO_ltm_vid_datavalid,              --                        .vid_datavalid
			ltm_vid_v_sync                 => CONNECTED_TO_ltm_vid_v_sync,                 --                        .vid_v_sync
			ltm_vid_h_sync                 => CONNECTED_TO_ltm_vid_h_sync,                 --                        .vid_h_sync
			ltm_vid_f                      => CONNECTED_TO_ltm_vid_f,                      --                        .vid_f
			ltm_vid_h                      => CONNECTED_TO_ltm_vid_h,                      --                        .vid_h
			ltm_vid_v                      => CONNECTED_TO_ltm_vid_v,                      --                        .vid_v
			ltm_clk_clk                    => CONNECTED_TO_ltm_clk_clk,                    --                 ltm_clk.clk
			reset_reset_n                  => CONNECTED_TO_reset_reset_n,                  --                   reset.reset_n
			sdram_addr                     => CONNECTED_TO_sdram_addr,                     --                   sdram.addr
			sdram_ba                       => CONNECTED_TO_sdram_ba,                       --                        .ba
			sdram_cas_n                    => CONNECTED_TO_sdram_cas_n,                    --                        .cas_n
			sdram_cke                      => CONNECTED_TO_sdram_cke,                      --                        .cke
			sdram_cs_n                     => CONNECTED_TO_sdram_cs_n,                     --                        .cs_n
			sdram_dq                       => CONNECTED_TO_sdram_dq,                       --                        .dq
			sdram_dqm                      => CONNECTED_TO_sdram_dqm,                      --                        .dqm
			sdram_ras_n                    => CONNECTED_TO_sdram_ras_n,                    --                        .ras_n
			sdram_we_n                     => CONNECTED_TO_sdram_we_n,                     --                        .we_n
			altpll_0_locked_conduit_export => CONNECTED_TO_altpll_0_locked_conduit_export, -- altpll_0_locked_conduit.export
			altpll_0_areset_conduit_export => CONNECTED_TO_altpll_0_areset_conduit_export, -- altpll_0_areset_conduit.export
			sdram_clk_clk                  => CONNECTED_TO_sdram_clk_clk,                  --               sdram_clk.clk
			altpll_c4_conduit_export       => CONNECTED_TO_altpll_c4_conduit_export        --       altpll_c4_conduit.export
		);

