#!/bin/sh

# workspaces() {
#     # получаем список всех workspace
#     ws_json=$(hyprctl workspaces -j)
#
#     # активный workspace
#     active=$(echo "$ws_json" | jq '.[] | select(.focused == true) | .id')
#
#     # рендер кнопок (1–6)
#     echo "(box :class \"works\" :orientation \"h\" :spacing 5 :space-evenly \"false\""
#     for i in 1 2 3 4 5 6; do
#         if [ "$i" -eq "$active" ]; then
#             icon=""  # активный
#         else
#             icon=""  # неактивный
#         fi
#         echo "(button :onclick \"hyprctl dispatch workspace $i\" \"$icon\")"
#     done
#     echo ")"
# }
#
# # первый вывод
# workspaces
#
# # слушаем события из hyprland
# hyprctl -j dispatch sub workspace | while read -r _; do
#     workspaces
# done

hyprctl -j dispatch sub workspace | while read -r _; do
    ws_json=$(hyprctl workspaces -j)
    active=$(echo "$ws_json" | jq '.[] | select(.focused==true) | .id')
    
    echo "(box :orientation \"h\" :spacing 5 :space-evenly false \
          (for i in [1 2 3 4 5 6] \
            (button :onclick \"hyprctl dispatch workspace $i\" \
              :class \"${active==i ? \"active\" : \"inactive\"}\" \
              (label :text \"${active==i ? \"\" : \"\"}\"))))"
done
