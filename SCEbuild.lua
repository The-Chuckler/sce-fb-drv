#!/usr/bin/env lua

local common = require "build_tools.lua.common"

-- Build the ROM.
common.build_rom_and_handle_failure("Engine/Includes", "scecube", "", "-p=FF -z=0,kosinskiplus,Size_of_Snd_driver_guess,after", false, "https://github.com/sonicretro/skdisasm")

-- Correct the ROM's header with a proper checksum and end-of-ROM value.
common.fix_header("scecube.bin")

-- A successful build; we can quit now.
common.exit()
