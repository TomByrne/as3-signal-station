package org.farmcode.sodalityLibrary.external.siteStream.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;
	
	public class SiteStreamResolveAdvice extends Advice implements IResolvePathsAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get resolvePath():String{
			return _resolvePath;
		}
		public function set resolvePath(value:String):void{
			_resolvePath = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get resolvedObject():*{
			return _resolvedObject;
		}
		public function set resolvedObject(value:*):void{
			_resolvedObject = value;
		}
		
		private var _resolvedObject:*;
		private var _resolvePath:String;
		
		public function SiteStreamResolveAdvice(resolvePath:String=null){
			this.resolvePath = resolvePath;
		}
		
		public function get resolvePaths():Array{
			return (!_resolvedObject && _resolvePath)?[_resolvePath]:[];
		}
		
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			_resolvedObject = value[_resolvePath];
		}
	}
}