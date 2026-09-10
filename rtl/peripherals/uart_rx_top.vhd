library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_rx_top is
  port (
    clk    : in std_logic;
    reset  : in std_logic;
    rx     : in std_logic;
    Data   : out std_logic_vector(7 downto 0);
    Erreur : out std_logic;
    DAV    : out std_logic
  );
end entity uart_rx_top;

architecture rtl of uart_rx_top is
    signal tick_demi_bit : std_logic;
    signal clear_fdiv    : std_logic;
    signal fdiv_reset    : std_logic;
begin

    -- Porte OU logique représentée sur le schéma pour le reset du FDIV
    fdiv_reset <= reset or clear_fdiv;

    -- Instanciation du générateur de ticks (FDIV)
    inst_fdiv: entity work.generateur_tick
      port map (
        clk_50   => clk,
        reset    => fdiv_reset,
        tick_tx  => open, -- Non utilisé pour la partie réception seule
        tick_rx  => tick_demi_bit
      );

    -- Instanciation du module UART RX
    inst_uart_rx: entity work.uart_rx
      port map (
        clk           => clk,
        reset         => reset,
        tick_demi_bit => tick_demi_bit,
        rx            => rx,
        Data          => Data,
        Erreur        => Erreur,
        DAV           => DAV,
        clear_fdiv    => clear_fdiv
      );

end architecture rtl;
