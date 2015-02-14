import corebuild.path
import os
import os.path
import fnmatch
import zipfile
import shutil

love_path = corebuild.path.get_love_executable()
folder = os.path.dirname(__file__)
if folder == '':
	folder = '.'

file_formats = ['*.lua', '*.png', '*.ogg', '*.ttf']
matches = []

for root, dirs, files in os.walk(folder):
	for file_format in file_formats:
		for filename in fnmatch.filter(files, file_format):
			actual_path = os.path.join(root, filename)
			effective_path = actual_path[len(folder) + 1:] # Crop the initial "./"
			matches.append((actual_path, effective_path))

bin_directory = os.path.join(folder, 'bin')

if not os.path.exists(bin_directory):
	os.makedirs(bin_directory)

packaged_game = os.path.join(bin_directory, 'game.love')
with zipfile.ZipFile(packaged_game, 'w') as myzip:
	for actual_path, effective_path in matches:
		with open(actual_path, 'rb') as file:
			file_content = file.read()
		myzip.writestr(effective_path, file_content)

game_executable = os.path.join(bin_directory, 'game.exe')
shutil.copyfile(love_path, game_executable)
with open(packaged_game, 'rb') as packaged_file:
	with open(game_executable, 'ab') as output_file:
		output_file.write(packaged_file.read())

for extra_file_name, extra_file_path in corebuild.path.get_auxiliary_files():
	shutil.copyfile(extra_file_path, os.path.join(bin_directory, extra_file_name))
