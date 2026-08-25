library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_processor_core is
end tb_processor_core;

architecture test of tb_processor_core is
    signal clk, reset : std_logic := '0';
    signal done : boolean := false;
    signal HEX0,HEX1,HEX2,HEX3,HEX4,HEX5: std_logic_vector(6 downto 0);

begin

    -- Correction : ajout du signe '=' manquant
    clk <= '0' when done else not(clk) after 10 ns;
    reset <= '1', '0' after 1 ns;

    -- INSTANCIATION DU PROCESSEUR (Le DUT : Device Under Test)
    dut: entity work.processor_core
        port map (
            clk ,  
            reset ,
            HEX0,HEX1,HEX2,HEX3,HEX4,HEX5
        );

    P1 : process
    begin
        wait for 80 ms; 
        done <= true;
        wait;
    end process; -- P1

end architecture test;
