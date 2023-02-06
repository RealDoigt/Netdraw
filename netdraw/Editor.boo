namespace netdraw

import System
import ConsolePaint
import ConsolePaint.RectanglePainting

static partial class Editor:
	
	final BORDER_COLOR = ConsoleColor.White
	
	private enum Screens:
		Edit
		Help
		Save
		Pick
		Menu
			
	private enum DrawModes:
		Draw
		Type
		Fill
		PickFull # PickChar + PickFore + PickBack
		PickChar
		PickFore
		PickBack
		PickColors # PickFore + PickBack
		
	private enum ColorModes:
		Full # texture + fg + bg
		Fore # texture + fg + don't change bg
		Back # texture + don't change fg + bg
		None # texture + don't change fg and bg
		NoTexture # don't change texture + fg + bg
		NoTextureFore # only change fg
		NoTextureBack # only change bg
	
	private currentPixel as Pixel
	private currentScreen as Screens
	private currentPicture as Picture
	private currentDrawMode as DrawModes
	private currentColorMode as ColorModes
	
	private x as int
	private y as int
	
	private def Help():
		pass
		
	private def Pick():
		pass
		
	def Init(p as Picture):
		
		currentPicture = p
		currentScreen = Screens.Edit
		currentDrawMode = DrawModes.Draw
		currentColorMode = ColorModes.Full
		
		currentPixel = Pixel (
			
			foreground: ConsoleColor.Gray,
			background: ConsoleColor.Black,
			texture: char('█')
		)
		
		while currentScreen != Screens.Menu:
			
			if currentScreen == Screens.Edit:
				Edit()
				
			elif currentScreen == Screens.Help:
				Help()
				
			elif currentScreen == Screens.Save:
				Save()
				
			elif currentScreen == Screens.Pick:
				Pick()
				
			Console.CursorVisible = false
				
		currentPicture = null
		Console.Clear()
		
		
		
	