package au.com.thefarmdigital.utils
{
	import flash.utils.ByteArray;
	
	public class ByteArrayUtils
	{
		public static function padArrayToBlockSize(array: ByteArray, numBits: uint, 
			padding: Number = 0x0): void
		{
			const BITS_PER_BYTE: uint = 8;
			
			if (numBits == 0)
			{
				throw new Error("Can't pad 0 bits");
			}
			else if (numBits % BITS_PER_BYTE != 0)
			{
				throw new Error("Can only pad bit values divisible by " + BITS_PER_BYTE);
			}
			else
			{			
				var blockSize: uint = numBits / BITS_PER_BYTE;
				
				var oldPosition: int = array.position;
				array.position = array.length;
				
				var totalLength: int = Math.ceil(array.length / blockSize) * blockSize;
				while (array.length < totalLength)
	            {
	            	array.writeByte(0); 
	            }
	            
	            array.position = oldPosition;
	  		}
		} 
	}
}