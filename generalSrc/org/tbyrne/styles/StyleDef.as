package org.tbyrne.styles
{
	import flash.utils.Dictionary;

	public class StyleDef
	{
		/**
		 * Selectors can select combinations of Classes and style names,
		 * e.g.
		 * ClassName			< Just by class name
		 * |styleName			< Just by style name
		 * ClassName|styleName	< By Class name and style name
		 * 
		 */
		//TODO: Add functionality for nested selectors
		public var selectors:Vector.<String>;
		
		public var values:Dictionary;
	}
}