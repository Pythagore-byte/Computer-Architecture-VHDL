--------------------------------------------------------------------------------
-- Banc de test : alu.vhd
-- Verifie les 8 operations et les drapeaux N, Z, C, V
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alu is
end entity tb_alu;

architecture sim of tb_alu is

    component alu is
        port (
            OP : in  std_logic_vector(2 downto 0);
            A  : in  std_logic_vector(31 downto 0);
            B  : in  std_logic_vector(31 downto 0);
            S  : out std_logic_vector(31 downto 0);
            N  : out std_logic;
            Z  : out std_logic;
            C  : out std_logic;
            V  : out std_logic
        );
    end component;

    signal OP          : std_logic_vector(2 downto 0);
    signal A, B, S      : std_logic_vector(31 downto 0);
    signal N, Z, C, V   : std_logic;

    procedure check(signal got : in std_logic_vector; expected : std_logic_vector; msg : string) is
    begin
        assert got = expected
            report "ECHEC: " & msg & " -- attendu " & to_hstring(unsigned(expected)) &
                   " obtenu " & to_hstring(unsigned(got))
            severity error;
    end procedure;

    procedure check_bit(signal got : in std_logic; expected : std_logic; msg : string) is
    begin
        assert got = expected
            report "ECHEC: " & msg & " -- attendu " & std_logic'image(expected) &
                   " obtenu " & std_logic'image(got)
            severity error;
    end procedure;

begin

    dut : alu
        port map (OP => OP, A => A, B => B, S => S, N => N, Z => Z, C => C, V => V);

    stim : process
    begin
        -- ADD : 5 + 3 = 8
        A <= x"00000005"; B <= x"00000003"; OP <= "000"; wait for 10 ns;
        check(S, x"00000008", "ADD 5+3");
        check_bit(Z, '0', "ADD 5+3 Z");
        check_bit(N, '0', "ADD 5+3 N");

        -- ADD : overflow (MAX_INT + 1)
        A <= x"7FFFFFFF"; B <= x"00000001"; OP <= "000"; wait for 10 ns;
        check(S, x"80000000", "ADD overflow value");
        check_bit(V, '1', "ADD overflow V");
        check_bit(N, '1', "ADD overflow N");

        -- B : passe B
        A <= x"11111111"; B <= x"22222222"; OP <= "001"; wait for 10 ns;
        check(S, x"22222222", "OP=B");

        -- SUB : 10 - 3 = 7
        A <= x"0000000A"; B <= x"00000003"; OP <= "010"; wait for 10 ns;
        check(S, x"00000007", "SUB 10-3");

        -- SUB : resultat nul -> Z=1
        A <= x"00000005"; B <= x"00000005"; OP <= "010"; wait for 10 ns;
        check(S, x"00000000", "SUB egal");
        check_bit(Z, '1', "SUB egal Z");

        -- SUB : resultat negatif -> N=1
        A <= x"00000003"; B <= x"00000005"; OP <= "010"; wait for 10 ns;
        check_bit(N, '1', "SUB negatif N");

        -- A : passe A
        A <= x"AAAAAAAA"; B <= x"55555555"; OP <= "011"; wait for 10 ns;
        check(S, x"AAAAAAAA", "OP=A");

        -- OR
        A <= x"F0F0F0F0"; B <= x"0F0F0F0F"; OP <= "100"; wait for 10 ns;
        check(S, x"FFFFFFFF", "OR");

        -- AND
        A <= x"FF00FF00"; B <= x"0F0F0F0F"; OP <= "101"; wait for 10 ns;
        check(S, x"0F000F00", "AND");

        -- XOR
        A <= x"FFFFFFFF"; B <= x"0F0F0F0F"; OP <= "110"; wait for 10 ns;
        check(S, x"F0F0F0F0", "XOR");

        -- NOT
        A <= x"0F0F0F0F"; B <= (others => '0'); OP <= "111"; wait for 10 ns;
        check(S, x"F0F0F0F0", "NOT");

        report "tb_alu : simulation terminee";
        wait;
    end process;

end architecture sim;
