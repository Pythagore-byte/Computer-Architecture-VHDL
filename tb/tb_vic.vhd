-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

-- entity tb_vic is
-- end tb_vic;

-- architecture test of tb_vic is
--     signal clk , reset : std_logic := '0';
--     signal irq_serv: std_logic := '0';
--     signal irq_0, irq_1 : std_logic := '0';
--     signal irq : std_logic;
--     signal vicpc : std_logic_vector(31 downto 0);
--     signal done : boolean := false;
    
-- begin

--     inst : entity work.vic port map(clk, reset, irq_serv, irq_0, irq_1, irq, vicpc);

--     -- Gestion de l'horloge (période de 10 ns)
--     reset <= '1', '0' after 15 ns;
--     clk <= '0' when done else not(clk) after 5 ns;

--     P1 : process
--     begin
--         -- Attente de la fin du reset
--         wait until reset = '0';
--         wait for 2 ns;

--         -- Test 1 : Déclenchement de irq_0 (front montant)
--         wait until rising_edge(clk);
--         irq_0 <= '1';
--         wait until rising_edge(clk);
--         irq_0 <= '0';
        
--         -- Vérification après mémorisation
--         wait for 1 ns;
--         assert (irq = '1') report "Erreur : irq doit etre a 1 pour irq_0" severity error;
--         assert (vicpc = x"00000009") report "Erreur : vicpc doit pointer vers l'adresse 0x9" severity error;

--         -- Test 2 : Acquittement de irq_0 via irq_serv
--         wait until rising_edge(clk);
--         irq_serv <= '1';
--         wait until rising_edge(clk);
--         irq_serv <= '0';
        
--         wait for 1 ns;
--         assert (irq = '0') report "Erreur : irq doit retomber a 0 apres acquittement" severity error;
--         assert (vicpc = x"00000000") report "Erreur : vicpc doit revenir a 0" severity error;

--         -- Test 3 : Déclenchement de irq_1 (front montant)
--         wait until rising_edge(clk);
--         irq_1 <= '1';
--         wait until rising_edge(clk);
--         irq_1 <= '0';
        
--         wait for 1 ns;
--         assert (irq = '1') report "Erreur : irq doit etre a 1 pour irq_1" severity error;
--         assert (vicpc = x"00000015") report "Erreur : vicpc doit pointer vers l'adresse 0x15" severity error;

--         -- Acquittement de irq_1
--         wait until rising_edge(clk);
--         irq_serv <= '1';
--         wait until rising_edge(clk);
--         irq_serv <= '0';
        
--         wait for 1 ns;

--         -- Test 4 : Gestion de la priorité (irq_0 et irq_1 activés simultanément)
--         wait until rising_edge(clk);
--         irq_0 <= '1';
--         irq_1 <= '1';
--         wait until rising_edge(clk);
--         irq_0 <= '0';
--         irq_1 <= '0';
        
--         wait for 1 ns;
--         assert (vicpc = x"00000009") report "Erreur : irq_0 doit etre prioritaire sur irq_1" severity error;

--         -- Premier acquittement (traite irq_0)
--         wait until rising_edge(clk);
--         irq_serv <= '1';
--         wait until rising_edge(clk);
--         irq_serv <= '0';
        
--         wait for 1 ns;
--         assert (vicpc = x"00000015") report "Erreur : irq_1 doit prendre le relais apres irq_0" severity error;

--         -- Second acquittement (traite irq_1)
--         wait until rising_edge(clk);
--         irq_serv <= '1';
--         wait until rising_edge(clk);
--         irq_serv <= '0';

--         wait for 20 ns;
--         done <= true;
--         wait;
--     end process;

-- end architecture test;





library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_vic is
end tb_vic;

architecture test of tb_vic is

    constant T : time := 10 ns;

    signal clk      : std_logic := '0';
    signal reset    : std_logic;
    signal irq_serv : std_logic := '0';
    signal irq_0    : std_logic := '0';
    signal irq_1    : std_logic := '0';
    signal irq      : std_logic;
    signal vicpc    : std_logic_vector(31 downto 0);
    signal done     : boolean := false;

    constant ADR_IRQ0 : std_logic_vector(31 downto 0) := x"00000009";
    constant ADR_IRQ1 : std_logic_vector(31 downto 0) := x"00000015";
    constant ADR_NULL : std_logic_vector(31 downto 0) := (others => '0');

