package org.farmcode.sodalityPlatformEngine.scene
{
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	[Event(name="dispose", type="org.farmcode.sodalityPlatformEngine.scene.events.SceneEvent")]
	public interface IScene extends IEventDispatcher
	{
		function get id():String;
		function get items():Array;
		function get cameraBounds():Rectangle;
		function setFocused(value: Boolean, before: IAdvice = null, afterAdvice: IAdvice = null): void;
		//function getItem(id:String):ISceneItem;
		function dispose(before: IAdvice = null, after: IAdvice = null): void;
		function init(before:IAdvice = null, after: IAdvice = null): void;
	}
}