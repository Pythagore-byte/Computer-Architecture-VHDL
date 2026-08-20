library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;





entity datapath is
  port (
    clk , reset : in std_logic;

    COM1        : in std_logic;
    COM2        : in std_logic;
    WrEn        : in std_logic;
    Imm         : std_logic_vector(7 downto 0);
    OP          : in std_logic_vector(2 downto 0);
    RW          : in std_logic_vector(3 downto 0);
    RA          : in std_logic_vector(3 downto 0);
    RB          : in std_logic_vector(3 downto 0);
    RegWr       : in std_logic;
    
    
    N,Z,C,V     : out std_logic
    
  );
end datapath;


architecture structural of datapath  is
    signal busA , busB , busW  : std_logic_vector(31 downto 0);
    signal out_imm : std_logic_vector(31 downto 0);
    signal data_out_memory: std_logic_vector(31 downto 0);
    signal AlUout : std_logic_vector(31 downto 0);
    signal mux1_out : std_logic_vector(31 downto 0);
    
    
begin
    
    banc_registre : entity work.register_file port map(clk, reset, RegWr, RA, RB, RW,busW, busA, busB);
    sign_ext: entity work.sign_extend generic map(8) port map (Imm, out_imm);
    mux1: entity work.mux2to1 port map(busB,out_imm, COM1,mux1_out );
    alu : entity work.alu port map(OP,busA, mux1_out,AlUout, N,Z,C,V);
    data_memory: entity work.data_memory port map(clk, reset, WrEn,AlUout(5 downto 0), busB, data_out_memory);
    mux2: entity work.mux2to1 port map(AlUout, data_out_memory,COM2, busW);

    
end architecture;
