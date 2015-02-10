import corebuild.path
import os.path
import subprocess

love_path = corebuild.path.get_love_executable()
folder = os.path.dirname(__file__)

subprocess.call([love_path, '--console', folder])
