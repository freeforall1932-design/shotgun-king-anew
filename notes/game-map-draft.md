# Draft game map — generated from `log.txt`

> Generated 2026-10-04 09:32 by `tools/parse_log.py`. **Draft**: everything here comes from the diagnostics mod's live log; promote confirmed facts into `notes/map.md` by hand.

## 1. Did the mod load?

- ✅ mod loaded — build 6, mod_index 1
- ✅ found itself in MODLIST; active=True
- ✅ READY line: build 6, 30 hooks registered, 920 globals visible
- ✅ probe blocks completed: `cards`, `exclude`, `souls`, `bank`, `input`

## 2. API availability (planned functions)

- available (63): `_log`, `concat`, `add`, `del`, `all`, `get_slot_cards`, `gsq`, `mk_menu_but`, `mk_text_but`, `mk_but`, `init_menu`, `spawn_pieces`, `new_piece`, `setup_piece`, `new_turn`, `new_level`, `add_card`, `new_card`, `CARDS`, `EXCLUDE`, `PIECES`, `get_disp_stats`, `draw_mode`, `goto_sq`, `get_range`, `throw_grenade`, `spend_hop`, `uplift`, `check_cards_auto_flip`, `flip_card`, `unflip_card`, `set_mode`, `init_game`, `init_codex`, `opp_turn`, `wait`, `inc_ammo`, `give_ammo`, `reload`, `pick`, `add_any_card`, `level_up`, `is_card_available`, `newbnk`, `bget`, `bset`, `defbtn`, `btn`, `btnp`, `btnr`, `fire`, `mk_bullet`, `hit`, `ev_hit`, `xpl`, `add_soul`, `activate_soul`, `add_soul_slot`, `add_scepter`, `activate_scepter`, `recal_scepters`, `TEST_SOULS`, `MOUSE`
- **not found** (5): `append`, `prepend`, `gimme`, `savbnk`, `scepters`
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
| add_card | 2 | — |
| cheat_ammo | 9 | — |
| cheat_card | 2 | — |
| cheat_spawn | 39 | — |
| init_game | 5 | — |
| new_level | 5 | — |
| setup_piece | 175 (sampled: 36 lines) | — |

- **Verdict:** append() hooks fire, `on_*` probes do not → for plain mods, events must be hooked with `append()` on game globals (the `on_*` dispatch comes from the Glacies Module Terminal mod, matching what the workshop mods show).

## 4. Live state samples

| turn | bads | bullets | hero_px | hero_py | ammo | chamber | free_souls |
|---|---|---|---|---|---|---|---|
| 1 | 12 | 0 | 3 | 7 | 6 | 1 | 0 |
| 2 | 12 | 0 | 3 | 7 | 6 | 0 | 0 |
| 3 | 12 | 0 | 3 | 7 | 4 | 1 | 0 |
| 4 | 12 | 0 | 3 | 7 | 4 | 0 | 0 |
| 5 | 12 | 0 | 4 | 7 | 6 | 1 | 0 |
| … | … | … | … | … | … | … | … |
| 26 | 12 | 0 | 2 | 6 | 7 | 1 | 0 |
| 27 | 12 | 0 | 1 | 5 | 7 | 1 | 0 |
| 28 | 12 | 0 | 1 | 5 | 7 | 0 | 0 |
| 29 | 12 | 0 | 2 | 6 | 6 | 1 | 0 |
| 30 | 12 | 0 | 3 | 7 | 7 | 1 | 0 |

## 5. Object model (real field names from the running game)

- **piece**: `upd=fn`, `sq=tbl`, `sq.highlight=false`, `sq.p=tbl`, `sq.p.upd=fn`, `sq.p.sq=tbl`, `sq.p.vx=0`, `sq.p.bad=true`, `sq.p.t=0`, `sq.p.team=1`, `sq.p.hp_max=11`, `sq.p.name=king`, `sq.p.truncated=true`, `sq.stack=tbl`, `sq.upd=fn`, `sq.dr=fn`, `sq.moat=false`, `sq.vx=0`, `sq.dcy=0`, `sq.frict=1`
- **hero**: `see_hat=false`, `upd=fn`, `sq=tbl`, `sq.risk=0`, `sq.upd=fn`, `sq.vx=0`, `sq.op=tbl`, `sq.op.see_hat=false`, `sq.op.upd=fn`, `sq.op.sq=tbl`, `sq.op.grenade_ready=true`, `sq.op.current_an=-0.46288803657627`, `sq.op.vx=0`, `sq.op.ready=false`, `sq.op.bad=false`, `sq.op.truncated=true`, `sq.t=406`, `sq.ww=16`, `sq.hh=16`, `sq.mark=tbl`
- **hero.sq**: `risk=0`, `upd=fn`, `vx=0`, `op=tbl`, `op.see_hat=false`, `op.upd=fn`, `op.sq=tbl`, `op.sq.risk=0`, `op.sq.upd=fn`, `op.sq.vx=0`, `op.sq.op=tbl`, `op.sq.t=406`, `op.sq.ww=16`, `op.sq.hh=16`, `op.sq.mark=tbl`, `op.sq.truncated=true`, `op.grenade_ready=true`, `op.current_an=-0.46288803657627`, `op.vx=0`, `op.ready=false`
- **stack**: `boss_hprc=200`, `chamber_max=1`, `grenade_dmg=2`, `special=grenade`, `blood_bowl=0`, `ammo_regen=1`, `pawn_hp=1`, `gid=7`, `queen_hp=1`, `knight_hp=1`, `pawn_global_promote=1`, `bishop_hp=1`, `rook_hp=3`, `grenades_max=1`, `surrender=1`, `firerange=3`, `truncated=true`, `fields_shown=16`
- **card**: `index=82`, `ex=7`, `twcv=fn`, `gid=82`, `need=tbl`, `twf=fn`, `twc=0`, `tws=30`, `ey=13`, `need_card=tbl`, `team=0`, `pwe=4`, `sl=tbl`, `sl.vx=0`, `sl.dcy=0`, `sl.ca=tbl`, `sl.ca.index=82`, `sl.ca.ex=7`, `sl.ca.twcv=fn`, `sl.ca.gid=11`

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

- entry 1: `cover=mods/sk-rework/cover.png`, `num=1`, `here=true`, `save=sk-rework`, `exists=true`, `name=sk-rework`, `title=SK Rework`, `author=freeforall1932`, `folder=mods/sk-rework`, `desc=SK Rework — Build 6 (Phase 2c + diagnostics). Build 5 crashed at boot in`, `priority_hint=0`, `active=true`
- entry 2: `here=true`, `save=disgraced_justice`, `exists=true`, `name=disgraced_justice`, `title=Disgraced Justice`, `author=Lorina Sonetto & Bob Qwerty`, `folder=mods/disgraced_justice`, `desc=Broken oaths and holy corruption.`, `priority_hint=0`, `active=false`, `script=mods/disgraced_justice/script.lua`
- entry 3: `cover=mods/extra features/cover.png`, `here=true`, `id=3145848395`, `save=extra features`, `exists=true`, `name=extra features`, `title=Glacies' Extra Features`, `author=Glacies`, `folder=mods/extra features`, `desc=This mod itself doesn't add any content. Only empowers other mods to have additional features.`, `priority_hint=0`, `active=false`
- entry 4: `cover=mods/glac terminal/cover.png`, `here=true`, `id=3144832438`, `save=glac terminal`, `exists=true`, `name=glac terminal`, `title=Glacies Module Terminal`, `author=Glacies`, `folder=mods/glac terminal`, `desc=Modder tool. DOESN'T ADD ANY CONTENT.`, `priority_hint=-3`, `active=false`
- entry 5: `cover=mods/glacies collection/cover.png`, `here=true`, `id=3148586988`, `save=glacies collection`, `exists=true`, `name=glacies collection`, `title=Glacies' Collection`, `author=Glacies`, `folder=mods/glacies collection`, `desc=Adds a bunch of ingame mechanics that can be used by other mods,`, `priority_hint=0`, `active=false`
- entry 6: `cover=mods/grenade predictor/cover.png`, `here=true`, `id=3449354474`, `save=grenade predictor`, `exists=true`, `name=grenade predictor`, `title=Grenade Predictor`, `author=Glacies`, `folder=mods/grenade predictor`, `desc=Hold middle wheel over a square to see the probabilities or average damages of a grenade.`, `priority_hint=0`, `active=false`
- entry 7: `modes=tbl`, `here=true`, `script=mods/nightmare/script.lua`, `save=nightmare`, `exists=true`, `name=nightmare`, `title=Nightmare Mode`, `id=3197738029`, `folder=mods/nightmare`, `desc=The title is a lie. This mod isn't as hard as a nightmare at all.`, `priority_hint=0`, `active=false`
- entry 8: `cover=mods/retry/cover.png`, `here=true`, `id=3626751996`, `save=retry`, `exists=true`, `name=retry`, `title=Retry after Death`, `author=Glacies`, `folder=mods/retry`, `desc=Restarts the current floor after you die.`, `priority_hint=0`, `active=false`
- entry 9: `modes=tbl`, `here=true`, `save=royal card lab`, `exists=true`, `name=royal card lab`, `title=Royal Card Lab`, `id=3144064207`, `folder=mods/royal card lab`, `desc=`, `priority_hint=-1`, `active=false`, `script=mods/royal card lab/script.lua`
- entry 10: `modes=tbl`, `here=true`, `cover=mods/Shootout/cover.png`, `save=Shootout`, `exists=true`, `name=Shootout`, `title=Shootout: the Rifle King Adventure`, `author=unknown2559`, `folder=mods/Shootout`, `desc=An endless adventure in which your typical arsenal is replaced with a shitty rifle'`, `priority_hint=0`, `active=false`
- entry 11: `cover=mods/show exclude/cover.png`, `here=true`, `id=3145391294`, `save=show exclude`, `exists=true`, `name=show exclude`, `title=Better Codex`, `author=Glacies`, `folder=mods/show exclude`, `desc=Features:`, `priority_hint=0`, `active=false`
- entry 12: `modes=tbl`, `langs=tbl`, `exists=true`, `title=Fairy Pieces for SGK`, `author=sub122`, `priority_hint=1`, `active=false`, `cover=mods/some_fairy_pieces/cover_sfps.png`, `save=some_fairy_pieces`, `name=some_fairy_pieces`, `id=3342310033`, `folder=mods/some_fairy_pieces`
- entry 13: `cover=mods/the art of war/cover.png`, `here=true`, `id=3512338449`, `save=the art of war`, `exists=true`, `name=the art of war`, `title=Military Tactics -The Art of War-`, `author=Glacies`, `folder=mods/the art of war`, `desc=[h2] Content [/h2]`, `priority_hint=-1`, `active=false`
- entry 14: `modes=tbl`, `here=true`, `langs=tbl`, `save=the_magnificient_quartz_army`, `exists=true`, `name=the_magnificient_quartz_army`, `title=The Magnificent Quartz Army`, `id=3151846036`, `folder=mods/the_magnificient_quartz_army`, `desc=The white army is getting bigger, this mod that adds a whole  lots of new pieces for the white army, as well as a special throne mod where the difficulties all affects these new pieces instead.`, `priority_hint=5`, `active=false`

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

