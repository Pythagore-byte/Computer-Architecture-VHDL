library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity instruction_unit is
  port (
    clk, reset  : in std_logic;
    nPCsel : in std_logic;
    offset : in std_logic_vector(23 downto 0);
    Instruction : out std_logic_vector(31 downto 0)
  ) ;
end instruction_unit;


architecture structural of instruction_unit is
    

    signal pc_in,  pc_out, out_sign_extend: std_logic_vector(31 downto 0);
    signal muxA, muxB: std_logic_vector(31 downto 0);
    
begin
    muxA <= std_logic_vector(signed(pc_out) + 1);
    muxB <= std_logic_vector(signed(pc_out) + signed(out_sign_extend) + 1);
    instruction_memory : entity work.instruction_memory port map(pc_out, Instruction);

    pc_reg : entity work.pc_reg port map(clk, reset, pc_in, pc_out);

    sign_extend: entity work.sign_extend generic map(24) port map(offset, out_sign_extend);
    mux2_2: entity work.mux2to1 generic map(32) port map(muxA,muxB,nPCsel, pc_in);

end architecture structural;
