package org.tbyrne.composeLibrary.tools.snapping
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.types.display3D.IPosition3dTrait;
	
	public interface ISnappableTrait extends IPosition3dTrait
	{
		function get snappingGroup():String;
		
		function get snappingActive():Boolean;
		/**
		 * handler(from:ISnappableTrait)
		 */
		function get snappingActiveChanged():IAct;
	}
}