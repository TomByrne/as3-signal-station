package org.farmcode.sodalityLibrary.control
{
	import flash.display.InteractiveObject;
	
	public interface IControlScheme
	{
		function set controllable(value:IControllable):void;
		function set root(value:InteractiveObject):void;
	}
}