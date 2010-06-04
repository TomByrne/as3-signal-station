package org.farmcode.display.layout
{
	public interface ILayout
	{
		function setLayoutSize(x:Number, y:Number, width:Number, height:Number):void;
		function addSubject(subject:ILayoutSubject):void;
		function removeSubject(subject:ILayoutSubject):void;
	}
}