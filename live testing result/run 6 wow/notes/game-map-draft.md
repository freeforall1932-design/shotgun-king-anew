# Draft game map — generated from `log.txt`

> Generated 2026-10-06 15:00 by `tools/parse_log.py`. **Draft**: everything here comes from the diagnostics mod's live log; promote confirmed facts into `notes/map.md` by hand.

## 1. Did the mod load?

- ✅ mod loaded — build 7, mod_index 1
- ✅ found itself in MODLIST; active=True
- ✅ READY line: build 7, 31 hooks registered, 920 globals visible
- ✅ probe blocks completed: `cards`, `exclude`, `souls`, `bank`, `input`

## 2. API availability (planned functions)

- available (76): `_log`, `concat`, `add`, `del`, `all`, `get_slot_cards`, `gsq`, `mk_menu_but`, `mk_text_but`, `mk_but`, `init_menu`, `spawn_pieces`, `new_piece`, `setup_piece`, `new_turn`, `new_level`, `add_card`, `new_card`, `CARDS`, `EXCLUDE`, `PIECES`, `get_disp_stats`, `draw_mode`, `goto_sq`, `get_range`, `throw_grenade`, `spend_hop`, `uplift`, `check_cards_auto_flip`, `flip_card`, `unflip_card`, `set_mode`, `init_game`, `init_codex`, `opp_turn`, `wait`, `inc_ammo`, `give_ammo`, `reload`, `pick`, `add_any_card`, `level_up`, `is_card_available`, `newbnk`, `bget`, `bset`, `defbtn`, `btn`, `btnp`, `btnr`, `fire`, `mk_bullet`, `hit`, `ev_hit`, `xpl`, `add_soul`, `activate_soul`, `add_soul_slot`, `add_scepter`, `activate_scepter`, `recal_scepters`, `TEST_SOULS`, `MOUSE`, `remove_buts`, `get_allies`, `get_free_squares`, `get_nearest_free_square`, `black_mist_check`, `get_dodge`, `refill_ammo`, `can_reload`, `need_reload`, `clip`, `is_free`, `flr`, `t`
- **not found** (8): `append`, `prepend`, `gimme`, `savbnk`, `scepters`, `chamber`, `stack`, `hero`
- Not found = not in `gimme("global")`: either the name is wrong or it is engine-internal. Adjust plans before coding against those.

## 3. Hooks & event dispatch

Registered (append) hooks:
- `new_turn` (id `sk-rework:turn`)
- `new_level` (id `sk-rework:level`)
- `setup_piece` (id `sk-rework:setup_piece`)
- `add_card` (id `sk-rework:add_card`)
- `init_game` (id `sk-rework:init_game`)
- `hit` (id `sk-rework:god-mode-hit`)
- `level_up` (id `sk-rework:offer-level-up`)
- `pick` (id `sk-rework:offer-pick`)
- `is_card_available` (id `sk-rework:offer-availability`)
- `add_soul` (id `sk-rework:add_soul`)
- `activate_soul` (id `sk-rework:activate_soul`)
- `add_soul_slot` (id `sk-rework:add_soul_slot`)
- `remove_soul_slot` (id `sk-rework:remove_soul_slot`)
- `exhaust_soul` (id `sk-rework:exhaust_soul`)
- `add_scepter` (id `sk-rework:add_scepter`)
- `activate_scepter` (id `sk-rework:activate_scepter`)
- `recal_scepters` (id `sk-rework:recal_scepters`)
- `get_scepter` (id `sk-rework:get_scepter`)
- `fire` (id `sk-rework:damage-fire`)
- `mk_bullet` (id `sk-rework:damage-config`)
- `mk_bullet` (id `sk-rework:damage-mk_bullet`)
- `ev_hit` (id `sk-rework:damage-ev_hit`)
- `fx_dmg` (id `sk-rework:damage-fx_dmg`)
- `bleed_dmg` (id `sk-rework:damage-bleed_dmg`)
- `xpl` (id `sk-rework:damage-xpl`)
- `xpl_king` (id `sk-rework:damage-xpl_king`)
- `init_menu` (id `sk-rework:menu-state`)
- `init_menu` (id `sk-rework:menu-clear`)
- `mk_menu_but` (id `sk-rework:menu-button-before`)
- `add` (id `sk-rework:menu-button-fields`)
- `mk_menu_but` (id `sk-rework:mod-menu-ui`)

| event | via append() hook | via on_* callback probe |
|---|---|---|
| init_game | 3 | — |
| new_level | 3 | — |
| setup_piece | 50 (sampled: 31 lines) | — |

- **Verdict:** append() hooks fire, `on_*` probes do not → for plain mods, events must be hooked with `append()` on game globals (the `on_*` dispatch comes from the Glacies Module Terminal mod, matching what the workshop mods show).

## 4. Live state samples

| turn | bads | bullets | hero_px | hero_py | ammo | chamber | free_souls |
|---|---|---|---|---|---|---|---|
| 1 | 7 | 0 | 4 | 7 | 5 | 1 | 0 |
| 2 | 7 | 0 | 5 | 7 | 5 | 1 | 0 |
| 3 | 7 | 0 | 5 | 6 | 5 | 1 | 0 |
| 4 | 7 | 0 | 5 | 6 | 5 | 0 | 0 |
| 5 | 7 | 0 | 3 | 7 | 5 | 1 | 0 |
| 6 | 12 | 0 | 3 | 7 | 6 | 1 | 0 |

## 5. Object model (real field names from the running game)

- **piece**: `t=0`, `x=128`, `y=30`, `dcx=0`, `dcy=0`, `vy=0`, `frict=1`, `vx=0`, `cd=0`, `hp=3`, `dp=3`, `ww=16`, `hh=16`, `flx=false`, `hdy=1`, `we=0`, `truncated=true`, `fields_shown=16`, `dr=fn`, `upd=fn`
- **hero**: `sweaty=false`, `t=92`, `x=160`, `y=142`, `dcx=0`, `dcy=0`, `jail=false`, `index=5`, `seek=wdist`, `vy=0`, `frict=1`, `dr=fn`, `fr=-1`, `vx=0`, `cd=0`, `hp=8`, `truncated=true`, `fields_shown=16`
- **hero.sq**: `gdist=99`, `t=379`, `risk=0`, `x=160`, `p=tbl`, `p.sweaty=false`, `p.t=92`, `p.x=160`, `p.y=142`, `p.dcx=0`, `p.dcy=0`, `p.jail=false`, `p.index=5`, `p.seek=wdist`, `p.vy=0`, `p.frict=1`, `p.dr=fn`, `p.truncated=true`, `dcx=0`, `dcy=0`
- **stack**: `firepower=4`, `grenades_max=1`, `soul_slot=1`, `chamber_max=1`, `knockback=0`, `pierce=0`, `blood_bowl=0`, `ammo_regen=1`, `pawn_global_promote=1`, `grenade_dmg=2`, `special=grenade`, `surrender=1`, `gid=7`, `ammo_max=5`, `reload_grenade=1`, `nothing=1`, `truncated=true`, `fields_shown=16`

## 6. Function map (candidates for the TBD areas)

`gimme("global")` returned 920 names.

### ammo / shells (map.md: spend & refill TBD)
`spend_hop`, `can_reload`, `ev_reload`, `fx_magic_star`, `give_ammo`, `inc_ammo`, `need_reload`, `refill_ammo`, `reload`, `RELOAD_BUTTON`, `srfshot`

### damage / health / death (map.md: single entry point TBD)
`check_folly_shields`, `on_death`, `bleed_dmg`, `chk_shield`, `ev_death`, `fx_dmg`, `fx_ground_poison`, `fx_shield`, `shpr`, `xpl`, `xpl_anyone`, `xpl_boss`, `xpl_king`

### spawn / pieces / floors (map.md: spawn decision TBD)
`get_nearest_piece`, `get_piece_name`, `get_piece_next_action`, `get_piece_squares`, `get_piece_targets`, `get_piece_tempo`, `get_pieces`, `get_pieces_list`, `get_real_bads`, `new_level`, `new_piece`, `all_bads`, `all_pieces`, `ask_piece`, `bad_shoot`, `carry_nearby_pieces`, `choose_piece_move`, `colorize_piece`, `dev_right_click_piece`, `DP_PIECES`, `dr_piece`, `dr_rotated_piece`, `end_level`, `ev_piece_drop`, `ev_side_spawn`, `ev_spawn_item`, `execute_piece`, `fx_show_piece`, `fx_spawn`, `is_piece`, `level_up`, `move_black_piece`, `move_piece`, `pal_piece`, `PIECES`, `PIECES_NAMES`, `PIECES_TYPES`, `setup_piece`, `spawn_dark_bishop`, `spawn_hero`, `spawn_horsemen`, `spawn_mother_queen`, `spawn_pieces`, `spawn_popup`, `stun_piece`, `throw_piece`, `trace_all_piece_dist`, `trace_piece_dist`

### cards / offers / codex (map.md: offer roll TBD)
`add_any_card`, `add_card`, `check_cards_auto_flip`, `get_all_cards`, `get_card`, `get_card_with`, `get_free_card_slot`, `get_nb_cards`, `get_slot_card`, `get_slot_card_with`, `get_slot_cards`, `init_cards_hint`, `init_codex`, `new_card`, `NEW_CARDS`, `any_card_ctrl`, `ask_card`, `CARDS`, `dr_flip_card`, `exhaust_card_with`, `flip`, `flip_card`, `HALF_POOL`, `has_card`, `increase_card_turns`, `is_card_available`, `pick`, `replace_card`, `reverse_card`, `show_card`, `TEST_CARDS`, `unflip_card`

### turn flow / game loop
`init_game`, `init_new_turn`, `new_turn`, `boss_turn`, `dark_bishop_turn`, `earn_extra_turn`, `ease_uturn`, `end_level`, `fwait`, `fx_ground_poison`, `increase_card_turns`, `opp_move`, `opp_turn`, `punkcake_wait`, `rect_round_col`, `round`, `wait`

### UI / menu / buttons (for the cheat panel + pickers)
`draw_arms`, `draw_button`, `draw_game`, `draw_icon`, `draw_mode`, `draw_on_board`, `draw_stick`, `get_all_buts`, `get_menu_desc`, `init_cards_hint`, `init_menu`, `mk_bullet`, `mk_but`, `mk_grid`, `mk_hint_but`, `mk_menu_but`, `mk_part`, `mk_sq_but`, `mk_square_but`, `mk_text_but`, `act_menu`, `butInfo`, `close_menu`, `CONFIRM_BUTTON`, `disrupt_menu_ctrl`, `fx_zoom_panel`, `hide_hint`, `menu_ctrl`, `open_menu`, `rank_select`, `RELOAD_BUTTON`, `remove_buts`, `reset_move_cursor`, `select_unit_ctrl`, `SHOOT_BUTTON`, `show_hint`, `SPECIAL_BUTTON`, `storm_all_but`, `track_but_ctrl`

### save / persistence
`check_save`, `init_banks`, `_load`, `_savbnk`, `bank`, `can_reload`, `dev_log_grids_time`, `dev_right_click_piece`, `dev_right_click_sq`, `dirload`, `ev_abort_mission`, `ev_ask_for_help`, `ev_backup`, `ev_death`, `ev_hit`, `ev_piece_drop`, `ev_promote`, `ev_raise_dead`, `ev_rat_atk`, `ev_reload`, `ev_reveal_heir`, `ev_side_spawn`, `ev_spawn_item`, `ev_surrender`, `ev_talk`, `ev_trampoline`, `ev_usurper`, `ev_vampire`, `load`, `load_all_fonts`, `load_hd_font`, `load_lang`, `load_lang_nofont`, `load_legacy_save`, `load_mods`, `load_params`, `load_safe_lang`, `MODSAV`, `need_reload`, `prev_mode`, `reload`, `RELOAD_BUTTON`, `reset_save`, `save`, `save_achievements`, `SAVE_FILE`, `save_run`, `SAVE_RUNS`, `save_stats`, `SAVE_VERSION`

### shots / bullets / aim (for ammo & shot mechanics)
`get_firepower`, `get_firerange`, `get_recoil_square`, `get_spread`, `mk_bullet`, `aim_ctrl`, `bad_shoot`, `fire`, `grenade_ctrl`, `SHOOT_BUTTON`, `shoot_ctrl`, `smoothAim`, `throw_grenade`, `throw_piece`

## 7. Replaceable globals (mods may replace these outright)

`AUTO_REPLACE`, `BOOT`, `CARDS`, `DEV`, `DUMMY`, `EXCLUDE`, `FIRST_ARMY`, `FORCE_WHITE_ARMY`, `FRAGILE`, `HERO_INIT`, `OVERWEIGHT`, `PIECES`, `SHOW_BUTS`, `START_LVL`, `TAGS`, `TEST_CARDS`, `TEST_SOULS`, `VISION`, `ammo`, `bg`, `cards`, `chamber`, `game_mode`, `grenades`, `heir`, `hero`, `leader`, `mMenu`, `mcl`, `mcr`, `menu`, `mlb`, `mode`, `mx`, `my`, `pentasquares`, `perm`, `scepters`, `stack`, `waypoint`, `white_army`

## 8. Forbidden globals (do not touch)

`DEN`, `MODSAV`, `_G`, `_S`, `cd`, `changelog`, `delmus`, `delsfx`, `delsrf`, `discord`, `execute`, `export`, `getfenv`, `help`, `load`, `logdupe`, `man`, `mantxt`, `progress`, `rm`, `safe_require`, `setfenv`, `steam`, `steamws`, `stop`, `url`

## 9. Full global list

