-- ============================================================================
--  Title       : Fizz Buzz generator
--
--  File Name   : FIZZ_BUZZ.vhd
--  Project     : Sample
--  Block       : 
--  Tree        : 
--  Designer    : toms74209200 <https://github.com/toms74209200>
--  Created     : 2019/02/13
--  Copyright   : 2019 toms74209200
--  License     : MIT License.
--                http://opensource.org/licenses/mit-license.php
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity FIZZ_BUZZ is
    port(
    -- System --
        RESET_n         : in    std_logic;                          --(n) Reset
        CLK             : in    std_logic;                          --(p) Clock

    -- Control --
        SINK_READY      : out   std_logic;                          --(p) Sink data ready
        SINK_VALID      : in    std_logic;                          --(p) Sink data valid
        SINK_DATA       : in    std_logic_vector(31 downto 0);      --(p) Sink data(Max Fizz Buzz count)
        SOURCE_VALID    : out   std_logic;                          --(p) Source data valid
        SOURCE_DATA     : out   std_logic_vector(31 downto 0);      --(p) Source data
        SOURCE_FIZZBUZZ : out   std_logic_vector(2 downto 0)        --(p) Source Fizz Buzz selector(2:FizzBuzz,1:Buzz,0:Fizz)
        );
end FIZZ_BUZZ;

architecture RTL of FIZZ_BUZZ is

-- Parameter --
constant FixedNum1d3    : std_logic_vector(SOURCE_DATA'range) := X"5555_5555";  -- 1/3 fixed point representation(Q32)
constant FixedNum1d5    : std_logic_vector(SOURCE_DATA'range) := X"3333_3333";  -- 1/5 fixed point representation(Q32)

-- Internal signals --
signal cnt              : std_logic_vector(SINK_DATA'range);            -- Fizz Buzz counter
signal cnt_max          : std_logic_vector(cnt'range);                  -- Fizz Buzz count max
signal done_i           : std_logic;                                    -- Fizz Buzz end
signal busy_i           : std_logic;                                    -- Fizz Buzz busy
signal cnt_lt           : std_logic_vector(cnt'range);                  -- Count latch
signal source_valid_i   : std_logic;                                    -- Source data valid
signal product_3i       : std_logic_vector(cnt'length*2-1 downto 0);    -- Multiple product 1/3
signal product_5i       : std_logic_vector(cnt'length*2-1 downto 0);    -- Multiple product 1/5
signal fizz_buzz_i      : std_logic_vector(SOURCE_FIZZBUZZ'range);      -- Source Fizz Buzz selector

begin
--
-- ============================================================================
--  Fizz Buzz count max input
-- ============================================================================
process (CLK, RESET_n) begin
    if (RESET_n = '0') then
        cnt_max <= (others => '0');
    elsif (CLK'event and CLK = '1') then
        if (busy_i = '1') then
            cnt_max <= cnt_max;
        elsif (SINK_VALID = '1') then
            cnt_max <= SINK_DATA;
        end if;
    end if;
end process;


-- ============================================================================
--  Fizz Buzz end
-- ============================================================================
done_i <= '1' when (busy_i = '1' and cnt = cnt_max) else
          '0';


-- ============================================================================
--  Fizz Buzz count busy
-- ============================================================================
process (CLK, RESET_n) begin
    if (RESET_n = '0') then
        busy_i <= '0';
    elsif (CLK'event and CLK = '1') then
        if (done_i = '1') then
            busy_i <= '0';
        elsif (SINK_VALID = '1') then
            busy_i <= '1';
        end if;
    end if;
end process;

SINK_READY <= not busy_i;


-- ============================================================================
--  Fizz Buzz count
-- ============================================================================
process (CLK, RESET_n) begin
    if (RESET_n = '0') then
        cnt <= (others => '0');
    elsif (CLK'event and CLK = '1') then
        if (busy_i = '1') then
            if (done_i = '1') then
                cnt <= cnt;
            else
                cnt <= cnt + 1;
            end if;
        elsif (SINK_VALID = '1') then
            cnt <= cnt + 1;
        end if;
    end if;
end process;


-- ============================================================================
--  Fizz Buzz count latch
-- ============================================================================
process (CLK, RESET_n) begin
    if (RESET_n = '0') then
        cnt_lt <= (others => '0');
    elsif (CLK'event and CLK = '1') then
        cnt_lt <= cnt;
    end if;
end process;

SOURCE_DATA <= cnt_lt;


-- ============================================================================
--  Data valid assert
-- ============================================================================
process (CLK, RESET_n) begin
    if (RESET_n = '0') then
        source_valid_i <= '0';
    elsif (CLK'event and CLK = '1') then
        source_valid_i <= busy_i;
    end if;
end process;

SOURCE_VALID <= source_valid_i;


-- ============================================================================
--  Multiplier
-- ============================================================================
process (CLK, RESET_n) begin
    if (RESET_n = '0') then
        product_3i <= (others => '0');
        product_5i <= (others => '0');
    elsif (CLK'event and CLK = '1') then
        if (busy_i = '1') then
            product_3i <= cnt * FixedNum1d3;
            product_5i <= cnt * FixedNum1d5;
        elsif (SINK_VALID = '1') then
            product_3i <= (others => '0');
            product_5i <= (others => '0');
        end if;
    end if;
end process;


-- ============================================================================
--  Fizz Buzz selector
-- ============================================================================
fizz_buzz_i <= "100" when (product_3i(cnt'left downto cnt'left-15) = X"FFFF" and product_5i(cnt'left downto cnt'left-15) = X"FFFF") else
               "010" when (product_5i(cnt'left downto cnt'left-15) = X"FFFF") else
               "001" when (product_3i(cnt'left downto cnt'left-15) = X"FFFF") else
               (others => '0');

SOURCE_FIZZBUZZ <= fizz_buzz_i;


end RTL;    -- FIZZ_BUZZ
