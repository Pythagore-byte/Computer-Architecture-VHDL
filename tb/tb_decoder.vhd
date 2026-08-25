library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_decoder is
end tb_decoder;

architecture sim of tb_decoder is

    -- Signaux pour piloter le composant (Decoder)
    signal s_Instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal s_PSR         : std_logic_vector(31 downto 0) := (others => '0');
    
    -- Signaux de sortie du décodeur
    signal s_PSREn       : std_logic;
    signal s_AluCtr      : std_logic_vector(2 downto 0);
    signal s_RegAff      : std_logic;
    signal s_WrSrc       : std_logic;
    signal s_MemWr       : std_logic;
    signal s_RegSel      : std_logic;
    signal s_ALUSrc      : std_logic;
    signal s_nPCSel      : std_logic;
    signal s_RegWr       : std_logic;

begin

    -- Instanciation du composant Decoder (UUT : Unit Under Test)
    dut: entity work.decoder
        port map (
            Instruction => s_Instruction,
            PSR         => s_PSR,
            PSREn       => s_PSREn,
            AluCtr      => s_AluCtr,
            RegAff      => s_RegAff,
            WrSrc       => s_WrSrc,
            MemWr       => s_MemWr,
            RegSel      => s_RegSel,
            ALUSrc      => s_ALUSrc,
            nPCSel      => s_nPCSel,
            RegWr       => s_RegWr
        );

    -- Processus de stimulus pour tester les instructions
    stimulus_process: process
    begin
        report "Début de la simulation du décodeur...";

        -- 1. Test de MOV R1, #0x20 (x"E3A01020")
        s_Instruction <= x"E3A01020";
        wait for 20 ns;

        -- 2. Test de ADDi R1, R1, #1 (x"E2811001")
        s_Instruction <= x"E2811001";
        wait for 20 ns;

        -- 3. Test de ADDr R2, R2, R0 (x"E0822000")
        s_Instruction <= x"E0822000";
        wait for 20 ns;

        -- 4. Test de CMP R1, #0x2A (x"E351002A")
        s_Instruction <= x"E351002A";
        wait for 20 ns;

        -- 5. Test de LDR R0, 0(R1) (x"E6110000")
        s_Instruction <= x"E6110000";
        wait for 20 ns;

        -- 6. Test de STR R2, 0(R1) (x"E6012000")
        s_Instruction <= x"E6012000";
        wait for 20 ns;

        -- 7. Test de BAL main (x"EAFFFFF7")
        s_Instruction <= x"EAFFFFF7";
        wait for 20 ns;

        -- 8. Test de BLT loop (x"BAFFFFFB") avec PSR(31) = '0' (pas de saut)
        s_Instruction <= x"BAFFFFFB";
        s_PSR         <= x"00000000"; -- N = 0
        wait for 20 ns;

        -- 9. Test de BLT loop (x"BAFFFFFB") avec PSR(31) = '1' (saut validé)
        s_PSR         <= x"80000000"; -- N = 1 (bit 31 à '1')
        wait for 20 ns;

        report "Fin de la simulation.";
        wait;
    end process;

end sim;