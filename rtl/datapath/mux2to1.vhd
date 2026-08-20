library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity mux2to1 is
    generic (N :integer :=32);
  port (
    A,B: in std_logic_vector(N-1 downto 0);
    COM : in std_logic;
    S  : out std_logic_vector(N-1 downto 0)
  ) ;
end mux2to1;

architecture comport of mux2to1 is
    
begin
    S<= A when COM='0' ELSE B;
end architecture comport;