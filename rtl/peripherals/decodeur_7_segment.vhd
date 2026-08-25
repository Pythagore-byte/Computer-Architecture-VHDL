library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity decodeur_7_segment is
  port (
    data : in std_logic_vector(3 downto 0);
    sevenseg : out std_logic_vector(6 downto 0)
  ) ;
end decodeur_7_segment;


architecture behavior of decodeur_7_segment is
    signal sevs: std_logic_vector(6 downto 0);
begin

    -- Affectation continue de la sortie
    sevenseg <= sevs;

    P1 : process(data)
    begin
        case(data) is
             -- Logique Anode Commune (0 = allumé, 1 = éteint)
            -- Ordre exact des bits : "gfedcba" (Le bit 'a' est tout à droite)
            when "0000" => sevs <= "1000000"; -- 0 (Seul 'g' est éteint)
            when "0001" => sevs <= "1111001"; -- 1 (Seuls 'b' et 'c' sont allumés)
            when "0010" => sevs <= "0100100"; -- 2
            when "0011" => sevs <= "0110000"; -- 3
            when "0100" => sevs <= "0011001"; -- 4
            when "0101" => sevs <= "0010010"; -- 5
            when "0110" => sevs <= "0000010"; -- 6
            when "0111" => sevs <= "1111000"; -- 7
            when "1000" => sevs <= "0000000"; -- 8 (Tous allumés)
            when "1001" => sevs <= "0010000"; -- 9
            when "1010" => sevs <= "0001000"; -- A
            when "1011" => sevs <= "0000011"; -- b
            when "1100" => sevs <= "1000110"; -- C
            when "1101" => sevs <= "0100001"; -- d
            when "1110" => sevs <= "0000110"; -- E
            when "1111" => sevs <= "0001110"; -- F
            when others => sevs <= "1111111"; -- Tout éteint par sécurité
        end case;
    end process;

end architecture;