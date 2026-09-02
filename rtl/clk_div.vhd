library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

---------------------------------------------------------------------------
-- Diviseur d'horloge a seuil variable.
--
-- Un SEUL compteur, une SEULE horloge generee : on ne commute jamais
-- entre deux horloges, on change seulement la valeur de comparaison.
-- Pas de risque d'impulsion tronquee au basculement.
--
-- rapide = '0' -> 2 Hz   (50 MHz / (2 x 12_500_000))
-- rapide = '1' -> 10 Hz  (50 MHz / (2 x  2_500_000))
--
-- Le facteur 2 vient du basculement : deux inversions font une periode.
---------------------------------------------------------------------------
entity clk_div is
  port (
    clk_50MHZ : in  std_logic;
    reset     : in  std_logic;
    rapide    : in  std_logic;
    clk_out   : out std_logic
  );
end clk_div;

architecture rtl of clk_div is
    signal compteur : integer range 0 to 12_500_000;
    signal seuil    : integer range 0 to 12_500_000;
    signal clk_i    : std_logic;
begin

    clk_out <= clk_i;

    seuil <= 2_500_000 when rapide = '1' else 12_500_000;
    -- 2500000 => f = 10Hz , - 12_500_000 => f = 2Hz , 

    P1 : process(clk_50MHZ, reset)
    begin
        if reset = '1' then
            clk_i    <= '0';
            compteur <= 0;

        elsif rising_edge(clk_50MHZ) then

            -- ">=" et non "=" : si on passe de 2 Hz a 10 Hz alors que le
            -- compteur a deja depasse 2_500_000, l'egalite stricte le
            -- ferait tourner jusqu'a deborder.
            if compteur >= seuil then
                clk_i    <= not clk_i;
                compteur <= 0;
            else
                compteur <= compteur + 1;
            end if;

        end if;
    end process;

end architecture rtl;