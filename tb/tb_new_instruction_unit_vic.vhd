-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

-- entity tb_new_instruction_unit_vic is
-- end tb_new_instruction_unit_vic;

-- architecture test of tb_new_instruction_unit_vic is

--     constant T : time := 10 ns;

--     signal clk   : std_logic := '0';
--     signal reset : std_logic;
--     signal done  : boolean := false;

--     -- stimuli
--     signal irq_0, irq_1 : std_logic := '0';
--     signal nPCsel       : std_logic := '0';
--     signal IRQ_END      : std_logic := '0';
--     signal offset       : std_logic_vector(23 downto 0) := (others => '0');

--     -- seule sortie observable
--     signal Instruction  : std_logic_vector(31 downto 0);

-- begin

--     clk   <= '0' when done else not clk after T/2;
--     reset <= '1', '0' after 12 ns;

--     dut : entity work.new_instruction_unit_vic
--         port map (
--             clk         => clk,
--             reset       => reset,
--             nPCsel      => nPCsel,
--             offset      => offset,
--             irq_0       => irq_0,
--             irq_1       => irq_1,
--             IRQ_END     => IRQ_END,
--             Instruction => Instruction
--         );

--     ---------------------------------------------------------------------
--     -- A OBSERVER DANS LA FENETRE WAVE (add wave -r *) :
--     --
--     --   dut/inst_vic/irq0_memo, irq1_memo
--     --   dut/IRQ, dut/VICPC, dut/IRQ_SERV
--     --   dut/inst_instruction_unit_vic/pc_out
--     --   dut/inst_instruction_unit_vic/LR
--     --   dut/inst_instruction_unit_vic/prise_en_compte
--     --
--     -- Le transcript annonce chaque phase : recale le curseur dessus.
--     ---------------------------------------------------------------------
--     P1 : process

--         procedure cycle(n : natural := 1) is
--         begin
--             for i in 1 to n loop
--                 wait until falling_edge(clk);
--             end loop;
--         end procedure;

--     begin

--         wait until reset = '0';
--         cycle;

--         -----------------------------------------------------------------
--         report "PHASE 1 : execution normale, PC doit s'incrementer" severity note;
--         -----------------------------------------------------------------
--         cycle(3);
--         -- attendu : pc_out = 1, 2, 3, 4 ...
--         -- IRQ, IRQ_SERV, prise_en_compte doivent rester a 0

--         -----------------------------------------------------------------
--         report "PHASE 2 : appui IRQ0 -> deroutement vers 0x9" severity note;
--         -----------------------------------------------------------------
--         irq_0 <= '1';
--         cycle;
--         irq_0 <= '0';
--         -- ce cycle : irq0_memo = 1, IRQ = 1, VICPC = 0x9, IRQ_SERV = 1
--         --            prise_en_compte = 1
--         cycle;
--         -- ce cycle : pc_out = 0x9, LR = adresse interrompue
--         --            IRQ retombe (acquitte), IRQ_SERV retombe

--         -----------------------------------------------------------------
--         report "PHASE 3 : execution de la routine 0x9, 0xA, 0xB" severity note;
--         -----------------------------------------------------------------
--         cycle(3);
--         -- pc_out = 9, 10, 11 ... LR ne doit PAS bouger

--         -----------------------------------------------------------------
--         report "PHASE 4 : instruction BX -> retour a LR+1" severity note;
--         -----------------------------------------------------------------
--         IRQ_END <= '1';
--         cycle;
--         IRQ_END <= '0';
--         -- au cycle suivant : pc_out = LR + 1

--         cycle(3);
--         -- le programme principal doit reprendre son incrementation

--         -----------------------------------------------------------------
--         report "PHASE 5 : branchement classique (nPCsel), offset = +3" severity note;
--         -----------------------------------------------------------------
--         offset <= std_logic_vector(to_signed(3, 24));
--         nPCsel <= '1';
--         cycle;
--         nPCsel <= '0';
--         offset <= (others => '0');
--         -- pc_out doit sauter de +4 (pc + offset + 1)

