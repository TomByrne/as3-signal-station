package org.tbyrne.composeLibrary.away3d
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.lights.LightBase;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	
	public class Away3dSceneProxy implements IAway3dScene
	{
		
		/**
		 * @inheritDoc
		 */
		public function get globalLightsChanged():IAct{
			return (_globalLightsChanged || (_globalLightsChanged = new Act()));
		}
		
		protected var _globalLightsChanged:Act;
		
		
		public function get globalLights():Array{
			return _lights;
		}
		
		
		private var _scene:Scene3D;
		private var _lights:Array = [];
		
		
		public function Away3dSceneProxy(scene:Scene3D){
			_scene = scene;
		}
		
		public function addChild(child:ObjectContainer3D):void{
			_scene.addChild(child);
		}
		public function removeChild(child:ObjectContainer3D):void{
			_scene.removeChild(child);
		}
		
		public function addGlobalLight(child:LightBase):void{
			if(_lights.indexOf(child)==-1){
				_scene.addChild(child);
				_lights.push(child);
				if(_globalLightsChanged)_globalLightsChanged.perform(this);
			}
		}
		public function removeGlobalLight(child:LightBase):void{
			var index:int = _lights.indexOf(child);
			if(index!=-1){
				_scene.removeChild(child);
				_lights.splice(index,1);
				if(_globalLightsChanged)_globalLightsChanged.perform(this);
			}
		}
	}
}