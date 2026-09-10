library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generateur_tick is
  port (
    clk_50 : in std_logic;
    reset : in std_logic;
    tick_tx : out std_logic;
    tick_rx : out std_logic
  ) ;
end generateur_tick;

architecture rtl of generateur_tick is
    constant BAUDE_RATE : integer := 9600;
    constant FREQUENCE : integer := 50000000;
    constant FACTEUR_SUR_ECHANTIONNAGE : integer := 16;
    constant NCycle_tx : integer := (FREQUENCE/BAUDE_RATE);
    constant NCycle_rx : integer := (FREQUENCE/(BAUDE_RATE*FACTEUR_SUR_ECHANTIONNAGE));

    signal compteur_1 : integer range 0 to NCycle_tx-1;
    signal compteur_2 : integer range 0 to NCycle_rx-1;
    
begin

    P1 : process(clk_50, reset)
    begin
        if reset = '1' then
            compteur_1 <= 0;
            compteur_2 <= 0;
            tick_tx <= '0';
            tick_rx <= '0';
        elsif rising_edge(clk_50) then
            -- Valeurs par défaut pour garantir un signal d'une seule période d'horloge
            tick_tx <= '0';
            tick_rx <= '0';
            
            if compteur_1 = NCycle_tx - 1 then
                compteur_1 <= 0;
                tick_tx <= '1';
            else
                compteur_1 <= compteur_1 + 1;
            end if;
            
            if compteur_2 = NCycle_rx - 1 then
                compteur_2 <= 0;
                tick_rx <= '1';
            else
                compteur_2 <= compteur_2 + 1;
            end if;
            
        end if;
    end process;

end architecture rtl;