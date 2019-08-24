
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constantspackage.all;
package vpfRecords is
type channel is record
    valid            : std_logic;
    red              : std_logic_vector(7 downto 0);
    green            : std_logic_vector(7 downto 0);
    blue             : std_logic_vector(7 downto 0);
end record;

type intersectPoint is record
    lft              : integer;
    rht              : integer;
    top              : integer;
    bot              : integer;
end record;
type cord is record
    x                : integer;
    y                : integer;
end record;
type coord is record
    x                : std_logic_vector(15 downto 0);
    y                : std_logic_vector(15 downto 0);
end record;
type mRegs is record
    cfigReg0         : std_logic_vector(31 downto 0);
    cfigReg1         : std_logic_vector(31 downto 0);
    cfigReg2         : std_logic_vector(31 downto 0);
    cfigReg3         : std_logic_vector(31 downto 0);
    cfigReg4         : std_logic_vector(31 downto 0);
    cfigReg5         : std_logic_vector(31 downto 0);
    cfigReg6         : std_logic_vector(31 downto 0);
    cfigReg7         : std_logic_vector(31 downto 0);
    cfigReg8         : std_logic_vector(31 downto 0);
    cfigReg9         : std_logic_vector(31 downto 0);
    cfigReg10        : std_logic_vector(31 downto 0);
    cfigReg11        : std_logic_vector(31 downto 0);
    cfigReg12        : std_logic_vector(31 downto 0);
    cfigReg13        : std_logic_vector(31 downto 0);
    cfigReg14        : std_logic_vector(31 downto 0);
    cfigReg15        : std_logic_vector(31 downto 0);
    cfigReg16        : std_logic_vector(31 downto 0);
    cfigReg17        : std_logic_vector(31 downto 0);
    cfigReg18        : std_logic_vector(31 downto 0);
    cfigReg19        : std_logic_vector(31 downto 0);
    cfigReg20        : std_logic_vector(31 downto 0);
    cfigReg21        : std_logic_vector(31 downto 0);
    cfigReg22        : std_logic_vector(31 downto 0);
    cfigReg23        : std_logic_vector(31 downto 0);
    cfigReg24        : std_logic_vector(31 downto 0);
    cfigReg25        : std_logic_vector(31 downto 0);
    cfigReg26        : std_logic_vector(31 downto 0);
    cfigReg27        : std_logic_vector(31 downto 0);
    cfigReg28        : std_logic_vector(31 downto 0);
    cfigReg29        : std_logic_vector(31 downto 0);
    cfigReg30        : std_logic_vector(31 downto 0);
    cfigReg31        : std_logic_vector(31 downto 0);
    cfigReg32        : std_logic_vector(31 downto 0);
    cfigReg33	     : std_logic_vector(31 downto 0);
    cfigReg34	     : std_logic_vector(31 downto 0);
    cfigReg35	     : std_logic_vector(31 downto 0);
    cfigReg36	     : std_logic_vector(31 downto 0);
    cfigReg37	     : std_logic_vector(31 downto 0);
    cfigReg38	     : std_logic_vector(31 downto 0);
    cfigReg39	     : std_logic_vector(31 downto 0);
    cfigReg40	     : std_logic_vector(31 downto 0);
    cfigReg41	     : std_logic_vector(31 downto 0);
    cfigReg42	     : std_logic_vector(31 downto 0);
    cfigReg43	     : std_logic_vector(31 downto 0);
    cfigReg44	     : std_logic_vector(31 downto 0);
    cfigReg45	     : std_logic_vector(31 downto 0);
    cfigReg46	     : std_logic_vector(31 downto 0);
    cfigReg47	     : std_logic_vector(31 downto 0);
    cfigReg48	     : std_logic_vector(31 downto 0);
    cfigReg49	     : std_logic_vector(31 downto 0);
    cfigReg50	     : std_logic_vector(31 downto 0);
    cfigReg51	     : std_logic_vector(31 downto 0);
    cfigReg52	     : std_logic_vector(31 downto 0);
    cfigReg53	     : std_logic_vector(31 downto 0);
    cfigReg54	     : std_logic_vector(31 downto 0);
    cfigReg55	     : std_logic_vector(31 downto 0);
    cfigReg56	     : std_logic_vector(31 downto 0);
    cfigReg57	     : std_logic_vector(31 downto 0);
    cfigReg58	     : std_logic_vector(31 downto 0);
    cfigReg59	     : std_logic_vector(31 downto 0);
    cfigReg60	     : std_logic_vector(31 downto 0);
    cfigReg61	     : std_logic_vector(31 downto 0);
    cfigReg62	     : std_logic_vector(31 downto 0);
    cfigReg63	     : std_logic_vector(31 downto 0);
end record;
type rData is record
    pEof             : std_logic;
    pSof             : std_logic;
    valid            : std_logic;
    data             : std_logic_vector(11 downto 0);
    cord             : coord;
