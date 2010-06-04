package au.com.thefarmdigital.delayedDraw
{
	import flash.display.DisplayObject;
	
	public interface IDrawable
	{
		/**
		 * Perform all the pending drawing for the object
		 */
		function commitDraw():void;
		
		/**
		 * Get the display being drawn in to
		 */
		function get drawDisplay():DisplayObject;
		
		/**
		 * Is ready to be drawn (e.g. is on stage)
		 */
		function get readyForDraw():Boolean;
		
		/**
		 * The validate method will clear any calls to invalidate and call the draw method (if <code>invalidate()</code> has been called or if
		 * <code>forceDraw</code> is true). The <code>draw()</code> method should never be called directly, if you need immediate execution,
		 * call <code>validate(true);</code> (although it's not recommended to write code which relies on this).
		 * 
		 * @param forceDraw specifies whether draw() should be called regardless of whether the view is invalid.
		 */
		function validate(forceDraw: Boolean = false): void;
	}
}