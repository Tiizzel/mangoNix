{
  flake.aspects.base.nixos = { pkgs, ... }:
    let
      createWebapp = pkgs.writeShellApplication {
        name = "create-webapp";
        runtimeInputs = with pkgs; [
          curl
          coreutils
          gnused
          gnugrep
          gawk
          xdg-utils
          desktop-file-utils
          imagemagick
        ];
        text = ''
          APPS_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/applications"
          ICONS_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/icons/webapps"
          HICOLOR_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/128x128/apps"
          DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/webapps"
          BIN_DIR="''${XDG_BIN_HOME:-$HOME/.local/bin}"

          mkdir -p "$APPS_DIR" "$ICONS_DIR" "$HICOLOR_DIR" "$DATA_DIR" "$BIN_DIR"

          slugify() {
            echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g'
          }

          notify_desktop_environment() {
            touch "$APPS_DIR"
            update-desktop-database "$APPS_DIR" 2>/dev/null || true
            gtk-update-icon-cache -q -f -t "''${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor" 2>/dev/null || true

            # If Noctalia shell is running, notify it so it immediately picks up changes
            if command -v noctalia >/dev/null 2>&1; then
              noctalia msg config-reload 2>/dev/null || true
              noctalia msg dock-reload 2>/dev/null || true
            fi
          }

          fetch_icon() {
            local url="$1"
            local output_path="$2"
            local domain
            domain=$(echo "$url" | awk -F/ '{print $3}' | cut -d: -f1)

            # 1. Try Google Favicon V2 service (high-resolution up to 128x128)
            local google_url="https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=''${url}&size=128"
            if curl -sSL -f -m 6 "$google_url" -o "$output_path.tmp"; then
              if [ -s "$output_path.tmp" ]; then
                magick "$output_path.tmp" -resize 128x128 "$output_path" 2>/dev/null && rm -f "$output_path.tmp" && return 0
                mv "$output_path.tmp" "$output_path"
                return 0
              fi
            fi

            # 2. Try DuckDuckGo icon service
            local ddg_url="https://icons.duckduckgo.com/ip3/''${domain}.ico"
            if curl -sSL -f -m 6 "$ddg_url" -o "$output_path.tmp"; then
              if [ -s "$output_path.tmp" ]; then
                magick "$output_path.tmp" -resize 128x128 "$output_path" 2>/dev/null && rm -f "$output_path.tmp" && return 0
                mv "$output_path.tmp" "$output_path"
                return 0
              fi
            fi

            rm -f "$output_path.tmp"
            return 1
          }

          get_browser_cmd() {
            local desktop_app=""
            if command -v xdg-settings >/dev/null 2>&1; then
              desktop_app=$(xdg-settings get default-web-browser 2>/dev/null || true)
            fi
            if [ -z "$desktop_app" ] && command -v xdg-mime >/dev/null 2>&1; then
              desktop_app=$(xdg-mime query default x-scheme-handler/https 2>/dev/null || true)
            fi

            local detected=""
            case "$desktop_app" in
              zen-beta*|*zen*beta*) detected="zen-beta" ;;
              zen*) detected="zen" ;;
              firefox*) detected="firefox" ;;
              brave*) detected="brave" ;;
              google-chrome*) detected="google-chrome-stable" ;;
              chromium*) detected="chromium" ;;
            esac

            if [ -n "$detected" ] && command -v "$detected" >/dev/null 2>&1; then
              echo "$detected"
              return 0
            fi

            # Fallback priority: zen-beta -> zen -> firefox
            if command -v zen-beta >/dev/null 2>&1; then
              echo "zen-beta"
            elif command -v zen >/dev/null 2>&1; then
              echo "zen"
            elif command -v firefox >/dev/null 2>&1; then
              echo "firefox"
            else
              echo "firefox"
            fi
          }

          get_browser_icon() {
            local browser="$1"
            case "$browser" in
              zen*) echo "zen-browser" ;;
              firefox*) echo "firefox" ;;
              brave*) echo "brave-browser" ;;
              google-chrome*) echo "google-chrome" ;;
              chromium*) echo "chromium" ;;
              *) echo "web-browser" ;;
            esac
          }

          build_exec_command() {
            local browser="$1"
            local isolated="$2"
            local slug="$3"
            local url="$4"

            case "$browser" in
              zen*|firefox*)
                if [ "$isolated" -eq 1 ]; then
                  local profile_dir="$DATA_DIR/$slug"
                  mkdir -p "$profile_dir"
                  echo "$browser --new-instance --profile \"$profile_dir\" --name webapp-$slug --class webapp-$slug --new-window \"$url\""
                else
                  echo "$browser --name webapp-$slug --class webapp-$slug --new-window \"$url\""
                fi
                ;;
              *)
                if [ "$isolated" -eq 1 ]; then
                  local profile_dir="$DATA_DIR/$slug"
                  mkdir -p "$profile_dir"
                  echo "$browser --app=\"$url\" --user-data-dir=\"$profile_dir\" --class=webapp-$slug"
                else
                  echo "$browser --app=\"$url\" --class=webapp-$slug"
                fi
                ;;
            esac
          }

          install_webapp_files() {
            local name="$1"
            local url="$2"
            local browser="$3"
            local isolated="$4"
            local icon="$5"
            local category="$6"

            local slug
            slug=$(slugify "$name")

            local desktop_file="$APPS_DIR/webapp-$slug.desktop"
            local cli_wrapper="$BIN_DIR/$slug"
            local hicolor_icon="$HICOLOR_DIR/webapp-$slug.png"

            if [ -f "$icon" ]; then
              cp -f "$icon" "$hicolor_icon" 2>/dev/null || true
            fi

            local exec_cmd
            exec_cmd=$(build_exec_command "$browser" "$isolated" "$slug" "$url")
            local exec_desktop="$exec_cmd %U"

            # Write Desktop Entry ATOMICALLY via temporary file
            local tmp_desktop="$APPS_DIR/.webapp-$slug.desktop.tmp.$$"
            cat <<DESKTOP_ENTRY > "$tmp_desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$name
GenericName=Web Application
Comment=Web Application for $url
Exec=$exec_desktop
Icon=$icon
Terminal=false
StartupNotify=true
StartupWMClass=webapp-$slug
Categories=$category
Actions=NewWindow;

[Desktop Action NewWindow]
Name=Open New Window
Exec=$exec_desktop
DESKTOP_ENTRY

            chmod 644 "$tmp_desktop"
            mv -f "$tmp_desktop" "$desktop_file"

            # Write CLI runner to ~/.local/bin/$slug atomically
            local tmp_cli="$BIN_DIR/.$slug.tmp.$$"
            cat <<RUNNER > "$tmp_cli"
#!/bin/sh
exec $exec_cmd "\$@"
RUNNER
            chmod +x "$tmp_cli"
            mv -f "$tmp_cli" "$cli_wrapper"

            notify_desktop_environment
          }

          list_webapps() {
            echo "═══════════════════════════════════════════════════════"
            echo "  Installed Web Applications"
            echo "═══════════════════════════════════════════════════════"
            local count=0
            for f in "$APPS_DIR"/webapp-*.desktop; do
              if [ -f "$f" ]; then
                count=$((count + 1))
                local name
                name=$(grep -E "^Name=" "$f" | head -n 1 | cut -d= -f2-)
                local exec_line
                exec_line=$(grep -E "^Exec=" "$f" | head -n 1 | cut -d= -f2-)
                local icon_line
                icon_line=$(grep -E "^Icon=" "$f" | head -n 1 | cut -d= -f2-)
                local comment_line
                comment_line=$(grep -E "^Comment=" "$f" | head -n 1 | cut -d= -f2-)
                local b_cmd
                b_cmd=$(echo "$exec_line" | awk '{print $1}')
                local mode="Shared profile"
                if echo "$exec_line" | grep -qE '(--profile|--user-data-dir)'; then
                  mode="Isolated profile"
                fi

                echo "[$count] $name"
                echo "    URL          : ''${comment_line#Web Application for }"
                echo "    Browser      : $b_cmd ($mode)"
                echo "    Desktop file : $f"
                echo "    Icon         : $icon_line"
                echo ""
              fi
            done
            if [ "$count" -eq 0 ]; then
              echo "  No webapps installed yet in $APPS_DIR"
            fi
            echo "═══════════════════════════════════════════════════════"
          }

          delete_webapp() {
            local target="''${1:-}"
            local desktop_file=""

            if [ -z "$target" ]; then
              local webapps=()
              for f in "$APPS_DIR"/webapp-*.desktop; do
                if [ -f "$f" ]; then
                  webapps+=("$f")
                fi
              done
              if [ "''${#webapps[@]}" -eq 0 ]; then
                echo "No webapps installed yet in $APPS_DIR"
                return 0
              fi
              echo "═══════════════════════════════════════════════════════"
              echo "  Select WebApp to Delete"
              echo "═══════════════════════════════════════════════════════"
              local idx=1
              for f in "''${webapps[@]}"; do
                local n
                n=$(grep -E "^Name=" "$f" | head -n 1 | cut -d= -f2-)
                local s
                s=$(basename "$f" .desktop | sed 's/^webapp-//')
                echo "  $idx) $n ($s)"
                idx=$((idx + 1))
              done
              read -r -p "Choose webapp to delete [1-''${#webapps[@]}]: " choice
              if echo "$choice" | grep -qE '^[0-9]+$'; then
                local sel_idx=$((choice - 1))
                if [ "$sel_idx" -ge 0 ] && [ "$sel_idx" -lt "''${#webapps[@]}" ]; then
                  desktop_file="''${webapps[$sel_idx]}"
                fi
              fi
              if [ -z "$desktop_file" ]; then
                echo "Invalid selection. Aborting." >&2
                exit 1
              fi
              local slug
              slug=$(basename "$desktop_file" .desktop | sed 's/^webapp-//')
              local name
              name=$(grep -E "^Name=" "$desktop_file" | head -n 1 | cut -d= -f2-)
              read -r -p "Are you sure you want to delete '$name'? [y/N]: " confirm
              case "$confirm" in
                [yY]|[yY][eE][sS]) ;;
                *) echo "Aborted."; return 0 ;;
              esac
            else
              local slug
              slug=$(slugify "$target")
              desktop_file="$APPS_DIR/webapp-$slug.desktop"
              if [ ! -f "$desktop_file" ]; then
                for f in "$APPS_DIR"/webapp-*.desktop; do
                  if [ -f "$f" ]; then
                    local n
                    n=$(grep -E "^Name=" "$f" | head -n 1 | cut -d= -f2-)
                    if [ "$(echo "$n" | tr '[:upper:]' '[:lower:]')" = "$(echo "$target" | tr '[:upper:]' '[:lower:]')" ]; then
                      desktop_file="$f"
                      slug=$(basename "$desktop_file" .desktop | sed 's/^webapp-//')
                      break
                    fi
                  fi
                done
              fi
            fi

            if [ -n "$desktop_file" ] && [ -f "$desktop_file" ]; then
              local icon_file="$ICONS_DIR/$slug.png"
              local hicolor_icon="$HICOLOR_DIR/webapp-$slug.png"
              local bin_file="$BIN_DIR/$slug"
              local profile_dir="$DATA_DIR/$slug"

              rm -f "$desktop_file"
              rm -f "$icon_file"
              rm -f "$hicolor_icon"
              rm -f "$bin_file"
              echo "✓ Deleted: $desktop_file"
              if [ -d "$profile_dir" ]; then
                read -r -p "Delete isolated profile data at $profile_dir? [y/N]: " del_prof
                case "$del_prof" in
                  [yY]|[yY][eE][sS])
                    rm -rf "$profile_dir"
                    echo "✓ Deleted profile data: $profile_dir"
                    ;;
                esac
              fi
              notify_desktop_environment
              echo "✓ WebApp removed successfully."
            else
              echo "Error: No webapp found matching '$target'" >&2
              exit 1
            fi
          }

          edit_webapp() {
            local target="''${1:-}"
            local desktop_file=""

            local webapps=()
            for f in "$APPS_DIR"/webapp-*.desktop; do
              if [ -f "$f" ]; then
                webapps+=("$f")
              fi
            done

            if [ "''${#webapps[@]}" -eq 0 ]; then
              echo "No webapps installed yet in $APPS_DIR" >&2
              return 1
            fi

            if [ -n "$target" ]; then
              local target_slug
              target_slug=$(slugify "$target")
              if [ -f "$APPS_DIR/webapp-$target_slug.desktop" ]; then
                desktop_file="$APPS_DIR/webapp-$target_slug.desktop"
              else
                for f in "''${webapps[@]}"; do
                  local n
                  n=$(grep -E "^Name=" "$f" | head -n 1 | cut -d= -f2-)
                  if [ "$(echo "$n" | tr '[:upper:]' '[:lower:]')" = "$(echo "$target" | tr '[:upper:]' '[:lower:]')" ]; then
                    desktop_file="$f"
                    break
                  fi
                done
              fi
              if [ -z "$desktop_file" ]; then
                echo "No webapp found matching '$target'."
              fi
            fi

            if [ -z "$desktop_file" ]; then
              echo "═══════════════════════════════════════════════════════"
              echo "  Select WebApp to Edit"
              echo "═══════════════════════════════════════════════════════"
              local idx=1
              for f in "''${webapps[@]}"; do
                local n
                n=$(grep -E "^Name=" "$f" | head -n 1 | cut -d= -f2-)
                local s
                s=$(basename "$f" .desktop | sed 's/^webapp-//')
                echo "  $idx) $n ($s)"
                idx=$((idx + 1))
              done
              read -r -p "Choose webapp to edit [1-''${#webapps[@]}]: " choice
              if echo "$choice" | grep -qE '^[0-9]+$'; then
                local sel_idx=$((choice - 1))
                if [ "$sel_idx" -ge 0 ] && [ "$sel_idx" -lt "''${#webapps[@]}" ]; then
                  desktop_file="''${webapps[$sel_idx]}"
                fi
              fi
            fi

            if [ -z "$desktop_file" ] || [ ! -f "$desktop_file" ]; then
              echo "Invalid selection. Aborting." >&2
              exit 1
            fi

            local orig_slug
            orig_slug=$(basename "$desktop_file" .desktop | sed 's/^webapp-//')

            local orig_name
            orig_name=$(grep -E "^Name=" "$desktop_file" | head -n 1 | cut -d= -f2-)

            local orig_url
            orig_url=$(grep -E "^Comment=" "$desktop_file" | head -n 1 | sed -E 's/^Comment=Web Application for //')
            if [ -z "$orig_url" ] || [ "$orig_url" = "$orig_name" ]; then
              orig_url=$(grep -E "^Exec=" "$desktop_file" | head -n 1 | grep -oE 'https?://[^ "]+' || true)
            fi

            local orig_exec
            orig_exec=$(grep -E "^Exec=" "$desktop_file" | head -n 1 | cut -d= -f2-)

            local orig_browser
            orig_browser=$(echo "$orig_exec" | awk '{print $1}')

            local orig_isolated=0
            if echo "$orig_exec" | grep -qE '(--profile|--user-data-dir)'; then
              orig_isolated=1
            fi

            local orig_icon
            orig_icon=$(grep -E "^Icon=" "$desktop_file" | head -n 1 | cut -d= -f2-)

            local orig_category
            orig_category=$(grep -E "^Categories=" "$desktop_file" | head -n 1 | cut -d= -f2-)
            [ -z "$orig_category" ] && orig_category="Network;WebBrowser;"

            local is_flags_edit=0
            if [ -n "''${NAME:-}" ] || [ -n "''${URL:-}" ] || [ -n "''${BROWSER:-}" ] || [ -n "''${FLAG_ISOLATED:-}" ] || [ -n "''${ICON:-}" ]; then
              is_flags_edit=1
            fi

            local new_name="$orig_name"
            local new_url="$orig_url"
            local new_browser="$orig_browser"
            local new_isolated="$orig_isolated"
            local new_icon="$orig_icon"
            local new_category="$orig_category"

            if [ "$is_flags_edit" -eq 1 ]; then
              [ -n "''${NAME:-}" ] && new_name="$NAME"
              [ -n "''${URL:-}" ] && new_url="$URL"
              [ -n "''${BROWSER:-}" ] && new_browser="$BROWSER"
              [ -n "''${FLAG_ISOLATED:-}" ] && new_isolated="$FLAG_ISOLATED"
              [ -n "''${ICON:-}" ] && new_icon="$ICON"
            else
              local mode_str="Shared Profile (keeps you logged in)"
              if [ "$orig_isolated" -eq 1 ]; then
                mode_str="Isolated Profile (separate session & cookies)"
              fi

              echo ""
              echo "═══════════════════════════════════════════════════════"
              echo "  Editing WebApp: $orig_name"
              echo "═══════════════════════════════════════════════════════"
              echo "Current configuration:"
              echo "  • Name     : $orig_name"
              echo "  • URL      : $orig_url"
              echo "  • Browser  : $orig_browser"
              echo "  • Profile  : $mode_str"
              echo "  • Icon     : $orig_icon"
              echo "═══════════════════════════════════════════════════════"
              echo "(Press [Enter] on any prompt to keep current setting)"
              echo ""

              # 1. Browser
              echo "Browser Selection (current: $orig_browser):"
              local browsers=()
              browsers+=("$orig_browser")
              for b in zen-beta zen firefox brave chromium google-chrome-stable google-chrome; do
                if [ "$b" != "$orig_browser" ] && command -v "$b" >/dev/null 2>&1; then
                  browsers+=("$b")
                fi
              done
              for i in "''${!browsers[@]}"; do
                local b_item="''${browsers[$i]}"
                if [ "$b_item" = "$orig_browser" ]; then
                  echo "  $((i + 1))) $b_item (current)"
                else
                  echo "  $((i + 1))) $b_item"
                fi
              done
              read -r -p "Choose browser [1-''${#browsers[@]} or command, Enter to keep]: " user_b
              if [ -n "$user_b" ]; then
                if echo "$user_b" | grep -qE '^[0-9]+$'; then
                  local choice_idx=$((user_b - 1))
                  if [ "$choice_idx" -ge 0 ] && [ "$choice_idx" -lt "''${#browsers[@]}" ]; then
                    new_browser="''${browsers[$choice_idx]}"
                  else
                    new_browser="$user_b"
                  fi
                else
                  new_browser="$user_b"
                fi
              fi

              # 2. Profile Mode
              echo ""
              echo "Profile & Session Mode:"
              echo "  1) Shared Profile   - Keeps you logged in (shares main browser profile)"
              echo "  2) Isolated Profile - Sandboxed cookies & session (isolated profile)"
              read -r -p "Choose profile mode [1-2, Enter to keep current]: " user_m
              if [ "$user_m" = "1" ]; then
                new_isolated=0
              elif [ "$user_m" = "2" ]; then
                new_isolated=1
              fi

              # 3. Name
              echo ""
              read -r -p "Application Name [Enter to keep '$orig_name']: " user_name
              [ -n "$user_name" ] && new_name="$user_name"

              # 4. URL
              echo ""
              read -r -p "Application URL [Enter to keep '$orig_url']: " user_url
              [ -n "$user_url" ] && new_url="$user_url"

              # 5. Icon
              echo ""
              echo "Icon Options (current: $orig_icon):"
              echo "  1) Keep current icon"
              echo "  2) Re-fetch high-res icon automatically from $new_url"
              echo "  3) Provide custom image URL or local file path"
              read -r -p "Choose icon option [1-3, default: 1]: " icon_opt
              case "$icon_opt" in
                2)
                  local tmp_slug
                  tmp_slug=$(slugify "$new_name")
                  local tmp_icon="$ICONS_DIR/$tmp_slug.png"
                  echo "Auto-detecting website icon from $new_url..."
                  if fetch_icon "$new_url" "$tmp_icon"; then
                    echo "✓ Successfully downloaded new icon."
                    new_icon="$tmp_icon"
                  else
                    echo "Notice: Could not fetch icon. Keeping current icon."
                  fi
                  ;;
                3)
                  read -r -p "Enter icon URL or local file path: " user_icon_path
                  if [ -n "$user_icon_path" ]; then
                    local custom_slug
                    custom_slug=$(slugify "$new_name")
                    local custom_icon="$ICONS_DIR/$custom_slug.png"
                    if echo "$user_icon_path" | grep -qE '^https?://'; then
                      if curl -sSL -f -m 10 "$user_icon_path" -o "$custom_icon.tmp"; then
                        magick "$custom_icon.tmp" -resize 128x128 "$custom_icon" 2>/dev/null || mv "$custom_icon.tmp" "$custom_icon"
                        rm -f "$custom_icon.tmp"
                        new_icon="$custom_icon"
                      fi
                    elif [ -f "$user_icon_path" ]; then
                      magick "$user_icon_path" -resize 128x128 "$custom_icon" 2>/dev/null || cp "$user_icon_path" "$custom_icon"
                      new_icon="$custom_icon"
                    fi
                  fi
                  ;;
              esac
            fi

            # Ensure URL has protocol
            if ! echo "$new_url" | grep -qE '^https?://'; then
              new_url="https://$new_url"
            fi

            local new_slug
            new_slug=$(slugify "$new_name")

            # If slug changed, handle migration of files and profile dir
            if [ "$new_slug" != "$orig_slug" ]; then
              rm -f "$APPS_DIR/webapp-$orig_slug.desktop"
              rm -f "$BIN_DIR/$orig_slug"
              rm -f "$HICOLOR_DIR/webapp-$orig_slug.png"
              if [ "$orig_icon" = "$ICONS_DIR/$orig_slug.png" ] && [ -f "$orig_icon" ]; then
                mv -f "$orig_icon" "$ICONS_DIR/$new_slug.png"
                new_icon="$ICONS_DIR/$new_slug.png"
              fi
              if [ -d "$DATA_DIR/$orig_slug" ]; then
                mv -f "$DATA_DIR/$orig_slug" "$DATA_DIR/$new_slug"
              fi
            fi

            install_webapp_files "$new_name" "$new_url" "$new_browser" "$new_isolated" "$new_icon" "$new_category"

            echo ""
            echo "═══════════════════════════════════════════════════════"
            echo "  ✓ WebApp Successfully Updated!"
            echo "═══════════════════════════════════════════════════════"
            echo "  • Name         : $new_name"
            echo "  • URL          : $new_url"
            echo "  • Browser      : $new_browser"
            echo "  • Mode         : $([ "$new_isolated" -eq 1 ] && echo "Isolated Profile" || echo "Shared Browser Profile")"
            echo "  • Desktop File : $APPS_DIR/webapp-$new_slug.desktop"
            echo "  • Icon         : $new_icon"
            echo "═══════════════════════════════════════════════════════"
          }

          show_help() {
            cat <<EOF
Usage: create-webapp [OPTIONS]
       webapp [OPTIONS]

Create, edit, and manage standalone desktop web applications.

Actions:
  -e, --edit [name]         Edit an existing webapp (browser, URL, profile, icon)
  -l, --list                List all installed webapps
  -d, --delete [name]       Remove an installed webapp
  -h, --help                Show this help message

Creation & Modification Options:
  -n, --name <name>         Name of the application (e.g. "YouTube Music")
  -u, --url <url>           URL of the web application (e.g. "https://music.youtube.com")
  -b, --browser <bin>       Browser executable (default: auto-detected zen-beta / firefox)
  -i, --icon <path|url>     Local image path or icon URL (auto-fetched if omitted)
  -c, --category <cat>      Desktop categories (default: "Network;WebBrowser;")
  --shared                  Use default browser profile (share logins & cookies, default)
  --isolated                Use an isolated user profile (separate cookies & sessions)

Running without arguments starts the interactive wizard.
EOF
          }

          # Argument handling
          IS_CALLED_WITHOUT_ARGS=0
          if [ "$#" -eq 0 ]; then
            IS_CALLED_WITHOUT_ARGS=1
          fi

          ACTION="create"
          TARGET=""
          NAME=""
          URL=""
          ICON=""
          CATEGORY="Network;WebBrowser;"
          ISOLATED=0
          FLAG_ISOLATED=""
          BROWSER=""

          while [ "$#" -gt 0 ]; do
            case "$1" in
              -e|--edit|edit|modify)
                ACTION="edit"
                if [ "$#" -gt 1 ] && ! echo "$2" | grep -qE '^-+'; then
                  TARGET="$2"
                  shift 2
                else
                  shift 1
                fi
                ;;
              -d|--delete|delete|remove)
                ACTION="delete"
                if [ "$#" -gt 1 ] && ! echo "$2" | grep -qE '^-+'; then
                  TARGET="$2"
                  shift 2
                else
                  shift 1
                fi
                ;;
              -l|--list|list)
                ACTION="list"
                shift 1
                ;;
              -n|--name)
                NAME="$2"
                shift 2
                ;;
              -u|--url)
                URL="$2"
                shift 2
                ;;
              -i|--icon)
                ICON="$2"
                shift 2
                ;;
              -c|--category)
                CATEGORY="$2;"
                shift 2
                ;;
              --isolated)
                ISOLATED=1
                FLAG_ISOLATED=1
                shift
                ;;
              --shared)
                ISOLATED=0
                FLAG_ISOLATED=0
                shift
                ;;
              -b|--browser)
                BROWSER="$2"
                shift 2
                ;;
              -h|--help|help)
                show_help
                exit 0
                ;;
              *)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
            esac
          done

          case "$ACTION" in
            list)
              list_webapps
              exit 0
              ;;
            delete)
              delete_webapp "$TARGET"
              exit 0
              ;;
            edit)
              edit_webapp "$TARGET"
              exit 0
              ;;
            create)
              # If invoked interactively with no arguments, show manager menu if webapps exist
              if [ "$IS_CALLED_WITHOUT_ARGS" -eq 1 ] && [ -t 0 ]; then
                has_apps=0
                for f in "$APPS_DIR"/webapp-*.desktop; do
                  if [ -f "$f" ]; then
                    has_apps=1
                    break
                  fi
                done
                if [ "$has_apps" -eq 1 ]; then
                  echo "═══════════════════════════════════════════════════════"
                  echo "  🚀 WebApp Desktop Manager"
                  echo "═══════════════════════════════════════════════════════"
                  echo "  1) Create a new WebApp (default)"
                  echo "  2) Edit an existing WebApp"
                  echo "  3) List installed WebApps"
                  echo "  4) Delete a WebApp"
                  echo "═══════════════════════════════════════════════════════"
                  read -r -p "Choose an option [1-4, Enter for Create]: " top_choice
                  case "$top_choice" in
                    2) edit_webapp ""; exit 0 ;;
                    3) list_webapps; exit 0 ;;
                    4) delete_webapp ""; exit 0 ;;
                    *) ;;
                  esac
                fi
              fi
              ;;
          esac

          # Interactive wizard for Create if arguments are missing
          IS_INTERACTIVE=0
          if [ -z "$NAME" ] || [ -z "$URL" ]; then
            IS_INTERACTIVE=1
          fi

          if [ -z "$NAME" ]; then
            echo "═══════════════════════════════════════════════════════"
            echo "  🚀 WebApp Desktop Creator"
            echo "═══════════════════════════════════════════════════════"
            read -r -p "App Name (e.g. ChatGPT, YouTube): " NAME
            if [ -z "$NAME" ]; then
              echo "Error: App Name is required." >&2
              exit 1
            fi
          fi

          if [ -z "$URL" ]; then
            read -r -p "App URL (e.g. https://chatgpt.com): " URL
            if [ -z "$URL" ]; then
              echo "Error: URL is required." >&2
              exit 1
            fi
          fi

          # Ensure URL has protocol
          if ! echo "$URL" | grep -qE '^https?://'; then
            URL="https://$URL"
          fi

          DEFAULT_BROWSER=$(get_browser_cmd)

          # Allow user to choose browser interactively if not passed via flags
          if [ "$IS_INTERACTIVE" -eq 1 ] && [ -z "$BROWSER" ]; then
            echo ""
            echo "Browser selection:"
            browsers=()
            browsers+=("$DEFAULT_BROWSER")
            for b in zen-beta zen firefox brave chromium google-chrome-stable google-chrome; do
              if [ "$b" != "$DEFAULT_BROWSER" ] && command -v "$b" >/dev/null 2>&1; then
                browsers+=("$b")
              fi
            done

            for i in "''${!browsers[@]}"; do
              b="''${browsers[$i]}"
              if [ "$b" = "$DEFAULT_BROWSER" ]; then
                echo "  $((i + 1))) $b (default)"
              else
                echo "  $((i + 1))) $b"
              fi
            done
            read -r -p "Choose browser [1-''${#browsers[@]} or command] (default: $DEFAULT_BROWSER): " USER_CHOICE
            if [ -z "$USER_CHOICE" ]; then
              BROWSER="$DEFAULT_BROWSER"
            elif echo "$USER_CHOICE" | grep -qE '^[0-9]+$'; then
              choice_idx=$((USER_CHOICE - 1))
              if [ "$choice_idx" -ge 0 ] && [ "$choice_idx" -lt "''${#browsers[@]}" ]; then
                BROWSER="''${browsers[$choice_idx]}"
              else
                BROWSER="$USER_CHOICE"
              fi
            else
              BROWSER="$USER_CHOICE"
            fi
          fi

          if [ -z "$BROWSER" ]; then
            BROWSER="$DEFAULT_BROWSER"
          fi

          SLUG=$(slugify "$NAME")
          ICON_FILE="$ICONS_DIR/$SLUG.png"

          echo ""
          echo "Configuring WebApp '$NAME' ($SLUG)..."

          # Handle Icon
          FINAL_ICON=""
          if [ -n "$ICON" ]; then
            if echo "$ICON" | grep -qE '^https?://'; then
              echo "Fetching icon from URL: $ICON..."
              if curl -sSL -f -m 10 "$ICON" -o "$ICON_FILE.tmp"; then
                magick "$ICON_FILE.tmp" -resize 128x128 "$ICON_FILE" 2>/dev/null || mv "$ICON_FILE.tmp" "$ICON_FILE"
                rm -f "$ICON_FILE.tmp"
                FINAL_ICON="$ICON_FILE"
              fi
            elif [ -f "$ICON" ]; then
              echo "Using local icon: $ICON..."
              magick "$ICON" -resize 128x128 "$ICON_FILE" 2>/dev/null || cp "$ICON" "$ICON_FILE"
              FINAL_ICON="$ICON_FILE"
            fi
          fi

          if [ -z "$FINAL_ICON" ]; then
            echo "Auto-detecting website icon from $URL..."
            if fetch_icon "$URL" "$ICON_FILE"; then
              echo "✓ Successfully downloaded high-res icon."
              FINAL_ICON="$ICON_FILE"
            else
              fallback_icon=$(get_browser_icon "$BROWSER")
              echo "Notice: Could not fetch icon automatically. Using fallback browser icon ($fallback_icon)."
              FINAL_ICON="$fallback_icon"
            fi
          fi

          install_webapp_files "$NAME" "$URL" "$BROWSER" "$ISOLATED" "$FINAL_ICON" "$CATEGORY"

          echo ""
          echo "═══════════════════════════════════════════════════════"
          echo "  ✓ WebApp Successfully Created!"
          echo "═══════════════════════════════════════════════════════"
          echo "  • Name         : $NAME"
          echo "  • URL          : $URL"
          echo "  • Browser      : $BROWSER"
          echo "  • Desktop File : $APPS_DIR/webapp-$SLUG.desktop"
          echo "  • Icon         : $FINAL_ICON"
          echo "  • Mode         : $([ "$ISOLATED" -eq 1 ] && echo "Isolated Profile" || echo "Shared Browser Profile")"
          echo "═══════════════════════════════════════════════════════"
          echo "You can now launch '$NAME' from your App Launcher (Noctalia, Fuzzel, etc.)"
        '';
      };

      webappAlias = pkgs.writeScriptBin "webapp" ''
        #!${pkgs.bash}/bin/bash
        exec ${createWebapp}/bin/create-webapp "$@"
      '';
    in {
      environment.systemPackages = [
        createWebapp
        webappAlias
      ];
    };
}
