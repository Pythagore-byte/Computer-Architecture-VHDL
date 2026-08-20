library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;




entity tb_sign_extend is

end tb_sign_extend;

architecture test of tb_sign_extend is
    signal N : integer:=2;
    signal S : std_logic_vector(31 downto 0);
    signal E : std_logic_vector(N-1 downto 0);
    
begin

    inst : entity work.sign_extend generic map(N) port map(E,S);


    P1 : process
    begin
        E<="10";
        WAIT FOR 10 NS;
        assert (S=X"FFFFFFFE") report "ERREUR SUR LA SORTIE" severity FAILURE;
        E<="01";
        WAIT FOR 10 NS;
        assert (S=X"00000001") report "ERREUR SUR LA SORTIE" severity FAILURE;
        WAIT;
    end process ; -- P1
    
end architecture test;