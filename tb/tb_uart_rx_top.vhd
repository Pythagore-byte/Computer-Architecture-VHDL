library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_uart_rx_top is
end tb_uart_rx_top;

architecture test of tb_uart_rx_top is
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal rx : std_logic := '1';
    signal Data : std_logic_vector(7 downto 0);
    signal Erreur : std_logic;
    signal DAV : std_logic;
    signal done : boolean := false;
    
    -- Durée d'un bit à 9600 bauds (5208 cycles d'horloge à 50 MHz * 10 ns)
    constant BIT_TIME : time := 52080 ns; 
begin

    reset <= '1', '0' after 20 ns;
    clk <= '0' when done else not(clk) after 5 ns; -- Horloge 50 MHz

    inst_top : entity work.uart_rx_top 
        port map(
            clk    => clk, 
            reset  => reset, 
            rx     => rx, 
            Data   => Data, 
            Erreur => Erreur, 
            DAV    => DAV
        );

    P1 : process
        variable data_to_send : std_logic_vector(7 downto 0) := x"A5"; -- Exemple : 10100101
    begin
        rx <= '1';
        wait for 100 ns;
        
        -- 1. Bit de Start ('0')
        rx <= '0';
        wait for BIT_TIME;
        
        -- 2. Transmission des 8 bits de données (du LSB au MSB)
        for i in 0 to 7 loop
            rx <= data_to_send(i);
            wait for BIT_TIME;
        end loop;
        
        -- 3. Bit de Stop ('1')
        rx <= '1';
        wait for BIT_TIME;
        
        -- Fin de la trame, on laisse le temps d'observer les sorties
        wait for 20 us;
        done <= true;
        wait;
    end process;

end architecture test;