```
ACHIEVEMENTS                ACH_FILE                    ADI                         AUTO_REPLACE                BACKERS                     BOOT
BUILD_TYPE                  CARDS                       CLM                         CONFIRM_BUTTON              CTRLR_LIST                  DEN
DIR                         DIRS                        DO_GIFKEY                   DP_BG                       DP_BOARD                    DP_FX
DP_INTER                    DP_PIECES                   DP_SHADES                   DP_TOP                      EXCLUDE                     EXE_ARGS
FIRST_ARMY                  FONTS_DATA                  FORCE_BRIGHT                FORCE_DARK                  FORCE_MEDIUM                GAMEPAD_LAYOUT
GAME_MODES                  GIF_END                     GIF_FOLDER                  GIF_LENGTH                  GIF_SCALE                   GIF_SNAP_SCALE
GIF_START                   HALF_POOL                   HERO_INIT                   INPUT_ASSIGNEMENT           IN_EXPORT                   ITEMS
KNIGHT_MOVES                LANGUAGES                   MCH                         MCW                         MODLIST                     MODS
MODSAV                      MOD_GAMEPLAY_KEYS           MOD_GRAPHICS_KEYS           MOD_HERO_INIT_KEYS          MOUSE                       MSC
NEW_CARDS                   OPTIONS                     OVERLAY_SCALE               OVERLAY_SURF                OVERLAY_TKEY                OVERWEIGHT
PC                          PDY                         PI                          PIECES                      PIECES_NAMES                PIECES_TYPES
RELOAD_BUTTON               ROLES                       RUMBLE                      SAVE_FILE                   SAVE_RUNS                   SAVE_VERSION
SET                         SHOOT_BUTTON                SNAP_KEY                    SPECIAL_BUTTON              SQ                          STAT_FILE
STEAM                       SUPPORTED_LANG              TAGS                        TEMPO                       TEST_CARDS                  TEST_SOULS
TEST_STACK                  TRANSLATORS                 VERSION                     VOL_MAX                     _G                          _O
_S                          __REMY_SYSTEMS__            __steamws_install           _draw                       _flr                        _init
_lib_draw                   _lib_init                   _lib_update                 _lib_window_focus           _lib_window_resize          _load
_log                        _music                      _savbnk                     _sfx                        _update                     _window_resize
abort                       abort_brutal                abs                         ach_count                   ach_desc                    ach_event
ach_popup_list              ach_unlock                  acos                        act_menu                    activate_scepter            activate_soul
add                         add_any_card                add_card                    add_child                   add_event                   add_indexes
add_scepter                 add_soul                    add_soul_slot               addfont                     adjust_to_gamepad           afile
aft                         aim_ctrl                    air                         all                         all_bads                    all_pieces
allinputs                   any_card_ctrl               apal                        apply_option                apply_options               arand
argtype                     asin                        ask_card                    ask_disrupt                 ask_piece                   askfile
aspr                        assert                      asspr                       atan2                       bad_shoot                   band
bank                        bget                        bind                        black_mist_check            blade_hit                   bleed_dmg
blend                       blend_light                 bnksize                     bnot                        boost                       boot
bor                         boss_turn                   bprint                      brd                         bres                        bres_2
bright                      bset                        btn                         btnclr                      btnlbl                      btnlbls
btnp                        btnr                        btnrp                       btnrst                      btnsil                      btnv
build_stack                 bump_all                    butInfo                     bxor                        camera                      can_reload
carry_nearby_pieces         catchinput                  catchtxt                    cd                          ceil                        changelog
cheat_unlock_all            cheatcode                   check_auto_replace          check_cards_auto_flip       check_collections           check_condition
check_corrupt               check_fatality              check_folly_shields         check_save                  chk_achievement             chk_bodyguard
chk_castle                  chk_iron                    chk_shield                  chkinfo                     chnlfx                      chnlprog
choose_piece_move           chr                         chunk                       circ                        circfill                    clean_up
clip                        clipboard                   cloak_hero                  clone                       close_menu                  cls
color                       colorize_piece              concat                      config                      confirm                     console_alt
console_init                console_sheet               console_ver                 controls                    convert                     corout
cos                         cprint                      crop_to                     ctrl_mode                   ctrlr                       cub
current_lang                curve                       custom_sort                 cyc                         dark_bishop_turn            dark_bishop_up
decay_up                    decilim                     defbtn                      del                         delbnk                      delchk
delfnt                      deli                        delmus                      delsfx                      delsrf                      delta
delwin                      demote                      desktop_path                dev_log_grids_time          dev_right_click_piece       dev_right_click_sq
dig                         dig_ctrl                    direct_event                dirload                     discord                     disrupt
disrupt_menu_ctrl           dist                        dr_boss                     dr_boss_target              dr_crosshair                dr_dark_bishop
dr_dot_line                 dr_flip_card                dr_movemap                  dr_piece                    dr_rotated_piece            dr_skin
draw_arms                   draw_button                 draw_game                   draw_icon                   draw_mode                   draw_on_board
draw_stick                  dre                         dsq                         dt                          earn_extra_turn             ease_atk
ease_bounce_out             ease_flat                   ease_in                     ease_in_back                ease_in_out                 ease_out
ease_out_back               ease_out_in                 ease_uturn                  effect_order                encfile                     end_game
end_level                   end_msg                     endgif                      ents_ach                    error                       escape
ev_abort_mission            ev_ask_for_help             ev_backup                   ev_death                    ev_hit                      ev_piece_drop
ev_promote                  ev_raise_dead               ev_rat_atk                  ev_reload                   ev_reveal_heir              ev_side_spawn
ev_spawn_item               ev_surrender                ev_talk                     ev_trampoline               ev_usurper                  ev_vampire
exe                         execute                     execute_action              execute_piece               exhaust                     exhaust_card_with
exhaust_soul                expbnk                      expfnt                      expn                        export                      export_icon_png
export_localized_strings    export_steam_loc            export_trophy_desc_file     expose                      expsrf                      fade_to
fast_tracker                fbrd                        file                        fillp                       fillp_dissolve              find
fire                        first_upper                 flip                        flip_card                   flr                         fnt
fnt_params                  fnt_size                    fntalias                    fntspec                     folder                      font
force_HD                    foreach                     forget_run                  format                      format_gameplay_datas       format_lang
format_list                 fps                         fpslimit                    freeze                      fst                         fwait
fx_ascend                   fx_cart                     fx_crumb                    fx_detect                   fx_dmg                      fx_dust
fx_emote                    fx_frame_drop               fx_ground_poison            fx_magic_star               fx_miss                     fx_red_flash
fx_screen_flash             fx_shield                   fx_show_piece               fx_show_sq                  fx_spawn                    fx_talk
fx_trg                      fx_twinkle                  fx_unlock                   fx_vanish                   fx_white_flash              fx_wrong
fx_zoom_panel               gameover                    gamepad_ctrl                gco                         gen_gfx                     get_ach_count
get_all_buts                get_all_cards               get_allies                  get_boost                   get_card                    get_card_with
get_carry_list              get_center                  get_delay                   get_desc                    get_disp_stats              get_dodge
get_empty_soul_slot         get_firepower               get_firerange               get_free_card_slot          get_free_squares            get_global_pos
get_group_name              get_hero_sq                 get_hero_trg                get_index_table             get_inventory               get_lang
get_leader_name             get_leader_type             get_menu_desc               get_mouse_target            get_nb_cards                get_nearest_free_square
get_nearest_piece           get_nei_with                get_patterns                get_piece_name              get_piece_next_action       get_piece_squares
get_piece_targets           get_piece_tempo             get_pieces                  get_pieces_list             get_plural                  get_prediction
get_range                   get_real_bads               get_recoil_square           get_scepter                 get_slot_card               get_slot_card_with
get_slot_cards              get_soul_range              get_spread                  get_sq_danger               get_sq_di                   get_square_at
get_square_coef             get_square_pos              get_stats                   get_time_string             get_zone                    get_zone_targets
getfenv                     getmetatable                gifframe                    giflen                      gifstream                   give_ammo
goto_fall                   goto_heaven                 goto_sq                     grab_item                   grenade_ctrl                grid_line
grid_rect                   gsq                         gsq_zone                    gtime                       has                         has_card
hdclear                     help                        hex                         hide_hint                   hide_title                  hit
hmod                        hrnd                        hsv                         i                           id_tbl                      impulse
inc_ammo                    inc_army                    inc_black_army              inc_stats                   increase_card_turns         inflict
ingame_ui_ctrl              init_achievements           init_banks                  init_cards_hint             init_codex                  init_credits
init_game                   init_hoard                  init_intro                  init_menu                   init_new_turn               init_safe_mode
init_test                   init_vig                    inpnum                      inv_kin                     ipairs                      irnd
is_action_valid             is_async                    is_basic_mode               is_bow_ready                is_card_available           is_free
is_free_for                 is_hero_close               is_imprisoned               is_king                     is_locked                   is_orth_view
is_piece                    is_reapable                 is_square_clean             is_type                     is_valid_target             isfile
isfolder                    jesterize                   jit                         join                        join_tbl                    kl
lang                        lang_sum                    leave_sq                    lerp                        level_up                    lib_call
line                        list                        listord                     load                        load_all_fonts              load_hd_font
load_lang                   load_lang_nofont            load_legacy_save            load_mods                   load_params                 load_safe_lang
locale                      locale_ps                   lockaudio                   log                         loga                        logdupe
logs                        loop                        lowercase                   lprint                      ls                          lshr
ltime                       man                         manhattan_dist              mantxt                      map                         map_tbl
match                       max                         mem                         memcpy                      memsbs                      memset
menu_ctrl                   merge_funcs                 mid                         min                         min_digits                  mk_bullet
mk_but                      mk_grid                     mk_hint_but                 mk_menu_but                 mk_part                     mk_sq_but
mk_square_but               mk_text_but                 mkdir                       mke                         modchk                      mode_setup
morph_to                    mouse                       move_black_piece            move_ctrl                   move_hero                   move_piece
mpal                        msg                         music                       muslen                      musvol                      mv
mv_speed                    mvt                         namefind                    need_reload                 new_card                    new_level
new_piece                   new_turn                    newbnk                      newchk                      newfnt                      newgif
newmus                      newsfx                      newsrf                      newwin                      no_popup                    numbered
nwinspec                    nxtmusic                    ny                          on_death                    one_time                    open_menu
opp_move                    opp_turn                    ord                         orth                        ospr                        oval
ovalfill                    paint_danger                pairs                       pal                         pal_inc                     pal_piece
pal_rst                     pal_z                       palette                     palt                        parse_effect                pat
peek                        peek2                       peek4                       perf                        perma_checks                pget
pick                        play                        play_events                 plur                        plural                      poke
poke2                       poke4                       pop_child                   pop_mode                    pow                         pprint
pref_path                   prev_mode                   print                       progress                    pset                        pside
psyms                       punkcake_gif                punkcake_intro              punkcake_wait               push_mode                   quarantine_req
quarantine_req_env          quit                        quitting                    rank_select                 rawget                      rawset
rawtime                     read                        read_gameplay_file          recal_scepters              rect                        rect_col
rect_dist                   rect_round_col              rectfill                    rectshade                   rectshade_dither            rectshadeopti
refill_ammo                 reg_add                     reload                      remove_buts                 remove_soul_slot            remysys_set_glob
remysys_timestamp           rep                         replace_card                require                     reset                       reset_mode
reset_move_cursor           reset_save                  reset_settings              reset_stats                 restore_run                 restype
resume                      retire                      reveal_spy                  reverse                     reverse_card                rgb
rlog                        rm                          rnd                         rotate                      rotl                        rotr
round                       rrect                       rrectfill                   rumble                      run                         run_mods
safe_require                safesize                    safesub                     save                        save_achievements           save_run
save_stats                  sbs                         scan_cancel                 score_grid                  screen_shake                seek_role
seer_target                 select_unit_ctrl            serialize                   set_army                    set_default_lang            set_holoking
set_instructions            set_mode                    setfenv                     setmetatable                setup_piece                 sfillp
sfillp_dissolve             sfillp_rst                  sfx                         sfxlen                      sfxvol                      sget
sgn                         shader                      shdrf                       shdrf2                      shdrf3                      shdrf4
shdri                       shdri2                      shdri3                      shdri4                      shdrsrf                     shl
shoot_ctrl                  show_card                   show_catapult               show_danger                 show_hint                   show_regret
show_title                  shpr                        shr                         shuffle                     shuffle_copy                shuffle_old
sig                         sin                         sleep                       slicer                      smoothAim                   smoothDir
sort                        spawn_dark_bishop           spawn_hero                  spawn_horsemen              spawn_mother_queen          spawn_pieces
spawn_popup                 spend_hop                   split                       spr                         sprgrid                     spritesheet
sqp                         sqr                         sqrdist                     sqrt                        srand                       srfmem
srfname                     srfshot                     srfsize                     sset                        sspr                        ssspr
start_lvl_music             start_music                 steal                       steam                       steamlb                     steamws
step                        stop                        storm                       storm_all_but               strheight                   stringify_table
strwidth                    stun_piece                  sub                         success_msg                 sugar_step                  sum_el
survive_sheath              sysbat                      syslang                     t                           table_from_string           target
tbl_has                     tbl_import                  tbl_index                   tbl_inv                     tbl_key                     tbz
tcamera                     tear_apart                  throw_grenade               throw_piece                 time                        toggle_target
tonum                       tostr                       trace_all_piece_dist        trace_cover                 trace_hdist                 trace_heros_dists
trace_piece_dist            traceback                   track_but_ctrl              track_mouse                 transfer                    transp
tri                         tri_angle                   trifill                     trig_achievement            twv                         txtheight
txtinp                      txtwidth                    type                        uadd                        unflip_card                 unlockaudio
unpack                      unpause                     unwatch                     upe                         uplift                      uppercase
url                         use_gamepad_layout          usingctrlr                  wait                        warp                        watch
watch_me                    white_king_up               window                      winspec                     wipe                        wlog
write                       write_big_at                write_mod_list              xpl                         xpl_anyone                  xpl_boss
xpl_king                    ysort
```

## 10. Mod list (live MODLIST dump)

