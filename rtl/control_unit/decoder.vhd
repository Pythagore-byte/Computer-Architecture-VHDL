library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity decoder is
  port (
    Instruction : in std_logic_vector(31 downto 0);
    PSR :in std_logic_vector(31 downto 0);
    PSREn : out std_logic;
    AluCtr: out std_logic_vector(2 downto 0);
    RegAff: out std_logic;
    WrSrc: out std_logic;
    MemWr: out std_logic;
    RegSel: out std_logic;
    ALUSrc: out std_logic;
    nPCSel: out std_logic;
    RegWr: out std_logic

  ) ;
end decoder;


architecture rtl of decoder is
    type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT,UNDEF);
    signal inst_courante: enum_instruction;

    constant OPCODE_MOV : std_logic_vector(3 downto 0) := "1101";
    constant OPCODE_ADD : std_logic_vector(3 downto 0) := "0100";
    constant OPCODE_CMP : std_logic_vector(3 downto 0) := "1010";
    
begin
    P1 : process(Instruction)
        variable type_bits : std_logic_vector(1 downto 0);
        variable cond       : std_logic_vector(3 downto 0);
        variable opcode     : std_logic_vector(3 downto 0);
        variable i_bit      : std_logic;
        variable l_bit      : std_logic;
    begin

        type_bits := Instruction(27 downto 26);
        cond      := Instruction(31 downto 28);
        opcode    := Instruction(24 downto 21);
        i_bit     := Instruction(25);
        l_bit     := Instruction(20);

        if type_bits="00" then
            case( opcode ) is
                when OPCODE_MOV =>
                    inst_courante<=MOV;
                when OPCODE_CMP =>
                    inst_courante<=CMP;
                when OPCODE_ADD =>
                    if i_bit='1' then
                        inst_courante<=ADDi;
                    else
                        inst_courante<=ADDr;  
                    end if ;
                when others =>
                    inst_courante <= UNDEF;     
            end case ;

        elsif type_bits="01" then
            if l_bit='1' then
                inst_courante<=LDR; 
            else
                inst_courante<=STR; 
            end if ;
        elsif type_bits="10" then
            if cond ="1110" then
                inst_courante<=BAL; 
            elsif cond ="1011" then
                inst_courante<=BLT; 
            else
                inst_courante <= UNDEF;  
                
            end if ;
        else
            inst_courante <= UNDEF;  
        end if ;

    end process ;
    P2 : process( Instruction, inst_courante , PSR)
    begin

        nPCsel  <= '0';
        RegWr   <= '0';
        ALUSrc  <= '0';
        AluCtr <= "000";
        PSREn   <= '0';
        MemWr   <= '0';
        WrSrc   <= '0';
        RegSel  <= '0';
        RegAff  <= '0';

        case( inst_courante ) is
        
            when MOV =>
                RegWr <='1';
                ALUSrc<=Instruction(25);
                ALUCtr <="001";
            when ADDi =>
                RegWr <='1';
                ALUSrc<='1';
    
            when ADDr =>
                RegWr <='1';
                ALUSrc<='0';
                ALUCtr <="000";

             when CMP =>
                ALUSrc<=Instruction(25);
                ALUCtr <="010";
                PSREn<='1';
                
                when LDR =>
                RegWr <='1';
                ALUSrc<='1';
                ALUCtr <="000";
                WrSrc<='1';
            
                when STR =>
                ALUSrc  <= '1';
                ALUCtr  <= "000";
                MemWr   <= '1';
                WrSrc   <= '1';
                RegSel  <= '1'; -- Indispensable pour basculer le mux sur Rd et envoyer R2 vers la mémoire
                RegAff  <= '1';

                when BAL =>
                nPCsel <='1';
            
                
                when BLT =>
                nPCsel <=PSR(31);

                when UNDEF =>
                RegWr <='0';
                ALUSrc<='0';
                ALUCtr <="000";
                PSREn<='0';
                MemWr <='0';
                WrSrc<='0';
                RegSel<='0';
                RegAff <='0';
                nPCsel <='0';

            when others =>
            null;
        
        end case ;
        
    end process ; -- P2
    
    
    
end architecture rtl;