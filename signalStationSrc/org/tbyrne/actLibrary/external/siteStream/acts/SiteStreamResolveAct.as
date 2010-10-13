package org.tbyrne.actLibrary.external.siteStream.acts
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.external.siteStream.actTypes.IResolvePathsAct;
	import org.tbyrne.acting.acts.UniversalAct;
	import org.tbyrne.hoborg.Cloner;
	
	public class SiteStreamResolveAct extends UniversalAct implements IResolvePathsAct
	{
		public function get resolvePath():String{
			return _resolvePath;
		}
		public function set resolvePath(value:String):void{
			_resolvePath = value;
		}
		
		public function get resolvedObject():*{
			return _resolvedObject;
		}
		public function set resolvedObject(value:*):void{
			_resolvedObject = value;
		}
		
		public function get resolveSuccessful():Boolean{
			return _resolveSuccessful;
		}
		public function set resolveSuccessful(value:Boolean):void{
			_resolveSuccessful = value;
		}
		
		private var _resolveSuccessful:Boolean;
		private var _resolvedObject:*;
		private var _resolvePath:String;
		
		public function SiteStreamResolveAct(resolvePath:String=null){
			this.resolvePath = resolvePath;
		}
		
		public function get resolvePaths():Array{
			return (!_resolvedObject && _resolvePath)?[_resolvePath]:[];
		}
		
		public function set resolvedObjects(value:Dictionary):void{
			_resolvedObject = value[_resolvePath];
		}
	}
}