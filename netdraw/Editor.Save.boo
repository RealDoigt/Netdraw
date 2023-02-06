namespace netdraw

import System
import ConsolePaint
import ConsolePaint.MenuMaking
import ConsolePaint.RectanglePainting

static partial class Editor:
	
	final NAME_BOX_Y = 6
	final NAME_WIDTH_MAX = 20
	
	final WARNING_FG = ConsoleColor.Red
	final WARNING_BG = ConsoleColor.Black
	final WARNING_FG2 = ConsoleColor.Yellow
	final WARNING_BG2 = ConsoleColor.DarkRed
	
	final WARNING_BOX_X = 22
	final WARNING_TEXT_X = 23
	final WARNING_BOX_HEIGHT = 9
	final WARNING_BOX_WIDTH = 30
	
	private def ConfirmOverwrite():
		
		Console.CursorVisible = false
					
		DrawRectangle (

			BorderType.Dotted,
			WARNING_BOX_X,
			NAME_BOX_Y,
			WARNING_BOX_HEIGHT,
			WARNING_BOX_WIDTH,
			WARNING_BG2
		)
		
		warning = (
		
			ColorString(WARNING_BG, WARNING_FG, "Warning! This will "),
			ColorString(WARNING_BG2, WARNING_FG2, "overwrite\n"),
			ColorString(WARNING_BG, WARNING_FG, "an existing file, are you\n"),
			ColorString(WARNING_BG, WARNING_FG, "sure you want to "),
			ColorString(WARNING_BG2, WARNING_FG2, "overwrite\n"),
			ColorString(WARNING_BG2, WARNING_FG2, "it?")
		)
		
		# next to the name box
		Console.SetCursorPosition(WARNING_TEXT_X, NAME_BOX_Y + 1)
		
		for str in warning:
			
			str.Write()
			
			# we don't want to reset x when there's no line break
			if str.ToString().EndsWith("\n"):
				Console.CursorLeft = WARNING_TEXT_X
		
		
		MakeUnorderedList (
		
			WARNING_TEXT_X, 
			NAME_BOX_Y + warning.Length, 
			("No", "Yes"),
			char(' '),
			1
		)
		
		return GetSelection(WARNING_TEXT_X, NAME_BOX_Y + warning.Length, 2) == 1
		
	private def Save():
		
		Console.Clear()
		
		# resets to prevent colour contamination from the editing
		Console.ResetColor()
		
		lines = (
		
			"Type the name of the file without the extension.",
			"Press enter to continue or escape to cancel.",
			"If a file of the same name already exists, you",
			"will be asked if you want to overwrite the file."
		)
		
		MakeBorderedOL (
		
			0, # x
			0, # y
			lines,
			BorderType.Single,
			BORDER_COLOR
		)
		
		DrawRectangle (
			
			BorderType.Single,
			0, # x
			NAME_BOX_Y,
			3, # height
			NAME_WIDTH_MAX + 1,
			BORDER_COLOR
		)
		
		Console.SetCursorPosition(14, 6)
		Console.Write("┤.ndi├")
		
		Console.SetCursorPosition(1, 7)
		fileName = ""
		
		if currentPicture.PreviousName != null:
			fileName = currentPicture.PreviousName
		
		Console.CursorLeft = 1
		Console.Write(fileName)
		Console.CursorVisible = true
		
		while currentScreen == Screens.Save:
			
			input = Console.ReadKey(true)
			
			if input.Key == ConsoleKey.Escape:
				currentScreen = Screens.Edit
				
			elif input.Key == ConsoleKey.Enter:
				
				if IO.File.Exists("img/$(fileName).ndi"):
					if ConfirmOverwrite():
						currentPicture.Save(fileName)
						
				else:
					currentPicture.Save(fileName)
				
				currentScreen = Screens.Edit
				
			elif input.Key == ConsoleKey.Backspace:
				
				if fileName.Length > 0:
					
					fileName = fileName[0:fileName.Length - 1]
					
					--Console.CursorLeft
					Console.Write(" ")
					--Console.CursorLeft
					
			else:
				
				if fileName.Length <= NAME_WIDTH_MAX:
					
					fileName += input.KeyChar
					Console.Write(input.KeyChar)
				
				
			