package org.farmcode.display.assets
{
	import flash.text.TextFormat;
	
	import org.farmcode.acting.actTypes.IAct;

	public interface ITextFieldAsset extends IInteractiveObjectAsset
	{
		function set text(value:String):void;
		function get text():String;
		
		function set type(value:String):void;
		function get type():String;
		
		function set restrict(value:String):void;
		function get restrict():String;
		
		function set maxChars(value:int):void;
		function get maxChars():int;
		
		function set htmlText(value:String):void;
		function get htmlText():String;
		
		function set multiline(value:Boolean):void;
		function get multiline():Boolean;
		
		function set wordWrap(value:Boolean):void;
		function get wordWrap():Boolean;
		
		function set selectable(value:Boolean):void;
		function get selectable():Boolean;
		
		function set defaultTextFormat(value:TextFormat):void;
		function get defaultTextFormat():TextFormat;
		
		function set border(value:Boolean):void;
		function get border():Boolean;
		
		function get selectionBeginIndex():int;
		function get selectionEndIndex():int;
		
		function get textWidth():Number;
		function get textHeight():Number;
		function get maxScrollV():int;
		function get maxScrollH():int;
		function get bottomScrollV():int;
		
		
		/**
		 * handler(e:Event, from:IInteractiveObjectAsset)
		 */
		function get change():IAct;
		
		
		function setTextFormat(format:TextFormat, beginIndex:int  = -1, endIndex:int  = -1):void;
		function setSelection(beginIndex:int, endIndex:int):void;
	}
}