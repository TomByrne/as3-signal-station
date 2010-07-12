package au.com.thefarmdigital.delayedDraw
{
	import org.farmcode.display.core.IScopedObject;
	
	public interface IDrawable extends IScopedObject
	{
		/**
		 * Perform all the pending drawing for the object
		 */
		function commitDraw():void;
		
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