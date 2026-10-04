# Draft game map — generated from `log.txt`

> Generated 2026-10-04 14:46 by `tools/parse_log.py`. **Draft**: everything here comes from the diagnostics mod's live log; promote confirmed facts into `notes/map.md` by hand.

## 1. Did the mod load?

- ✅ mod loaded — build 5, mod_index 1
- ✅ found itself in MODLIST; active=True
- ✅ READY line: build 5, 30 hooks registered, 920 globals visible

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

- ⚠️ no events fired — the mod loaded but the run may have been too short (start a floor and take a few turns).

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

- entry 1: `num=1`, `cover=mods/sk-rework/cover.png`, `active=true`, `folder=mods/sk-rework`, `desc=SK Rework — Build 5 (Phase 2c + diagnostics).`, `mode_description=tbl`, `exists=true`, `name=sk-rework`, `priority_hint=0`, `author=freeforall1932`, `save=sk-rework`, `here=true`
- entry 2: `active=false`, `folder=mods/disgraced_justice`, `desc=Broken oaths and holy corruption.`, `exists=true`, `name=disgraced_justice`, `priority_hint=0`, `author=Lorina Sonetto & Bob Qwerty`, `save=disgraced_justice`, `here=true`, `title=Disgraced Justice`, `script=mods/disgraced_justice/script.lua`
- entry 3: `cover=mods/extra features/cover.png`, `id=3145848395`, `active=false`, `folder=mods/extra features`, `desc=This mod itself doesn't add any content. Only empowers other mods to have additional features.`, `mode_description=tbl`, `exists=true`, `name=extra features`, `priority_hint=0`, `author=Glacies`, `save=extra features`, `here=true`
- entry 4: `cover=mods/glac terminal/cover.png`, `id=3144832438`, `active=false`, `folder=mods/glac terminal`, `desc=Modder tool. DOESN'T ADD ANY CONTENT.`, `mode_description=tbl`, `exists=true`, `name=glac terminal`, `priority_hint=-3`, `author=Glacies`, `save=glac terminal`, `here=true`
- entry 5: `cover=mods/glacies collection/cover.png`, `id=3148586988`, `active=false`, `folder=mods/glacies collection`, `desc=Adds a bunch of ingame mechanics that can be used by other mods,`, `mode_description=tbl`, `exists=true`, `name=glacies collection`, `priority_hint=0`, `author=Glacies`, `save=glacies collection`, `here=true`
- entry 6: `cover=mods/grenade predictor/cover.png`, `id=3449354474`, `active=false`, `folder=mods/grenade predictor`, `desc=Hold middle wheel over a square to see the probabilities or average damages of a grenade.`, `mode_description=tbl`, `exists=true`, `name=grenade predictor`, `priority_hint=0`, `author=Glacies`, `save=grenade predictor`, `here=true`
- entry 7: `folder=mods/nightmare`, `cover=mods/nightmare/cover.png`, `id=3197738029`, `active=false`, `modes=tbl`, `mode_description=tbl`, `priority_hint=0`, `exists=true`, `name=nightmare`, `desc=The title is a lie. This mod isn't as hard as a nightmare at all.`, `author=Glacies`, `save=nightmare`
- entry 8: `cover=mods/retry/cover.png`, `id=3626751996`, `active=false`, `folder=mods/retry`, `desc=Restarts the current floor after you die.`, `mode_description=tbl`, `exists=true`, `name=retry`, `priority_hint=0`, `author=Glacies`, `save=retry`, `here=true`
- entry 9: `folder=mods/royal card lab`, `cover=mods/royal card lab/cover.png`, `id=3144064207`, `active=false`, `modes=tbl`, `mode_description=tbl`, `priority_hint=-1`, `exists=true`, `name=royal card lab`, `desc=`, `author=Glacies`, `save=royal card lab`
- entry 10: `folder=mods/Shootout`, `cover=mods/Shootout/cover.png`, `active=false`, `modes=tbl`, `priority_hint=0`, `exists=true`, `name=Shootout`, `desc=An endless adventure in which your typical arsenal is replaced with a shitty rifle'`, `author=unknown2559`, `save=Shootout`, `here=true`, `title=Shootout: the Rifle King Adventure`
- entry 11: `cover=mods/show exclude/cover.png`, `id=3145391294`, `active=false`, `folder=mods/show exclude`, `desc=Features:`, `mode_description=tbl`, `exists=true`, `name=show exclude`, `priority_hint=0`, `author=Glacies`, `save=show exclude`, `here=true`
- entry 12: `id=3342310033`, `modes=tbl`, `langs=tbl`, `exists=true`, `name=some_fairy_pieces`, `author=sub122`, `save=some_fairy_pieces`, `here=true`, `priority_hint=1`, `script=mods/some_fairy_pieces/script.lua`, `mode_record=tbl`, `cover=mods/some_fairy_pieces/cover_sfps.png`
- entry 13: `cover=mods/the art of war/cover.png`, `id=3512338449`, `active=false`, `folder=mods/the art of war`, `desc=[h2] Content [/h2]`, `mode_description=tbl`, `exists=true`, `name=the art of war`, `priority_hint=-1`, `author=Glacies`, `save=the art of war`, `here=true`
- entry 14: `name=the_magnificient_quartz_army`, `cover=mods/the_magnificient_quartz_army/tmqa_cover.png`, `id=3151846036`, `active=false`, `script=mods/the_magnificient_quartz_army/script.lua`, `langs=tbl`, `title=The Magnificent Quartz Army`, `exists=true`, `folder=mods/the_magnificient_quartz_army`, `desc=The white army is getting bigger, this mod that adds a whole  lots of new pieces for the white army, as well as a special throne mod where the difficulties all affects these new pieces instead.`, `author=matheo000`, `save=the_magnificient_quartz_army`

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

