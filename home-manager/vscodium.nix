{ lib, config, pkgs, inputs, ... }:
{    
  programs.vscode = {
    enable = true;
    #TODO Remove telemetry
    # package = pkgs.vscodium;
    package = pkgs.vscodium;
    profiles.default = {
      extensions =
      # with inputs.nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; 
      # with pkgs.vscode-extensions; 
      with pkgs.vscode-marketplace; 
      [
        # nix language
        # bbenoist.nix
        # nix-shell suport 

        jnoortheen.nix-ide #
        arrterian.nix-env-selector #
        mkhl.direnv

        formulahendry.code-runner
        
        # C/C++
        #TODO Replce with C/C++ extension pack
        twxs.cmake # Cmake
        # vadimcn.vscode-lldb
        # jeff-hykin.better-c-syntax
        jeff-hykin.better-cpp-syntax
        # ms-vscode.cpptools-extension-pack
        # ms-vscode.cpptools
        llvm-vs-code-extensions.vscode-clangd
        

        # Python
        magicstack.magicpython
        # ms-python.python
        # ms-python.debugpy

        # toto tree
        gruntfuggly.todo-tree

        # rust-lang.rust-analyzer
        # github.copilot
      ];
      
      userSettings = {
        "update.mode" = "none";
        "extensions.autoUpdate" = false; # This stuff fixes vscode freaking out when theres an update
        # needed otherwise vscode crashes, see https://github.com/NixOS/nixpkgs/issues/246509
        "window.titleBarStyle" = "custom"; 

        # "window.menuBarVisibility" = "toggle";
        # "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'SymbolsNerdFont', 'monospace', monospace";
        # "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font', 'SymbolsNerdFont'";
        "editor.fontSize" = lib.mkForce 16;
        
        "workbench.colorCustomizations" = {
            "[Stylix]" = {
                # "button.background" = "#${config.lib.stylix.colors.base0B}BB";
                # "button.foreground" = "#${config.lib.stylix.colors.base06}";
                # "button.secondaryBackground" = "#${config.lib.stylix.colors.base01}BB";
                # "button.secondaryForeground" = "#${config.lib.stylix.colors.base05}";
                # "editor.selectionHighlightBackground" = "#${config.lib.stylix.colors.base0E}EE";
                # "editor.wordHighlightBackground" = "#${config.lib.stylix.colors.base0A}00";
                # "scrollbarSlider.activeBackground" = "#${config.lib.stylix.colors.base04}55";
                # "scrollbarSlider.background" = "#${config.lib.stylix.colors.base03}55";
                # "scrollbarSlider.hoverBackground" = "#${config.lib.stylix.colors.base04}99";
                # "statusBar.background" = "#${config.lib.stylix.colors.base00}";
                # "statusBar.noFolderBackground" = "#${config.lib.stylix.colors.base00}";
                # "statusBar.noFolderForeground" = "#${config.lib.stylix.colors.base06}";
                # "statusBarItem.remoteBackground" = "#${config.lib.stylix.colors.base0D}";

                # "editorBracketHighlight.foreground1" = "#${config.lib.stylix.colors.base0D}";
                # "editorBracketHighlight.foreground2" = "#${config.lib.stylix.colors.base0B}";
                # "editorBracketHighlight.foreground3" = "#${config.lib.stylix.colors.base0E}";
                # "editorBracketHighlight.foreground4" = "#${config.lib.stylix.colors.base0A}";
                # "editorBracketHighlight.foreground5" = "#${config.lib.stylix.colors.base0F}";
                # "editorBracketHighlight.foreground6" = "#${config.lib.stylix.colors.base0C}";

                # "editorError.foreground" = "#${config.lib.stylix.colors.base08}";
                # "editorWarning.foreground" = "#${config.lib.stylix.colors.base0A}";
                # "editorError.border" = "#${config.lib.stylix.colors.base08}";
            };
        };


        "glassit.alpha" = 0.1;


        # Telemetry Stuff
        "github.copilot.enable" = false;


        "vsicons.dontShowNewVersionMessage" = true;
        "explorer.confirmDragAndDrop" = false;
        "editor.fontLigatures" = true;
        # "editor.minimap.enabled" = false;
        "workbench.startupEditor" = "none";

        # "editor.formatOnSave" = true;
        # "editor.formatOnType" = true;
        # "editor.formatOnPaste" = true;

        # "workbench.layoutControl.type" = "menu";
        # "workbench.editor.limit.enabled" = true;
        # "workbench.editor.limit.value" = 10;
        # "workbench.editor.limit.perEditorGroup" = true;
        # "workbench.editor.showTabs" = "single";
        "workbench.editor.showTabs" = "multiple";
        # "files.autoSave" = "onWindowChange";
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 500;
        # "explorer.openEditors.visible" = 0;
        # "breadcrumbs.enabled" = false;
        "editor.renderControlCharacters" = false;
        # "workbench.activityBar.location" = "hidden";
        # "workbench.statusBar.visible" = false;
        "workbench.sideBar.location" = "right";
        # "editor.scrollbar.verticalScrollbarSize" = 2;
        # "editor.scrollbar.horizontalScrollbarSize" = 2;
        # "editor.scrollbar.vertical" = "hidden";
        # "editor.scrollbar.horizontal" = "hidden";
        # "workbench.layoutControl.enabled" = false;

        "editor.mouseWheelZoom" = true;

        "C_Cpp.autocompleteAddParentheses" = true;
        "C_Cpp.formatting" = "vcFormat";
        "C_Cpp.vcFormat.newLine.closeBraceSameLine.emptyFunction" = true;
        "C_Cpp.vcFormat.newLine.closeBraceSameLine.emptyType" = true;
        "C_Cpp.vcFormat.space.beforeEmptySquareBrackets" = true;
        "C_Cpp.vcFormat.newLine.beforeOpenBrace.block" = "sameLine";
        "C_Cpp.vcFormat.newLine.beforeOpenBrace.function" = "sameLine";
        "C_Cpp.vcFormat.newLine.beforeElse" = false;
        "C_Cpp.vcFormat.newLine.beforeCatch" = false;
        "C_Cpp.vcFormat.newLine.beforeOpenBrace.type" = "sameLine";
        "C_Cpp.vcFormat.space.betweenEmptyBraces" = true;
        "C_Cpp.vcFormat.space.betweenEmptyLambdaBrackets" = true;
        "C_Cpp.vcFormat.indent.caseLabels" = true;
        "C_Cpp.intelliSenseCacheSize" = 2048;
        "C_Cpp.intelliSenseMemoryLimit" = 2048;
        "C_Cpp.default.browse.path" = [
          ''''${workspaceFolder}/**''
        ];
        "C_Cpp.default.cStandard" = "gnu11";
        "C_Cpp.inlayHints.parameterNames.hideLeadingUnderscores" = false;
        "C_Cpp.intelliSenseUpdateDelay" = 500;
        "C_Cpp.workspaceParsingPriority" = "medium";
        "C_Cpp.clang_format_sortIncludes" = true;
        "C_Cpp.doxygen.generatedStyle" = "/**";

        "editor.tokenColorCustomizations" = lib.mkForce {
          "[Stylix]" = {
            textMateRules = [
              {
                scope = [
                  "punctuation.section.embedded"
                  "variable.interpolation"
                ];
                settings = {
                  foreground = "#${config.lib.stylix.colors.base09}";
                };
              }
              {
                scope = [
                    "variable.parameter"

                    # Other related scopes inside the expression:
                    "entity.other.attribute-name.nix"
                    "punctuation.accessor.nix"

                    # The interpolation punctuation itself:
                    "punctuation.section.embedded.nix"
                ];
                settings = {
                    foreground = "#${config.lib.stylix.colors.base09}";
                };
            }
            ];
          };
        };

      };
      
      # Keybindings
      keybindings = [
        {
          key = "ctrl+q";
          command = "editor.action.commentLine";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "ctrl+s";
          # command = "workbench.action.files.saveFiles"; # Save all
          command = "workbench.action.files.save"; # Save current file
        }
      ];
    };
  };
}