package org.tbyrne.composeLibrary.away3d.types
{
	import away3d.containers.Scene3D;
	
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.away3d.IAway3dScene;
	
	public interface IScene3dAwareTrait extends ITrait
	{
		function set scene3d(value:IAway3dScene):void;
	}
}