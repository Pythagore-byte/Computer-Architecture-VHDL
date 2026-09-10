library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_fpga_uart is
  port (
    CLK_50 : in std_logic;
    KEY : in std_logic_vector(2 downto 0);
    SW  : in std_logic;
    HEX0,HEX1,HEX2,HEX3,HEX4,HEX5: out std_logic_vector(6 downto 0);
    TX: out std_logic
  ) ;
end top_fpga_uart;

architecture structural of top_fpga_uart is
    signal reset_i        : std_logic;
    signal key1_propre    : std_logic;
    signal key2_propre    : std_logic;
    signal irq_0 , irq_1  : std_logic;
    signal clk_slow       : std_logic;
    signal PC             : std_logic_vector(31 downto 0);
begin

    reset_i <= not KEY(0);

    ---------------------------------------------------------------------
    -- Antirebond sur les deux boutons d'interruption.
    ---------------------------------------------------------------------
    deb_1 : entity work.antirebond
        port map(CLK_50, KEY(1), key1_propre);

    deb_2 : entity work.antirebond
        port map(CLK_50, KEY(2), key2_propre);

    irq_0 <= not key1_propre;
    irq_1 <= not key2_propre;

    -- SW = '0' -> 2 Hz (pas a pas)  |  SW = '1' -> 10 Hz (demo)
    div : entity work.clk_div
        port map(CLK_50, reset_i, SW, clk_slow);

    cpu : entity work.processor_core_vic_uart
        port map(
            clk   => clk_slow,
            clk_50 => CLK_50,
            reset => reset_i,
            irq_0 => irq_0,
            irq_1 => irq_1,
            HEX0  => HEX0,
            HEX1  => HEX1,
            HEX2  => HEX2,
            HEX3  => HEX3,
            PC    => PC,
            Tx    => TX
        );

    seg_pc0 : entity work.decodeur_7_segment port map(PC(3 downto 0), HEX4);
    seg_pc1 : entity work.decodeur_7_segment port map(PC(7 downto 4), HEX5);

end architecture structural;
