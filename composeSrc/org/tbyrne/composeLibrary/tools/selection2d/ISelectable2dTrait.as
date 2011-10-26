package org.tbyrne.composeLibrary.tools.selection2d
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
	public interface ISelectable2dTrait extends ITrait
	{
		
		function checkPoint(x:Number, y:Number):Boolean;
		function checkRectangle(x:Number, y:Number, width:Number, height:Number):Number;
		
		function setSelected(selected:Boolean):void;
		function setInterested(selected:Boolean):void;
	}
}