package org.farmcode.display.layout
{
	import org.farmcode.display.core.IView;

	public interface ILayout
	{
		function set scopeView(value:IView):void;
		function setLayoutSize(x:Number, y:Number, width:Number, height:Number):void;
		function addSubject(subject:ILayoutSubject):void;
		function removeSubject(subject:ILayoutSubject):void;
	}
}