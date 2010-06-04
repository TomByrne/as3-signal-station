package org.farmcode.sodalityPlatformEngine.physics.adviceTypes
{
	import Box2D.Dynamics.b2Body;
	
	import org.farmcode.sodality.advice.IAdvice;

	public interface IAddContactListenerAdvice extends IAdvice
	{
		function get contactHandler():Function;
		function get contactBodies():Array;
	}
}