- entry 1: `script=mods/sk-rework/script.lua`, `desc=SK Rework — Build 7 (run-5 absorbed: panel fix, damage/crit, ammo, dodge,`, `here=true`, `cover=mods/sk-rework/cover.png`, `save=sk-rework`, `active=true`, `name=sk-rework`, `folder=mods/sk-rework`, `exists=true`, `title=SK Rework`, `author=freeforall1932`, `num=1`, `priority_hint=0`
- entry 2: `script=mods/disgraced_justice/script.lua`, `desc=Broken oaths and holy corruption.`, `here=true`, `save=disgraced_justice`, `active=false`, `name=disgraced_justice`, `exists=true`, `title=Disgraced Justice`, `folder=mods/disgraced_justice`, `author=Lorina Sonetto & Bob Qwerty`, `priority_hint=0`
- entry 3: `script=mods/extra features/script.lua`, `desc=This mod itself doesn't add any content. Only empowers other mods to have additional features.`, `here=true`, `cover=mods/extra features/cover.png`, `save=extra features`, `active=false`, `name=extra features`, `folder=mods/extra features`, `exists=true`, `title=Glacies' Extra Features`, `id=3145848395`, `author=Glacies`, `priority_hint=0`
- entry 4: `script=mods/glac terminal/script.lua`, `desc=Modder tool. DOESN'T ADD ANY CONTENT.`, `here=true`, `cover=mods/glac terminal/cover.png`, `save=glac terminal`, `active=false`, `name=glac terminal`, `folder=mods/glac terminal`, `exists=true`, `title=Glacies Module Terminal`, `id=3144832438`, `author=Glacies`, `priority_hint=-3`
- entry 5: `script=mods/glacies collection/script.lua`, `desc=Adds a bunch of ingame mechanics that can be used by other mods,`, `here=true`, `cover=mods/glacies collection/cover.png`, `save=glacies collection`, `active=false`, `name=glacies collection`, `folder=mods/glacies collection`, `exists=true`, `title=Glacies' Collection`, `id=3148586988`, `author=Glacies`, `priority_hint=0`
- entry 6: `script=mods/grenade predictor/script.lua`, `desc=Hold middle wheel over a square to see the probabilities or average damages of a grenade.`, `here=true`, `cover=mods/grenade predictor/cover.png`, `save=grenade predictor`, `active=false`, `name=grenade predictor`, `folder=mods/grenade predictor`, `exists=true`, `title=Grenade Predictor`, `id=3449354474`, `author=Glacies`, `mode_record=tbl`
- entry 7: `script=mods/nightmare/script.lua`, `desc=The title is a lie. This mod isn't as hard as a nightmare at all.`, `here=true`, `mode_description=tbl`, `cover=mods/nightmare/cover.png`, `active=false`, `name=nightmare`, `save=nightmare`, `exists=true`, `title=Nightmare Mode`, `modes=tbl`, `author=Glacies`, `folder=mods/nightmare`, `id=3197738029`
- entry 8: `script=mods/retry/script.lua`, `desc=Restarts the current floor after you die.`, `here=true`, `cover=mods/retry/cover.png`, `save=retry`, `active=false`, `name=retry`, `folder=mods/retry`, `exists=true`, `title=Retry after Death`, `id=3626751996`, `author=Glacies`, `priority_hint=0`
- entry 9: `script=mods/royal card lab/script.lua`, `desc=`, `here=true`, `cover=mods/royal card lab/cover.png`, `active=false`, `name=royal card lab`, `folder=mods/royal card lab`, `exists=true`, `title=Royal Card Lab`, `save=royal card lab`, `author=Glacies`, `modes=tbl`, `id=3144064207`
- entry 10: `script=mods/Shootout/script.lua`, `desc=An endless adventure in which your typical arsenal is replaced with a shitty rifle'`, `here=true`, `cover=mods/Shootout/cover.png`, `save=Shootout`, `active=false`, `name=Shootout`, `folder=mods/Shootout`, `exists=true`, `title=Shootout: the Rifle King Adventure`, `author=unknown2559`, `modes=tbl`, `priority_hint=0`
- entry 11: `script=mods/show exclude/script.lua`, `desc=Features:`, `here=true`, `cover=mods/show exclude/cover.png`, `save=show exclude`, `active=false`, `name=show exclude`, `folder=mods/show exclude`, `exists=true`, `title=Better Codex`, `id=3145391294`, `author=Glacies`, `priority_hint=0`
- entry 12: `script=mods/some_fairy_pieces/script.lua`, `cover=mods/some_fairy_pieces/cover_sfps.png`, `active=false`, `title=Fairy Pieces for SGK`, `desc=Fairy chess piecess for Shotgun King. Contains a few basic fairy pieces.`, `modes=tbl`, `id=3342310033`, `name=some_fairy_pieces`, `here=true`, `exists=true`, `mode_record=tbl`, `folder=mods/some_fairy_pieces`, `save=some_fairy_pieces`, `langs=tbl`
- entry 13: `script=mods/the art of war/script.lua`, `desc=[h2] Content [/h2]`, `here=true`, `cover=mods/the art of war/cover.png`, `save=the art of war`, `active=false`, `name=the art of war`, `folder=mods/the art of war`, `exists=true`, `title=Military Tactics -The Art of War-`, `id=3512338449`, `author=Glacies`, `priority_hint=-1`
- entry 14: `script=mods/the_magnificient_quartz_army/script.lua`, `desc=The white army is getting bigger, this mod that adds a whole  lots of new pieces for the white army, as well as a special throne mod where the difficulties all affects these new pieces instead.`, `here=true`, `cover=mods/the_magnificient_quartz_army/tmqa_cover.png`, `folder=mods/the_magnificient_quartz_army`, `id=3151846036`, `name=the_magnificient_quartz_army`, `save=the_magnificient_quartz_army`, `exists=true`, `title=The Magnificent Quartz Army`, `active=false`, `author=matheo000`, `modes=tbl`, `langs=tbl`

## 11. Card id map (live CARDS dump)

186 cards. `id` is the display name (confirmed live: `SKE|add_card|id=A Piercing Truth`); stats.sav codex keys use the same names.

| id | gid | ext | pwe |
|---|---|---|---|
| Ermine Belt | 0 | 0 | 4 |
| Rightful Curtsy | 1 | 0 | 4 |
| Elite Gem | 2 | 0 | 4 |
| Extra Barrel | 3 | 0 | 6 |
| Royal Loafers | 4 | 0 | 2 |
| Majestic Censer | 5 | 0 | 4 |
| Sacred Crown | 6 | 0 | 4 |
| Blunderbuss | 7 | 0 | 4 |
| Engraved Scope | 8 | 0 | 4 |
| Holy Gunpowder | 9 | 0 | 4 |
| Ritual Dagger | 10 | 0 | 4 |
| August Presence | 11 | 0 | 4 |
| Crow's Blessing | 12 | 0 | 4 |
| Wand of Downpour | 13 | 0 | 1 |
| Wand of Frenzy | 14 | 0 | 1 |
| Wand of Wrath | 15 | 0 | 1 |
| Wand of Wings | 16 | 0 | 1 |
| The Moat | 17 | 0 | 4 |
| Gradual Absolution | 18 | 0 | 2 |
| Taunting Hop | 19 | 0 | 4 |
| Wand of Gust | 20 | 0 | 1 |
| Faithful Steed | 21 | 0 | 4 |
| Unjust Decree | 22 | 0 | 2 |
| Kingly Alms | 23 | 0 | 4 |
| Subtle Poison | 24 | 0 | 2 |
| Kingdom Wealth | 25 | 0 | 3 |
| Small Fry Harvest | 26 | 0 | 2 |
| A Piercing Truth | 27 | 0 | 4 |
| Black Mist | 28 | 0 | 4 |
| King's Shoulders | 29 | 0 | 2 |
| High Focus | 30 | 0 | 4 |
| Courteous Jousting | 31 | 0 | 4 |
| Cornered Despot | 32 | 0 | 4 |
| Sawed-off Justice | 33 | 1 | 4 |
| Welcome Gift | 34 | 1 | 4 |
| Cannon Fodder | 35 | 1 | 4 |
| Possessed | 36 | 1 | 4 |
| Philanthropy | 37 | 1 | 4 |
| Imperial Shot Put | 38 | 1 | 4 |
| Egotic Maelstrom | 39 | 1 | 4 |
| Church Organ | 40 | 1 | 4 |
| Black Plague | 41 | 1 | 4 |
| Ravenous Rats | 42 | 1 | 4 |
| Deep Water | 43 | 1 | 4 |
| Unholy Call | 44 | 1 | 4 |
| Undercover Mission | 45 | 1 | 4 |
| Caltrops | 46 | 1 | 4 |
| Nightbane | 47 | 1 | 4 |
| Bushido | 48 | 1 | 4 |
| Bloodless Coups | 49 | 1 | 4 |
| Wand of Hypnosis | 50 | 1 | 1 |
| Presbyopia | 51 | 1 | 4 |
| Golden Aging | 52 | 1 | 4 |
| Fool Companion | 53 | 1 | 4 |
| Force-feeding | 54 | 1 | 4 |
| Seer's Orb | 55 | 2 | 4 |
| Fearsome | 56 | 2 | 4 |
| Human Shield | 57 | 2 | 4 |
| Reign of Terror | 58 | 2 | 4 |
| Selective Listening | 59 | 2 | 4 |
| Monarch's Confidence | 60 | 2 | 4 |
| The Mole | 61 | 2 | 4 |
| Elusive | 62 | 2 | 4 |
| Holoking | 63 | 2 | 4 |
| Cloaking Device | 64 | 2 | 4 |
| Low-Cost Disguise | 65 | 2 | 4 |
| Wand of Souls | 66 | 2 | 1 |
| Wand of Execution | 67 | 2 | 1 |
| Patience | 68 | 2 | 4 |
| Bold Plan | 69 | 2 | 4 |
| Silencer | 70 | 2 | 4 |
| Ambush | 71 | 2 | 4 |
| Ancient Flagstone | 72 | 2 | 2 |
| Tearing Bullets | 73 | 2 | 4 |
| Indelible Memories | 74 | 2 | 4 |
| Mystic Shackles | 75 | 2 | 4 |
| Secret Move | 76 | 2 | 4 |
| Sacred Light | 77 | 2 | 4 |
| Workshop | 78 | 2 | 4 |
| Right-hand | 79 | 3 | 4 |
| Warhorse | 80 | 3 | 4 |
| Bastion | 81 | 3 | 4 |
| Sprint | 82 | 3 | 4 |
| Soul Projection | 83 | 3 | 4 |
| Onboarding Party | 84 | 3 | 4 |
| Small Key | 85 | 3 | 4 |
| Rapunzel | 86 | 3 | 4 |
| Wand of Treachery | 87 | 3 | 1 |
| Guerilla Tactics | 88 | 3 | 4 |
| Shovel | 89 | 3 | 2 |
| Grindstone | 90 | 3 | 2 |
| Death Mark | 91 | 3 | 4 |
| Shrapnel | 92 | 3 | 4 |
| Backups | 100 | 0 | 4 |
| Cavalry | 101 | 0 | 4 |
| Conclave | 102 | 0 | 4 |
| Entitle | 103 | 0 | 4 |
| Cardinal | 104 | 0 | 4 |
| Remparts | 105 | 0 | 4 |
| Pillage | 106 | 0 | 4 |
| Crusades | 107 | 0 | 4 |
| Peace | 108 | 0 | 4 |
| King's Mistress | 109 | 0 | 4 |
| Revolution | 110 | 0 | 4 |
| Bodyguard | 111 | 0 | 4 |
| Ruins | 112 | 0 | 4 |
| Assault | 113 | 0 | 4 |
| Kite Shield | 114 | 0 | 4 |
| Zealots | 115 | 0 | 4 |
| Militia | 116 | 0 | 4 |
| Ammunition Depot | 117 | 0 | 4 |
| Scouting | 118 | 0 | 4 |
| Pikemen | 119 | 0 | 4 |
| Ascension | 120 | 0 | 4 |
| Castle | 121 | 0 | 4 |
| Conscription | 122 | 0 | 4 |
| Theocracy | 123 | 0 | 4 |
| Fallen Dynasty | 124 | 0 | 0 |
| Iron Maiden | 125 | 0 | 4 |
| Court of the King | 126 | 0 | 4 |
| The Red Book | 127 | 0 | 4 |
| Saboteur | 128 | 0 | 4 |
| Homecoming | 129 | 0 | 0 |
| Lookout Tower | 130 | 0 | 4 |
| Throne Room | 131 | 0 | 4 |
| The Secret Heir | 132 | 0 | 4 |
| Genderqueer | 133 | 0 | 4 |
| Karma | 134 | 1 | 4 |
| Undead Armies | 135 | 1 | 4 |
| Shortage | 136 | 1 | 4 |
| Succubus | 137 | 1 | 4 |
| Bunker | 138 | 1 | 4 |
| Sanctity | 139 | 1 | 4 |
| Knightmare | 140 | 1 | 4 |
| Highest Dungeon | 141 | 1 | 2 |
| Cathedral | 142 | 1 | 4 |
| The Bridge | 143 | 1 | 4 |
| Divine Healing | 144 | 1 | 4 |
| Last Guardian | 145 | 1 | 4 |
| Trowel | 146 | 1 | 4 |
| Full Plate Armor | 147 | 1 | 4 |
| Military Academy | 148 | 1 | 4 |
| Witch's Curse | 149 | 1 | 4 |
| Saddle | 150 | 1 | 4 |
| The Jester | 151 | 1 | 4 |
| Guillotine | 152 | 1 | 4 |
| Analysis Paralysis | 153 | 1 | 4 |
| Plumed Knight | 154 | 2 | 4 |
| Emergency Call | 155 | 2 | 4 |
| Mangonel | 156 | 2 | 4 |
| Governess | 157 | 2 | 4 |
| Mausoleum | 158 | 2 | 4 |
| Reverend Mother | 159 | 2 | 4 |
| Sokoban | 160 | 2 | 4 |
| Tag Team | 161 | 2 | 4 |
| Unicorn | 162 | 2 | 4 |
| Lady in the Tower | 163 | 2 | 4 |
| Final Countdown | 164 | 2 | 4 |
| Nomad Life | 165 | 2 | 4 |
| Prison | 166 | 2 | 4 |
| Inquisition | 167 | 2 | 4 |
| King's Look-alike | 168 | 2 | 4 |
| The Royal Hunt | 169 | 2 | 4 |
| Tragic Homecoming | 170 | 2 | 0 |
| Buckler of Limos | 171 | 2 | 4 |
| Vampirism | 172 | 2 | 4 |
| Commoner's Reign | 173 | 2 | 0 |
| Bouncy Castle | 174 | 2 | 4 |
| Self-Defense | 175 | 2 | 0 |
| Unsettled Throne | 176 | 2 | 4 |
| Vendetta | 177 | 3 | 8 |
| Stoning | 178 | 3 | 4 |
| Anarchy | 179 | 3 | 2 |
| Auto-da-fe | 180 | 3 | 4 |
| Late for dinner | 181 | 3 | 4 |
| Excommunication | 182 | 3 | 4 |
| Pyre of Lust | 183 | 3 | 2 |
| Gatehouse | 184 | 3 | 4 |
| Lightfoot | 185 | 3 | 4 |
| Loyalist March | 186 | 3 | 2 |
| Trench War | 187 | 3 | 2 |
| Catacombs | 188 | 3 | 4 |
| Flesh Wall | 189 | 3 | 2 |
| Hired Blade | 190 | 3 | 4 |
| Oathkeeper | 191 | 3 | 2 |
| Redemption | 192 | 3 | 4 |

