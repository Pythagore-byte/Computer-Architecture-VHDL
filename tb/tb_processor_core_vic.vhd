-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

-- entity tb_processor_core_vic is
-- end tb_processor_core_vic;

-- architecture test of tb_processor_core_vic is
--     signal clk, reset : std_logic := '0';
--     signal irq_0, irq_1 : std_logic := '0';
--     signal done : boolean := false;
--     signal HEX0,HEX1,HEX2,HEX3,HEX4,HEX5: std_logic_vector(6 downto 0);

-- begin

--     clk <= '0' when done else not(clk) after 10 ns;
--     reset <= '1', '0' after 1 ns;

--     dut: entity work.processor_core_vic
--         port map (
--             clk,
--             reset,
--             irq_0,
--             irq_1,
--             HEX0,HEX1,HEX2,HEX3,HEX4,HEX5
--         );

--     ---------------------------------------------------------------------
--     -- Les appuis sont generes sur front descendant pour que irq_0 / irq_1
--     -- soient stables au moment ou le VIC les echantillonne.
--     --
--     -- A OBSERVER (add wave -r *) :
--     --   dut/new_instruction_unit_vic/inst_instruction_unit_vic/pc_reg/PC_out
--     --   dut/new_instruction_unit_vic/inst_instruction_unit_vic/LR
--     --   dut/new_instruction_unit_vic/IRQ, VICPC, IRQ_SERV
--     --   dut/IRQ_END      (genere par le decodeur, plus par le testbench)
--     --   dut/instruction
--     --   dut/afficheur
--     ---------------------------------------------------------------------
--     P1 : process

--         procedure cycle(n : natural := 1) is
--         begin
--             for i in 1 to n loop
--                 wait until falling_edge(clk);
--             end loop;
--         end procedure;

--         -- appui bref : un front montant, relache au cycle suivant
--         procedure appui_irq0 is
--         begin
--             irq_0 <= '1';
--             cycle;
--             irq_0 <= '0';
--         end procedure;

--         procedure appui_irq1 is
--         begin
--             irq_1 <= '1';
--             cycle;
--             irq_1 <= '0';
--         end procedure;

--     begin

--         wait until reset = '0';
--         cycle(10);
--         report "PHASE 1 : le programme principal tourne (boucle _loop)" severity note;

--         -----------------------------------------------------------------
--         report "PHASE 2 : appui IRQ0 -> ISR0 (adresse 9, BX en 19)" severity note;
--         -----------------------------------------------------------------
--         appui_irq0;
--         -- attendu : PC saute a 9, execute 9..19, puis revient a LR+1
--         cycle(20);

--         -----------------------------------------------------------------
--         report "PHASE 3 : appui IRQ1 -> ISR1 (adresse 21, BX en 31)" severity note;
--         -----------------------------------------------------------------
--         appui_irq1;
--         cycle(20);

--         -----------------------------------------------------------------
--         report "PHASE 4 : les deux boutons en meme temps -> IRQ0 prioritaire" severity note;
--         -----------------------------------------------------------------
--         irq_0 <= '1';
--         irq_1 <= '1';
--         cycle;
--         irq_0 <= '0';
--         irq_1 <= '0';
--         -- attendu : ISR0 d'abord (9..19), puis ISR1 enchainee (21..31),
--         -- puis retour au programme principal. Aucune interruption perdue.
--         cycle(40);

--         -----------------------------------------------------------------
--         report "PHASE 5 : appui pendant l'execution d'une ISR" severity note;
--         -----------------------------------------------------------------
--         appui_irq0;
--         cycle(5);              -- on est au milieu de l'ISR0
--         appui_irq1;            -- nouvelle demande pendant la routine
--         -- attendu : le VIC memorise IRQ1 ; elle est servie apres le BX
--         cycle(40);

--         -----------------------------------------------------------------
--         report "PHASE 6 : appui maintenu -> une seule interruption" severity note;
--         -----------------------------------------------------------------
--         irq_0 <= '1';
--         cycle(30);             -- bouton garde appuye longtemps
--         irq_0 <= '0';
--         -- attendu : ISR0 executee UNE seule fois, pas en boucle
--         cycle(20);

--         report "Fin de simulation" severity note;
--         done <= true;
--         wait;

--     end process; -- P1

-- end architecture test;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_processor_core_vic is
end tb_processor_core_vic;

architecture test of tb_processor_core_vic is

    constant T : time := 20 ns;

    signal clk, reset   : std_logic := '0';
    signal irq_0, irq_1 : std_logic := '0';
    signal done         : boolean := false;

    signal HEX0,HEX1,HEX2,HEX3 : std_logic_vector(6 downto 0);
    signal PC                  : std_logic_vector(31 downto 0);

    -- Cartographie du programme (instruction_memory_irq)
    constant FIN_MAIN : natural := 8;    -- le programme principal occupe 0..8
    constant ISR0_DEB : natural := 9;
    constant ISR0_BX  : natural := 19;
    constant ISR1_DEB : natural := 21;
    constant ISR1_BX  : natural := 31;

