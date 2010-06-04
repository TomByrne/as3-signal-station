package au.com.thefarmdigital.sound
{
	public class SoundError extends Error
	{
		public function SoundError(message:String="", id:int=0){
			super(message, id);
		}
		
	}
}