- **Ermine Belt**: `index=0`, `need_card=tbl`, `team=0`, `ammo_max=3`, `pwe=4`, `ext=0`, `id=Ermine Belt`, `tags=tbl`, `need_tag=tbl`, `gid=0`, `n=3`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Rightful Curtsy**: `index=1`, `need_card=tbl`, `team=0`, `tags=tbl`, `tags.1=on_hit`, `ammo_max=1`, `pwe=4`, `ext=0`, `id=Rightful Curtsy`, `need_tag=tbl`, `knockback=50`, `gid=1`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Elite Gem**: `index=2`, `need_card=tbl`, `team=0`, `tags=tbl`, `id=Elite Gem`, `pwe=4`, `ext=0`, `ammo_regen=1`, `need_tag=tbl`, `need=tbl`, `gid=2`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `firerange=1`
- **Extra Barrel**: `index=3`, `chamber_max=1`, `team=0`, `tags=tbl`, `pwe=6`, `ext=0`, `id=Extra Barrel`, `need_card=tbl`, `need_tag=tbl`, `gid=3`, `n=3`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Royal Loafers**: `index=4`, `need_card=tbl`, `team=0`, `special=strafe`, `exclude=tbl`, `exclude.1=Sawed-off Justice`, `pwe=2`, `ext=0`, `id=Royal Loafers`, `tags=tbl`, `need_tag=tbl`, `gid=4`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Majestic Censer**: `index=5`, `need_card=tbl`, `team=0`, `tags=tbl`, `ammo_max=1`, `pwe=4`, `ext=0`, `id=Majestic Censer`, `need=tbl`, `need_tag=tbl`, `gid=5`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `soul_slot=1`
- **Sacred Crown**: `index=6`, `need_card=tbl`, `team=0`, `crown=1`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Sacred Crown`, `need_tag=tbl`, `need_soul=1`, `gid=6`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Blunderbuss**: `index=7`, `need_card=tbl`, `team=0`, `firepower=2`, `tags=tbl`, `spread=30`, `ext=0`, `id=Blunderbuss`, `pwe=4`, `need_tag=tbl`, `gid=7`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Engraved Scope**: `index=8`, `need_card=tbl`, `team=0`, `special=scope`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Engraved Scope`, `need=tbl`, `need_tag=tbl`, `gid=8`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `search=1`
- **Holy Gunpowder**: `index=9`, `need_card=tbl`, `team=0`, `firepower=1`, `ammo_max=-1`, `pwe=4`, `ext=0`, `id=Holy Gunpowder`, `tags=tbl`, `need_tag=tbl`, `gid=9`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Ritual Dagger**: `index=10`, `exclude=tbl`, `exclude.1=King's Shoulders`, `exclude.2=Guillotine`, `gid=10`, `need=tbl`, `need_card=tbl`, `team=0`, `firerange=-1`, `pwe=4`, `ext=0`, `id=Ritual Dagger`, `n=1`, `blade=1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `tags.2=blade`, `exclude_tag=tbl`, `gain=tbl`, `leader_hp=-3`
- **August Presence**: `index=11`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `ext=0`, `id=August Presence`, `need_tag=tbl`, `presence=1`, `gid=11`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Crow's Blessing**: `index=12`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Crow's Blessing`, `need=tbl`, `need_tag=tbl`, `gid=12`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `firerange=2`
- **Wand of Downpour**: `wand=tbl`, `wand.1=0`, `wand.2=10`, `need_card=tbl`, `team=0`, `index=13`, `pwe=1`, `ext=0`, `id=Wand of Downpour`, `tags=tbl`, `need_tag=tbl`, `gid=13`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Wand of Frenzy**: `wand=tbl`, `wand.1=1`, `need_card=tbl`, `team=0`, `index=14`, `pwe=1`, `ext=0`, `id=Wand of Frenzy`, `tags=tbl`, `need_tag=tbl`, `gid=14`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Wand of Wrath**: `wand=tbl`, `wand.1=2`, `wand.2=firepower`, `need_card=tbl`, `team=0`, `index=15`, `pwe=1`, `ext=0`, `id=Wand of Wrath`, `tags=tbl`, `need_tag=tbl`, `gid=15`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Wand of Wings**: `wand=tbl`, `wand.1=3`, `wand.2=3`, `need_card=tbl`, `team=0`, `index=16`, `pwe=1`, `ext=0`, `id=Wand of Wings`, `tags=tbl`, `need_tag=tbl`, `gid=16`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **The Moat**: `index=17`, `need_card=tbl`, `team=0`, `moat=4`, `pwe=4`, `ext=0`, `id=The Moat`, `tags=tbl`, `need_tag=tbl`, `gid=17`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Gradual Absolution**: `index=18`, `need_card=tbl`, `team=0`, `tags=tbl`, `need=tbl`, `pwe=2`, `ext=0`, `id=Gradual Absolution`, `need_tag=tbl`, `need_soul=2`, `gid=18`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `absolution=1`, `gain=tbl`
- **Taunting Hop**: `hop=1`, `need_card=tbl`, `team=0`, `index=19`, `hop_dmg=1`, `pwe=4`, `ext=0`, `id=Taunting Hop`, `tags=tbl`, `tags.1=jump`, `need_tag=tbl`, `gid=19`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Wand of Gust**: `wand=tbl`, `wand.1=4`, `need_card=tbl`, `team=0`, `index=20`, `pwe=1`, `ext=0`, `id=Wand of Gust`, `tags=tbl`, `need_tag=tbl`, `gid=20`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Faithful Steed**: `index=21`, `need_card=tbl`, `need_card.1=Warhorse`, `team=0`, `tags=tbl`, `exclude_tag=tbl`, `pwe=4`, `ext=0`, `id=Faithful Steed`, `need_tag=tbl`, `need=tbl`, `gid=21`, `n=1`, `knight_black_carryking=1`, `knight_black_castle=1`, `gain=tbl`, `sac=tbl`
- **Unjust Decree**: `index=22`, `special=decree`, `gid=22`, `need=tbl`, `need_card=tbl`, `team=0`, `firepower=-1`, `pwe=2`, `ext=0`, `id=Unjust Decree`, `n=1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need_chamber_max=2`
- **Kingly Alms**: `index=23`, `special=grenade`, `grenade_center_dmg=2`, `gid=23`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `ext=0`, `id=Kingly Alms`, `gain=tbl`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=grenade`, `exclude_tag=tbl`, `grenades_max=1`, `n=3`
- **Subtle Poison**: `queen_hp=-1`, `queen_poison=15`, `exclude=tbl`, `exclude.1=Guillotine`, `gid=24`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=2`, `ext=0`, `id=Subtle Poison`, `index=24`, `leader_hp=-1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Kingdom Wealth**: `index=25`, `exclude=tbl`, `exclude.1=Guillotine`, `gid=25`, `need=tbl`, `need_card=tbl`, `team=0`, `ammo_max=6`, `pwe=3`, `ext=0`, `id=Kingdom Wealth`, `n=1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `gain=tbl`, `leader_hp=2`
- **Small Fry Harvest**: `index=26`, `pawn_shell=1`, `exclude=tbl`, `exclude.1=King's Shoulders`, `gid=26`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=2`, `ext=0`, `id=Small Fry Harvest`, `sac=tbl`, `need_tag=tbl`, `blade=1`, `tags=tbl`, `tags.1=blade`, `exclude_tag=tbl`, `gain=tbl`, `n=2`
- **A Piercing Truth**: `index=27`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `ext=0`, `id=A Piercing Truth`, `need=tbl`, `need_tag=tbl`, `gid=27`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `pierce=30`
- **Black Mist**: `index=28`, `need_card=tbl`, `team=0`, `tags=tbl`, `mist=1`, `pwe=4`, `ext=0`, `id=Black Mist`, `need_tag=tbl`, `need=tbl`, `gid=28`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `firerange=-1`
- **King's Shoulders**: `index=29`, `grab=1`, `team=0`, `exclude=tbl`, `exclude.1=Ritual Dagger`, `exclude.2=Small Fry Harvest`, `exclude.3=Nightbane`, `exclude.4=Bushido`, `exclude.5=Shovel`, `exclude.6=Full Plate Armor`, `exclude.7=Vendetta`, `tags=tbl`, `pwe=2`, `ext=0`, `id=King's Shoulders`, `need_tag=tbl`, `need_card=tbl`, `gid=29`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `exclude_tag.1=blade`, `gain=tbl`, `need=tbl`
- **High Focus**: `index=30`, `gid=30`, `n=2`, `flip_on=contact`, `need_card=tbl`, `team=0`, `firepower=1`, `pwe=4`, `ext=0`, `id=High Focus`, `need=tbl`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `spread=-10`
- **Courteous Jousting**: `index=31`, `need_card=tbl`, `team=0`, `knight_joust=1`, `tags=tbl`, `spread=-10`, `ext=0`, `id=Courteous Jousting`, `pwe=4`, `need_tag=tbl`, `gid=31`, `need=tbl`, `need.1=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Cornered Despot**: `index=32`, `need_card=tbl`, `team=0`, `firepower=2`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Cornered Despot`, `exclude_tag=tbl`, `need_tag=tbl`, `gid=32`, `n=1`, `sac=tbl`, `flip_on=inner`, `gain=tbl`, `need=tbl`
- **Sawed-off Justice**: `index=33`, `exclude=tbl`, `exclude.1=Royal Loafers`, `gid=33`, `need=tbl`, `recoil=1`, `need_card=tbl`, `team=0`, `firepower=2`, `pwe=4`, `ext=1`, `id=Sawed-off Justice`, `n=1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `firerange=-1`
- **Welcome Gift**: `index=34`, `need_card=tbl`, `team=0`, `firepower=4`, `tags=tbl`, `jumpy=1`, `ext=1`, `id=Welcome Gift`, `pwe=4`, `need_tag=tbl`, `gid=34`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Cannon Fodder**: `index=35`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `ext=1`, `id=Cannon Fodder`, `need=tbl`, `need_tag=tbl`, `gid=35`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `pawnreap=1`
- **Possessed**: `index=36`, `need_card=tbl`, `need_card.1=Conclave`, `need_card.2=Unholy Call`, `team=0`, `tags=tbl`, `pwe=4`, `ext=1`, `id=Possessed`, `need=tbl`, `need_tag=tbl`, `gid=36`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `soul_slot=2`
- **Philanthropy**: `index=37`, `grenade_dmg=-1`, `special=grenade`, `gid=37`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `ext=1`, `id=Philanthropy`, `grenades_max=2`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=grenade`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Imperial Shot Put**: `index=38`, `need_card=tbl`, `need_card.1=King's Shoulders`, `team=0`, `cannonball=1`, `ammo_max=-1`, `pwe=4`, `ext=1`, `id=Imperial Shot Put`, `tags=tbl`, `need_tag=tbl`, `gid=38`, `n=3`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Egotic Maelstrom**: `index=39`, `cycle=1`, `gid=39`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `ext=1`, `id=Egotic Maelstrom`, `delayed=tbl`, `delayed.firepower=1`, `sac=tbl`, `need_tag=tbl`, `delay=12`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Church Organ**: `index=40`, `chamber_max=2`, `team=0`, `tags=tbl`, `ammo_max=2`, `pwe=4`, `ext=1`, `id=Church Organ`, `need=tbl`, `need_tag=tbl`, `gid=40`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need_card=tbl`, `need_card.1=Cathedral`
- **Black Plague**: `index=41`, `need_card=tbl`, `need_card.1=Crow's Blessing`, `need_card.2=Ravenous Rats`, `team=0`, `tags=tbl`, `gain=tbl`, `pwe=4`, `ext=1`, `id=Black Plague`, `need_tag=tbl`, `need=tbl`, `gid=41`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `plague=1`, `firerange=-1`
- **Ravenous Rats**: `index=42`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `ext=1`, `id=Ravenous Rats`, `need=tbl`, `need_tag=tbl`, `gid=42`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `rats=1`
- **Deep Water**: `index=43`, `need_card=tbl`, `need_card.1=The Moat`, `team=0`, `tags=tbl`, `deepwater=1`, `ext=1`, `id=Deep Water`, `pwe=4`, `need_tag=tbl`, `gid=43`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Unholy Call**: `index=44`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `pentagrams=3`, `id=Unholy Call`, `need=tbl`, `need_tag=tbl`, `gid=44`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `ext=1`
- **Undercover Mission**: `index=45`, `need_card=tbl`, `team=0`, `tags=tbl`, `tags.1=mission`, `pwe=4`, `ext=1`, `id=Undercover Mission`, `need_tag=tbl`, `waypoint=1`, `gid=45`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Caltrops**: `bleed_slow=1`, `need_card=tbl`, `team=0`, `index=46`, `tags=tbl`, `tags.1=bleed`, `pwe=4`, `ext=1`, `id=Caltrops`, `exclude_tag=tbl`, `need_tag=tbl`, `gid=46`, `n=2`, `sac=tbl`, `caltrops=15`, `gain=tbl`, `need=tbl`
- **Nightbane**: `index=47`, `need_card=tbl`, `team=0`, `exclude=tbl`, `exclude.1=King's Shoulders`, `tags=tbl`, `tags.1=blade`, `pwe=4`, `ext=1`, `id=Nightbane`, `exclude_tag=tbl`, `need_tag=tbl`, `gid=47`, `n=1`, `sac=tbl`, `blade=3`, `gain=tbl`, `need=tbl`
- **Bushido**: `index=48`, `exclude=tbl`, `exclude.1=King's Shoulders`, `bushido=1`, `gid=48`, `need=tbl`, `need_card=tbl`, `team=0`, `firepower=-1`, `pwe=4`, `ext=1`, `id=Bushido`, `sac=tbl`, `need_tag=tbl`, `blade=2`, `tags=tbl`, `tags.1=blade`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Bloodless Coups**: `index=49`, `exclude=tbl`, `exclude.1=Militia`, `exclude.2=Stoning`, `pawn_curse=1`, `pawn_peace=1`, `gid=49`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `ext=1`, `id=Bloodless Coups`, `n=1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `spread=-15`
- **Wand of Hypnosis**: `wand=tbl`, `wand.1=5`, `need_card=tbl`, `team=0`, `index=50`, `pwe=1`, `ext=1`, `id=Wand of Hypnosis`, `tags=tbl`, `need_tag=tbl`, `gid=50`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Presbyopia**: `index=51`, `need_card=tbl`, `need_card.1=Golden Aging`, `team=0`, `tags=tbl`, `queen_bishop_minr=2`, `ext=1`, `id=Presbyopia`, `pwe=4`, `need_tag=tbl`, `gid=51`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Golden Aging**: `index=52`, `cycle=1`, `exclude=tbl`, `exclude.1=Guillotine`, `leader_queen_hp=-1`, `gid=52`, `n=1`, `need_card=tbl`, `team=0`, `pwe=4`, `ext=1`, `id=Golden Aging`, `delayed=tbl`, `delayed.leader_queen_tempo=1`, `tags=tbl`, `tags.1=leader`, `need_tag=tbl`, `need=tbl`, `need.1=4`, `need.2=8`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `delay=10`
- **Fool Companion**: `index=53`, `need_card=tbl`, `need_card.1=The Jester`, `team=0`, `tags=tbl`, `pwe=4`, `ext=1`, `id=Fool Companion`, `need=tbl`, `need_tag=tbl`, `gid=53`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `jester_guard=1`
- **Force-feeding**: `index=54`, `full_firepower=1`, `team=0`, `overload=1`, `tags=tbl`, `pwe=4`, `ext=1`, `id=Force-feeding`, `need_card=tbl`, `need_tag=tbl`, `gid=54`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Seer's Orb**: `index=55`, `special=orb`, `gid=55`, `n=1`, `search=1`, `need_card=tbl`, `team=0`, `pwe=4`, `ext=2`, `id=Seer's Orb`, `orb=1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=orb`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Fearsome**: `index=56`, `need_card=tbl`, `team=0`, `tags=tbl`, `ammo_max=1`, `pwe=4`, `ext=2`, `id=Fearsome`, `need=tbl`, `need_tag=tbl`, `gid=56`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `fearsome=1`
- **Human Shield**: `index=57`, `need_card=tbl`, `need_card.1=Fearsome`, `team=0`, `tags=tbl`, `ammo_max=2`, `pwe=4`, `ext=2`, `id=Human Shield`, `exclude_tag=tbl`, `need_tag=tbl`, `gid=57`, `n=1`, `sac=tbl`, `humanshield=1`, `gain=tbl`, `need=tbl`
- **Reign of Terror**: `index=58`, `need_card=tbl`, `need_card.1=Fearsome`, `team=0`, `tags=tbl`, `ammo_max=-2`, `pwe=4`, `ext=2`, `id=Reign of Terror`, `need=tbl`, `need_tag=tbl`, `gid=58`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `terrorism=1`
- **Selective Listening**: `index=59`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `ext=2`, `id=Selective Listening`, `exclude_tag=tbl`, `need_tag=tbl`, `gid=59`, `n=1`, `sac=tbl`, `tactic=2`, `gain=tbl`, `need=tbl`
- **Monarch's Confidence**: `index=60`, `need_card=tbl`, `team=0`, `tags=tbl`, `need_chamber_max=2`, `pwe=4`, `ext=2`, `id=Monarch's Confidence`, `need_tag=tbl`, `need=tbl`, `gid=60`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `confidence=1`
- **The Mole**: `index=61`, `need_card=tbl`, `team=0`, `tags=tbl`, `tags.1=mission`, `pwe=4`, `ext=2`, `spy=1`, `id=The Mole`, `need_tag=tbl`, `gid=61`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `need.4=0`, `need.5=0`, `need.6=0`, `need.7=0`
- **Elusive**: `hop=1`, `need_card=tbl`, `team=0`, `index=62`, `tags=tbl`, `tags.1=jump`, `pwe=4`, `ext=2`, `elusive=1`, `need=tbl`, `need_tag=tbl`, `gid=62`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `id=Elusive`
- **Holoking**: `index=63`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `ext=2`, `id=Holoking`, `holoking=1`, `need_tag=tbl`, `gid=63`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Cloaking Device**: `index=64`, `need_card=tbl`, `need_card.1=Holoking`, `team=0`, `tags=tbl`, `tags.1=cloak`, `holocloak=1`, `pwe=4`, `ext=2`, `id=Cloaking Device`, `holoreveal=1`, `need_tag=tbl`, `gid=64`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Low-Cost Disguise**: `index=65`, `need_card=tbl`, `team=0`, `tags=tbl`, `tags.1=cloak`, `pwe=4`, `ext=2`, `id=Low-Cost Disguise`, `need_tag=tbl`, `pawn_disguise=2`, `gid=65`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Wand of Souls**: `wand=tbl`, `wand.1=6`, `need_card=tbl`, `team=0`, `index=66`, `pwe=1`, `ext=2`, `id=Wand of Souls`, `tags=tbl`, `need_tag=tbl`, `gid=66`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Wand of Execution**: `wand=tbl`, `wand.1=7`, `need_card=tbl`, `team=0`, `index=67`, `pwe=1`, `ext=2`, `id=Wand of Execution`, `tags=tbl`, `need_tag=tbl`, `gid=67`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Patience**: `floor_max=9`, `gid=68`, `need=tbl`, `need_card=tbl`, `team=0`, `ammo_max=1`, `pwe=4`, `ext=2`, `id=Patience`, `index=68`, `gain=tbl`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `exclude_tag=tbl`, `browse=1`, `n=2`
- **Bold Plan**: `index=69`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `replace_white_card=1`, `id=Bold Plan`, `need=tbl`, `need_tag=tbl`, `gid=69`, `n=3`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `ext=2`
- **Silencer**: `index=70`, `need_card=tbl`, `team=0`, `tags=tbl`, `silencer=1`, `pwe=4`, `ext=2`, `id=Silencer`, `firerange=-1`, `need=tbl`, `need_tag=tbl`, `need_tag.1=cloak`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gid=70`
- **Ambush**: `index=71`, `grenade_dmg=1`, `gid=71`, `need=tbl`, `flip_on=not_cloaked`, `need_card=tbl`, `team=0`, `pwe=4`, `ext=2`, `id=Ambush`, `n=1`, `need_tag=tbl`, `need_tag.1=cloak`, `sac=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `firerange=2`
- **Ancient Flagstone**: `index=72`, `need_card=tbl`, `team=0`, `flagstones=1`, `pwe=2`, `ext=2`, `id=Ancient Flagstone`, `tags=tbl`, `need_tag=tbl`, `gid=72`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Tearing Bullets**: `index=73`, `need_card=tbl`, `team=0`, `tags=tbl`, `tags.1=bleed`, `tags.2=on_hit`, `pwe=4`, `tearing=1`, `id=Tearing Bullets`, `need=tbl`, `need_tag=tbl`, `gid=73`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `ext=2`
- **Indelible Memories**: `index=74`, `special=grenade`, `grenade_bleed=1`, `gid=74`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `ext=2`, `id=Indelible Memories`, `grenades_max=1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=bleed`, `tags.2=grenade`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Mystic Shackles**: `index=75`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `ext=2`, `shackles=1`, `id=Mystic Shackles`, `need=tbl`, `gid=75`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need_tag=tbl`, `need_tag.1=orb`
- **Secret Move**: `hop=1`, `need_card=tbl`, `team=0`, `index=76`, `tags=tbl`, `tags.1=jump`, `pwe=4`, `ext=2`, `id=Secret Move`, `sac=tbl`, `need=tbl`, `gid=76`, `n=1`, `botte=2`, `exclude_tag=tbl`, `gain=tbl`, `need_tag=tbl`, `need_tag.1=jump`
- **Sacred Light**: `index=77`, `grenade_dmg=-2`, `special=grenade`, `grenade_proof=1`, `grenade_stun=2`, `gid=77`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `ext=2`, `id=Sacred Light`, `tags=tbl`, `tags.1=grenade`, `need_tag=tbl`, `grenades_max=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Workshop**: `index=78`, `cycle=1`, `gid=78`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=4`, `ext=2`, `id=Workshop`, `delayed=tbl`, `delayed.mk_grenades=1`, `delayed.mk_ammo=2`, `n=1`, `need_tag=tbl`, `need_tag.1=grenade`, `delay=8`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `sac=tbl`
- **Right-hand**: `index=79`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Gradual Absolution`, `need_card.1.2=Possessed`, `need_card.1.3=The Red Book`, `team=0`, `tags=tbl`, `tags.1=ally`, `pwe=4`, `ext=3`, `id=Right-hand`, `need=tbl`, `need_tag=tbl`, `gid=79`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `allies=tbl`, `allies.1=2`
- **Warhorse**: `index=80`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Saddle`, `need_card.1.2=Knightmare`, `need_card.1.3=Cavalry`, `team=0`, `tags=tbl`, `tags.1=ally`, `pwe=4`, `ext=3`, `id=Warhorse`, `need=tbl`, `need_tag=tbl`, `gid=80`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `allies=tbl`, `allies.1=1`
- **Bastion**: `index=81`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Highest Dungeon`, `need_card.1.2=Bunker`, `need_card.1.3=Lookout Tower`, `team=0`, `tags=tbl`, `tags.1=ally`, `pwe=4`, `ext=3`, `id=Bastion`, `need=tbl`, `need_tag=tbl`, `gid=81`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `allies=tbl`, `allies.1=3`
- **Sprint**: `index=82`, `need_card=tbl`, `team=0`, `tags=tbl`, `pwe=4`, `ext=3`, `id=Sprint`, `need=tbl`, `need_tag=tbl`, `gid=82`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `sprint=1`
- **Soul Projection**: `index=83`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Undead Armies`, `need_card.1.2=Knightmare`, `team=0`, `tags=tbl`, `tags.1=ally`, `summoner=1`, `ext=3`, `id=Soul Projection`, `pwe=4`, `need_tag=tbl`, `gid=83`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Onboarding Party**: `index=84`, `need_card=tbl`, `need_card.1=Welcome Gift`, `team=0`, `tags=tbl`, `pwe=4`, `ext=3`, `id=Onboarding Party`, `onboarding=1`, `need_tag=tbl`, `gid=84`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Small Key**: `index=85`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Prison`, `need_card.1.2=Trowel`, `team=0`, `small_key=1`, `pwe=4`, `ext=3`, `id=Small Key`, `tags=tbl`, `need_tag=tbl`, `gid=85`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Rapunzel**: `index=86`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Lady in the Tower`, `need_card.1.2=Highest Dungeon`, `team=0`, `rapunzel=1`, `pwe=4`, `ext=3`, `id=Rapunzel`, `tags=tbl`, `tags.1=ally`, `need_tag=tbl`, `gid=86`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Wand of Treachery**: `wand=tbl`, `wand.1=8`, `need_card=tbl`, `team=0`, `index=87`, `pwe=1`, `ext=3`, `id=Wand of Treachery`, `tags=tbl`, `tags.1=ally`, `need_tag=tbl`, `gid=87`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Guerilla Tactics**: `index=88`, `special=grenade`, `gid=88`, `need=tbl`, `need_card=tbl`, `firerange=1`, `ammo_max=1`, `pwe=4`, `ext=3`, `id=Guerilla Tactics`, `tags=tbl`, `tags.1=grenade`, `team=0`, `need_tag=tbl`, `grenades_max=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Shovel**: `index=89`, `special=dig`, `gid=89`, `need=tbl`, `need_card=tbl`, `tunnels=1`, `exclude=tbl`, `exclude.1=King's Shoulders`, `tags=tbl`, `tags.1=blade`, `tags.2=tunnels`, `pwe=2`, `ext=3`, `hole_start=2`, `id=Shovel`, `n=1`, `need_tag=tbl`, `blade=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `team=0`
- **Grindstone**: `index=90`, `cycle=1`, `gid=90`, `need=tbl`, `need_card=tbl`, `team=0`, `pwe=2`, `ext=3`, `id=Grindstone`, `delayed=tbl`, `delayed.blade=1`, `sac=tbl`, `need_tag=tbl`, `delay=6`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Death Mark**: `index=91`, `need_card=tbl`, `team=0`, `firepower=-1`, `sheath=1`, `pwe=4`, `ext=3`, `id=Death Mark`, `tags=tbl`, `tags.1=on_hit`, `need_tag=tbl`, `gid=91`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Shrapnel**: `index=92`, `need_card=tbl`, `team=0`, `tags=tbl`, `tags.1=on_hit`, `pwe=4`, `shrapnel=3`, `ext=3`, `id=Shrapnel`, `need=tbl`, `knockback=15`, `gid=92`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need_tag=tbl`, `need_tag.1=on_hit`
- **Backups**: `index=93`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=0`, `id=Backups`, `tags=tbl`, `need_tag=tbl`, `gid=100`, `need=tbl`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `n=3`
- **Cavalry**: `index=94`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Cavalry`, `need=tbl`, `need_tag=tbl`, `gid=101`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `delay=15`
- **Conclave**: `index=95`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Conclave`, `need=tbl`, `need_tag=tbl`, `gid=102`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `gain.2=2`, `delay=15`
- **Entitle**: `index=96`, `need_card=tbl`, `team=1`, `ammo_max=-1`, `pwe=4`, `ext=0`, `id=Entitle`, `tags=tbl`, `need_tag=tbl`, `gid=103`, `n=1`, `sac=tbl`, `sac.1=0`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=1`, `need=tbl`
- **Cardinal**: `index=97`, `need_card=tbl`, `team=1`, `ammo_max=-1`, `pwe=4`, `ext=0`, `id=Cardinal`, `tags=tbl`, `need_tag=tbl`, `gid=104`, `n=1`, `sac=tbl`, `sac.1=0`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `need=tbl`
- **Remparts**: `index=98`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=0`, `id=Remparts`, `tags=tbl`, `need_tag=tbl`, `gid=105`, `need=tbl`, `sac=tbl`, `sac.1=0`, `sac.2=0`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=3`, `n=2`
- **Pillage**: `index=99`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Pillage`, `need=tbl`, `need_tag=tbl`, `gid=106`, `n=1`, `sac=tbl`, `sac.1=3`, `exclude_tag=tbl`, `pawn_hp=1`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `gain.4=0`, `gain.5=0`
- **Crusades**: `index=100`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=0`, `id=Crusades`, `tags=tbl`, `need_tag=tbl`, `gid=107`, `need=tbl`, `sac=tbl`, `sac.1=2`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `n=1`
- **Peace**: `index=101`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=0`, `id=Peace`, `tags=tbl`, `need_tag=tbl`, `gid=108`, `need=tbl`, `sac=tbl`, `sac.1=1`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `gain.2=2`, `n=1`
- **King's Mistress**: `index=102`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=0`, `id=King's Mistress`, `need=tbl`, `need.1=4`, `need_tag=tbl`, `gid=109`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=4`, `queen_cage=3`
- **Revolution**: `index=103`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=0`, `id=Revolution`, `tags=tbl`, `need_tag=tbl`, `gid=110`, `need=tbl`, `sac=tbl`, `sac.1=2`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `gain.4=0`, `gain.5=0`, `gain.6=0`, `n=1`
- **Bodyguard**: `knight_bodyguard=1`, `knight_hp=1`, `team=1`, `index=104`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Bodyguard`, `need_card=tbl`, `need_tag=tbl`, `gid=111`, `need=tbl`, `need.1=1`, `need.2=8`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Ruins**: `index=105`, `need_card=tbl`, `rook_hp=-2`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Ruins`, `need=tbl`, `need_tag=tbl`, `gid=112`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=3`, `gain.2=0`, `gain.3=0`, `team=1`
- **Assault**: `index=106`, `need_card=tbl`, `team=1`, `pawn_assault=1`, `pwe=4`, `ext=0`, `id=Assault`, `tags=tbl`, `need_tag=tbl`, `gid=113`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `need.4=0`, `need.5=0`
- **Kite Shield**: `index=107`, `need_card=tbl`, `team=1`, `knight_shield=1`, `pwe=4`, `ext=0`, `id=Kite Shield`, `tags=tbl`, `tags.1=on_hit`, `need_tag=tbl`, `gid=114`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `need=tbl`, `need.1=1`, `need.2=1`
- **Zealots**: `index=108`, `pawn_tempo=-1`, `bishop_tempo=-1`, `gid=115`, `n=1`, `flip_on=no_bishop`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=0`, `id=Zealots`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`, `need.1=2`
- **Militia**: `index=109`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=Bloodless Coups`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Militia`, `pawn_militia=1`, `need_tag=tbl`, `gid=116`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`
- **Ammunition Depot**: `index=110`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Ammunition Depot`, `need_tag=tbl`, `rook_shell=2`, `gid=117`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=3`, `need=tbl`
- **Scouting**: `index=111`, `need_card=tbl`, `team=1`, `tags=tbl`, `pawn_tempo=-1`, `ext=0`, `id=Scouting`, `pwe=4`, `need_tag=tbl`, `gid=118`, `n=1`, `sac=tbl`, `sac.1=1`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `need=tbl`
- **Pikemen**: `index=112`, `pawn_pike=1`, `n=1`, `need_card=tbl`, `team=1`, `need=tbl`, `need.1=0`, `need.2=0`, `pwe=4`, `ext=0`, `id=Pikemen`, `pawn_hp=1`, `pawn_reformed=1`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gid=119`
- **Ascension**: `index=113`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Ascension`, `sac=tbl`, `need_tag=tbl`, `gid=120`, `n=1`, `bishop_flying=1`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`, `need.1=2`, `need.2=2`
- **Castle**: `index=114`, `rook_hp=1`, `exclude=tbl`, `exclude.1=Guillotine`, `gid=121`, `n=1`, `rook_castle=1`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=0`, `id=Castle`, `need_tag=tbl`, `need=tbl`, `need.1=3`, `need.2=8`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `gain=tbl`, `sac=tbl`
- **Conscription**: `index=115`, `cycle=1`, `team=1`, `tags=tbl`, `need=tbl`, `pwe=4`, `ext=0`, `id=Conscription`, `need_tag=tbl`, `need_card=tbl`, `gid=122`, `n=2`, `delay=5`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `sac=tbl`
- **Theocracy**: `index=116`, `exclude=tbl`, `exclude.1=Guillotine`, `gid=123`, `n=1`, `bishop_hp=2`, `no_ruler=1`, `need_card=tbl`, `team=1`, `theocracy=1`, `pwe=4`, `ext=0`, `id=Theocracy`, `tags=tbl`, `tags.1=leader`, `need_tag=tbl`, `sac=tbl`, `sac.1=5`, `ruler=2`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `need=tbl`, `need.1=2`, `need.2=2`
- **Fallen Dynasty**: `fallen=1`, `need_card=tbl`, `team=1`, `index=117`, `pwe=0`, `ext=0`, `id=Fallen Dynasty`, `tags=tbl`, `need_tag=tbl`, `gid=124`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Iron Maiden**: `index=118`, `gid=125`, `n=1`, `flip_on=only_queen`, `queen_iron=1`, `queen_tempo=2`, `pwe=4`, `ext=0`, `id=Iron Maiden`, `team=1`, `need=tbl`, `need.1=4`, `need.2=4`, `need_tag=tbl`, `sac=tbl`, `sac.1=4`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need_card=tbl`
- **Court of the King**: `index=119`, `all_tempo=1`, `team=1`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Court of the King`, `need_card=tbl`, `need_tag=tbl`, `gid=126`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `gain.3=2`, `gain.4=3`, `need=tbl`
- **The Red Book**: `index=120`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=The Royal Hunt`, `exclude.2=Buckler of Limos`, `bishop_orth=1`, `pwe=4`, `ext=0`, `id=The Red Book`, `tags=tbl`, `need_tag=tbl`, `gid=127`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `need=tbl`
- **Saboteur**: `index=121`, `need_card=tbl`, `team=1`, `tags=tbl`, `bad_shells=1`, `ext=0`, `id=Saboteur`, `pwe=4`, `need_tag=tbl`, `gid=128`, `n=2`, `sac=tbl`, `sac.1=0`, `sac.2=0`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `need=tbl`
- **Homecoming**: `index=122`, `need_card=tbl`, `team=1`, `pwe=0`, `ext=0`, `id=Homecoming`, `tags=tbl`, `need_tag=tbl`, `gid=129`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=4`, `need=tbl`
- **Lookout Tower**: `index=123`, `need_card=tbl`, `team=1`, `tags=tbl`, `sac=tbl`, `pwe=4`, `ext=0`, `id=Lookout Tower`, `need_tag=tbl`, `need=tbl`, `gid=130`, `alarm=1`, `delay=20`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=3`, `n=2`
- **Throne Room**: `queen_hp=1`, `exclude=tbl`, `exclude.1=Guillotine`, `gid=131`, `n=1`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=0`, `id=Throne Room`, `index=124`, `need=tbl`, `need.1=5`, `leader_hp=2`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `gain=tbl`, `need_tag=tbl`
- **The Secret Heir**: `index=125`, `heir=1`, `team=1`, `exclude=tbl`, `exclude.1=Guillotine`, `tags=tbl`, `tags.1=leader`, `pwe=4`, `ext=0`, `id=The Secret Heir`, `need_card=tbl`, `need_tag=tbl`, `gid=132`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `need=tbl`
- **Genderqueer**: `index=126`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=0`, `id=Genderqueer`, `need=tbl`, `need_tag=tbl`, `gid=133`, `n=1`, `delay=10`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=4`, `sac=tbl`, `sac.1=2`
- **Karma**: `index=127`, `reform=1`, `gid=134`, `need=tbl`, `reversable=1`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=1`, `id=Karma`, `tags=tbl`, `sqb_spread=30`, `need_tag=tbl`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `sqw_firepower=-1`
- **Undead Armies**: `index=128`, `need_card=tbl`, `team=1`, `tags=tbl`, `need=tbl`, `pwe=4`, `ext=1`, `id=Undead Armies`, `knight_bishop_rook_rep=0`, `need_tag=tbl`, `gid=135`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `pawn_hp=-1`
- **Shortage**: `index=129`, `need_card=tbl`, `team=1`, `tags=tbl`, `ammo_max=-3`, `pwe=4`, `ext=1`, `id=Shortage`, `gain=tbl`, `need=tbl`, `need_tag=tbl`, `need_tag.1=grenade`, `n=1`, `sac=tbl`, `sac.1=0`, `exclude_tag=tbl`, `grenades_max=-1`, `gid=136`
- **Succubus**: `index=130`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=1`, `id=Succubus`, `need=tbl`, `need_tag=tbl`, `gid=137`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `soul_slot=1`, `gain=tbl`, `gain.1=4`
- **Bunker**: `index=131`, `grenade_dmg=-1`, `exclude=tbl`, `exclude.1=Guillotine`, `gid=138`, `n=1`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=1`, `id=Bunker`, `leader_pawn_hp=1`, `need_tag=tbl`, `need_tag.1=grenade`, `sac=tbl`, `sac.1=3`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`
- **Sanctity**: `index=132`, `need_card=tbl`, `need_card.1=Conclave`, `team=1`, `tags=tbl`, `pwe=4`, `ext=1`, `id=Sanctity`, `need=tbl`, `need_tag=tbl`, `gid=139`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `bishop_sanctity=1`
- **Knightmare**: `index=133`, `knight_hp=-1`, `team=1`, `tags=tbl`, `n=1`, `pwe=4`, `ext=1`, `id=Knightmare`, `need_tag=tbl`, `knight_wraith=1`, `gid=140`, `need=tbl`, `need.1=1`, `need.2=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Fearsome`, `need_card.1.2=Black Mist`
- **Highest Dungeon**: `index=134`, `need_card=tbl`, `team=1`, `tags=tbl`, `exclude_tag=tbl`, `pwe=2`, `ext=1`, `id=Highest Dungeon`, `need_tag=tbl`, `n=1`, `gid=141`, `need=tbl`, `need.1=3`, `sac=tbl`, `flip_on=no_rook`, `gain=tbl`, `all_hp=1`
- **Cathedral**: `index=135`, `need_card=tbl`, `need_card.1=Cardinal`, `team=1`, `tags=tbl`, `pwe=4`, `ext=1`, `id=Cathedral`, `exclude_tag=tbl`, `need_tag=tbl`, `gid=142`, `n=1`, `sac=tbl`, `sac.1=2`, `rook_protect=1`, `gain=tbl`, `gain.1=3`, `need=tbl`
- **The Bridge**: `index=136`, `need_card=tbl`, `need_card.1=The Moat`, `team=1`, `tags=tbl`, `bridge=1`, `pwe=4`, `ext=1`, `id=The Bridge`, `need=tbl`, `need_tag=tbl`, `gid=143`, `n=1`, `delay=10`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=1`, `sac=tbl`
- **Divine Healing**: `index=137`, `need_card=tbl`, `team=1`, `tags=tbl`, `bishop_hp=1`, `pwe=4`, `ext=1`, `id=Divine Healing`, `need_tag=tbl`, `gain=tbl`, `gid=144`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `bishop_healer=2`, `need=tbl`, `need.1=2`
- **Last Guardian**: `index=138`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=1`, `id=Last Guardian`, `need=tbl`, `need.1=0`, `need.2=0`, `need_tag=tbl`, `gid=145`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `pawn_lastg=1`
- **Trowel**: `index=139`, `need_card=tbl`, `team=1`, `tags=tbl`, `exclude_tag=tbl`, `pwe=4`, `ext=1`, `id=Trowel`, `need_tag=tbl`, `rook_hp=4`, `gid=146`, `n=1`, `sac=tbl`, `flip_on=no_pawn`, `gain=tbl`, `need=tbl`, `need.1=3`, `need.2=0`
- **Full Plate Armor**: `index=140`, `all_tempo=1`, `exclude=tbl`, `exclude.1=King's Shoulders`, `gid=147`, `need=tbl`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=1`, `id=Full Plate Armor`, `n=1`, `sac=tbl`, `need_tag=tbl`, `blade=-1`, `tags=tbl`, `tags.1=blade`, `exclude_tag=tbl`, `gain=tbl`, `all_hp=1`
- **Military Academy**: `index=141`, `cycle=1`, `team=1`, `tags=tbl`, `need=tbl`, `pwe=4`, `ext=1`, `id=Military Academy`, `need_tag=tbl`, `need_card=tbl`, `gid=148`, `n=1`, `delay=10`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=1`, `sac=tbl`
- **Witch's Curse**: `index=142`, `queen_curse=1`, `gid=149`, `n=1`, `need_card=tbl`, `firerange=-1`, `firepower=-1`, `pwe=4`, `ext=1`, `id=Witch's Curse`, `tags=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `need.1=4`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `spread=10`
- **Saddle**: `index=143`, `need_card=tbl`, `team=1`, `knight_tempo=1`, `tags=tbl`, `pwe=4`, `ext=1`, `id=Saddle`, `knight_carry=1`, `need_tag=tbl`, `gid=150`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`, `need.1=1`
- **The Jester**: `index=144`, `need_card=tbl`, `need_card.1=Throne Room`, `team=1`, `jester=1`, `pwe=4`, `ext=1`, `id=The Jester`, `tags=tbl`, `need_tag=tbl`, `gid=151`, `need=tbl`, `need.1=0`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `n=1`
- **Guillotine**: `index=145`, `need_card=tbl`, `need_card.1=Revolution`, `team=1`, `exclude=tbl`, `exclude.1=Ritual Dagger`, `exclude.2=Subtle Poison`, `exclude.3=Kingdom Wealth`, `exclude.4=Golden Aging`, `exclude.5=Castle`, `exclude.6=Theocracy`, `exclude.7=Throne Room`, `exclude.8=The Secret Heir`, `exclude.9=Bunker`, `exclude.10=Emergency Call`, `exclude.11=Mausoleum`, `exclude.12=King's Look-alike`, `exclude.13=The Royal Hunt`, `exclude.14=Buckler of Limos`, `exclude.15=Vampirism`, `exclude.16=Commoner's Reign`, `exclude.17=Unsettled Throne`, `exclude.18=Anarchy`, `pwe=4`, `ext=1`, `id=Guillotine`, `tags=tbl`, `need_tag=tbl`, `gid=152`, `n=1`, `sac=tbl`, `sac.1=5`, `exclude_tag=tbl`, `exclude_tag.1=leader`, `gain=tbl`, `need=tbl`
- **Analysis Paralysis**: `index=146`, `need_card=tbl`, `need_card.1=High Focus`, `team=1`, `tags=tbl`, `paralysis=6`, `pwe=4`, `ext=1`, `id=Analysis Paralysis`, `need_tag=tbl`, `need=tbl`, `gid=153`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `search=1`
- **Plumed Knight**: `index=147`, `need_card=tbl`, `team=1`, `choose_knight_plumed=1`, `pwe=4`, `ext=2`, `id=Plumed Knight`, `tags=tbl`, `need_tag=tbl`, `gid=154`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`, `need.1=1`
- **Emergency Call**: `index=148`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=Guillotine`, `tags=tbl`, `tags.1=leader`, `leader_emergency=1`, `ext=2`, `id=Emergency Call`, `pwe=4`, `need_tag=tbl`, `gid=155`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `need=tbl`, `need.1=0`, `need.2=0`
- **Mangonel**: `index=149`, `need_card=tbl`, `team=1`, `tags=tbl`, `id=Mangonel`, `pwe=4`, `rook_catapult=1`, `rook_tempo=2`, `need_tag=tbl`, `need=tbl`, `gid=156`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=3`, `ext=2`
- **Governess**: `index=150`, `need_card=tbl`, `team=1`, `tags=tbl`, `force_promote=4`, `ext=2`, `id=Governess`, `pwe=4`, `need_tag=tbl`, `gid=157`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `need=tbl`
- **Mausoleum**: `index=151`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=Guillotine`, `tags=tbl`, `tags.1=leader`, `pwe=4`, `ext=2`, `id=Mausoleum`, `rook_leaderbond=2`, `need_tag=tbl`, `gid=158`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=3`, `need=tbl`
- **Reverend Mother**: `index=152`, `need_card=tbl`, `need_card.1=Theocracy`, `team=1`, `tags=tbl`, `pwe=4`, `ext=2`, `id=Reverend Mother`, `need_tag=tbl`, `queen_despair=1`, `gid=159`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=4`, `need=tbl`
- **Sokoban**: `index=153`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=2`, `id=Sokoban`, `rook_push=3`, `need_tag=tbl`, `gid=160`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `need=tbl`, `need.1=3`, `need.2=3`
- **Tag Team**: `index=154`, `gid=161`, `n=1`, `rook_swap=tbl`, `rook_swap.1=2`, `rook_bishop_hp=1`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=2`, `id=Tag Team`, `need=tbl`, `need.1=2`, `need.2=3`, `need_tag=tbl`, `bishop_swap=tbl`, `bishop_swap.1=3`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `sac=tbl`
- **Unicorn**: `index=155`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=2`, `id=Unicorn`, `need=tbl`, `need_tag=tbl`, `gid=162`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=1`, `knight_charge=1`
- **Lady in the Tower**: `index=156`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=2`, `id=Lady in the Tower`, `need=tbl`, `need_tag=tbl`, `gid=163`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=3`, `rook_killprom=4`
- **Final Countdown**: `index=157`, `need_card=tbl`, `team=1`, `tags=tbl`, `deathcount=12`, `pwe=4`, `ext=2`, `id=Final Countdown`, `need_tag=tbl`, `need=tbl`, `gid=164`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `deathcount_trig=6`
- **Nomad Life**: `knight_promote=1`, `need_card=tbl`, `team=1`, `index=158`, `pwe=4`, `ext=2`, `id=Nomad Life`, `tags=tbl`, `need_tag=tbl`, `gid=165`, `n=2`, `sac=tbl`, `sac.1=3`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `gain.3=2`, `need=tbl`
- **Prison**: `index=159`, `knight_bishop_prison=3`, `team=1`, `tags=tbl`, `pwe=4`, `ext=2`, `id=Prison`, `need_card=tbl`, `need_tag=tbl`, `gid=166`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `gain.2=1`, `need=tbl`, `need.1=1`, `need.2=2`, `need.3=3`
- **Inquisition**: `index=160`, `need_card=tbl`, `bishop_uncover=1`, `bishop_investigate=1`, `tags=tbl`, `pwe=4`, `ext=2`, `id=Inquisition`, `team=1`, `need=tbl`, `need_tag=tbl`, `need_tag.1=mission`, `need_tag.2=cloak`, `n=1`, `sac=tbl`, `sac.1=0`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `gid=167`
- **King's Look-alike**: `index=161`, `exclude=tbl`, `exclude.1=Guillotine`, `gid=168`, `need=tbl`, `no_ruler=1`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=2`, `false_king=1`, `leader_hp=1`, `n=2`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=5`, `id=King's Look-alike`
- **The Royal Hunt**: `index=162`, `need_card=tbl`, `team=1`, `leader_bow=2`, `exclude=tbl`, `exclude.1=The Red Book`, `exclude.2=Guillotine`, `pwe=4`, `ext=2`, `id=The Royal Hunt`, `tags=tbl`, `tags.1=leader`, `need_tag=tbl`, `gid=169`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Tragic Homecoming**: `queen_hp=2`, `need_card=tbl`, `team=1`, `index=163`, `pwe=0`, `ext=2`, `id=Tragic Homecoming`, `tags=tbl`, `need_tag=tbl`, `gid=170`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=4`, `need=tbl`
- **Buckler of Limos**: `index=164`, `exclude=tbl`, `exclude.1=The Red Book`, `exclude.2=Guillotine`, `leader_armorgap=3`, `leader_tempo=1`, `leader_buckler=1`, `need_firepower=5`, `gid=171`, `need=tbl`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=2`, `id=Buckler of Limos`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Vampirism**: `index=165`, `exclude=tbl`, `exclude.1=Guillotine`, `leader_queen_hp=1`, `leader_queen_vampire=1`, `gid=172`, `need=tbl`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=2`, `id=Vampirism`, `need_tag=tbl`, `need_tag.1=bleed`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Commoner's Reign**: `index=166`, `knight_hp=2`, `exclude=tbl`, `exclude.1=Guillotine`, `gid=173`, `need=tbl`, `need_card=tbl`, `team=1`, `pwe=0`, `ext=2`, `id=Commoner's Reign`, `sac=tbl`, `sac.1=5`, `need_tag=tbl`, `ruler=1`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=1`, `n=1`
- **Bouncy Castle**: `index=167`, `rook_hp=-2`, `need_knockback=100`, `gid=174`, `need=tbl`, `trampoline=1`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=2`, `id=Bouncy Castle`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Self-Defense**: `index=168`, `knight_hp=2`, `team=1`, `tags=tbl`, `pwe=0`, `ext=2`, `id=Self-Defense`, `need_card=tbl`, `need_tag=tbl`, `gid=175`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`
- **Unsettled Throne**: `index=169`, `heir=1`, `exclude=tbl`, `exclude.1=Guillotine`, `heirprom=1`, `need_heir=1`, `need=tbl`, `need_card=tbl`, `team=1`, `pwe=4`, `ext=2`, `id=Unsettled Throne`, `gid=176`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Vendetta**: `index=170`, `exclude=tbl`, `exclude.1=King's Shoulders`, `vendetta=1`, `gid=177`, `need=tbl`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Tragic Homecoming`, `need_card.1.2=King's Mistress`, `team=1`, `pwe=8`, `ext=3`, `id=Vendetta`, `sac=tbl`, `need_tag=tbl`, `blade=1`, `tags=tbl`, `tags.1=blade`, `exclude_tag=tbl`, `gain=tbl`, `n=1`
- **Stoning**: `index=171`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=Bloodless Coups`, `tags=tbl`, `pwe=4`, `ext=3`, `id=Stoning`, `sac=tbl`, `need_tag=tbl`, `gid=178`, `n=1`, `pawn_stoning=1`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `need.4=0`, `need.5=0`
- **Anarchy**: `index=172`, `need_card=tbl`, `team=1`, `exclude=tbl`, `exclude.1=Guillotine`, `tags=tbl`, `tags.1=leader`, `pwe=2`, `ext=3`, `id=Anarchy`, `need_tag=tbl`, `anarchy=1`, `gid=179`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`, `need.1=0`, `need.2=1`, `need.3=2`, `need.4=3`, `need.5=4`
- **Auto-da-fe**: `index=173`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Inquisition`, `need_card.1.2=Conclave`, `need_card.1.3=Zealots`, `team=1`, `tags=tbl`, `pwe=4`, `ext=3`, `id=Auto-da-fe`, `n=1`, `need_tag=tbl`, `gid=180`, `need=tbl`, `need.1=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `bishop_censor=1`
- **Late for dinner**: `index=174`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Kingdom Wealth`, `need_card.1.2=Final Countdown`, `team=1`, `tags=tbl`, `pwe=4`, `ext=3`, `id=Late for dinner`, `need=tbl`, `need_tag=tbl`, `gid=181`, `n=1`, `delay=10`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=1`, `gain.3=2`, `gain.4=3`, `sac=tbl`, `sac.1=0`, `sac.2=1`, `sac.3=2`
- **Excommunication**: `index=175`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=3`, `id=Excommunication`, `exile=15`, `need_tag=tbl`, `gid=182`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=3`, `gain.2=1`, `need=tbl`, `need.1=2`
- **Pyre of Lust**: `index=176`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=2`, `ext=3`, `id=Pyre of Lust`, `exile=15`, `need_tag=tbl`, `gid=183`, `need=tbl`, `need.1=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=4`, `n=1`
- **Gatehouse**: `index=177`, `rook_hp=-1`, `rook_tempo=2`, `gid=184`, `n=1`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Remparts`, `need_card.1.2=Trowel`, `team=1`, `rook_spawn=1`, `pwe=4`, `ext=3`, `id=Gatehouse`, `need_tag=tbl`, `sac=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `need=tbl`, `need.1=3`
- **Lightfoot**: `index=178`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `pawn_lightfoot=1`, `id=Lightfoot`, `need=tbl`, `need_tag=tbl`, `gid=185`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `ext=3`
- **Loyalist March**: `index=179`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=2`, `ext=3`, `id=Loyalist March`, `need=tbl`, `need_tag=tbl`, `gid=186`, `n=1`, `delay=10`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `gain.4=0`, `gain.5=0`, `gain.6=0`, `gain.7=0`, `gain.8=0`, `sac=tbl`
- **Trench War**: `index=180`, `need_card=tbl`, `team=1`, `tags=tbl`, `id=Trench War`, `pwe=2`, `ext=3`, `hole_cover=1`, `need_tag=tbl`, `need=tbl`, `gid=187`, `n=2`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=1`, `hole_start=5`
- **Catacombs**: `index=181`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `spread=10`, `ext=3`, `hole_solid=1`, `id=Catacombs`, `need=tbl`, `need_tag=tbl`, `need_tag.1=tunnels`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=3`, `gid=188`
- **Flesh Wall**: `index=182`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=2`, `ext=3`, `id=Flesh Wall`, `need=tbl`, `need_tag=tbl`, `gid=189`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=0`, `pawn_block=1`
- **Hired Blade**: `index=183`, `need_card=tbl`, `team=1`, `ammo_max=-1`, `pwe=4`, `ext=3`, `id=Hired Blade`, `tags=tbl`, `need_tag=tbl`, `gid=190`, `n=2`, `sac=tbl`, `sac.1=0`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=12`, `need=tbl`
- **Oathkeeper**: `index=184`, `need_card=tbl`, `team=1`, `pwe=2`, `ext=3`, `id=Oathkeeper`, `tags=tbl`, `need_tag=tbl`, `gid=191`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=13`, `need=tbl`
- **Redemption**: `index=185`, `need_card=tbl`, `team=1`, `tags=tbl`, `pwe=4`, `ext=3`, `id=Redemption`, `redemption=1`, `need=tbl`, `gid=192`, `n=1`, `sac=tbl`, `exclude_tag=tbl`, `gain=tbl`, `gain.1=2`, `need_tag=tbl`, `need_tag.1=ally`
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
- **is_card_available**: `n=1`, `id=Ermine Belt`, `special=nil`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **availability**: `index=0`
- **availability**: `need_card=tbl`
- **availability**: `team=0`
- **availability**: `ammo_max=3`
- **availability**: `pwe=4`
- **availability**: `ext=0`
- **availability**: `id=Ermine Belt`
- **availability**: `need=tbl`
- **availability**: `sac=tbl`
- **availability**: `need_tag=tbl`
- **availability**: `n=3`
- **availability**: `tags=tbl`
- **availability**: `exclude_tag=tbl`
- **availability**: `gain=tbl`
- **availability**: `gid=0`
- **availability**: `fields_shown=15`
- **is_card_available**: `n=2`, `id=Rightful Curtsy`, `special=nil`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **availability**: `index=1`
- **availability**: `need_card=tbl`
- **availability**: `team=0`
- **availability**: `sac=tbl`
- **availability**: `ammo_max=1`
- **availability**: `pwe=4`
- **availability**: `ext=0`
- **availability**: `id=Rightful Curtsy`
- **availability**: `need=tbl`
- **availability**: `knockback=50`
- **availability**: `gid=1`
- **availability**: `n=2`
- **availability**: `tags=tbl`
- **availability**: `tags.1=on_hit`
- **availability**: `exclude_tag=tbl`
- **availability**: `gain=tbl`
- **availability**: `need_tag=tbl`
- **availability**: `fields_shown=16`
- **is_card_available**: `n=3`, `id=Elite Gem`, `special=nil`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **availability**: `index=2`
- **availability**: `need_card=tbl`
- **availability**: `team=0`
- **availability**: `n=1`
- **availability**: `firerange=1`
- **availability**: `pwe=4`
- **availability**: `ext=0`
- **availability**: `ammo_regen=1`
- **availability**: `need_tag=tbl`
- **availability**: `tags=tbl`
- **availability**: `gid=2`
- **availability**: `need=tbl`
- **availability**: `sac=tbl`
- **availability**: `exclude_tag=tbl`
- **availability**: `gain=tbl`
- **availability**: `id=Elite Gem`
- **availability**: `fields_shown=16`
- **is_card_available**: `n=4`, `id=Extra Barrel`, `special=nil`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **availability**: `index=3`
- **availability**: `chamber_max=1`
- **availability**: `team=0`
- **availability**: `need=tbl`
- **availability**: `pwe=6`
- **availability**: `ext=0`
- **availability**: `id=Extra Barrel`
- **availability**: `gid=3`
- **availability**: `sac=tbl`
- **availability**: `need_tag=tbl`
- **availability**: `n=3`
- **availability**: `tags=tbl`
- **availability**: `exclude_tag=tbl`
- **availability**: `gain=tbl`
- **availability**: `need_card=tbl`
- **availability**: `fields_shown=15`
- **is_card_available**: `n=5`, `id=Royal Loafers`, `special=strafe`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **availability**: `index=4`
- **availability**: `need_card=tbl`
- **availability**: `team=0`
- **availability**: `special=strafe`
- **availability**: `need=tbl`
- **availability**: `pwe=2`
- **availability**: `ext=0`
- **availability**: `id=Royal Loafers`
- **availability**: `gid=4`
- **availability**: `sac=tbl`
- **availability**: `need_tag=tbl`
- **availability**: `n=1`
- **availability**: `tags=tbl`
- **availability**: `exclude_tag=tbl`
- **availability**: `gain=tbl`
- **availability**: `exclude=tbl`
- **availability**: `exclude.1=Sawed-off Justice`
- **availability**: `fields_shown=16`
- **is_card_available**: `n=6`, `id=Majestic Censer`, `special=nil`, `wand=nil`, `soul_slot=1`, `need_soul=nil`
- **availability**: `index=5`
- **availability**: `need_card=tbl`
- **availability**: `team=0`
- **availability**: `n=1`
- **availability**: `ammo_max=1`
- **availability**: `pwe=4`
- **availability**: `ext=0`
- **availability**: `id=Majestic Censer`
- **availability**: `gain=tbl`
- **availability**: `tags=tbl`
- **availability**: `gid=5`
- **availability**: `need=tbl`
- **availability**: `sac=tbl`
- **availability**: `exclude_tag=tbl`
- **availability**: `soul_slot=1`
- **availability**: `need_tag=tbl`
- **availability**: `fields_shown=16`
- **is_card_available**: `n=7`, `id=Sacred Crown`, `special=nil`, `wand=nil`, `soul_slot=nil`, `need_soul=1`
- **availability**: `index=6`
- **availability**: `need_card=tbl`
- **availability**: `team=0`
- **availability**: `crown=1`
- **availability**: `sac=tbl`
- **availability**: `pwe=4`
- **availability**: `ext=0`
- **availability**: `id=Sacred Crown`
- **availability**: `need=tbl`
- **availability**: `need_soul=1`
- **availability**: `gid=6`
- **availability**: `n=1`
- **availability**: `tags=tbl`
- **availability**: `exclude_tag=tbl`
- **availability**: `gain=tbl`
- **availability**: `need_tag=tbl`
- **availability**: `fields_shown=16`
- **is_card_available**: `n=8`, `id=Blunderbuss`, `special=nil`, `wand=nil`, `soul_slot=nil`, `need_soul=nil`
- **availability**: `index=7`
- **availability**: `need_card=tbl`
- **availability**: `team=0`
- **availability**: `firepower=2`
- **availability**: `pwe=4`
- **availability**: `spread=30`
- **availability**: `ext=0`
- **availability**: `id=Blunderbuss`
- **availability**: `need_tag=tbl`
- _(showing 160 of 243 logged offer records)_

