package org.tbyrne.adjust
{
	import flash.utils.Dictionary;

	public class Adjustment
	{
		/**
		 * Selectors can select combinations of Classes and names,
		 * e.g.
		 * ClassName			< Just by class name
		 * |styleName			< Just by style name
		 * ClassName|styleName	< By Class name and style name
		 * 
		 */
		//TODO: Add functionality for nested selectors
		public var selectors:Vector.<String>;
		
		public var values:Dictionary;
		
		public function Adjustment(selectors:Array=null, values:Object=null){
			if(selectors!=null)this.selectors = Vector.<String>(selectors);
			if(values){
				this.values = new Dictionary();
				for(var i:String in values){
					this.values[i] = values[i];
				}
			}
		}
	}
}