- **Ermine Belt**: `gid=0`, `id=Ermine Belt`, `n=3`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=0`, `gain=tbl`, `team=0`, `ext=0`, `ammo_max=3`
- **Rightful Curtsy**: `n=2`, `gid=1`, `id=Rightful Curtsy`, `knockback=50`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=on_hit`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=1`, `gain=tbl`, `team=0`, `ext=0`, `ammo_max=1`
- **Elite Gem**: `team=0`, `gid=2`, `id=Elite Gem`, `exclude_tag=tbl`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `firerange=1`, `sac=tbl`, `index=2`, `gain=tbl`, `n=1`, `ext=0`, `ammo_regen=1`
- **Extra Barrel**: `gid=3`, `id=Extra Barrel`, `n=3`, `exclude_tag=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `team=0`, `sac=tbl`, `index=3`, `gain=tbl`, `chamber_max=1`, `ext=0`, `pwe=6`
- **Royal Loafers**: `n=1`, `gid=4`, `id=Royal Loafers`, `exclude=tbl`, `exclude.1=Sawed-off Justice`, `exclude_tag=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `team=0`, `sac=tbl`, `index=4`, `gain=tbl`, `special=strafe`, `ext=0`, `pwe=2`
- **Majestic Censer**: `team=0`, `gid=5`, `id=Majestic Censer`, `exclude_tag=tbl`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `soul_slot=1`, `sac=tbl`, `index=5`, `gain=tbl`, `n=1`, `ext=0`, `ammo_max=1`
- **Sacred Crown**: `n=1`, `gid=6`, `id=Sacred Crown`, `exclude_tag=tbl`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `team=0`, `sac=tbl`, `index=6`, `gain=tbl`, `need_soul=1`, `ext=0`, `crown=1`
- **Blunderbuss**: `n=2`, `gid=7`, `id=Blunderbuss`, `exclude_tag=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `spread=30`, `sac=tbl`, `index=7`, `gain=tbl`, `firepower=2`, `ext=0`, `pwe=4`
- **Engraved Scope**: `n=1`, `gid=8`, `id=Engraved Scope`, `exclude_tag=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `search=1`, `sac=tbl`, `index=8`, `gain=tbl`, `special=scope`, `ext=0`, `pwe=4`
- **Holy Gunpowder**: `n=2`, `gid=9`, `id=Holy Gunpowder`, `exclude_tag=tbl`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `team=0`, `sac=tbl`, `index=9`, `gain=tbl`, `firepower=1`, `ext=0`, `ammo_max=-1`
- **Ritual Dagger**: `id=Ritual Dagger`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `tags.2=blade`, `index=10`, `exclude_tag=tbl`, `team=0`, `exclude=tbl`, `exclude.1=King's Shoulders`, `exclude.2=Guillotine`, `gid=10`, `need=tbl`, `ext=0`, `gain=tbl`, `firerange=-1`, `sac=tbl`, `n=1`, `need_card=tbl`, `leader_hp=-3`, `blade=1`, `pwe=4`
- **August Presence**: `gid=11`, `id=August Presence`, `need_card=tbl`, `presence=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `n=1`, `exclude_tag=tbl`, `sac=tbl`, `index=11`, `gain=tbl`, `team=0`, `ext=0`, `pwe=4`
- **Crow's Blessing**: `gid=12`, `id=Crow's Blessing`, `need_card=tbl`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `firerange=2`, `sac=tbl`, `index=12`, `gain=tbl`, `team=0`, `ext=0`, `pwe=4`
- **Wand of Downpour**: `gid=13`, `id=Wand of Downpour`, `wand=tbl`, `wand.1=0`, `wand.2=10`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=13`, `gain=tbl`, `team=0`, `ext=0`, `pwe=1`
- **Wand of Frenzy**: `gid=14`, `id=Wand of Frenzy`, `wand=tbl`, `wand.1=1`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=14`, `gain=tbl`, `team=0`, `ext=0`, `pwe=1`
- **Wand of Wrath**: `gid=15`, `id=Wand of Wrath`, `wand=tbl`, `wand.1=2`, `wand.2=firepower`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=15`, `gain=tbl`, `team=0`, `ext=0`, `pwe=1`
- **Wand of Wings**: `gid=16`, `id=Wand of Wings`, `wand=tbl`, `wand.1=3`, `wand.2=3`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=16`, `gain=tbl`, `team=0`, `ext=0`, `pwe=1`
- **The Moat**: `gid=17`, `id=The Moat`, `team=0`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=17`, `gain=tbl`, `moat=4`, `ext=0`, `pwe=4`
- **Gradual Absolution**: `gid=18`, `team=0`, `id=Gradual Absolution`, `need_tag=tbl`, `exclude_tag=tbl`, `absolution=1`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `gain=tbl`, `sac=tbl`, `index=18`, `need_soul=2`, `n=2`, `ext=0`, `pwe=2`
- **Taunting Hop**: `sac=tbl`, `gid=19`, `id=Taunting Hop`, `exclude_tag=tbl`, `team=0`, `need_tag=tbl`, `hop_dmg=1`, `tags=tbl`, `tags.1=jump`, `need_card=tbl`, `need=tbl`, `hop=1`, `index=19`, `gain=tbl`, `n=2`, `ext=0`, `pwe=4`
- **Wand of Gust**: `gid=20`, `id=Wand of Gust`, `wand=tbl`, `wand.1=4`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=20`, `gain=tbl`, `team=0`, `ext=0`, `pwe=1`
- **Faithful Steed**: `knight_black_castle=1`, `gid=21`, `id=Faithful Steed`, `team=0`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `sac=tbl`, `index=21`, `n=1`, `need_card=tbl`, `need_card.1=Warhorse`, `ext=0`, `knight_black_carryking=1`
- **Unjust Decree**: `need_chamber_max=2`, `need_tag=tbl`, `tags=tbl`, `index=22`, `special=decree`, `exclude_tag=tbl`, `gid=22`, `need=tbl`, `id=Unjust Decree`, `ext=0`, `n=1`, `sac=tbl`, `team=0`, `need_card=tbl`, `firepower=-1`, `gain=tbl`, `pwe=2`
- **Kingly Alms**: `grenade_center_dmg=2`, `id=Kingly Alms`, `need_tag=tbl`, `tags=tbl`, `tags.1=grenade`, `grenades_max=1`, `index=23`, `special=grenade`, `exclude_tag=tbl`, `team=0`, `need=tbl`, `gid=23`, `sac=tbl`, `ext=0`, `need_card=tbl`, `n=3`, `gain=tbl`, `pwe=4`
- **Subtle Poison**: `id=Subtle Poison`, `queen_hp=-1`, `queen_poison=15`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `index=24`, `exclude_tag=tbl`, `gid=24`, `need=tbl`, `exclude=tbl`, `exclude.1=Guillotine`, `gain=tbl`, `ext=0`, `sac=tbl`, `n=1`, `need_card=tbl`, `leader_hp=-1`, `team=0`, `pwe=2`
- **Kingdom Wealth**: `exclude=tbl`, `exclude.1=Guillotine`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `index=25`, `exclude_tag=tbl`, `team=0`, `ammo_max=6`, `need=tbl`, `ext=0`, `gain=tbl`, `n=1`, `sac=tbl`, `gid=25`, `need_card=tbl`, `leader_hp=2`, `id=Kingdom Wealth`, `pwe=3`
- **Small Fry Harvest**: `exclude=tbl`, `exclude.1=King's Shoulders`, `pawn_shell=1`, `tags=tbl`, `tags.1=blade`, `index=26`, `exclude_tag=tbl`, `team=0`, `id=Small Fry Harvest`, `need=tbl`, `ext=0`, `gid=26`, `n=2`, `sac=tbl`, `gain=tbl`, `need_card=tbl`, `need_tag=tbl`, `blade=1`, `pwe=2`
- **A Piercing Truth**: `gid=27`, `id=A Piercing Truth`, `need_card=tbl`, `n=2`, `pierce=30`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_tag=tbl`, `sac=tbl`, `index=27`, `gain=tbl`, `team=0`, `ext=0`, `pwe=4`
- **Black Mist**: `mist=1`, `gid=28`, `id=Black Mist`, `exclude_tag=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `firerange=-1`, `sac=tbl`, `index=28`, `gain=tbl`, `n=2`, `ext=0`, `pwe=4`
- **King's Shoulders**: `ext=0`, `team=0`, `id=King's Shoulders`, `exclude=tbl`, `exclude.1=Ritual Dagger`, `exclude.2=Small Fry Harvest`, `exclude.3=Nightbane`, `exclude.4=Bushido`, `exclude.5=Shovel`, `exclude.6=Full Plate Armor`, `exclude.7=Vendetta`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gid=29`, `gain=tbl`, `sac=tbl`, `index=29`, `n=1`, `grab=1`, `exclude_tag=tbl`, `exclude_tag.1=blade`, `pwe=2`
- **High Focus**: `id=High Focus`, `need_tag=tbl`, `tags=tbl`, `index=30`, `exclude_tag=tbl`, `team=0`, `flip_on=contact`, `need=tbl`, `gid=30`, `ext=0`, `spread=-10`, `sac=tbl`, `n=2`, `need_card=tbl`, `firepower=1`, `gain=tbl`, `pwe=4`
- **Courteous Jousting**: `need=tbl`, `need.1=1`, `team=0`, `id=Courteous Jousting`, `exclude_tag=tbl`, `gid=31`, `need_tag=tbl`, `knight_joust=1`, `tags=tbl`, `need_card=tbl`, `gain=tbl`, `sac=tbl`, `index=31`, `spread=-10`, `n=1`, `ext=0`, `pwe=4`
- **Cornered Despot**: `n=1`, `gid=32`, `id=Cornered Despot`, `exclude_tag=tbl`, `team=0`, `flip_on=inner`, `need=tbl`, `tags=tbl`, `need_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=32`, `gain=tbl`, `firepower=2`, `ext=0`, `pwe=4`
- **Sawed-off Justice**: `id=Sawed-off Justice`, `need_tag=tbl`, `tags=tbl`, `index=33`, `exclude_tag=tbl`, `gid=33`, `exclude=tbl`, `exclude.1=Royal Loafers`, `team=0`, `need=tbl`, `ext=1`, `recoil=1`, `firerange=-1`, `sac=tbl`, `n=1`, `need_card=tbl`, `firepower=2`, `gain=tbl`, `pwe=4`
- **Welcome Gift**: `n=1`, `gid=34`, `id=Welcome Gift`, `exclude_tag=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `jumpy=1`, `sac=tbl`, `index=34`, `gain=tbl`, `firepower=4`, `ext=1`, `pwe=4`
- **Cannon Fodder**: `gid=35`, `id=Cannon Fodder`, `need_card=tbl`, `tags=tbl`, `need_tag=tbl`, `need=tbl`, `pawnreap=1`, `n=1`, `exclude_tag=tbl`, `sac=tbl`, `index=35`, `gain=tbl`, `team=0`, `ext=1`, `pwe=4`
- **Possessed**: `team=0`, `id=Possessed`, `n=1`, `gid=36`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `soul_slot=2`, `sac=tbl`, `index=36`, `need_card=tbl`, `need_card.1=Conclave`, `need_card.2=Unholy Call`, `gain=tbl`, `gain.1=2`, `ext=1`, `pwe=4`
- **Philanthropy**: `id=Philanthropy`, `need_tag=tbl`, `tags=tbl`, `tags.1=grenade`, `grenades_max=2`, `index=37`, `grenade_dmg=-1`, `special=grenade`, `exclude_tag=tbl`, `team=0`, `need=tbl`, `gid=37`, `sac=tbl`, `ext=1`, `need_card=tbl`, `n=1`, `gain=tbl`, `pwe=4`
- **Imperial Shot Put**: `gid=38`, `team=0`, `id=Imperial Shot Put`, `exclude_tag=tbl`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `sac=tbl`, `gain=tbl`, `cannonball=1`, `index=38`, `need_card=tbl`, `need_card.1=King's Shoulders`, `n=3`, `ext=1`, `ammo_max=-1`
- **Egotic Maelstrom**: `id=Egotic Maelstrom`, `delayed=tbl`, `delayed.firepower=1`, `delay=12`, `need_tag=tbl`, `tags=tbl`, `cycle=1`, `index=39`, `exclude_tag=tbl`, `gid=39`, `need=tbl`, `team=0`, `sac=tbl`, `ext=1`, `need_card=tbl`, `gain=tbl`, `n=1`, `pwe=4`
- **Church Organ**: `n=1`, `team=0`, `id=Church Organ`, `exclude_tag=tbl`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gid=40`, `gain=tbl`, `sac=tbl`, `index=40`, `need_card=tbl`, `need_card.1=Cathedral`, `chamber_max=2`, `ext=1`, `ammo_max=2`
- **Black Plague**: `gain=tbl`, `gid=41`, `id=Black Plague`, `exclude_tag=tbl`, `team=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `plague=1`, `firerange=-1`, `sac=tbl`, `index=41`, `n=1`, `need_card=tbl`, `need_card.1=Crow's Blessing`, `need_card.2=Ravenous Rats`, `ext=1`, `pwe=4`
- **Ravenous Rats**: `rats=1`, `gid=42`, `id=Ravenous Rats`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `sac=tbl`, `index=42`, `n=1`, `team=0`, `ext=1`, `pwe=4`
- **Deep Water**: `gid=43`, `id=Deep Water`, `n=1`, `deepwater=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=0`, `exclude_tag=tbl`, `sac=tbl`, `index=43`, `gain=tbl`, `need_card=tbl`, `need_card.1=The Moat`, `ext=1`, `pwe=4`
- **Unholy Call**: `gid=44`, `id=Unholy Call`, `pentagrams=3`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=44`, `gain=tbl`, `team=0`, `ext=1`, `pwe=4`
- **Undercover Mission**: `waypoint=1`, `gid=45`, `id=Undercover Mission`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=mission`, `gain=tbl`, `exclude_tag=tbl`, `sac=tbl`, `index=45`, `n=1`, `team=0`, `ext=1`, `pwe=4`
- **Caltrops**: `ext=1`, `gid=46`, `id=Caltrops`, `tags=tbl`, `tags.1=bleed`, `team=0`, `need_tag=tbl`, `need=tbl`, `bleed_slow=1`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=46`, `gain=tbl`, `n=2`, `caltrops=15`, `pwe=4`
- **Nightbane**: `need_card=tbl`, `gid=47`, `id=Nightbane`, `exclude=tbl`, `exclude.1=King's Shoulders`, `tags=tbl`, `tags.1=blade`, `need_tag=tbl`, `need=tbl`, `blade=3`, `n=1`, `exclude_tag=tbl`, `sac=tbl`, `index=47`, `gain=tbl`, `team=0`, `ext=1`, `pwe=4`
- **Bushido**: `id=Bushido`, `need_tag=tbl`, `bushido=1`, `tags=tbl`, `tags.1=blade`, `index=48`, `exclude_tag=tbl`, `team=0`, `exclude=tbl`, `exclude.1=King's Shoulders`, `need=tbl`, `gid=48`, `ext=1`, `gain=tbl`, `sac=tbl`, `n=1`, `need_card=tbl`, `firepower=-1`, `blade=2`, `pwe=4`
- **Bloodless Coups**: `id=Bloodless Coups`, `need_tag=tbl`, `tags=tbl`, `index=49`, `exclude_tag=tbl`, `team=0`, `exclude=tbl`, `exclude.1=Militia`, `exclude.2=Stoning`, `gid=49`, `need=tbl`, `ext=1`, `pawn_peace=1`, `spread=-15`, `sac=tbl`, `n=1`, `need_card=tbl`, `gain=tbl`, `pawn_curse=1`, `pwe=4`
- **Wand of Hypnosis**: `gid=50`, `id=Wand of Hypnosis`, `wand=tbl`, `wand.1=5`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=50`, `gain=tbl`, `team=0`, `ext=1`, `pwe=1`
- **Presbyopia**: `gid=51`, `id=Presbyopia`, `need_card=tbl`, `need_card.1=Golden Aging`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `queen_bishop_minr=2`, `exclude_tag=tbl`, `sac=tbl`, `index=51`, `gain=tbl`, `team=0`, `ext=1`, `pwe=4`
- **Golden Aging**: `id=Golden Aging`, `delayed=tbl`, `delayed.leader_queen_tempo=1`, `delay=10`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `cycle=1`, `index=52`, `exclude_tag=tbl`, `gid=52`, `need=tbl`, `need.1=4`, `need.2=8`, `exclude=tbl`, `exclude.1=Guillotine`, `leader_queen_hp=-1`, `ext=1`, `sac=tbl`, `team=0`, `need_card=tbl`, `n=1`, `gain=tbl`, `pwe=4`
- **Fool Companion**: `jester_guard=1`, `gid=53`, `id=Fool Companion`, `need_card=tbl`, `need_card.1=The Jester`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `n=1`, `exclude_tag=tbl`, `sac=tbl`, `index=53`, `gain=tbl`, `team=0`, `ext=1`, `pwe=4`
- **Force-feeding**: `sac=tbl`, `gid=54`, `id=Force-feeding`, `exclude_tag=tbl`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `full_firepower=1`, `need_card=tbl`, `overload=1`, `index=54`, `gain=tbl`, `team=0`, `ext=1`, `pwe=4`
- **Seer's Orb**: `id=Seer's Orb`, `need_tag=tbl`, `tags=tbl`, `tags.1=orb`, `index=55`, `special=orb`, `exclude_tag=tbl`, `team=0`, `orb=1`, `need=tbl`, `gid=55`, `search=1`, `sac=tbl`, `ext=2`, `need_card=tbl`, `n=1`, `gain=tbl`, `pwe=4`
- **Fearsome**: `n=2`, `gid=56`, `id=Fearsome`, `exclude_tag=tbl`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `fearsome=1`, `need_card=tbl`, `sac=tbl`, `index=56`, `gain=tbl`, `team=0`, `ext=2`, `ammo_max=1`
- **Human Shield**: `humanshield=1`, `team=0`, `id=Human Shield`, `exclude_tag=tbl`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gid=57`, `gain=tbl`, `sac=tbl`, `index=57`, `n=1`, `need_card=tbl`, `need_card.1=Fearsome`, `ext=2`, `ammo_max=2`
- **Reign of Terror**: `gid=58`, `team=0`, `id=Reign of Terror`, `terrorism=1`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `gain=tbl`, `sac=tbl`, `index=58`, `n=1`, `need_card=tbl`, `need_card.1=Fearsome`, `ext=2`, `ammo_max=-2`
- **Selective Listening**: `gid=59`, `id=Selective Listening`, `team=0`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=59`, `gain=tbl`, `tactic=2`, `ext=2`, `pwe=4`
- **Monarch's Confidence**: `need_chamber_max=2`, `gid=60`, `id=Monarch's Confidence`, `exclude_tag=tbl`, `team=0`, `need_tag=tbl`, `confidence=1`, `tags=tbl`, `need_card=tbl`, `need=tbl`, `sac=tbl`, `index=60`, `gain=tbl`, `n=1`, `ext=2`, `pwe=4`
- **The Mole**: `gid=61`, `id=The Mole`, `spy=1`, `team=0`, `need_tag=tbl`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `need.4=0`, `need.5=0`, `need.6=0`, `need.7=0`, `tags=tbl`, `tags.1=mission`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=61`, `gain=tbl`, `n=2`, `ext=2`, `pwe=4`
- **Elusive**: `sac=tbl`, `gid=62`, `id=Elusive`, `exclude_tag=tbl`, `team=0`, `need_tag=tbl`, `elusive=1`, `tags=tbl`, `tags.1=jump`, `need_card=tbl`, `need=tbl`, `hop=1`, `index=62`, `gain=tbl`, `n=1`, `ext=2`, `pwe=4`
- **Holoking**: `gid=63`, `id=Holoking`, `index=63`, `gain=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `holoking=1`, `n=1`, `team=0`, `ext=2`, `pwe=4`
- **Cloaking Device**: `index=64`, `team=0`, `id=Cloaking Device`, `exclude_tag=tbl`, `gid=64`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=cloak`, `need_card=tbl`, `need_card.1=Holoking`, `gain=tbl`, `sac=tbl`, `holoreveal=1`, `n=1`, `holocloak=1`, `ext=2`, `pwe=4`
- **Low-Cost Disguise**: `gid=65`, `id=Low-Cost Disguise`, `pawn_disguise=2`, `n=2`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=cloak`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=65`, `gain=tbl`, `team=0`, `ext=2`, `pwe=4`
- **Wand of Souls**: `gid=66`, `id=Wand of Souls`, `wand=tbl`, `wand.1=6`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=66`, `gain=tbl`, `team=0`, `ext=2`, `pwe=1`
- **Wand of Execution**: `gid=67`, `id=Wand of Execution`, `wand=tbl`, `wand.1=7`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=67`, `gain=tbl`, `team=0`, `ext=2`, `pwe=1`
- **Patience**: `id=Patience`, `need_tag=tbl`, `tags=tbl`, `floor_max=9`, `exclude_tag=tbl`, `team=0`, `index=68`, `need=tbl`, `ammo_max=1`, `ext=2`, `browse=1`, `sac=tbl`, `n=2`, `need_card=tbl`, `gain=tbl`, `gid=68`, `pwe=4`
- **Bold Plan**: `replace_white_card=1`, `gid=69`, `id=Bold Plan`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gain=tbl`, `exclude_tag=tbl`, `sac=tbl`, `index=69`, `n=3`, `team=0`, `ext=2`, `pwe=4`
- **Silencer**: `gain=tbl`, `team=0`, `id=Silencer`, `exclude_tag=tbl`, `gid=70`, `need_tag=tbl`, `need_tag.1=cloak`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `firerange=-1`, `sac=tbl`, `index=70`, `n=1`, `silencer=1`, `ext=2`, `pwe=4`
- **Ambush**: `id=Ambush`, `need_tag=tbl`, `need_tag.1=cloak`, `tags=tbl`, `index=71`, `grenade_dmg=1`, `exclude_tag=tbl`, `gid=71`, `flip_on=not_cloaked`, `need=tbl`, `gain=tbl`, `firerange=2`, `sac=tbl`, `ext=2`, `need_card=tbl`, `n=1`, `team=0`, `pwe=4`
- **Ancient Flagstone**: `gid=72`, `id=Ancient Flagstone`, `index=72`, `exclude_tag=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `n=1`, `sac=tbl`, `flagstones=1`, `gain=tbl`, `team=0`, `ext=2`, `pwe=2`
- **Tearing Bullets**: `tearing=1`, `gid=73`, `id=Tearing Bullets`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=bleed`, `tags.2=on_hit`, `gain=tbl`, `exclude_tag=tbl`, `sac=tbl`, `index=73`, `n=1`, `team=0`, `ext=2`, `pwe=4`
- **Indelible Memories**: `id=Indelible Memories`, `grenade_bleed=1`, `need_tag=tbl`, `tags=tbl`, `tags.1=bleed`, `tags.2=grenade`, `grenades_max=1`, `index=74`, `special=grenade`, `exclude_tag=tbl`, `team=0`, `need=tbl`, `gid=74`, `sac=tbl`, `ext=2`, `need_card=tbl`, `n=1`, `gain=tbl`, `pwe=4`
- **Mystic Shackles**: `gid=75`, `id=Mystic Shackles`, `index=75`, `n=1`, `need_tag=tbl`, `need_tag.1=orb`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `shackles=1`, `gain=tbl`, `team=0`, `ext=2`, `pwe=4`
- **Secret Move**: `sac=tbl`, `team=0`, `id=Secret Move`, `exclude_tag=tbl`, `gid=76`, `need_tag=tbl`, `need_tag.1=jump`, `botte=2`, `tags=tbl`, `tags.1=jump`, `need_card=tbl`, `need=tbl`, `hop=1`, `index=76`, `n=1`, `gain=tbl`, `ext=2`, `pwe=4`
- **Sacred Light**: `grenade_proof=1`, `id=Sacred Light`, `grenade_stun=2`, `need_tag=tbl`, `tags=tbl`, `tags.1=grenade`, `grenades_max=1`, `index=77`, `grenade_dmg=-2`, `special=grenade`, `exclude_tag=tbl`, `gid=77`, `need=tbl`, `gain=tbl`, `sac=tbl`, `ext=2`, `need_card=tbl`, `n=1`, `team=0`, `pwe=4`
- **Workshop**: `id=Workshop`, `delayed=tbl`, `delayed.mk_ammo=2`, `delayed.mk_grenades=1`, `delay=8`, `need_tag=tbl`, `need_tag.1=grenade`, `tags=tbl`, `cycle=1`, `index=78`, `exclude_tag=tbl`, `team=0`, `need=tbl`, `gid=78`, `sac=tbl`, `ext=2`, `need_card=tbl`, `gain=tbl`, `n=1`, `pwe=4`
- **Right-hand**: `gid=79`, `id=Right-hand`, `n=1`, `team=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=ally`, `exclude_tag=tbl`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Gradual Absolution`, `need_card.1.2=Possessed`, `need_card.1.3=The Red Book`, `sac=tbl`, `index=79`, `gain=tbl`, `allies=tbl`, `allies.1=2`, `ext=3`, `pwe=4`
- **Warhorse**: `gid=80`, `id=Warhorse`, `n=1`, `team=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=ally`, `exclude_tag=tbl`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Saddle`, `need_card.1.2=Knightmare`, `need_card.1.3=Cavalry`, `sac=tbl`, `index=80`, `gain=tbl`, `allies=tbl`, `allies.1=1`, `ext=3`, `pwe=4`
- **Bastion**: `gid=81`, `id=Bastion`, `n=1`, `team=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=ally`, `exclude_tag=tbl`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Highest Dungeon`, `need_card.1.2=Bunker`, `need_card.1.3=Lookout Tower`, `sac=tbl`, `index=81`, `gain=tbl`, `allies=tbl`, `allies.1=3`, `ext=3`, `pwe=4`
- **Sprint**: `gid=82`, `id=Sprint`, `need_card=tbl`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `sprint=1`, `sac=tbl`, `index=82`, `gain=tbl`, `team=0`, `ext=3`, `pwe=4`
- **Soul Projection**: `gid=83`, `id=Soul Projection`, `n=1`, `team=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=ally`, `exclude_tag=tbl`, `summoner=1`, `sac=tbl`, `index=83`, `gain=tbl`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Undead Armies`, `need_card.1.2=Knightmare`, `ext=3`, `pwe=4`
- **Onboarding Party**: `gid=84`, `id=Onboarding Party`, `n=1`, `team=0`, `need_tag=tbl`, `onboarding=1`, `tags=tbl`, `exclude_tag=tbl`, `need=tbl`, `sac=tbl`, `index=84`, `gain=tbl`, `need_card=tbl`, `need_card.1=Welcome Gift`, `ext=3`, `pwe=4`
- **Small Key**: `gid=85`, `id=Small Key`, `n=1`, `small_key=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=0`, `exclude_tag=tbl`, `sac=tbl`, `index=85`, `gain=tbl`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Prison`, `need_card.1.2=Trowel`, `ext=3`, `pwe=4`
- **Rapunzel**: `gid=86`, `id=Rapunzel`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Lady in the Tower`, `need_card.1.2=Highest Dungeon`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=ally`, `rapunzel=1`, `exclude_tag=tbl`, `sac=tbl`, `index=86`, `gain=tbl`, `team=0`, `ext=3`, `pwe=4`
- **Wand of Treachery**: `gid=87`, `id=Wand of Treachery`, `wand=tbl`, `wand.1=8`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=ally`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=87`, `gain=tbl`, `team=0`, `ext=3`, `pwe=1`
- **Guerilla Tactics**: `id=Guerilla Tactics`, `need_tag=tbl`, `tags=tbl`, `tags.1=grenade`, `grenades_max=1`, `index=88`, `special=grenade`, `exclude_tag=tbl`, `gid=88`, `need=tbl`, `ammo_max=1`, `ext=3`, `firerange=1`, `sac=tbl`, `n=1`, `need_card=tbl`, `gain=tbl`, `team=0`, `pwe=4`
- **Shovel**: `id=Shovel`, `need_tag=tbl`, `blade=1`, `index=89`, `special=dig`, `exclude_tag=tbl`, `gid=89`, `tunnels=1`, `exclude=tbl`, `exclude.1=King's Shoulders`, `need=tbl`, `tags=tbl`, `tags.1=blade`, `tags.2=tunnels`, `hole_start=2`, `ext=3`, `sac=tbl`, `n=1`, `need_card=tbl`, `team=0`, `gain=tbl`, `pwe=2`
- **Grindstone**: `id=Grindstone`, `delayed=tbl`, `delayed.blade=1`, `delay=6`, `need_tag=tbl`, `tags=tbl`, `cycle=1`, `index=90`, `exclude_tag=tbl`, `gid=90`, `need=tbl`, `gain=tbl`, `sac=tbl`, `ext=3`, `need_card=tbl`, `team=0`, `n=1`, `pwe=2`
- **Death Mark**: `n=2`, `gid=91`, `id=Death Mark`, `exclude_tag=tbl`, `team=0`, `sheath=1`, `need=tbl`, `tags=tbl`, `tags.1=on_hit`, `need_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=91`, `gain=tbl`, `firepower=-1`, `ext=3`, `pwe=4`
- **Shrapnel**: `gain=tbl`, `team=0`, `id=Shrapnel`, `knockback=15`, `pwe=4`, `need_tag=tbl`, `need_tag.1=on_hit`, `need=tbl`, `tags=tbl`, `tags.1=on_hit`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=92`, `n=2`, `gid=92`, `ext=3`, `shrapnel=3`
- **Backups**: `gid=100`, `id=Backups`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=1`, `exclude_tag=tbl`, `sac=tbl`, `index=93`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `n=3`, `ext=0`, `pwe=4`
- **Cavalry**: `gid=101`, `id=Cavalry`, `need_card=tbl`, `delay=15`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=1`, `exclude_tag=tbl`, `sac=tbl`, `index=94`, `n=1`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `ext=0`, `pwe=4`
- **Conclave**: `gid=102`, `id=Conclave`, `need_card=tbl`, `delay=15`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=1`, `exclude_tag=tbl`, `sac=tbl`, `index=95`, `n=1`, `gain=tbl`, `gain.1=2`, `gain.2=2`, `ext=0`, `pwe=4`
- **Entitle**: `gid=103`, `id=Entitle`, `team=1`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `sac.1=0`, `index=96`, `n=1`, `gain=tbl`, `gain.1=1`, `ext=0`, `ammo_max=-1`
- **Cardinal**: `gid=104`, `id=Cardinal`, `team=1`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `sac.1=0`, `index=97`, `n=1`, `gain=tbl`, `gain.1=2`, `ext=0`, `ammo_max=-1`
- **Remparts**: `gid=105`, `id=Remparts`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=1`, `exclude_tag=tbl`, `sac=tbl`, `sac.1=0`, `sac.2=0`, `index=98`, `gain=tbl`, `gain.1=3`, `n=2`, `ext=0`, `pwe=4`
- **Pillage**: `gid=106`, `id=Pillage`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `pawn_hp=1`, `sac=tbl`, `sac.1=3`, `index=99`, `n=1`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `gain.4=0`, `gain.5=0`, `ext=0`, `pwe=4`
- **Crusades**: `gid=107`, `id=Crusades`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `exclude_tag=tbl`, `sac=tbl`, `sac.1=2`, `index=100`, `n=1`, `team=1`, `ext=0`, `pwe=4`
- **Peace**: `gid=108`, `id=Peace`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=2`, `gain.2=2`, `exclude_tag=tbl`, `sac=tbl`, `sac.1=1`, `index=101`, `n=1`, `team=1`, `ext=0`, `pwe=4`
- **King's Mistress**: `gid=109`, `id=King's Mistress`, `sac=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `need.1=4`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `queen_cage=3`, `index=102`, `n=1`, `gain=tbl`, `gain.1=4`, `ext=0`, `pwe=4`
- **Revolution**: `gid=110`, `id=Revolution`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `gain.4=0`, `gain.5=0`, `gain.6=0`, `exclude_tag=tbl`, `sac=tbl`, `sac.1=2`, `index=103`, `n=1`, `team=1`, `ext=0`, `pwe=4`
- **Bodyguard**: `index=104`, `gid=111`, `id=Bodyguard`, `exclude_tag=tbl`, `knight_hp=1`, `need_tag=tbl`, `need=tbl`, `need.1=1`, `need.2=8`, `tags=tbl`, `need_card=tbl`, `gain=tbl`, `sac=tbl`, `knight_bodyguard=1`, `n=1`, `team=1`, `ext=0`, `pwe=4`
- **Ruins**: `gid=112`, `id=Ruins`, `team=1`, `gain=tbl`, `gain.1=3`, `gain.2=0`, `gain.3=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=105`, `n=1`, `rook_hp=-2`, `ext=0`, `pwe=4`
- **Assault**: `gid=113`, `id=Assault`, `ext=0`, `team=1`, `need_tag=tbl`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `need.4=0`, `need.5=0`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=106`, `n=1`, `gain=tbl`, `gain.1=0`, `pawn_assault=1`, `pwe=4`
- **Kite Shield**: `gid=114`, `id=Kite Shield`, `team=1`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `need.1=1`, `need.2=1`, `tags=tbl`, `tags.1=on_hit`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=107`, `n=1`, `gain=tbl`, `gain.1=0`, `ext=0`, `knight_shield=1`
- **Zealots**: `id=Zealots`, `need_tag=tbl`, `tags=tbl`, `index=108`, `exclude_tag=tbl`, `pawn_tempo=-1`, `gid=115`, `flip_on=no_bishop`, `need=tbl`, `need.1=2`, `team=1`, `ext=0`, `sac=tbl`, `bishop_tempo=-1`, `need_card=tbl`, `n=1`, `gain=tbl`, `pwe=4`
- **Militia**: `need_card=tbl`, `gid=116`, `id=Militia`, `pawn_militia=1`, `exclude=tbl`, `exclude.1=Bloodless Coups`, `need_tag=tbl`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `exclude_tag=tbl`, `sac=tbl`, `index=109`, `n=1`, `team=1`, `ext=0`, `pwe=4`
- **Ammunition Depot**: `gid=117`, `id=Ammunition Depot`, `need_card=tbl`, `rook_shell=2`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=1`, `exclude_tag=tbl`, `sac=tbl`, `index=110`, `n=2`, `gain=tbl`, `gain.1=3`, `ext=0`, `pwe=4`
- **Scouting**: `pawn_tempo=-1`, `gid=118`, `id=Scouting`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `exclude_tag=tbl`, `sac=tbl`, `sac.1=1`, `index=111`, `n=1`, `team=1`, `ext=0`, `pwe=4`
- **Pikemen**: `id=Pikemen`, `need_tag=tbl`, `tags=tbl`, `pawn_hp=1`, `index=112`, `exclude_tag=tbl`, `team=1`, `pawn_pike=1`, `pawn_reformed=1`, `gid=119`, `ext=0`, `sac=tbl`, `need=tbl`, `need.1=0`, `need.2=0`, `need_card=tbl`, `n=1`, `gain=tbl`, `pwe=4`
- **Ascension**: `gid=120`, `id=Ascension`, `need_card=tbl`, `tags=tbl`, `need_tag=tbl`, `need=tbl`, `need.1=2`, `need.2=2`, `bishop_flying=1`, `team=1`, `exclude_tag=tbl`, `sac=tbl`, `index=113`, `gain=tbl`, `n=1`, `ext=0`, `pwe=4`
- **Castle**: `exclude=tbl`, `exclude.1=Guillotine`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `index=114`, `rook_hp=1`, `exclude_tag=tbl`, `gid=121`, `need=tbl`, `need.1=3`, `need.2=8`, `id=Castle`, `rook_castle=1`, `ext=0`, `sac=tbl`, `n=1`, `need_card=tbl`, `gain=tbl`, `team=1`, `pwe=4`
- **Conscription**: `need_card=tbl`, `team=1`, `id=Conscription`, `gid=122`, `delay=5`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `cycle=1`, `sac=tbl`, `index=115`, `n=2`, `gain=tbl`, `gain.1=0`, `ext=0`, `pwe=4`
- **Theocracy**: `id=Theocracy`, `ruler=2`, `theocracy=1`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `index=116`, `exclude_tag=tbl`, `gid=123`, `exclude=tbl`, `exclude.1=Guillotine`, `need=tbl`, `need.1=2`, `need.2=2`, `sac=tbl`, `sac.1=5`, `ext=0`, `bishop_hp=2`, `no_ruler=1`, `team=1`, `need_card=tbl`, `gain=tbl`, `gain.1=2`, `n=1`, `pwe=4`
- **Fallen Dynasty**: `gid=124`, `id=Fallen Dynasty`, `index=117`, `exclude_tag=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `n=1`, `sac=tbl`, `fallen=1`, `gain=tbl`, `team=1`, `ext=0`, `pwe=0`
- **Iron Maiden**: `id=Iron Maiden`, `need_tag=tbl`, `tags=tbl`, `index=118`, `exclude_tag=tbl`, `gid=125`, `flip_on=only_queen`, `need=tbl`, `need.1=4`, `need.2=4`, `team=1`, `ext=0`, `n=1`, `sac=tbl`, `sac.1=4`, `queen_iron=1`, `need_card=tbl`, `queen_tempo=2`, `gain=tbl`, `pwe=4`
- **Court of the King**: `gid=126`, `id=Court of the King`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `all_tempo=1`, `exclude_tag=tbl`, `sac=tbl`, `index=119`, `n=2`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `gain.3=2`, `gain.4=3`, `ext=0`, `pwe=4`
- **The Red Book**: `gain=tbl`, `gain.1=2`, `gid=127`, `id=The Red Book`, `exclude=tbl`, `exclude.1=The Royal Hunt`, `exclude.2=Buckler of Limos`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=120`, `n=1`, `team=1`, `ext=0`, `bishop_orth=1`
- **Saboteur**: `bad_shells=1`, `gid=128`, `id=Saboteur`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=1`, `exclude_tag=tbl`, `sac=tbl`, `sac.1=0`, `sac.2=0`, `index=121`, `n=2`, `gain=tbl`, `gain.1=2`, `ext=0`, `pwe=4`
- **Homecoming**: `gid=129`, `id=Homecoming`, `team=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=122`, `n=1`, `gain=tbl`, `gain.1=4`, `ext=0`, `pwe=0`
- **Lookout Tower**: `gid=130`, `team=1`, `id=Lookout Tower`, `pwe=4`, `delay=20`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=123`, `gain=tbl`, `gain.1=3`, `n=2`, `ext=0`, `alarm=1`
- **Throne Room**: `exclude=tbl`, `exclude.1=Guillotine`, `queen_hp=1`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `index=124`, `exclude_tag=tbl`, `team=1`, `need=tbl`, `need.1=5`, `id=Throne Room`, `ext=0`, `gain=tbl`, `sac=tbl`, `n=1`, `need_card=tbl`, `leader_hp=2`, `gid=131`, `pwe=4`
- **The Secret Heir**: `need_card=tbl`, `gid=132`, `id=The Secret Heir`, `exclude=tbl`, `exclude.1=Guillotine`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=leader`, `heir=1`, `exclude_tag=tbl`, `sac=tbl`, `index=125`, `gain=tbl`, `gain.1=0`, `team=1`, `ext=0`, `pwe=4`
- **Genderqueer**: `gid=133`, `id=Genderqueer`, `need_card=tbl`, `delay=10`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=1`, `exclude_tag=tbl`, `sac=tbl`, `sac.1=2`, `index=126`, `n=1`, `gain=tbl`, `gain.1=4`, `ext=0`, `pwe=4`
- **Karma**: `sqb_spread=30`, `id=Karma`, `need_tag=tbl`, `tags=tbl`, `index=127`, `exclude_tag=tbl`, `team=1`, `gain=tbl`, `need=tbl`, `ext=1`, `sqw_firepower=-1`, `n=1`, `sac=tbl`, `gid=134`, `need_card=tbl`, `reversable=1`, `reform=1`, `pwe=4`
- **Undead Armies**: `need_card=tbl`, `gid=135`, `id=Undead Armies`, `knight_bishop_rook_rep=0`, `n=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `pawn_hp=-1`, `sac=tbl`, `index=128`, `gain=tbl`, `team=1`, `ext=1`, `pwe=4`
- **Shortage**: `gain=tbl`, `team=1`, `id=Shortage`, `exclude_tag=tbl`, `pwe=4`, `need_tag=tbl`, `need_tag.1=grenade`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `grenades_max=-1`, `sac=tbl`, `sac.1=0`, `index=129`, `n=1`, `gid=136`, `ext=1`, `ammo_max=-3`
- **Succubus**: `gid=137`, `id=Succubus`, `need_card=tbl`, `gain=tbl`, `gain.1=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `soul_slot=1`, `sac=tbl`, `index=130`, `n=1`, `team=1`, `ext=1`, `pwe=4`
- **Bunker**: `exclude=tbl`, `exclude.1=Guillotine`, `leader_pawn_hp=1`, `need_tag=tbl`, `need_tag.1=grenade`, `tags=tbl`, `tags.1=leader`, `index=131`, `grenade_dmg=-1`, `exclude_tag=tbl`, `gid=138`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `id=Bunker`, `ext=1`, `sac=tbl`, `sac.1=3`, `n=1`, `need_card=tbl`, `gain=tbl`, `team=1`, `pwe=4`
- **Sanctity**: `gid=139`, `id=Sanctity`, `need_card=tbl`, `need_card.1=Conclave`, `team=1`, `bishop_sanctity=1`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_tag=tbl`, `sac=tbl`, `index=132`, `n=1`, `gain=tbl`, `gain.1=2`, `ext=1`, `pwe=4`
- **Knightmare**: `knight_hp=-1`, `team=1`, `id=Knightmare`, `exclude_tag=tbl`, `gid=140`, `need_tag=tbl`, `knight_wraith=1`, `tags=tbl`, `n=1`, `gain=tbl`, `sac=tbl`, `index=133`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Fearsome`, `need_card.1.2=Black Mist`, `need=tbl`, `need.1=1`, `need.2=1`, `ext=1`, `pwe=4`
- **Highest Dungeon**: `gid=141`, `team=1`, `id=Highest Dungeon`, `need_tag=tbl`, `exclude_tag=tbl`, `flip_on=no_rook`, `need=tbl`, `need.1=3`, `tags=tbl`, `need_card=tbl`, `gain=tbl`, `sac=tbl`, `index=134`, `n=1`, `all_hp=1`, `ext=1`, `pwe=2`
- **Cathedral**: `gid=142`, `id=Cathedral`, `n=1`, `team=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `rook_protect=1`, `exclude_tag=tbl`, `sac=tbl`, `sac.1=2`, `index=135`, `gain=tbl`, `gain.1=3`, `need_card=tbl`, `need_card.1=Cardinal`, `ext=1`, `pwe=4`
- **The Bridge**: `bridge=1`, `team=1`, `id=The Bridge`, `gid=143`, `delay=10`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `n=1`, `sac=tbl`, `index=136`, `need_card=tbl`, `need_card.1=The Moat`, `gain=tbl`, `gain.1=1`, `ext=1`, `pwe=4`
- **Divine Healing**: `gain=tbl`, `gid=144`, `id=Divine Healing`, `exclude_tag=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `need.1=2`, `tags=tbl`, `need_card=tbl`, `bishop_healer=2`, `sac=tbl`, `index=137`, `n=1`, `bishop_hp=1`, `ext=1`, `pwe=4`
- **Last Guardian**: `gid=145`, `id=Last Guardian`, `sac=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `need.1=0`, `need.2=0`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `pawn_lastg=1`, `index=138`, `gain=tbl`, `n=1`, `ext=1`, `pwe=4`
- **Trowel**: `gain=tbl`, `gid=146`, `id=Trowel`, `exclude_tag=tbl`, `team=1`, `flip_on=no_pawn`, `need=tbl`, `need.1=3`, `need.2=0`, `tags=tbl`, `need_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=139`, `n=1`, `rook_hp=4`, `ext=1`, `pwe=4`
- **Full Plate Armor**: `id=Full Plate Armor`, `need_tag=tbl`, `tags=tbl`, `tags.1=blade`, `index=140`, `exclude_tag=tbl`, `gid=147`, `exclude=tbl`, `exclude.1=King's Shoulders`, `team=1`, `all_hp=1`, `ext=1`, `all_tempo=1`, `gain=tbl`, `sac=tbl`, `n=1`, `need_card=tbl`, `need=tbl`, `blade=-1`, `pwe=4`
- **Military Academy**: `need_card=tbl`, `gid=148`, `id=Military Academy`, `team=1`, `delay=10`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `cycle=1`, `sac=tbl`, `index=141`, `n=1`, `gain=tbl`, `gain.1=1`, `ext=1`, `pwe=4`
- **Witch's Curse**: `id=Witch's Curse`, `need_tag=tbl`, `tags=tbl`, `index=142`, `queen_curse=1`, `exclude_tag=tbl`, `gid=149`, `need_card=tbl`, `need=tbl`, `need.1=4`, `ext=1`, `gain=tbl`, `firerange=-1`, `sac=tbl`, `team=1`, `spread=10`, `firepower=-1`, `n=1`, `pwe=4`
- **Saddle**: `ext=1`, `gid=150`, `id=Saddle`, `exclude_tag=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `need.1=1`, `tags=tbl`, `need_card=tbl`, `gain=tbl`, `sac=tbl`, `index=143`, `n=1`, `knight_carry=1`, `knight_tempo=1`, `pwe=4`
- **The Jester**: `team=1`, `id=The Jester`, `index=144`, `gid=151`, `need_tag=tbl`, `need=tbl`, `need.1=0`, `tags=tbl`, `exclude_tag=tbl`, `n=1`, `sac=tbl`, `jester=1`, `gain=tbl`, `gain.1=0`, `need_card=tbl`, `need_card.1=Throne Room`, `ext=1`, `pwe=4`
- **Guillotine**: `gid=152`, `id=Guillotine`, `ext=1`, `exclude=tbl`, `exclude.1=Ritual Dagger`, `exclude.2=Subtle Poison`, `exclude.3=Kingdom Wealth`, `exclude.4=Golden Aging`, `exclude.5=Castle`, `exclude.6=Theocracy`, `exclude.7=Throne Room`, `exclude.8=The Secret Heir`, `exclude.9=Bunker`, `exclude.10=Emergency Call`, `exclude.11=Mausoleum`, `exclude.12=King's Look-alike`, `exclude.13=The Royal Hunt`, `exclude.14=Buckler of Limos`, `exclude.15=Vampirism`, `exclude.16=Commoner's Reign`, `exclude.17=Unsettled Throne`, `exclude.18=Anarchy`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=1`, `gain=tbl`, `sac=tbl`, `sac.1=5`, `index=145`, `n=1`, `need_card=tbl`, `need_card.1=Revolution`, `exclude_tag=tbl`, `exclude_tag.1=leader`, `pwe=4`
- **Analysis Paralysis**: `paralysis=6`, `team=1`, `id=Analysis Paralysis`, `exclude_tag=tbl`, `gid=153`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gain=tbl`, `search=1`, `sac=tbl`, `index=146`, `need_card=tbl`, `need_card.1=High Focus`, `n=2`, `ext=1`, `pwe=4`
- **Plumed Knight**: `gid=154`, `id=Plumed Knight`, `team=1`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `need.1=1`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=147`, `gain=tbl`, `n=1`, `ext=2`, `choose_knight_plumed=1`
- **Emergency Call**: `leader_emergency=1`, `gid=155`, `id=Emergency Call`, `need_card=tbl`, `exclude=tbl`, `exclude.1=Guillotine`, `need_tag=tbl`, `need=tbl`, `need.1=0`, `need.2=0`, `tags=tbl`, `tags.1=leader`, `gain=tbl`, `gain.1=0`, `exclude_tag=tbl`, `sac=tbl`, `index=148`, `n=1`, `team=1`, `ext=2`, `pwe=4`
- **Mangonel**: `gain=tbl`, `gain.1=3`, `gid=156`, `id=Mangonel`, `exclude_tag=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `rook_catapult=1`, `sac=tbl`, `index=149`, `n=1`, `rook_tempo=2`, `ext=2`, `pwe=4`
- **Governess**: `gid=157`, `id=Governess`, `force_promote=4`, `need_card=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `n=1`, `exclude_tag=tbl`, `sac=tbl`, `index=150`, `gain=tbl`, `gain.1=2`, `team=1`, `ext=2`, `pwe=4`
- **Mausoleum**: `need_card=tbl`, `gid=158`, `id=Mausoleum`, `rook_leaderbond=2`, `exclude=tbl`, `exclude.1=Guillotine`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=leader`, `n=1`, `exclude_tag=tbl`, `sac=tbl`, `index=151`, `gain=tbl`, `gain.1=3`, `team=1`, `ext=2`, `pwe=4`
- **Reverend Mother**: `gid=159`, `id=Reverend Mother`, `gain=tbl`, `gain.1=4`, `queen_despair=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `team=1`, `exclude_tag=tbl`, `sac=tbl`, `index=152`, `n=1`, `need_card=tbl`, `need_card.1=Theocracy`, `ext=2`, `pwe=4`
- **Sokoban**: `gid=160`, `id=Sokoban`, `need_card=tbl`, `team=1`, `rook_push=3`, `need=tbl`, `need.1=3`, `need.2=3`, `tags=tbl`, `exclude_tag=tbl`, `need_tag=tbl`, `sac=tbl`, `index=153`, `n=1`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `ext=2`, `pwe=4`
- **Tag Team**: `id=Tag Team`, `need_tag=tbl`, `tags=tbl`, `index=154`, `exclude_tag=tbl`, `gid=161`, `team=1`, `bishop_swap=tbl`, `bishop_swap.1=3`, `rook_swap=tbl`, `rook_swap.1=2`, `rook_bishop_hp=1`, `ext=2`, `sac=tbl`, `need=tbl`, `need.1=2`, `need.2=3`, `need_card=tbl`, `n=1`, `gain=tbl`, `pwe=4`
- **Unicorn**: `team=1`, `id=Unicorn`, `need_card=tbl`, `gain=tbl`, `gain.1=1`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `knight_charge=1`, `sac=tbl`, `index=155`, `n=1`, `gid=162`, `ext=2`, `pwe=4`
- **Lady in the Tower**: `gid=163`, `id=Lady in the Tower`, `rook_killprom=4`, `gain=tbl`, `gain.1=3`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=156`, `n=1`, `team=1`, `ext=2`, `pwe=4`
- **Final Countdown**: `team=1`, `gid=164`, `id=Final Countdown`, `exclude_tag=tbl`, `pwe=4`, `need_tag=tbl`, `deathcount=12`, `tags=tbl`, `need_card=tbl`, `need=tbl`, `sac=tbl`, `index=157`, `gain=tbl`, `n=1`, `ext=2`, `deathcount_trig=6`
- **Nomad Life**: `team=1`, `id=Nomad Life`, `index=158`, `gid=165`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `sac.1=3`, `knight_promote=1`, `n=2`, `gain=tbl`, `gain.1=1`, `gain.2=1`, `gain.3=2`, `ext=2`, `pwe=4`
- **Prison**: `gid=166`, `id=Prison`, `gain=tbl`, `gain.1=2`, `gain.2=1`, `team=1`, `need_tag=tbl`, `need=tbl`, `need.1=1`, `need.2=2`, `need.3=3`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=159`, `n=1`, `knight_bishop_prison=3`, `ext=2`, `pwe=4`
- **Inquisition**: `team=1`, `gid=167`, `id=Inquisition`, `exclude_tag=tbl`, `ext=2`, `need_tag=tbl`, `need_tag.1=mission`, `need_tag.2=cloak`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `n=1`, `sac=tbl`, `sac.1=0`, `index=160`, `gain=tbl`, `gain.1=2`, `bishop_uncover=1`, `bishop_investigate=1`, `pwe=4`
- **King's Look-alike**: `id=King's Look-alike`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `index=161`, `ext=2`, `gid=168`, `exclude=tbl`, `exclude.1=Guillotine`, `exclude_tag=tbl`, `need=tbl`, `team=1`, `no_ruler=1`, `n=2`, `sac=tbl`, `gain=tbl`, `gain.1=5`, `need_card=tbl`, `leader_hp=1`, `false_king=1`, `pwe=4`
- **The Royal Hunt**: `n=2`, `gid=169`, `id=The Royal Hunt`, `exclude=tbl`, `exclude.1=The Red Book`, `exclude.2=Guillotine`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=162`, `gain=tbl`, `team=1`, `ext=2`, `leader_bow=2`
- **Tragic Homecoming**: `team=1`, `id=Tragic Homecoming`, `queen_hp=2`, `gid=170`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=163`, `n=1`, `gain=tbl`, `gain.1=4`, `ext=2`, `pwe=0`
- **Buckler of Limos**: `leader_armorgap=3`, `leader_tempo=1`, `id=Buckler of Limos`, `need_firepower=5`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `index=164`, `exclude_tag=tbl`, `gid=171`, `need=tbl`, `exclude=tbl`, `exclude.1=The Red Book`, `exclude.2=Guillotine`, `team=1`, `ext=2`, `sac=tbl`, `leader_buckler=1`, `need_card=tbl`, `n=1`, `gain=tbl`, `pwe=4`
- **Vampirism**: `exclude=tbl`, `exclude.1=Guillotine`, `leader_queen_vampire=1`, `need_tag=tbl`, `need_tag.1=bleed`, `tags=tbl`, `tags.1=leader`, `leader_queen_hp=1`, `index=165`, `exclude_tag=tbl`, `gid=172`, `need=tbl`, `id=Vampirism`, `ext=2`, `sac=tbl`, `gain=tbl`, `need_card=tbl`, `n=1`, `team=1`, `pwe=4`
- **Commoner's Reign**: `exclude=tbl`, `exclude.1=Guillotine`, `ruler=1`, `need_tag=tbl`, `tags=tbl`, `tags.1=leader`, `index=166`, `knight_hp=2`, `exclude_tag=tbl`, `gid=173`, `need=tbl`, `id=Commoner's Reign`, `ext=2`, `sac=tbl`, `sac.1=5`, `gain=tbl`, `gain.1=1`, `need_card=tbl`, `team=1`, `n=1`, `pwe=0`
- **Bouncy Castle**: `id=Bouncy Castle`, `need_knockback=100`, `tags=tbl`, `index=167`, `rook_hp=-2`, `exclude_tag=tbl`, `gid=174`, `trampoline=1`, `need=tbl`, `team=1`, `ext=2`, `sac=tbl`, `n=1`, `need_card=tbl`, `gain=tbl`, `need_tag=tbl`, `pwe=4`
- **Self-Defense**: `gid=175`, `id=Self-Defense`, `knight_hp=2`, `exclude_tag=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `need_card=tbl`, `n=1`, `sac=tbl`, `index=168`, `gain=tbl`, `team=1`, `ext=2`, `pwe=0`
- **Unsettled Throne**: `id=Unsettled Throne`, `heirprom=1`, `need_tag=tbl`, `need_heir=1`, `tags=tbl`, `tags.1=leader`, `heir=1`, `index=169`, `exclude_tag=tbl`, `gid=176`, `need=tbl`, `exclude=tbl`, `exclude.1=Guillotine`, `team=1`, `sac=tbl`, `ext=2`, `need_card=tbl`, `gain=tbl`, `n=1`, `pwe=4`
- **Vendetta**: `exclude=tbl`, `exclude.1=King's Shoulders`, `need_tag=tbl`, `tags=tbl`, `tags.1=blade`, `vendetta=1`, `index=170`, `exclude_tag=tbl`, `team=1`, `need=tbl`, `id=Vendetta`, `ext=3`, `gid=177`, `sac=tbl`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Tragic Homecoming`, `need_card.1.2=King's Mistress`, `gain=tbl`, `n=1`, `blade=1`, `pwe=8`
- **Stoning**: `need_card=tbl`, `gid=178`, `id=Stoning`, `exclude=tbl`, `exclude.1=Bloodless Coups`, `n=1`, `need_tag=tbl`, `need=tbl`, `need.1=0`, `need.2=0`, `need.3=0`, `need.4=0`, `need.5=0`, `tags=tbl`, `pawn_stoning=1`, `exclude_tag=tbl`, `sac=tbl`, `index=171`, `gain=tbl`, `team=1`, `ext=3`, `pwe=4`
- **Anarchy**: `anarchy=1`, `gid=179`, `id=Anarchy`, `gain=tbl`, `exclude=tbl`, `exclude.1=Guillotine`, `need_tag=tbl`, `need=tbl`, `need.1=0`, `need.2=1`, `need.3=2`, `need.4=3`, `need.5=4`, `tags=tbl`, `tags.1=leader`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=172`, `n=1`, `team=1`, `ext=3`, `pwe=2`
- **Auto-da-fe**: `team=1`, `id=Auto-da-fe`, `index=173`, `gid=180`, `need_tag=tbl`, `need=tbl`, `need.1=2`, `tags=tbl`, `exclude_tag=tbl`, `n=1`, `sac=tbl`, `bishop_censor=1`, `gain=tbl`, `gain.1=2`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Inquisition`, `need_card.1.2=Conclave`, `need_card.1.3=Zealots`, `ext=3`, `pwe=4`
- **Late for dinner**: `team=1`, `id=Late for dinner`, `n=1`, `delay=10`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `gid=181`, `exclude_tag=tbl`, `sac=tbl`, `sac.1=0`, `sac.2=1`, `sac.3=2`, `index=174`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Kingdom Wealth`, `need_card.1.2=Final Countdown`, `gain=tbl`, `gain.1=0`, `gain.2=1`, `gain.3=2`, `gain.4=3`, `ext=3`, `pwe=4`
- **Excommunication**: `gid=182`, `id=Excommunication`, `need_card=tbl`, `team=1`, `need_tag=tbl`, `need=tbl`, `need.1=2`, `tags=tbl`, `exclude_tag=tbl`, `exile=15`, `sac=tbl`, `index=175`, `n=1`, `gain=tbl`, `gain.1=3`, `gain.2=1`, `ext=3`, `pwe=4`
- **Pyre of Lust**: `team=1`, `id=Pyre of Lust`, `n=1`, `exclude_tag=tbl`, `need_tag=tbl`, `need=tbl`, `need.1=2`, `tags=tbl`, `need_card=tbl`, `exile=15`, `sac=tbl`, `index=176`, `gain=tbl`, `gain.1=4`, `gid=183`, `ext=3`, `pwe=2`
- **Gatehouse**: `id=Gatehouse`, `need_tag=tbl`, `tags=tbl`, `index=177`, `rook_hp=-1`, `exclude_tag=tbl`, `rook_spawn=1`, `gid=184`, `rook_tempo=2`, `need=tbl`, `need.1=3`, `gain=tbl`, `sac=tbl`, `ext=3`, `n=1`, `need_card=tbl`, `need_card.1=tbl`, `need_card.1.1=Remparts`, `need_card.1.2=Trowel`, `team=1`, `pwe=4`
- **Lightfoot**: `gid=185`, `id=Lightfoot`, `pawn_lightfoot=1`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=178`, `n=1`, `team=1`, `ext=3`, `pwe=4`
- **Loyalist March**: `gid=186`, `id=Loyalist March`, `team=1`, `delay=10`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=179`, `n=1`, `gain=tbl`, `gain.1=0`, `gain.2=0`, `gain.3=0`, `gain.4=0`, `gain.5=0`, `gain.6=0`, `gain.7=0`, `gain.8=0`, `ext=3`, `pwe=2`
- **Trench War**: `ext=3`, `gid=187`, `id=Trench War`, `need_card=tbl`, `exclude_tag=tbl`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `hole_start=5`, `team=1`, `sac=tbl`, `index=180`, `n=2`, `gain=tbl`, `gain.1=1`, `hole_cover=1`, `pwe=2`
- **Catacombs**: `n=1`, `team=1`, `id=Catacombs`, `tags=tbl`, `gid=188`, `need_tag=tbl`, `need_tag.1=tunnels`, `need=tbl`, `hole_solid=1`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=181`, `spread=10`, `gain=tbl`, `gain.1=3`, `ext=3`, `pwe=4`
- **Flesh Wall**: `gid=189`, `id=Flesh Wall`, `gain=tbl`, `gain.1=0`, `tags=tbl`, `need_tag=tbl`, `need=tbl`, `pawn_block=1`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=182`, `n=1`, `team=1`, `ext=3`, `pwe=2`
- **Hired Blade**: `team=1`, `id=Hired Blade`, `gid=190`, `pwe=4`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `sac.1=0`, `index=183`, `n=2`, `gain=tbl`, `gain.1=12`, `ext=3`, `ammo_max=-1`
- **Oathkeeper**: `gid=191`, `id=Oathkeeper`, `gain=tbl`, `gain.1=13`, `need_tag=tbl`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=184`, `n=1`, `team=1`, `ext=3`, `pwe=2`
- **Redemption**: `gid=192`, `id=Redemption`, `redemption=1`, `team=1`, `need_tag=tbl`, `need_tag.1=ally`, `need=tbl`, `tags=tbl`, `exclude_tag=tbl`, `need_card=tbl`, `sac=tbl`, `index=185`, `n=1`, `gain=tbl`, `gain.1=2`, `ext=3`, `pwe=4`
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

