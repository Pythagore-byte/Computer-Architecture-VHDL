library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_datapath is
end tb_datapath;



architecture test of tb_datapath is
    signal clk, reset : std_logic:='0';
    signal COM1, COM2 : std_logic:='0';
    signal WrEn: std_logic:='0';
    signal Imm: std_logic_vector(7 downto 0):=std_logic_vector(to_unsigned(8,8));
    signal OP: std_logic_vector(2 downto 0):="000";
    signal RW,RA,RB: std_logic_vector(3 downto 0):="0000";
    signal RegWr : std_logic:='0';
    signal N,Z,C,V: std_logic;
    signal done : boolean:=false;
    
begin

    inst: entity work.datapath port map(clk, reset, COM1, COM2, WrEn, Imm, OP,RW,RA,RB, RegWr, N,Z,C,V);

    clk <= '0' when done else not(clk) after 10 ns;
    reset <='1', '0' after 5 ns ; 



    P1 : process
    begin
        --test 1: l'addition de deux registre R(1) = R(1)+R(15)
        RegWr <='1'; -- autorisation de l ecriture dans le registre
        RA <=X"1"; -- R(1)
        RB<=X"F"; -- R(15)
        RW<=X"1"; -- ECRIRE LE RESULTAT DE R(1)+R(15) DANS R(1)
        wait FOR 20 NS;
        --test 2 : l'additon d un registre avec une valeur immediate , R(2)= R(1)+8
        RW <=X"2"; --ECRIRE DANS R(2)
        COM1 <='1';
        wait FOR 20 NS;
        --test 3 : la soustraction de deux registres R(3) = R(2)-R(15)
        OP <= "010"; --OPERANDE POUR LA SOUSTRACTION
        RW <= X"3"; --ECRIRE DANS R(3)
        RA<=X"2"; -- R(2)
        COM1<='0';
        wait FOR 20 NS;
        --test 4 : la soustraction d une valeur immediate a un registre
        Imm <= std_logic_vector(to_unsigned(10,8));
        RW <=X"4"; --ECRIRE DANS R(4)
        RA<=X"3";
        COM1<='1';
        wait FOR 20 NS;
        --test 5 : La copie de la valeur d’un registre dans un autre registre R(14) = R(2)
        OP <="011";
        RA<=X"2";
        wait FOR 20 NS;
        --test 6 : L’écriture d’un registre dans un mot de la mémoire memory(0) = R(2)
        RegWr <='0'; -- ecriture dans le registre desactivee
        WrEn <= '1'; -- ecriture dans la memoire 
        Imm <= std_logic_vector(to_unsigned(56,8));
        OP <="010";
        RB<=X"2";
        wait FOR 20 NS;
        --test 7 : La lecture d’un mot de la mémoire dans un registre R(10) = memory(63)
        RegWr <='1';
        COM2 <='1';
        Imm <= std_logic_vector(to_unsigned(7,8));
        OP<="000";
        RW <=X"A";
        wait FOR 20 NS;

        done <= true;
        wait;
    end process ; 
    
end architecture test;
