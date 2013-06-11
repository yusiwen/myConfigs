#!/usr/bin/env python
import re
import subprocess
import i3

def swipe_right():
	ws_list = i3.get_workspaces()
	current_ws = [ws for ws in ws_list if ws['focused']][0]
	current_index = ws_list.index(current_ws)
	if current_index < (len(ws_list) -1):
		right_ws = ws_list[current_index + 1]
		i3.workspace(right_ws['name'])

def swipe_left():
	ws_list = i3.get_workspaces()
	current_ws = [ws for ws in ws_list if ws['focused']][0]
	current_index = ws_list.index(current_ws)
	if current_index > 0:
		left_ws = ws_list[current_index - 1]
		i3.workspace(left_ws['name'])

if __name__ == "__main__":
	cmd = 'synclient -m 100'

	p = subprocess.Popen(cmd, stdout = subprocess.PIPE, stderr = subprocess.STDOUT, shell = True)
	skip = False
	first = True
	start = False
	start_x = 0
	start_y = 0
	diff_x = 0
	diff_y = 0	
	try:
		while True:
			line = p.stdout.readline()
			if not line:
				break
			try:
				tokens = [x for x in re.split('([^0-9\.])+', line.strip()) if x.strip()]
				x, y, fingers = int(tokens[1]), int(tokens[2]), int(tokens[4])
				
				if fingers==3:
					if not start:
						start_x = x
						start_y = y
						start = True
				if start and not fingers==3:
					diff_x = x-start_x
					diff_y = y-start_y
					#MODIFY THE NUMBERS BELLOW FOR SENSITIVITY
					if diff_y > 900:
						if diff_x > -300 and diff_x < 300:
								#print("3 finger swipe-down")
								i3.fullscreen()
					elif diff_y < -900:
						if diff_x > -300 and diff_x < 300:
								#print("3 finger swipe-up")
								i3.fullscreen()
					elif diff_x > 900:
						if diff_y > -300 and diff_y < 300:
								#print("3 finger swipe-right")
								swipe_right()
					elif diff_x < -900:
						if diff_y > -300 and diff_y < 300:
								#print("3 finger swipe-left")
								swipe_left()
					else:
						print("3 finger down")
					start = False
					start_x = 0
					start_y = 0
					diff_y = 0
					diff_x = 0
			except (IndexError, ValueError):
				pass
	except KeyboardInterrupt:
		pass
