
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_tx_top is
  port (
    clk : in std_logic;
    reset : in std_logic;
    GO : in std_logic;
    UART_Conf : in  std_logic_vector(31 downto 0);
    Tx : out std_logic
  );
end uart_tx_top;

architecture rtl of uart_tx_top is
    signal tick_bit : std_logic;
    signal go_prec : std_logic;
    signal pulse : std_logic;
begin

    inst_fdiv: entity work.generateur_tick port map(clk, reset, tick_bit, open);
    
    -- On associe directement 'pulse' à l'émetteur
    inst_uart_tx : entity work.uart_tx port map(clk, reset, pulse, Data, tick_bit, Tx); 

    P1 : process(clk, reset)
    begin
        if reset = '1' then
            go_prec <= '1'; -- État de repos d'un bouton actif-bas
            pulse   <= '0';
        elsif rising_edge(clk) then
            go_prec <= GO;
            
            -- Détection du front descendant (appui sur le bouton actif-bas KEY[0])
            if GO = '0' and go_prec = '1' then
                pulse <= '1';
            else
                pulse <= '0';
            end if;
        end if;
    end process; -- P1
    
end architecture rtl;