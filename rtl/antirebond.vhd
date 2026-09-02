library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;




entity antirebond is
    port (
        clk: in std_logic;
        bouton_in : in std_logic;
        bouton_out : out std_logic   
    );
end entity antirebond;



architecture rtl of antirebond is
    signal etat_stable : std_logic:='1';
    signal sync_0 : std_logic:='1';
    signal sync_1 : std_logic:='1';
    signal compteur : integer range 0 to 500000-1; -- 10ms 
begin
    bouton_out <= etat_stable;
    identifier : process(clk)
    begin
        if rising_edge(clk) then
            sync_0 <= bouton_in;
            sync_1 <= sync_0;
            if (sync_1 /= etat_stable) then
                compteur <=compteur + 1;
                if compteur = 499999 then 
                    etat_stable <=sync_1;
                    compteur <=0;      
                end if;
            else
                compteur <=0; 
            end if;
        end if;
    end process ; -- identifier
    
end architecture rtl;