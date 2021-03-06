package org.tbyrne.display.assets.nativeTypes
{
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	import org.tbyrne.acting.actTypes.IAct;

	public interface ITextField extends IInteractiveObject
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
		
		function set displayAsPassword(value:Boolean):void;
		function get displayAsPassword():Boolean;
		
		function set selectable(value:Boolean):void;
		function get selectable():Boolean;
		
		function set defaultTextFormat(value:TextFormat):void;
		function get defaultTextFormat():TextFormat;
		
		function set border(value:Boolean):void;
		function get border():Boolean;
		
		function set embedFonts(value:Boolean):void;
		function get embedFonts():Boolean;
		
		function set autoSize(value:String):void;
		function get autoSize():String;
		
		function get selectionBeginIndex():int;
		function get selectionEndIndex():int;
		
		function get textWidth():Number;
		function get textHeight():Number;
		function get maxScrollV():int;
		function get maxScrollH():int;
		function get bottomScrollV():int;
		
		
		/**
		 * handler(from:ITextField)
		 */
		function get change():IAct;
		
		/**
		 * handler(from:ITextField)
		 */
		function get userChange():IAct;
		
		
		function setTextFormat(format:TextFormat, beginIndex:int  = -1, endIndex:int  = -1):void;
		function setSelection(beginIndex:int, endIndex:int):void;
		function appendText(text:String):void;
		function getCharIndexAtPoint(x:Number, y:Number):int;
		function getCharBoundaries(charIndex:int):Rectangle;
		function getLineMetrics(lineIndex:int):TextLineMetrics;
	}
}