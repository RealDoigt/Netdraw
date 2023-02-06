namespace netdraw

import System
import System.IO
import ConsolePaint
import System.Drawing
import ConsolePaint.MenuMaking
import ConsolePaint.RectanglePainting

MENU_POS_X = Console.WindowWidth / 2 - 10
MENU_POS_Y = Console.WindowHeight / 2 - 3
BORDER_COLOR = ConsoleColor.White
PICTURE_MIN_SIZE = 2
BLANK = char(' ')

BACKGROUND = ConsoleImage(Bitmap("bg.png"))

def drawBackground():
	
	y = 0
	while y + BACKGROUND.Height < Console.WindowHeight:
		
		x = 0
		while x + BACKGROUND.Width < Console.WindowWidth:
			
			BACKGROUND.PaintAt(x, y)
			x += BACKGROUND.Width
			
		y += BACKGROUND.Height

def increment(i as int, windowSize as int):
		
	++i
	
	# capped to byte max because ConsolePaint has an inconvenient limitation
	if i < windowSize and i < byte.MaxValue:
		return i
		
	return Math.Min(windowSize, byte.MaxValue cast int)
	
def decrement(i as int):
		
	--i
	
	if i >= PICTURE_MIN_SIZE:
		return i
		
	return PICTURE_MIN_SIZE
	
def adjustSize(ref i as int, windowSize as int):
	
	stepShift = 9 # is really 10
	stepControl = 24 # is really 25
	
	DrawRectangle (
		
		BorderType.Single,
		0, # x
		0, # y
		5, # height
		Console.WindowWidth cast byte,
		BORDER_COLOR
    )
	
	Console.SetCursorPosition(1, 1)
	shouldContinue = true
	
	print "Press enter to return"
	
	Console.CursorLeft = 1
	print "Go faster with shift or control"
	
	arrow = "♦"
	
	while shouldContinue:
		
		Console.CursorLeft = 1 # last two spaces are a lazy erase
		Console.Write("Press up/down to increase/decrease: $arrow$i  ")
		
		input = Console.ReadKey(true)
		
		if input.Key == ConsoleKey.UpArrow:
			
			if input.Modifiers & ConsoleModifiers.Shift != 0:
				i += stepShift
				
			elif input.Modifiers & ConsoleModifiers.Control != 0:
				i += stepControl
			
			i = increment(i, windowSize)
			arrow = "▲"
			
		elif input.Key == ConsoleKey.DownArrow:
			
			if input.Modifiers & ConsoleModifiers.Shift != 0:
				i -= stepShift
				
			elif input.Modifiers & ConsoleModifiers.Control != 0:
				i -= stepControl
			
			i = decrement(i)
			arrow = "▼"
			
		elif input.Key == ConsoleKey.Enter:
			shouldContinue = false
			
		# to let the user know that they're not pressing one of the accepted input keys
		else:
			arrow = "♦"
	
def editNewImage():
	
	sizeX = 10
	sizeY = 10
	
	# TODO: Fix the bug in editor.edit because this border space wastes space 
	borderSpace = 3
	
	drawBackground()
	
	editActions = (
		
		{adjustSize(sizeX, Console.WindowWidth - borderSpace)}, 
		{adjustSize(sizeY, Console.WindowHeight - borderSpace)}, 
		{Editor.Init(Picture(sizeX, sizeY))}
	)
	
	editOptions = ("Change Width", "Change Height", "Create!")
	
	MakeBorderedUL (
	
		MENU_POS_X, 
		MENU_POS_Y, 
		editOptions,
		BLANK,
		BorderType.Single, 
		BORDER_COLOR
	)
	
	while true:
		
		selection = GetSelection(MENU_POS_X + 1, MENU_POS_Y + 1, editOptions.Length)
		editActions[selection]()
		
		if selection + 1 == editActions.Length:
			return
	
def editExistingImage():
	
	drawBackground()
	
	if not Directory.Exists(Picture.IMG_DIR):
		return
		
	files = Directory.GetFiles(Picture.IMG_DIR)
	
	for f in files:
		f = f[Picture.IMG_DIR.Length + 1:]
	
	if files.Length < 1:
		return
		
	MakeBorderedUL (
	
		MENU_POS_X, 
		MENU_POS_Y, 
		files,
		BLANK,
		BorderType.Single, 
		BORDER_COLOR
	)
	
	#Picture(files[GetSelection(MENU_POS_X + 1, MENU_POS_Y + 1, files.Length)])
	Editor.Init(Picture(files[GetSelection(MENU_POS_X + 1, MENU_POS_Y + 1, files.Length)]))

Console.Title = "Netdraw"
Console.CursorVisible = false
Console.TreatControlCAsInput = true

# The default brush would have been a global constant if I could;
# change line 95 of Editor.Edit() if you change the brush here
Painting.brush = char('\'')

shouldStop = false
options = ("New File", "Load File", "Quit")
actions = (editNewImage, editExistingImage, {shouldStop = true})

while not shouldStop:

	drawBackground()
	
	MakeBorderedUL (
	
		MENU_POS_X, 
		MENU_POS_Y, 
		options,
		BLANK,
		BorderType.Single, 
		BORDER_COLOR
	)
	
	actions[GetSelection(MENU_POS_X + 1, MENU_POS_Y + 1, options.Length)]()

Console.Clear()
Console.CursorVisible = true
