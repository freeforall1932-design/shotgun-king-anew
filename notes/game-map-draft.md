# Draft game map — generated from `log.txt`

> Generated 2026-10-03 17:16 by `tools/parse_log.py`. **Draft**: everything here comes from the diagnostics mod's live log; promote confirmed facts into `notes/map.md` by hand.

## 1. Did the mod load?

- ✅ mod loaded — build 4, mod_index 1
- ✅ found itself in MODLIST; active=True
- ✅ READY line: build 4, 5 hooks registered, 920 globals visible

## 2. API availability (planned functions)

- available (33): `_log`, `concat`, `add`, `del`, `all`, `get_slot_cards`, `gsq`, `mk_menu_but`, `init_menu`, `spawn_pieces`, `new_piece`, `setup_piece`, `new_turn`, `new_level`, `add_card`, `new_card`, `CARDS`, `get_disp_stats`, `draw_mode`, `goto_sq`, `get_range`, `throw_grenade`, `spend_hop`, `uplift`, `check_cards_auto_flip`, `flip_card`, `unflip_card`, `mk_hint_but`, `set_mode`, `init_game`, `init_codex`, `opp_turn`, `wait`
- **not found** (4): `append`, `prepend`, `gimme`, `edit_disp_stats`
- Not found = not in `gimme("global")`: either the name is wrong or it is engine-internal. Adjust plans before coding against those.

## 3. Hooks & event dispatch

Registered (append) hooks:
- `new_turn` (id `sk-rework:turn`)
- `new_level` (id `sk-rework:level`)
- `setup_piece` (id `sk-rework:setup_piece`)
- `add_card` (id `sk-rework:add_card`)
- `init_game` (id `sk-rework:init_game`)

| event | via append() hook | via on_* callback probe |
|---|---|---|
| add_card | 4 | — |
| init_game | 4 | — |
| new_level | 6 | — |
| setup_piece | 125 (sampled: 34 lines) | — |

- **Verdict:** append() hooks fire, `on_*` probes do not → for plain mods, events must be hooked with `append()` on game globals (the `on_*` dispatch comes from the Glacies Module Terminal mod, matching what the workshop mods show).

## 4. Live state samples

| turn | bads | bullets | hero_px | hero_py |
|---|---|---|---|---|
| 1 | 11 | 0 | 4 | 7 |
| 2 | 11 | 0 | 3 | 6 |
| 3 | 11 | 0 | 2 | 5 |
| 4 | 11 | 0 | 2 | 5 |
| 5 | 9 | 0 | 2 | 5 |
| … | … | … | … | … |
| 27 | 4 | 0 | 2 | 5 |
| 28 | 3 | 0 | 2 | 5 |
| 29 | 2 | 0 | 2 | 5 |
| 30 | 2 | 0 | 3 | 5 |
| 50 | 5 | 0 | 3 | 6 |

## 5. Object model (real field names from the running game)

- **piece**: `vy=0`, `frict=1`, `sq.x=128`, `sq.y=30`, `sq.vy=0`, `sq.frict=1`, `sq.fly=false`, `sq.dp=1`, `hdy=0`, `we=0`, `name=bishop`, `cd=0`, `vx=0`, `dcx=0`, `dcy=0`, `fields_shown=15`, `nocarry=1`, `reap=1`
- **hero**: `vy=0`, `frict=1`, `sq.vy=0`, `sq.frict=1`, `sq.dist=0`, `sq.we=0`, `sq.vx=0`, `sq.dcx=0`, `free_souls=0`, `hdy=0`, `sweaty=false`, `grenade_ready=false`, `we=0`, `name=king`, `cd=3`, `fields_shown=15`
- **hero.sq**: `vy=0`, `frict=1`, `dist=0`, `p.vy=0`, `p.frict=1`, `p.free_souls=0`, `p.hdy=0`, `p.sweaty=false`, `op.vy=0`, `op.frict=1`, `op.free_souls=0`, `op.hdy=0`, `op.sweaty=false`, `we=0`, `vx=0`, `dcx=0`, `dcy=0`, `fr=0`, `hh=16`, `flx=false`
- **card**: `vy=0`, `frict=1`, `we=0`, `vx=0`, `dcx=0`, `dcy=0`, `ww=16`, `fields_shown=8`, `gain.1=2`, `gain.2=1`, `gain.3=2`, `gain.4=3`, `hop_dmg=1`, `bishop_orth=1`

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

