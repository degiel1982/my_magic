-- Helper function for checking if inventory is filled
local function inventory_is_filled(inv)
  return not (inv:is_empty("tool") or inv:is_empty("orb1") or inv:is_empty("orb2") or inv:is_empty("orb3") or inv:is_empty("orb4"))
end

-- Helper function to set tool wear
local function set_tool_wear(inv, slot, wear)
  local item = inv:get_stack(slot, 1)
  item:set_wear(wear)
  inv:set_stack(slot, 1, item)
end

-- Helper function for adding enchanted tools
local function add_enchanted_tool(inv, tool_name, enchanted_name, wear)
  inv:add_item("output", enchanted_name)
  local enchanted_tool = inv:get_stack("output", 1)
  enchanted_tool:set_wear(wear)
  inv:set_stack("output", 1, enchanted_tool)

  -- Remove the original tool from the inventory
  local tool = inv:get_stack("tool", 1)
  tool:take_item()
  inv:set_stack("tool", 1, tool)
end

-- Enchantment Table Node Registration
minetest.register_node("mymagic:enchantment_table", {
  description = "Enchantment Table",
  tiles = {
    {name="mymagic_enchantment_table_top_ani.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.3}},
    "mymagic_enchantment_table_bottom.png",
    {name="mymagic_enchantment_table_side_ani.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.3}},
    "mymagic_enchantment_table_side_ani.png",
    "mymagic_enchantment_table_side_ani.png",
    "mymagic_enchantment_table_side_ani.png"
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  light_source = 7,
  groups = {choppy = 2},
  node_box = {
    type = "fixed",
    fixed = {
      {-0.4375, -0.5, 0.25, -0.25, 0.125, 0.4375},
      {0.25, -0.5, 0.25, 0.4375, 0.125, 0.4375},
      {-0.4375, -0.5, -0.4375, -0.25, 0.125, -0.25},
      {0.25, -0.5, -0.4375, 0.4375, 0.125, -0.25},
      {-0.5, 0.125, -0.5, 0.5, 0.25, 0.5},
      {-0.375, -0.0625, -0.375, 0.375, 0.125, 0.375},
      {-0.4375, 0.25, 0.125, -0.375, 0.5, 0.1875},
      {0.375, 0.25, 0.125, 0.4375, 0.5, 0.1875},
      {-0.0625, 0.25, 0.375, 0, 0.5, 0.4375},
      {-0.25, 0.25, -0.375, -0.1875, 0.5, -0.3125},
      {0.1875, 0.25, -0.375, 0.25, 0.5, -0.3125}
    }
  },

  -- Meta data setup after placing node
  after_place_node = function(pos, placer)
    local meta = minetest.get_meta(pos)
    meta:set_string("infotext", "Enchantment Table")
  end,

  -- Check if the node can be dug
  can_dig = function(pos, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    return inventory_is_filled(inv)
  end,

  -- Setup inventory and UI on construct
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", "size[10,8;]" ..
      "background[-2,-2;13,12;mymagic_enchantment_table_bg.png]" ..
      "listcolors[#00000000;#00000000;#000000]" ..
      "label[1,0.5;Tool]" ..
      "label[3,0.5;Orbs]" ..
      "list[current_name;tool;1,1;1,1;]" ..
      "list[current_name;orb1;3,1;1,1;]" ..
      "list[current_name;orb2;4,1;1,1;]" ..
      "list[current_name;orb3;3,2;1,1;]" ..
      "list[current_name;orb4;4,2;1,1;]" ..
      "button[5.5,1;2,1;button;Enchant]" ..
      "list[current_name;output;6,2;1,1;]" ..
      "list[current_player;main;0.5,4;8,4;]")
    meta:set_string("infotext", "Tool Upgrade")

    local inv = meta:get_inventory()
    inv:set_size("tool", 1)
    inv:set_size("orb1", 1)
    inv:set_size("orb2", 1)
    inv:set_size("orb3", 1)
    inv:set_size("orb4", 1)
    inv:set_size("output", 1)
  end,

  -- Handle enchanting logic
  on_receive_fields = function(pos, formname, fields, sender)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    if fields["button"] then
      if not inventory_is_filled(inv) then return end

      local tool = inv:get_stack("tool", 1)
      local orba = inv:get_stack("orb1", 1)
      local orbb = inv:get_stack("orb2", 1)
      local orbc = inv:get_stack("orb3", 1)
      local orbd = inv:get_stack("orb4", 1)

local enchantment_map = {
    -- Picks
    ["default:pick_wood"] = {next = "mymagic_tools:pick_enchanted_wood_orange", color = "orange"},
    ["mymagic_tools:pick_enchanted_wood_orange"] = {next = "mymagic_tools:pick_enchanted_wood_green", color = "green"},
    ["mymagic_tools:pick_enchanted_wood_green"] = {next = "mymagic_tools:pick_enchanted_wood_blue", color = "blue"},
    ["mymagic_tools:pick_enchanted_wood_blue"] = {next = "mymagic_tools:pick_enchanted_wood_red", color = "red"},

    -- Axes
    ["default:axe_wood"] = {next = "mymagic_tools:axe_enchanted_wood_orange", color = "orange"},
    ["mymagic_tools:axe_enchanted_wood_orange"] = {next = "mymagic_tools:axe_enchanted_wood_green", color = "green"},
    ["mymagic_tools:axe_enchanted_wood_green"] = {next = "mymagic_tools:axe_enchanted_wood_blue", color = "blue"},
    ["mymagic_tools:axe_enchanted_wood_blue"] = {next = "mymagic_tools:axe_enchanted_wood_red", color = "red"},

    -- Shovels
    ["default:shovel_wood"] = {next = "mymagic_tools:shovel_enchanted_wood_orange", color = "orange"},
    ["mymagic_tools:shovel_enchanted_wood_orange"] = {next = "mymagic_tools:shovel_enchanted_wood_green", color = "green"},
    ["mymagic_tools:shovel_enchanted_wood_green"] = {next = "mymagic_tools:shovel_enchanted_wood_blue", color = "blue"},
    ["mymagic_tools:shovel_enchanted_wood_blue"] = {next = "mymagic_tools:shovel_enchanted_wood_red", color = "red"},

    -- Swords
    ["default:sword_wood"] = {next = "mymagic_tools:sword_enchanted_wood_orange", color = "orange"},
    ["mymagic_tools:sword_enchanted_wood_orange"] = {next = "mymagic_tools:sword_enchanted_wood_green", color = "green"},
    ["mymagic_tools:sword_enchanted_wood_green"] = {next = "mymagic_tools:sword_enchanted_wood_blue", color = "blue"},
    ["mymagic_tools:sword_enchanted_wood_blue"] = {next = "mymagic_tools:sword_enchanted_wood_red", color = "red"},

    -- Knives
    ["mymagic_tools:knife_wood"] = {next = "mymagic_tools:knife_enchanted_wood_orange", color = "orange"},
    ["mymagic_tools:knife_enchanted_wood_orange"] = {next = "mymagic_tools:knife_enchanted_wood_green", color = "green"},
    ["mymagic_tools:knife_enchanted_wood_green"] = {next = "mymagic_tools:knife_enchanted_wood_blue", color = "blue"},
    ["mymagic_tools:knife_enchanted_wood_blue"] = {next = "mymagic_tools:knife_enchanted_wood_red", color = "red"},

    -- Diamond Helmet
    ["3d_armor:helmet_diamond"] = {next = "mymagic_tools:diamond_helmet_orange", color = "orange"},
    ["mymagic_tools:diamond_helmet_orange"] = {next = "mymagic_tools:diamond_helmet_green", color = "green"},
    ["mymagic_tools:diamond_helmet_green"] = {next = "mymagic_tools:diamond_helmet_blue", color = "blue"},
    ["mymagic_tools:diamond_helmet_blue"] = {next = "mymagic_tools:diamond_helmet_red", color = "red"},

    -- Diamond Chestplate
    ["3d_armor:chestplate_diamond"] = {next = "mymagic_tools:diamond_chestplate_orange", color = "orange"},
    ["mymagic_tools:diamond_chestplate_orange"] = {next = "mymagic_tools:diamond_chestplate_green", color = "green"},
    ["mymagic_tools:diamond_chestplate_green"] = {next = "mymagic_tools:diamond_chestplate_blue", color = "blue"},
    ["mymagic_tools:diamond_chestplate_blue"] = {next = "mymagic_tools:diamond_chestplate_red", color = "red"},

    -- Diamond Leggings
    ["3d_armor:leggings_diamond"] = {next = "mymagic_tools:diamond_leggings_orange", color = "orange"},
    ["mymagic_tools:diamond_leggings_orange"] = {next = "mymagic_tools:diamond_leggings_green", color = "green"},
    ["mymagic_tools:diamond_leggings_green"] = {next = "mymagic_tools:diamond_leggings_blue", color = "blue"},
    ["mymagic_tools:diamond_leggings_blue"] = {next = "mymagic_tools:diamond_leggings_red", color = "red"},

    -- Diamond Boots
    ["3d_armor:boots_diamond"] = {next = "mymagic_tools:diamond_boots_orange", color = "orange"},
    ["mymagic_tools:diamond_boots_orange"] = {next = "mymagic_tools:diamond_boots_green", color = "green"},
    ["mymagic_tools:diamond_boots_green"] = {next = "mymagic_tools:diamond_boots_blue", color = "blue"},
    ["mymagic_tools:diamond_boots_blue"] = {next = "mymagic_tools:diamond_boots_red", color = "red"}
}


      local tool_name = tool:get_name()
      if enchantment_map[tool_name] and
         orba:get_name() == "mymagic:orb_" .. enchantment_map[tool_name].color and
         orbb:get_name() == "mymagic:orb_" .. enchantment_map[tool_name].color and
         orbc:get_name() == "mymagic:orb_" .. enchantment_map[tool_name].color and
         orbd:get_name() == "mymagic:orb_" .. enchantment_map[tool_name].color then
        add_enchanted_tool(inv, tool_name, enchantment_map[tool_name].next, tool:get_wear())
      end
    end
  end
})

-- Crafting Recipe
minetest.register_craft({
  output = "mymagic:enchantment_table",
  recipe = {
    {"default:torch", "mymagic:orb_red", "default:torch"},
    {"default:wood", "default:wood", "default:wood"},
    {"default:stick", "", "default:stick"}
  }
})
