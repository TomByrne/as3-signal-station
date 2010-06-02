package org.farmcode.sodalityLibrary.external.siteStream.advice
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;
	
	public class ResolvePathsAdvice extends Advice implements IResolvePathsAdvice
	{
		private var _resolvePaths:Array;
		private var _resolvedObjects:Dictionary;
		
		public function ResolvePathsAdvice(resolvePaths:Array=null){
			this.resolvePaths = resolvePaths;
		}
		
		[Property(toString="true",clonable="true")]
		public function get resolvePaths():Array{
			return _resolvePaths;
		}
		public function set resolvePaths(value:Array):void{
			_resolvePaths = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
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
		
		override public function clone() : Event{
			if(!_resolvedObjects)_resolvedObjects = new Dictionary();
			return super.clone();
		}
	}
}