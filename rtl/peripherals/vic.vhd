
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vic is
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    irq_serv : in  std_logic;
    irq_0    : in  std_logic;
    irq_1    : in  std_logic;
    irq      : out std_logic;
    vicpc    : out std_logic_vector(31 downto 0)
  );
end vic;

architecture rtl of vic is
    signal irq0_memo,  irq1_memo  : std_logic;
    signal irq0_avant, irq1_avant : std_logic;
begin

    irq <= irq0_memo or irq1_memo;

    -- VICPC est desormais COMBINATOIRE : il suit immediatement les memos,
    -- donc il est valide dans le meme cycle que irq.
    -- (avant, il etait registre et arrivait un cycle trop tard)
    vicpc <= x"00000009" when irq0_memo = '1' else
             x"00000015" when irq1_memo = '1' else
             (others => '0');

    P1 : process(clk, reset)
    begin
        if reset = '1' then
            irq0_memo  <= '0';
            irq1_memo  <= '0';
            irq0_avant <= '0';
            irq1_avant <= '0';

        elsif rising_edge(clk) then

            irq0_avant <= irq_0;
            irq1_avant <= irq_1;

            -- acquittement : une seule requete, la prioritaire
            if irq_serv = '1' then
                if irq0_memo = '1' then
                    irq0_memo <= '0';
                elsif irq1_memo = '1' then
                    irq1_memo <= '0';
                end if;
            end if;

            -- detection de front : placee EN DERNIER, elle a donc le dernier
            -- mot en cas de collision avec un acquittement
            if irq_0 = '1' and irq0_avant = '0' then
                irq0_memo <= '1';
            end if;

            if irq_1 = '1' and irq1_avant = '0' then
                irq1_memo <= '1';
            end if;

        end if;
    end process;

end architecture rtl;