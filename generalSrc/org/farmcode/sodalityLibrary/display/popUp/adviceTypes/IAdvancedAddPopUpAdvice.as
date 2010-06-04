package org.farmcode.sodalityLibrary.display.popUp.adviceTypes
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	
	public interface IAdvancedAddPopUpAdvice extends IAddPopUpAdvice
	{
		function get popUpParent():DisplayObjectContainer;
		function get centre():Boolean;
		function get keepInCentre():Boolean;
		function get positioningOffsets():Point;
		function get bgFillColour():Number;
		function get bgAlpha():Number;
		function get bgTransitionTime():Number;
		function get focusable(): Boolean;
	}
}