## 12b. Full card fields & EXCLUDE pairs (build 5+)

- **Ermine Belt**: `ammo_max=3`, `n=3`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=0`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=Ermine Belt`, `gid=0`
- **Rightful Curtsy**: `sac=tbl`, `knockback=50`, `n=2`, `gid=1`, `tags=tbl`, `tags.1=on_hit`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=1`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `ammo_max=1`, `id=Rightful Curtsy`
- **Elite Gem**: `need_tag=tbl`, `sac=tbl`, `n=1`, `gid=2`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=2`, `need_card=tbl`, `team=0`, `firerange=1`, `need=tbl`, `pwe=4`, `id=Elite Gem`, `ammo_regen=1`
- **Extra Barrel**: `need_tag=tbl`, `n=3`, `gid=3`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=3`, `need_card=tbl`, `team=0`, `need=tbl`, `sac=tbl`, `pwe=6`, `id=Extra Barrel`, `chamber_max=1`
- **Royal Loafers**: `need_tag=tbl`, `exclude=tbl`, `exclude.1=Sawed-off Justice`, `n=1`, `gid=4`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=4`, `need_card=tbl`, `team=0`, `special=strafe`, `need=tbl`, `pwe=2`, `sac=tbl`, `id=Royal Loafers`
- **Majestic Censer**: `exclude_tag=tbl`, `sac=tbl`, `n=1`, `gid=5`, `tags=tbl`, `gain=tbl`, `soul_slot=1`, `ext=0`, `index=5`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=Majestic Censer`, `ammo_max=1`
- **Sacred Crown**: `need_tag=tbl`, `need=tbl`, `n=1`, `gid=6`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=6`, `need_card=tbl`, `team=0`, `crown=1`, `need_soul=1`, `pwe=4`, `sac=tbl`, `id=Sacred Crown`
- **Blunderbuss**: `need_tag=tbl`, `sac=tbl`, `n=2`, `gid=7`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=7`, `need_card=tbl`, `team=0`, `firepower=2`, `need=tbl`, `pwe=4`, `spread=30`, `id=Blunderbuss`
- **Engraved Scope**: `need_tag=tbl`, `sac=tbl`, `n=1`, `gid=8`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `search=1`, `index=8`, `need_card=tbl`, `team=0`, `special=scope`, `need=tbl`, `pwe=4`, `ext=0`, `id=Engraved Scope`
- **Holy Gunpowder**: `need_tag=tbl`, `sac=tbl`, `n=2`, `gid=9`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=9`, `need_card=tbl`, `team=0`, `firepower=1`, `need=tbl`, `pwe=4`, `id=Holy Gunpowder`, `ammo_max=-1`
- **Ritual Dagger**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `need_tag=tbl`, `gid=10`, `tags=tbl`, `tags.1=leader`, `tags.2=blade`, `id=Ritual Dagger`, `exclude_tag=tbl`, `ext=0`, `index=10`, `exclude=tbl`, `exclude.1=King's Shoulders`, `exclude.2=Guillotine`, `firerange=-1`, `blade=1`, `gain=tbl`, `leader_hp=-3`, `sac=tbl`
- **August Presence**: `presence=1`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=11`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=August Presence`, `gid=11`
- **Crow's Blessing**: `need=tbl`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=12`, `need_card=tbl`, `team=0`, `firerange=2`, `need_tag=tbl`, `pwe=4`, `id=Crow's Blessing`, `gid=12`
- **Wand of Downpour**: `ext=0`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `wand=tbl`, `wand.1=0`, `wand.2=10`, `index=13`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=1`, `id=Wand of Downpour`, `gid=13`
- **Wand of Frenzy**: `ext=0`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `wand=tbl`, `wand.1=1`, `index=14`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=1`, `id=Wand of Frenzy`, `gid=14`
- **Wand of Wrath**: `ext=0`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `wand=tbl`, `wand.1=2`, `wand.2=firepower`, `index=15`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=1`, `id=Wand of Wrath`, `gid=15`
- **Wand of Wings**: `ext=0`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `wand=tbl`, `wand.1=3`, `wand.2=3`, `index=16`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=1`, `id=Wand of Wings`, `gid=16`
- **The Moat**: `need=tbl`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=17`, `need_card=tbl`, `team=0`, `moat=4`, `need_tag=tbl`, `pwe=4`, `id=The Moat`, `gid=17`
- **Gradual Absolution**: `need=tbl`, `need_tag=tbl`, `n=2`, `gid=18`, `tags=tbl`, `id=Gradual Absolution`, `exclude_tag=tbl`, `absolution=1`, `index=18`, `need_card=tbl`, `team=0`, `sac=tbl`, `need_soul=2`, `pwe=2`, `gain=tbl`, `ext=0`
- **Taunting Hop**: `index=19`, `sac=tbl`, `n=2`, `gid=19`, `tags=tbl`, `tags.1=jump`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `hop=1`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `hop_dmg=1`, `id=Taunting Hop`
- **Wand of Gust**: `ext=0`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `wand=tbl`, `wand.1=4`, `index=20`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=1`, `id=Wand of Gust`, `gid=20`
- **Faithful Steed**: `knight_black_castle=1`, `sac=tbl`, `n=1`, `gid=21`, `tags=tbl`, `id=Faithful Steed`, `exclude_tag=tbl`, `ext=0`, `index=21`, `need_card=tbl`, `need_card.1=Warhorse`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `gain=tbl`, `knight_black_carryking=1`
- **Unjust Decree**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `firepower=-1`, `pwe=2`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `id=Unjust Decree`, `exclude_tag=tbl`, `ext=0`, `index=22`, `special=decree`, `need_chamber_max=2`, `gain=tbl`, `gid=22`
- **Kingly Alms**: `n=3`, `need=tbl`, `need_card=tbl`, `team=0`, `grenade_center_dmg=2`, `pwe=4`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=grenade`, `id=Kingly Alms`, `exclude_tag=tbl`, `ext=0`, `index=23`, `special=grenade`, `grenades_max=1`, `gain=tbl`, `gid=23`
- **Subtle Poison**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `leader_hp=-1`, `need_tag=tbl`, `queen_hp=-1`, `tags=tbl`, `tags.1=leader`, `id=Subtle Poison`, `exclude_tag=tbl`, `ext=0`, `index=24`, `gid=24`, `exclude=tbl`, `exclude.1=Guillotine`, `pwe=2`, `gain=tbl`, `sac=tbl`, `queen_poison=15`
- **Kingdom Wealth**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `leader_hp=2`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `id=Kingdom Wealth`, `exclude_tag=tbl`, `ext=0`, `index=25`, `exclude=tbl`, `exclude.1=Guillotine`, `ammo_max=6`, `pwe=3`, `gain=tbl`, `gid=25`
- **Small Fry Harvest**: `n=2`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=2`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=blade`, `blade=1`, `exclude_tag=tbl`, `ext=0`, `index=26`, `exclude=tbl`, `exclude.1=King's Shoulders`, `pawn_shell=1`, `id=Small Fry Harvest`, `gain=tbl`, `gid=26`
- **A Piercing Truth**: `pierce=30`, `n=2`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=27`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=A Piercing Truth`, `gid=27`
- **Black Mist**: `need_tag=tbl`, `sac=tbl`, `n=2`, `gid=28`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=28`, `need_card=tbl`, `team=0`, `firerange=-1`, `need=tbl`, `pwe=4`, `mist=1`, `id=Black Mist`
- **King's Shoulders**: `need_tag=tbl`, `need_card=tbl`, `n=1`, `gid=29`, `tags=tbl`, `id=King's Shoulders`, `exclude_tag=tbl`, `exclude_tag.1=blade`, `ext=0`, `index=29`, `grab=1`, `team=0`, `exclude=tbl`, `exclude.1=Ritual Dagger`, `exclude.2=Small Fry Harvest`, `exclude.3=Nightbane`, `exclude.4=Bushido`, `exclude.5=Shovel`, `exclude.6=Full Plate Armor`, `exclude.7=Vendetta`, `need=tbl`, `pwe=2`, `sac=tbl`, `gain=tbl`
- **High Focus**: `n=2`, `need=tbl`, `need_card=tbl`, `team=0`, `firepower=1`, `pwe=4`, `flip_on=contact`, `need_tag=tbl`, `gid=30`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=30`, `sac=tbl`, `spread=-10`, `id=High Focus`
- **Courteous Jousting**: `exclude_tag=tbl`, `gain=tbl`, `n=1`, `gid=31`, `tags=tbl`, `id=Courteous Jousting`, `knight_joust=1`, `ext=0`, `index=31`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `sac=tbl`, `pwe=4`, `spread=-10`, `need=tbl`, `need.1=1`
- **Cornered Despot**: `need_tag=tbl`, `sac=tbl`, `n=1`, `gid=32`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=32`, `need_card=tbl`, `team=0`, `firepower=2`, `need=tbl`, `pwe=4`, `flip_on=inner`, `id=Cornered Despot`
- **Sawed-off Justice**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `firepower=2`, `pwe=4`, `need_tag=tbl`, `gid=33`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=33`, `firerange=-1`, `exclude=tbl`, `exclude.1=Royal Loafers`, `recoil=1`, `sac=tbl`, `id=Sawed-off Justice`
- **Welcome Gift**: `index=34`, `need=tbl`, `n=1`, `gid=34`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `jumpy=1`, `need_card=tbl`, `team=0`, `firepower=4`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Welcome Gift`
- **Cannon Fodder**: `pawnreap=1`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=35`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=Cannon Fodder`, `gid=35`
- **Possessed**: `need=tbl`, `n=1`, `gid=36`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `soul_slot=2`, `ext=1`, `index=36`, `need_card=tbl`, `need_card.1=Conclave`, `need_card.2=Unholy Call`, `team=0`, `exclude_tag=tbl`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Possessed`
- **Philanthropy**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=grenade`, `id=Philanthropy`, `exclude_tag=tbl`, `ext=1`, `index=37`, `grenade_dmg=-1`, `special=grenade`, `grenades_max=2`, `gain=tbl`, `gid=37`
- **Imperial Shot Put**: `need_tag=tbl`, `sac=tbl`, `n=3`, `gid=38`, `tags=tbl`, `id=Imperial Shot Put`, `exclude_tag=tbl`, `ext=1`, `index=38`, `need_card=tbl`, `need_card.1=King's Shoulders`, `team=0`, `need=tbl`, `cannonball=1`, `pwe=4`, `gain=tbl`, `ammo_max=-1`
- **Egotic Maelstrom**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `delayed=tbl`, `delayed.firepower=1`, `need_tag=tbl`, `gid=39`, `tags=tbl`, `id=Egotic Maelstrom`, `exclude_tag=tbl`, `ext=1`, `index=39`, `cycle=1`, `delay=12`, `gain=tbl`, `sac=tbl`
- **Church Organ**: `need_tag=tbl`, `gain=tbl`, `n=1`, `gid=40`, `tags=tbl`, `id=Church Organ`, `exclude_tag=tbl`, `ext=1`, `index=40`, `need_card=tbl`, `need_card.1=Cathedral`, `team=0`, `need=tbl`, `sac=tbl`, `pwe=4`, `ammo_max=2`, `chamber_max=2`
- **Black Plague**: `exclude_tag=tbl`, `need=tbl`, `n=1`, `gid=41`, `tags=tbl`, `id=Black Plague`, `plague=1`, `ext=1`, `index=41`, `need_card=tbl`, `need_card.1=Crow's Blessing`, `need_card.2=Ravenous Rats`, `team=0`, `firerange=-1`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `gain=tbl`
- **Ravenous Rats**: `rats=1`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=42`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=Ravenous Rats`, `gid=42`
- **Deep Water**: `sac=tbl`, `n=1`, `gid=43`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=43`, `deepwater=1`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `need_card=tbl`, `need_card.1=The Moat`, `id=Deep Water`
- **Unholy Call**: `pentagrams=3`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=44`, `need_card=tbl`, `team=0`, `need=tbl`, `need_tag=tbl`, `pwe=4`, `id=Unholy Call`, `gid=44`
- **Undercover Mission**: `id=Undercover Mission`, `n=1`, `sac=tbl`, `tags=tbl`, `tags.1=mission`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=45`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `waypoint=1`, `gid=45`
- **Caltrops**: `caltrops=15`, `sac=tbl`, `n=2`, `gid=46`, `tags=tbl`, `tags.1=bleed`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=46`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `bleed_slow=1`, `id=Caltrops`
- **Nightbane**: `blade=3`, `need_tag=tbl`, `n=1`, `sac=tbl`, `tags=tbl`, `tags.1=blade`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=47`, `need_card=tbl`, `team=0`, `exclude=tbl`, `exclude.1=King's Shoulders`, `need=tbl`, `pwe=4`, `id=Nightbane`, `gid=47`
- **Bushido**: `n=1`, `need=tbl`, `bushido=1`, `need_card=tbl`, `team=0`, `firepower=-1`, `pwe=4`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=blade`, `blade=2`, `exclude_tag=tbl`, `ext=1`, `index=48`, `exclude=tbl`, `exclude.1=King's Shoulders`, `id=Bushido`, `gain=tbl`, `gid=48`
- **Bloodless Coups**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `pawn_peace=1`, `pwe=4`, `need_tag=tbl`, `gid=49`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `pawn_curse=1`, `index=49`, `exclude=tbl`, `exclude.1=Militia`, `exclude.2=Stoning`, `ext=1`, `sac=tbl`, `spread=-15`, `id=Bloodless Coups`
- **Wand of Hypnosis**: `ext=1`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `wand=tbl`, `wand.1=5`, `index=50`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=1`, `id=Wand of Hypnosis`, `gid=50`
- **Presbyopia**: `index=51`, `n=1`, `gid=51`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `queen_bishop_minr=2`, `need_card=tbl`, `need_card.1=Golden Aging`, `team=0`, `need=tbl`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Presbyopia`
- **Golden Aging**: `cycle=1`, `need=tbl`, `need.1=4`, `need.2=8`, `need_card=tbl`, `team=0`, `pwe=4`, `delayed=tbl`, `delayed.leader_queen_tempo=1`, `need_tag=tbl`, `gid=52`, `tags=tbl`, `tags.1=leader`, `id=Golden Aging`, `exclude_tag=tbl`, `ext=1`, `index=52`, `leader_queen_hp=-1`, `exclude=tbl`, `exclude.1=Guillotine`, `n=1`, `delay=10`, `gain=tbl`, `sac=tbl`
- **Fool Companion**: `need=tbl`, `n=1`, `gid=53`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=53`, `need_card=tbl`, `need_card.1=The Jester`, `team=0`, `need_tag=tbl`, `jester_guard=1`, `pwe=4`, `sac=tbl`, `id=Fool Companion`
- **Force-feeding**: `exclude_tag=tbl`, `sac=tbl`, `n=1`, `gid=54`, `tags=tbl`, `gain=tbl`, `overload=1`, `ext=1`, `index=54`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=Force-feeding`, `full_firepower=1`
- **Seer's Orb**: `n=1`, `need=tbl`, `search=1`, `need_card=tbl`, `team=0`, `pwe=4`, `need_tag=tbl`, `gid=55`, `tags=tbl`, `tags.1=orb`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=55`, `special=orb`, `sac=tbl`, `orb=1`, `id=Seer's Orb`
- **Fearsome**: `exclude_tag=tbl`, `sac=tbl`, `n=2`, `gid=56`, `tags=tbl`, `gain=tbl`, `fearsome=1`, `ext=2`, `index=56`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=Fearsome`, `ammo_max=1`
- **Human Shield**: `need_tag=tbl`, `gain=tbl`, `n=1`, `gid=57`, `tags=tbl`, `id=Human Shield`, `exclude_tag=tbl`, `ext=2`, `index=57`, `need_card=tbl`, `need_card.1=Fearsome`, `team=0`, `need=tbl`, `sac=tbl`, `pwe=4`, `humanshield=1`, `ammo_max=2`
- **Reign of Terror**: `sac=tbl`, `tags=tbl`, `n=1`, `gid=58`, `terrorism=1`, `id=Reign of Terror`, `exclude_tag=tbl`, `ext=2`, `index=58`, `need_card=tbl`, `need_card.1=Fearsome`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `gain=tbl`, `ammo_max=-2`
- **Selective Listening**: `pwe=4`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=59`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `tactic=2`, `id=Selective Listening`, `gid=59`
- **Monarch's Confidence**: `index=60`, `sac=tbl`, `n=1`, `gid=60`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `confidence=1`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `need_chamber_max=2`, `id=Monarch's Confidence`
- **The Mole**: `spy=1`, `n=2`, `gid=61`, `tags=tbl`, `tags.1=mission`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=61`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `sac=tbl`, `pwe=4`, `id=The Mole`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `need.4=0`, `need.5=0`, `need.6=0`, `need.7=0`
- **Elusive**: `index=62`, `need=tbl`, `n=1`, `gid=62`, `tags=tbl`, `tags.1=jump`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `hop=1`, `need_card=tbl`, `team=0`, `elusive=1`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Elusive`
- **Holoking**: `pwe=4`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=63`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `holoking=1`, `id=Holoking`, `gid=63`
- **Cloaking Device**: `need_tag=tbl`, `sac=tbl`, `n=1`, `gid=64`, `tags=tbl`, `tags.1=cloak`, `id=Cloaking Device`, `exclude_tag=tbl`, `ext=2`, `index=64`, `need_card=tbl`, `need_card.1=Holoking`, `team=0`, `holoreveal=1`, `need=tbl`, `pwe=4`, `gain=tbl`, `holocloak=1`
- **Low-Cost Disguise**: `need=tbl`, `n=2`, `sac=tbl`, `tags=tbl`, `tags.1=cloak`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=65`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `pawn_disguise=2`, `pwe=4`, `id=Low-Cost Disguise`, `gid=65`
- **Wand of Souls**: `ext=2`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `wand=tbl`, `wand.1=6`, `index=66`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=1`, `id=Wand of Souls`, `gid=66`
- **Wand of Execution**: `ext=2`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `wand=tbl`, `wand.1=7`, `index=67`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=1`, `id=Wand of Execution`, `gid=67`
- **Patience**: `n=2`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `need_tag=tbl`, `gid=68`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `floor_max=9`, `index=68`, `browse=1`, `ammo_max=1`, `sac=tbl`, `id=Patience`
- **Bold Plan**: `id=Bold Plan`, `n=3`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=69`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `replace_white_card=1`, `gid=69`
- **Silencer**: `need=tbl`, `pwe=4`, `need_tag=tbl`, `need_tag.1=cloak`, `gid=70`, `tags=tbl`, `id=Silencer`, `exclude_tag=tbl`, `ext=2`, `index=70`, `need_card=tbl`, `team=0`, `firerange=-1`, `sac=tbl`, `silencer=1`, `gain=tbl`, `n=1`
- **Ambush**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `flip_on=not_cloaked`, `need_tag=tbl`, `need_tag.1=cloak`, `sac=tbl`, `tags=tbl`, `id=Ambush`, `exclude_tag=tbl`, `ext=2`, `index=71`, `grenade_dmg=1`, `firerange=2`, `gain=tbl`, `gid=71`
- **Ancient Flagstone**: `need_tag=tbl`, `n=1`, `gid=72`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=72`, `need_card=tbl`, `team=0`, `need=tbl`, `sac=tbl`, `flagstones=1`, `pwe=2`, `id=Ancient Flagstone`
- **Tearing Bullets**: `need=tbl`, `n=1`, `sac=tbl`, `tags=tbl`, `tags.1=bleed`, `tags.2=on_hit`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=73`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `tearing=1`, `pwe=4`, `id=Tearing Bullets`, `gid=73`
- **Indelible Memories**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `need_tag=tbl`, `gid=74`, `tags=tbl`, `tags.1=bleed`, `tags.2=grenade`, `id=Indelible Memories`, `exclude_tag=tbl`, `ext=2`, `index=74`, `special=grenade`, `grenades_max=1`, `gain=tbl`, `sac=tbl`, `grenade_bleed=1`
- **Mystic Shackles**: `id=Mystic Shackles`, `n=1`, `gid=75`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=75`, `need_card=tbl`, `team=0`, `need=tbl`, `sac=tbl`, `pwe=4`, `shackles=1`, `need_tag=tbl`, `need_tag.1=orb`
- **Secret Move**: `index=76`, `gain=tbl`, `n=1`, `gid=76`, `tags=tbl`, `tags.1=jump`, `id=Secret Move`, `exclude_tag=tbl`, `ext=2`, `hop=1`, `need_card=tbl`, `team=0`, `need=tbl`, `sac=tbl`, `pwe=4`, `botte=2`, `need_tag=tbl`, `need_tag.1=jump`
- **Sacred Light**: `n=1`, `need=tbl`, `need_card=tbl`, `grenade_proof=1`, `pwe=4`, `grenade_stun=2`, `need_tag=tbl`, `gid=77`, `tags=tbl`, `tags.1=grenade`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=77`, `grenade_dmg=-2`, `special=grenade`, `grenades_max=1`, `team=0`, `sac=tbl`, `id=Sacred Light`
- **Workshop**: `cycle=1`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `delayed=tbl`, `delayed.mk_ammo=2`, `delayed.mk_grenades=1`, `need_tag=tbl`, `need_tag.1=grenade`, `gid=78`, `tags=tbl`, `id=Workshop`, `exclude_tag=tbl`, `ext=2`, `index=78`, `n=1`, `delay=8`, `gain=tbl`, `sac=tbl`
- **Right-hand**: `need=tbl`, `n=1`, `gid=79`, `tags=tbl`, `tags.1=ally`, `gain=tbl`, `allies=tbl`, `allies.1=2`, `ext=3`, `index=79`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Gradual Absolution`, `need_card.1.2=Possessed`, `need_card.1.3=The Red Book`, `team=0`, `exclude_tag=tbl`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Right-hand`
- **Warhorse**: `need=tbl`, `n=1`, `gid=80`, `tags=tbl`, `tags.1=ally`, `gain=tbl`, `allies=tbl`, `allies.1=1`, `ext=3`, `index=80`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Saddle`, `need_card.1.2=Knightmare`, `need_card.1.3=Cavalry`, `team=0`, `exclude_tag=tbl`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Warhorse`
- **Bastion**: `need=tbl`, `n=1`, `gid=81`, `tags=tbl`, `tags.1=ally`, `gain=tbl`, `allies=tbl`, `allies.1=3`, `ext=3`, `index=81`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Highest Dungeon`, `need_card.1.2=Bunker`, `need_card.1.3=Lookout Tower`, `team=0`, `exclude_tag=tbl`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Bastion`
- **Sprint**: `id=Sprint`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=3`, `index=82`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `sprint=1`, `gid=82`
- **Soul Projection**: `pwe=4`, `n=1`, `gid=83`, `tags=tbl`, `tags.1=ally`, `gain=tbl`, `exclude_tag=tbl`, `ext=3`, `index=83`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Undead Armies`, `need_card.1.2=Knightmare`, `team=0`, `need_tag=tbl`, `need=tbl`, `summoner=1`, `sac=tbl`, `id=Soul Projection`
- **Onboarding Party**: `sac=tbl`, `n=1`, `gid=84`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=3`, `index=84`, `need_card=tbl`, `need_card.1=Welcome Gift`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `onboarding=1`, `id=Onboarding Party`
- **Small Key**: `small_key=1`, `n=1`, `gid=85`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=3`, `index=85`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Prison`, `need_card.1.2=Trowel`, `team=0`, `need=tbl`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Small Key`
- **Rapunzel**: `need=tbl`, `n=1`, `gid=86`, `tags=tbl`, `tags.1=ally`, `gain=tbl`, `exclude_tag=tbl`, `ext=3`, `index=86`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Lady in the Tower`, `need_card.1.2=Highest Dungeon`, `team=0`, `rapunzel=1`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Rapunzel`
- **Wand of Treachery**: `ext=3`, `n=1`, `sac=tbl`, `tags=tbl`, `tags.1=ally`, `gain=tbl`, `exclude_tag=tbl`, `wand=tbl`, `wand.1=8`, `index=87`, `need_card=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `pwe=1`, `id=Wand of Treachery`, `gid=87`
- **Guerilla Tactics**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `ammo_max=1`, `sac=tbl`, `tags=tbl`, `tags.1=grenade`, `gain=tbl`, `exclude_tag=tbl`, `ext=3`, `index=88`, `firerange=1`, `special=grenade`, `grenades_max=1`, `id=Guerilla Tactics`, `need_tag=tbl`, `gid=88`
- **Shovel**: `n=1`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=2`, `need_tag=tbl`, `gid=89`, `tags=tbl`, `tags.1=blade`, `tags.2=tunnels`, `gain=tbl`, `exclude_tag=tbl`, `ext=3`, `index=89`, `exclude=tbl`, `exclude.1=King's Shoulders`, `id=Shovel`, `special=dig`, `blade=1`, `sac=tbl`, `tunnels=1`, `hole_start=2`
- **Grindstone**: `cycle=1`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=2`, `delayed=tbl`, `delayed.blade=1`, `need_tag=tbl`, `gid=90`, `tags=tbl`, `id=Grindstone`, `exclude_tag=tbl`, `ext=3`, `index=90`, `n=1`, `delay=6`, `gain=tbl`, `sac=tbl`
- **Death Mark**: `index=91`, `need=tbl`, `n=2`, `gid=91`, `tags=tbl`, `tags.1=on_hit`, `gain=tbl`, `exclude_tag=tbl`, `ext=3`, `sheath=1`, `need_card=tbl`, `team=0`, `firepower=-1`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Death Mark`
- **Shrapnel**: `sac=tbl`, `knockback=15`, `n=2`, `gid=92`, `tags=tbl`, `tags.1=on_hit`, `id=Shrapnel`, `exclude_tag=tbl`, `ext=3`, `index=92`, `need_card=tbl`, `team=0`, `shrapnel=3`, `need=tbl`, `pwe=4`, `gain=tbl`, `need_tag=tbl`, `need_tag.1=on_hit`
- **Backups**: `n=3`, `need=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `exclude_tag=tbl`, `ext=0`, `index=93`, `need_card=tbl`, `team=1`, `id=Backups`, `need_tag=tbl`, `pwe=4`, `gid=100`, `sac=tbl`
- **Cavalry**: `pwe=4`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `exclude_tag=tbl`, `ext=0`, `index=94`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `delay=15`, `id=Cavalry`, `gid=101`
- **Conclave**: `pwe=4`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `gain.2=2`, `exclude_tag=tbl`, `ext=0`, `index=95`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `delay=15`, `id=Conclave`, `gid=102`
- **Entitle**: `gid=103`, `n=1`, `sac=tbl`, `sac.1=0`, `tags=tbl`, `gain=tbl`, `gain.1=1`, `exclude_tag=tbl`, `ext=0`, `index=96`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=Entitle`, `ammo_max=-1`
- **Cardinal**: `gid=104`, `n=1`, `sac=tbl`, `sac.1=0`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `exclude_tag=tbl`, `ext=0`, `index=97`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=Cardinal`, `ammo_max=-1`
- **Remparts**: `n=2`, `need=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=3`, `exclude_tag=tbl`, `ext=0`, `index=98`, `need_card=tbl`, `team=1`, `gid=105`, `need_tag=tbl`, `pwe=4`, `id=Remparts`, `sac=tbl`, `sac.1=0`, `sac.2=0`
- **Pillage**: `need=tbl`, `n=1`, `sac=tbl`, `sac.1=3`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `gain.4=0`, `gain.5=0`, `exclude_tag=tbl`, `ext=0`, `index=99`, `pawn_hp=1`, `team=1`, `need_tag=tbl`, `need_card=tbl`, `pwe=4`, `gid=106`, `id=Pillage`
- **Crusades**: `n=1`, `need=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `exclude_tag=tbl`, `ext=0`, `index=100`, `need_card=tbl`, `team=1`, `gid=107`, `need_tag=tbl`, `pwe=4`, `id=Crusades`, `sac=tbl`, `sac.1=2`
- **Peace**: `n=1`, `need=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `gain.2=2`, `exclude_tag=tbl`, `ext=0`, `index=101`, `need_card=tbl`, `team=1`, `gid=108`, `need_tag=tbl`, `pwe=4`, `id=Peace`, `sac=tbl`, `sac.1=1`
- **King's Mistress**: `gid=109`, `n=1`, `need=tbl`, `need.1=4`, `tags=tbl`, `gain=tbl`, `gain.1=4`, `exclude_tag=tbl`, `ext=0`, `index=102`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `sac=tbl`, `pwe=4`, `id=King's Mistress`, `queen_cage=3`
- **Revolution**: `n=1`, `need=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `gain.4=0`, `gain.5=0`, `gain.6=0`, `exclude_tag=tbl`, `ext=0`, `index=103`, `need_card=tbl`, `team=1`, `gid=110`, `need_tag=tbl`, `pwe=4`, `id=Revolution`, `sac=tbl`, `sac.1=2`
- **Bodyguard**: `need_tag=tbl`, `sac=tbl`, `n=1`, `need=tbl`, `need.1=1`, `need.2=8`, `tags=tbl`, `id=Bodyguard`, `exclude_tag=tbl`, `ext=0`, `index=104`, `need_card=tbl`, `team=1`, `knight_bodyguard=1`, `knight_hp=1`, `pwe=4`, `gain=tbl`, `gid=111`
- **Ruins**: `pwe=4`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=3`, `gain.2=0`, `gain.3=0`, `exclude_tag=tbl`, `ext=0`, `index=105`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `rook_hp=-2`, `id=Ruins`, `gid=112`
- **Assault**: `id=Assault`, `n=1`, `gid=113`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `exclude_tag=tbl`, `ext=0`, `index=106`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `sac=tbl`, `pwe=4`, `pawn_assault=1`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `need.4=0`, `need.5=0`
- **Kite Shield**: `gid=114`, `n=1`, `need=tbl`, `need.1=1`, `need.2=1`, `tags=tbl`, `tags.1=on_hit`, `gain=tbl`, `gain.1=0`, `exclude_tag=tbl`, `ext=0`, `index=107`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `sac=tbl`, `pwe=4`, `id=Kite Shield`, `knight_shield=1`
- **Zealots**: `n=1`, `need=tbl`, `need.1=2`, `need_card=tbl`, `team=1`, `pwe=4`, `flip_on=no_bishop`, `pawn_tempo=-1`, `bishop_tempo=-1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `id=Zealots`, `exclude_tag=tbl`, `ext=0`, `index=108`, `gid=115`, `gain=tbl`
- **Militia**: `gid=116`, `need_tag=tbl`, `n=1`, `pawn_militia=1`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `exclude_tag=tbl`, `ext=0`, `index=109`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=Bloodless Coups`, `sac=tbl`, `pwe=4`, `id=Militia`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`
- **Ammunition Depot**: `tags=tbl`, `n=2`, `sac=tbl`, `rook_shell=2`, `id=Ammunition Depot`, `exclude_tag=tbl`, `ext=0`, `index=110`, `need_card=tbl`, `team=1`, `need=tbl`, `need_tag=tbl`, `pwe=4`, `gain=tbl`, `gain.1=3`, `gid=117`
- **Scouting**: `pawn_tempo=-1`, `n=1`, `sac=tbl`, `sac.1=1`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `exclude_tag=tbl`, `ext=0`, `index=111`, `need_card=tbl`, `team=1`, `need=tbl`, `need_tag=tbl`, `pwe=4`, `gid=118`, `id=Scouting`
- **Pikemen**: `n=1`, `need=tbl`, `need.1=0`, `need.2=0`, `pawn_hp=1`, `team=1`, `pwe=4`, `need_tag=tbl`, `gid=119`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=112`, `id=Pikemen`, `sac=tbl`, `need_card=tbl`, `pawn_reformed=1`, `pawn_pike=1`
- **Ascension**: `ext=0`, `n=1`, `need=tbl`, `need.1=2`, `need.2=2`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `bishop_flying=1`, `index=113`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `sac=tbl`, `pwe=4`, `gid=120`, `id=Ascension`
- **Castle**: `n=1`, `need=tbl`, `need.1=3`, `need.2=8`, `need_card=tbl`, `team=1`, `pwe=4`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `id=Castle`, `exclude_tag=tbl`, `ext=0`, `rook_castle=1`, `exclude=tbl`, `exclude.1=Guillotine`, `index=114`, `gid=121`, `gain=tbl`, `rook_hp=1`
- **Conscription**: `need_tag=tbl`, `pwe=4`, `cycle=1`, `gid=122`, `tags=tbl`, `id=Conscription`, `exclude_tag=tbl`, `ext=0`, `index=115`, `need_card=tbl`, `team=1`, `need=tbl`, `sac=tbl`, `delay=5`, `gain=tbl`, `gain.1=0`, `n=2`
- **Theocracy**: `n=1`, `need=tbl`, `need.1=2`, `need.2=2`, `ruler=2`, `need_card=tbl`, `team=1`, `pwe=4`, `need_tag=tbl`, `gid=123`, `theocracy=1`, `gain=tbl`, `gain.1=2`, `exclude_tag=tbl`, `ext=0`, `index=116`, `bishop_hp=2`, `no_ruler=1`, `exclude=tbl`, `exclude.1=Guillotine`, `tags=tbl`, `tags.1=leader`, `sac=tbl`, `sac.1=5`, `id=Theocracy`
- **Fallen Dynasty**: `need_tag=tbl`, `n=1`, `gid=124`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=0`, `index=117`, `need_card=tbl`, `team=1`, `fallen=1`, `need=tbl`, `pwe=0`, `sac=tbl`, `id=Fallen Dynasty`
- **Iron Maiden**: `n=1`, `need=tbl`, `need.1=4`, `need.2=4`, `need_card=tbl`, `team=1`, `pwe=4`, `flip_on=only_queen`, `need_tag=tbl`, `gid=125`, `tags=tbl`, `id=Iron Maiden`, `exclude_tag=tbl`, `ext=0`, `index=118`, `queen_iron=1`, `queen_tempo=2`, `sac=tbl`, `sac.1=4`, `gain=tbl`
- **Court of the King**: `index=119`, `n=2`, `sac=tbl`, `tags=tbl`, `id=Court of the King`, `exclude_tag=tbl`, `ext=0`, `all_tempo=1`, `need_card=tbl`, `team=1`, `need=tbl`, `need_tag=tbl`, `pwe=4`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `gain.3=2`, `gain.4=3`, `gid=126`
- **The Red Book**: `id=The Red Book`, `need_tag=tbl`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `exclude_tag=tbl`, `ext=0`, `index=120`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=The Royal Hunt`, `exclude.2=Buckler of Limos`, `need=tbl`, `pwe=4`, `gid=127`, `bishop_orth=1`
- **Saboteur**: `bad_shells=1`, `n=2`, `gid=128`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `exclude_tag=tbl`, `ext=0`, `index=121`, `need_card=tbl`, `team=1`, `need=tbl`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `sac.1=0`, `sac.2=0`, `id=Saboteur`
- **Homecoming**: `n=1`, `sac=tbl`, `tags=tbl`, `id=Homecoming`, `exclude_tag=tbl`, `ext=0`, `index=122`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `pwe=0`, `gain=tbl`, `gain.1=4`, `gid=129`
- **Lookout Tower**: `alarm=1`, `pwe=4`, `n=2`, `gid=130`, `tags=tbl`, `id=Lookout Tower`, `exclude_tag=tbl`, `ext=0`, `index=123`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `delay=20`, `sac=tbl`, `gain=tbl`, `gain.1=3`
- **Throne Room**: `n=1`, `need=tbl`, `need.1=5`, `need_card=tbl`, `team=1`, `pwe=4`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `id=Throne Room`, `exclude_tag=tbl`, `ext=0`, `index=124`, `exclude=tbl`, `exclude.1=Guillotine`, `gid=131`, `leader_hp=2`, `gain=tbl`, `queen_hp=1`
- **The Secret Heir**: `id=The Secret Heir`, `need_tag=tbl`, `n=1`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `gain=tbl`, `gain.1=0`, `exclude_tag=tbl`, `ext=0`, `index=125`, `need_card=tbl`, `heir=1`, `exclude=tbl`, `exclude.1=Guillotine`, `need=tbl`, `pwe=4`, `team=1`, `gid=132`
- **Genderqueer**: `pwe=4`, `n=1`, `sac=tbl`, `sac.1=2`, `tags=tbl`, `gain=tbl`, `gain.1=4`, `exclude_tag=tbl`, `ext=0`, `index=126`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `delay=10`, `gid=133`, `id=Genderqueer`
- **Karma**: `sqb_spread=30`, `n=1`, `need=tbl`, `reversable=1`, `need_card=tbl`, `team=1`, `pwe=4`, `reform=1`, `need_tag=tbl`, `gid=134`, `tags=tbl`, `id=Karma`, `exclude_tag=tbl`, `ext=1`, `index=127`, `gain=tbl`, `sac=tbl`, `sqw_firepower=-1`
- **Undead Armies**: `need_tag=tbl`, `sac=tbl`, `n=1`, `knight_bishop_rook_rep=0`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=128`, `pawn_hp=-1`, `team=1`, `need_card=tbl`, `need=tbl`, `pwe=4`, `gid=135`, `id=Undead Armies`
- **Shortage**: `need=tbl`, `n=1`, `need_tag=tbl`, `need_tag.1=grenade`, `sac=tbl`, `sac.1=0`, `tags=tbl`, `id=Shortage`, `exclude_tag=tbl`, `ext=1`, `index=129`, `need_card=tbl`, `team=1`, `gain=tbl`, `grenades_max=-1`, `pwe=4`, `gid=136`, `ammo_max=-3`
- **Succubus**: `need=tbl`, `n=1`, `sac=tbl`, `tags=tbl`, `id=Succubus`, `soul_slot=1`, `ext=1`, `index=130`, `need_card=tbl`, `team=1`, `exclude_tag=tbl`, `need_tag=tbl`, `pwe=4`, `gain=tbl`, `gain.1=4`, `gid=137`
- **Bunker**: `n=1`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `leader_pawn_hp=1`, `need_card=tbl`, `team=1`, `pwe=4`, `need_tag=tbl`, `need_tag.1=grenade`, `sac=tbl`, `sac.1=3`, `tags=tbl`, `tags.1=leader`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=131`, `grenade_dmg=-1`, `exclude=tbl`, `exclude.1=Guillotine`, `gid=138`, `id=Bunker`
- **Sanctity**: `sac=tbl`, `n=1`, `gid=139`, `tags=tbl`, `bishop_sanctity=1`, `exclude_tag=tbl`, `ext=1`, `index=132`, `need_card=tbl`, `need_card.1=Conclave`, `team=1`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=Sanctity`, `gain=tbl`, `gain.1=2`
- **Knightmare**: `exclude_tag=tbl`, `sac=tbl`, `n=1`, `gid=140`, `tags=tbl`, `id=Knightmare`, `knight_wraith=1`, `ext=1`, `index=133`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Fearsome`, `need_card.1.2=Black Mist`, `team=1`, `need_tag=tbl`, `knight_hp=-1`, `pwe=4`, `gain=tbl`, `need=tbl`, `need.1=1`, `need.2=1`
- **Highest Dungeon**: `need_tag=tbl`, `exclude_tag=tbl`, `n=1`, `gid=141`, `tags=tbl`, `id=Highest Dungeon`, `all_hp=1`, `ext=1`, `index=134`, `need_card=tbl`, `team=1`, `sac=tbl`, `gain=tbl`, `pwe=2`, `flip_on=no_rook`, `need=tbl`, `need.1=3`
- **Cathedral**: `index=135`, `n=1`, `sac=tbl`, `sac.1=2`, `tags=tbl`, `gain=tbl`, `gain.1=3`, `exclude_tag=tbl`, `ext=1`, `rook_protect=1`, `need_card=tbl`, `need_card.1=Cardinal`, `team=1`, `need=tbl`, `need_tag=tbl`, `pwe=4`, `gid=142`, `id=Cathedral`
- **The Bridge**: `need_tag=tbl`, `pwe=4`, `n=1`, `gid=143`, `tags=tbl`, `gain=tbl`, `gain.1=1`, `exclude_tag=tbl`, `ext=1`, `index=136`, `need_card=tbl`, `need_card.1=The Moat`, `team=1`, `need=tbl`, `sac=tbl`, `delay=10`, `id=The Bridge`, `bridge=1`
- **Divine Healing**: `need_tag=tbl`, `gain=tbl`, `n=1`, `need=tbl`, `need.1=2`, `tags=tbl`, `id=Divine Healing`, `exclude_tag=tbl`, `ext=1`, `index=137`, `bishop_hp=1`, `team=1`, `need_card=tbl`, `sac=tbl`, `pwe=4`, `gid=144`, `bishop_healer=2`
- **Last Guardian**: `gid=145`, `n=1`, `need=tbl`, `need.1=0`, `need.2=0`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=138`, `need_card=tbl`, `pawn_lastg=1`, `need_tag=tbl`, `sac=tbl`, `pwe=4`, `id=Last Guardian`, `team=1`
- **Trowel**: `need_tag=tbl`, `pwe=4`, `n=1`, `gid=146`, `tags=tbl`, `id=Trowel`, `exclude_tag=tbl`, `ext=1`, `index=139`, `need_card=tbl`, `team=1`, `sac=tbl`, `gain=tbl`, `rook_hp=4`, `flip_on=no_pawn`, `need=tbl`, `need.1=3`, `need.2=0`
- **Full Plate Armor**: `n=1`, `need=tbl`, `all_hp=1`, `all_tempo=1`, `need_card=tbl`, `team=1`, `pwe=4`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=blade`, `id=Full Plate Armor`, `exclude_tag=tbl`, `ext=1`, `index=140`, `exclude=tbl`, `exclude.1=King's Shoulders`, `blade=-1`, `gain=tbl`, `gid=147`
- **Military Academy**: `need_tag=tbl`, `pwe=4`, `n=1`, `gid=148`, `tags=tbl`, `gain=tbl`, `gain.1=1`, `exclude_tag=tbl`, `ext=1`, `index=141`, `need_card=tbl`, `team=1`, `need=tbl`, `sac=tbl`, `delay=10`, `id=Military Academy`, `cycle=1`
- **Witch's Curse**: `n=1`, `need=tbl`, `need.1=4`, `need_card=tbl`, `team=1`, `firepower=-1`, `queen_curse=1`, `pwe=4`, `need_tag=tbl`, `gid=149`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=1`, `index=142`, `firerange=-1`, `sac=tbl`, `spread=10`, `id=Witch's Curse`
- **Saddle**: `need_tag=tbl`, `pwe=4`, `n=1`, `gid=150`, `tags=tbl`, `id=Saddle`, `exclude_tag=tbl`, `ext=1`, `index=143`, `need_card=tbl`, `team=1`, `sac=tbl`, `gain=tbl`, `knight_carry=1`, `knight_tempo=1`, `need=tbl`, `need.1=1`
- **The Jester**: `pwe=4`, `n=1`, `need=tbl`, `need.1=0`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `exclude_tag=tbl`, `ext=1`, `index=144`, `need_card=tbl`, `need_card.1=Throne Room`, `team=1`, `need_tag=tbl`, `sac=tbl`, `jester=1`, `gid=151`, `id=The Jester`
- **Guillotine**: `need=tbl`, `n=1`, `sac=tbl`, `sac.1=5`, `tags=tbl`, `id=Guillotine`, `exclude_tag=tbl`, `exclude_tag.1=leader`, `ext=1`, `index=145`, `need_card=tbl`, `need_card.1=Revolution`, `team=1`, `exclude=tbl`, `exclude.1=Ritual Dagger`, `exclude.2=Subtle Poison`, `exclude.3=Kingdom Wealth`, `exclude.4=Golden Aging`, `exclude.5=Castle`, `exclude.6=Theocracy`, `exclude.7=Throne Room`, `exclude.8=The Secret Heir`, `exclude.9=Bunker`, `exclude.10=Emergency Call`, `exclude.11=Mausoleum`, `exclude.12=King's Look-alike`, `exclude.13=The Royal Hunt`, `exclude.14=Buckler of Limos`, `exclude.15=Vampirism`, `exclude.16=Commoner's Reign`, `exclude.17=Unsettled Throne`, `exclude.18=Anarchy`, `need_tag=tbl`, `pwe=4`, `gain=tbl`, `gid=152`
- **Analysis Paralysis**: `need_tag=tbl`, `gain=tbl`, `n=2`, `gid=153`, `tags=tbl`, `id=Analysis Paralysis`, `exclude_tag=tbl`, `search=1`, `index=146`, `need_card=tbl`, `need_card.1=High Focus`, `team=1`, `need=tbl`, `sac=tbl`, `pwe=4`, `paralysis=6`, `ext=1`
- **Plumed Knight**: `gid=154`, `n=1`, `need=tbl`, `need.1=1`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=147`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `sac=tbl`, `pwe=4`, `id=Plumed Knight`, `choose_knight_plumed=1`
- **Emergency Call**: `leader_emergency=1`, `sac=tbl`, `n=1`, `need=tbl`, `need.1=0`, `need.2=0`, `tags=tbl`, `tags.1=leader`, `gain=tbl`, `gain.1=0`, `exclude_tag=tbl`, `ext=2`, `index=148`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=Guillotine`, `need_tag=tbl`, `pwe=4`, `gid=155`, `id=Emergency Call`
- **Mangonel**: `sac=tbl`, `rook_catapult=1`, `n=1`, `gid=156`, `tags=tbl`, `gain=tbl`, `gain.1=3`, `exclude_tag=tbl`, `ext=2`, `index=149`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `id=Mangonel`, `rook_tempo=2`
- **Governess**: `id=Governess`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `exclude_tag=tbl`, `ext=2`, `index=150`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `gid=157`, `force_promote=4`
- **Mausoleum**: `id=Mausoleum`, `need_tag=tbl`, `n=1`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `gain=tbl`, `gain.1=3`, `exclude_tag=tbl`, `ext=2`, `index=151`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=Guillotine`, `need=tbl`, `pwe=4`, `rook_leaderbond=2`, `gid=158`
- **Reverend Mother**: `tags=tbl`, `n=1`, `gid=159`, `queen_despair=1`, `gain=tbl`, `gain.1=4`, `exclude_tag=tbl`, `ext=2`, `index=152`, `need_card=tbl`, `need_card.1=Theocracy`, `team=1`, `need=tbl`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `id=Reverend Mother`
- **Sokoban**: `id=Sokoban`, `n=1`, `gid=160`, `tags=tbl`, `rook_push=3`, `exclude_tag=tbl`, `ext=2`, `index=153`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `sac=tbl`, `pwe=4`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `need=tbl`, `need.1=3`, `need.2=3`
- **Tag Team**: `n=1`, `need=tbl`, `need.1=2`, `need.2=3`, `need_card=tbl`, `team=1`, `pwe=4`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `rook_swap=tbl`, `rook_swap.1=2`, `rook_bishop_hp=1`, `index=154`, `gid=161`, `ext=2`, `bishop_swap=tbl`, `bishop_swap.1=3`, `id=Tag Team`
- **Unicorn**: `need=tbl`, `n=1`, `sac=tbl`, `tags=tbl`, `id=Unicorn`, `exclude_tag=tbl`, `ext=2`, `index=155`, `knight_charge=1`, `team=1`, `need_tag=tbl`, `need_card=tbl`, `pwe=4`, `gain=tbl`, `gain.1=1`, `gid=162`
- **Lady in the Tower**: `id=Lady in the Tower`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=3`, `exclude_tag=tbl`, `ext=2`, `index=156`, `need_card=tbl`, `rook_killprom=4`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `team=1`, `gid=163`
- **Final Countdown**: `need_tag=tbl`, `sac=tbl`, `n=1`, `gid=164`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=157`, `need_card=tbl`, `team=1`, `deathcount_trig=6`, `need=tbl`, `pwe=4`, `id=Final Countdown`, `deathcount=12`
- **Nomad Life**: `need=tbl`, `n=2`, `gid=165`, `tags=tbl`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `gain.3=2`, `exclude_tag=tbl`, `ext=2`, `index=158`, `need_card=tbl`, `team=1`, `knight_promote=1`, `need_tag=tbl`, `pwe=4`, `sac=tbl`, `sac.1=3`, `id=Nomad Life`
- **Prison**: `sac=tbl`, `n=1`, `need=tbl`, `need.1=1`, `need.2=2`, `need.3=3`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `gain.2=1`, `exclude_tag=tbl`, `ext=2`, `index=159`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `knight_bishop_prison=3`, `pwe=4`, `gid=166`, `id=Prison`
- **Inquisition**: `need=tbl`, `pwe=4`, `need_tag=tbl`, `need_tag.1=mission`, `need_tag.2=cloak`, `gid=167`, `tags=tbl`, `id=Inquisition`, `exclude_tag=tbl`, `ext=2`, `index=160`, `need_card=tbl`, `team=1`, `n=1`, `gain=tbl`, `gain.1=2`, `bishop_uncover=1`, `bishop_investigate=1`, `sac=tbl`, `sac.1=0`
- **King's Look-alike**: `false_king=1`, `n=2`, `need=tbl`, `need_card=tbl`, `team=1`, `pwe=4`, `need_tag=tbl`, `gid=168`, `tags=tbl`, `tags.1=leader`, `id=King's Look-alike`, `exclude_tag=tbl`, `ext=2`, `index=161`, `no_ruler=1`, `exclude=tbl`, `exclude.1=Guillotine`, `gain=tbl`, `gain.1=5`, `leader_hp=1`, `sac=tbl`
- **The Royal Hunt**: `gid=169`, `need_tag=tbl`, `n=2`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=162`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=The Red Book`, `exclude.2=Guillotine`, `need=tbl`, `pwe=4`, `id=The Royal Hunt`, `leader_bow=2`
- **Tragic Homecoming**: `need_tag=tbl`, `n=1`, `queen_hp=2`, `tags=tbl`, `id=Tragic Homecoming`, `exclude_tag=tbl`, `ext=2`, `index=163`, `need_card=tbl`, `team=1`, `need=tbl`, `sac=tbl`, `pwe=0`, `gain=tbl`, `gain.1=4`, `gid=170`
- **Buckler of Limos**: `leader_armorgap=3`, `leader_tempo=1`, `leader_buckler=1`, `need=tbl`, `need_card=tbl`, `team=1`, `pwe=4`, `need_tag=tbl`, `gid=171`, `tags=tbl`, `tags.1=leader`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=164`, `exclude=tbl`, `exclude.1=The Red Book`, `exclude.2=Guillotine`, `need_firepower=5`, `n=1`, `sac=tbl`, `id=Buckler of Limos`
- **Vampirism**: `n=1`, `need=tbl`, `leader_queen_vampire=1`, `need_card=tbl`, `team=1`, `pwe=4`, `need_tag=tbl`, `need_tag.1=bleed`, `gid=172`, `tags=tbl`, `tags.1=leader`, `id=Vampirism`, `exclude_tag=tbl`, `ext=2`, `index=165`, `leader_queen_hp=1`, `exclude=tbl`, `exclude.1=Guillotine`, `gain=tbl`, `sac=tbl`
- **Commoner's Reign**: `n=1`, `need=tbl`, `ruler=1`, `need_card=tbl`, `team=1`, `knight_hp=2`, `pwe=0`, `need_tag=tbl`, `gid=173`, `tags=tbl`, `tags.1=leader`, `gain=tbl`, `gain.1=1`, `exclude_tag=tbl`, `ext=2`, `index=166`, `exclude=tbl`, `exclude.1=Guillotine`, `id=Commoner's Reign`, `sac=tbl`, `sac.1=5`
- **Bouncy Castle**: `n=1`, `need=tbl`, `need_knockback=100`, `need_card=tbl`, `team=1`, `pwe=4`, `need_tag=tbl`, `gid=174`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `trampoline=1`, `index=167`, `id=Bouncy Castle`, `ext=2`, `rook_hp=-2`, `sac=tbl`
- **Self-Defense**: `need_tag=tbl`, `n=1`, `gid=175`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=2`, `index=168`, `need_card=tbl`, `team=1`, `need=tbl`, `knight_hp=2`, `pwe=0`, `sac=tbl`, `id=Self-Defense`
- **Unsettled Throne**: `n=1`, `need=tbl`, `need_heir=1`, `need_card=tbl`, `heir=1`, `pwe=4`, `heirprom=1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `id=Unsettled Throne`, `exclude_tag=tbl`, `ext=2`, `index=169`, `exclude=tbl`, `exclude.1=Guillotine`, `team=1`, `gain=tbl`, `gid=176`
- **Vendetta**: `n=1`, `need=tbl`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Tragic Homecoming`, `need_card.1.2=King's Mistress`, `team=1`, `vendetta=1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=blade`, `blade=1`, `exclude_tag=tbl`, `ext=3`, `index=170`, `exclude=tbl`, `exclude.1=King's Shoulders`, `pwe=8`, `id=Vendetta`, `gain=tbl`, `gid=177`
- **Stoning**: `index=171`, `sac=tbl`, `n=1`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `need.4=0`, `need.5=0`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `ext=3`, `pawn_stoning=1`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=Bloodless Coups`, `need_tag=tbl`, `pwe=4`, `gid=178`, `id=Stoning`
- **Anarchy**: `need_tag=tbl`, `sac=tbl`, `n=1`, `gid=179`, `tags=tbl`, `tags.1=leader`, `id=Anarchy`, `exclude_tag=tbl`, `ext=3`, `index=172`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=Guillotine`, `gain=tbl`, `pwe=2`, `need=tbl`, `need.1=0`, `need.2=1`, `need.3=2`, `need.4=3`, `need.5=4`, `anarchy=1`
- **Auto-da-fe**: `sac=tbl`, `n=1`, `gid=180`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `exclude_tag=tbl`, `ext=3`, `index=173`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Inquisition`, `need_card.1.2=Conclave`, `need_card.1.3=Zealots`, `team=1`, `bishop_censor=1`, `need_tag=tbl`, `pwe=4`, `id=Auto-da-fe`, `need=tbl`, `need.1=2`
- **Late for dinner**: `pwe=4`, `n=1`, `sac=tbl`, `sac.1=0`, `sac.2=1`, `sac.3=2`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=1`, `gain.3=2`, `gain.4=3`, `exclude_tag=tbl`, `ext=3`, `index=174`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Kingdom Wealth`, `need_card.1.2=Final Countdown`, `team=1`, `need_tag=tbl`, `need=tbl`, `delay=10`, `gid=181`, `id=Late for dinner`
- **Excommunication**: `gid=182`, `n=1`, `need=tbl`, `need.1=2`, `tags=tbl`, `exile=15`, `exclude_tag=tbl`, `ext=3`, `index=175`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `sac=tbl`, `pwe=4`, `id=Excommunication`, `gain=tbl`, `gain.1=3`, `gain.2=1`
- **Pyre of Lust**: `need_tag=tbl`, `n=1`, `gid=183`, `tags=tbl`, `gain=tbl`, `gain.1=4`, `exclude_tag=tbl`, `ext=3`, `index=176`, `need_card=tbl`, `team=1`, `sac=tbl`, `id=Pyre of Lust`, `pwe=2`, `need=tbl`, `need.1=2`, `exile=15`
- **Gatehouse**: `n=1`, `need=tbl`, `need.1=3`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Remparts`, `need_card.1.2=Trowel`, `team=1`, `pwe=4`, `rook_spawn=1`, `rook_tempo=2`, `sac=tbl`, `tags=tbl`, `id=Gatehouse`, `exclude_tag=tbl`, `ext=3`, `index=177`, `gid=184`, `rook_hp=-1`, `gain=tbl`, `need_tag=tbl`
- **Lightfoot**: `id=Lightfoot`, `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `exclude_tag=tbl`, `ext=3`, `index=178`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `gid=185`, `pawn_lightfoot=1`
- **Loyalist March**: `need_tag=tbl`, `n=1`, `gid=186`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `gain.4=0`, `gain.5=0`, `gain.6=0`, `gain.7=0`, `gain.8=0`, `exclude_tag=tbl`, `ext=3`, `index=179`, `need_card=tbl`, `team=1`, `need=tbl`, `sac=tbl`, `pwe=2`, `id=Loyalist March`, `delay=10`
- **Trench War**: `hole_cover=1`, `need_tag=tbl`, `n=2`, `gid=187`, `tags=tbl`, `id=Trench War`, `exclude_tag=tbl`, `ext=3`, `index=180`, `need_card=tbl`, `team=1`, `need=tbl`, `sac=tbl`, `pwe=2`, `gain=tbl`, `gain.1=1`, `hole_start=5`
- **Catacombs**: `need=tbl`, `gain=tbl`, `gain.1=3`, `need_tag=tbl`, `need_tag.1=tunnels`, `hole_solid=1`, `tags=tbl`, `id=Catacombs`, `exclude_tag=tbl`, `ext=3`, `index=181`, `need_card=tbl`, `team=1`, `sac=tbl`, `n=1`, `pwe=4`, `spread=10`, `gid=188`
- **Flesh Wall**: `need_tag=tbl`, `n=1`, `gid=189`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `exclude_tag=tbl`, `pawn_block=1`, `index=182`, `need_card=tbl`, `team=1`, `need=tbl`, `sac=tbl`, `pwe=2`, `ext=3`, `id=Flesh Wall`
- **Hired Blade**: `id=Hired Blade`, `n=2`, `gid=190`, `tags=tbl`, `gain=tbl`, `gain.1=12`, `exclude_tag=tbl`, `ext=3`, `index=183`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `pwe=4`, `sac=tbl`, `sac.1=0`, `ammo_max=-1`
- **Oathkeeper**: `n=1`, `sac=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=13`, `exclude_tag=tbl`, `ext=3`, `index=184`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `pwe=2`, `id=Oathkeeper`, `gid=191`
- **Redemption**: `id=Redemption`, `n=1`, `gid=192`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `exclude_tag=tbl`, `ext=3`, `index=185`, `need_card=tbl`, `team=1`, `need=tbl`, `sac=tbl`, `pwe=4`, `need_tag=tbl`, `need_tag.1=ally`, `redemption=1`
- **EXCLUDE pairs**: `Royal Loafers<>Sawed-off Justice`, `Militia<>Bloodless Coups`, `The Red Book<>The Royal Hunt`, `The Red Book<>Buckler of Limos`, `Bloodless Coups<>Stoning`

## 12c. Offer-roll choices & filters (build 5+)

- **candidate**: `id=Royal Loafers`, `special=strafe`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Majestic Censer`, `special=nil`, `wand=nil`, `soul_slot=1`, `need_soul=nil`
- **candidate**: `id=Sacred Crown`, `special=nil`, `wand=nil`, `soul_slot=nil`, `need_soul=1`
- **candidate**: `id=Engraved Scope`, `special=scope`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Downpour`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Frenzy`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Wrath`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Wings`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Gradual Absolution`, `special=nil`, `wand=nil`, `soul_slot=nil`, `need_soul=2`
- **candidate**: `id=Wand of Gust`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Unjust Decree`, `special=decree`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Kingly Alms`, `special=grenade`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Possessed`, `special=nil`, `wand=nil`, `soul_slot=2`, `need_soul=nil`
- **candidate**: `id=Philanthropy`, `special=grenade`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Hypnosis`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Seer's Orb`, `special=orb`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Souls`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Execution`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Indelible Memories`, `special=grenade`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Sacred Light`, `special=grenade`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Treachery`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Guerilla Tactics`, `special=grenade`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Shovel`, `special=dig`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Succubus`, `special=nil`, `wand=nil`, `soul_slot=1`, `need_soul=nil`
- **candidate**: `id=Royal Loafers`, `special=strafe`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Majestic Censer`, `special=nil`, `wand=nil`, `soul_slot=1`, `need_soul=nil`
- **candidate**: `id=Sacred Crown`, `special=nil`, `wand=nil`, `soul_slot=nil`, `need_soul=1`
- **candidate**: `id=Engraved Scope`, `special=scope`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Downpour`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Frenzy`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Wrath`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Wings`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Gradual Absolution`, `special=nil`, `wand=nil`, `soul_slot=nil`, `need_soul=2`
- **candidate**: `id=Wand of Gust`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Unjust Decree`, `special=decree`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Kingly Alms`, `special=grenade`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Possessed`, `special=nil`, `wand=nil`, `soul_slot=2`, `need_soul=nil`
- **candidate**: `id=Philanthropy`, `special=grenade`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Hypnosis`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Seer's Orb`, `special=orb`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Souls`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Execution`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Indelible Memories`, `special=grenade`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Sacred Light`, `special=grenade`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Wand of Treachery`, `special=nil`, `wand=tbl`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Guerilla Tactics`, `special=grenade`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Shovel`, `special=dig`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **candidate**: `id=Succubus`, `special=nil`, `wand=nil`, `soul_slot=1`, `need_soul=nil`

