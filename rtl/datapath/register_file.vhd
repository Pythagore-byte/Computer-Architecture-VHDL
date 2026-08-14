library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity register_file is
    port(
        clk:   in std_logic;
        reset: in std_logic;
        WE:    in std_logic;
        RA:    in std_logic;
        RB:    in std_logic;
        RW:    in std_logic;
        W:     in std_logic_vector(31 downto 0);
        A:     out std_logic_vector(31 downto 0);
        B:     out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of register_file is
    type table is array (15 downto 0) of std_logic_vector(31 downto 0);
    -- fonction d'initialisatio du banc de registre
    function init_banc return table is
        variable result : table;
        for i in 14 downto 0 loop
            result(i):=(others=>'0');
        end loop;
        result(15):=x"00000030"; --valeur de derniere case du registre
    end init_banc;
        signal banc: table := init_banc;

begin
    P1 : process(clk, reset)
    begin
        if reset='1' then
            banc <= init_banc;
        elsif rising_edge(clk) then
            if WE='1' then
                banc(to_integer(unsigned(RW))) <=W;
            end if;
        end if; 
    end process ; -- P1
    A<=banc(to_integer(unsigned(RA)));
    B<=banc(to_integer(unsigned(RB)));
    
 
end architecture rtl;