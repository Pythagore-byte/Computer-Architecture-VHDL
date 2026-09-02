library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity processor_core_vic is
  port (
    clk: in std_logic;
    reset : in std_logic;
    irq_0: in std_logic;
    irq_1: in std_logic;
    HEX0,HEX1,HEX2,HEX3: out std_logic_vector(6 downto 0);
    PC : out std_logic_vector(31 downto 0)
  ) ;
end processor_core_vic;

architecture structural of processor_core_vic is
    signal instruction : std_logic_vector(31 downto 0);
    signal imm24 : std_logic_vector(23 downto 0);
    signal imm8 : std_logic_vector(7 downto 0);
    signal nzcv: std_logic_vector(31 downto 0);
    signal N,Z,C,V: std_logic;
    signal AluCtr : std_logic_vector(2 downto 0);
    signal RegAff, WrSrc, MemWr, RegSel, ALUSrc, nPCSel, RegWr: std_logic;
    signal Rd , Rn , Rm : std_logic_vector(3 downto 0);
    signal afficheur: std_logic_vector(31 downto 0);
    signal bus_B_out: std_logic_vector(31 downto 0);
    signal  IRQ_END : std_logic;
    signal R2_dbg : std_logic_vector(31 downto 0);
   
    
begin
    imm24 <= instruction(23 downto 0);
    imm8 <= instruction(7 downto 0);
    Rd <= instruction(15 downto 12);
    Rn <= instruction(19 downto 16);
    Rm <= instruction(11 downto 8);
    nzcv <= N&Z&C&V&X"0000000";

    new_instruction_unit_vic: entity work.new_instruction_unit_vic port map(
        clk, reset, nPCSel,imm24,irq_0, irq_1, IRQ_END , instruction, PC
        );

    control_unit_vic: entity work.control_unit_vic port map(
        clk, reset, instruction, nzcv, AluCtr, RegAff,WrSrc,MemWr,RegSel,ALUSrc,nPCSel, RegWr, IRQ_END
    );

    data_path_complet: entity work.datapath_complet port map(
        clk, reset , ALUSrc, WrSrc, MemWr, imm8, ALUCtr, Rd, Rn, Rm, RegWr, RegSel ,bus_B_out,R2_dbg, N, Z, C,V
    );
    -- reg_Aff: entity work.reg_Aff port map(clk, reset, RegAff, bus_B_out, afficheur);


        decod_7_seg1: entity work.decodeur_7_segment port map(R2_dbg(3 downto 0), HEX0);
        decod_7_seg2: entity work.decodeur_7_segment port map(R2_dbg(7 downto 4),HEX1);
        decod_7_seg3: entity work.decodeur_7_segment port map(R2_dbg(11 downto 8), HEX2);
        decod_7_seg4: entity work.decodeur_7_segment port map(R2_dbg(15 downto 12),HEX3);
    -- decod_7_seg1: entity work.decodeur_7_segment port map(afficheur(3 downto 0), HEX0);
    -- decod_7_seg2: entity work.decodeur_7_segment port map(afficheur(7 downto 4),HEX1);
    -- decod_7_seg3: entity work.decodeur_7_segment port map(afficheur(11 downto 8), HEX2);
    -- decod_7_seg4: entity work.decodeur_7_segment port map(afficheur(15 downto 12),HEX3);
    -- decod_7_seg5: entity work.decodeur_7_segment port map(afficheur(19 downto 16),HEX4);
    -- decod_7_seg6: entity work.decodeur_7_segment port map(afficheur(23 downto 20),HEX5);

end architecture structural;







