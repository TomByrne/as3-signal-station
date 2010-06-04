package org.farmcode.sodalityPlatformEngine.physics.adviceTypes
{
	import Box2D.Dynamics.b2Body;
	
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.geom.Point;

	public interface IGetBodyAtPointAdvice extends IAdvice
	{
		function get worldPoint():Point;
		function set bodyAtPoint(value:b2Body):void;
		function get includeStatic():Boolean;
	}
}