package org.farmcode.sodalityPlatformEngine.core
{
	import flash.geom.Rectangle;
	
	import org.farmcode.sodalityPlatformEngine.display.DisplayLayer;
	

	public interface IApplicationData
	{
		function get advisors():Array;
		function get initialAdvice():Array;
		function get minAppSize():Rectangle;
		function get scaleBelowMin():Boolean;
		function get rootDisplay():DisplayLayer;
	}
}