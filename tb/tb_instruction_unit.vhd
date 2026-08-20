-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;



-- entity tb_instruction_unit is

-- end tb_instruction_unit;

-- architecture test of tb_instruction_unit is
--     signal clk, reset :  std_logic :='0';
--     signal nPCsel :std_logic;
--     signal offset : std_logic_vector(23 downto 0):=X"000001";
--     signal Instruction : std_logic_vector(31 downto 0);
--     signal done : boolean :=false;
    
-- begin

--     reset <='1','0' after  10 ns;
--     clk <= '0' when done else not(clk) after 10 ns;

--     inst: entity work.instruction_unit port map(clk, reset, nPCsel, offset, Instruction);

--     P1 : process
--     begin
--         nPCsel <='0';
--         wait for 20 ns;
--         assert (Instruction =x"E3A01020") report "ERREUR" severity note;

--         wait for 20 ns;
--         assert (Instruction =x"E3A02000") report "ERREUR" severity note;

--         -- wait for 20 ns;

--         -- assert (Instruction =x"E6110000") report "ERREUR" severity note;


--         -- wait for 20 ns;
--         -- assert (Instruction = x"E3A02000") report "ERREUR" severity note;
        
--         -- nPCsel <='1';
--         -- wait for 20 ns;
--         -- assert (Instruction = x"E6110000") report "ERREUR" severity note;

--         done <=true;
--         wait;

        
--     end process ; -- P1



    
-- end architecture;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instruction_unit_tb is
end instruction_unit_tb;

architecture Behavioral of instruction_unit_tb is

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal nPCsel      : std_logic := '0';
    signal offset      : std_logic_vector(23 downto 0) := (others => '0');
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
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

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

        -- offset = 4
        offset <= std_logic_vector(to_unsigned(4, 24));

        wait for 50 ns;

        -- =========================
        -- FIN
        -- =========================
        wait;

    end process;

end Behavioral;