## 12d. Souls, scepters & pieces probe (build 5+)

- `piece|type=0|name=pawn|hp=3|tempo=5|danger=1`
- `piece_0|index=0`
- `piece_0|type=0`
- `piece_0|name=pawn`
- `piece_0|tempo=5`
- `piece_0|seek=wdist`
- `piece_0|danger=1`
- `piece_0|behavior=tbl`
- `piece_0|behavior.1=tbl`
- `piece_0|behavior.1.1=1`
- `piece_0|behavior.1.2=1`
- `piece_0|behavior.1.3=1`
- `piece_0|behavior.1.move=1`
- `piece_0|behavior.1.native=1`
- `piece_0|behavior.1.id=line`
- `piece_0|behavior.2=tbl`
- `piece_0|behavior.2.1=4`
- `piece_0|behavior.2.2=5`
- `piece_0|behavior.2.3=1`
- `piece_0|behavior.2.atk=1`
- `piece_0|behavior.2.native=1`
- `piece_0|behavior.2.id=line`
- `piece_0|hdy=2`
- `piece_0|sided=1`
- `piece_0|hp=3`
- `piece_0|fields_shown=10`
- `piece|type=1|name=knight|hp=3|tempo=3|danger=3`
- `piece_1|index=1`
- `piece_1|nocarry=1`
- `piece_1|type=1`
- `piece_1|name=knight`
- `piece_1|tempo=3`
- `piece_1|seek=kdist`
- `piece_1|danger=3`
- `piece_1|reap=1`
- `piece_1|behavior=tbl`
- `piece_1|behavior.1=tbl`
- `piece_1|behavior.1.1=2`
- `piece_1|behavior.1.2=-1`
- `piece_1|behavior.1.3=2`