begin

    inst : entity work.vic
        port map (
            clk      => clk,
            reset    => reset,
            irq_serv => irq_serv,
            irq_0    => irq_0,
            irq_1    => irq_1,
            irq      => irq,
            vicpc    => vicpc
        );

    clk <= '0' when done else not clk after T/2;

    -- Relache du reset a 12 ns : volontairement HORS d'un front montant
    -- (fronts a 5, 15, 25... ns) pour eviter toute course reset/horloge.
    reset <= '1', '0' after 12 ns;

    ---------------------------------------------------------------------
    -- Methodologie :
    --   * les stimuli sont appliques sur FRONT DESCENDANT
    --     -> les entrees sont stables bien avant le front montant
    --   * les verifications se font aussi sur front descendant
    --     -> on observe l'etat resultant du front montant precedent
    --   * VICPC est une sortie REGISTREE : il apparait UN CYCLE apres irq
    ---------------------------------------------------------------------

    P1 : process

        procedure cycle(n : natural := 1) is
        begin
            for i in 1 to n loop
                wait until falling_edge(clk);
            end loop;
        end procedure;

    begin

        -----------------------------------------------------------------
        -- Test 0 : etat apres reset
        -----------------------------------------------------------------
        wait until reset = '0';
        cycle;

        assert irq = '0'
            report "T0 : irq doit etre a 0 apres reset" severity error;
        assert vicpc = ADR_NULL
            report "T0 : vicpc doit etre a 0 apres reset" severity error;

        -----------------------------------------------------------------
        -- Test 1 : front montant sur IRQ0
        -----------------------------------------------------------------
        irq_0 <= '1';
        cycle;                      -- le front est capte : irq0_memo = 1

        assert irq = '1'
            report "T1 : irq doit passer a 1 sur front IRQ0" severity error;
        assert vicpc = ADR_NULL
            report "T1 : vicpc est registre, il vaut encore 0 a ce cycle" severity error;

        cycle;                      -- cycle suivant : l'adresse sort

        assert vicpc = ADR_IRQ0
            report "T1 : vicpc doit valoir 0x9" severity error;

        irq_0 <= '0';

        -----------------------------------------------------------------
        -- Test 2 : acquittement d'IRQ0
        -----------------------------------------------------------------
        cycle;
        assert vicpc = ADR_IRQ0
            report "T2 : vicpc doit rester a 0x9 tant qu'il n'y a pas d'acquittement" severity error;

        irq_serv <= '1';
        cycle;                      -- acquittement pris en compte
        irq_serv <= '0';

        assert irq = '0'
            report "T2 : irq doit retomber apres acquittement" severity error;
        assert vicpc = ADR_IRQ0
            report "T2 : vicpc est fige pendant irq_serv (pas de mise a jour)" severity error;

        cycle;
        assert vicpc = ADR_NULL
            report "T2 : vicpc doit revenir a 0 une fois la requete effacee" severity error;

        -----------------------------------------------------------------
        -- Test 3 : front montant sur IRQ1
        -----------------------------------------------------------------
        irq_1 <= '1';
        cycle;                      -- irq1_memo = 1
        irq_1 <= '0';

        assert irq = '1'
            report "T3 : irq doit passer a 1 sur front IRQ1" severity error;

        cycle;
        assert vicpc = ADR_IRQ1
            report "T3 : vicpc doit valoir 0x15" severity error;

        irq_serv <= '1';
        cycle;
        irq_serv <= '0';

        assert irq = '0'
            report "T3 : irq doit retomber apres acquittement d'IRQ1" severity error;

        cycle;

        -----------------------------------------------------------------
        -- Test 4 : IRQ0 et IRQ1 simultanees -> priorite puis relais
        -----------------------------------------------------------------
        irq_0 <= '1';
        irq_1 <= '1';
        cycle;                      -- les DEUX fronts doivent etre memorises
        irq_0 <= '0';
        irq_1 <= '0';

        assert irq = '1'
            report "T4 : irq doit etre a 1" severity error;

        cycle;
        assert vicpc = ADR_IRQ0
            report "T4 : IRQ0 est prioritaire, vicpc doit valoir 0x9" severity error;

        -- premier acquittement : il ne doit effacer QUE IRQ0
        irq_serv <= '1';
        cycle;
        irq_serv <= '0';

        assert irq = '1'
            report "T4 : IRQ1 ne doit PAS avoir ete effacee par l'acquittement d'IRQ0" severity error;

        cycle;
        assert vicpc = ADR_IRQ1
            report "T4 : IRQ1 doit prendre le relais, vicpc = 0x15" severity error;

        -- second acquittement : IRQ1
        irq_serv <= '1';
        cycle;
        irq_serv <= '0';

        assert irq = '0'
            report "T4 : irq doit retomber apres le second acquittement" severity error;

        cycle(2);

        -----------------------------------------------------------------
        -- Test 5 : CAS CRITIQUE
        -- nouveau front sur IRQ0 pendant l'acquittement du precedent
        -----------------------------------------------------------------
        irq_0 <= '1';
        cycle;                      -- premiere requete memorisee
        irq_0 <= '0';
        cycle;

        assert vicpc = ADR_IRQ0
            report "T5 : preparation, vicpc doit valoir 0x9" severity error;

        -- collision volontaire : irq_serv ET nouveau front sur le meme front d'horloge
        irq_serv <= '1';
        irq_0    <= '1';
        cycle;
        irq_serv <= '0';

        assert irq = '1'
            report "T5 : interruption PERDUE, le nouveau front doit primer sur l'acquittement" severity error;

        cycle;
        assert vicpc = ADR_IRQ0
            report "T5 : la nouvelle requete doit ressortir a 0x9" severity error;

        -----------------------------------------------------------------
        -- Test 6 : appui maintenu -> une seule requete
        -- (irq_0 est deja a '1' depuis le test 5, on le garde appuye)
        -----------------------------------------------------------------
        irq_serv <= '1';
        cycle;                      -- acquittement : PAS de front car irq_0 reste a 1
        irq_serv <= '0';

        assert irq = '0'
            report "T6 : irq doit retomber, irq_0 maintenu ne cree pas de nouveau front" severity error;

        cycle(4);                   -- irq_0 toujours appuye
        assert irq = '0'
            report "T6 : un appui maintenu ne doit generer qu'UNE seule requete" severity error;

        irq_0 <= '0';
        cycle(2);

        -----------------------------------------------------------------
        report "Fin de simulation : tous les tests sont passes" severity note;
        done <= true;
        wait;

    end process;

