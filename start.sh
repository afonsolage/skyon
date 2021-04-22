sed -i 's/network\/debug\/remote_port = [0-9]*$/network\/debug\/remote_port = 15024/g' ~/.config/godot/editor_settings-3.tres
godot -e skyon_client/project.godot&
sleep 1
sed -i 's/network\/debug\/remote_port = [0-9]*$/network\/debug\/remote_port = 15035/g' ~/.config/godot/editor_settings-3.tres
godot -e skyon_server/project.godot&
