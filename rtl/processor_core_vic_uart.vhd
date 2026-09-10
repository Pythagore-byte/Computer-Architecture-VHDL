
-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

-- entity processor_core_vic_uart is
--   port (
--     clk     : in std_logic;
--     clk_50  : in std_logic; -- Horloge système (50 MHz pour l'UART)
--     reset   : in std_logic;
--     irq_0   : in std_logic;
--     irq_1   : in std_logic;
--     HEX0,HEX1,HEX2,HEX3: out std_logic_vector(6 downto 0);
--     PC      : out std_logic_vector(31 downto 0);
--     Tx      : out std_logic -- Sortie UART vers le top-level global (PIN_D9)
--   );
-- end processor_core_vic_uart;

-- architecture structural of processor_core_vic_uart is
--     signal instruction : std_logic_vector(31 downto 0);
--     signal imm24       : std_logic_vector(23 downto 0);
--     signal imm8        : std_logic_vector(7 downto 0);
--     signal nzcv        : std_logic_vector(31 downto 0);
--     signal N,Z,C,V     : std_logic;
--     signal AluCtr      : std_logic_vector(2 downto 0);
--     signal RegAff, WrSrc, MemWr, RegSel, ALUSrc, nPCSel, RegWr: std_logic;
--     signal Rd , Rn , Rm : std_logic_vector(3 downto 0);
--     signal bus_B_out   : std_logic_vector(31 downto 0);
--     signal IRQ_END     : std_logic;
--     signal R2_dbg      : std_logic_vector(31 downto 0);

--     -- Signaux spécifiques pour l'UART et la synchronisation inter-horloges
--     signal tick_bit      : std_logic;
--     signal uart_conf_reg : std_logic_vector(31 downto 0);
--     signal wr_en_uart    : std_logic;
--     signal alu_result    : std_logic_vector(31 downto 0); 
    
--     -- Pont inter-domaines (Slow clk -> Fast clk_50)
--     signal toggle_cpu    : std_logic := '0';
--     signal sync_ff1, sync_ff2, sync_ff3 : std_logic := '0';
--     signal go_uart_fast  : std_logic;

-- begin
--     imm24 <= instruction(23 downto 0);
--     imm8 <= instruction(7 downto 0);
--     Rd <= instruction(15 downto 12);
--     Rn <= instruction(19 downto 16);
--     Rm <= instruction(11 downto 8);
--     nzcv <= N&Z&C&V&X"0000000";

--     new_instruction_unit_vic: entity work.new_instruction_unit_vic port map(
--         clk, reset, nPCSel, imm24, irq_0, irq_1, IRQ_END, instruction, PC
--     );

--     control_unit_vic: entity work.control_unit_vic port map(
--         clk, reset, instruction, nzcv, AluCtr, RegAff, WrSrc, MemWr, RegSel, ALUSrc, nPCSel, RegWr, IRQ_END
--     );

--     data_path_uart: entity work.datapath_uart port map(
--         clk       => clk, 
--         reset     => reset, 
--         ALUSrc    => ALUSrc, 
--         WrSrc     => WrSrc, 
--         MemWr     => MemWr, 
--         Imm       => imm8, 
--         ALUCtr    => AluCtr, 
--         Rd        => Rd, 
--         Rn        => Rn, 
--         Rm        => Rm, 
--         RegWr     => RegWr, 
--         RegSel    => RegSel, 
--         bus_B_out => bus_B_out,
--         R2_dbg    => R2_dbg,
--         AluResult => alu_result,
--         N         => N,
--         Z         => Z,
--         C         => C,
--         V         => V
--     );

--     -----------------------------------------------------------------
--     -- 1. Domaine Horloge Lente (CPU à 2Hz/10Hz) : Écriture 0x40 et Toggle
--     -----------------------------------------------------------------
--     wr_en_uart <= '1' when (MemWr = '1' and alu_result = x"00000040") else '0';

--     process(clk, reset)
--     begin
--         if reset = '1' then
--             uart_conf_reg <= (others => '0');
--             toggle_cpu    <= '0';
--         elsif rising_edge(clk) then
--             if wr_en_uart = '1' then
--                 uart_conf_reg <= bus_B_out;
--                 toggle_cpu    <= not toggle_cpu; -- Bascule l'état à chaque écriture
--             end if;
--         end if;
--     end process;

--     -----------------------------------------------------------------
--     -- 2. Domaine CLK_50 (50 MHz) : Synchronisation et impulsion Go UART
--     -----------------------------------------------------------------
--     process(clk_50, reset)
--     begin
--         if reset = '1' then
--             sync_ff1 <= '0';
--             sync_ff2 <= '0';
--             sync_ff3 <= '0';
--         elsif rising_edge(clk_50) then
--             sync_ff1 <= toggle_cpu;
--             sync_ff2 <= sync_ff1;
--             sync_ff3 <= sync_ff2;
--         end if;
--     end process;

--     -- Génère une impulsion d'un cycle à 50 MHz sur détection de front du toggle
--     go_uart_fast <= sync_ff2 xor sync_ff3;

--     -- 3. Instanciation du générateur de tick UART (sur 50 MHz)
--     inst_fdiv: entity work.generateur_tick 
--         port map (clk_50, reset, tick_bit, open);

--     -- 4. Instanciation de l'émetteur UART (sur 50 MHz)
--     inst_uart_tx_reg : entity work.uart_tx_reg 
--         port map (
--             clk       => clk_50,
--             reset     => reset,
--             Go        => go_uart_fast,
--             UART_Conf => uart_conf_reg,
--             Tick_bit  => tick_bit,
--             Tx        => Tx
--         );

--     -----------------------------------------------------------------
--     -- Affichage 7 segments
--     -----------------------------------------------------------------
--     decod_7_seg1: entity work.decodeur_7_segment port map(R2_dbg(3 downto 0), HEX0);
--     decod_7_seg2: entity work.decodeur_7_segment port map(R2_dbg(7 downto 4), HEX1);
--     decod_7_seg3: entity work.decodeur_7_segment port map(R2_dbg(11 downto 8), HEX2);
--     decod_7_seg4: entity work.decodeur_7_segment port map(R2_dbg(15 downto 12), HEX3);

-- end architecture structural;

-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

-- entity processor_core_vic_uart is
--   port (
--     clk     : in std_logic;
--     clk_50  : in std_logic; -- Horloge système (50 MHz pour l'UART)
--     reset   : in std_logic;
--     irq_0   : in std_logic;
--     irq_1   : in std_logic;
--     HEX0,HEX1,HEX2,HEX3: out std_logic_vector(6 downto 0);
--     PC      : out std_logic_vector(31 downto 0);
--     Tx      : out std_logic -- Sortie UART vers le top-level global (PIN_D9)
--   );
-- end processor_core_vic_uart;

-- architecture structural of processor_core_vic_uart is
--     signal instruction : std_logic_vector(31 downto 0);
--     signal imm24       : std_logic_vector(23 downto 0);
--     signal imm8        : std_logic_vector(7 downto 0);
--     signal nzcv        : std_logic_vector(31 downto 0);
--     signal N,Z,C,V     : std_logic;
--     signal AluCtr      : std_logic_vector(2 downto 0);
--     signal RegAff, WrSrc, MemWr, RegSel, ALUSrc, nPCSel, RegWr: std_logic;
--     signal Rd , Rn , Rm : std_logic_vector(3 downto 0);
--     signal bus_B_out   : std_logic_vector(31 downto 0);
--     signal IRQ_END     : std_logic;
--     signal R2_dbg      : std_logic_vector(31 downto 0);

--     -- Signaux spécifiques pour l'UART et la synchronisation inter-horloges
--     signal tick_bit      : std_logic;
--     signal uart_conf_reg : std_logic_vector(31 downto 0);
--     signal wr_en_uart    : std_logic;
--     signal alu_result    : std_logic_vector(31 downto 0); 
    
--     -- Pont inter-domaines (Slow clk <-> Fast clk_50)
--     signal toggle_cpu    : std_logic := '0';
--     signal sync_ff1, sync_ff2, sync_ff3 : std_logic := '0';
--     signal go_uart_fast  : std_logic;

--     -- Signaux pour l'interruption UART (TxIrq)
--     signal tx_irq_fast   : std_logic;
--     signal tx_irq_slow_sync1, tx_irq_slow_sync2 : std_logic := '0';
--     signal irq_uart_net  : std_logic;
    
--     -- Liaison VIC / Unité d'instruction
--     signal irq_global    : std_logic;
--     signal vicpc_net     : std_logic_vector(31 downto 0);

-- begin
--     imm24 <= instruction(23 downto 0);
--     imm8 <= instruction(7 downto 0);
--     Rd <= instruction(15 downto 12);
--     Rn <= instruction(19 downto 16);
--     Rm <= instruction(11 downto 8);
--     nzcv <= N&Z&C&V&X"0000000";

--     -- Modification de l'unité d'interruption pour intégrer le VIC étendu
--     -- (Note : Assure-toi que ton entité new_instruction_unit_vic accepte 
--     --  les signaux irq_global et vicpc issus du VIC, ou adapte le nom si besoin)
--     -- Remplacer l'ancienne instanciation de new_instruction_unit_vic par celle-ci :
--     new_instruction_unit_vic: entity work.new_instruction_unit_vic_uart port map(
--         clk         => clk, 
--         reset       => reset, 
--         nPCSel      => nPCSel, 
--         offset      => imm24,       -- Correction du nom (anciennement imm => imm24)
--         irq_0       => irq_0, 
--         irq_1       => irq_1, 
--         irq_uart    => irq_uart_net, -- Transmission du TxIrq synchronisé vers le VIC interne
--         IRQ_END     => IRQ_END, 
--         instruction => instruction, 
--         PC          => PC
--     );

--     control_unit_vic: entity work.control_unit_vic port map(
--         clk, reset, instruction, nzcv, AluCtr, RegAff, WrSrc, MemWr, RegSel, ALUSrc, nPCSel, RegWr, IRQ_END
--     );

--     data_path_uart: entity work.datapath_uart port map(
--         clk       => clk, 
--         reset     => reset, 
--         ALUSrc    => ALUSrc, 
--         WrSrc     => WrSrc, 
--         MemWr     => MemWr, 
--         Imm       => imm8, 
--         ALUCtr    => AluCtr, 
--         Rd        => Rd, 
--         Rn        => Rn, 
--         Rm        => Rm, 
--         RegWr     => RegWr, 
--         RegSel    => RegSel, 
--         bus_B_out => bus_B_out,
--         R2_dbg    => R2_dbg,
--         AluResult => alu_result,
--         N         => N,
--         Z         => Z,
--         C         => C,
--         V         => V
--     );



--     -----------------------------------------------------------------
--     -- 1. Domaine Horloge Lente (CPU) : Écriture 0x40 et Toggle Go
--     -----------------------------------------------------------------
--     wr_en_uart <= '1' when (MemWr = '1' and alu_result = x"00000040") else '0';

--     process(clk, reset)
--     begin
--         if reset = '1' then
--             uart_conf_reg <= (others => '0');
--             toggle_cpu    <= '0';
--         elsif rising_edge(clk) then
--             if wr_en_uart = '1' then
--                 uart_conf_reg <= bus_B_out;
--                 toggle_cpu    <= not toggle_cpu; 
--             end if;
--         end if;
--     end process;

--     -----------------------------------------------------------------
--     -- 2. Domaine CLK_50 (50 MHz) : Synchronisation Go & Émission UART
--     -----------------------------------------------------------------
--     process(clk_50, reset)
--     begin
--         if reset = '1' then
--             sync_ff1 <= '0';
--             sync_ff2 <= '0';
--             sync_ff3 <= '0';
--         elsif rising_edge(clk_50) then
--             sync_ff1 <= toggle_cpu;
--             sync_ff2 <= sync_ff1;
--             sync_ff3 <= sync_ff2;
--         end if;
--     end process;

--     go_uart_fast <= sync_ff2 xor sync_ff3;

--     inst_fdiv: entity work.generateur_tick 
--         port map (clk_50, reset, tick_bit, open);

--     -- Instance UART mise à jour avec la sortie TxIrq
--     inst_uart_tx_reg : entity work.uart_tx_reg 
--         port map (
--             clk       => clk_50,
--             reset     => reset,
--             Go        => go_uart_fast,
--             UART_Conf => uart_conf_reg,
--             Tick_bit  => tick_bit,
--             Tx        => Tx,
--             TxIrq     => tx_irq_fast
--         );

--     -----------------------------------------------------------------
--     -- 3. Resynchronisation de TxIrq (Fast 50MHz -> Slow clk du CPU)
--     -----------------------------------------------------------------
--     process(clk, reset)
--     begin
--         if reset = '1' then
--             tx_irq_slow_sync1 <= '0';
--             tx_irq_slow_sync2 <= '0';
--         elsif rising_edge(clk) then
--             tx_irq_slow_sync1 <= tx_irq_fast;
--             tx_irq_slow_sync2 <= tx_irq_slow_sync1;
--         end if;
--     end process;

--     -- Signal d'interruption propre ramené dans le domaine d'horloge lent du processeur
--     irq_uart_net <= tx_irq_slow_sync2;

--     -----------------------------------------------------------------
--     -- Affichage 7 segments
--     -----------------------------------------------------------------
--     decod_7_seg1: entity work.decodeur_7_segment port map(R2_dbg(3 downto 0), HEX0);
--     decod_7_seg2: entity work.decodeur_7_segment port map(R2_dbg(7 downto 4), HEX1);
--     decod_7_seg3: entity work.decodeur_7_segment port map(R2_dbg(11 downto 8), HEX2);
--     decod_7_seg4: entity work.decodeur_7_segment port map(R2_dbg(15 downto 12), HEX3);

-- end architecture structural;



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity processor_core_vic_uart is
  port (
    clk     : in std_logic;
    clk_50  : in std_logic; -- Horloge système (50 MHz pour l'UART)
    reset   : in std_logic;
    irq_0   : in std_logic;
    irq_1   : in std_logic;
    HEX0,HEX1,HEX2,HEX3: out std_logic_vector(6 downto 0);
    PC      : out std_logic_vector(31 downto 0);
    Tx      : out std_logic -- Sortie UART vers le top-level global (PIN_D9)
  );
end processor_core_vic_uart;

architecture structural of processor_core_vic_uart is
    signal instruction : std_logic_vector(31 downto 0);
    signal imm24       : std_logic_vector(23 downto 0);
    signal imm8        : std_logic_vector(7 downto 0);
    signal nzcv        : std_logic_vector(31 downto 0);
    signal N,Z,C,V     : std_logic;
    signal AluCtr      : std_logic_vector(2 downto 0);
    signal RegAff, WrSrc, MemWr, RegSel, ALUSrc, nPCSel, RegWr: std_logic;
    signal Rd , Rn , Rm : std_logic_vector(3 downto 0);
    signal bus_B_out   : std_logic_vector(31 downto 0);
    signal IRQ_END     : std_logic;
    signal R2_dbg      : std_logic_vector(31 downto 0);

    -- Signaux spécifiques pour l'UART et la synchronisation inter-horloges
    signal tick_bit      : std_logic;
    signal uart_conf_reg : std_logic_vector(31 downto 0);
    signal wr_en_uart    : std_logic;
    signal alu_result    : std_logic_vector(31 downto 0); 
    
    -- Pont inter-domaines (Slow clk <-> Fast clk_50) pour le départ d'émission
    signal toggle_cpu    : std_logic := '0';
    signal sync_ff1, sync_ff2, sync_ff3 : std_logic := '0';
    signal go_uart_fast  : std_logic;

begin
    imm24 <= instruction(23 downto 0);
    imm8 <= instruction(7 downto 0);
    Rd <= instruction(15 downto 12);
    Rn <= instruction(19 downto 16);
    Rm <= instruction(11 downto 8);
    nzcv <= N&Z&C&V&X"0000000";

    -- Retour à l'unité d'interruption standard (irq_0 et irq_1 uniquement)
    new_instruction_unit_vic: entity work.new_instruction_unit_vic port map(
        clk         => clk, 
        reset       => reset, 
        nPCSel      => nPCSel, 
        offset      => imm24, 
        irq_0       => irq_0, 
        irq_1       => irq_1, 
        IRQ_END     => IRQ_END, 
        instruction => instruction, 
        PC          => PC
    );

    control_unit_vic: entity work.control_unit_vic port map(
        clk, reset, instruction, nzcv, AluCtr, RegAff, WrSrc, MemWr, RegSel, ALUSrc, nPCSel, RegWr, IRQ_END
    );

    data_path_uart: entity work.datapath_uart port map(
        clk       => clk, 
        reset     => reset, 
        ALUSrc    => ALUSrc, 
        WrSrc     => WrSrc, 
        MemWr     => MemWr, 
        Imm       => imm8, 
        ALUCtr    => AluCtr, 
        Rd        => Rd, 
        Rn        => Rn, 
        Rm        => Rm, 
        RegWr     => RegWr, 
        RegSel    => RegSel, 
        bus_B_out => bus_B_out,
        R2_dbg    => R2_dbg,
        AluResult => alu_result,
        N         => N,
        Z         => Z,
        C         => C,
        V         => V
    );

    -----------------------------------------------------------------
    -- 1. Domaine Horloge Lente (CPU) : Écriture 0x40 et Toggle Go
    -----------------------------------------------------------------
    wr_en_uart <= '1' when (MemWr = '1' and alu_result = x"00000040") else '0';

    process(clk, reset)
    begin
        if reset = '1' then
            uart_conf_reg <= (others => '0');
            toggle_cpu    <= '0';
        elsif rising_edge(clk) then
            if wr_en_uart = '1' then
                uart_conf_reg <= bus_B_out;
                toggle_cpu    <= not toggle_cpu; 
            end if;
        end if;
    end process;

    -----------------------------------------------------------------
    -- 2. Domaine CLK_50 (50 MHz) : Synchronisation Go & Émission UART
    -----------------------------------------------------------------
    process(clk_50, reset)
    begin
        if reset = '1' then
            sync_ff1 <= '0';
            sync_ff2 <= '0';
            sync_ff3 <= '0';
        elsif rising_edge(clk_50) then
            sync_ff1 <= toggle_cpu;
            sync_ff2 <= sync_ff1;
            sync_ff3 <= sync_ff2;
        end if;
    end process;

    go_uart_fast <= sync_ff2 xor sync_ff3;

    inst_fdiv: entity work.generateur_tick 
        port map (clk_50, reset, tick_bit, open);

    -- Instance UART d'origine sans TxIrq
    inst_uart_tx_reg : entity work.uart_tx_reg 
        port map (
            clk       => clk_50,
            reset     => reset,
            Go        => go_uart_fast,
            UART_Conf => uart_conf_reg,
            Tick_bit  => tick_bit,
            Tx        => Tx
        );

    -----------------------------------------------------------------
    -- Affichage 7 segments
    -----------------------------------------------------------------
    decod_7_seg1: entity work.decodeur_7_segment port map(R2_dbg(3 downto 0), HEX0);
    decod_7_seg2: entity work.decodeur_7_segment port map(R2_dbg(7 downto 4), HEX1);
    decod_7_seg3: entity work.decodeur_7_segment port map(R2_dbg(11 downto 8), HEX2);
    decod_7_seg4: entity work.decodeur_7_segment port map(R2_dbg(15 downto 12), HEX3);

end architecture structural;