-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;


-- entity datapath_uart is
--   port (
--     clk , reset : in std_logic;

--     ALUSrc        : in std_logic;
--     WrSrc        : in std_logic;
--     MemWr        : in std_logic;
--     Imm         : in std_logic_vector(7 downto 0);
--     ALUCtr        : in std_logic_vector(2 downto 0);
--     Rd          : in std_logic_vector(3 downto 0);
--     Rn          : in std_logic_vector(3 downto 0);
--     Rm          : in std_logic_vector(3 downto 0);
--     RegWr       : in std_logic;
--     RegSel      : in std_logic;
--     bus_B_out   : out std_logic_vector(31 downto 0);
--     R2_dbg      : out std_logic_vector(31 downto 0);
    
--     -- Nouveau port pour sortir l'adresse/résultat de l'ALU
--     AluResult   : out std_logic_vector(31 downto 0); 
    
--     N,Z,C,V     : out std_logic
--   );
-- end datapath_uart;

-- architecture structural of datapath_uart  is
--     signal busA , busB , busW  : std_logic_vector(31 downto 0);
--     signal out_imm : std_logic_vector(31 downto 0);
--     signal data_out_memory: std_logic_vector(31 downto 0);
--     signal AlUout : std_logic_vector(31 downto 0);
--     signal mux1_out : std_logic_vector(31 downto 0);
--     signal Rb: std_logic_vector(3 downto 0);
-- begin
--     bus_B_out <= busB;
--     AluResult <= AlUout; -- On expose le résultat de l'ALU vers l'extérieur

--     mux: entity work.mux2to1 generic map(4) port map(Rm, Rd, RegSel, Rb);
--     banc_registre : entity work.register_file port map(clk, reset, RegWr, Rn, Rb, Rd, busW, busA, busB, R2_dbg);
--     sign_ext: entity work.sign_extend generic map(8) port map (Imm, out_imm);
--     mux1: entity work.mux2to1 port map(busB, out_imm, ALUSrc, mux1_out);
--     alu : entity work.alu port map(ALUCtr, busA, mux1_out, AlUout, N, Z, C, V);
--     data_memory: entity work.data_memory port map(clk, reset, MemWr, AlUout(5 downto 0), busB, data_out_memory);
--     mux2: entity work.mux2to1 port map(AlUout, data_out_memory, WrSrc, busW);
-- end architecture;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity datapath_uart is
  port (
    clk , reset : in std_logic;

    ALUSrc      : in std_logic;
    WrSrc       : in std_logic;
    MemWr       : in std_logic;
    Imm         : in std_logic_vector(7 downto 0);
    ALUCtr      : in std_logic_vector(2 downto 0);
    Rd          : in std_logic_vector(3 downto 0);
    Rn          : in std_logic_vector(3 downto 0);
    Rm          : in std_logic_vector(3 downto 0);
    RegWr       : in std_logic;
    RegSel      : in std_logic;
    bus_B_out   : out std_logic_vector(31 downto 0);
    R2_dbg      : out std_logic_vector(31 downto 0);

    -- Sortie de l'ALU, utilisee comme adresse memoire ET pour decider
    -- si l'ecriture vise la RAM ou un peripherique mappe (ex: UART=0x40)
    AluResult   : out std_logic_vector(31 downto 0);

    N,Z,C,V     : out std_logic
  );
end datapath_uart;

architecture structural of datapath_uart  is
    signal busA , busB , busW  : std_logic_vector(31 downto 0);
    signal out_imm : std_logic_vector(31 downto 0);
    signal data_out_memory: std_logic_vector(31 downto 0);
    signal AlUout : std_logic_vector(31 downto 0);
    signal mux1_out : std_logic_vector(31 downto 0);
    signal Rb: std_logic_vector(3 downto 0);

    ---------------------------------------------------------------------
    -- Decodeur d'adresses minimal : une adresse ne peut pas etre a la
    -- fois une case de RAM et un peripherique. Sans ce signal, MemWr
    -- ecrivait dans data_memory a CHAQUE ecriture, y compris vers
    -- l'UART (0x40), silencieusement, dans la case 0 (car
    -- AluResult(5 downto 0) de 0x40 vaut "000000").
    ---------------------------------------------------------------------
    signal wen_ram : std_logic;

begin
    bus_B_out <= busB;
    AluResult <= AlUout;

    -- L'ecriture en RAM est desarmee des que l'adresse cible l'UART.
    -- Etendre a d'autres peripheriques : ajouter une condition "and"
    -- pour chaque nouvelle adresse reservee.
    wen_ram <= MemWr when AlUout /= x"00000040" else '0';

    mux: entity work.mux2to1 generic map(4) port map(Rm, Rd, RegSel, Rb);
    banc_registre : entity work.register_file port map(clk, reset, RegWr, Rn, Rb, Rd, busW, busA, busB, R2_dbg);
    sign_ext: entity work.sign_extend generic map(8) port map (Imm, out_imm);
    mux1: entity work.mux2to1 port map(busB, out_imm, ALUSrc, mux1_out);
    alu : entity work.alu port map(ALUCtr, busA, mux1_out, AlUout, N, Z, C, V);

    -- MODIFIE : wen_ram au lieu de MemWr
    data_memory: entity work.data_memory port map(clk, reset, wen_ram, AlUout(5 downto 0), busB, data_out_memory);

    mux2: entity work.mux2to1 port map(AlUout, data_out_memory, WrSrc, busW);
end architecture;