end architecture test;library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_vic is
end tb_vic;

architecture test of tb_vic is

    constant T : time := 10 ns;

    signal clk      : std_logic := '0';
    signal reset    : std_logic;
    signal irq_serv : std_logic := '0';
    signal irq_0    : std_logic := '0';
    signal irq_1    : std_logic := '0';
    signal irq      : std_logic;
    signal vicpc    : std_logic_vector(31 downto 0);
    signal done     : boolean := false;

    constant ADR_IRQ0 : std_logic_vector(31 downto 0) := x"00000009";
    constant ADR_IRQ1 : std_logic_vector(31 downto 0) := x"00000015";
    constant ADR_NULL : std_logic_vector(31 downto 0) := (others => '0');

begin

    inst : entity work.vic
        port map (
            clk      => clk,
            reset    => reset,
            irq_serv => irq_serv,
            irq_0    => irq_0,
            irq_1    => irq_1,
            irq      => irq,
            vicpc    => vicpc
        );

    clk <= '0' when done else not clk after T/2;

    -- Relache du reset a 12 ns : volontairement HORS d'un front montant
    -- (fronts a 5, 15, 25... ns) pour eviter toute course reset/horloge.
    reset <= '1', '0' after 12 ns;

    ---------------------------------------------------------------------
    -- Methodologie :
    --   * les stimuli sont appliques sur FRONT DESCENDANT
    --     -> les entrees sont stables bien avant le front montant
    --   * les verifications se font aussi sur front descendant
    --     -> on observe l'etat resultant du front montant precedent
    --   * VICPC est une sortie REGISTREE : il apparait UN CYCLE apres irq
    ---------------------------------------------------------------------

    P1 : process

        procedure cycle(n : natural := 1) is
        begin
            for i in 1 to n loop
                wait until falling_edge(clk);
            end loop;
        end procedure;

    begin

        -----------------------------------------------------------------
        -- Test 0 : etat apres reset
        -----------------------------------------------------------------
        wait until reset = '0';
        cycle;

        assert irq = '0'
            report "T0 : irq doit etre a 0 apres reset" severity error;
        assert vicpc = ADR_NULL
            report "T0 : vicpc doit etre a 0 apres reset" severity error;

        -----------------------------------------------------------------
        -- Test 1 : front montant sur IRQ0
        -----------------------------------------------------------------
        irq_0 <= '1';
        cycle;                      -- le front est capte : irq0_memo = 1

        assert irq = '1'
            report "T1 : irq doit passer a 1 sur front IRQ0" severity error;
        assert vicpc = ADR_IRQ0
            report "T1 : vicpc doit valoir 0x9 DES ce cycle (sortie combinatoire)" severity error;

        cycle;

        assert vicpc = ADR_IRQ0
            report "T1 : vicpc doit se maintenir a 0x9" severity error;

        irq_0 <= '0';

        -----------------------------------------------------------------
        -- Test 2 : acquittement d'IRQ0
        -----------------------------------------------------------------
        cycle;
        assert vicpc = ADR_IRQ0
            report "T2 : vicpc doit rester a 0x9 tant qu'il n'y a pas d'acquittement" severity error;

        irq_serv <= '1';
        cycle;                      -- acquittement pris en compte
        irq_serv <= '0';

        assert irq = '0'
            report "T2 : irq doit retomber apres acquittement" severity error;
        assert vicpc = ADR_NULL
            report "T2 : vicpc doit retomber a 0 des que la requete est effacee" severity error;

        cycle;
        assert vicpc = ADR_NULL
            report "T2 : vicpc doit rester a 0" severity error;

        -----------------------------------------------------------------
        -- Test 3 : front montant sur IRQ1
        -----------------------------------------------------------------
        irq_1 <= '1';
        cycle;                      -- irq1_memo = 1
        irq_1 <= '0';

        assert irq = '1'
            report "T3 : irq doit passer a 1 sur front IRQ1" severity error;

        cycle;
        assert vicpc = ADR_IRQ1
            report "T3 : vicpc doit valoir 0x15" severity error;

        irq_serv <= '1';
        cycle;
        irq_serv <= '0';

        assert irq = '0'
            report "T3 : irq doit retomber apres acquittement d'IRQ1" severity error;

        cycle;

        -----------------------------------------------------------------
        -- Test 4 : IRQ0 et IRQ1 simultanees -> priorite puis relais
        -----------------------------------------------------------------
        irq_0 <= '1';
        irq_1 <= '1';
        cycle;                      -- les DEUX fronts doivent etre memorises
        irq_0 <= '0';
        irq_1 <= '0';

        assert irq = '1'
            report "T4 : irq doit etre a 1" severity error;

        cycle;
        assert vicpc = ADR_IRQ0
            report "T4 : IRQ0 est prioritaire, vicpc doit valoir 0x9" severity error;

        -- premier acquittement : il ne doit effacer QUE IRQ0
        irq_serv <= '1';
        cycle;
        irq_serv <= '0';

        assert irq = '1'
            report "T4 : IRQ1 ne doit PAS avoir ete effacee par l'acquittement d'IRQ0" severity error;

        cycle;
        assert vicpc = ADR_IRQ1
            report "T4 : IRQ1 doit prendre le relais, vicpc = 0x15" severity error;

        -- second acquittement : IRQ1
        irq_serv <= '1';
        cycle;
        irq_serv <= '0';

        assert irq = '0'
            report "T4 : irq doit retomber apres le second acquittement" severity error;

        cycle(2);

        -----------------------------------------------------------------
        -- Test 5 : CAS CRITIQUE
        -- nouveau front sur IRQ0 pendant l'acquittement du precedent
        -----------------------------------------------------------------
        irq_0 <= '1';
        cycle;                      -- premiere requete memorisee
        irq_0 <= '0';
        cycle;

        assert vicpc = ADR_IRQ0
            report "T5 : preparation, vicpc doit valoir 0x9" severity error;

        -- collision volontaire : irq_serv ET nouveau front sur le meme front d'horloge
        irq_serv <= '1';
        irq_0    <= '1';
        cycle;
        irq_serv <= '0';

        assert irq = '1'
            report "T5 : interruption PERDUE, le nouveau front doit primer sur l'acquittement" severity error;

        cycle;
        assert vicpc = ADR_IRQ0
            report "T5 : la nouvelle requete doit ressortir a 0x9" severity error;

        -----------------------------------------------------------------
        -- Test 6 : appui maintenu -> une seule requete
        -- (irq_0 est deja a '1' depuis le test 5, on le garde appuye)
        -----------------------------------------------------------------
        irq_serv <= '1';
        cycle;                      -- acquittement : PAS de front car irq_0 reste a 1
        irq_serv <= '0';

        assert irq = '0'
            report "T6 : irq doit retomber, irq_0 maintenu ne cree pas de nouveau front" severity error;

        cycle(4);                   -- irq_0 toujours appuye
        assert irq = '0'
            report "T6 : un appui maintenu ne doit generer qu'UNE seule requete" severity error;

        irq_0 <= '0';
        cycle(2);

        -----------------------------------------------------------------
        report "Fin de simulation : tous les tests sont passes" severity note;
        done <= true;
        wait;

    end process;

end architecture test;