-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

-- entity top_fpga is
--   port (
--     CLK_50 : in std_logic;
--     KEY : in std_logic_vector(2 downto 0);
--     SW  : in std_logic;
--     HEX0,HEX1,HEX2,HEX3,HEX4,HEX5: out std_logic_vector(6 downto 0)
--   ) ;
-- end top_fpga;

-- architecture structural of top_fpga is
--     signal reset_i        : std_logic;
--     signal irq_0 , irq_1  : std_logic;
--     signal clk_slow       : std_logic;
--     signal PC             : std_logic_vector(31 downto 0);
-- begin

--     reset_i <= not KEY(0);
--     irq_0   <= not KEY(1);
--     irq_1   <= not KEY(2);

--     -- SW = '0' -> 2 Hz (pas a pas)  |  SW = '1' -> 10 Hz (demo)
--     div : entity work.clk_div
--         port map(CLK_50, reset_i, SW, clk_slow);

--     cpu : entity work.processor_core_vic
--         port map(clk_slow, reset_i, irq_0, irq_1,
--                  HEX0, HEX1, HEX2, HEX3, PC);

    
--     seg_pc0 : entity work.decodeur_7_segment port map(PC(3 downto 0), HEX4);
--     seg_pc1 : entity work.decodeur_7_segment port map(PC(7 downto 4), HEX5);

-- end architecture structural;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_fpga is
  port (
    CLK_50 : in std_logic;
    KEY : in std_logic_vector(2 downto 0);
    SW  : in std_logic;
    HEX0,HEX1,HEX2,HEX3,HEX4,HEX5: out std_logic_vector(6 downto 0)
  ) ;
end top_fpga;

architecture structural of top_fpga is
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
    -- IMPORTANT : cadence par CLK_50, pas par clk_slow. Le compteur de
    -- 500 000 cycles vaut 10 ms a 50 MHz ; a 2 Hz il mettrait 69 heures.
    --
    -- Le filtrage travaille sur le signal BRUT (actif bas) ; l'inversion
    -- vient apres, pour que le VIC voie un front montant a l'appui.
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

    cpu : entity work.processor_core_vic
        port map(clk_slow, reset_i, irq_0, irq_1,
                 HEX0, HEX1, HEX2, HEX3, PC);

    seg_pc0 : entity work.decodeur_7_segment port map(PC(3 downto 0), HEX4);
    seg_pc1 : entity work.decodeur_7_segment port map(PC(7 downto 4), HEX5);

end architecture structural;