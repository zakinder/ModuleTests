--02072019 [02-07-2019]
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantspackage.all;
use work.vpfRecords.all;
entity VFP_v1_0 is
    port (
    -- d5m input
    pixclk                    : in std_logic;
    ifval                     : in std_logic;
    ilval                     : in std_logic;
    idata                     : in std_logic_vector(11 downto 0);
    --tx channel
    rgb_m_axis_aclk           : in std_logic;
    rgb_m_axis_aresetn        : in std_logic;
    rgb_m_axis_tready         : in std_logic;
    rgb_m_axis_tvalid         : out std_logic;
    rgb_m_axis_tlast          : out std_logic;
    rgb_m_axis_tuser          : out std_logic;
    rgb_m_axis_tdata          : out std_logic_vector(15 downto 0);
    --rx channel
    rgb_s_axis_aclk           : in std_logic;
    rgb_s_axis_aresetn        : in std_logic;
    rgb_s_axis_tready         : out std_logic;
    rgb_s_axis_tvalid         : in std_logic;
    rgb_s_axis_tuser          : in std_logic;
    rgb_s_axis_tlast          : in std_logic;
    rgb_s_axis_tdata          : in std_logic_vector(15 downto 0);
    --destination channel
    m_axis_mm2s_aclk          : in std_logic;
    m_axis_mm2s_aresetn       : in std_logic;
    m_axis_mm2s_tready        : in std_logic;
    m_axis_mm2s_tvalid        : out std_logic;
    m_axis_mm2s_tuser         : out std_logic;
    m_axis_mm2s_tlast         : out std_logic;
    m_axis_mm2s_tdata         : out std_logic_vector(15 downto 0);
    m_axis_mm2s_tkeep         : out std_logic_vector(2 downto 0);
    m_axis_mm2s_tstrb         : out std_logic_vector(2 downto 0);
    m_axis_mm2s_tid           : out std_logic_vector(0 downto 0);
    m_axis_mm2s_tdest         : out std_logic_vector(0 downto 0);
    --video configuration       
    vfpconfig_aclk            : in std_logic;
    vfpconfig_aresetn         : in std_logic;
    vfpconfig_awaddr          : in std_logic_vector(7 downto 0);
    vfpconfig_awprot          : in std_logic_vector(2 downto 0);
    vfpconfig_awvalid         : in std_logic;
    vfpconfig_awready         : out std_logic;
    vfpconfig_wdata           : in std_logic_vector(31 downto 0);
    vfpconfig_wstrb           : in std_logic_vector(3 downto 0);
    vfpconfig_wvalid          : in std_logic;
    vfpconfig_wready          : out std_logic;
    vfpconfig_bresp           : out std_logic_vector(1 downto 0);
    vfpconfig_bvalid          : out std_logic;
    vfpconfig_bready          : in std_logic;
    vfpconfig_araddr          : in std_logic_vector(7 downto 0);
    vfpconfig_arprot          : in std_logic_vector(2 downto 0);
    vfpconfig_arvalid         : in std_logic;
    vfpconfig_arready         : out std_logic;
    vfpconfig_rdata           : out std_logic_vector(31 downto 0);
    vfpconfig_rresp           : out std_logic_vector(1 downto 0);
    vfpconfig_rvalid          : out std_logic;
    vfpconfig_rready          : in std_logic);
end VFP_v1_0;
architecture arch_imp of VFP_v1_0 is
    constant s_data_width        : integer := 16;
component vfpConfig is
port (
        ACLK               : in std_logic;
        ARESETN            : in std_logic;
        AWADDR             : in std_logic_vector(7 downto 0);
        AWPROT             : in std_logic_vector(2 downto 0);
        AWVALID            : in std_logic;
        AWREADY            : out std_logic;
        WDATA              : in std_logic_vector(31 downto 0);
        WSTRB              : in std_logic_vector(3 downto 0);
        WVALID             : in std_logic;
        WREADY             : out std_logic;
        BRESP              : out std_logic_vector(1 downto 0);
        BVALID             : out std_logic;
        BREADY             : in std_logic;
        ARADDR             : in std_logic_vector(7 downto 0);
        ARPROT             : in std_logic_vector(2 downto 0);
        ARVALID            : in std_logic;
        ARREADY            : out std_logic;
        RDATA              : out std_logic_vector(31 downto 0);
        RRESP              : out std_logic_vector(1 downto 0);
        RVALID             : out std_logic;
        RREADY             : in std_logic);
