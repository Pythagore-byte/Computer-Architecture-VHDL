library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity data_memory is
  port (
    clk, reset : in std_logic;
    Wen  : in std_logic;
    Addr : in std_logic_vector(5 downto 0);
    DataIn : in std_logic_vector(31 downto 0);
    DataOut : out std_logic_vector(31 downto 0)
  ) ;
end data_memory;




architecture rtl of data_memory is

  type table is  array (63 downto 0) of std_logic_vector(31 downto 0);

    function init_memory return table is
        variable result : table;
    begin
        for i in 0 to 63 loop
            result(i) :=std_logic_vector(to_unsigned(i, 32));
        end loop;
        return result;
    end init_memory;  
    signal memory: table := init_memory;

    
begin

    P1 : process( clk, reset )
    begin
        if reset ='1' then
            memory<=init_memory;
        elsif  rising_edge(clk) then
            if Wen ='1' then
                memory(to_integer(unsigned(addr))) <=DataIn;
            end if;
            
        end if;

    end process ; -- P1
    DataOut <= memory(to_integer(unsigned(addr)));

    
end architecture rtl;