
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_instruction_unit is
end tb_instruction_unit;

architecture Behavioral of tb_instruction_unit is

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal nPCsel      : std_logic := '0';
    signal offset      : std_logic_vector(23 downto 0) := (others => '0');
    signal done : boolean:=false;
    signal Instruction : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instance du circuit à tester
    DUT : entity work.instruction_unit
        port map (
            clk         => clk,
            reset       => reset,
            nPCsel      => nPCsel,
            offset      => offset,
            Instruction => Instruction
        );

    -- Génération de l'horloge
    clk<='0' when done else not(clk) after CLK_PERIOD/2;

    -- Stimuli
    stimulus : process
    begin
        -- =========================
        -- TEST 1 : RESET
        -- =========================
        reset <= '1';
        nPCsel <= '0';
        offset <= (others => '0');

        wait for 20 ns;

        reset <= '0';

        -- =========================
        -- TEST 2 : PC + 1
        -- nPCsel = 0
        -- =========================
        nPCsel <= '0';

        wait for 50 ns;

        -- =========================
        -- TEST 3 : PC + 1 + offset
        -- nPCsel = 1
        -- =========================
        nPCsel <= '1';

        -- offset = 1
        offset <= std_logic_vector(to_signed(1, 24));

        wait for 20 ns;

        -- =========================
        -- FIN
        -- =========================
        done <=true;
        wait;

    end process;

end Behavioral;