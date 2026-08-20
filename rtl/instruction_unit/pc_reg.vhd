library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;




entity pc_reg is
  port (
    clk, reset : in std_logic;
    PC_in : in std_logic_vector(31 downto 0);
    PC_out : out std_logic_vector(31 downto 0)
  ) ;
end pc_reg;


architecture comport of pc_reg is
    
begin
    P1 : process( clk,reset)
    begin
        if reset ='1' then
            PC_out<=(others =>'0');
        elsif rising_edge(clk) then
        PC_out <= PC_in;
        end if;
        
    end process ; 
    
    
    
end architecture comport;