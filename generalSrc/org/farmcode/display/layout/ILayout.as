package org.farmcode.display.layout
{
	import org.farmcode.display.core.IView;

	public interface ILayout
	{
		function set scopeView(value:IView):void;
		
		// TODO: split into size and position calls
		function setLayoutSize(x:Number, y:Number, width:Number, height:Number):void;
		function validate(forceDraw:Boolean=false):void;
		
		/**
		 * returns true if subject was successfully added
		 */
		function addSubject(subject:ILayoutSubject):Boolean;
		/**
		 * returns true if subject was successfully removed
		 */
		function removeSubject(subject:ILayoutSubject):Boolean;
	}
}