package org.tbyrne.actLibrary.external.siteStream.acts
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.external.siteStream.actTypes.IResolvePathsAct;
	import org.tbyrne.acting.acts.UniversalAct;
	
	public class ResolvePathsAct extends UniversalAct implements IResolvePathsAct
	{
		private var _resolvePaths:Array;
		private var _resolvedObjects:Dictionary;
		private var _resolveSuccessful:Boolean;
		
		public function ResolvePathsAct(resolvePaths:Array=null){
			this.resolvePaths = resolvePaths;
		}
		public function get resolvePaths():Array{
			return _resolvePaths;
		}
		public function set resolvePaths(value:Array):void{
			_resolvePaths = value;
		}
		
		
		public function get resolveSuccessful():Boolean{
			return _resolveSuccessful;
		}
		public function set resolveSuccessful(value:Boolean):void{
			_resolveSuccessful = value;
		}
		
		public function set resolvedObjects(value:Dictionary):void{
			if(_resolvedObjects && value){
				var i:*;
				for(i in _resolvedObjects){
					delete _resolvedObjects[i];
				}
				for(i in value){
					_resolvedObjects[i] = value[i];
				}
			}else{
				_resolvedObjects = value;
			}
		}
		public function get resolvedObjects():Dictionary{
			return _resolvedObjects;
		}
	}
}