--         cycle(2);

--         -----------------------------------------------------------------
--         report "PHASE 6 : appui IRQ1 -> deroutement vers 0x15" severity note;
--         -----------------------------------------------------------------
--         irq_1 <= '1';
--         cycle;
--         irq_1 <= '0';
--         cycle;
--         -- pc_out = 0x15 (21 en decimal), LR = adresse interrompue

--         cycle(3);

--         IRQ_END <= '1';
--         cycle;
--         IRQ_END <= '0';
--         cycle(2);

--         -----------------------------------------------------------------
--         report "PHASE 7 : CAS CRITIQUE - nouvelle IRQ pendant le BX" severity note;
--         -----------------------------------------------------------------
--         irq_0 <= '1';                   -- premiere interruption
--         cycle;
--         irq_0 <= '0';
--         cycle(3);                       -- on est dans la routine 0x9

--         -- collision : BX et nouvel appui sur le meme cycle
--         IRQ_END <= '1';
--         irq_1   <= '1';
--         cycle;
--         IRQ_END <= '0';
--         irq_1   <= '0';
--         -- ATTENDU sur ce cycle :
--         --   prise_en_compte = 0  (IRQ_END gagne)
--         --   pc_out passe a LR+1  (retour au programme principal)
--         --   irq1_memo = 1, IRQ reste a 1 (le VIC n'a PAS ete acquitte)
--         --   LR ne doit PAS avoir change

--         cycle;
--         -- ATTENDU maintenant :
--         --   prise_en_compte = 1, pc_out = 0x15
--         --   LR = adresse du programme principal (PAS celle du BX)

--         cycle(3);
--         IRQ_END <= '1';
--         cycle;
--         IRQ_END <= '0';

--         cycle(3);

--         -----------------------------------------------------------------
--         report "Fin de simulation" severity note;
--         done <= true;
--         wait;

--     end process;

-- end architecture test;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_new_instruction_unit_vic is
end tb_new_instruction_unit_vic;

architecture test of tb_new_instruction_unit_vic is

    constant T : time := 10 ns;

    signal clk   : std_logic := '0';
    signal reset : std_logic;
    signal done  : boolean := false;

    -- stimuli
    signal irq_0, irq_1 : std_logic := '0';
    signal nPCsel       : std_logic := '0';
    signal IRQ_END      : std_logic := '0';
    signal offset       : std_logic_vector(23 downto 0) := (others => '0');

    -- observation
    signal Instruction  : std_logic_vector(31 downto 0);
    signal PC           : std_logic_vector(31 downto 0);

    constant ADR_IRQ0 : natural := 9;
    constant ADR_IRQ1 : natural := 21;

begin

    clk   <= '0' when done else not clk after T/2;
    reset <= '1', '0' after 12 ns;

    -- Association NOMMEE : l'ordre des ports peut changer sans casser
    -- le testbench. A preferer systematiquement.
    dut : entity work.new_instruction_unit_vic
        port map (
            clk         => clk,
            reset       => reset,
            nPCsel      => nPCsel,
            offset      => offset,
            irq_0       => irq_0,
            irq_1       => irq_1,
            IRQ_END     => IRQ_END,
            Instruction => Instruction,
            PC          => PC
        );

    P1 : process

        procedure cycle(n : natural := 1) is
        begin
            for i in 1 to n loop
                wait until falling_edge(clk);
            end loop;
        end procedure;

        -- Verifie que le PC vaut la valeur attendue
        procedure verifier_pc(constant cible : natural;
                              constant nom   : string) is
        begin
            assert to_integer(unsigned(PC)) = cible
                report nom & " : PC vaut " & integer'image(to_integer(unsigned(PC)))
                     & " au lieu de " & integer'image(cible)
                severity error;
        end procedure;

        variable pc_avant : natural;

    begin

        wait until reset = '0';
        cycle;

        -----------------------------------------------------------------
        report "T0 : execution normale, le PC doit s'incrementer" severity note;
        -----------------------------------------------------------------
        pc_avant := to_integer(unsigned(PC));
        cycle;
        assert to_integer(unsigned(PC)) = pc_avant + 1
            report "T0 : le PC doit s'incrementer de 1" severity error;

        cycle(2);

        -----------------------------------------------------------------
        report "T1 : appui IRQ0 -> deroutement vers 0x9" severity note;
        -----------------------------------------------------------------
        pc_avant := to_integer(unsigned(PC));
        irq_0 <= '1';
        cycle;                       -- le VIC capte le front, IRQ monte
        irq_0 <= '0';
        pc_avant := to_integer(unsigned(PC));
        cycle;                       -- le deroutement a lieu

        verifier_pc(ADR_IRQ0, "T1");

        -----------------------------------------------------------------
        report "T2 : la routine s'execute, puis BX -> retour a LR+1" severity note;
        -----------------------------------------------------------------
        cycle(2);                    -- PC = 10, 11
        verifier_pc(ADR_IRQ0 + 2, "T2");

        IRQ_END <= '1';
        cycle;
        IRQ_END <= '0';

        assert to_integer(unsigned(PC)) = pc_avant + 1
            report "T2 : le PC doit reprendre juste apres l'instruction interrompue"
            severity error;

        cycle(2);

        -----------------------------------------------------------------
        report "T3 : appui IRQ1 -> deroutement vers 0x15" severity note;
        -----------------------------------------------------------------
        irq_1 <= '1';
        cycle;
        irq_1 <= '0';
        cycle;

        verifier_pc(ADR_IRQ1, "T3");

        cycle(2);
        IRQ_END <= '1';
        cycle;
        IRQ_END <= '0';

        assert to_integer(unsigned(PC)) < ADR_IRQ0
            report "T3 : on doit etre revenu dans le programme principal"
            severity error;

        cycle(2);

        -----------------------------------------------------------------
        report "T4 : IRQ pendant un BRANCHEMENT -> deroutement differe" severity note;
        -----------------------------------------------------------------
        -- Sans la condition nPCsel = '0', le branchement serait annule
        -- et le retour a LR+1 ramenerait sur l'instruction de branchement
        -- elle-meme : boucle infinie.
        pc_avant := to_integer(unsigned(PC));
        offset <= std_logic_vector(to_signed(3, 24));
        nPCsel <= '1';
        irq_0  <= '1';               -- collision volontaire
        cycle;
        nPCsel <= '0';
        irq_0  <= '0';
        offset <= (others => '0');

        assert to_integer(unsigned(PC)) = pc_avant + 4
            report "T4 : le branchement doit avoir lieu (pc + offset + 1)"
            severity error;

        cycle;
        verifier_pc(ADR_IRQ0, "T4");   -- l'IRQ est servie au cycle suivant

        -----------------------------------------------------------------
        report "T5 : IRQ pendant une ROUTINE -> deroutement bloque" severity note;
        -----------------------------------------------------------------
        -- Sans le drapeau en_interruption, LR recevrait une adresse
        -- situee DANS la routine et le BX y reviendrait indefiniment.
        cycle;                       -- PC = 10, on est dans la routine
        irq_1 <= '1';
        cycle;
        irq_1 <= '0';

        assert to_integer(unsigned(PC)) >= ADR_IRQ0
           and to_integer(unsigned(PC)) <  ADR_IRQ1
            report "T5 : le PC doit rester dans la routine, pas se derouter"
            severity error;

        cycle;
        IRQ_END <= '1';              -- fin de la routine 0
        cycle;
        IRQ_END <= '0';

        cycle;
        verifier_pc(ADR_IRQ1, "T5");   -- IRQ1 conservee, servie apres le retour

        cycle(2);
        IRQ_END <= '1';
        cycle;
        IRQ_END <= '0';
        cycle(2);

        -----------------------------------------------------------------
        report "Fin de simulation : unite de gestion + VIC OK" severity note;
        done <= true;
        wait;

    end process;

end architecture test;