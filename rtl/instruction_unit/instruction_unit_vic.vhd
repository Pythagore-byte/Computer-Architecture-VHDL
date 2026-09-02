


-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

-- entity instruction_unit_vic is
--   port (
--     clk, reset  : in  std_logic;
--     nPCsel      : in  std_logic;
--     offset      : in  std_logic_vector(23 downto 0);
--     IRQ         : in  std_logic;
--     VICPC       : in  std_logic_vector(31 downto 0);
--     IRQ_END     : in  std_logic;
--     Instruction : out std_logic_vector(31 downto 0);
--     IRQ_SERV    : out std_logic;
--     PC : out std_logic_vector(31 downto 0)
--   );
-- end instruction_unit_vic;

-- architecture structural of instruction_unit_vic is

--     signal pc_in, pc_out       : std_logic_vector(31 downto 0);
--     signal out_sign_extend     : std_logic_vector(31 downto 0);
--     signal LR                  : std_logic_vector(31 downto 0);
--     signal prise_en_compte     : std_logic;

-- begin
--     PC <= pc_out;

--     instruction_memory_irq : entity work.instruction_memory_irq
--         port map(pc_out, Instruction);

--     pc_reg : entity work.pc_reg
--         port map(clk, reset, pc_in, pc_out);

--     sign_extend : entity work.sign_extend
--         generic map(24)
--         port map(offset, out_sign_extend);

--     ---------------------------------------------------------------------
--     -- Condition unique de prise en compte d'une interruption.
--     -- Definie UNE SEULE FOIS et utilisee par P1, P2 et IRQ_SERV :
--     -- impossible de desynchroniser le chargement de PC et celui de LR.
--     --
--     -- IRQ_END est prioritaire sur IRQ : si une nouvelle interruption est
--     -- en attente pendant l'execution du BX, on termine d'abord le retour
--     -- au programme principal. Sinon LR serait ecrase par l'adresse du BX
--     -- et l'adresse de retour du programme principal serait perdue.
--     ---------------------------------------------------------------------
--     -- prise_en_compte <= '1' when (IRQ = '1' and IRQ_END = '0') else '0';
--     prise_en_compte <= '1' when (IRQ = '1' and IRQ_END = '0' and nPCsel = '0') else '0';

--     -- Acquittement : impulsion d'un seul cycle, comme l'exige le VIC
--     IRQ_SERV <= prise_en_compte;

--     ---------------------------------------------------------------------
--     -- P1 : selection combinatoire de la prochaine valeur du PC
--     ---------------------------------------------------------------------
--     P1 : process(prise_en_compte, IRQ_END, nPCsel, VICPC, LR,
--                  pc_out, out_sign_extend)
--     begin
--         if prise_en_compte = '1' then
--             pc_in <= VICPC;                                  -- entree en IT

--         elsif IRQ_END = '1' then
--             pc_in <= std_logic_vector(signed(LR) + 1);       -- retour de IT

--         elsif nPCsel = '1' then                              -- branchement
--             pc_in <= std_logic_vector(signed(pc_out)
--                                     + signed(out_sign_extend) + 1);
--         else
--             pc_in <= std_logic_vector(signed(pc_out) + 1);   -- cas normal
--         end if;
--     end process;

--     ---------------------------------------------------------------------
--     -- P2 : registre LR, ecrit uniquement a la prise en compte
--     ---------------------------------------------------------------------
--     P2 : process(clk, reset)
--     begin
--         if reset = '1' then
--             LR <= (others => '0');
--         elsif rising_edge(clk) then
--             if prise_en_compte = '1' then
--                 LR <= pc_out;
--             end if;
--         end if;
--     end process;

-- end architecture structural;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instruction_unit_vic is
  port (
    clk, reset  : in  std_logic;
    nPCsel      : in  std_logic;
    offset      : in  std_logic_vector(23 downto 0);
    IRQ         : in  std_logic;
    VICPC       : in  std_logic_vector(31 downto 0);
    IRQ_END     : in  std_logic;
    Instruction : out std_logic_vector(31 downto 0);
    IRQ_SERV    : out std_logic;
    PC          : out std_logic_vector(31 downto 0)
  );
