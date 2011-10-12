package org.tbyrne.tbyrne.composeLibrary.away3d
{
	import away3d.containers.Scene3D;
	
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	
	public interface IAway3dAwareTrait extends ITrait
	{
		function set scene3d(value:Scene3D):void;
	}
}