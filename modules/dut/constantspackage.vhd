
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package constantspackage is
    -------------------------------------------------------------------------
    constant yes                       : std_logic := '1';
    constant no                        : std_logic := '0';
    constant hi                        : std_logic := '1';
    constant lo                        : std_logic := '0';
    constant one                       : integer   := 1;
    constant zero                      : integer   := 0;
    constant ch0                       : integer   := 0;
    constant ch1                       : integer   := 1;
    constant ch2                       : integer   := 2;
    constant ch3                       : integer   := 3;
    -------------------------------------------------------------------------
    constant soble                     : integer   := 0;
    constant sobRgb                    : integer   := 1;
    constant sobPoi                    : integer   := 2;
    constant hsvPoi                    : integer   := 3;
    constant sharp                     : integer   := 4;
    constant blur1x                    : integer   := 5;
    constant blur2x                    : integer   := 6;
    constant blur3x                    : integer   := 7;
    constant blur4x                    : integer   := 8;
    constant hsv                       : integer   := 9;
    constant rgb                       : integer   := 10;
    constant rgbRemix                  : integer   := 11;
    constant tPatter1                  : integer   := 12;
    constant tPatter2                  : integer   := 13;
    constant tPatter3                  : integer   := 14;
    constant tPatter4                  : integer   := 15;
    constant tPatter5                  : integer   := 16;
    constant rgbCorrect                : integer   := 17;
    constant hsl                       : integer   := 18;
    constant hsvCcBl                   : integer   := 19;
    -------------------------------------------------------------------------
    -- videoProcess constants
    -------------------------------------------------------------------------
    constant C_S_AXI_DATA_WIDTH        : integer := 32;
    constant C_rgb_m_axis_TDATA_WIDTH  : integer := 16;
    constant C_rgb_m_axis_START_COUNT  : integer := 32;
    constant C_rgb_s_axis_TDATA_WIDTH  : integer := 16;
    constant C_m_axis_mm2s_TDATA_WIDTH : integer := 16;
    constant C_m_axis_mm2s_START_COUNT : integer := 32;
    constant C_vfpConfig_DATA_WIDTH    : integer := 32;
    constant C_vfpConfig_ADDR_WIDTH    : integer := 8;
    constant i_data_width              : integer := 8;
    constant s_data_width              : integer := 16;
    constant b_data_width              : integer := 32;
    constant i_precision               : integer := 12;
    constant i_full_range              : boolean := FALSE;
    constant conf_data_width           : integer := 32;
    constant conf_addr_width           : integer := 8;
    -------------------------------------------------------------------------
    constant blurMsb                   : integer := 11;
    constant blurLsb                   : integer := 4;
    constant rgb_msb                   : integer := 12;
    constant rgb_lsb                   : integer := 5;
    constant XYCOORD                   : integer := 16;
    -------------------------------------------------------------------------
    constant initCordValueRht          : integer := 0;
    constant initCordValueLft          : integer := 65535;
    constant initCordValueTop          : integer := 65535;
    constant initCordValueBot          : integer := 0;
    constant frameSizeLft              : integer := 1;
    constant frameSizeRht              : integer := 1920;
    constant frameSizeTop              : integer := 5;
    constant frameSizeBot              : integer := 1080;
    constant pInterestWidth            : integer := 127;
    constant pInterestHight            : integer := 127;
    constant white                     : std_logic_vector(7 downto 0)      :=x"FF";
    constant black                     : std_logic_vector(7 downto 0)      :=x"00";
end package;