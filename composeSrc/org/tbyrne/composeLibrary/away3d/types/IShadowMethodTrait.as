package org.tbyrne.composeLibrary.away3d.types
{
	import away3d.materials.methods.ShadingMethodBase;
	
	import org.tbyrne.compose.traits.ITrait;
	
	public interface IShadowMethodTrait extends ITrait
	{
		function get shadowMethod():ShadingMethodBase;
	}
}