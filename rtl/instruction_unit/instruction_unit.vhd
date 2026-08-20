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
    

    signal next_pc,  pc_out, out_sign_extend: std_logic_vector(31 downto 0);
    
begin
    instruction_memory : entity work.instruction_memory port map(pc_out, Instruction);

    pc_reg : entity work.pc_reg port map(clk, reset, next_pc, pc_out);

    sign_extend: entity work.sign_extend generic map(24) port map(offset, out_sign_extend);

    P1 : process(clk, reset)
    begin
        if reset='1' then
            next_pc <=(others=>'0');
        elsif rising_edge(clk) then
            if nPCsel = '0' then
                next_pc <= std_logic_vector(unsigned(pc_out) + '1');
            else
                next_pc <= std_logic_vector(unsigned(pc_out) + '1' + unsigned(out_sign_extend));
                
            end if;
            
        end if;
        
    end process ; -- P1



    
    
    
end architecture structural;
