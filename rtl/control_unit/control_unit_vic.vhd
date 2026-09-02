library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_unit_vic is
  port (
    clk : in std_logic;
    reset: in std_logic;
    instruction : in std_logic_vector(31 downto 0);
    flags : in std_logic_vector(31 downto 0);
    AluCtr: out std_logic_vector(2 downto 0);
    RegAff: out std_logic;
    WrSrc: out std_logic;
    MemWr: out std_logic;
    RegSel: out std_logic;
    ALUSrc: out std_logic;
    nPCSel: out std_logic;
    RegWr: out std_logic;
    IRQ_END : out std_logic
    
  ) ;
end control_unit_vic;

architecture structural of control_unit_vic is
    signal psr : std_logic_vector(31 downto 0);
    signal commande_chargement: std_logic;


    
begin

    psr_reg : entity work.psr_reg port map(clk, reset,commande_chargement,flags, psr );
    decoder_vic: entity work.decoder_vic port map(Instruction,psr,commande_chargement, AluCtr, RegAff,WrSrc,MemWr, RegSel,ALUSrc, nPCSel,RegWr, IRQ_END);
    
end architecture structural;

