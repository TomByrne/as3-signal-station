package org.tbyrne.composeLibrary.away3d.types
{
	import away3d.lights.LightBase;
	
	import org.tbyrne.compose.traits.ITrait;
	
	public interface ILight3dTrait extends ITrait
	{
		function get light():LightBase;
	}
}