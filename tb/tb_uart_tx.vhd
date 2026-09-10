library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_uart_tx is
end tb_uart_tx;

architecture test of tb_uart_tx is

    constant T   : time    := 10 ns;
    -- Diviseur volontairement petit : un temps bit = 10 cycles.
    -- Avec 5208 (le vrai 9600 bauds), un octet durerait 52 000 cycles
    -- et le chronogramme serait illisible.
    constant DIV : integer := 10;

    signal clk      : std_logic := '0';
    signal reset    : std_logic;
    signal done     : boolean   := false;
    signal tick_bit : std_logic;
    signal Go       : std_logic := '0';
    signal Data     : std_logic_vector(7 downto 0) := x"41";  -- 'A'
    signal Tx       : std_logic;

begin

    clk   <= '0' when done else not clk after T/2;
    reset <= '1', '0' after 12 ns;

    inst_fdiv : entity work.fdiv
        generic map (DIVISEUR => DIV)
        port map (clk => clk, reset => reset, tick_bit => tick_bit);

    inst_uart : entity work.uart_tx
        port map (clk      => clk,
                  reset    => reset,
                  Go       => Go,
                  Data     => Data,
                  Tick_bit => tick_bit,
                  Tx       => Tx);

    P1 : process

        -- Attend le prochain tick, puis se place au milieu du temps bit
        -- pour echantillonner Tx la ou il est stable.
        procedure lire_bit(constant attendu : std_logic;
                           constant nom     : string) is
        begin
            wait until rising_edge(clk) and tick_bit = '1';
            wait for T * (DIV / 2);
            assert Tx = attendu
                report nom & " : Tx vaut '" & std_logic'image(Tx)
                     & "' au lieu de '" & std_logic'image(attendu) & "'"
                severity error;
        end procedure;

    begin

        wait until reset = '0';

        assert Tx = '1'
            report "Repos : la ligne UART doit etre a '1'" severity error;

        -- Demande d'emission
        wait until falling_edge(clk);
        Go <= '1';
        wait until falling_edge(clk);
        Go <= '0';

        report "Emission de 0x41 ('A') : start, 8 bits poids faible d'abord, stop"
            severity note;

        -- 0x41 = 0100 0001 -> emis dans l'ordre : 1 0 0 0 0 0 1 0
        lire_bit('0', "start");
        lire_bit('1', "bit 0");
        lire_bit('0', "bit 1");
        lire_bit('0', "bit 2");
        lire_bit('0', "bit 3");
        lire_bit('0', "bit 4");
        lire_bit('0', "bit 5");
        lire_bit('1', "bit 6");
        lire_bit('0', "bit 7");
        lire_bit('1', "stop");

        wait for T * DIV * 3;

        assert Tx = '1'
            report "Apres emission : la ligne doit revenir au repos '1'"
            severity error;

        report "Fin de simulation : uart_tx OK" severity note;
        done <= true;
        wait;

    end process;

end architecture test;