## 12e. Damage & bullet pipeline probe (build 5+)

- `hit|target=pawn|dmg=2|hp=3|bad=false|god_mode=false`
- `bleed_dmg|n=1|a1=tbl|a2=2|a3=nil|a4=nil`
- `bleed_dmg_arg1|see_hat=false`
- `bleed_dmg_arg1|upd=fn`
- `bleed_dmg_arg1|sq=tbl`
- `bleed_dmg_arg1|sq.risk=0`
- `bleed_dmg_arg1|sq.upd=fn`
- `bleed_dmg_arg1|sq.vx=0`
- `bleed_dmg_arg1|sq.t=13099`
- `bleed_dmg_arg1|sq.ww=16`
- `bleed_dmg_arg1|sq.px=2`
- `bleed_dmg_arg1|sq.flx=false`
- `bleed_dmg_arg1|sq.danger=tbl`
- `bleed_dmg_arg1|sq.shells=tbl`
- `bleed_dmg_arg1|sq.seed=311`
- `bleed_dmg_arg1|sq.x=128`
- `bleed_dmg_arg1|sq.y=126`
- `bleed_dmg_arg1|sq.truncated=true`
- `bleed_dmg_arg1|vx=0`
- `bleed_dmg_arg1|bad=false`
- `bleed_dmg_arg1|t=12225`
- `bleed_dmg_arg1|team=0`
- `bleed_dmg_arg1|sided=1`
- `bleed_dmg_arg1|tempo=5`
- `bleed_dmg_arg1|hh=16`
- `bleed_dmg_arg1|mark=tbl`
- `bleed_dmg_arg1|danger=1`
- `bleed_dmg_arg1|truncated=true`
- `bleed_dmg_arg1|fields_shown=12`
- `fx_dmg|n=1|a1=tbl|a2=2|a3=nil|a4=nil`

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
- `menu_but_1|t=0`
- `menu_but_1|flx=false`
- `menu_but_1|fly=false`
- `menu_but_1|dp=3`
- `menu_but_1|we=0`
- `menu_but_1|ww=16`
- `menu_but_1|vy=0`
- `menu_but_1|vx=0`
- `menu_but_1|dcy=0`
- `menu_but_1|hh=16`
- `menu_but_1|dcx=0`
- `menu_but_1|x=212`
- `menu_but_1|fr=0`
- `menu_but_1|y=108.5`
- `menu_but_1|frict=1`

