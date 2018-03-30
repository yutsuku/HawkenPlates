HawkenPlates - a World of Warcraft (1.12.1) AddOn
====================================

Installation:

Put "HawkenPlates" folder into ".../World of Warcraft/Interface/AddOns/".
Create AddOns folder if necessary

After Installation directory tree should look like the following

<pre>
World of Warcraft
`- Interface
   `- AddOns
      `- HawkenPlates
         |-- README.md
         |-- ShaguPlates.toc
         |-- castbar.lua
         |-- config.lua
         |-- env
         |   |-- compat.lua
         |   |-- locales_deDE.lua
         |   |-- locales_enUS.lua
         |   |-- locales_frFR.lua
         |   |-- locales_ruRU.lua
         |   |-- locales_zhCN.lua
         |   `-- shortnames.lua
         |-- fonts
         |   |-- Monda-Bold.ttf
         |   |-- Monda-Regular.ttf
         |   |-- OFL.txt
         |   `-- arial.ttf
         |-- img
         |   |-- bar.tga
         |   `-- small
         |       |-- bar.tga
         |       |-- icons_abilities_attackBoost_small.blp
         |       |-- icons_abilities_blitz_G2_small.tga
         |       |-- icons_abilities_blitz_small.tga
         |       |-- icons_abilities_camouflage_small.tga
         |       |-- icons_abilities_coolant_G2_small.tga
         |       |-- icons_abilities_coolant_small.blp
         |       |-- icons_abilities_coolant_small.tga
         |       |-- icons_abilities_damageReduction_small.blp
         |       |-- icons_abilities_damageReduction_small.tga
         |       |-- icons_abilities_fuelReplenish_small.tga
         |       |-- icons_abilities_heatWave_small.tga
         |       |-- icons_abilities_heavyExplosive_small.tga
         |       |-- icons_abilities_heavyMobile_small.blp
         |       |-- icons_abilities_heavyMobile_small.tga
         |       |-- icons_abilities_heavyRegen_small.blp
         |       |-- icons_abilities_heavyRegen_small.tga
         |       |-- icons_abilities_heavyTurret_small.tga
         |       |-- icons_abilities_powershot_small.blp
         |       |-- icons_abilities_powershot_small.tga
         |       |-- icons_abilities_precision_small.tga
         |       |-- icons_abilities_repairAmplification_small.blp
         |       |-- icons_abilities_repairAmplification_small.tga
         |       |-- icons_abilities_stalker_small.blp
         |       `-- icons_abilities_stalker_small.tga
         |-- nameplates.lua
         `-- sound
             |-- explosion
             |   |-- Explo_Death_Player_Hvt_sdlx_MONO_1a.ogg
             |   |-- Explo_Death_Player_Hvt_sdlx_MONO_1b.ogg
             |   |-- Explo_Death_Player_Lt_sdlx_MONO_1a.ogg
             |   |-- Explo_Death_Player_Lt_sdlx_MONO_1b.ogg
             |   |-- Explo_Death_Player_Med_sdlx_MONO_1a.ogg
             |   |-- Explo_Death_Player_Med_sdlx_MONO_1b.ogg
             |   |-- Grenade_Explosion_Concrete_1.ogg
             |   |-- Grenade_Explosion_Concrete_2.ogg
             |   `-- Grenade_Explosion_Concrete_3.ogg
             `-- hit
                 `-- hitConfirmation.ogg


</pre>

Features:
- [Hawken style](https://www.startpage.com/do/search?q=hawken) nameplates,
- short names,
- highlight every time unit HP drops,
- **EXPLOSION** sounds when unit dies,
- class icons are based on Hawken,
- enemy nameplate expands depending on your and enemy health (does't work properly on Kronos server).

Known Issues:
- None.

Notes:
- Heavyly based on ShaguPlates.