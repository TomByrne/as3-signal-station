package org.tbyrne.composeLibrary.away3d
{
	import away3d.containers.ObjectContainer3D;
	import away3d.lights.LightBase;
	
	import org.tbyrne.acting.actTypes.IAct;

	public interface IAway3dScene
	{
		
		/**
		 * handler(from:IAway3dScene)
		 */
		function get globalLightsChanged():IAct;
		function get globalLights():Array;
		
		function addChild(child:ObjectContainer3D):void;
		function removeChild(child:ObjectContainer3D):void;
		
		function addGlobalLight(child:LightBase):void;
		function removeGlobalLight(child:LightBase):void;
		
	}
}