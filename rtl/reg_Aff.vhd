library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;





entity reg_Aff is
  port (
    clk: in std_logic;
    reset : in std_logic;
    WE : in std_logic;
    DATAIN : in std_logic_vector(31 downto 0);
    DATAOUT : out std_logic_vector(31 downto 0)
  ) ;
end reg_Aff;



architecture comport of reg_Aff is
    
begin
    P1 : process(clk, reset)
    begin
        if reset='1' then
            DATAOUT <=(others=>'0');
        elsif rising_edge(clk) then
            if WE='1' then
                DATAOUT <= DATAIN;
            end if;
            
        end if;
        
    end process ; -- P1
    
    
    
end architecture comport;