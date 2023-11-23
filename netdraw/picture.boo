namespace netdraw

import System
import System.IO
import System.IO.Compression

public struct Pixel:
	
	public foreground as ConsoleColor
	public background as ConsoleColor
	public texture as char
	
enum CharEncoding:
	ASCII
	DCII
	UTF8
	UTF16

class Picture:
	
	static final private TEMP_DIR as string = "temp"
	static final private FILES = (TEMP_DIR + "/s", TEMP_DIR + "/f", TEMP_DIR + "/b", TEMP_DIR + "/t")
	static final public IMG_DIR = "img"
	
	private foreground as (ConsoleColor, 2)
	private background as (ConsoleColor, 2)
	private texture as (char, 2)
	
	private width as int
	private height as int
	
	private previousName as string
	
	private def Flatten[of T](rectArr as (T, 2)):
		
		result = List[of T]()
		
		for y in range(height):
			for x in range(width):
				result.Add(rectArr[y, x])
				
		return result.ToArray()
		
	private def Encrypt(colors as (ConsoleColor, 2)):
		
		result = List[of byte]()
		
		/*
			This algorithm isn't optimal in execution speed because I first
	    	translate the 2d array to a list, but it's optimal in simplicity.
	    	If I actually wanted to, I would take the time to devise a better
	    	way that is perhaps less simple but much faster. If anyone wants
	    	to do it themselves, I'm open to pull requests...
	    */
		flattenedArray = Flatten(colors)
		
		# RLE
		precedingValue = flattenedArray[0] cast byte
		quantity as byte = 1
		i = 1
		
		while i < flattenedArray.Length:
			
			if flattenedArray[i] == precedingValue and quantity != 16:
				++quantity
				
			else:
				
				result.Add((--quantity << 4) | precedingValue)
				precedingValue = flattenedArray[i] cast byte
				quantity = 1
				
			++i
		
		return result.ToArray()
		
	private def SplitInt(val as int):
			
		result = List[of byte]() 
		
		for i in (24, 16, 8, 0):
			result.Add((val >> i) cast byte)
			
		return result
		
	private def Decrypt(data as (byte)):
		
		result as (ConsoleColor, 2) = matrix(ConsoleColor, height, width)
		
		x = 0
		y = 0
		
		for datum in data:
			
			quantity = (datum >> 4) + 1
			color = (datum & 15) cast ConsoleColor
			
			while quantity > 0:
				
				result[y, x] = color
				--quantity
				
				if ++x == width:
					x = 0
					++y
		
		return result
		
	private def DeleteTemp():
		
		for file in FILES:
			File.Delete(file)
			
		Directory.Delete(TEMP_DIR)
		
	private static def GetBitSize(val as int) as byte:
		
		if val > ushort.MaxValue:
			return 2 # 32-bit
			
		if val > byte.MaxValue:
			return 1 # 16-bit
			
		return 0 # 8-bit
		
	private static def AddVariableByteQTY(list as List[of byte], val as int, size as byte):
		
		if size == 0:
			pass
		
	def constructor(fileName as string):
		
		if fileName.EndsWith(".ndi"):
			pass
		
	def constructor(width as int, height as int):
		
		foreground = matrix(ConsoleColor, height, width)
		background = matrix(ConsoleColor, height, width)
		texture = matrix(char, height, width)
		
		self.width = width
		self.height = height
		
	def Save(fileName as string):
		Save(fileName, CharEncoding.UTF16)
	
	/*
		Saves a compressed image using RLE with the following properties:
		
		8-bit header: defines the bit sizes of the height and width, also defines a char encoding
			- 0 custom
			- 1 dcii
			- 2 utf-8
			- 3 utf-16
			- from the right, width is the first bit pair and the height is the second
		after the header:
		x-bit width: how large the image is where x is the size specified in the header
		y-bit height: how long the image is where y is the size specified in the header
		8-bit width * height data chunk: colour of each foreground pixel
		8-bit width * height data chunk: colour of each background pixel
		z-bit width * height data chunk: character code point of each foreground pixel
	*/
	def Save(fileName as string, encoding as CharEncoding):
		
		# BEGIN: HEADER
		bytes = List[of byte]()
		
		header as byte = encoding cast byte << 4
		
		if height > byte.MaxValue:
			header |= 2 << 2
		
		else:
			header |= 1 << 1
			
		if width > byte.MaxValue:
			header |= 2
			
		else:
			header |= 1
			
		bytes.Add(header)
		# END: HEADER
			
	def Print():
		
		prevFG = Console.ForegroundColor
		prevBG = Console.BackgroundColor
		posX = Console.CursorLeft
		
		for y in range(height):
			
			Console.WriteLine()
			Console.CursorLeft = posX
			
			for x in range(width):
				
				Console.ForegroundColor = foreground[y, x]
				Console.BackgroundColor = background[y, x]
				Console.Write(texture[y, x])
			
		Console.ForegroundColor = prevFG
		Console.BackgroundColor = prevBG
				
	Width:
		get:
			return width
			
	Height:
		get:
			return height
			
	PreviousName:
		get:
			return previousName
			
	self[x as int, y as int]:
		get:
			return Pixel (
				foreground: self.foreground[y, x],
				background: self.background[y, x],
				texture: self.texture[y, x]
			)
		
	def SetPixel(x as int, y as int, texture as char):
		
		foreground[y, x] = Console.ForegroundColor
		background[y, x] = Console.BackgroundColor
		self.texture[y, x] = texture
		

