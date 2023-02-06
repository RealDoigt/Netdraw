namespace netdraw

import System
import ConsolePaint
import ConsolePaint.Painting
import ConsolePaint.RectanglePainting

static partial class Editor:
	
	final DIFFERENCE_X = 1
	final DIFFERENCE_Y = 3
	
	private def CycleThroughEnumOptions(currentValue as int, enumMax as int, shiftKey as bool):
		
		if shiftKey:
					
			if currentValue == 0:
				currentValue = enumMax
				
			else:
				--currentValue
				
		else:
			
			if currentValue == enumMax:
				currentValue = 0
				
			else:
				++currentValue
				
		return currentValue
		
	private def PrintEditInfo():
		
		# resets to prevent colour contamination from the editing
		Console.ResetColor()
		
		# clear previous trash
		Console.SetCursorPosition(1, 1)
		Console.Write(" " * (Console.WindowWidth - 2))
		
		Console.SetCursorPosition(1, 1)
		Console.Write("X: $x")
		
		# Adjust position to x's max size
		Console.CursorLeft = 8
		Console.Write("Y: $y")
		
		# Adjust Position to y's max size
		Console.CursorLeft = 15
		Console.Write("DM: $currentDrawMode CM: $currentColorMode BG: $(currentPixel.background) FG: $(currentPixel.foreground)")
		Console.Write(" T: $(currentPixel.texture) Help: H")

	private def Edit():
		
		Console.Clear()
		Console.CursorVisible = true
		
		# making sure the cursor is at the right place to print
		Console.SetCursorPosition(1, 2)
		currentPicture.Print()
		
		# Edit Info Border
		DrawRectangle (
		
			BorderType.Single,
			0, # x
			0, # y
			3, # height
			Console.WindowWidth cast byte,
			BORDER_COLOR
		)
		
		# Picture Border
		DrawRectangle (
			
			BorderType.Single,
			0, # x 
			2, # y
			(currentPicture.Height + 2) cast byte, 
			(currentPicture.Width + 2) cast byte, 
			BORDER_COLOR
		)
		
		# Intersects
		brush = char('├')
		DrawCell(0, 2, BORDER_COLOR)
		
		if currentPicture.Width + 1 < Console.WindowWidth:
			brush = char('┬')
			
		else:
			brush = char('┤')
			
		DrawCell((currentPicture.Width + 1) cast byte, 2, BORDER_COLOR)
		
		# reset brush to initial value
		brush = char('\'')
		
		# init internal coordinates
		x = 0
		y = 0
		
		while currentScreen == Screens.Edit:
			
			PrintEditInfo()
			Console.SetCursorPosition(x + DIFFERENCE_X, y + DIFFERENCE_Y)
			
			info = Console.ReadKey(true)
			
			# Cursor movement
			if info.Key == ConsoleKey.UpArrow and y - 1 >= 0:
				
				--Console.CursorTop
				--y
				
			elif info.Key == ConsoleKey.DownArrow and y + 1 < currentPicture.Height:
				
				++Console.CursorTop
				++y
				
			elif info.Key == ConsoleKey.LeftArrow and x - 1 >= 0:
				
				--Console.CursorLeft
				--x
				
			elif info.Key == ConsoleKey.RightArrow and x + 1 < currentPicture.Width:
				
				++Console.CursorLeft
				++x
			
			# Shortcuts with function keys
			elif info.Key == ConsoleKey.F1:
				
				currentDrawMode = CycleThroughEnumOptions (
					
					currentDrawMode, 
					DrawModes.PickColors, 
					info.Modifiers & ConsoleModifiers.Shift != 0
				)
					
			elif info.Key == ConsoleKey.F2:
				
				currentColorMode = CycleThroughEnumOptions (
				
					currentColorMode, 
					ColorModes.NoTextureBack, 
					info.Modifiers & ConsoleModifiers.Shift != 0
				)
					
			elif info.Key == ConsoleKey.F3:
				ChangeColorCycle(true, 0)
				
			elif info.Key == ConsoleKey.F4:
				ChangeColorCycle(true, ConsoleModifiers.Control)
			
			elif info.Key == ConsoleKey.F5:
				currentDrawMode = DrawModes.Type
			
			elif info.Key == ConsoleKey.F7:
				currentScreen = Screens.Pick
			
			elif currentDrawMode != DrawModes.Type:			
				
				# TODO: other fill area
				if info.Key == ConsoleKey.Spacebar:
					
					if currentDrawMode == DrawModes.Draw:
						Draw()
						
					elif currentDrawMode == DrawModes.PickFull:
						currentPixel = currentPicture[x, y]
						
					elif currentDrawMode == DrawModes.PickChar:
						currentPixel.texture = currentPicture[x, y].texture
					
					elif currentDrawMode == DrawModes.PickFore:
						currentPixel.foreground = currentPicture[x, y].foreground
					
					elif currentDrawMode == DrawModes.PickBack:
						currentPixel.background = currentPicture[x, y].background
						
					elif currentDrawMode == DrawModes.PickColors:
						
						currentPixel.background = currentPicture[x, y].background
						currentPixel.foreground = currentPicture[x, y].foreground
						
				elif info.Key == ConsoleKey.S:
					currentScreen = Screens.Save
				
				elif info.Key == ConsoleKey.Q:
					currentScreen = Screens.Menu
				
				elif info.Key == ConsoleKey.H:
					currentScreen = Screens.Help
					
				elif info.Key == ConsoleKey.F:
					Fill()
					
				elif info.Key == ConsoleKey.C:
					
					secondKey = Console.ReadKey(true).Key
					
					if secondKey == ConsoleKey.UpArrow:
						ChangeColorCycle(true, info.Modifiers)
						
					elif secondKey == ConsoleKey.DownArrow:
						ChangeColorCycle(false, info.Modifiers)
					
					# these are in order of their internal enum value
					elif secondKey == ConsoleKey.D0:
						ChangeColor(ConsoleColor.Black, info.Modifiers)
						
					elif secondKey == ConsoleKey.D1:
						ChangeColor(ConsoleColor.DarkBlue, info.Modifiers)
						
					elif secondKey == ConsoleKey.D2:
						ChangeColor(ConsoleColor.DarkGreen, info.Modifiers)
						
					elif secondKey == ConsoleKey.D3:
						ChangeColor(ConsoleColor.DarkCyan, info.Modifiers)
						
					elif secondKey == ConsoleKey.D4:
						ChangeColor(ConsoleColor.DarkRed, info.Modifiers)
						
					elif secondKey == ConsoleKey.D5:
						ChangeColor(ConsoleColor.DarkMagenta, info.Modifiers)
						
					elif secondKey == ConsoleKey.D6:
						ChangeColor(ConsoleColor.DarkYellow, info.Modifiers) 
						
					elif secondKey == ConsoleKey.D7:
						ChangeColor(ConsoleColor.Gray, info.Modifiers)
						
					elif secondKey == ConsoleKey.D8:
						ChangeColor(ConsoleColor.DarkGray, info.Modifiers)
						
					elif secondKey == ConsoleKey.D9:
						ChangeColor(ConsoleColor.Blue, info.Modifiers)
						
					elif secondKey == ConsoleKey.A:
						ChangeColor(ConsoleColor.Green, info.Modifiers)
						
					elif secondKey == ConsoleKey.B:
						ChangeColor(ConsoleColor.Cyan, info.Modifiers)
						
					elif secondKey == ConsoleKey.C:
						ChangeColor(ConsoleColor.Red, info.Modifiers)
						
					elif secondKey == ConsoleKey.D:
						ChangeColor(ConsoleColor.Magenta, info.Modifiers)
						
					elif secondKey == ConsoleKey.E:
						ChangeColor(ConsoleColor.Yellow, info.Modifiers)
						
					elif secondKey == ConsoleKey.F:
						ChangeColor(ConsoleColor.White, info.Modifiers)
			
			elif currentDrawMode == DrawModes.Type:
				
				currentPixel.texture = info.KeyChar
				Draw()
				++x
				
				if x == currentPicture.Width:
					
					x = 0
					
					++Console.CursorTop
					++y
					
					if y == currentPicture.Height:
						
						Console.CursorTop = DIFFERENCE_Y
						y = 0

	private def ChangeColor(color as ConsoleColor, modifiers as ConsoleModifiers):
		
		if modifiers & ConsoleModifiers.Control != 0:
			currentPixel.background = color
			
		else:
			currentPixel.foreground = color
	
	# true -> cycle down
	# false -> cycle up
	private def ChangeColorCycle(direction as bool, modifiers as ConsoleModifiers):
		
		currentColor = currentPixel.foreground
						
		if modifiers & ConsoleModifiers.Control != 0:
			currentColor = currentPixel.background
		
		ChangeColor (
		
			CycleThroughEnumOptions (
			
				currentColor, 
				ConsoleColor.White,
				direction
			),
			
			modifiers
		)
	
	/*
		Fills everything according to drawmode, not the kind of fill which
	    fills every cell where there isn't a collision with another color
	*/
	private def Fill():
		
		Console.SetCursorPosition(DIFFERENCE_X, DIFFERENCE_Y)
					
		for line in range(currentPicture.Width):
			
			y = line
			Console.CursorTop = y + DIFFERENCE_Y
			
			for column in range(currentPicture.Height):
				
				x = column
				Console.CursorLeft = x + DIFFERENCE_X
				
				Draw()
		
	private def Draw():
		
		originalPixel = currentPicture[x, y]
		texture = currentPixel.texture
		
		Console.BackgroundColor = currentPixel.background
		Console.ForegroundColor = currentPixel.foreground
			
		if currentColorMode == ColorModes.Fore:
			Console.BackgroundColor = originalPixel.background
			
		elif currentColorMode == ColorModes.Back:
			Console.ForegroundColor = originalPixel.foreground
			
		elif currentColorMode == ColorModes.None:
			
			Console.BackgroundColor = originalPixel.background
			Console.ForegroundColor = originalPixel.foreground
			
		elif currentColorMode == ColorModes.NoTexture:
			texture = originalPixel.texture
			
		elif currentColorMode == ColorModes.NoTextureFore:
			
			Console.BackgroundColor = originalPixel.background
			texture = originalPixel.texture
			
		elif currentColorMode == ColorModes.NoTextureBack:
			
			Console.ForegroundColor = originalPixel.foreground
			texture = originalPixel.texture
			
		currentPicture.SetPixel(x, y, texture)
		Console.Write(texture)
		--Console.CursorLeft