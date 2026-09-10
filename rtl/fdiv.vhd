library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fdiv is
  generic (DIVISEUR : integer := 5208);   -- 50 MHz / 9600 bauds
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    tick_bit : out std_logic
  );
end fdiv;



architecture rtl of fdiv is
    signal compteur : integer range 0 to DIVISEUR-1;
    signal tick : std_logic;
    
begin
    tick_bit <= tick;
   P1 : process( clk, reset)

   begin
        
        if reset ='1' then
            compteur <= 0;
            tick <= '0';
        elsif rising_edge(clk) then
            if compteur = DIVISEUR -1 then
                tick <= '1';
                compteur <= 0;
            else
                tick <= '0';
                compteur <= compteur + 1;
            end if;   
            
        end if;
    
   end process ; -- P1
    
    
end architecture rtl;