library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity tb_register_file is
end tb_register_file;

architecture test of tb_register_file is
    signal clk , reset : std_logic:='0';
    signal WE: std_logic:='0';
    signal RA , RB , RW: std_logic_vector(3 downto 0):=(others=>'0');
    signal A,B,W: std_logic_vector(31 downto 0);
    signal done : boolean :=false;
    
begin
    inst: entity work.register_file port map(clk, reset, WE, RA,RB, RW,W,A,B);
    reset <='1' , '0' after 10 ns;
    clk <='0' when done else not(clk) after 10 ns;

    P1 : process
    begin
        --ECRIRE 10 DANS LE REGISTRE 1 
        WE <='1';
        RW <=X"0";
        W<=X"0000000A"; -- 
        wait for 20 ns;
        --ECRIRE 20 DANS LE REGISTRE 2
        W<=X"00000014";
        RW<=X"1";
        wait FOR 20 NS;
        --A = CONTENU REGISTRE 2 
        RA<=X"1"; 
        WE <='0';
        wait FOR 20 NS;
        assert (A=X"00000014") report "erreur sur la valeur de A" severity failure;
        RB <=X"F";
        wait FOR 20 NS;
        assert (B=X"00000030") report "erreur sur la valeur de B" severity failure;

        done <= true;
        wait;

        
    end process ; -- P1

    
end architecture test;