end instruction_unit_vic;

architecture structural of instruction_unit_vic is

    signal pc_in, pc_out    : std_logic_vector(31 downto 0);
    signal out_sign_extend  : std_logic_vector(31 downto 0);
    signal LR               : std_logic_vector(31 downto 0);
    signal prise_en_compte  : std_logic;
    signal en_interruption  : std_logic;

begin

    instruction_memory_irq : entity work.instruction_memory_irq
        port map(pc_out, Instruction);

    pc_reg : entity work.pc_reg
        port map(clk, reset, pc_in, pc_out);

    sign_extend : entity work.sign_extend
        generic map(24)
        port map(offset, out_sign_extend);

    PC <= pc_out;

    ---------------------------------------------------------------------
    -- Condition unique de prise en compte d'une interruption.
    -- Definie UNE SEULE FOIS et utilisee par P1, P2, P3 et IRQ_SERV :
    -- impossible de desynchroniser le PC, le LR et l'acquittement.
    --
    -- Quatre conditions, chacune pour une raison precise :
    --
    --  IRQ = '1'              il y a une demande
    --
    --  IRQ_END = '0'          on ne deroute pas pendant l'execution du BX.
    --                         Sinon LR recevrait l'adresse du BX et
    --                         l'adresse de retour vers le programme
    --                         principal serait perdue.
    --
    --  nPCsel = '0'           on ne deroute pas pendant un branchement.
    --                         Le branchement serait annule, et le retour
    --                         a LR+1 ramenerait sur l'instruction de
    --                         branchement elle-meme -> boucle infinie.
    --
    --  en_interruption = '0'  on ne deroute pas si on est deja dans une
    --                         routine. Sinon LR recevrait une adresse
    --                         situee DANS la routine, et le BX y
    --                         reviendrait indefiniment.
    --
    -- Dans tous les cas bloques, le VIC n'est PAS acquitte : il conserve
    -- sa demande, qui sera servie des que la condition se libere.
    ---------------------------------------------------------------------
    prise_en_compte <= '1' when (IRQ             = '1'
                            and  IRQ_END         = '0'
                            and  nPCsel          = '0'
                            and  en_interruption = '0') else '0';

    -- Acquittement : impulsion d'un seul cycle, comme l'exige le VIC
    IRQ_SERV <= prise_en_compte;

    ---------------------------------------------------------------------
    -- P1 : selection combinatoire de la prochaine valeur du PC
    ---------------------------------------------------------------------
    P1 : process(prise_en_compte, IRQ_END, nPCsel, VICPC, LR,
                 pc_out, out_sign_extend)
    begin
        if prise_en_compte = '1' then
            pc_in <= VICPC;                                  -- entree en IT

        elsif IRQ_END = '1' then
            pc_in <= std_logic_vector(signed(LR) + 1);       -- retour de IT

        elsif nPCsel = '1' then                              -- branchement
            pc_in <= std_logic_vector(signed(pc_out)
                                    + signed(out_sign_extend) + 1);
        else
            pc_in <= std_logic_vector(signed(pc_out) + 1);   -- cas normal
        end if;
    end process;

    ---------------------------------------------------------------------
    -- P2 : registre LR, ecrit uniquement a la prise en compte
    ---------------------------------------------------------------------
    P2 : process(clk, reset)
    begin
        if reset = '1' then
            LR <= (others => '0');
        elsif rising_edge(clk) then
            if prise_en_compte = '1' then
                LR <= pc_out;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------
    -- P3 : drapeau "je suis dans une routine d'interruption"
    --
    -- Les deux conditions sont mutuellement exclusives : quand
    -- IRQ_END vaut '1', prise_en_compte vaut forcement '0' puisque
    -- IRQ_END fait partie de sa definition. L'ordre du if/elsif est
    -- donc sans importance ici.
    ---------------------------------------------------------------------
    P3 : process(clk, reset)
    begin
        if reset = '1' then
            en_interruption <= '0';
        elsif rising_edge(clk) then
            if prise_en_compte = '1' then
                en_interruption <= '1';
            elsif IRQ_END = '1' then
                en_interruption <= '0';
            end if;
        end if;
    end process;

end architecture structural;