package org.tbyrne.composeLibrary.tools.snapping
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.display3D.types.IPosition3dTrait;
	
	public interface ISnappableTrait extends ITrait
	{
		
		function get snappingActive():Boolean;
		/**
		 * handler(from:ISnappableTrait)
		 */
		function get snappingActiveChanged():IAct;
		
		function get snapPoints():Vector.<ISnapPoint>;
	}
}