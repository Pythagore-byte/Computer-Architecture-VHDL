library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity datapath_complet is
  port (
    clk , reset : in std_logic;

    ALUSrc        : in std_logic;
    WrSrc        : in std_logic;
    MemWr        : in std_logic;
    Imm         : std_logic_vector(7 downto 0);
    ALUCtr          : in std_logic_vector(2 downto 0);
    Rd          : in std_logic_vector(3 downto 0);
    Rn          : in std_logic_vector(3 downto 0);
    Rm          : in std_logic_vector(3 downto 0);
    RegWr       : in std_logic;
    RegSel: in std_logic;
    bus_B_out: out std_logic_vector(31 downto 0);
    
    
    N,Z,C,V     : out std_logic
    
  );
end datapath_complet;


architecture structural of datapath_complet  is
    signal busA , busB , busW  : std_logic_vector(31 downto 0);
    signal out_imm : std_logic_vector(31 downto 0);
    signal data_out_memory: std_logic_vector(31 downto 0);
    signal AlUout : std_logic_vector(31 downto 0);
    signal mux1_out : std_logic_vector(31 downto 0);
    signal Rb: std_logic_vector(3 downto 0);
    
    
begin
    bus_B_out <= busB;
    mux: entity work.mux2to1 generic map(4) port map(Rm, Rd, RegSel, Rb);
    banc_registre : entity work.register_file port map(clk, reset, RegWr, Rn, Rb, Rd,busW, busA, busB);
    sign_ext: entity work.sign_extend generic map(8) port map (Imm, out_imm);
    mux1: entity work.mux2to1 port map(busB,out_imm, ALUSrc,mux1_out );
    alu : entity work.alu port map(ALUCtr,busA, mux1_out,AlUout, N,Z,C,V);
    data_memory: entity work.data_memory port map(clk, reset, MemWr,AlUout(5 downto 0), busB, data_out_memory);
    mux2: entity work.mux2to1 port map(AlUout, data_out_memory,WrSrc, busW);
  
end architecture;
