library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_tx_reg is
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    Go        : in  std_logic;
    UART_Conf : in  std_logic_vector(31 downto 0);
    Tick_bit  : in  std_logic;
    Tx        : out std_logic
  ) ;
end uart_tx_reg;

architecture rtl of uart_tx_reg is
    type ETAT is (E1, E2, E3, E4);
    signal etat_suivant : ETAT;
    signal etat_present : ETAT;
    signal cnt_bit      : integer range 0 to 15;
    signal reg          : std_logic_vector(9 downto 0);
begin

    ---------------------------------------------------------------------
    -- P1 : partie sequentielle (etat + registres)
    ---------------------------------------------------------------------
    P1 : process(clk, reset)
    begin
        if reset = '1' then
            etat_present <= E1;
            Tx           <= '1';
            cnt_bit      <= 0;
            reg          <= (others => '0');

        elsif rising_edge(clk) then
            etat_present <= etat_suivant;

            case etat_present is

                when E1 =>
                    Tx      <= '1';              -- ligne au repos
                    cnt_bit <= 0;

                when E2 =>
                    reg     <= '1' & UART_Conf(7 downto 0) & '0'; -- stop + donnee + start
                    cnt_bit <= 0;

                when E3 =>
                    Tx <= reg(cnt_bit);

                when E4 =>
                    if Tick_bit = '1' then
                        if cnt_bit = 9 then
                            cnt_bit <= 0;
                        else
                            cnt_bit <= cnt_bit + 1;
                        end if;
                    end if;   

            end case;
        end if;
    end process;

    ---------------------------------------------------------------------
    -- P2 : partie combinatoire (transitions uniquement)
    ---------------------------------------------------------------------
    P2 : process(etat_present, Go, Tick_bit, cnt_bit)
    begin
        etat_suivant <= etat_present;

        case etat_present is

            when E1 =>
                if Go = '1' then
                    etat_suivant <= E2;
                end if;

            when E2 =>
                if Tick_bit = '1' then
                    etat_suivant <= E3;
                end if;

            when E3 =>
                etat_suivant <= E4;

            when E4 =>
                -- On sort sur le TICK, jamais avant : chaque bit occupe
                -- ainsi un temps bit complet, stop compris.
                --
                -- Le test porte sur cnt_bit = 9 et non 10 : cnt_bit est un
                -- signal, il ne prendra 10 qu'APRES ce front. Attendre 10
                -- ferait repasser une fois de trop par E3, ou reg(10)
                -- serait lu hors bornes.
                if Tick_bit = '1' then
                    if cnt_bit = 9 then
                        etat_suivant <= E1;      -- le stop vient d'etre emis
                    else
                        etat_suivant <= E3;      -- bit suivant
                    end if;
                end if;

        end case;
    end process;

end architecture rtl;