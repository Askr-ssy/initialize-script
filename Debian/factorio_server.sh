#/bin/bash

wget -c https://factorio.com/get-download/stable/headless/linux64 -O factorio_headless_x64.tar.xz

tar -xvJf factorio_headless_x64.tar.xz
rm -rf factorio_headless_x64.tar.xz
mv factorio /opt/factorio
cd /opt/factorio
mkdir saves
mkdir maps
python3 -c "
import json
with open('./data/server-settings.example.json', 'r', encoding='utf-8') as example:
    config = json.load(example)

config['name'] = 'HTF'
config['description'] = 'Happy Tree Friend'
config['max_players'] = 100
config['visibility']['public'] = False
config['game_password'] = '3933030'
config['require_user_verification'] = False
config['ignore_player_limit_for_returning_players'] = True
config['autosave_interval'] = 10
config['autosave_slots'] = 6
config['auto_pause'] = False

with open('./data/server-settings.json', 'w', encoding='utf-8') as file:
    json.dump(config, file)
"
./bin/x64/factorio --create ./maps/map1.zip

nohup /opt/factorio/bin/x64/factorio \
    --config /opt/factorio/config/config.ini \
    --port 39342 --start-server /opt/factorio/maps/test1.zip \
    --server-settings /opt/factorio/data/server-settings.json \
    >/dev/null 2>&1 &

# TODO 服务化