## 12d. Souls, scepters & pieces probe (build 5+)

- `piece|type=0|name=pawn|hp=3|tempo=5|danger=1`
- `piece_0|type=0`
- `piece_0|danger=1`
- `piece_0|hdy=2`
- `piece_0|behavior=tbl`
- `piece_0|behavior.1=tbl`
- `piece_0|behavior.1.1=1`
- `piece_0|behavior.1.2=1`
- `piece_0|behavior.1.3=1`
- `piece_0|behavior.1.native=1`
- `piece_0|behavior.1.id=line`
- `piece_0|behavior.1.move=1`
- `piece_0|behavior.2=tbl`
- `piece_0|behavior.2.1=4`
- `piece_0|behavior.2.2=5`
- `piece_0|behavior.2.3=1`
- `piece_0|behavior.2.native=1`
- `piece_0|behavior.2.id=line`
- `piece_0|behavior.2.atk=1`
- `piece_0|index=0`
- `piece_0|hp=3`
- `piece_0|sided=1`
- `piece_0|name=pawn`
- `piece_0|tempo=5`
- `piece_0|seek=wdist`
- `piece_0|fields_shown=10`
- `piece|type=1|name=knight|hp=3|tempo=3|danger=3`
- `piece_1|type=1`
- `piece_1|danger=3`
- `piece_1|hdy=1`
- `piece_1|behavior=tbl`
- `piece_1|behavior.1=tbl`
- `piece_1|behavior.1.1=2`
- `piece_1|behavior.1.2=-1`
- `piece_1|behavior.1.3=2`
- `piece_1|behavior.1.4=1`
- `piece_1|behavior.1.5=1`
- `piece_1|behavior.1.6=2`
- `piece_1|behavior.1.7=-1`
- `piece_1|behavior.1.8=2`