- entry 1: `desc=Ammo & gameplay rework (private personal-use project).`, `name=sk-rework`, `num=1`, `exists=true`, `cover=mods/sk-rework/cover.png`, `folder=mods/sk-rework`, `author=freeforall1932`, `here=true`, `script=mods/sk-rework/script.lua`, `title=SK Rework`, `mode_description=tbl`, `save=sk-rework`, `active=true`, `priority_hint=0`
- entry 2: `desc=Broken oaths and holy corruption.`, `name=disgraced_justice`, `exists=true`, `folder=mods/disgraced_justice`, `author=Lorina Sonetto & Bob Qwerty`, `here=true`, `script=mods/disgraced_justice/script.lua`, `title=Disgraced Justice`, `save=disgraced_justice`, `active=false`, `priority_hint=0`
- entry 3: `desc=This mod itself doesn't add any content. Only empowers other mods to have additional features.`, `name=extra features`, `exists=true`, `cover=mods/extra features/cover.png`, `folder=mods/extra features`, `author=Glacies`, `here=true`, `script=mods/extra features/script.lua`, `title=Glacies' Extra Features`, `id=3145848395`, `mode_description=tbl`, `save=extra features`, `active=false`, `priority_hint=0`
- entry 4: `desc=Modder tool. DOESN'T ADD ANY CONTENT.`, `name=glac terminal`, `exists=true`, `cover=mods/glac terminal/cover.png`, `folder=mods/glac terminal`, `author=Glacies`, `here=true`, `script=mods/glac terminal/script.lua`, `title=Glacies Module Terminal`, `id=3144832438`, `mode_description=tbl`, `save=glac terminal`, `active=false`, `priority_hint=-3`
- entry 5: `desc=Adds a bunch of ingame mechanics that can be used by other mods,`, `name=glacies collection`, `exists=true`, `cover=mods/glacies collection/cover.png`, `folder=mods/glacies collection`, `author=Glacies`, `here=true`, `script=mods/glacies collection/script.lua`, `title=Glacies' Collection`, `id=3148586988`, `mode_description=tbl`, `save=glacies collection`, `active=false`, `priority_hint=0`
- entry 6: `desc=Hold middle wheel over a square to see the probabilities or average damages of a grenade.`, `name=grenade predictor`, `exists=true`, `cover=mods/grenade predictor/cover.png`, `folder=mods/grenade predictor`, `author=Glacies`, `here=true`, `mode_record=tbl`, `script=mods/grenade predictor/script.lua`, `title=Grenade Predictor`, `id=3449354474`, `mode_description=tbl`, `active=false`, `save=grenade predictor`, `priority_hint=0`
- entry 7: `desc=The title is a lie. This mod isn't as hard as a nightmare at all.`, `name=nightmare`, `id=3197738029`, `exists=true`, `cover=mods/nightmare/cover.png`, `folder=mods/nightmare`, `author=Glacies`, `here=true`, `mode_record=tbl`, `script=mods/nightmare/script.lua`, `title=Nightmare Mode`, `mode_description=tbl`, `modes=tbl`, `active=false`, `save=nightmare`, `priority_hint=0`
- entry 8: `desc=Restarts the current floor after you die.`, `name=retry`, `exists=true`, `cover=mods/retry/cover.png`, `folder=mods/retry`, `author=Glacies`, `here=true`, `script=mods/retry/script.lua`, `title=Retry after Death`, `id=3626751996`, `mode_description=tbl`, `save=retry`, `active=false`, `priority_hint=0`
- entry 9: `desc=`, `name=royal card lab`, `id=3144064207`, `exists=true`, `cover=mods/royal card lab/cover.png`, `folder=mods/royal card lab`, `author=Glacies`, `here=true`, `script=mods/royal card lab/script.lua`, `title=Royal Card Lab`, `mode_description=tbl`, `priority_hint=-1`, `modes=tbl`, `active=false`, `save=royal card lab`
- entry 10: `desc=An endless adventure in which your typical arsenal is replaced with a shitty rifle'`, `name=Shootout`, `exists=true`, `cover=mods/Shootout/cover.png`, `folder=mods/Shootout`, `author=unknown2559`, `here=true`, `script=mods/Shootout/script.lua`, `title=Shootout: the Rifle King Adventure`, `priority_hint=0`, `save=Shootout`, `active=false`, `modes=tbl`
- entry 11: `desc=Features:`, `name=show exclude`, `exists=true`, `cover=mods/show exclude/cover.png`, `folder=mods/show exclude`, `author=Glacies`, `here=true`, `script=mods/show exclude/script.lua`, `title=Better Codex`, `id=3145391294`, `mode_description=tbl`, `save=show exclude`, `active=false`, `priority_hint=0`
- entry 12: `desc=Fairy chess piecess for Shotgun King. Contains a few basic fairy pieces.`, `langs=tbl`, `exists=true`, `author=sub122`, `priority_hint=1`, `mode_description=tbl`, `name=some_fairy_pieces`, `folder=mods/some_fairy_pieces`, `here=true`, `mode_record=tbl`, `script=mods/some_fairy_pieces/script.lua`, `title=Fairy Pieces for SGK`, `active=false`, `save=some_fairy_pieces`, `modes=tbl`, `id=3342310033`
- entry 13: `desc=[h2] Content [/h2]`, `name=the art of war`, `exists=true`, `cover=mods/the art of war/cover.png`, `folder=mods/the art of war`, `author=Glacies`, `here=true`, `script=mods/the art of war/script.lua`, `title=Military Tactics -The Art of War-`, `id=3512338449`, `mode_description=tbl`, `save=the art of war`, `active=false`, `priority_hint=-1`
- entry 14: `desc=The white army is getting bigger, this mod that adds a whole  lots of new pieces for the white army, as well as a special throne mod where the difficulties all affects these new pieces instead.`, `name=the_magnificient_quartz_army`, `title=The Magnificent Quartz Army`, `exists=true`, `id=3151846036`, `folder=mods/the_magnificient_quartz_army`, `author=matheo000`, `here=true`, `save=the_magnificient_quartz_army`, `script=mods/the_magnificient_quartz_army/script.lua`, `mode_description=tbl`, `langs=tbl`, `modes=tbl`, `active=false`, `cover=mods/the_magnificient_quartz_army/tmqa_cover.png`

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

## 13. Next step

- Promote confirmed entries into `notes/map.md` (replace the TBD lines).
- Pick the dev-cheat panel targets from the ammo/UI candidate lists.
- Lines from other systems in the log: 1547 (ignored; raise an issue if the game seems noisy).
