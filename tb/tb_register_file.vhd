-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;



-- entity tb_register_file is
-- end tb_register_file;

-- architecture test of tb_register_file is
--     signal clk , reset : std_logic:='0';
--     signal WE: std_logic:='0';
--     signal RA , RB , RW: std_logic_vector(3 downto 0):=(others=>'0');
--     signal A,B,W: std_logic_vector(31 downto 0);
--     signal done : boolean :=false;
    
-- begin
--     inst: entity work.register_file port map(clk, reset, WE, RA,RB, RW,W,A,B);
--     reset <='1' , '0' after 10 ns;
--     clk <='0' when done else not(clk) after 10 ns;

--     P1 : process
--     begin
--         --ECRIRE 10 DANS LE REGISTRE 1 
--         WE <='1';
--         RW <=X"0";
--         W<=X"0000000A"; -- 
--         wait for 20 ns;
--         --ECRIRE 20 DANS LE REGISTRE 2
--         W<=X"00000014";
--         RW<=X"1";
--         wait FOR 20 NS;
--         --A = CONTENU REGISTRE 2 
--         RA<=X"1"; 
--         WE <='0';
--         wait FOR 20 NS;
--         assert (A=X"00000014") report "erreur sur la valeur de A" severity failure;
--         RB <=X"F";
--         wait FOR 20 NS;
--         assert (B=X"00000030") report "erreur sur la valeur de B" severity failure;

--         done <= true;
--         wait;

        
--     end process ; -- P1

    
-- end architecture test;


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
    signal R2_dbg : std_logic_vector(31 downto 0);
    signal done : boolean :=false;

begin
    -- Association NOMMEE : un port ajoute plus tard ne casse plus
    -- ce testbench.
    inst: entity work.register_file
        port map(clk    => clk,
                 reset  => reset,
                 WE     => WE,
                 RA     => RA,
                 RB     => RB,
                 RW     => RW,
                 W      => W,
                 A      => A,
                 B      => B,
                 R2_dbg => R2_dbg);

    reset <='1' , '0' after 10 ns;
    clk <='0' when done else not(clk) after 10 ns;

    P1 : process
    begin
        --ECRIRE 10 DANS LE REGISTRE 0
        WE <='1';
        RW <=X"0";
        W<=X"0000000A";
        wait for 20 ns;
        --ECRIRE 20 DANS LE REGISTRE 1
        W<=X"00000014";
        RW<=X"1";
        wait FOR 20 NS;
        --A = CONTENU REGISTRE 1
        RA<=X"1";
        WE <='0';
        wait FOR 20 NS;
        assert (A=X"00000014") report "erreur sur la valeur de A" severity error;
        RB <=X"F";
        wait FOR 20 NS;
        assert (B=X"00000030") report "erreur sur la valeur de B" severity error;

        --ECRIRE 100 DANS LE REGISTRE 2 ET VERIFIER LA SORTIE D'OBSERVATION
        WE <='1';
        RW <=X"2";
        W  <=X"00000064";
        wait FOR 20 NS;
        WE <='0';
        wait FOR 20 NS;
        assert (R2_dbg=X"00000064")
            report "erreur sur R2_dbg : la sortie d'observation doit suivre le registre 2"
            severity error;

        --R2_dbg NE DOIT PAS BOUGER QUAND ON ECRIT AILLEURS
        WE <='1';
        RW <=X"5";
        W  <=X"12345678";
        wait FOR 20 NS;
        WE <='0';
        wait FOR 20 NS;
        assert (R2_dbg=X"00000064")
            report "erreur : R2_dbg a change alors qu'on ecrivait dans un autre registre"
            severity error;

        report "Fin de simulation : register_file OK" severity note;
        done <= true;
        wait;


    end process ; -- P1


end architecture test;