## 12d. Souls, scepters & pieces probe (build 5+)

- `piece|type=0|name=pawn|hp=3|tempo=5|danger=1`
- `piece_0|tempo=5`
- `piece_0|danger=1`
- `piece_0|seek=wdist`
- `piece_0|name=pawn`
- `piece_0|type=0`
- `piece_0|index=0`
- `piece_0|behavior=tbl`
- `piece_0|behavior.1=tbl`
- `piece_0|behavior.1.1=1`
- `piece_0|behavior.1.2=1`
- `piece_0|behavior.1.3=1`
- `piece_0|behavior.1.native=1`
- `piece_0|behavior.1.move=1`
- `piece_0|behavior.1.id=line`
- `piece_0|behavior.2=tbl`
- `piece_0|behavior.2.1=4`
- `piece_0|behavior.2.2=5`
- `piece_0|behavior.2.3=1`
- `piece_0|behavior.2.native=1`
- `piece_0|behavior.2.atk=1`
- `piece_0|behavior.2.id=line`
- `piece_0|sided=1`
- `piece_0|hdy=2`
- `piece_0|hp=3`
- `piece_0|fields_shown=10`
- `piece|type=1|name=knight|hp=3|tempo=3|danger=3`
- `piece_1|tempo=3`
- `piece_1|danger=3`
- `piece_1|reap=1`
- `piece_1|seek=kdist`
- `piece_1|name=knight`
- `piece_1|type=1`
- `piece_1|index=1`
- `piece_1|behavior=tbl`
- `piece_1|behavior.1=tbl`
- `piece_1|behavior.1.1=2`
- `piece_1|behavior.1.2=-1`
- `piece_1|behavior.1.3=2`
- `piece_1|behavior.1.4=1`

## 12f. Input & button-remap probe (build 5+)

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
- `btn|unsafe=false`
- `btn|cancel=false`
- `btn|ctrl=false`

## 12g. Dev panel, Mod Menu & Save persistence (build 5+)

- `menu_state|n=1|menu=nil|mMenu=nil`

## 13. Next step

- Promote confirmed entries into `notes/map.md` (replace the TBD lines).
- Pick the dev-cheat panel targets from the ammo/UI candidate lists.
- Lines from other systems in the log: 1000 (ignored; raise an issue if the game seems noisy).