## 12e. Damage & bullet pipeline probe (build 5+)

- `mk_bullet|n=1|a1=176.10476309722|a2=135.29047976963|a3=0.51206737889202|a4=8`
- `mk_bullet|n=2|a1=176.10476309722|a2=135.29047976963|a3=0.40333482563488|a4=8`
- `mk_bullet|n=3|a1=176.10476309722|a2=135.29047976963|a3=0.41173865790238|a4=8`
- `mk_bullet|n=4|a1=176.10476309722|a2=135.29047976963|a3=0.55579765576809|a4=8`
- `fire|n=1|ammo=5|chamber=0|bullets=4`
- `bullet|shot_n=1|idx=1|dmg=1|pierce=0|shot=true|x=176.10476309722|y=135.29047976963|life=8`
- `bullet|shot_n=1|idx=2|dmg=1|pierce=0|shot=true|x=176.10476309722|y=135.29047976963|life=9`
- `bullet|shot_n=1|idx=3|dmg=1|pierce=0|shot=true|x=176.10476309722|y=135.29047976963|life=8`
- `bullet|shot_n=1|idx=4|dmg=1|pierce=0|shot=true|x=176.10476309722|y=135.29047976963|life=10`
- `xpl|n=1|a1=tbl|a2=nil|a3=nil|a4=nil`
- `xpl_arg1|walked=true`
- `xpl_arg1|in_move=false`
- `xpl_arg1|dcx=0`
- `xpl_arg1|dcy=0`
- `xpl_arg1|vy=0`
- `xpl_arg1|frict=1`
- `xpl_arg1|vx=0`
- `xpl_arg1|cd=0`
- `xpl_arg1|dp=3`
- `xpl_arg1|upd=fn`
- `xpl_arg1|dr=fn`
- `xpl_arg1|flx=false`
- `xpl_arg1|truncated=true`
- `xpl_arg1|fields_shown=12`
- `xpl|n=2|a1=tbl|a2=nil|a3=nil|a4=nil`
- `xpl_arg1|t=537`
- `xpl_arg1|x=144`
- `xpl_arg1|y=142`
- `xpl_arg1|dcx=0`
- `xpl_arg1|dcy=0`

