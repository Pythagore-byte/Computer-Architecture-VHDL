library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity tb_data_memory is
end tb_data_memory;




architecture test of tb_data_memory is
    signal clk, reset: std_logic:='0';
    signal Wen : std_logic:='0';
    signal addr : std_logic_vector(5 downto 0);
    signal DataIn: std_logic_vector(31 downto 0):=std_logic_vector(to_unsigned(10, 32));
    signal DataOut: std_logic_vector(31 downto 0);
    signal done :boolean:=false;
    
begin
    inst: entity work.data_memory port map(clk, reset, Wen, addr, DataIn, DataOut);


    reset <='1','0' after 5 ns;
    clk <= '0' when done else not(clk) after 10 ns;
    P1 : process
    begin
        --choisir l address 30 de la memoire
        addr <=std_logic_vector(to_unsigned(30, 6));
        wait for 20 ns;
        assert (DataOut = std_logic_vector(to_unsigned(30, 32))) report "ERREUR"  severity FAILURE;
        --ecrire a l 'address 30 la valeur 10 
        Wen <='1';
        wait for 20 ns;
        assert (DataOut = std_logic_vector(to_unsigned(10, 32))) report "ERREUR"  severity FAILURE;
        --ecrire a la case memoire 64 la valeur 200
        DataIn <= std_logic_vector(to_unsigned(200, 32));
        addr <=std_logic_vector(to_unsigned(64, 6));
        wait for 20 ns;
        assert (DataOut = std_logic_vector(to_unsigned(200, 32))) report "ERREUR"  severity FAILURE;
        done <=true;
        wait;

        
    end process ; -- P1
    

end architecture test;
