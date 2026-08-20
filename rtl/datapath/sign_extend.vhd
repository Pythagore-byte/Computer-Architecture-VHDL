library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity sign_extend is
    generic(N:integer:=32);
  port (
    E: IN std_logic_vector(N-1 downto 0);
    S : OUT std_logic_vector(31 downto 0)
  ) ;
end sign_extend;



architecture comport of sign_extend is
    signal tmp : std_logic_vector(32-N-1 downto 0);
begin
    S<=tmp & E;
    p : process( E , tmp)
    begin
        if E(N-1) = '1' then
            tmp <=(others=>'1');
        else
            tmp <=(others=>'0');   
        end if;    
    end process ; -- p
    
end architecture comport;