## 12f. Input & button-remap probe (build 5+)

- `defbtn_api=available`
- `btn|validate=false`
- `btn|cancel=false`
- `btn|shoot=false`
- `btn|special=false`
- `btn|reload=false`
- `btn|unsafe=false`
- `btn|ctrl=false`
- `btncode|m:lb=false`
- `btncode|m:rb=false`
- `btncode|m:mb=false`
- `input|probed=10|source=confirmed_list|status=done`
- `global|MOUSE=true`
- `global|INPUT_ASSIGNEMENT=			validate> c:a, m:lb`
- `global|SHOOT_BUTTON=RT`
- `global|RELOAD_BUTTON=Y`
- `global|SPECIAL_BUTTON=X`
- `global|CONFIRM_BUTTON=A`
- `global|SNAP_KEY=k:f1`
- `global|mcl=nil`
- `global|mcr=nil`
- `global|mlb=nil`
- `global|mx=nil`
- `global|my=nil`
- `menu_but|n=1|id=play`
- `menu_but_1|fly=false`
- `menu_but_1|t=0`
- `menu_but_1|dp=3`
- `menu_but_1|vx=0`
- `menu_but_1|hh=16`
- `menu_but_1|x=212`
- `menu_but_1|y=108.5`
- `menu_but_1|fr=0`
- `menu_but_1|ww=16`
- `menu_but_1|we=0`
- `menu_but_1|dcy=0`
- `menu_but_1|dcx=0`
- `menu_but_1|vy=0`
- `menu_but_1|frict=1`
- `menu_but_1|flx=false`