## 12g. Dev panel, Mod Menu & Save persistence (build 5+)

- `bank|ready=true|magic=0|god_mode=false`
- `menu_state|n=1|menu=nil|mMenu=nil`
- `panel|available=true|native=mk_text_but`
- `panel|width=320|y=148`
- `panel|width=320|y=148`
- `panel|open=true|buttons=6`
- `panel|open=false`
- `panel|damage_controls=deferred_until_live_damage_probe`
- `panel|damage_controls=deferred_until_live_damage_probe`
- `panel|god_mode=true`
- `panel|god_mode=false`
- `panel|open=false`
- `panel|open=false`
- `panel|open=false`
- `panel|open=false`
- `panel|open=false`
- `panel|open=true|buttons=6`
- `panel|open=false`
- `panel|open=false`
- `panel|open=false`
- `panel|open=false`
- `panel|open=false`
- `panel|open=false`
- `panel|open=false`
- `panel|width=320|y=148`
- `panel|width=320|y=148`
- `panel|width=320|y=148`
- `menu_state|n=2|menu=nil|mMenu=tbl`
- `mMenu|y=99.5`
- `mMenu|x=183`

## 13. Next step

- Promote confirmed entries into `notes/map.md` (replace the TBD lines).
- Pick the dev-cheat panel targets from the ammo/UI candidate lists.
- Lines from other systems in the log: 1040 (ignored; raise an issue if the game seems noisy).
