--------------------------------------------------------------------------------
-- Magic Blocks (require enchanted tool to punch)
--------------------------------------------------------------------------------
local magicBlocks = {
    {"Orange", "orange", "sword", {magic_sword = 4}},
    {"Green",  "green",  "sword", {magic_sword = 3}},
    {"Blue",   "blue",   "sword", {magic_sword = 2}},
    {"Red",    "red",    "sword", {magic_sword = 1}},
    {"Orange", "orange", "axe",   {magic_axe = 4}},
    {"Green",  "green",  "axe",   {magic_axe = 3}},
    {"Blue",   "blue",   "axe",   {magic_axe = 2}},
    {"Red",    "red",    "axe",   {magic_axe = 1}},
}
for _, b in ipairs(magicBlocks) do
    local desc, col, tool, groups = unpack(b)
    minetest.register_node("mymagic:block_"..col..tool, {
        description = desc.." Magic block - "..tool,
        tiles = {"mymagic_block_"..tool.."_"..col..".png"},
        paramtype = "light", drop = "", groups = groups,
        on_punch = function(pos, node, puncher)
            minetest.chat_send_player(puncher:get_player_name(),
                "You need an enchanted "..col.." "..tool.." to break this block")
        end,
    })
end

--------------------------------------------------------------------------------
-- Particle Effect for destruction (spawns magic particles)
--------------------------------------------------------------------------------
local function spawnParticles(pos)
    minetest.add_particlespawner(40, 1, pos, pos,
        {x=-5,y=-5,z=-5}, {x=5,y=5,z=5},
        {x=-2,y=-2,z=-2}, {x=2,y=2,z=2},
        0.2,2,0.2,3, false, "mymagic_magic_parti.png")
end

--------------------------------------------------------------------------------
-- Magic Item Blocks (drop items and spawn particles on destruct)
--------------------------------------------------------------------------------
local magicItems = {
    {"default:sword_diamond", "sword", "Sword Block"},
    {"default:pick_diamond",  "pick",  "Pick Block"},
    {"default:axe_diamond",   "axe",   "Axe Block"},
}
for _, itm in ipairs(magicItems) do
    local itemId, idName, descr = unpack(itm)
    minetest.register_node("mymagic:"..idName.."_block", {
        description = descr,
        tiles = {"mymagic_block_"..idName..".png"},
        drawtype = "nodebox", paramtype = "light", drop = "", light_source = 12,
        groups = {magic_sword = 1, cracky = 3},
        node_box = { type = "fixed", fixed = {
            {-0.5,-0.5, 0.3125, -0.3125,0.5,0.5},
            {-0.5,-0.5,-0.5,   -0.3125,0.5,-0.3125},
            { 0.3125,-0.5,-0.5,  0.5,0.5,-0.3125},
            { 0.3125,-0.5, 0.3125, 0.5,0.5,0.5},
            { 0.3125,-0.5,-0.3125, 0.5,-0.3125,0.3125},
            {-0.5,-0.5,-0.3125, -0.3125,-0.3125,0.3125},
            {-0.5,0.3125,-0.3125,-0.3125,0.5,0.3125},
            { 0.3125,0.3125,-0.3125, 0.5,0.5,0.3125},
            {-0.3125,0.3125, 0.3125, 0.3125,0.5,0.5},
            {-0.3125,0.3125,-0.5,   0.3125,0.5,-0.3125},
            {-0.3125,-0.5,-0.5,    0.3125,-0.3125,-0.3125},
            {-0.3125,-0.5, 0.3125,  0.3125,-0.3125,0.5},
            {-0.3125,-0.3125,-0.3125,0.3125,0.3125,0.3125},
        }},
        on_destruct = function(pos)
            minetest.spawn_item(pos, itemId)
            spawnParticles(pos)
        end,
    })
end

--------------------------------------------------------------------------------
-- Colored Energy Blocks with crafting recipes
--------------------------------------------------------------------------------
local shovelMap = { red = 1, blue = 2, green = 3, orange = 4 }
local energyColors = {
    {"red",    {r=255, g=0,   b=0,   a=200}},
    {"green",  {r=0,   g=255, b=0,   a=200}},
    {"blue",   {r=0,   g=150, b=180, a=200}},
    {"orange", {r=200, g=150, b=0,   a=200}},
}
for _, ec in ipairs(energyColors) do
    local col, rgb = ec[1], ec[2]
    minetest.register_node("mymagic:colored_energy_"..col, {
        description = "Energy Block",
        tiles = {{name="mymagic_teleport_ani_"..col..".png",
                 animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=0.5}}},
        drawtype = "glasslike", post_effect_color = rgb, drop = "", light_source = 14, walkable = false,
        groups = {cracky = 1, magic_shovel = shovelMap[col] or 0},
    })
    minetest.register_craft({
        output = "mymagic:colored_energy_"..col,
        recipe = {
            {"mymagic:orb_"..col, "mymagic:orb_"..col, ""},
            {"mymagic:orb_"..col, "mymagic:orb_"..col, ""},
            {"", "", ""},
        },
    })
end

--------------------------------------------------------------------------------
-- Fake Teleport Blocks (hidden from creative inventory)
--------------------------------------------------------------------------------
for _, h in ipairs({"hole1", "hole2"}) do
    minetest.register_node("mymagic:"..h, {
        description = "FakeTeleport Block",
        tiles = {"mymagic_hole_in_floor.png", "mymagic_floor.png", "mymagic_floor.png",
                 "mymagic_floor.png", "mymagic_floor.png", "mymagic_floor.png"},
        paramtype = "light", drop = "", groups = {magic_shovel = 1, not_in_creative_inventory = 1},
    })
end