begin

    clk   <= '0' when done else not clk after T/2;
    reset <= '1', '0' after 25 ns;

    dut : entity work.processor_core_vic
        port map (
            clk    => clk,
            reset  => reset,
            irq_0  => irq_0,
            irq_1  => irq_1,
            HEX0   => HEX0,
            HEX1   => HEX1,
            HEX2   => HEX2,
            HEX3   => HEX3,
            PC     => PC
        );

    P1 : process

        procedure cycle(n : natural := 1) is
        begin
            for i in 1 to n loop
                wait until falling_edge(clk);
            end loop;
        end procedure;

        -- Appui bref sur un bouton : un seul front montant
        procedure appui(signal bouton : out std_logic) is
        begin
            bouton <= '1';
            cycle;
            bouton <= '0';
        end procedure;

        -- Attend que le PC atteigne une valeur, dans une limite de cycles.
        -- Le deroutement peut etre differe d'un ou deux cycles (branchement
        -- en cours, routine en cours) : on laisse donc une marge.
        procedure attendre_pc(constant cible : natural;
                              constant maxi  : natural;
                              constant nom   : string) is
            variable trouve : boolean := false;
        begin
            for i in 1 to maxi loop
                if to_integer(unsigned(PC)) = cible then
                    trouve := true;
                    exit;
                end if;
                cycle;
            end loop;
            assert trouve
                report nom & " : le PC n'a jamais atteint "
                     & integer'image(cible) & " (il vaut "
                     & integer'image(to_integer(unsigned(PC))) & ")"
                severity error;
        end procedure;

        procedure verifier_dans_main(constant nom : string) is
        begin
            assert to_integer(unsigned(PC)) <= FIN_MAIN
                report nom & " : le PC devrait etre dans le programme principal, il vaut "
                     & integer'image(to_integer(unsigned(PC)))
                severity error;
        end procedure;

    begin

        wait until reset = '0';
        cycle;

        -----------------------------------------------------------------
        report "T0 : le programme principal tourne" severity note;
        -----------------------------------------------------------------
        cycle(20);
        verifier_dans_main("T0");

        -----------------------------------------------------------------
        report "T1 : appui IRQ0 -> ISR0 executee puis retour" severity note;
        -----------------------------------------------------------------
        appui(irq_0);
        attendre_pc(ISR0_DEB, 6,  "T1 (entree ISR0)");
        attendre_pc(ISR0_BX,  15, "T1 (BX de l'ISR0)");
        cycle;
        verifier_dans_main("T1 (retour)");

        cycle(10);

        -----------------------------------------------------------------
        report "T2 : appui IRQ1 -> ISR1 executee puis retour" severity note;
        -----------------------------------------------------------------
        appui(irq_1);
        attendre_pc(ISR1_DEB, 6,  "T2 (entree ISR1)");
        attendre_pc(ISR1_BX,  15, "T2 (BX de l'ISR1)");
        cycle;
        verifier_dans_main("T2 (retour)");

        cycle(10);

        -----------------------------------------------------------------
        report "T3 : appui simultane -> IRQ0 prioritaire, puis IRQ1" severity note;
        -----------------------------------------------------------------
        irq_0 <= '1';
        irq_1 <= '1';
        cycle;
        irq_0 <= '0';
        irq_1 <= '0';

        attendre_pc(ISR0_DEB, 6,  "T3 (IRQ0 d'abord)");
        attendre_pc(ISR0_BX,  15, "T3 (BX de l'ISR0)");
        -- IRQ1 n'a PAS ete acquittee : elle doit etre servie ensuite
        attendre_pc(ISR1_DEB, 6,  "T3 (IRQ1 conservee)");
        attendre_pc(ISR1_BX,  15, "T3 (BX de l'ISR1)");
        cycle;
        verifier_dans_main("T3 (retour)");

        cycle(10);

        -----------------------------------------------------------------
        report "T4 : appui PENDANT une routine -> pas de blocage" severity note;
        -----------------------------------------------------------------
        -- C'est le drapeau en_interruption qui protege ici : sans lui,
        -- LR recevrait une adresse situee dans la routine et le BX y
        -- reviendrait indefiniment.
        appui(irq_0);
        attendre_pc(ISR0_DEB, 6, "T4 (entree ISR0)");
        cycle(3);                            -- on est au milieu de l'ISR0
        appui(irq_1);                        -- nouvelle demande
        attendre_pc(ISR0_BX, 15, "T4 (l'ISR0 va bien jusqu'a son BX)");
        attendre_pc(ISR1_DEB, 6, "T4 (IRQ1 servie apres le retour)");
        attendre_pc(ISR1_BX, 15, "T4 (BX de l'ISR1)");
        cycle;
        verifier_dans_main("T4 (retour)");

        cycle(10);

        -----------------------------------------------------------------
        report "T5 : appuis repetes -> le processeur ne doit jamais figer" severity note;
        -----------------------------------------------------------------
        for i in 1 to 5 loop
            appui(irq_0);
            cycle(4);
            appui(irq_1);
            cycle(4);
        end loop;

        -- On laisse tout se terminer, puis on verifie qu'on est bien
        -- revenu dans le programme principal.
        cycle(80);
        verifier_dans_main("T5 (aucun blocage)");

        cycle(10);

        -----------------------------------------------------------------
        report "Fin de simulation : processeur + VIC OK" severity note;
        done <= true;
        wait;

    end process;

end architecture test;