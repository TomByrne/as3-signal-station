package org.farmcode.sodalityPlatformEngine.behaviour.advice
{
	import au.com.thefarmdigital.behaviour.IBehavingItem;
	
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;

	public class AbstractBehaviourAdvice extends Advice implements IResolvePathsAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get behavingItem():IBehavingItem{
			return _behavingItem;
		}
		public function set behavingItem(value:IBehavingItem):void{
			_behavingItem = value;
		}
		[Property(toString="true",clonable="true")]
		public function get behavingItemPath():String{
			return _behavingItemPath;
		}
		public function set behavingItemPath(value:String):void{
			_behavingItemPath = value;
		}
		public function get resolvePaths():Array{
			return _behavingItem?[]:[_behavingItemPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			var behavingItem:IBehavingItem = value[_behavingItemPath];
			if(behavingItem)this.behavingItem = behavingItem;
		}
		
		private var _behavingItem:IBehavingItem;
		protected var _behavingItemPath:String;
		
		public function AbstractBehaviourAdvice(behavingItemPath:String=null, behavingItem:IBehavingItem=null){
			this.behavingItem = behavingItem;
			this.behavingItemPath = behavingItemPath;
		}
	}
}