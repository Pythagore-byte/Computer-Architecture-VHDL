--------------------------------------------------------------------------------
-- Unite Arithmetique et Logique (UAL / ALU) - 32 bits
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
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
end entity alu;

architecture rtl of alu is

    constant OP_ADD : std_logic_vector(2 downto 0) := "000";
    constant OP_B   : std_logic_vector(2 downto 0) := "001";
    constant OP_SUB : std_logic_vector(2 downto 0) := "010";
    constant OP_A   : std_logic_vector(2 downto 0) := "011";
    constant OP_OR  : std_logic_vector(2 downto 0) := "100";
    constant OP_AND : std_logic_vector(2 downto 0) := "101";
    constant OP_XOR : std_logic_vector(2 downto 0) := "110";
    constant OP_NOT : std_logic_vector(2 downto 0) := "111";

    signal Y      : signed(32 downto 0) := (others => '0');
    signal result : signed(31 downto 0) := (others => '0');

begin

    P1 : process(A, B, OP)
        variable temp : signed(32 downto 0);
    begin

        -- Valeur par défaut
        temp := (others => '0');

        case OP is

            when OP_ADD =>
                temp := signed('0' & A) + signed('0' & B);

            when OP_SUB =>
                temp := signed('0' & A) - signed('0' & B);

            when OP_A =>
                temp := signed('0' & A);

            when OP_B =>
                temp := signed('0' & B);

            when OP_OR =>
                temp := signed('0' & (A or B));

            when OP_AND =>
                temp := signed('0' & (A and B));

            when OP_XOR =>
                temp := signed('0' & (A xor B));

            when OP_NOT =>
                temp := signed('0' & (not A));

            when others =>
                temp := (others => '0');

        end case;

        Y      <= temp;
        result <= temp(31 downto 0);

    end process P1;

    S <= std_logic_vector(result);

    Z <= '1' when result = 0 else '0';

    N <= result(31);

    -- Carry
    C <= Y(32);

    -- Overflow
    V <= '1' when
            (OP = OP_ADD and A(31) = B(31) and result(31) /= A(31))
            or
            (OP = OP_SUB and A(31) /= B(31) and result(31) /= A(31))
         else '0';

end architecture rtl;