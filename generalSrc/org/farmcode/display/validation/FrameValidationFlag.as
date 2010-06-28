package org.farmcode.display.validation
{
	/**
	 * - Tag something as invalid, associated with a display object.
	 * - on frame enter, traverse down heirarchy, drawing DOs
	 * - When Flag gets manually validated, it should also validate children in heirarchy
	 * - If invalidating during draw (and included in current draw):
	 * 		- If already validated this draw, add to next frames list
	 * 		- If not, ignore.
	 * - If manually validate during draw:
	 * 		- immediately validate I guess
	 * 
	 */
	
	
	public class FrameValidationFlag extends ValidationFlag
	{
		public function FrameValidationFlag(validator:Function, valid:Boolean)
		{
			super(validator, valid);
		}
	}
}