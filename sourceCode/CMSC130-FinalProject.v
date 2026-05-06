library ieee;
use ieee.std_logic_1164.all;

entity locker_system is
    port (
        -- Inputs
        sw_owner     : in  std_logic;
        sw_sig_other : in  std_logic;
        sw_parents   : in  std_logic;
        sw_siblings  : in  std_logic;
        sw_pet       : in  std_logic;
        sw_others    : in  std_logic;

        -- Outputs
        open_A      : out std_logic;
        open_B      : out std_logic;
        open_C      : out std_logic;
        led_denied  : out std_logic
    );
end entity;

architecture rtl of locker_system is

    signal access_A   : std_logic;
    signal access_B   : std_logic;
    signal access_C   : std_logic;

    signal switch_sum : integer range 0 to 6;
    signal multi_lock : std_logic;

begin


    -- COUNT ACTIVE SWITCHES
    process(sw_owner, sw_sig_other, sw_parents,
            sw_siblings, sw_pet, sw_others)
        variable sum : integer range 0 to 6;
    begin
        sum := 0;

        if sw_owner = '1' then sum := sum + 1; end if;
        if sw_sig_other = '1' then sum := sum + 1; end if;
        if sw_parents = '1' then sum := sum + 1; end if;
        if sw_siblings = '1' then sum := sum + 1; end if;
        if sw_pet = '1' then sum := sum + 1; end if;
        if sw_others = '1' then sum := sum + 1; end if;

        switch_sum <= sum;
    end process;


    -- LOCKOUT CONDITION

    multi_lock <= '1' when switch_sum > 1 else '0';

    -- ACCESS LOGIC

    access_A <= (sw_owner OR sw_sig_other OR sw_siblings OR sw_pet)
                AND NOT (sw_parents OR sw_others)
                AND NOT multi_lock;

    access_B <= (sw_owner OR sw_parents OR sw_pet)
                AND NOT (sw_sig_other OR sw_siblings)
                AND NOT multi_lock;

    access_C <= (sw_owner OR sw_siblings)
                AND NOT (sw_sig_other OR sw_parents OR sw_pet)
                AND NOT multi_lock;

    -- OUTPUTS
    open_A <= access_A;
    open_B <= access_B;
    open_C <= access_C;

    led_denied <= NOT (access_A OR access_B OR access_C);

end architecture;