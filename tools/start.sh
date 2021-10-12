sed -i 's/network\/debug\/remote_port = [0-9]*$/network\/debug\/remote_port = 15024/g' ~/.config/godot/editor_settings-3.tres
sed -i 's/filesystem\/file_server\/port = [0-9]*$/filesystem\/file_server\/port = 15025/g' ~/.config/godot/editor_settings-3.tres
sed -i 's/network\/language_server\/remote_port = [0-9]*$/network\/language_server\/remote_port = 15026/g' ~/.config/godot/editor_settings-3.tres
godot -e ../client/project.godot&
sleep 3
sed -i 's/network\/debug\/remote_port = [0-9]*$/network\/debug\/remote_port = 15034/g' ~/.config/godot/editor_settings-3.tres
sed -i 's/filesystem\/file_server\/port = [0-9]*$/filesystem\/file_server\/port = 15035/g' ~/.config/godot/editor_settings-3.tres
sed -i 's/network\/language_server\/remote_port = [0-9]*$/network\/language_server\/remote_port = 15036/g' ~/.config/godot/editor_settings-3.tres
godot -e ../server/project.godot&
