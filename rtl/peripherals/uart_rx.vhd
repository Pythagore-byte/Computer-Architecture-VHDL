library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_rx is
  port (
    clk : in std_logic;
    reset : in std_logic;
    tick_demi_bit : in std_logic;
    rx : in std_logic;
    Data : out std_logic_vector(7 downto 0);
    Erreur : out std_logic;
    DAV : out std_logic;
    clear_fdiv: out std_logic
  ) ;
end uart_rx;

architecture rtl of uart_rx is
    signal reg : std_logic_vector(7 downto 0);
    signal cnt_bit : integer range 0 to 7;
    signal cnt_tick : integer range 0 to 15;  -- Pour compter les 16 ticks par bit
    type STATE is (IDLE , START , DATA_STATE, STOP);
    signal etat_present : STATE;
begin

    P1 : process(clk, reset)
    begin
        if reset = '1' then
            cnt_bit <= 0;
            cnt_tick <= 0;
            reg <= (others => '0');
            clear_fdiv <= '0';
            Erreur <= '0';
            DAV <= '0';
            etat_present <= IDLE;
        elsif rising_edge(clk) then
            clear_fdiv <= '0';
            DAV <= '0';
            Erreur <= '0';
            
            case( etat_present ) is
                when IDLE =>
                    if rx = '0' then
                        clear_fdiv <= '1';
                        cnt_tick <= 0;
                        cnt_bit <= 0;
                        etat_present <= START; 
                    end if;

                when START =>
                    if tick_demi_bit = '1' then
                        if cnt_tick = 7 then
                            cnt_tick <= 0;
                            if rx = '1' then
                                etat_present <= IDLE;
                            else
                                etat_present <= DATA_STATE;  
                            end if;
                        else
                            cnt_tick <= cnt_tick + 1;   
                        end if;
                    end if;
                
                when DATA_STATE =>
                    if tick_demi_bit = '1' then
                        -- On échantillonne pile au milieu du bit
                        if cnt_tick = 7 then
                            reg <= rx & reg(7 downto 1);
                        end if;
                        
                        -- Gestion du compteur de ticks et de bits
                        if cnt_tick = 15 then
                            cnt_tick <= 0;
                            
                            -- On vérifie avant d'incrémenter pour ne pas dépasser 7
                            if cnt_bit = 7 then
                                cnt_bit <= 0;          -- Remise à zéro pour la prochaine trame
                                etat_present <= STOP;  
                            else
                                cnt_bit <= cnt_bit + 1; 
                            end if;
                        else
                            cnt_tick <= cnt_tick + 1; 
                        end if; 
                    end if;
                    

                when STOP =>
                    if tick_demi_bit = '1' then
                        if cnt_tick = 15 then
                            cnt_tick <= 0;
                            if rx = '1' then
                                Data <= reg;
                                DAV <= '1';
                                etat_present <= IDLE;  
                            else
                                Erreur <= '1';
                                etat_present <= IDLE;  
                            end if;
                        else
                            cnt_tick <= cnt_tick + 1;
                        end if;
                    end if;
            end case;
        end if;
        
    end process;

end architecture rtl;