end component vfpConfig;
component videoProcess_v1_0_m_axis_mm2s is
generic (
    s_data_width                : integer := 16);
port (
    aclk                        : in std_logic;
    aresetn                     : in std_logic;
    rgb_s_axis_tready           : out std_logic;
    rgb_s_axis_tvalid           : in std_logic;
    rgb_s_axis_tuser            : in std_logic;
    rgb_s_axis_tlast            : in std_logic;
    rgb_s_axis_tdata            : in std_logic_vector(s_data_width-1  downto 0);
    m_axis_mm2s_tkeep           : out std_logic_vector(2 downto 0);
    m_axis_mm2s_tstrb           : out std_logic_vector(2 downto 0);
    m_axis_mm2s_tid             : out std_logic_vector(0 downto 0);
    m_axis_mm2s_tdest           : out std_logic_vector(0 downto 0);  
    m_axis_mm2s_tready          : in std_logic;
    m_axis_mm2s_tvalid          : out std_logic;
    m_axis_mm2s_tuser           : out std_logic;
    m_axis_mm2s_tlast           : out std_logic;
    m_axis_mm2s_tdata           : out std_logic_vector(s_data_width-1 downto 0));
end component videoProcess_v1_0_m_axis_mm2s;


begin
vfpConfigInst: vfpConfig
port map(
    ACLK           => vfpconfig_aclk,
    ARESETN        => vfpconfig_aresetn,
    AWADDR         => vfpconfig_awaddr,
    AWPROT         => vfpconfig_awprot,
    AWVALID        => vfpconfig_awvalid,
    AWREADY        => vfpconfig_awready,
    WDATA          => vfpconfig_wdata,
    WSTRB          => vfpconfig_wstrb,
    WVALID         => vfpconfig_wvalid,
    WREADY         => vfpconfig_wready,
    BRESP          => vfpconfig_bresp,
    BVALID         => vfpconfig_bvalid,
    BREADY         => vfpconfig_bready,
    ARADDR         => vfpconfig_araddr,
    ARPROT         => vfpconfig_arprot,
    ARVALID        => vfpconfig_arvalid,
    ARREADY        => vfpconfig_arready,
    RDATA          => vfpconfig_rdata,
    RRESP          => vfpconfig_rresp,
    RVALID         => vfpconfig_rvalid,
    RREADY         => vfpconfig_rready);
mm2sInst: videoProcess_v1_0_m_axis_mm2s
generic map(
    s_data_width         => s_data_width)
port map(
    aclk                 => rgb_s_axis_aclk,
    aresetn              => rgb_s_axis_aresetn,
    rgb_s_axis_tready    => rgb_s_axis_tready,
    rgb_s_axis_tvalid    => rgb_s_axis_tvalid,
    rgb_s_axis_tuser     => rgb_s_axis_tuser,
    rgb_s_axis_tlast     => rgb_s_axis_tlast,
    rgb_s_axis_tdata     => rgb_s_axis_tdata,
    m_axis_mm2s_tkeep    => m_axis_mm2s_tkeep,
    m_axis_mm2s_tstrb    => m_axis_mm2s_tstrb,
    m_axis_mm2s_tid      => m_axis_mm2s_tid,
    m_axis_mm2s_tdest    => m_axis_mm2s_tdest,
    m_axis_mm2s_tready   => m_axis_mm2s_tready,
    m_axis_mm2s_tvalid   => m_axis_mm2s_tvalid,
    m_axis_mm2s_tuser    => m_axis_mm2s_tuser,
    m_axis_mm2s_tlast    => m_axis_mm2s_tlast,    
    m_axis_mm2s_tdata    => m_axis_mm2s_tdata);
end arch_imp;