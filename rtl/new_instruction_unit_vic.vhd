library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity new_instruction_unit_vic is
  port (
    clk : in std_logic;
    reset : in std_logic;
    nPCsel: in std_logic;
    offset : in std_logic_vector(23 downto 0);
    irq_0    : in  std_logic;
    irq_1    : in  std_logic;
    IRQ_END : in std_logic;
    Instruction : out std_logic_vector(31 downto 0);
    PC : out std_logic_vector(31 downto 0)
  ) ;
end new_instruction_unit_vic;



architecture rtl of new_instruction_unit_vic is
    signal IRQ: std_logic;
    signal VICPC : std_logic_vector(31 downto 0);
    signal IRQ_SERV: std_logic;

    
begin
    inst_vic: entity work.vic port map(clk, reset, IRQ_SERV,irq_0, irq_1, IRQ, VICPC);
    inst_instruction_unit_vic: entity work.instruction_unit_vic port map(clk, reset , nPCsel, offset,IRQ, VICPC,IRQ_END, instruction, IRQ_SERV, PC);

    
end architecture rtl;

