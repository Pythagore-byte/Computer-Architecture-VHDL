library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_control_unit is
end tb_control_unit;

architecture test of tb_control_unit is

    -- Signaux de commande du testbench
    signal s_clk         : std_logic := '0';
    signal s_reset       : std_logic := '0';
    signal s_instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal s_flags       : std_logic_vector(31 downto 0) := (others => '0');
    signal done :boolean:=false;

    -- Signaux de sortie de l'unité de contrôle
    signal s_AluCtr      : std_logic_vector(2 downto 0);
    signal s_RegAff      : std_logic;
    signal s_WrSrc       : std_logic;
    signal s_MemWr       : std_logic;
    signal s_RegSel      : std_logic;
    signal s_ALUSrc      : std_logic;
    signal s_nPCSel      : std_logic;
    signal s_RegWr       : std_logic;

    -- Constante pour la période d'horloge (10 ns -> 100 MHz)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instanciation de l'Unité de Contrôle (UUT)
    dut: entity work.control_unit
        port map (
            clk         => s_clk,
            reset       => s_reset,
            instruction => s_instruction,
            flags       => s_flags,
            AluCtr      => s_AluCtr,
            RegAff      => s_RegAff,
            WrSrc       => s_WrSrc,
            MemWr       => s_MemWr,
            RegSel      => s_RegSel,
            ALUSrc      => s_ALUSrc,
            nPCSel      => s_nPCSel,
            RegWr       => s_RegWr
        );

    -- Génération de l'horloge
    s_clk <='0' when done else not(s_clk) after CLK_PERIOD/2;

    

    -- Processus de test (Stimulus)
    stimulus_process: process
    begin
        report "Début de la simulation de l'unité de contrôle...";

        -- 1. Reset initial
        s_reset <= '1';
        wait for 20 ns;
        s_reset <= '0';
        wait for 10 ns;

        -- 2. Test de MOV R1, #0x20 (x"E3A01020")
        s_instruction <= x"E3A01020";
        wait for 20 ns;

        -- 3. Test de ADDi R1, R1, #1 (x"E2811001")
        s_instruction <= x"E2811001";
        wait for 20 ns;

        -- 4. Test de CMP R1, #0x2A (x"E351002A") - Met à jour les drapeaux
        s_instruction <= x"E351002A";
        s_flags       <= x"80000000"; -- Simulation d'un drapeau N=1 (négatif)
        wait for 20 ns;

        -- 5. Test de LDR R0, 0(R1) (x"E6110000")
        s_instruction <= x"E6110000";
        wait for 20 ns;

        -- 6. Test de STR R2, 0(R1) (x"E6012000")
        s_instruction <= x"E6012000";
        wait for 20 ns;

        -- 7. Test de BLT loop (x"BAFFFFFB") avec N=1 (le saut doit s'activer via le PSR)
        s_instruction <= x"BAFFFFFB";
        wait for 20 ns;

        report "Fin de la simulation de l'unité de contrôle.";
        done <=true;
        wait;
    end process;

end test;