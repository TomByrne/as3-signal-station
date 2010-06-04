package org.farmcode.sodalityPlatformEngine.display.popUp.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.IScene;

	public interface IFocusOnSceneAdvice extends IAdvice
	{
		function get focused(): Boolean;
		
		function set performFocus(value: Boolean): void;
		function get performFocus(): Boolean;
		
		function get scene(): IScene;
	}
}