package org.tbyrne.composeLibrary.away3d.types
{
	import away3d.materials.MaterialBase;
	
	import org.tbyrne.compose.traits.ITrait;
	
	public interface IMaterial3dTrait extends ITrait
	{
		function get material3d():MaterialBase;
	}
}