## 12g. Dev panel, Mod Menu & Save persistence (build 5+)

- `bank|restored=true|magic=505`
- `bank|ready=true|magic=505|budget=1`
- `cfg|on=0|dmg=1-1|crit=0%|crit_dmg=2|pierce_crit=1|card_mode=auto|safe=0|god_mode=false`
- `api|remove_buts=fn|goto_sq=fn|get_allies=fn|get_free_squares=fn|get_nearest_free_square=fn|black_mist_check=fn|get_dodge=fn|fx_spawn=fn|reload=fn|refill_ammo=fn|can_reload=fn|need_reload=fn|clip=fn|chamber=nil|is_free=fn|flr=fn`
- `menu_state|n=1|menu=nil|mMenu=nil`
- `menu|widgets_added=true|entry=mods|back=true`
- `menu|widgets_added=true|entry=back|back=true`
- `bank|restored=true|magic=505`
- `bank|ready=true|magic=505|budget=1`
- `cfg|on=0|dmg=1-1|crit=0%|crit_dmg=2|pierce_crit=1|card_mode=auto|safe=0|god_mode=false`
- `api|remove_buts=fn|goto_sq=fn|get_allies=fn|get_free_squares=fn|get_nearest_free_square=fn|black_mist_check=fn|get_dodge=fn|fx_spawn=fn|reload=fn|refill_ammo=fn|can_reload=fn|need_reload=fn|clip=fn|chamber=nil|is_free=fn|flr=fn`
- `menu_state|n=1|menu=nil|mMenu=nil`
- `menu|widgets_added=true|entry=mods|back=true`
- `menu|widgets_added=true|entry=back|back=true`
- `panel|available=true|native=mk_text_but`
- `panel|width=320|y=128`
- `panel|open=true|page=1|buttons=13`
- `cfg|on=0|dmg=1-1|crit=0%|crit_dmg=2|pierce_crit=1|card_mode=auto|safe=0|god_mode=false`
- `menu_state|n=2|menu=nil|mMenu=tbl`
- `mMenu|y=101.41857910156`
- `mMenu|x=173.52647399902`
- `mMenu|fields_shown=2`
- `menu|widgets_added=true|entry=mods|back=true`
- `menu|widgets_added=true|entry=back|back=true`
- `menu_state|n=3|menu=nil|mMenu=tbl`
- `mMenu|y=143`
- `mMenu|x=222`
- `mMenu|fields_shown=2`

## 12h. Build 7 — panel v2, damage/crit, dodge & engine-call trace

- engine calls: **4 started · 4 ok · 0 blocked by SAFE**
- call names: `newbnk`×2, `savbnk`×2
- `SKUI|cfg|on=0|dmg=1-1|crit=0%|crit_dmg=2|pierce_crit=1|card_mode=auto|safe=0|god_mode=false`
- `SKUI|api|remove_buts=fn|goto_sq=fn|get_allies=fn|get_free_squares=fn|get_nearest_free_square=fn|black_mist_check=fn|get_dodge=fn|fx_spawn=fn|reload=fn|refill_ammo=fn|can_reload=fn|need_reload=fn|clip=fn|chamber=nil|is_free=fn|flr=fn`
- `SKUI|menu|widgets_added=true|entry=mods|back=true`
- `SKUI|menu|widgets_added=true|entry=back|back=true`
- `SKUI|cfg|on=0|dmg=1-1|crit=0%|crit_dmg=2|pierce_crit=1|card_mode=auto|safe=0|god_mode=false`
- `SKUI|api|remove_buts=fn|goto_sq=fn|get_allies=fn|get_free_squares=fn|get_nearest_free_square=fn|black_mist_check=fn|get_dodge=fn|fx_spawn=fn|reload=fn|refill_ammo=fn|can_reload=fn|need_reload=fn|clip=fn|chamber=nil|is_free=fn|flr=fn`
- `SKUI|menu|widgets_added=true|entry=mods|back=true`
- `SKUI|menu|widgets_added=true|entry=back|back=true`
- `SKUI|panel|available=true|native=mk_text_but`
- `SKUI|panel|width=320|y=128`
- `SKUI|panel|open=true|page=1|buttons=13`
- `SKUI|cfg|on=0|dmg=1-1|crit=0%|crit_dmg=2|pierce_crit=1|card_mode=auto|safe=0|god_mode=false`
- `SKUI|menu|widgets_added=true|entry=mods|back=true`
- `SKUI|menu|widgets_added=true|entry=back|back=true`

## 13. Next step

- Promote confirmed entries into `notes/map.md` (replace the TBD lines).
- Pick the dev-cheat panel targets from the ammo/UI candidate lists.
- Lines from other systems in the log: 1910 (ignored; raise an issue if the game seems noisy).