end record;
type rgbSnSumRecord is record
    red              : signed(ADD_RESULT_WIDTH-1 downto 0);
    green            : signed(ADD_RESULT_WIDTH-1 downto 0);
    blue             : signed(ADD_RESULT_WIDTH-1 downto 0);
end record;
type rgbSnSumTrRecord is record
    red              : signed(12 downto 0);
    green            : signed(12 downto 0);
    blue             : signed(12 downto 0);
end record;




type tpRgb is record
    valid            : std_logic;
    red              : std_logic_vector(11 downto 0);
    green            : std_logic_vector(11 downto 0);
    blue             : std_logic_vector(11 downto 0);
end record;
type uChannel is record
    valid            : std_logic;
    red              : unsigned(7 downto 0);
    green            : unsigned(7 downto 0);
    blue             : unsigned(7 downto 0);
end record;
type intChannel is record
    valid            : std_logic;
    red              : integer;
    green            : integer;
    blue             : integer;
end record;
type blurchannel is record
    valid            : std_logic;
    red              : std_logic_vector(11 downto 0);
    green            : std_logic_vector(11 downto 0);
    blue             : std_logic_vector(11 downto 0);
end record;

type hsvChannel is record
    valid            : std_logic;
    h                : std_logic_vector(7 downto 0);
    s                : std_logic_vector(7 downto 0);
    v                : std_logic_vector(7 downto 0);
end record;


type coefficient is record
    k1               : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    k2               : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    k3               : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    k4               : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    k5               : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    k6               : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    k7               : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    k8               : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    k9               : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    config           : integer;
end record;
type region is record
    rl               : std_logic_vector(i_data_width-1 downto 0);-- :=x"0A";
    rh               : std_logic_vector(i_data_width-1 downto 0);-- :=x"50";
    gl               : std_logic_vector(i_data_width-1 downto 0);-- :=x"0A";
    gh               : std_logic_vector(i_data_width-1 downto 0);-- :=x"50";
    bl               : std_logic_vector(i_data_width-1 downto 0);-- :=x"0A";
    bh               : std_logic_vector(i_data_width-1 downto 0);-- :=x"50";
end record;
type poi is record
    pointInterest    : integer;
    deltaConfig      : integer;
    cpuAckGoAgain    : std_logic;
    cpuWgridLock     : std_logic;
    cpuAckoffFrame   : std_logic;
    fifoReadAddress  : std_logic_vector(13 downto 0);
    fifoReadEnable   : std_logic;
    clearFifoData    : std_logic;
end record;  
type rawRgb is record
    red              : unsigned(11 downto 0);
    green            : unsigned(12 downto 0);
    blue             : unsigned(11 downto 0);
end record;
type tp is record
    tp1              : std_logic_vector(11 downto 0);
    tp2              : std_logic_vector(11 downto 0);
    tp3              : std_logic_vector(11 downto 0);
end record;
type uTp is record
    tp1              : unsigned(11 downto 0);
    tp2              : unsigned(11 downto 0);
    tp3              : unsigned(11 downto 0);
end record;
type vStreamData is record
    eof              : std_logic;
    sof              : std_logic;
    ycbcr            : channel;
    cord             : coord;
end record;

type rTp is record
    pEof             : std_logic;
    pSof             : std_logic;
    valid            : std_logic;
    taps             : tp;
    cord             : coord;
end record;
type rRgb is record
    pEof             : std_logic;
    pSof             : std_logic;
    valid            : std_logic;
    red              : std_logic_vector(7 downto 0);
    green            : std_logic_vector(7 downto 0);
    blue             : std_logic_vector(7 downto 0);
    cord             : coord;
end record;
type fcolors is record
    rgb              : channel;
    hsl              : channel;
    hsv              : channel;
    hsvCcBl          : channel;
    sharp            : channel;
    blur1x           : channel;
    blur2x           : channel;
    blur3x           : channel;
    blur4x           : channel;
    rgbCorrect       : channel;
    soble            : channel;
    rgbRemix         : channel;
    rgbDetect        : channel;
    rgbPoi           : channel;
    rgbSum           : tpRgb;
    rgbDetectLock    : std_logic;
    rgbPoiLock       : std_logic;
    pEof             : std_logic;
    pSof             : std_logic;
    cod              : coord;
end record;

type detap is record
    vTap0x           : signed(i_data_width downto 0);
    vTap1x           : signed(i_data_width downto 0);
    vTap2x           : signed(i_data_width downto 0);
end record;
type s_pixel is record
    m1               : signed (17 downto 0);
    m2               : signed (17 downto 0);
    m3               : signed (17 downto 0);
    mac              : signed (16 downto 0);
end record;
type presults is record
    pax              : signed (16 downto 0);
    pay              : signed (16 downto 0);
    mx               : signed (34 downto 0);
    my               : signed (34 downto 0);
    sxy              : signed (34 downto 0);
    sqr              : std_logic_vector (31 downto 0);
    edgeValid        : std_logic;
    sbof             : std_logic_vector (31 downto 0);
end record;
end package;