library ieee;
use ieee.std_logic_1164.all;

entity top is
  port
    (
      clk   : in std_logic;
      res_n : in std_logic;

      ltm_r     : out std_logic_vector(7 downto 0);
      ltm_g     : out std_logic_vector(7 downto 0);
      ltm_b     : out std_logic_vector(7 downto 0);
      ltm_den   : out std_logic;
      ltm_vsync : out std_logic;
      ltm_hsync : out std_logic;
      ltm_clk   : out std_logic;
      ltm_res   : out std_logic;

      sdram_clk   : out   std_logic;
      sdram_addr  : out   std_logic_vector(12 downto 0);
      sdram_ba    : out   std_logic_vector(1 downto 0);
      sdram_cas_n : out   std_logic;
      sdram_cke   : out   std_logic;
      sdram_cs_n  : out   std_logic;
      sdram_dq    : inout std_logic_vector(31 downto 0) := (others => 'X');
      sdram_dqm   : out   std_logic_vector(3 downto 0);
      sdram_ras_n : out   std_logic;
      sdram_we_n  : out   std_logic
      );
end entity;

architecture arch of top is


  component raytracing is
    port (
      altpll_0_areset_conduit_export : in    std_logic                     := 'X';  -- export
      altpll_0_locked_conduit_export : out   std_logic;  -- export
      clk_clk                        : in    std_logic                     := 'X';  -- clk
      ltm_vid_data                   : out   std_logic_vector(23 downto 0);  -- vid_data
      ltm_underflow                  : out   std_logic;  -- underflow
      ltm_vid_datavalid              : out   std_logic;  -- vid_datavalid
      ltm_vid_v_sync                 : out   std_logic;  -- vid_v_sync
      ltm_vid_h_sync                 : out   std_logic;  -- vid_h_sync
      ltm_vid_f                      : out   std_logic;  -- vid_f
      ltm_vid_h                      : out   std_logic;  -- vid_h
      ltm_vid_v                      : out   std_logic;  -- vid_v
      ltm_clk_clk                    : out   std_logic;  -- clk
      reset_reset_n                  : in    std_logic                     := 'X';  -- reset_n
      sdram_addr                     : out   std_logic_vector(12 downto 0);  -- addr
      sdram_ba                       : out   std_logic_vector(1 downto 0);  -- ba
      sdram_cas_n                    : out   std_logic;  -- cas_n
      sdram_cke                      : out   std_logic;  -- cke
      sdram_cs_n                     : out   std_logic;  -- cs_n
      sdram_dq                       : inout std_logic_vector(31 downto 0) := (others => 'X');  -- dq
      sdram_dqm                      : out   std_logic_vector(3 downto 0);  -- dqm
      sdram_ras_n                    : out   std_logic;  -- ras_n
      sdram_we_n                     : out   std_logic;  -- we_n
      sdram_clk_clk                  : out   std_logic
      );
  end component raytracing;

  signal v_data        : std_logic_vector(23 downto 0);
  signal ltm_vsync_int : std_logic;
  signal ltm_hsync_int : std_logic;



begin

  u0 : component raytracing
    port map (
      clk_clk                        => clk,
      reset_reset_n                  => res_n,
      altpll_0_areset_conduit_export => '0',
      altpll_0_locked_conduit_export => open,
      ltm_vid_data                   => v_data,
      ltm_underflow                  => open,
      ltm_vid_datavalid              => ltm_den,
      ltm_vid_v_sync                 => ltm_vsync_int,
      ltm_vid_h_sync                 => ltm_hsync_int,
      ltm_vid_f                      => open,
      ltm_vid_h                      => open,
      ltm_vid_v                      => open,
      ltm_clk_clk                    => ltm_clk,
      sdram_addr                     => sdram_addr,
      sdram_ba                       => sdram_ba,
      sdram_cas_n                    => sdram_cas_n,
      sdram_cke                      => sdram_cke,
      sdram_cs_n                     => sdram_cs_n,
      sdram_dq                       => sdram_dq,
      sdram_dqm                      => sdram_dqm,
      sdram_ras_n                    => sdram_ras_n,
      sdram_we_n                     => sdram_we_n,
      sdram_clk_clk                  => sdram_clk
      );

  ltm_res   <= res_n;
  ltm_vsync <= not ltm_vsync_int;
  ltm_hsync <= not ltm_hsync_int;
  ltm_r     <= v_data(7 downto 0);
  ltm_g     <= v_data(15 downto 8);
  ltm_b     <= v_data(23 downto 16);

end architecture;


