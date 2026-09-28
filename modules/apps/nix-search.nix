{
  flake.aspects.base.home = { pkgs, ... }: let
    nixSearch = pkgs.writeShellApplication {
      name = "nix-search";
      runtimeInputs = with pkgs; [
        fzf
        nh
        jq
        ncurses
        xdg-utils
        wl-clipboard
      ];
      text = ''
        # Preview handler called by fzf
        if [ "''${1:-}" = "--preview" ]; then
            line="''${2:-}"
            name="" version="" desc="" extra1="" extra2="" extra3="" extra4="" item_type=""
            IFS=$'\t' read -r name version desc extra1 extra2 extra3 extra4 item_type <<< "$line"

            if [ "$item_type" = "pkg" ]; then
                printf "\033[1;36m━━━ Package: %s ━━━\033[0m\n\n" "$name"
                printf "\033[1;33mVersion:\033[0m     %s\n" "$version"
                printf "\033[1;33mMain Binary:\033[0m %s\n" "$extra3"
                printf "\033[1;33mLicense:\033[0m     %s\n" "$extra2"
                printf "\033[1;33mHomepage:\033[0m    \033[4;34m%s\033[0m\n" "$extra1"
                printf "\033[1;33mDefined In:\033[0m  %s\n\n" "$extra4"
                printf "\033[1;32mDescription:\033[0m\n%s\n\n" "$desc"
                printf "\033[1;35mActions:\033[0m\n"
                printf "  \033[1mEnter\033[0m   Copy attribute name (%s)\n" "$name"
                printf "  \033[1mCtrl-Y\033[0m  Copy 'pkgs.%s'\n" "$name"
                printf "  \033[1mCtrl-O\033[0m  Open web page in Zen Browser\n"
                printf "  \033[1mEsc\033[0m     Back to menu\n"
            elif [ "$item_type" = "opt" ]; then
                printf "\033[1;35m━━━ Option: %s ━━━\033[0m\n\n" "$name"
                printf "\033[1;33mType:\033[0m        %s\n" "$version"
                printf "\033[1;33mDefault:\033[0m     %s\n" "$extra1"
                printf "\033[1;33mDefined In:\033[0m  %s\n\n" "$extra2"
                printf "\033[1;32mDescription:\033[0m\n%s\n\n" "$desc"
                printf "\033[1;35mActions:\033[0m\n"
                printf "  \033[1mEnter\033[0m   Copy option name (%s)\n" "$name"
                printf "  \033[1mCtrl-Y\033[0m  Copy '%s = ...;'\n" "$name"
                printf "  \033[1mCtrl-O\033[0m  Open web page in Zen Browser\n"
                printf "  \033[1mEsc\033[0m     Back to menu\n"
            fi
            exit 0
        fi

        # If not running in a terminal (e.g. launched directly from app launcher), spawn inside floating ghostty
        if [ ! -t 0 ] || [ ! -t 1 ]; then
            exec ghostty --class=nix-search -e nix-search "$@"
        fi

        # Styling
        C_RESET="\033[0m"
        C_CYAN="\033[1;36m"
        C_GREEN="\033[1;32m"
        C_DIM="\033[38;2;140;140;160m"
        C_SEL_BG="\033[48;2;45;55;75m\033[38;2;255;255;255m\033[1m"
        C_BORDER="\033[38;2;80;90;120m"

        SOURCES=(
            "MyNixOS"
            "NixOS packages"
            "NixOS options"
        )

        DESCRIPTIONS=(
            "Search packages & options together"
            "Search official packages (search.nixos.org)"
            "Search official options (search.nixos.org)"
        )

        cleanup() {
            tput cnorm 2>/dev/null || true
        }
        trap cleanup EXIT

        read_key() {
            local key=""
            IFS= read -rsn1 key 2>/dev/null || return 1
            if [[ "$key" == $'\x1b' ]]; then
                local rest=""
                read -rsn2 -t 0.05 rest 2>/dev/null || rest=""
                key+="$rest"
            fi
            printf "%s" "$key"
        }

        render_menu() {
            local selected="$1"
            clear
            printf "\n"
            # shellcheck disable=SC2059
            {
                printf "''${C_BORDER}  ┌─────────────────────────────────────────────────────────────┐''${C_RESET}\n"
                printf "''${C_BORDER}  │''${C_RESET}  ''${C_CYAN}❄  NIX SEARCH NAVIGATOR''${C_RESET}                                   ''${C_BORDER}│''${C_RESET}\n"
                printf "''${C_BORDER}  ├─────────────────────────────────────────────────────────────┤''${C_RESET}\n"
                printf "''${C_BORDER}  │''${C_RESET}                                                             ''${C_BORDER}│''${C_RESET}\n"

                for i in "''${!SOURCES[@]}"; do
                    local name="''${SOURCES[$i]}"
                    local desc="''${DESCRIPTIONS[$i]}"
                    if [ "$i" -eq "$selected" ]; then
                        printf "''${C_BORDER}  │''${C_RESET}  ''${C_SEL_BG} ❯ %-16s ''${C_RESET} ''${C_GREEN}%-35s''${C_RESET} ''${C_BORDER}│''${C_RESET}\n" "$name" "$desc"
                    else
                        printf "''${C_BORDER}  │''${C_RESET}    %-16s   ''${C_DIM}%-35s''${C_RESET} ''${C_BORDER}│''${C_RESET}\n" "$name" "$desc"
                    fi
                done

                printf "''${C_BORDER}  │''${C_RESET}                                                             ''${C_BORDER}│''${C_RESET}\n"
                printf "''${C_BORDER}  ├─────────────────────────────────────────────────────────────┤''${C_RESET}\n"
                printf "''${C_BORDER}  │''${C_RESET}  ''${C_DIM}[j/k or ↑/↓] Move   [l, → or Enter] Search   [q] Quit''${C_RESET}       ''${C_BORDER}│''${C_RESET}\n"
                printf "''${C_BORDER}  └─────────────────────────────────────────────────────────────┘''${C_RESET}\n"
            }
        }

        fetch_packages() {
            local q="$1"
            local limit="''${2:-50}"
            nh search packages "$q" -l "$limit" -j 2>/dev/null | jq -r '
                .results[] |
                [
                    .package_attr_name,
                    (.package_pversion // "-"),
                    ((.package_description // "") | gsub("\n"; " ") | gsub("\t"; " ")),
                    ((.package_homepage // []) | join(", ")),
                    (.package_license_set // [] | join(", ")),
                    (.package_mainProgram // "-"),
                    (.package_position // "-"),
                    "pkg"
                ] | @tsv
            ' 2>/dev/null || true
        }

        fetch_options() {
            local q="$1"
            local limit="''${2:-50}"
            nh search options "$q" -l "$limit" -j 2>/dev/null | jq -r '
                .results[] |
                [
                    .option_name,
                    (.option_type // "-"),
                    ((.option_description // "") | gsub("<[^>]*>"; "") | gsub("\n"; " ") | gsub("\t"; " ")),
                    (.option_default // "-"),
                    (.option_source // "-"),
                    "-",
                    "-",
                    "opt"
                ] | @tsv
            ' 2>/dev/null || true
        }

        run_search_flow() {
            local idx="$1"
            local source_name="''${SOURCES[$idx]}"

            tput cnorm 2>/dev/null || true
            clear
            printf "\n"
            printf "  \033[1;36m❄ Source:\033[0m \033[1m%s\033[0m\n\n" "$source_name"
            printf "  \033[38;2;140;140;160mEnter search query (or leave empty to go back):\033[0m "
            read -r -e query

            if [ -z "''${query:-}" ]; then
                tput civis 2>/dev/null || true
                return 0
            fi

            printf "\n  \033[38;2;120;180;240m⏳ Querying %s for '%s'...\033[0m\n" "$source_name" "$query"

            local raw_data=""
            case "$source_name" in
                "MyNixOS")
                    raw_data="$(fetch_packages "$query" 25)"$'\n'"$(fetch_options "$query" 25)"
                    ;;
                "NixOS packages")
                    raw_data="$(fetch_packages "$query" 50)"
                    ;;
                "NixOS options")
                    raw_data="$(fetch_options "$query" 50)"
                    ;;
            esac

            raw_data="$(echo "$raw_data" | grep -v '^[[:space:]]*$' || true)"

            if [ -z "$raw_data" ]; then
                printf "\n  \033[1;31m✖ No results found for '%s'.\033[0m\n" "$query"
                printf "  \033[38;2;140;140;160mPress any key to return to menu...\033[0m"
                read -rn1
                tput civis 2>/dev/null || true
                return 0
            fi

            local self_bin="''${BASH_SOURCE[0]}"

            # shellcheck disable=SC2016
            local fzf_selection
            fzf_selection=$(echo "$raw_data" | fzf \
                --ansi \
                --delimiter='\t' \
                --with-nth='1,2,3' \
                --prompt="$source_name > " \
                --header="[Enter] Copy Name | [Ctrl-Y] Copy Snippet | [Ctrl-O] Open Web | [Esc] Back" \
                --expect="ctrl-y,ctrl-o" \
                --preview="\"$self_bin\" --preview {}" \
                --preview-window="right:52%:wrap" \
                --bind="left:abort" \
                --layout=reverse \
                --height=100%) || {
                tput civis 2>/dev/null || true
                return 0 # User pressed Esc or left arrow, return to menu
            }

            local key
            local selected_line
            key=$(echo "$fzf_selection" | head -n 1)
            selected_line=$(echo "$fzf_selection" | tail -n +2)

            [ -z "$selected_line" ] && return 0

            local name="" version="" desc="" extra1="" extra2="" extra3="" extra4="" item_type=""
            IFS=$'\t' read -r name version desc extra1 extra2 extra3 extra4 item_type <<< "$selected_line"

            clear
            case "$key" in
                ctrl-o)
                    local web_url=""
                    local enc_name
                    enc_name=$(jq -rn --arg x "$name" '$x|@uri')
                    if [ "$source_name" = "MyNixOS" ]; then
                        web_url="https://mynixos.com/search?q=$enc_name"
                    elif [ "$item_type" = "pkg" ]; then
                        web_url="https://search.nixos.org/packages?channel=unstable&query=$enc_name"
                    else
                        web_url="https://search.nixos.org/options?channel=unstable&query=$enc_name"
                    fi
                    printf "\n\033[1;36m🌐 Opening web page:\033[0m %s\n" "$web_url"
                    xdg-open "$web_url" >/dev/null 2>&1 &
                    sleep 0.5
                    ;;
                ctrl-y)
                    if [ "$item_type" = "pkg" ]; then
                        printf "pkgs.%s" "$name" | wl-copy
                        printf "\n\033[1;32m✔ Copied 'pkgs.%s' to clipboard!\033[0m\n\n" "$name"
                    else
                        printf "%s = " "$name" | wl-copy
                        printf "\n\033[1;32m✔ Copied '%s = ' to clipboard!\033[0m\n\n" "$name"
                    fi
                    sleep 1.2
                    ;;
                *)
                    printf "%s" "$name" | wl-copy
                    printf "\n\033[1;32m✔ Copied '%s' to clipboard!\033[0m\n\n" "$name"
                    sleep 1.2
                    ;;
            esac

            exit 0
        }

        tput civis 2>/dev/null || true
        selected=0
        num_sources=''${#SOURCES[@]}

        while true; do
            render_menu "$selected"
            key=$(read_key) || break

            case "$key" in
                k|$'\x1b[A') # Up (Vim or arrow)
                    selected=$(( (selected - 1 + num_sources) % num_sources ))
                    ;;
                j|$'\x1b[B') # Down (Vim or arrow)
                    selected=$(( (selected + 1) % num_sources ))
                    ;;
                l|$'\x1b[C'|"") # Right (Vim/arrow) or Enter
                    run_search_flow "$selected"
                    ;;
                q|$'\x1b') # Quit
                    clear
                    exit 0
                    ;;
            esac
        done
      '';
    };
  in {
    home.packages = [
      nixSearch
      (pkgs.writeShellScriptBin "ns" ''exec nix-search "$@"'')
    ];

    xdg.desktopEntries.nix-search = {
      name = "Nix Search";
      genericName = "NixOS Package & Option Search";
      comment = "Search MyNixOS, NixOS Packages, and NixOS Options with fuzzy find";
      exec = "ghostty --class=nix-search -e nix-search";
      icon = "system-search";
      categories = [ "Utility" "Development" ];
      terminal = false;
    };
  };
}
